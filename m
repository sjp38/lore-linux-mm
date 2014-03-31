Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id C28916B0035
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 17:16:10 -0400 (EDT)
Received: by mail-la0-f51.google.com with SMTP id pv20so6235589lab.38
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 14:16:09 -0700 (PDT)
Received: from mail-la0-x235.google.com (mail-la0-x235.google.com [2a00:1450:4010:c03::235])
        by mx.google.com with ESMTPS id e6si9492893lah.79.2014.03.31.14.16.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 31 Mar 2014 14:16:09 -0700 (PDT)
Received: by mail-la0-f53.google.com with SMTP id b8so6369099lan.12
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 14:16:08 -0700 (PDT)
Subject: [PATCH RFC] drivers/char/mem: byte generating devices and poisoned
 mappings
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Tue, 01 Apr 2014 01:16:07 +0400
Message-ID: <20140331211607.26784.43976.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Yury Gribov <y.gribov@samsung.com>, Alexandr Andreev <aandreev@parallels.com>, Vassili Karpov <av1474@comtv.ru>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch adds 256 virtual character devices: /dev/byte0, ..., /dev/byte255.
Each works like /dev/zero but generates memory filled with particular byte.

Features/use cases:
* handy source of non-zero bytes for 'dd' (dd if=/dev/byte1 ...)
* effective way for allocating poisoned memory (just mmap, without memset)
* /dev/byte42 is full of stars (*)

Memory filled by default with non-zero bytes might help optimize logic in some
applications. For example (according to Yury Gribov) Address Sanitizer generates
additional conditional jump for each memory access just to handle default zero
byte as '0x8' to avoid memset`ing huge shadow memory map at the beginning.
In this case allocating memory via mapping /dev/byte8 will reduce size and
overhead of instrumented code without adding any memory usage overhead.

/dev/byteX devices have the same performance optimizations like /dev/zero.
Shared read-only pages are allocated lazily at the first request and freed by
the memory shrinker (design inspired by huge-zero-page). Private mappings are
organized as normal anonymous mappings with special page-fault handler which
allocates, initializes and installs pages like do_anonymous_page().

Unlike to /dev/zero shared ro-pages are installed into PTEs as normal pages and
accounted into file-RSS: vm_normal_page() allows only zero-page to be installed
as 'special'. This difference is fixable, but I don't see why it's matters.

This patch also (mostly) implements effective non-zero-filled shmem/tmpfs files,
(they are used for shared mappings) but here is no interface for the userspace.
This feature mught be exported as ioctl or fcntl call.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Alexandr Andreev <aandreev@parallels.com>
Cc: Vassili Karpov <av1474@comtv.ru>
Cc: Yury Gribov <y.gribov@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 drivers/char/Kconfig     |    7 +
 drivers/char/mem.c       |  285 ++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/shmem_fs.h |    4 +
 mm/shmem.c               |   58 ++++++++-
 4 files changed, 346 insertions(+), 8 deletions(-)

diff --git a/drivers/char/Kconfig b/drivers/char/Kconfig
index 1386749..e52cb4e 100644
--- a/drivers/char/Kconfig
+++ b/drivers/char/Kconfig
@@ -15,6 +15,13 @@ config DEVKMEM
 	  kind of kernel debugging operations.
 	  When in doubt, say "N".
 
+config DEVBYTES
+	bool "Byte generating devices"
+	depends on SHMEM
+	help
+	  This option adds 256 virual devices similar to /dev/zero,
+	  one for each byte value: /dev/byte0, /dev/byte1, ..., /dev/byte255.
+
 config SGI_SNSC
 	bool "SGI Altix system controller communication support"
 	depends on (IA64_SGI_SN2 || IA64_GENERIC)
diff --git a/drivers/char/mem.c b/drivers/char/mem.c
index 92c5937..30293aa 100644
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -857,6 +857,11 @@ static const struct file_operations memory_fops = {
 
 static char *mem_devnode(struct device *dev, umode_t *mode)
 {
+#ifdef CONFIG_DEVBYTES
+	if (mode && MAJOR(dev->devt) != MEM_MAJOR)
+		*mode = 0666;
+	else
+#endif
 	if (mode && devlist[MINOR(dev->devt)].mode)
 		*mode = devlist[MINOR(dev->devt)].mode;
 	return NULL;
@@ -864,6 +869,284 @@ static char *mem_devnode(struct device *dev, umode_t *mode)
 
 static struct class *mem_class;
 
+#ifdef CONFIG_DEVBYTES
+
+#include <linux/shmem_fs.h>
+#include <linux/rmap.h>
+
+/*
+ * FIXME Is here generic functions for this?
+ */
+static unsigned long __memset_user(void __user *dst, int c, unsigned long size)
+{
+	unsigned long word = REPEAT_BYTE(c), len, ret = 0;
+
+	len = PTR_ALIGN(dst, sizeof(word)) - dst;
+	if (len && len < size) {
+		ret += __copy_to_user(dst, &word, len);
+		dst += len;
+		size -= len;
+	}
+	for (; size >= sizeof(word); dst += sizeof(word), size -= sizeof(word))
+		ret += __copy_to_user(dst, &word, sizeof(word));
+	if (size)
+		ret += __copy_to_user(dst, &word, size);
+	return ret;
+}
+
+static void memset_page(struct page *page, int c)
+{
+	void *kaddr;
+
+	kaddr = kmap_atomic(page);
+	memset(kaddr, c, PAGE_SIZE);
+	kunmap_atomic(kaddr);
+	flush_dcache_page(page);
+}
+
+static struct page *byte_pages[256];
+static DEFINE_SPINLOCK(byte_pages_lock);
+static LIST_HEAD(byte_pages_list);
+static int byte_pages_nr;
+
+struct page *get_byte_page(unsigned char byte)
+{
+	struct page *page;
+
+retry:
+	page = ACCESS_ONCE(byte_pages[byte]);
+	if (page && get_page_unless_zero(page)) {
+		if (byte_pages[byte] == page)
+			return page;
+		put_page(page);
+		goto retry;
+	}
+
+	page = alloc_page(GFP_HIGHUSER);
+	if (!page)
+		return NULL;
+
+	memset_page(page, byte);
+	SetPageUptodate(page);
+
+	spin_lock(&byte_pages_lock);
+	if (byte_pages[byte]) {
+		spin_unlock(&byte_pages_lock);
+		put_page(page);
+		goto retry;
+	}
+	set_page_private(page, byte);
+	byte_pages[byte] = page;
+	get_page(page);
+	list_add_tail(&page->lru, &byte_pages_list);
+	byte_pages_nr++;
+	spin_unlock(&byte_pages_lock);
+
+	return page;
+}
+
+static unsigned long
+byte_pages_count(struct shrinker *shrink, struct shrink_control *sc)
+{
+	return byte_pages_nr;
+}
+
+static unsigned long
+byte_pages_scan(struct shrinker *shrink, struct shrink_control *sc)
+{
+	struct page *page, *next;
+	int shrinked = 0;
+
+	spin_lock(&byte_pages_lock);
+	list_for_each_entry_safe(page, next, &byte_pages_list, lru) {
+		if (page_freeze_refs(page, 1)) {
+			byte_pages[page_private(page)] = NULL;
+			set_page_private(page, 0);
+			list_del(&page->lru);
+			free_hot_cold_page(page, 0);
+			byte_pages_nr--;
+			shrinked++;
+		}
+	}
+	spin_unlock(&byte_pages_lock);
+
+	return shrinked;
+}
+
+static struct shrinker byte_pages_shrinker = {
+	.count_objects = byte_pages_count,
+	.scan_objects = byte_pages_scan,
+	.seeks = DEFAULT_SEEKS,
+};
+
+
+static int byte_open(struct inode *inode, struct file *file)
+{
+	file->private_data = (void *)(unsigned long)MINOR(inode->i_rdev);
+	return 0;
+}
+
+#define byte_lseek	null_lseek
+#define byte_write	write_null
+#define byte_aio_write	aio_write_null
+
+/*
+ * Here is some manual overdrive. This can be done by VM_MIXEDMAP mapping,
+ * but their functionality is pretty restricted: no mlock and vma merging.
+ */
+static int byte_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	unsigned byte = (unsigned long)vma->vm_file->private_data;
+	unsigned long addr = (unsigned long)vmf->virtual_address;
+	int write = vmf->flags & FAULT_FLAG_WRITE;
+	struct mm_struct *mm = vma->vm_mm;
+	struct page *page;
+	pte_t *pte, entry;
+	spinlock_t *ptl;
+
+	if (write) {
+		page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, addr);
+		if (!page)
+			return VM_FAULT_OOM;
+		if (mem_cgroup_newpage_charge(page, mm, GFP_KERNEL)) {
+			put_page(page);
+			return VM_FAULT_OOM;
+		}
+		memset_page(page, byte);
+		SetPageUptodate(page);
+	} else {
+		page = get_byte_page(byte);
+		if (!page)
+			return VM_FAULT_OOM;
+	}
+
+	pte = get_locked_pte(mm, addr, &ptl);
+	if (!pte)
+		goto out;
+	if (!pte_none(*pte))
+		goto out_unlock;
+	entry = mk_pte(page, vma->vm_page_prot);
+	if (write) {
+		entry = pte_mkwrite(pte_mkdirty(entry));
+		inc_mm_counter(mm, MM_ANONPAGES);
+		page_add_new_anon_rmap(page, vma, addr);
+	} else {
+		/*
+		 * vm_normal_page() allows only one special page: zero-page.
+		 */
+		inc_mm_counter(mm, MM_FILEPAGES);
+		page_add_file_rmap(page);
+	}
+	set_pte_at(mm, addr, pte, entry);
+	page = NULL;
+out_unlock:
+	pte_unmap_unlock(pte, ptl);
+out:
+	if (page) {
+		if (write)
+			mem_cgroup_uncharge_page(page);
+		put_page(page);
+	}
+	return VM_FAULT_NOPAGE;
+}
+
+static const struct vm_operations_struct byte_vm_ops = {
+	.fault		= byte_fault,
+};
+
+static int byte_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	if (vma->vm_flags & VM_SHARED)
+		return shmem_byte_setup(vma, (unsigned long)file->private_data);
+	vma->vm_ops = &byte_vm_ops;
+	return 0;
+}
+
+static ssize_t byte_read(struct file *file, char __user *buf,
+			 size_t count, loff_t *ppos)
+{
+	unsigned byte = (unsigned long)file->private_data;
+	size_t written;
+
+	if (!count)
+		return 0;
+
+	if (!access_ok(VERIFY_WRITE, buf, count))
+		return -EFAULT;
+
+	written = 0;
+	while (count) {
+		size_t chunk = min(count, PAGE_SIZE);
+
+		if (__memset_user(buf, byte, chunk))
+			return -EFAULT;
+		if (signal_pending(current))
+			return written ? written : -ERESTARTSYS;
+		written += chunk;
+		buf += chunk;
+		count -= chunk;
+		cond_resched();
+	}
+	return written;
+}
+
+static ssize_t byte_aio_read(struct kiocb *iocb, const struct iovec *iov,
+			     unsigned long nr_segs, loff_t pos)
+{
+	size_t written = 0;
+	unsigned long i;
+	ssize_t ret;
+
+	for (i = 0; i < nr_segs; i++) {
+		ret = byte_read(iocb->ki_filp, iov[i].iov_base, iov[i].iov_len,
+				&pos);
+		if (ret < 0)
+			break;
+		written += ret;
+	}
+
+	return written ? written : -EFAULT;
+}
+
+static const struct file_operations byte_fops = {
+	.llseek		= byte_lseek,
+	.read		= byte_read,
+	.write		= byte_write,
+	.aio_read	= byte_aio_read,
+	.aio_write      = byte_aio_write,
+	.open		= byte_open,
+	.mmap		= byte_mmap,
+};
+
+static int __init byte_init(void)
+{
+	int major, minor;
+
+	major  = __register_chrdev(0, 0, 256, "byte", &byte_fops);
+	if (major < 0) {
+		printk("unable to get major for byte devs\n");
+		return major;
+	}
+
+	for (minor = 0; minor < 256; minor++)
+		device_create(mem_class, NULL, MKDEV(major, minor),
+			      NULL, "byte%d", minor);
+
+	byte_pages[0] = ZERO_PAGE(0);
+	register_shrinker(&byte_pages_shrinker);
+
+	return 0;
+}
+
+#else
+
+static int __init byte_init(void)
+{
+	return 0;
+}
+
+#endif /* CONFIG_DEVBYTES */
+
 static int __init chr_dev_init(void)
 {
 	int minor;
@@ -895,6 +1178,8 @@ static int __init chr_dev_init(void)
 			      NULL, devlist[minor].name);
 	}
 
+	byte_init();
+
 	return tty_init();
 }
 
diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 9d55438..9fe850b 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -11,6 +11,7 @@
 
 struct shmem_inode_info {
 	spinlock_t		lock;
+	unsigned char		byte;		/* byte for filling new pages */
 	unsigned long		flags;
 	unsigned long		alloced;	/* data pages alloced to file */
 	union {
@@ -57,6 +58,9 @@ extern struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
 extern void shmem_truncate_range(struct inode *inode, loff_t start, loff_t end);
 extern int shmem_unuse(swp_entry_t entry, struct page *page);
 
+extern struct page *get_byte_page(unsigned char byte);
+extern int shmem_byte_setup(struct vm_area_struct *vma, unsigned char byte);
+
 static inline struct page *shmem_read_mapping_page(
 				struct address_space *mapping, pgoff_t index)
 {
diff --git a/mm/shmem.c b/mm/shmem.c
index 1f18c9d..bbbffc9 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -774,6 +774,22 @@ out:
 	return error;
 }
 
+static void shmem_initialize_page(struct inode *inode, struct page *page)
+{
+	void *kaddr;
+
+	kaddr = kmap_atomic(page);
+#ifdef CONFIG_DEVBYTES
+	if (SHMEM_I(inode)->byte)
+		memset(kaddr, SHMEM_I(inode)->byte, PAGE_SIZE);
+	else
+#endif
+		clear_page(kaddr);
+	kunmap_atomic(kaddr);
+	flush_dcache_page(page);
+	SetPageUptodate(page);
+}
+
 /*
  * Move the page from the page cache to the swap cache.
  */
@@ -833,9 +849,7 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 			if (shmem_falloc)
 				goto redirty;
 		}
-		clear_highpage(page);
-		flush_dcache_page(page);
-		SetPageUptodate(page);
+		shmem_initialize_page(inode, page);
 	}
 
 	swap = get_swap_page();
@@ -1233,11 +1247,8 @@ clear:
 		 * but SGP_FALLOC on a page fallocated earlier must initialize
 		 * it now, lest undo on failure cancel our earlier guarantee.
 		 */
-		if (sgp != SGP_WRITE) {
-			clear_highpage(page);
-			flush_dcache_page(page);
-			SetPageUptodate(page);
-		}
+		if (sgp != SGP_WRITE)
+			shmem_initialize_page(inode, page);
 		if (sgp == SGP_DIRTY)
 			set_page_dirty(page);
 	}
@@ -1535,6 +1546,10 @@ static void do_shmem_file_read(struct file *filp, loff_t *ppos, read_descriptor_
 			 */
 			if (!offset)
 				mark_page_accessed(page);
+#ifdef CONFIG_DEVBYTES
+		} else if (SHMEM_I(inode)->byte) {
+			page = get_byte_page(SHMEM_I(inode)->byte);
+#endif
 		} else {
 			page = ZERO_PAGE(0);
 			page_cache_get(page);
@@ -3010,6 +3025,33 @@ int shmem_zero_setup(struct vm_area_struct *vma)
 	return 0;
 }
 
+#ifdef CONFIG_DEVBYTES
+
+/**
+ * shmem_byte_setup - setup a non-zeroed shared anonymous mapping
+ * @vma: the vma to be mmapped is prepared by do_mmap_pgoff
+ * @byte: the byte which will be used as a filler
+ */
+int shmem_byte_setup(struct vm_area_struct *vma, unsigned char byte)
+{
+	loff_t size = vma->vm_end - vma->vm_start;
+	struct file *file;
+	char name[12];
+
+	snprintf(name, sizeof(name), "dev/byte%d", byte);
+	file = shmem_file_setup(name, size, vma->vm_flags);
+	if (IS_ERR(file))
+		return PTR_ERR(file);
+	SHMEM_I(file->f_inode)->byte = byte;
+	if (vma->vm_file)
+		fput(vma->vm_file);
+	vma->vm_file = file;
+	vma->vm_ops = &shmem_vm_ops;
+	return 0;
+}
+
+#endif
+
 /**
  * shmem_read_mapping_page_gfp - read into page cache, using specified page allocation flags.
  * @mapping:	the page's address_space

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
