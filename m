Received: from alogconduit1ah.ccr.net (root@alogconduit1ak.ccr.net [208.130.159.11])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA06710
	for <linux-mm@kvack.org>; Sun, 30 May 1999 13:53:01 -0400
Subject: [RFC][PATCH] dirty pages in the page cache.
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 30 May 1999 12:56:49 -0500
Message-ID: <m13e0e4f1a.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, linux-fsdevel@vger.rutgers.edu
Cc: Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

The following patch implements dirty pages in the page cache, using it's own
version of kflushd, kpgflushd so the support is not confined to just block
based filesystems, and allows fun things like allocate of space on write.

The code still has a ways to go before it reaches optimum tuning
but the important part of the interal API looks solid.  

As far as space consumption in struct page, one more set of list pointers
has been added (to keep the dirty page list, and whatever), and 12 bits
of flags has been used, allowing a crude but space efficient timer on
when a page should be next written.

Some important functions are:
mark_page_dirty, mark_page_clean, unlock_page, write_page.

Eric

diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb6/fs/buffer.c linux-2.3.3.eb7/fs/buffer.c
--- linux-2.3.3.eb6/fs/buffer.c	Sat May 22 17:16:33 1999
+++ linux-2.3.3.eb7/fs/buffer.c	Sat May 22 18:23:49 1999
@@ -1103,23 +1103,6 @@
 	goto try_again;
 }
 
-/* Run the hooks that have to be done when a page I/O has completed. */
-static inline void after_unlock_page (struct page * page)
-{
-	if (test_and_clear_bit(PG_decr_after, &page->flags)) {
-		atomic_dec(&nr_async_pages);
-#ifdef DEBUG_SWAP
-		printk ("DebugVM: Finished IO on page %p, nr_async_pages %d\n",
-			(char *) page_address(page), 
-			atomic_read(&nr_async_pages));
-#endif
-	}
-	if (test_and_clear_bit(PG_swap_unlock_after, &page->flags))
-		swap_after_unlock_page(page->key);
-	if (test_and_clear_bit(PG_free_after, &page->flags))
-		__free_page(page);
-}
-
 /*
  * Free all temporary buffers belonging to a page.
  * This needs to be called with interrupts disabled.
@@ -1190,9 +1173,7 @@
 	/* OK, the async IO on this page is complete. */
 	free_async_buffers(bh);
 	restore_flags(flags);
-	clear_bit(PG_locked, &page->flags);
-	wake_up(&page->wait);
-	after_unlock_page(page);
+	unlock_page(page);
 	return;
 
 still_busy:
@@ -1285,14 +1266,12 @@
 		 * and unlock_buffer(). */
 	} else {
 		unsigned long flags;
-		clear_bit(PG_locked, &page->flags);
 		set_bit(PG_uptodate, &page->flags);
-		wake_up(&page->wait);
 		save_flags(flags);
 		cli();
 		free_async_buffers(bh);
 		restore_flags(flags);
-		after_unlock_page(page);
+		unlock_page(page);
 	}
 	++current->maj_flt;
 	return 0;
@@ -1593,6 +1572,7 @@
 
 	sync_supers(0);
 	sync_inodes(0);
+	sync_pcache(1, 0);
 
 	ncount = 0;
 #ifdef DEBUG
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb6/include/linux/mm.h linux-2.3.3.eb7/include/linux/mm.h
--- linux-2.3.3.eb6/include/linux/mm.h	Sat May 22 18:19:40 1999
+++ linux-2.3.3.eb7/include/linux/mm.h	Sat May 22 18:23:49 1999
@@ -141,6 +141,7 @@
 	wait_queue_head_t wait;
 	struct page **pprev_hash;
 	void *generic_pp; /* This is page buffers iff PageBuffer(page) is true. */
+	struct list_head lru;	/* dirty page queue */
 } mem_map_t;
 
 /* Page flag bit values */
@@ -157,8 +158,15 @@
 #define PG_swap_cache		10
 #define PG_skip			11
 #define PG_buffer		12
+#define PG_wcycle_low		13
+#define PG_wcycle_high		24
 #define PG_reserved		31
 
+/* Which cycle of page_flush which will write out the pages */
+#define PageWCycle(page)	(((page)->flags & ((2 << PG_wcycle_high) -1)) >> PG_wcycle_low)
+#define PageSetWCycle(page, cycle) \
+	((page)->flags |= ((cycle & ((PG_wcycle_high - PG_wcycle_low) -1)) << PG_wcycle_low))
+
 /* Make it prettier to test the above... */
 #define PageLocked(page)	(test_bit(PG_locked, &(page)->flags))
 #define PageError(page)		(test_bit(PG_error, &(page)->flags))
@@ -225,6 +233,12 @@
  * page->inode is the pointer to the inode, and page->key is the
  * offset into the file (divided by PAGE_CACHE_SIZE).
  *
+ * If an inode page wants to use the generic dirty page management, 
+ * mark_page_dirty() is called, which sets page->dirty.  Either
+ * mark_page_clean() or write_page() can be called to remove this
+ * condition.  Though usually this will happen automatically after the
+ * page has aged appropriately.
+ *
  * A page may have buffers allocated to it. In this case,
  * PageBuffer(page) is true and page->generic_pp is a circular list of
  * these buffer heads. Else, PageBuffer(page) is false.
@@ -332,12 +346,12 @@
 extern int do_munmap(unsigned long, size_t);
 
 /* filemap.c */
-extern unsigned long page_unuse(struct page *);
-extern int shrink_mmap(int, int);
 extern void truncate_inode_pages(struct inode *, loff_t);
 extern void invalidate_inode_pages(struct inode *);
+extern int sync_inode_pages(struct inode *inode, int wait);
 extern void zap_inode_pages(struct inode *);
 extern void update_vm_cache(struct inode *, loff_t, const char *, int);
+extern struct page *get_inode_page(struct inode *, loff_t, unsigned long *);
 extern unsigned long get_cached_page(struct inode *, unsigned long, int);
 extern void put_cached_page(unsigned long);
 
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb6/include/linux/pagemap.h linux-2.3.3.eb7/include/linux/pagemap.h
--- linux-2.3.3.eb6/include/linux/pagemap.h	Sat May 22 18:19:40 1999
+++ linux-2.3.3.eb7/include/linux/pagemap.h	Sat May 22 18:23:49 1999
@@ -155,4 +155,25 @@
 	struct vm_store *store, unsigned long key,
 	struct page **hash);
 
+extern int sync_pcache(int old, int max_write);
+extern int sync_pcache_dev(kdev_t dev);
+
+extern atomic_t nr_dirty_pages;
+extern void wakeup_pgflush(int wait);
+/* more thought needs to go into mark_page_dirty,
+ *
+ * It looks like an excellent place to require functionality to be present
+ * if there is a configurable function under it.
+ *
+ * Also I need to figure out how the delay for writing a page needs to be set.
+ */
+extern void mark_page_dirty(struct page *page);
+extern void mark_page_clean(struct page *page);
+extern void unlock_page(struct page *page);
+extern int generic_writepage(
+	struct vm_store *store, struct page *page, unsigned long index, void **p);
+extern int generic_updatepage(struct file *file, struct page *page, 
+	const char *buf, unsigned int offset, unsigned int count, int sync);
+extern int write_page(struct page *page); /* do I need to export this one? */
+
 #endif
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb6/include/linux/vm_store.h linux-2.3.3.eb7/include/linux/vm_store.h
--- linux-2.3.3.eb6/include/linux/vm_store.h	Sat May 22 18:19:40 1999
+++ linux-2.3.3.eb7/include/linux/vm_store.h	Sat May 22 18:23:49 1999
@@ -47,6 +47,8 @@
 extern int shrink_mmap(int priority, int gfp_mask);
 extern void update_vm_store_cache(struct vm_store *store,
 	unsigned long index, unsigned long offset, const char * buf, int count);
+extern int sync_store_pages(struct vm_store *store);
+extern int wait_on_store_pages(struct vm_store *store);
 
 #endif /* KERNEL */
 #endif /* _LINUX_VM_STORE_H */
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb6/init/main.c linux-2.3.3.eb7/init/main.c
--- linux-2.3.3.eb6/init/main.c	Sat May 22 16:10:13 1999
+++ linux-2.3.3.eb7/init/main.c	Sat May 22 18:23:49 1999
@@ -67,6 +67,8 @@
 
 static int init(void *);
 extern int bdflush(void *);
+extern int pgflush(void *);
+extern void pgflush_init(void);
 extern int kswapd(void *);
 extern int kpiod(void *);
 extern void kswapd_setup(void);
@@ -1299,6 +1301,9 @@
 
 	/* Launch bdflush from here, instead of the old syscall way. */
 	kernel_thread(bdflush, NULL, CLONE_FS | CLONE_FILES | CLONE_SIGHAND);
+	/* Launch pgflush from here, it's a clone of bdflush... */
+	pgflush_init();
+	kernel_thread(pgflush, NULL, CLONE_FS | CLONE_FILES | CLONE_SIGHAND);
 	/* Start the background pageout daemon. */
 	kswapd_setup();
 	kernel_thread(kpiod, NULL, CLONE_FS | CLONE_FILES | CLONE_SIGHAND);
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb6/ipc/shm.c linux-2.3.3.eb7/ipc/shm.c
--- linux-2.3.3.eb6/ipc/shm.c	Sat May 22 18:19:40 1999
+++ linux-2.3.3.eb7/ipc/shm.c	Sat May 22 18:23:49 1999
@@ -515,6 +515,7 @@
 	shmd->vm_file = NULL;
 	shmd->vm_store = NULL;
 	shmd->vm_index = 0;
+	shmd->vm_store = NULL;
 	shmd->vm_ops = &shm_vm_ops;
 
 	shp->u.shm_nattch++;            /* prevent destruction */
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb6/kernel/ksyms.c linux-2.3.3.eb7/kernel/ksyms.c
--- linux-2.3.3.eb6/kernel/ksyms.c	Sat May 22 16:10:25 1999
+++ linux-2.3.3.eb7/kernel/ksyms.c	Sat May 22 18:23:49 1999
@@ -105,7 +105,6 @@
 EXPORT_SYMBOL(remap_page_range);
 EXPORT_SYMBOL(max_mapnr);
 EXPORT_SYMBOL(high_memory);
-EXPORT_SYMBOL(update_vm_cache);
 EXPORT_SYMBOL(vmtruncate);
 EXPORT_SYMBOL(find_vma);
 EXPORT_SYMBOL(get_unmapped_area);
@@ -145,8 +144,6 @@
 EXPORT_SYMBOL(check_disk_change);
 EXPORT_SYMBOL(invalidate_buffers);
 EXPORT_SYMBOL(invalidate_inodes);
-EXPORT_SYMBOL(invalidate_inode_pages);
-EXPORT_SYMBOL(truncate_inode_pages);
 EXPORT_SYMBOL(fsync_dev);
 EXPORT_SYMBOL(permission);
 EXPORT_SYMBOL(inode_setattr);
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb6/mm/Makefile linux-2.3.3.eb7/mm/Makefile
--- linux-2.3.3.eb6/mm/Makefile	Sat May 22 18:19:40 1999
+++ linux-2.3.3.eb7/mm/Makefile	Sat May 22 18:23:49 1999
@@ -11,8 +11,8 @@
 O_OBJS	 := memory.o mmap.o filemap.o mprotect.o mlock.o mremap.o \
 	    vmalloc.o slab.o \
 	    swap.o vmscan.o page_io.o page_alloc.o swap_state.o swapfile.o \
-	    vm_store.o
+	    vm_store.o page_flush.o
 
-OX_OBJS := swap_syms.o
+OX_OBJS := swap_syms.o page_syms.o
 
 include $(TOPDIR)/Rules.make
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb6/mm/filemap.c linux-2.3.3.eb7/mm/filemap.c
--- linux-2.3.3.eb6/mm/filemap.c	Sat May 22 18:21:10 1999
+++ linux-2.3.3.eb7/mm/filemap.c	Sat May 22 18:23:49 1999
@@ -58,6 +58,9 @@
  * locked down (those are sure to be up-to-date anyway, so we shouldn't
  * invalidate them).
  */
+/*
+ * Should we invalidate dirty pages? --EWB 19 June 1998
+ */
 void invalidate_inode_pages(struct inode * inode)
 {
  	invalidate_store_pages(inode->vm_store);
@@ -84,6 +87,11 @@
 	if (keep_bytes) {
 		/* partial truncate, clear end of page */
 		page = find_page(inode->vm_store, partial_keep);
+		/* Wait in case we are reading the page and truncating it simultaneously */
+		while (PageLocked(page) && !PageUptodate(page)) {
+			wait_on_page(page);
+			page = find_page(inode->vm_store, partial_keep);
+		}
 		if (page) {
 			unsigned long address = page_address(page);
 			memset((void *) (keep_bytes + address), 0, PAGE_CACHE_SIZE - keep_bytes);
@@ -118,6 +126,24 @@
 	update_vm_store_cache(inode->vm_store, index, offset, buf, count);
 }
 
+/* Sync all of the pages associated with an inode */
+int sync_inode_pages(struct inode *inode, int wait)
+{
+	int error = 0;
+	struct vm_store *store, *next;
+	for(store = inode->vm_store; store != NULL; store = next) {
+		next = store->st_next;
+		error |= sync_store_pages(store);
+	}
+	if (wait) {
+		for(store = inode->vm_store; store != NULL; store = next) {
+			next = store->st_next;
+			error |= wait_on_store_pages(store);
+		}
+	}
+	return error? -EIO : 0;
+}
+
 struct page *get_inode_page(
 	struct inode *inode, loff_t page, unsigned long *page_cache_ptr)
 {
@@ -300,14 +326,14 @@
 	max_ahead = 0;
 
 /*
- * The current page is locked.
+ * The current page is not uptodate.
  * If the current position is inside the previous read IO request, do not
  * try to reread previously read ahead pages.
  * Otherwise decide or not to read ahead some pages synchronously.
  * If we are not going to read ahead, set the read ahead context for this 
  * page only.
  */
-	if (PageLocked(page)) {
+	if (!PageUptodate(page)) {
 		if (!filp->f_ralen || index >= raend || index + filp->f_ralen < raend) {
 			raend = index;
 			if (((loff_t)raend << PAGE_CACHE_SHIFT) < inode->i_size)
@@ -321,7 +347,7 @@
 		}
 	}
 /*
- * The current page is not locked.
+ * The current page is uptodate 
  * If we were reading ahead and,
  * if the current max read ahead size is not zero and,
  * if the current position is inside the last read-ahead IO request,
@@ -507,7 +533,9 @@
 		else if (reada_ok && filp->f_ramax > (MIN_READAHEAD >> PAGE_CACHE_SHIFT))
 				filp->f_ramax = (MIN_READAHEAD >> PAGE_CACHE_SHIFT);
 
-		wait_on_page(page);
+		if (!PageUptodate(page) && PageLocked(page)) {
+			wait_on_page(page);
+		}
 
 		if (!PageUptodate(page))
 			goto page_read_error;
@@ -798,7 +826,7 @@
 			goto failure;
 	}
 
-	if (PageLocked(page))
+	if (PageLocked(page) && !PageUptodate(page))
 		goto page_locked_wait;
 	if (!PageUptodate(page))
 		goto page_read_error;
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb6/mm/mmap.c linux-2.3.3.eb7/mm/mmap.c
--- linux-2.3.3.eb6/mm/mmap.c	Sat May 22 18:19:40 1999
+++ linux-2.3.3.eb7/mm/mmap.c	Sat May 22 18:23:49 1999
@@ -71,7 +71,7 @@
 }
 
 /* Remove one vm structure from the inode's i_mmap ring. */
-static inline void remove_shared_vm_struct(struct vm_area_struct *vma)
+static void remove_shared_vm_struct(struct vm_area_struct *vma)
 {
 	struct file * file = vma->vm_file;
 	struct vm_store *store = vma->vm_store;
@@ -536,6 +536,7 @@
 		mpnt->vm_file = area->vm_file;
 		mpnt->vm_store = area->vm_store;
 		mpnt->vm_pte = area->vm_pte;
+		mpnt->vm_store = area->vm_store;
 		if (mpnt->vm_file)
 			mpnt->vm_file->f_count++;
 		if (mpnt->vm_ops && mpnt->vm_ops->open)
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb6/mm/page_alloc.c linux-2.3.3.eb7/mm/page_alloc.c
--- linux-2.3.3.eb6/mm/page_alloc.c	Sat May 22 18:19:40 1999
+++ linux-2.3.3.eb7/mm/page_alloc.c	Sat May 22 18:23:49 1999
@@ -124,6 +124,8 @@
 	if (!PageReserved(page) && atomic_dec_and_test(&page->count)) {
 		if (PageSwapCache(page))
 			panic ("Freeing swap cache page");
+		if (PageDirty(page))
+			panic ("Freeing dirty page");
 		page->flags &= ~(1 << PG_referenced);
 		free_pages_ok(page - mem_map, 0);
 		return;
@@ -141,6 +143,8 @@
 		if (atomic_dec_and_test(&map->count)) {
 			if (PageSwapCache(map))
 				panic ("Freeing swap cache pages");
+			if (PageDirty(map))
+				panic ("Freeing dirty page");
 			map->flags &= ~(1 << PG_referenced);
 			free_pages_ok(map_nr, order);
 			return;
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb6/mm/page_flush.c linux-2.3.3.eb7/mm/page_flush.c
--- linux-2.3.3.eb6/mm/page_flush.c	Wed Dec 31 18:00:00 1969
+++ linux-2.3.3.eb7/mm/page_flush.c	Sat May 22 18:23:49 1999
@@ -0,0 +1,566 @@
+/*
+ *  linux/mm/page_flush.c
+ *
+ *  Copyright (C) 1998 Eric Biederman
+ */
+#include <linux/fs.h>
+#include <linux/mm.h>
+#include <linux/pagemap.h>
+#include <linux/vmalloc.h>
+#include <linux/swap.h>
+#include <linux/init.h>
+#include <linux/smp_lock.h>
+#include <asm/bitops.h>
+#include <asm/pgtable.h>
+
+#ifdef DEBUG
+#  define debug_printk(n, args) do { if (n <= DEBUG) printk args ; } while(0)
+#else
+#  define debug_printk(n, args)
+#endif
+
+/* These need to be made dynamically tuneable... */
+/* Percentage of page cache dirty to activate pgflush */				 
+#define PG_DIRTY_FRACT  40
+/* Maximum number of dirty blocks to pages out per wake-cycle. */
+#define PG_DIRTY_WRITE_COUNT 500
+/* default amount of time to age a dirty page before writing. */
+#define PG_AGE_DIRTY_PAGE (30*HZ)
+/* Amount of time inbetween cycles */
+#define PG_CYCLE_TIME (1*HZ)
+/* Number of cycles */
+#define PG_CYCLES (1 << (PG_wcycle_high - PG_wcycle_low))
+
+
+void wakeup_pgflush(int wait);
+
+/* TO PLAY WITH
+ * - mergsort the list before processing to get better locality of reference
+ * - device bandwidth discover, to keeps writes from piling up faster than
+ *   a device can handle
+ */
+
+/* I believe for best performance I need to have a list of dirty pages,
+ * and have a write time for each dirty page.
+ * A fifo list should help since writes tend to be in order for files.
+ * A flushtime should help correctly handle how long pages are cached.
+ *
+ */
+
+/* Use a spinlock so I don't have to worry when the dirty page list is updated.
+ * Well actually I don't think it is safe to add to the dirty list
+ * during an interrupt but removing a page should be safe.
+ */
+atomic_t nr_dirty_pages = ATOMIC_INIT(0);
+static spinlock_t dirty_page_list_lock = SPIN_LOCK_UNLOCKED;
+static LIST_HEAD(dirty_page_list);
+
+/* Note:
+ * If you have a device that for some strange reason
+ * can't handle having it's buffer written to by the cpu
+ * while it's writing data out to disk (or wherever)
+ * you need to make a copy yourself as this code assumes it 
+ * is perfectly safe to write to locked buffers, as long as the
+ * locked buffers are uptodate.
+ */
+
+/* Last cycle number I used & and last time (in jiffies) I ran */
+static unsigned long last_cycle = 0;
+static unsigned long last_run  = 0;
+
+/* Note: Special care has been taken so jiffie wrap around is an expected case
+ * and is handled properly.  All flushtimes are computed on a sliding scale
+ * where half the numbers are always above jiffies and half the numbers are
+ * always below.
+ */
+static inline void set_page_writetime(struct page *page, unsigned long wtime)
+{
+	unsigned long newtime;
+	int newcycle;
+	if (PageDirty(page)) {
+		/* Move page to dirty list if jiffies is clear */
+		newtime = jiffies + wtime;
+		newcycle = (newtime - last_run)/ PG_CYCLE_TIME;
+		if (newcycle == 0) {
+			newcycle = 1;
+		} else if (newcycle >= PG_CYCLES) {
+			newcycle = PG_CYCLES -1;
+		}
+		if (newcycle > ((PageWCycle(page) - last_run)%PG_CYCLES)) {
+			PageSetWCycle(page, (newcycle + last_run)%PG_CYCLES);
+		}
+	}
+}
+
+static inline void after_add_to_dirty_list(void)
+{
+	int too_many;
+	/* This buffer is dirty, maybe we need to start flushing.
+	 * If too high a percentage of the buffers are dirty...
+	 */
+	too_many = (page_cache_size * PG_DIRTY_FRACT)/100;
+	if (atomic_read(&nr_dirty_pages) > too_many) 
+		wakeup_pgflush(0);
+}
+
+
+/*
+ * Before we start the kernel thread, print out the 
+ * kswapd initialization message (otherwise the init message 
+ * may be printed in the middle of another driver's init 
+ * message).  It looks very bad when that happens.
+ */
+__initfunc(void pgflush_init(void))
+{
+	int i;
+	char *revision="$Revision: 0.5 $", *s, *e;
+	
+	if ((s = strchr(revision, ':')) &&
+	    (e = strchr(s, '$')))
+		s++, i = e - s;
+	else
+		s = revision, i = -1;
+	printk ("Starting pgflushd v%.*s\n", i, s);
+}
+
+#ifdef DEBUG
+static int dirty_page_list_length(void)
+{
+	struct list_head *head, *ptr;
+	int count;
+
+	head = &dirty_page_list;
+	ptr = head->next;
+	count = 0;
+	while(ptr != head) {
+		count++;
+		ptr = ptr->next;
+	}
+	return count;
+}
+
+static void verify_dirty_page_length(void)
+{
+	int length = dirty_page_list_length();
+	if (length != atomic_read(&nr_dirty_pages)) {
+		printk("length:%d != count:%d\n",
+			length, atomic_read(&nr_dirty_pages));
+	}
+}
+#else
+#define verify_dirty_page_length()
+#endif
+
+static void add_to_dirty_page_list(struct page *page)
+{
+	unsigned long flags;
+	spin_lock_irqsave(&dirty_page_list_lock, flags);
+
+	list_add(&page->lru, &dirty_page_list);
+	atomic_inc(&nr_dirty_pages);
+
+	verify_dirty_page_length();
+
+	spin_unlock_irqrestore(&dirty_page_list_lock, flags);
+}
+
+static void remove_from_dirty_page_list(struct page *page)
+{
+	unsigned long flags;
+	spin_lock_irqsave(&dirty_page_list_lock, flags);
+
+	atomic_dec(&nr_dirty_pages);
+	list_del(&page->lru);
+
+	verify_dirty_page_length();
+
+	spin_unlock_irqrestore(&dirty_page_list_lock, flags);
+}
+
+static struct page *first_dirty_page(void)
+{
+	struct page *result;
+	result =  list_entry(dirty_page_list.prev, struct page, lru);
+	if (result == list_entry(&dirty_page_list, struct page, lru)) {
+#ifdef DEBUG
+		if (atomic_read(&nr_dirty_pages) != 0) {
+			printk(KERN_DEBUG "%d dirty pages, and list empty?\n",
+				atomic_read(&nr_dirty_pages));
+		}
+#endif
+		result = 0;
+	}
+	return result;
+}
+#define next_dirty_page(page) list_entry(page->lru.prev, struct page, lru)
+
+#define is_dirty_page(page) PageDirty(page)
+
+void mark_page_dirty(struct page *page)
+{
+	if (!page) {
+		printk("mark_page_dirty: attempt to mark nonexistent page dirty!\n");
+		return;
+	}
+	if (!page->store) {
+		printk("mark_page_dirty: attempt to mark page: %ld without a vm_store!\n",
+			page_address(page));
+		return;
+	}
+	if (!test_and_set_bit(PG_dirty, &page->flags)) {
+		set_page_writetime(page, PG_AGE_DIRTY_PAGE);
+		add_to_dirty_page_list(page);
+		after_add_to_dirty_list();
+	} else {
+#if 0
+ 		/* This is actually a common case! */
+		printk(KERN_DEBUG "mark_page_dirty: page: %ld is already dirty!\n",
+			page - mem_map);
+#endif
+	}
+}
+
+inline void mark_page_clean(struct page *page)
+{
+	if (test_and_clear_bit(PG_dirty, &page->flags)) {
+		remove_from_dirty_page_list(page);
+	} else {
+		printk("mark_page_clean: page: %ld is already clean!\n",
+		       page_address(page));
+	}
+}
+
+/*
+ * Locks
+ * ==========================================
+ */ 
+
+/* Run the hooks that have to be done when a page I/O has completed. */
+static inline void after_unlock_page(struct page *page)
+{
+	if (test_and_clear_bit(PG_decr_after, &page->flags)) {
+		atomic_dec(&nr_async_pages);
+#ifdef DEBUG_SWAP
+		printk ("DebugVM: Finished IO on page %p, nr_async_pages %d\n",
+			(char *) page_address(page), 
+			atomic_read(&nr_async_pages));
+#endif
+	}
+	if (test_and_clear_bit(PG_swap_unlock_after, &page->flags)) {
+		swap_after_unlock_page(page->key);
+	}
+	if (test_and_clear_bit(PG_free_after, &page->flags)) {
+		__free_page(page);
+	}
+}
+
+void unlock_page(struct page *page)
+{
+	/* Note: There is a possible pathological case here
+	 * Someone may wait for a page and then toally free it
+	 * before after_unlock_page is called.  
+	 * A proper setting of PG_free_after avoids this.
+	 */
+	clear_bit(PG_locked, &page->flags);
+	wake_up(&page->wait);
+	after_unlock_page(page);
+}
+
+/*
+ * Ideally all of the resources needed on the backing store have been
+ * allocated by this point, and the only error possible would be a
+ * failure of the backing store.
+ * 
+ * Since there is at least one legitamate error condition I have implmented 
+ * some support for error handling.  Synchronous errors are returned
+ * and asynchronous catastrophics errors may be returned by setting PG_error
+ *
+ */
+int write_page(struct page *page)
+{
+	struct vm_store *store;
+	int error = 0;
+	/* Preconditions:
+	 * 1) We are in the page cache
+	 * 2) The page is not already doing some i/o.
+	 */
+	if (!page) {
+		printk(KERN_DEBUG "write_page: nonexistent page!\n");
+		return -EIO;
+	}
+	store = page->store;
+	if (!store) {
+		printk(KERN_DEBUG "write_page: page: %ld without store!\n",
+		       page_address(page));
+		error = -EIO;
+	}
+	
+	if (!error && PageDirty(page)) {
+		/* A page being written out a second time while
+		 * it is already being written should be rare case,
+		 * Therfore wait until the situation passes and then
+		 * write out the page.
+		 *
+		 * This also happens to handles the strange case of
+		 * writing a page while it is being read, and prevents it...
+		 */
+		while(test_and_set_bit(PG_locked, &page->flags)) {
+			wait_on_page(page);
+		}
+		
+		/* Mark the page clean before it is written, but
+		 * after it is certain the page will be written
+		 * so I don't have to worry about fancy locks on the
+		 * dirty page list.   And so I can detect cases where
+		 * a page becomes dirty while it is being written out.
+		 */
+		mark_page_clean(page);
+
+		if (store && store->st_ops && store->st_ops->write_page) {
+			error = store->st_ops->write_page(
+				store, page, page->key, &page->generic_pp);
+		} else {
+			printk(KERN_ERR "No write_page function!\n");
+			error = -EIO;
+		}
+	} 
+	if (error) {
+		if (PageLocked(page)) 
+			unlock_page(page);
+		if (is_dirty_page(page)) {
+			mark_page_clean(page);
+		} else {
+			printk("Attempt to write clean page %lu",
+				(long)(page - mem_map));
+		}
+		set_bit(PG_error, &page->flags);
+	}
+	return error;
+}
+
+
+/*
+ * generics
+ * ==========================================
+ */ 
+int generic_writepage(struct vm_store *store, struct page *page, unsigned long index, void **ptr)
+{
+	struct inode *inode;
+	unsigned long block;
+	int *p, nr[PAGE_SIZE/512];
+	int i;
+
+	inode = store->generic_stp;
+	atomic_inc(&page->count);
+	set_bit(PG_free_after, &page->flags);
+
+	i = PAGE_SIZE >> inode->i_sb->s_blocksize_bits;
+	block = index << (PAGE_SHIFT - inode->i_sb->s_blocksize_bits);
+	p = nr;
+	do {
+		/* FIXME: bmap doesn't allocate blocks for writing */
+		*p = inode->i_op->bmap(inode, block);
+		i--;
+		block++;
+		p++;
+	} while(i > 0);
+
+	/* IO start */
+	brw_page(WRITE, page, inode->i_dev, nr, inode->i_sb->s_blocksize, 1);
+	return 0;
+}
+
+/* Do the basic work of updating a page */
+int generic_updatepage(struct file *file, struct page *page, 
+	const char *buf, unsigned int offset,
+	unsigned int count, int sync)
+{
+	int result = count;
+
+	mark_page_dirty(page);
+
+	/* Currently I assume that by the time you get here
+	 * all needed resources have been obtained so the
+	 * write should only fail if there is a hardware error.
+	 * Which is an important case to handle, but not to optimize.
+	 */
+	if (sync) {
+		result = write_page(page);
+		wait_on_page(page);
+		if (!result && PageError(page)) {
+			result = -EIO;
+		}
+	}
+	return result;
+}
+
+/*
+ * ==========================================
+ */ 
+
+/* Here we attempt to write back old pages. 
+ */
+int sync_pcache(int old, int max_write)
+{
+	struct page * page, *next;
+	int i;
+	int ndirty = 0, nwritten = 0;
+	int min_cycle, cycles, cycle;
+
+	min_cycle = last_cycle +1;
+	cycles = (jiffies - last_run) / PG_CYCLE_TIME;
+	if (cycles > PG_CYCLES) {
+		cycles = PG_CYCLES;
+	}
+	last_run = jiffies;
+	last_cycle = (last_cycle + cycles)% PG_CYCLES;
+
+	if (!max_write) {
+		max_write = ((-1U) >> 1U);
+	}
+	debug_printk(2, (KERN_DEBUG "sync_pcache(%d,%d)\n", old, max_write));
+repeat:
+	page = first_dirty_page();
+	i = page?atomic_read(&nr_dirty_pages):0; 
+#ifdef DEBUG
+	if (page) {
+		debug_printk(2, (KERN_DEBUG "sync_pcache: page: %ld i: %d store=%p is_dirty:%d dirty:%d locked:%d\n", 
+			(long)(page - mem_map), i,
+			page->store, is_dirty_page(page),
+			PageDirty(page), PageLocked(page) ));
+	} else {
+		debug_printk(2, (KERN_DEBUG "sync_pcache: page: (none) i: %d\n", i));
+	}
+#endif
+	for(; (i-- > 0) && (nwritten < max_write); page = next) {
+#ifdef DEBUG
+		if (current->need_resched) {
+			schedule();
+		}
+#endif		
+		/* We may have stalled while waiting for I/O to complete. */
+		if (!is_dirty_page(page)) 
+			goto repeat;
+		next = next_dirty_page(page);
+
+		if (PageLocked(page)) {
+			continue;
+		}
+		ndirty++;
+
+		cycle = (PageWCycle(page) - min_cycle)%PG_CYCLES;
+		/* It is safe to write dirty pages that are shared
+		 * because I clear the dirty indicator first.
+		 */
+		if (old && (cycle >= cycles)) {
+			continue;
+		}
+		nwritten++;
+		write_page(page);
+	}
+	debug_printk(1, (KERN_DEBUG "Wrote %d/%d buffers\n", nwritten, ndirty));
+	return nwritten;
+}
+
+
+#if 0
+/* Here we attempt to write back old pages. 
+ */
+int sync_pcache_dev(kdev_t dev)
+{
+	struct page * page, *next;
+	int i;
+	int error = 0;
+repeat:
+	page = first_dirty_page();
+	i = page?atomic_read(&nr_dirty_pages):0; 
+	for(; (i-- > 0) ; page = next) {
+		struct vm_store *store = page->store;
+		/* We may have stalled while waiting for I/O to complete. */
+		if (!is_dirty_page(page))
+			goto repeat;
+		next = next_dirty_page(page);
+
+		if (PageLocked(page) || !PageDirty(page)
+		    || (dev && store && (inode->i_dev != dev))) {
+			continue;
+		}
+		/* It is safe to write shared dirty pages */
+		error |= write_page(page);
+	}
+	return error? 0 : -EIO;
+}
+#endif
+
+/* ====================== pgflush support =================== */
+
+/* This is a simple kernel daemon, whose job it is to provide a dynamic
+ * response to dirty buffers.  Once this process is activated, we write back
+ * a limited number of buffers to the disks and then go back to sleep again.
+ */
+static DECLARE_WAIT_QUEUE_HEAD(pgflush_wait);
+static DECLARE_WAIT_QUEUE_HEAD(pgflush_done);
+struct task_struct *pgflush_tsk = 0;
+
+void wakeup_pgflush(int wait)
+{
+	if (current == pgflush_tsk)
+		return;
+	wake_up(&pgflush_wait);
+	if (wait) {
+		run_task_queue(&tq_disk);
+		sleep_on(&pgflush_done);
+	}
+}
+
+/* This is the actual pgflush daemon itself. 
+ * We launch it ourselves internally with
+ * kernel_thread(...)  directly after the first thread in init/main.c */
+
+int pgflush(void *unsused)
+{
+	/*
+	 *	We have a bare-bones task_struct, and really should fill
+	 *	in a few more things so "top" and /proc/2/{exe,root,cwd}
+	 *	display semi-sane things. Not real crucial though...  
+	 */
+
+	current->session = 1;
+	current->pgrp = 1;
+	sprintf(current->comm, "kpgflushd");
+	pgflush_tsk = current;
+
+	/*
+	 *	As a kernel thread we want to tamper with system buffers
+	 *	and other internals and thus be subject to the SMP locking
+	 *	rules. (On a uniprocessor box this does nothing).
+	 */
+	lock_kernel();
+	for(;;) {
+		int ndirty;
+
+		debug_printk(1, (KERN_DEBUG "pgflush() activaged..."));
+		
+		/* CHECK_EMERGENCY_SYNC */ /* only if I replace bdflush */
+
+		ndirty = sync_pcache(0, PG_DIRTY_WRITE_COUNT);
+
+		debug_printk(1, (KERN_DEBUG "pgflush: sleeping again.\n"));
+
+		run_task_queue(&tq_disk);
+		wake_up(&pgflush_done);
+
+		/* If there are still a lot of dirty pages around, skip the sleep 
+		 * and flush some more 
+		 */
+
+		if (ndirty == 0 || 
+		    atomic_read(&nr_dirty_pages) <= (page_cache_size * 5)/100) {
+			spin_lock_irq(&current->sigmask_lock);
+			flush_signals(current);
+			spin_unlock_irq(&current->sigmask_lock);
+
+			interruptible_sleep_on(&pgflush_wait);
+		}
+	}
+}
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb6/mm/page_syms.c linux-2.3.3.eb7/mm/page_syms.c
--- linux-2.3.3.eb6/mm/page_syms.c	Wed Dec 31 18:00:00 1969
+++ linux-2.3.3.eb7/mm/page_syms.c	Sat May 22 18:23:49 1999
@@ -0,0 +1,38 @@
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/fs.h>
+#include <linux/pagemap.h>
+#include <linux/mm.h>
+#include <linux/vm_store.h>
+
+/* store functions */
+EXPORT_SYMBOL(get_store_page);
+EXPORT_SYMBOL(invalidate_store_pages);
+EXPORT_SYMBOL(zap_store_pages);
+EXPORT_SYMBOL(remove_store_page);
+EXPORT_SYMBOL(update_vm_store_cache);
+EXPORT_SYMBOL(sync_store_pages);
+EXPORT_SYMBOL(wait_on_store_pages);
+
+/* filemap functions */
+EXPORT_SYMBOL(invalidate_inode_pages);
+EXPORT_SYMBOL(truncate_inode_pages);
+EXPORT_SYMBOL(sync_inode_pages);
+EXPORT_SYMBOL(zap_inode_pages);
+EXPORT_SYMBOL(update_vm_cache);
+EXPORT_SYMBOL(get_inode_page);
+
+/* pagemap functions */
+
+EXPORT_SYMBOL(add_to_page_cache);
+EXPORT_SYMBOL(page_cache_size);
+EXPORT_SYMBOL(page_hash_table);
+EXPORT_SYMBOL(__wait_on_page);
+
+EXPORT_SYMBOL(mark_page_dirty);
+EXPORT_SYMBOL(mark_page_clean);
+EXPORT_SYMBOL(unlock_page);
+
+EXPORT_SYMBOL(write_page);
+EXPORT_SYMBOL(generic_writepage);
+EXPORT_SYMBOL(generic_updatepage);
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb6/mm/vm_store.c linux-2.3.3.eb7/mm/vm_store.c
--- linux-2.3.3.eb6/mm/vm_store.c	Sat May 22 18:19:40 1999
+++ linux-2.3.3.eb7/mm/vm_store.c	Sat May 22 18:23:49 1999
@@ -14,7 +14,9 @@
 	struct page **hash)
 {
 	atomic_inc(&page->count);
-	page->flags = (page->flags & ~((1 << PG_uptodate) | (1 << PG_error))) | (1 << PG_referenced);
+	page->flags = (page->flags & 
+		~((1 << PG_uptodate) | (1 << PG_error) | (1 << PG_dirty))) 
+		| (1 << PG_referenced);
 	page->key = key;
 	add_page_to_store_queue(store, page);
 	__add_page_to_hash_queue(page, hash);
@@ -67,6 +69,10 @@
 	if (store && store->st_ops && store->st_ops->clear_page) {
 		(store->st_ops->clear_page)(store, page, page->key, &page->generic_pp);
 	}
+	/* If clear_page left us with a dirty page forget it */
+	if (PageDirty(page)) {
+		mark_page_clean(page);
+	}
 	remove_page_from_hash_queue(page);
 	remove_page_from_store_queue(page);
 	page_cache_release(page);
@@ -151,6 +157,49 @@
 	} while (count);
 }
 
+/* 
+ * Make 1 pass through the pages and start I/O on all of the pages.
+ * If an I/O error is detected -EIO is returned.
+ * If non errors are detected 0 is returned.
+ */
+int sync_store_pages(struct vm_store *store)
+{
+	struct page *page, *next;
+	int error = 0;
+	page = store->st_pages;
+	for(; page != NULL; page = next) {
+		/* compute the next element early in case we sleep and the
+		 * page goes away
+		 */
+		next = page->next;
+		if (PageLocked(page)) {
+			continue;
+		}
+		if (PageDirty(page)) {
+			error |= write_page(page);
+		}
+	}
+	return error? -EIO : 0;
+}
+
+/* Make 1 pass through the store pages,
+ * waiting on each page is uptodate, and locked.
+ * If an I/O error is detected -EIO is returned
+ */
+int wait_on_store_pages(struct vm_store *store) 
+{
+	int error = 0;
+	struct page *page;
+	page = store->st_pages;
+	for(; page != NULL; page = page->next) {
+		while (PageLocked(page) && PageUptodate(page)) {
+			atomic_inc(&page->count);
+			wait_on_page(page);
+		}
+		error |= PageError(page);
+	}
+	return error? -EIO : 0;
+}
 
 /* 
  * Wait for IO to complete on a locked page.
@@ -176,6 +225,7 @@
 	remove_wait_queue(&page->wait, &wait);
 }
 
+/* Find a freeable page and free it */
 int shrink_mmap(int priority, int gfp_mask)
 {
 	static unsigned long clock = 0;
@@ -207,7 +257,7 @@
 		
 		referenced = test_and_clear_bit(PG_referenced, &page->flags);
 
-		if (PageLocked(page))
+		if (PageLocked(page) || PageDirty(page))
 			continue;
 
 		if ((gfp_mask & __GFP_DMA) && !PageDMA(page))
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb6/mm/vmscan.c linux-2.3.3.eb7/mm/vmscan.c
--- linux-2.3.3.eb6/mm/vmscan.c	Sat May 22 17:16:37 1999
+++ linux-2.3.3.eb7/mm/vmscan.c	Sat May 22 18:23:49 1999
@@ -385,6 +385,13 @@
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
 
+	/* Write out dirty pages when memory gets low.
+	 * Eventually they will unlock and we can free them if needed.
+	 */
+	if (atomic_read(&nr_dirty_pages)) {
+		wakeup_pgflush(0);
+	}
+ 
 	priority = 6;
 	do {
 		while (shrink_mmap(priority, gfp_mask)) {
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
