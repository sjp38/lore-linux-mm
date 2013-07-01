Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id B694D6B0044
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 07:58:13 -0400 (EDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 09/13] mm: PRAM: ban pages that have been reserved at boot time
Date: Mon, 1 Jul 2013 15:57:44 +0400
Message-ID: <d618f7f63ca9256464399ab93074336c1af7f000.1372582756.git.vdavydov@parallels.com>
In-Reply-To: <cover.1372582754.git.vdavydov@parallels.com>
References: <cover.1372582754.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, criu@openvz.org, devel@openvz.org, xemul@parallels.com, khorenko@parallels.com

Obviously, not all memory ranges can be used for saving persistent
over-kexec data, because some of them are reserved by the system core
and various device drivers at boot time. If a memory range used for
initialization of a particular device turns out to be busy because PRAM
uses it for storing its data, the device driver initialization stage or
even the whole system boot sequence may fail.

As a workaround the current implementation uses a rather dirty hack. It
tracks all memory regions that have ever been reserved during the boot
sequence and avoids using pages belonging to those regions for storing
persistent data. Since the device configuration cannot change during
kexec and the newly booted kernel is likely to have a similar boot-time
device driver set, this hack should work in most cases.
---
 arch/x86/mm/init_32.c |    1 +
 arch/x86/mm/init_64.c |    1 +
 include/linux/pram.h  |    4 +
 mm/bootmem.c          |    4 +
 mm/memblock.c         |    7 +-
 mm/pram.c             |  211 ++++++++++++++++++++++++++++++++++++++++++++++++-
 6 files changed, 225 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index da38426..67b963a 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -782,6 +782,7 @@ void __init mem_init(void)
 
 	totalram_pages += pram_reserved_pages;
 	reservedpages -= pram_reserved_pages;
+	pram_show_banned();
 
 	codesize =  (unsigned long) &_etext - (unsigned long) &_text;
 	datasize =  (unsigned long) &_edata - (unsigned long) &_etext;
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 8aa4bc4..fbe3e17 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1080,6 +1080,7 @@ void __init mem_init(void)
 
 	totalram_pages += pram_reserved_pages;
 	reservedpages -= pram_reserved_pages;
+	pram_show_banned();
 
 	codesize =  (unsigned long) &_etext - (unsigned long) &_text;
 	datasize =  (unsigned long) &_edata - (unsigned long) &_etext;
diff --git a/include/linux/pram.h b/include/linux/pram.h
index b7f2799..d4f23e3 100644
--- a/include/linux/pram.h
+++ b/include/linux/pram.h
@@ -50,9 +50,13 @@ extern size_t pram_read(struct pram_stream *ps, void *buf, size_t count);
 #ifdef CONFIG_PRAM
 extern unsigned long pram_reserved_pages;
 extern void pram_reserve(void);
+extern void pram_ban_region(unsigned long start, unsigned long end);
+extern void pram_show_banned(void);
 #else
 #define pram_reserved_pages 0UL
 static inline void pram_reserve(void) { }
+static inline void pram_ban_region(unsigned long start, unsigned long end) { }
+static inline void pram_show_banned(void) { }
 #endif
 
 #endif /* _LINUX_PRAM_H */
diff --git a/mm/bootmem.c b/mm/bootmem.c
index 2b0bcb0..34d0b42 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -16,6 +16,7 @@
 #include <linux/kmemleak.h>
 #include <linux/range.h>
 #include <linux/memblock.h>
+#include <linux/pram.h>
 
 #include <asm/bug.h>
 #include <asm/io.h>
@@ -328,6 +329,9 @@ static int __init __reserve(bootmem_data_t *bdata, unsigned long sidx,
 			bdebug("silent double reserve of PFN %lx\n",
 				idx + bdata->node_min_pfn);
 		}
+
+	pram_ban_region(sidx + bdata->node_min_pfn,
+			eidx + bdata->node_min_pfn - 1);
 	return 0;
 }
 
diff --git a/mm/memblock.c b/mm/memblock.c
index b8d9147..d2c248e 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -19,6 +19,7 @@
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
 #include <linux/memblock.h>
+#include <linux/pram.h>
 
 static struct memblock_region memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
 static struct memblock_region memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS] __initdata_memblock;
@@ -553,13 +554,17 @@ int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
 int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
 {
 	struct memblock_type *_rgn = &memblock.reserved;
+	int err;
 
 	memblock_dbg("memblock_reserve: [%#016llx-%#016llx] %pF\n",
 		     (unsigned long long)base,
 		     (unsigned long long)base + size,
 		     (void *)_RET_IP_);
 
-	return memblock_add_region(_rgn, base, size, MAX_NUMNODES);
+	err = memblock_add_region(_rgn, base, size, MAX_NUMNODES);
+	if (!err)
+		pram_ban_region(PFN_DOWN(base), PFN_UP(base + size) - 1);
+	return err;
 }
 
 /**
diff --git a/mm/pram.c b/mm/pram.c
index 8a66a86..969ff3f 100644
--- a/mm/pram.c
+++ b/mm/pram.c
@@ -17,6 +17,7 @@
 #include <linux/pram.h>
 #include <linux/reboot.h>
 #include <linux/sched.h>
+#include <linux/spinlock.h>
 #include <linux/string.h>
 #include <linux/sysfs.h>
 #include <linux/types.h>
@@ -110,6 +111,47 @@ static LIST_HEAD(pram_nodes);			/* linked through page::lru */
 static DEFINE_MUTEX(pram_mutex);		/* serializes open/close */
 
 unsigned long __initdata pram_reserved_pages;
+static bool __meminitdata pram_reservation_in_progress;
+
+/*
+ * Obviously, not all memory ranges can be used for saving persistent
+ * over-kexec data, because some of them are reserved by the system core and
+ * various device drivers at boot time. If a memory range used for
+ * initialization of a particular device turns out to be busy because PRAM uses
+ * it for storing its data, the device driver initialization stage or even the
+ * whole system boot sequence may fail.
+ *
+ * As a workaround the current implementation uses a rather dirty hack. It
+ * tracks all memory regions that have ever been reserved during the boot
+ * sequence and avoids using pages belonging to those regions for storing
+ * persistent data. Since the device configuration cannot change during kexec
+ * and the newly booted kernel is likely to have a similar boot-time device
+ * driver set, this hack should work in most cases.
+ */
+
+/*
+ * Represents a region of memory that PRAM is not allowed to use.
+ */
+struct banned_region {
+	unsigned long start, end;		/* pfn, inclusive */
+};
+
+#define MAX_NR_BANNED		(32 + MAX_NUMNODES * 2)
+
+static unsigned int nr_banned;			/* number of banned regions */
+
+/* banned regions; arranged in ascending order, do not overlap */
+static struct banned_region banned[MAX_NR_BANNED];
+
+/*
+ * If a page allocated for PRAM needs turns out to belong to a banned region,
+ * it is placed to the banned_pages list for next allocation attempts not to
+ * encounter it all over again. The list is shrunk when the system memory is
+ * low.
+ */
+static LIST_HEAD(banned_pages);			/* linked through page::lru */
+static DEFINE_SPINLOCK(banned_pages_lock);
+static unsigned long nr_banned_pages;
 
 /*
  * The PRAM super block pfn, see above.
@@ -281,6 +323,7 @@ void __init pram_reserve(void)
 		return;
 
 	pr_info("PRAM: Examining persistent memory...\n");
+	pram_reservation_in_progress = true;
 
 	err = pram_reserve_page(pram_sb_pfn);
 	if (err)
@@ -325,6 +368,7 @@ void __init pram_reserve(void)
 	}
 
 out:
+	pram_reservation_in_progress = false;
 	if (err) {
 		BUG_ON(pram_reserved_pages > 0);
 		pr_err("PRAM: Reservation failed: %d\n", err);
@@ -333,9 +377,114 @@ out:
 		pr_info("PRAM: %lu pages reserved\n", pram_reserved_pages);
 }
 
+/*
+ * Bans pfn range [start..end] (inclusive) for PRAM.
+ */
+void __meminit pram_ban_region(unsigned long start, unsigned long end)
+{
+	int i, merged = -1;
+
+	if (pram_reservation_in_progress)
+		return;
+
+	/* first try to merge the region with an existing one */
+	for (i = nr_banned - 1; i >= 0 && start <= banned[i].end + 1; i--) {
+		if (end + 1 >= banned[i].start) {
+			start = min(banned[i].start, start);
+			end = max(banned[i].end, end);
+			if (merged < 0)
+				merged = i;
+		} else
+			/* regions are arranged in ascending order and do not
+			 * intersect so the merged region cannot jump over its
+			 * predecessors */
+			BUG_ON(merged >= 0);
+	}
+
+	i++;
+
+	if (merged >= 0) {
+		banned[i].start = start;
+		banned[i].end = end;
+		/* shift if merged with more than one region */
+		memmove(banned + i + 1, banned + merged + 1,
+			sizeof(*banned) * (nr_banned - merged - 1));
+		nr_banned -= merged - i;
+		return;
+	}
+
+	/* the region does not intersect with anyone existing,
+	 * try to create a new one */
+	if (nr_banned == MAX_NR_BANNED) {
+		pr_err("PRAM: Failed to ban %lu-%lu: "
+		       "Too many banned regions\n", start, end);
+		return;
+	}
+
+	memmove(banned + i + 1, banned + i,
+		sizeof(*banned) * (nr_banned - i));
+	banned[i].start = start;
+	banned[i].end = end;
+	nr_banned++;
+}
+
+void __init pram_show_banned(void)
+{
+	int i;
+	unsigned long n, total = 0;
+
+	pr_info("PRAM: banned regions:\n");
+	for (i = 0; i < nr_banned; i++) {
+		n = banned[i].end - banned[i].start + 1;
+		pr_info("%4d: [%08lx - %08lx] %ld pages\n",
+			i, banned[i].start, banned[i].end, n);
+		total += n;
+	}
+	pr_info("Total banned: %ld pages in %d regions\n",
+		total, nr_banned);
+}
+
+/*
+ * Returns true if the page may not be used for storing persistent data.
+ */
+static bool pram_page_banned(struct page *page)
+{
+	unsigned long pfn = page_to_pfn(page);
+	int l = 0, r = nr_banned - 1, m;
+
+	/* do binary search */
+	while (l <= r) {
+		m = (l + r) / 2;
+		if (pfn < banned[m].start)
+			r = m - 1;
+		else if (pfn > banned[m].end)
+			l = m + 1;
+		else
+			return true;
+	}
+	return false;
+}
+
 static inline struct page *pram_alloc_page(gfp_t gfp_mask)
 {
-	return alloc_page(gfp_mask);
+	struct page *page;
+	LIST_HEAD(list);
+	unsigned long len = 0;
+
+	page = alloc_page(gfp_mask);
+	gfp_mask |= __GFP_COLD;
+	while (page && pram_page_banned(page)) {
+		len++;
+		list_add(&page->lru, &list);
+		page = alloc_page(gfp_mask);
+	}
+	if (len > 0) {
+		spin_lock(&banned_pages_lock);
+		nr_banned_pages += len;
+		list_splice(&list, &banned_pages);
+		spin_unlock(&banned_pages_lock);
+	}
+	return page;
 }
 
 static inline void pram_free_page(void *addr)
@@ -346,6 +495,46 @@ static inline void pram_free_page(void *addr)
 	free_page((unsigned long)addr);
 }
 
+static void __banned_pages_shrink(unsigned long nr_to_scan)
+{
+	struct page *page;
+
+	if (nr_to_scan <= 0)
+		return;
+
+	while (nr_banned_pages > 0) {
+		BUG_ON(list_empty(&banned_pages));
+		page = list_first_entry(&banned_pages, struct page, lru);
+		list_del(&page->lru);
+		__free_page(page);
+		nr_banned_pages--;
+		nr_to_scan--;
+		if (!nr_to_scan)
+			break;
+	}
+}
+
+static int banned_pages_shrink(struct shrinker *shrink,
+			       struct shrink_control *sc)
+{
+	int nr_left = nr_banned_pages;
+
+	if (!sc->nr_to_scan || !nr_left)
+		return nr_left;
+
+	spin_lock(&banned_pages_lock);
+	__banned_pages_shrink(sc->nr_to_scan);
+	nr_left = nr_banned_pages;
+	spin_unlock(&banned_pages_lock);
+
+	return nr_left;
+}
+
+static struct shrinker banned_pages_shrinker = {
+	.shrink = banned_pages_shrink,
+	.seeks = DEFAULT_SEEKS,
+};
+
 static inline void pram_insert_node(struct pram_node *node)
 {
 	list_add(&virt_to_page(node)->lru, &pram_nodes);
@@ -650,6 +839,7 @@ void pram_finish_load(struct pram_stream *ps)
 
 /*
  * Insert page to PRAM node allocating a new PRAM link if necessary.
+ * It is up to the caller to assert that the page is not banned.
  */
 static int __pram_save_page(struct pram_stream *ps,
 			    struct page *page, int flags)
@@ -703,13 +893,28 @@ static int __pram_save_page(struct pram_stream *ps,
 int pram_save_page(struct pram_stream *ps, struct page *page, int flags)
 {
 	struct pram_node *node = ps->node;
+	struct page *new = NULL;
+	int err;
 
 	BUG_ON(node->type != PRAM_PAGE_STREAM);
 	BUG_ON((node->flags & PRAM_ACCMODE_MASK) != PRAM_SAVE);
 
 	BUG_ON(PageCompound(page));
 
-	return __pram_save_page(ps, page, flags);
+	/* if page is banned, relocate it */
+	if (pram_page_banned(page)) {
+		new = pram_alloc_page(ps->gfp_mask);
+		if (!new)
+			return -ENOMEM;
+		copy_highpage(new, page);
+		page = new;
+		flags &= ~PRAM_PAGE_LRU;
+	}
+
+	err = __pram_save_page(ps, page, flags);
+	if (new)
+		put_page(new);
+	return err;
 }
 
 /*
@@ -963,6 +1168,7 @@ static int __init pram_init_sb(void)
 		page = pram_alloc_page(GFP_KERNEL | __GFP_ZERO);
 		if (!page) {
 			pr_err("PRAM: Failed to allocate super block\n");
+			__banned_pages_shrink(ULONG_MAX);
 			return 0;
 		}
 		pram_sb = page_address(page);
@@ -983,6 +1189,7 @@ static int __init pram_init(void)
 {
 	if (pram_init_sb()) {
 		register_reboot_notifier(&pram_reboot_notifier);
+		register_shrinker(&banned_pages_shrinker);
 		sysfs_update_group(kernel_kobj, &pram_attr_group);
 	}
 	return 0;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
