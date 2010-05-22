Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CCA186B01B6
	for <linux-mm@kvack.org>; Sat, 22 May 2010 14:09:01 -0400 (EDT)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-03.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 22 May 2010 18:08:57 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH 3/3] mm: Swap checksum
Date: Sat, 22 May 2010 15:08:51 -0300
Message-Id: <1274551731-4534-3-git-send-email-cesarb@cesarb.net>
In-Reply-To: <4BF81D87.6010506@cesarb.net>
References: <4BF81D87.6010506@cesarb.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Cesar Eduardo Barros <cesarb@cesarb.net>
List-ID: <linux-mm.kvack.org>

Add support for checksumming the swap pages written to disk, using the
same checksum as btrfs (crc32c). Since the contents of the swap do not
matter after a shutdown, the checksum is kept in memory only.

Note that this code does not checksum the software suspend image.

Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 include/linux/swap.h |   30 +++++++++
 mm/Kconfig           |   22 ++++++
 mm/Makefile          |    1 +
 mm/page_io.c         |   90 +++++++++++++++++++++++---
 mm/swapcsum.c        |   94 ++++++++++++++++++++++++++
 mm/swapfile.c        |  178 +++++++++++++++++++++++++++++++++++++++++++++++++-
 6 files changed, 404 insertions(+), 11 deletions(-)
 create mode 100644 mm/swapcsum.c

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 86a0d64..92b24d4 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -15,6 +15,9 @@
 struct notifier_block;
 
 struct bio;
+struct bio_vec;
+
+struct workqueue_struct;
 
 #define SWAP_FLAG_PREFER	0x8000	/* set if swap priority specified */
 #define SWAP_FLAG_PRIO_MASK	0x7fff
@@ -180,6 +183,10 @@ struct swap_info_struct {
 	struct swap_extent *curr_swap_extent;
 	struct swap_extent first_swap_extent;
 	struct block_device *bdev;	/* swap device or bdev of swap file */
+#ifdef CONFIG_SWAP_CHECKSUM
+	unsigned short *csum_count;	/* usage count of a csum page */
+	u32 **csum;			/* vmalloc'ed array of swap csums */
+#endif
 	struct file *swap_file;		/* seldom referenced */
 	unsigned int old_block_size;	/* seldom referenced */
 };
@@ -369,6 +376,29 @@ static inline void mem_cgroup_uncharge_swap(swp_entry_t ent)
 }
 #endif
 
+#ifdef CONFIG_SWAP_CHECKSUM
+/* linux/mm/swapfile.c */
+extern int swap_csum_set(swp_entry_t entry, u32 crc);
+extern int swap_csum_get(swp_entry_t entry, u32 *crc);
+
+/* linux/mm/swapcsum.c */
+extern bool noswapcsum __read_mostly;
+extern bool swap_csum_verify(struct page *page);
+extern struct workqueue_struct *swapcsum_workqueue;
+#else
+#define noswapcsum true
+#endif
+
+/* linux/mm/swapcsum.c */
+extern int _swap_csum_write(struct page *page);
+
+static inline int swap_csum_write(struct page *page)
+{
+	if (noswapcsum)
+		return 0;
+	return _swap_csum_write(page);
+}
+
 #else /* CONFIG_SWAP */
 
 #define nr_swap_pages				0L
diff --git a/mm/Kconfig b/mm/Kconfig
index 9c61158..890faf4 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -287,3 +287,25 @@ config NOMMU_INITIAL_TRIM_EXCESS
 	  of 1 says that all excess pages should be trimmed.
 
 	  See Documentation/nommu-mmap.txt for more information.
+
+config SWAP_CHECKSUM
+	bool "Swap checksum"
+	depends on SWAP && EXPERIMENTAL
+	select LIBCRC32C
+	default n
+	help
+	  This option enables checksumming of swap pages when saved to disk.
+
+	  Use the kernel command line options "swapcsum" to enable and
+	  "noswapcsum" to disable. The default value is configurable.
+
+	  Note that this option does not checksum the software suspend image.
+
+config SWAP_CHECKSUM_DEFAULT
+	bool "Enable swap checksum by default"
+	depends on SWAP_CHECKSUM
+	default y
+	help
+	  You can use the kernel command line options "swapcsum" to enable and
+	  "noswapcsum" to disable swap checksumming. This option controls the
+	  default value.
diff --git a/mm/Makefile b/mm/Makefile
index 6c2a73a..677bc43 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -17,6 +17,7 @@ obj-y += init-mm.o
 
 obj-$(CONFIG_BOUNCE)	+= bounce.o
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
+obj-$(CONFIG_SWAP_CHECKSUM)	+= swapcsum.o
 obj-$(CONFIG_HAS_DMA)	+= dmapool.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
 obj-$(CONFIG_NUMA) 	+= mempolicy.o
diff --git a/mm/page_io.c b/mm/page_io.c
index 0e2d4e8..ed0a856 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -18,6 +18,8 @@
 #include <linux/bio.h>
 #include <linux/swapops.h>
 #include <linux/writeback.h>
+#include <linux/workqueue.h>
+#include <linux/slab.h>
 #include <asm/pgtable.h>
 
 static struct bio *get_swap_bio(gfp_t gfp_flags,
@@ -66,22 +68,71 @@ static void end_swap_bio_write(struct bio *bio, int err)
 	bio_put(bio);
 }
 
+static void end_swap_page_read_error(struct page *page)
+{
+	SetPageError(page);
+	ClearPageUptodate(page);
+	unlock_page(page);
+}
+
+static void end_swap_page_read(struct page *page)
+{
+	SetPageUptodate(page);
+	unlock_page(page);
+}
+
+struct swap_readpage_csum_work {
+	struct work_struct work;
+	struct page *page;
+};
+
+#ifdef CONFIG_SWAP_CHECKSUM
+static void swap_readpage_csum_work_func(struct work_struct *work)
+{
+	struct swap_readpage_csum_work *csum_work =
+		container_of(work, struct swap_readpage_csum_work, work);
+	struct page *page = csum_work->page;
+
+	kfree(csum_work);
+
+	if (unlikely(!swap_csum_verify(page)))
+		end_swap_page_read_error(page);
+	else
+		end_swap_page_read(page);
+}
+
+static void swap_readpage_queue_csum_work(struct page *page, void *bi_private)
+{
+	struct swap_readpage_csum_work *csum_work = bi_private;
+
+	INIT_WORK(&csum_work->work, swap_readpage_csum_work_func);
+	csum_work->page = page;
+	queue_work(swapcsum_workqueue, &csum_work->work);
+}
+#else
+/* The call to this function should be optimized out. */
+extern void swap_readpage_queue_csum_work(struct page *page, void *bi_private);
+#endif
+
 static void end_swap_bio_read(struct bio *bio, int err)
 {
 	const int uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
 	struct page *page = bio->bi_io_vec[0].bv_page;
 
 	if (!uptodate) {
-		SetPageError(page);
-		ClearPageUptodate(page);
+		if (!noswapcsum)
+			kfree(bio->bi_private);
+		end_swap_page_read_error(page);
 		printk(KERN_ALERT "Read-error on swap-device (%u:%u:%Lu)\n",
 				imajor(bio->bi_bdev->bd_inode),
 				iminor(bio->bi_bdev->bd_inode),
 				(unsigned long long)bio->bi_sector);
 	} else {
-		SetPageUptodate(page);
+		if (noswapcsum)
+			end_swap_page_read(page);
+		else
+			swap_readpage_queue_csum_work(page, bio->bi_private);
 	}
-	unlock_page(page);
 	bio_put(bio);
 }
 
@@ -100,11 +151,12 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
 	}
 	bio = get_swap_bio(GFP_NOIO, page, end_swap_bio_write);
 	if (bio == NULL) {
-		set_page_dirty(page);
-		unlock_page(page);
 		ret = -ENOMEM;
-		goto out;
+		goto out_error;
 	}
+	ret = swap_csum_write(page);
+	if (unlikely(ret))
+		goto out_error_put;
 	if (wbc->sync_mode == WB_SYNC_ALL)
 		rw |= (1 << BIO_RW_SYNCIO) | (1 << BIO_RW_UNPLUG);
 	count_vm_event(PSWPOUT);
@@ -113,6 +165,13 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
 	submit_bio(rw, bio);
 out:
 	return ret;
+
+out_error_put:
+	bio_put(bio);
+out_error:
+	set_page_dirty(page);
+	unlock_page(page);
+	goto out;
 }
 
 int swap_readpage(struct page *page)
@@ -124,12 +183,25 @@ int swap_readpage(struct page *page)
 	VM_BUG_ON(PageUptodate(page));
 	bio = get_swap_bio(GFP_KERNEL, page, end_swap_bio_read);
 	if (bio == NULL) {
-		unlock_page(page);
 		ret = -ENOMEM;
-		goto out;
+		goto out_error;
+	}
+	if (!noswapcsum) {
+		bio->bi_private = kmalloc(
+			sizeof(struct swap_readpage_csum_work), GFP_KERNEL);
+		if (unlikely(!bio->bi_private)) {
+			ret = -ENOMEM;
+			goto out_error_put;
+		}
 	}
 	count_vm_event(PSWPIN);
 	submit_bio(READ, bio);
 out:
 	return ret;
+
+out_error_put:
+	bio_put(bio);
+out_error:
+	unlock_page(page);
+	goto out;
 }
diff --git a/mm/swapcsum.c b/mm/swapcsum.c
new file mode 100644
index 0000000..98ba97d
--- /dev/null
+++ b/mm/swapcsum.c
@@ -0,0 +1,94 @@
+#include <linux/crc32c.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/pagemap.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
+#include <linux/workqueue.h>
+
+#ifdef CONFIG_SWAP_CHECKSUM_DEFAULT
+#define NOSWAPCSUM_DEFAULT false
+#else
+#define NOSWAPCSUM_DEFAULT true
+#endif
+
+bool noswapcsum __read_mostly = NOSWAPCSUM_DEFAULT;
+
+static int __init swap_csum_enable(char *s)
+{
+	noswapcsum = false;
+	return 1;
+}
+__setup("swapcsum", swap_csum_enable);
+
+static int __init swap_csum_disable(char *s)
+{
+	noswapcsum = true;
+	return 1;
+}
+__setup("noswapcsum", swap_csum_disable);
+
+static u32 swap_csum_page(struct page *page)
+{
+	void *address;
+	u32 crc;
+
+	address = kmap_atomic(page, KM_USER0);
+	crc = ~crc32c(~(u32)0, address, PAGE_SIZE);
+	kunmap_atomic(address, KM_USER0);
+	return crc;
+}
+
+int _swap_csum_write(struct page *page)
+{
+	swp_entry_t entry;
+
+	VM_BUG_ON(!PageSwapCache(page));
+
+	entry.val = page_private(page);
+	return swap_csum_set(entry, swap_csum_page(page));
+}
+
+bool swap_csum_verify(struct page *page)
+{
+	swp_entry_t entry;
+	u32 crc, old_crc;
+
+	VM_BUG_ON(!PageSwapCache(page));
+
+	entry.val = page_private(page);
+
+	if (unlikely(swap_csum_get(entry, &old_crc))) {
+		printk(KERN_ALERT "Missing swap checksum for page "
+			"type %u offset %lu\n",
+			swp_type(entry), swp_offset(entry));
+		WARN_ON(true);
+		return false;
+	}
+
+	crc = swap_csum_page(page);
+	if (unlikely(crc != old_crc)) {
+		printk(KERN_ALERT "Wrong swap checksum for page "
+			"type %u offset %lu (0x%08x != 0x%08x)\n",
+			swp_type(entry), swp_offset(entry),
+			(unsigned)crc, (unsigned)old_crc);
+		return false;
+	}
+
+	return true;
+}
+
+struct workqueue_struct *swapcsum_workqueue;
+
+/* TODO: create the workqueue on swapon, destroy the workqueue on swapoff */
+static int __init swap_csum_init(void)
+{
+	if (noswapcsum)
+		return 0;
+
+	swapcsum_workqueue = create_workqueue("swapcsum");
+	BUG_ON(!swapcsum_workqueue);
+	return 0;
+}
+module_init(swap_csum_init)
diff --git a/mm/swapfile.c b/mm/swapfile.c
index af7d499..50d1cce 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -63,6 +63,50 @@ static inline unsigned char swap_count(unsigned char ent)
 	return ent & ~SWAP_HAS_CACHE;	/* may include SWAP_HAS_CONT flag */
 }
 
+#ifdef CONFIG_SWAP_CHECKSUM
+/*
+ * The swap checksums are stored in checksum pages, with CSUMS_PER_PAGE
+ * checksums per page. The checksum pages are allocated on the first
+ * write, and freed when none of the pages with checksums on that
+ * checksum page is in use anymore.
+ *
+ * To simplify the freeing of the checksum pages, si->csum_count has a
+ * count of the in-use pages corresponding to that checksum page. For
+ * the purpose of this count, pages with any count other than 0 or
+ * SWAP_MAP_BAD are in use.
+ */
+
+#define CSUMS_PER_PAGE (PAGE_SIZE / sizeof(u32))
+
+static void __swap_csum_count_inc(struct swap_info_struct *si,
+					unsigned long offset)
+{
+	if (noswapcsum)
+		return;
+
+	++si->csum_count[offset / CSUMS_PER_PAGE];
+}
+
+static void __swap_csum_count_dec(struct swap_info_struct *si,
+					unsigned long offset)
+{
+	if (noswapcsum)
+		return;
+
+	BUG_ON(!si->csum_count[offset / CSUMS_PER_PAGE]);
+
+	if (!--si->csum_count[offset / CSUMS_PER_PAGE]) {
+		free_page((unsigned long)si->csum[offset / CSUMS_PER_PAGE]);
+		si->csum[offset / CSUMS_PER_PAGE] = NULL;
+	}
+}
+#else
+static inline void __swap_csum_count_inc(struct swap_info_struct *si,
+					unsigned long offset) { }
+static inline void __swap_csum_count_dec(struct swap_info_struct *si,
+					unsigned long offset) { }
+#endif
+
 /* returns 1 if swap entry is freed */
 static int
 __try_to_reclaim_swap(struct swap_info_struct *si, unsigned long offset)
@@ -340,6 +384,7 @@ checks:
 		si->highest_bit = 0;
 	}
 	si->swap_map[offset] = usage;
+	__swap_csum_count_inc(si, offset);
 	si->cluster_next = offset + 1;
 	si->flags -= SWP_SCANNING;
 
@@ -500,7 +545,7 @@ swp_entry_t get_swap_page_of_type(int type)
 	return (swp_entry_t) {0};
 }
 
-static struct swap_info_struct *swap_info_get(swp_entry_t entry)
+static struct swap_info_struct *swap_info_get_unlocked(swp_entry_t entry)
 {
 	struct swap_info_struct *p;
 	unsigned long offset, type;
@@ -518,7 +563,6 @@ static struct swap_info_struct *swap_info_get(swp_entry_t entry)
 		goto bad_offset;
 	if (!p->swap_map[offset])
 		goto bad_free;
-	spin_lock(&swap_lock);
 	return p;
 
 bad_free:
@@ -536,6 +580,14 @@ out:
 	return NULL;
 }
 
+static struct swap_info_struct *swap_info_get(swp_entry_t entry)
+{
+	struct swap_info_struct *p = swap_info_get_unlocked(entry);
+	if (likely(p))
+		spin_lock(&swap_lock);
+	return p;
+}
+
 static unsigned char swap_entry_free(struct swap_info_struct *p,
 				     swp_entry_t entry, unsigned char usage)
 {
@@ -574,6 +626,8 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 
 	/* free if no reference */
 	if (!usage) {
+		__swap_csum_count_dec(p, offset);
+
 		if (offset < p->lowest_bit)
 			p->lowest_bit = offset;
 		if (offset > p->highest_bit)
@@ -1525,6 +1579,10 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 {
 	struct swap_info_struct *p = NULL;
 	unsigned char *swap_map;
+#ifdef CONFIG_SWAP_CHECKSUM
+	unsigned short *csum_count;
+	u32 **csum;
+#endif
 	struct file *swap_file, *victim;
 	struct address_space *mapping;
 	struct inode *inode;
@@ -1639,10 +1697,18 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	p->max = 0;
 	swap_map = p->swap_map;
 	p->swap_map = NULL;
+#ifdef CONFIG_SWAP_CHECKSUM
+	csum_count = p->csum_count;
+	csum = p->csum;
+#endif
 	p->flags = 0;
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
 	vfree(swap_map);
+#ifdef CONFIG_SWAP_CHECKSUM
+	vfree(csum_count);
+	vfree(csum);
+#endif
 	/* Destroy swap account informatin */
 	swap_cgroup_swapoff(type);
 
@@ -1798,6 +1864,11 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	unsigned long maxpages;
 	unsigned long swapfilepages;
 	unsigned char *swap_map = NULL;
+#ifdef CONFIG_SWAP_CHECKSUM
+	unsigned long csum_pages = 0;
+	unsigned short *csum_count = NULL;
+	u32 **csum = NULL;
+#endif
 	struct page *page = NULL;
 	struct inode *inode = NULL;
 	int did_down = 0;
@@ -1983,7 +2054,34 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		goto bad_swap;
 	}
 
+#ifdef CONFIG_SWAP_CHECKSUM
+	if (!noswapcsum) {
+		csum_pages = DIV_ROUND_UP(maxpages, CSUMS_PER_PAGE);
+
+		csum = vmalloc(csum_pages * sizeof(*csum));
+		if (!csum) {
+			error = -ENOMEM;
+			goto bad_swap;
+		}
+
+		csum_count = vmalloc(csum_pages * sizeof(*csum_count));
+		if (!csum_count) {
+			error = -ENOMEM;
+			goto bad_swap;
+		}
+	}
+
+	p->csum_count = csum_count;
+	p->csum = csum;
+#endif
+
 	memset(swap_map, 0, maxpages);
+#ifdef CONFIG_SWAP_CHECKSUM
+	if (!noswapcsum) {
+		memset(csum_count, 0, csum_pages * sizeof(*csum_count));
+		memset(csum, 0, csum_pages * sizeof(*csum));
+	}
+#endif
 	nr_good_pages = maxpages - 1;	/* omit header page */
 
 	for (i = 0; i < swap_header->info.nr_badpages; i++) {
@@ -2076,6 +2174,10 @@ bad_swap_2:
 	p->flags = 0;
 	spin_unlock(&swap_lock);
 	vfree(swap_map);
+#ifdef CONFIG_SWAP_CHECKSUM
+	vfree(csum_count);
+	vfree(csum);
+#endif
 	if (swap_file)
 		filp_close(swap_file, NULL);
 out:
@@ -2487,3 +2589,75 @@ static void free_swap_count_continuations(struct swap_info_struct *si)
 		}
 	}
 }
+
+#ifdef CONFIG_SWAP_CHECKSUM
+int swap_csum_set(swp_entry_t entry, u32 crc)
+{
+	int ret = 0;
+	struct swap_info_struct *si;
+	unsigned long offset;
+	u32 *csum_page;
+
+	si = swap_info_get(entry);
+	if (unlikely(!si))
+		return -EINVAL;
+	offset = swp_offset(entry);
+
+	BUG_ON(!si->csum);
+	csum_page = si->csum[offset / CSUMS_PER_PAGE];
+	if (!csum_page) {
+		csum_page = (void *)__get_free_page(GFP_ATOMIC);
+		if (unlikely(!csum_page)) {
+			ret = -ENOMEM;
+			goto out;
+		}
+
+		si->csum[offset / CSUMS_PER_PAGE] = csum_page;
+	}
+
+	csum_page[offset % CSUMS_PER_PAGE] = crc;
+
+out:
+	spin_unlock(&swap_lock);
+	return ret;
+}
+
+int swap_csum_get(swp_entry_t entry, u32 *crc)
+{
+	int ret = 0;
+	struct swap_info_struct *si;
+	unsigned long offset;
+	u32 *csum_page;
+
+	/*
+	 * Not locking swap_lock here is safe because:
+	 *
+	 * - We are within end_swap_bio_read for a page in this
+	 *   swapfile, thus it is in use and its swap_info_struct
+	 *   cannot be freed.
+	 * - If we are reading a page from the swapfile, its count must
+	 *   be nonzero, thus the corresponding csum_count must also be
+	 *   nonzero, meaning the corresponding checksum page will not
+	 *   be freed.
+	 * - The checksum value itself is only modified when the page
+	 *   is written, but doing so makes no sense since we are
+	 *   currently in the middle of reading it.
+	 */
+	si = swap_info_get_unlocked(entry);
+	if (unlikely(!si))
+		return -EINVAL;
+	offset = swp_offset(entry);
+
+	BUG_ON(!si->csum);
+	csum_page = si->csum[offset / CSUMS_PER_PAGE];
+	if (unlikely(!csum_page)) {
+		ret = -ENOENT;
+		goto out;
+	}
+
+	*crc = csum_page[offset % CSUMS_PER_PAGE];
+
+out:
+	return ret;
+}
+#endif
-- 
1.6.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
