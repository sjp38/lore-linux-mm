Received: from alogconduit1ah.ccr.net (root@alogconduit1ak.ccr.net [208.130.159.11])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA06498
	for <linux-mm@kvack.org>; Sun, 30 May 1999 13:42:11 -0400
Subject: [RFC] [PATCH] vm_store
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 30 May 1999 12:28:34 -0500
Message-ID: <m14sku4gcc.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.rutgers.edu, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

This patch creates the the abstraction of a vm_store, allowing the
page cache to be seperated from the vfs layer.

It also seperates out what is the page cache, from filemap.c
into mm/vm_store.c

The only vm_store operation implemented in this patch
is clear_page.  Allowing delete_from_swap_cache to stop being a
special case.


Note: This is on top of some other patches, to see my whole series
see:
http://www.ccr.net/ebiederm/files/patches9.tar.gz
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb5/arch/m68k/atari/stram.c linux-2.3.3.eb6/arch/m68k/atari/stram.c
--- linux-2.3.3.eb5/arch/m68k/atari/stram.c	Tue Feb  9 22:52:51 1999
+++ linux-2.3.3.eb6/arch/m68k/atari/stram.c	Sat May 22 18:19:39 1999
@@ -944,7 +944,7 @@
 				/* Now get rid of the extra reference to
 				   the temporary page we've been using. */
 				if (PageSwapCache(page_map))
-					delete_from_swap_cache(page_map);
+						remove_store_page(page_map);
 				__free_page(page_map);
 	#ifdef DO_PROC
 				stat_swap_force++;
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb5/fs/dcache.c linux-2.3.3.eb6/fs/dcache.c
--- linux-2.3.3.eb5/fs/dcache.c	Sun May 16 21:53:57 1999
+++ linux-2.3.3.eb6/fs/dcache.c	Sat May 22 18:19:39 1999
@@ -236,7 +236,7 @@
 		 * (We skip inodes that aren't immediately available.)
 		 */
 		if (inode) {
-			value = inode->i_nrpages;	
+			value = inode->vm_store->st_nrpages;	
 			if (value >= max_value)
 				continue;
 			if (inode->i_state || inode->i_count > 1)
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb5/fs/exec.c linux-2.3.3.eb6/fs/exec.c
--- linux-2.3.3.eb5/fs/exec.c	Sat May 22 17:16:53 1999
+++ linux-2.3.3.eb6/fs/exec.c	Sat May 22 18:19:39 1999
@@ -316,6 +316,7 @@
 		mpnt->vm_ops = NULL;
 		mpnt->vm_index = 0;
 		mpnt->vm_file = NULL;
+		mpnt->vm_store = NULL;
 		mpnt->vm_pte = 0;
 		insert_vm_struct(current->mm, mpnt);
 		current->mm->total_vm = (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb5/fs/inode.c linux-2.3.3.eb6/fs/inode.c
--- linux-2.3.3.eb5/fs/inode.c	Sat May 22 16:10:11 1999
+++ linux-2.3.3.eb6/fs/inode.c	Sat May 22 18:19:39 1999
@@ -231,14 +231,12 @@
  */
 void clear_inode(struct inode *inode)
 {
-	if (inode->i_nrpages)
-		truncate_inode_pages(inode, 0);
 	wait_on_inode(inode);
 	if (IS_QUOTAINIT(inode))
 		DQUOT_DROP(inode);
 	if (inode->i_sb && inode->i_sb->s_op && inode->i_sb->s_op->clear_inode)
 		inode->i_sb->s_op->clear_inode(inode);
-
+	zap_inode_pages(inode);
 	inode->i_state = 0;
 }
 
@@ -549,6 +547,8 @@
 		inode = list_entry(tmp, struct inode, i_list);
 add_new_inode:
 		list_add(&inode->i_list, &inode_in_use);
+		inode->vm_store->st_id = 0;
+		inode->vm_store->generic_stp = &inode;
 		inode->i_sb = NULL;
 		inode->i_dev = 0;
 		inode->i_ino = ++last_ino;
@@ -589,6 +589,8 @@
 add_new_inode:
 		list_add(&inode->i_list, &inode_in_use);
 		list_add(&inode->i_hash, head);
+		inode->vm_store->st_id = 0;
+		inode->vm_store->generic_stp = &inode;
 		inode->i_sb = sb;
 		inode->i_dev = sb->s_dev;
 		inode->i_ino = ino;
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb5/fs/locks.c linux-2.3.3.eb6/fs/locks.c
--- linux-2.3.3.eb5/fs/locks.c	Sat May 22 16:09:58 1999
+++ linux-2.3.3.eb6/fs/locks.c	Sat May 22 18:19:39 1999
@@ -403,8 +403,8 @@
 	 */
 	if (IS_MANDLOCK(inode) &&
 	    (inode->i_mode & (S_ISGID | S_IXGRP)) == S_ISGID &&
-	    inode->i_mmap) {
-		struct vm_area_struct *vma = inode->i_mmap;
+	    inode->vm_store->st_mmap) {
+		struct vm_area_struct *vma = inode->vm_store->st_mmap;
 		error = -EAGAIN;
 		do {
 			if (vma->vm_flags & VM_MAYSHARE)
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb5/include/linux/fs.h linux-2.3.3.eb6/include/linux/fs.h
--- linux-2.3.3.eb5/include/linux/fs.h	Sat May 22 17:16:36 1999
+++ linux-2.3.3.eb6/include/linux/fs.h	Sat May 22 18:19:40 1999
@@ -18,6 +18,7 @@
 #include <linux/list.h>
 #include <linux/dcache.h>
 #include <linux/stat.h>
+#include <linux/vm_store.h>
 
 #include <asm/atomic.h>
 #include <asm/bitops.h>
@@ -356,17 +357,15 @@
 	unsigned long		i_blksize;
 	unsigned long		i_blocks;
 	unsigned long		i_version;
-	unsigned long		i_nrpages;
 	struct semaphore	i_sem;
 	struct semaphore	i_atomic_write;
 	struct inode_operations	*i_op;
 	struct super_block	*i_sb;
 	wait_queue_head_t	i_wait;
 	struct file_lock	*i_flock;
-	struct vm_area_struct	*i_mmap;
-	struct page		*i_pages;
 	struct dquot		*i_dquot[MAXQUOTAS];
 
+ 	struct vm_store		vm_store[1];
 	unsigned long		i_state;
 
 	unsigned int		i_flags;
@@ -788,7 +787,6 @@
 
 extern int check_disk_change(kdev_t dev);
 extern int invalidate_inodes(struct super_block * sb);
-extern void invalidate_inode_pages(struct inode *);
 extern void invalidate_buffers(kdev_t dev);
 extern int floppy_is_wp(int minor);
 extern void sync_inodes(kdev_t dev);
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb5/include/linux/mm.h linux-2.3.3.eb6/include/linux/mm.h
--- linux-2.3.3.eb5/include/linux/mm.h	Sat May 22 17:16:53 1999
+++ linux-2.3.3.eb6/include/linux/mm.h	Sat May 22 18:19:40 1999
@@ -16,6 +16,8 @@
 #include <asm/page.h>
 #include <asm/atomic.h>
 
+struct vm_store;
+
 /*
  * Linux kernel virtual memory manager primitives.
  * The idea being to have a "virtual" mm in the same way
@@ -60,6 +62,7 @@
 	 * except the value is potentially too large for the old vm_offset field.
 	 */
 	struct file * vm_file;
+	struct vm_store *vm_store;
 	unsigned long vm_pte;			/* shared mem */
 };
 
@@ -85,6 +88,10 @@
 #define VM_LOCKED	0x2000
 #define VM_IO           0x4000  /* Memory mapped I/O or similar */
 
+#define VM_SPARSE_MERGE	0x8000 /* Sparce VMA's with non continous
+				* indecies may be merged 
+				*/
+
 #define VM_STACK_FLAGS	0x0177
 
 /*
@@ -126,7 +133,7 @@
 	/* these must be first (free area handling) */
 	struct page *next;
 	struct page *prev;
-	struct inode *inode;
+	struct vm_store *store;
 	unsigned long key;
 	struct page *next_hash;
 	atomic_t count;
@@ -325,10 +332,12 @@
 extern int do_munmap(unsigned long, size_t);
 
 /* filemap.c */
-extern void remove_inode_page(struct page *);
 extern unsigned long page_unuse(struct page *);
 extern int shrink_mmap(int, int);
 extern void truncate_inode_pages(struct inode *, loff_t);
+extern void invalidate_inode_pages(struct inode *);
+extern void zap_inode_pages(struct inode *);
+extern void update_vm_cache(struct inode *, loff_t, const char *, int);
 extern unsigned long get_cached_page(struct inode *, unsigned long, int);
 extern void put_cached_page(unsigned long);
 
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb5/include/linux/pagemap.h linux-2.3.3.eb6/include/linux/pagemap.h
--- linux-2.3.3.eb5/include/linux/pagemap.h	Sat May 22 17:16:36 1999
+++ linux-2.3.3.eb6/include/linux/pagemap.h	Sat May 22 18:19:40 1999
@@ -11,6 +11,7 @@
 
 #include <linux/mm.h>
 #include <linux/fs.h>
+#include <linux/vm_store.h>
 
 static inline unsigned long page_address(struct page * page)
 {
@@ -50,23 +51,23 @@
 /*
  * We use a power-of-two hash table to avoid a modulus,
  * and get a reasonable hash by knowing roughly how the
- * inode pointer and offsets are distributed (ie, we
+ * store pointer and offsets are distributed (ie, we
  * roughly know which bits are "significant")
  */
-static inline unsigned long _page_hashfn(struct inode * inode, unsigned long key)
+static inline unsigned long _page_hashfn(struct vm_store * store, unsigned long key)
 {
-#define i (((unsigned long) inode)/(sizeof(struct inode) & ~ (sizeof(struct inode) - 1)))
+#define i (((unsigned long) store)/(sizeof(struct inode) & ~ (sizeof(struct inode) - 1)))
 #define o (key)
-#define s(x) ((x)+((x)>>PAGE_HASH_BITS))
+#define s(x) ((x)+((x)>>PAGE_HASH_BITS)+((x)>>(PAGE_HASH_BITS*2)))
 	return s(i+o) & (PAGE_HASH_SIZE-1);
 #undef i
 #undef o
 #undef s
 }
 
-#define page_hash(inode,key) (page_hash_table+_page_hashfn(inode,key))
+#define page_hash(store,key) (page_hash_table+_page_hashfn(store,key))
 
-static inline struct page * __find_page(struct inode * inode, unsigned long key, struct page *page)
+static inline struct page * __find_page(struct vm_store * store, unsigned long key, struct page *page)
 {
 	goto inside;
 	for (;;) {
@@ -74,7 +75,7 @@
 inside:
 		if (!page)
 			goto not_found;
-		if (page->inode != inode)
+		if (page->store != store)
 			continue;
 		if (page->key == key)
 			break;
@@ -85,9 +86,9 @@
 not_found:
 	return page;
 }
-static inline struct page *find_page(struct inode * inode, unsigned long key)
+static inline struct page *find_page(struct vm_store * store, unsigned long key)
 {
-	return __find_page(inode, key, *page_hash(inode, key));
+	return __find_page(store, key, *page_hash(store, key));
 }
 
 static inline void remove_page_from_hash_queue(struct page * page)
@@ -110,19 +111,19 @@
 	page->pprev_hash = p;
 }
 
-static inline void add_page_to_hash_queue(struct page * page, struct inode * inode, unsigned long key)
+static inline void add_page_to_hash_queue(struct page * page, struct vm_store * store, unsigned long key)
 {
-	__add_page_to_hash_queue(page, page_hash(inode,key));
+	__add_page_to_hash_queue(page, page_hash(store,key));
 }
 
-static inline void remove_page_from_inode_queue(struct page * page)
+static inline void remove_page_from_store_queue(struct page * page)
 {
-	struct inode * inode = page->inode;
+	struct vm_store * store = page->store;
 
-	page->inode = NULL;
-	inode->i_nrpages--;
-	if (inode->i_pages == page)
-		inode->i_pages = page->next;
+	page->store = NULL;
+	store->st_nrpages--;
+	if (store->st_pages == page)
+		store->st_pages = page->next;
 	if (page->next)
 		page->next->prev = page->prev;
 	if (page->prev)
@@ -131,12 +132,12 @@
 	page->prev = NULL;
 }
 
-static inline void add_page_to_inode_queue(struct inode * inode, struct page * page)
+static inline void add_page_to_store_queue(struct vm_store * store, struct page * page)
 {
-	struct page **p = &inode->i_pages;
+	struct page **p = &store->st_pages;
 
-	inode->i_nrpages++;
-	page->inode = inode;
+	store->st_nrpages++;
+	page->store = store;
 	page->prev = NULL;
 	if ((page->next = *p) != NULL)
 		page->next->prev = page;
@@ -150,6 +151,8 @@
 		__wait_on_page(page);
 }
 
-extern void update_vm_cache(struct inode *, loff_t, const char *, int);
+extern void add_to_page_cache(struct page *page,
+	struct vm_store *store, unsigned long key,
+	struct page **hash);
 
 #endif
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb5/include/linux/swap.h linux-2.3.3.eb6/include/linux/swap.h
--- linux-2.3.3.eb5/include/linux/swap.h	Sat May 22 17:16:36 1999
+++ linux-2.3.3.eb6/include/linux/swap.h	Sat May 22 18:19:40 1999
@@ -66,7 +66,7 @@
 extern int nr_swap_pages;
 extern int nr_free_pages;
 extern atomic_t nr_async_pages;
-extern struct inode swapper_inode;
+extern struct vm_store swapper_store;
 extern unsigned long page_cache_size;
 extern int buffermem;
 
@@ -107,7 +107,6 @@
 /*
  * Make these inline later once they are working properly.
  */
-extern void delete_from_swap_cache(struct page *page);
 extern void free_page_and_swap_cache(unsigned long addr);
 
 /* linux/mm/swapfile.c */
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb5/include/linux/vm_store.h linux-2.3.3.eb6/include/linux/vm_store.h
--- linux-2.3.3.eb5/include/linux/vm_store.h	Wed Dec 31 18:00:00 1969
+++ linux-2.3.3.eb6/include/linux/vm_store.h	Sat May 22 18:19:40 1999
@@ -0,0 +1,52 @@
+#ifndef _LINUX_VM_STORE_H
+#define _LINUX_VM_STORE_H
+#ifdef __KERNEL__
+/*
+ * This structure replaces the use of an inode in the page cache.
+ * struct vm_store is much lighter than an inode, and several of them
+ * can be allocated per inode, to hold large files if necessary.
+ *
+ * Also this should make it much easier to handle reverse page mapping,
+ * and shared memory.
+ *
+ * Note:
+ *  This structure should be an even 32 bytes on 32 bit machines, and
+ *  an even 64 bytes on 64 bit machines.
+ */
+struct vm_store {
+	struct vm_area_struct *st_mmap;
+	struct page *st_pages;
+	unsigned long st_nrpages;
+	struct vm_store_operations *st_ops;
+
+	struct vm_store *st_next;
+	struct vm_store *st_prev;
+	long st_id;  /* user defined */
+	void *generic_stp;
+};
+
+struct vm_store_operations {
+	int (*write_page) (struct vm_store *, struct page *, unsigned long key, void **p);
+	void (*clear_page) (struct vm_store *, struct page *, unsigned long key, void **p);
+};
+
+static inline struct vm_store * find_store(struct vm_store * first, unsigned long id)
+{
+	struct vm_store *store;
+	for(store = first; store != 0; store = store->st_next) {
+		if (store->st_id == id) 
+			break;
+	}
+	return store;
+}
+extern struct page *get_store_page(struct vm_store *store,
+	unsigned long index, unsigned long *page_cache_ptr);
+extern void invalidate_store_pages(struct vm_store *store);
+extern void zap_store_pages(struct vm_store * store, unsigned long low, unsigned long high);
+extern void remove_store_page(struct page *page);
+extern int shrink_mmap(int priority, int gfp_mask);
+extern void update_vm_store_cache(struct vm_store *store,
+	unsigned long index, unsigned long offset, const char * buf, int count);
+
+#endif /* KERNEL */
+#endif /* _LINUX_VM_STORE_H */
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb5/ipc/shm.c linux-2.3.3.eb6/ipc/shm.c
--- linux-2.3.3.eb5/ipc/shm.c	Sat May 22 17:20:31 1999
+++ linux-2.3.3.eb6/ipc/shm.c	Sat May 22 18:19:40 1999
@@ -513,6 +513,7 @@
 			 | VM_MAYREAD | VM_MAYEXEC | VM_READ | VM_EXEC
 			 | ((shmflg & SHM_RDONLY) ? 0 : VM_MAYWRITE | VM_WRITE);
 	shmd->vm_file = NULL;
+	shmd->vm_store = NULL;
 	shmd->vm_index = 0;
 	shmd->vm_ops = &shm_vm_ops;
 
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb5/mm/Makefile linux-2.3.3.eb6/mm/Makefile
--- linux-2.3.3.eb5/mm/Makefile	Sat May 22 17:09:32 1999
+++ linux-2.3.3.eb6/mm/Makefile	Sat May 22 18:19:40 1999
@@ -10,7 +10,8 @@
 O_TARGET := mm.o
 O_OBJS	 := memory.o mmap.o filemap.o mprotect.o mlock.o mremap.o \
 	    vmalloc.o slab.o \
-	    swap.o vmscan.o page_io.o page_alloc.o swap_state.o swapfile.o
+	    swap.o vmscan.o page_io.o page_alloc.o swap_state.o swapfile.o \
+	    vm_store.o
 
 OX_OBJS := swap_syms.o
 
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb5/mm/filemap.c linux-2.3.3.eb6/mm/filemap.c
--- linux-2.3.3.eb5/mm/filemap.c	Sat May 22 17:27:18 1999
+++ linux-2.3.3.eb6/mm/filemap.c	Sat May 22 18:21:10 1999
@@ -53,7 +53,6 @@
 static inline void 
 make_pio_request(struct file *, unsigned long, unsigned long);
 
-
 /*
  * Invalidate the pages of an inode, removing all pages that aren't
  * locked down (those are sure to be up-to-date anyway, so we shouldn't
@@ -61,25 +60,7 @@
  */
 void invalidate_inode_pages(struct inode * inode)
 {
-	struct page ** p;
-	struct page * page;
-
-	p = &inode->i_pages;
-	while ((page = *p) != NULL) {
-		if (PageLocked(page)) {
-			p = &page->next;
-			continue;
-		}
-		inode->i_nrpages--;
-		if ((*p = page->next) != NULL)
-			(*p)->prev = page->prev;
-		page->next = NULL;
-		page->prev = NULL;
-		remove_page_from_hash_queue(page);
-		page->inode = NULL;
-		page_cache_release(page);
-		continue;
-	}
+ 	invalidate_store_pages(inode->vm_store);
 }
 
 /*
@@ -88,7 +69,6 @@
  */
 void truncate_inode_pages(struct inode * inode, loff_t start)
 {
-	struct page ** p;
 	struct page * page;
 	unsigned long last_keep, partial_keep;
 	unsigned long keep_bytes;
@@ -100,30 +80,11 @@
 	partial_keep = start >> PAGE_CACHE_SHIFT;
 	last_keep = partial_keep + (keep_bytes?1:0);
 
-repeat:
-	p = &inode->i_pages;
-	while ((page = *p) != NULL) {
-		unsigned long index = page->key;
-
-		/* page wholly truncated - free it */
-		if (index >= last_keep) {
-			if (PageLocked(page)) {
-				wait_on_page(page);
-				goto repeat;
-			}
-			inode->i_nrpages--;
-			if ((*p = page->next) != NULL)
-				(*p)->prev = page->prev;
-			page->next = NULL;
-			page->prev = NULL;
-			remove_page_from_hash_queue(page);
-			page->inode = NULL;
-			page_cache_release(page);
-			continue;
-		}
-		p = &page->next;
+	zap_store_pages(inode->vm_store, last_keep, -1);
+	if (keep_bytes) {
 		/* partial truncate, clear end of page */
-		if (index == partial_keep) {
+		page = find_page(inode->vm_store, partial_keep);
+		if (page) {
 			unsigned long address = page_address(page);
 			memset((void *) (keep_bytes + address), 0, PAGE_CACHE_SIZE - keep_bytes);
 			flush_page_to_ram(address);
@@ -131,93 +92,14 @@
 	}
 }
 
-/*
- * Remove a page from the page cache and free it.
- */
-void remove_inode_page(struct page *page)
+/* Remove all store pages */
+void zap_inode_pages(struct inode *inode)
 {
-	remove_page_from_hash_queue(page);
-	remove_page_from_inode_queue(page);
-	page_cache_release(page);
-}
-
-int shrink_mmap(int priority, int gfp_mask)
-{
-	static unsigned long clock = 0;
-	unsigned long limit = num_physpages;
-	struct page * page;
-	int count;
-
-	count = limit >> priority;
-
-	page = mem_map + clock;
-	do {
-		int referenced;
-
-		/* This works even in the presence of PageSkip because
-		 * the first two entries at the beginning of a hole will
-		 * be marked, not just the first.
-		 */
-		page++;
-		clock++;
-		if (clock >= max_mapnr) {
-			clock = 0;
-			page = mem_map;
-		}
-		if (PageSkip(page)) {
-			/* next_hash is overloaded for PageSkip */
-			page = page->next_hash;
-			clock = page - mem_map;
-		}
-		
-		referenced = test_and_clear_bit(PG_referenced, &page->flags);
-
-		if (PageLocked(page))
-			continue;
-
-		if ((gfp_mask & __GFP_DMA) && !PageDMA(page))
-			continue;
-
-		/* We can't free pages unless there's just one user */
-		if (atomic_read(&page->count) != 1)
-			continue;
-
-		count--;
-
-		/*
-		 * Is it a page swap page? If so, we want to
-		 * drop it if it is no longer used, even if it
-		 * were to be marked referenced..
-		 */
-		if (PageSwapCache(page)) {
-			if (referenced && swap_count(page->key) != 1)
-				continue;
-			delete_from_swap_cache(page);
-			return 1;
-		}	
-
-		if (referenced)
-			continue;
-
-		/* Is it a buffer page? */
-		if (PageBuffer(page)) {
-			if (buffer_under_min())
-				continue;
-			if (!try_to_free_buffers(page))
-				continue;
-			return 1;
-		}
-
-		/* is it a page-cache page? */
-		if (page->inode) {
-			if (pgcache_under_min())
-				continue;
-			remove_inode_page(page);
-			return 1;
-		}
-
-	} while (count > 0);
-	return 0;
+	struct vm_store *store, *next;
+	for(store = inode->vm_store; store != NULL; store = next) {
+		next = store->st_next;
+		zap_store_pages(store, 0, -1);
+	}
 }
 
 /*
@@ -226,42 +108,21 @@
  */
 void update_vm_cache(struct inode * inode, loff_t pos, const char * buf, int count)
 {
-	unsigned long offset, len, index;
+	unsigned long offset, index;
 
 	if (pos > PAGE_MAX_FILE_OFFSET) {
 		return;
 	}
 	offset = (pos & ~PAGE_CACHE_MASK);
 	index = pos >> PAGE_CACHE_SHIFT;
-	len = PAGE_CACHE_SIZE - offset;
-	do {
-		struct page * page;
+	update_vm_store_cache(inode->vm_store, index, offset, buf, count);
+}
 
-		if (len > count)
-			len = count;
-		page = find_page(inode, index);
-		if (page) {
-			wait_on_page(page);
-			memcpy((void *) (offset + page_address(page)), buf, len);
-			page_cache_release(page);
-		}
-		count -= len;
-		buf += len;
-		len = PAGE_CACHE_SIZE;
-		offset = 0;
-		index++
-	} while (count);
-}
-
-static inline void add_to_page_cache(struct page * page,
-	struct inode * inode, unsigned long key,
-	struct page **hash)
-{
-	atomic_inc(&page->count);
-	page->flags = (page->flags & ~((1 << PG_uptodate) | (1 << PG_error))) | (1 << PG_referenced);
-	page->key = key;
-	add_page_to_inode_queue(inode, page);
-	__add_page_to_hash_queue(page, hash);
+struct page *get_inode_page(
+	struct inode *inode, loff_t page, unsigned long *page_cache_ptr)
+{
+	unsigned long index = page >> PAGE_CACHE_SHIFT;
+	return get_store_page(inode->vm_store, index, page_cache_ptr);
 }
 
 /*
@@ -273,57 +134,26 @@
 				unsigned long index, unsigned long page_cache)
 {
 	struct inode *inode = file->f_dentry->d_inode;
+	struct vm_store *store = inode->vm_store;
 	struct page * page;
-	struct page ** hash;
 
-	switch (page_cache) {
-	case 0:
-		page_cache = page_cache_alloc();
-		if (!page_cache)
-			break;
-	default:
-		if ((((loff_t)index) << PAGE_CACHE_SHIFT) > inode->i_size)
-			break;
-		hash = page_hash(inode, index);
-		page = __find_page(inode, index, *hash);
-		if (!page) {
+	/* FIXME loff_t used in a loop . . . */
+	page = NULL;
+	if ((((loff_t) index) << PAGE_CACHE_SHIFT) < inode->i_size) {
+		page = get_store_page(store, index, &page_cache);
+	}
+	if (page) {
+		if (!PageUptodate(page) && !PageLocked(page)) {
 			/*
-			 * Ok, add the new page to the hash-queues...
+			 * Ok, read the new page...
 			 */
-			page = page_cache_entry(page_cache);
-			add_to_page_cache(page, inode, index, hash);
 			inode->i_op->readpage(file, page);
-			page_cache = 0;
 		}
 		page_cache_release(page);
 	}
 	return page_cache;
 }
 
-/* 
- * Wait for IO to complete on a locked page.
- *
- * This must be called with the caller "holding" the page,
- * ie with increased "page->count" so that the page won't
- * go away during the wait..
- */
-void __wait_on_page(struct page *page)
-{
-	struct task_struct *tsk = current;
-	DECLARE_WAITQUEUE(wait, tsk);
-
-	add_wait_queue(&page->wait, &wait);
-repeat:
-	tsk->state = TASK_UNINTERRUPTIBLE;
-	run_task_queue(&tq_disk);
-	if (PageLocked(page)) {
-		schedule();
-		goto repeat;
-	}
-	tsk->state = TASK_RUNNING;
-	remove_wait_queue(&page->wait, &wait);
-}
-
 #if 0
 #define PROFILE_READAHEAD
 #define DEBUG_READAHEAD
@@ -478,7 +308,7 @@
  * page only.
  */
 	if (PageLocked(page)) {
-		if (!filp->f_ralen || ppos >= raend || ppos + filp->f_ralen < raend) {
+		if (!filp->f_ralen || index >= raend || index + filp->f_ralen < raend) {
 			raend = index;
 			if (((loff_t)raend << PAGE_CACHE_SHIFT) < inode->i_size)
 				max_ahead = filp->f_ramax;
@@ -590,8 +420,7 @@
 {
 	struct dentry *dentry = filp->f_dentry;
 	struct inode *inode = dentry->d_inode;
-	unsinged long page_cache, index;
-	size_t pos, pgpos, page_cache;
+	unsigned long page_cache, index;
 	int reada_ok;
 	int max_readahead = get_max_readahead(inode);
 	loff_t pos;
@@ -644,7 +473,7 @@
 	}
 
 	for (;;) {
-		struct page *page, **hash;
+		struct page *page;
 
 		if (pos >= inode->i_size)
 			break;
@@ -657,9 +486,12 @@
 		/*
 		 * Try to find the data in the page cache..
 		 */
-		hash = page_hash(inode, index);
-		page = __find_page(inode, index, *hash);
-		if (!page)
+		page = get_inode_page(inode, pos, &page_cache);
+		if (!page) {
+			desc->error = -ENOMEM;
+			break;
+		}
+		if (!PageUptodate(page) && !PageLocked(page))
 			goto no_cached_page;
 
 found_page:
@@ -710,29 +542,6 @@
 
 no_cached_page:
 		/*
-		 * Ok, it wasn't cached, so we need to create a new
-		 * page..
-		 */
-		if (!page_cache) {
-			page_cache = page_cache_alloc();
-			/*
-			 * That could have slept, so go around to the
-			 * very beginning..
-			 */
-			if (page_cache)
-				continue;
-			desc->error = -ENOMEM;
-			break;
-		}
-
-		/*
-		 * Ok, add the new page to the hash-queues...
-		 */
-		page = page_cache_entry(page_cache);
-		page_cache = 0;
-		add_to_page_cache(page, inode, index, hash);
-
-		/*
 		 * Error handling is tricky. If we get a read error,
 		 * the cached page stays in the cache (but uptodate=0),
 		 * and the next process that accesses it will try to
@@ -957,7 +766,7 @@
 	struct dentry * dentry = file->f_dentry;
 	struct inode * inode = dentry->d_inode;
 	unsigned long index, reada, i;
-	struct page * page, **hash;
+	struct page * page;
 	unsigned long old_page, new_page;
 	
 
@@ -967,12 +776,14 @@
 		((((loff_t)index) << PAGE_SHIFT) >= inode->i_size))
 		goto no_page;
 
-	hash = page_hash(inode, (index >> (PAGE_CACHE_SHIFT - PAGE_SHIFT)));
 	/*
 	 * Do we have something in the page cache already?
 	 */
-	page = __find_page(inode, (index >> (PAGE_CACHE_SHIFT - PAGE_SHIFT)), *hash);
+	page = get_store_page(inode->vm_store, 
+		index >> (PAGE_CACHE_SHIFT - PAGE_SHIFT), &new_page);
 	if (!page)
+		goto failure;
+	if (!PageLocked(page) && !PageUptodate(page))
 		goto no_cached_page;
 
 found_page:
@@ -1029,28 +840,15 @@
 	for (i = 1 << page_cluster; i > 0; --i, reada++)
 		new_page = try_to_read_ahead(file, reada, new_page);
 
-	if (!new_page)
-		new_page = page_cache_alloc();
-	if (!new_page)
-		goto no_page;
-
-	/*
-	 * During getting the above page we might have slept,
-	 * so we need to re-check the situation with the page
-	 * cache.. The page we just got may be useful if we
-	 * can't share, so don't get rid of it here.
-	 */
-	page = __find_page(inode, (index >> (PAGE_CACHE_SHIFT - PAGE_SHIFT)), *hash);
-	if (page)
+	/* While reading ahead we might have slept */
+	if (PageLocked(page) || PageUptodate(page))
 		goto found_page;
 
-	/*
-	 * Now, create a new page-cache page from the page we got
-	 */
-	page = page_cache_entry(new_page);
-	new_page = 0;
-	add_to_page_cache(page, inode, (index >> (PAGE_CACHE_SHIFT - PAGE_SHIFT)), hash);
-
+	/* Note: If we are past the end of the file
+	 * this routine is expected to clear the page and set
+	 * PG_uptotdate.  This handles the cases of private anonymous
+	 * pages, past then end of the file.
+  	 */
 	if (inode->i_op->readpage(file, page) != 0)
 		goto failure;
 
@@ -1081,7 +879,8 @@
 	 * mm layer so, possibly freeing the page cache page first.
 	 */
 failure:
-	page_cache_release(page);
+	if (page)
+		page_cache_release(page);
 	if (new_page)
 		page_cache_free(new_page);
 no_page:
@@ -1343,6 +1142,7 @@
 	struct vm_operations_struct * ops;
 	struct inode *inode = file->f_dentry->d_inode;
 	unsigned long index;
+	struct vm_store *store;
 
 	if ((offset > PAGE_MAX_FILE_OFFSET) ||
 		((offset + (vma->vm_end - vma->vm_start)) > PAGE_MAX_FILE_OFFSET)) {
@@ -1366,7 +1166,9 @@
 		return -EACCES;
 	if (!inode->i_op || !inode->i_op->readpage)
 		return -ENOEXEC;
+	store = inode->vm_store;
 	UPDATE_ATIME(inode);
+	vma->vm_store = store;
 	vma->vm_index = index;
 	vma->vm_ops = ops;
 	return 0;
@@ -1480,7 +1282,7 @@
 	struct inode	*inode = dentry->d_inode; 
 	loff_t pos = *ppos;
 	loff_t limit = current->rlim[RLIMIT_FSIZE].rlim_cur;
-	struct page	*page, **hash;
+	struct page	*page;
 	unsigned long	page_cache = 0;
 	unsigned long	written;
 	long		status, sync;
@@ -1525,30 +1327,20 @@
 	}
 
 	while (count) {
-		unsigned long bytes, index, offset;
+		unsigned long bytes, offset;
 		/*
 		 * Try to find the page in the cache. If it isn't there,
 		 * allocate a free page.
 		 */
 		offset = (pos & ~PAGE_CACHE_MASK);
-		index = pos >> PAGE_CACHE_SHIFT;
 		bytes = PAGE_CACHE_SIZE - offset;
 		if (bytes > count)
 			bytes = count;
 
-		hash = page_hash(inode, index);
-		page = __find_page(inode, index, *hash);
+		page = get_inode_page(inode, pos, &page_cache);
 		if (!page) {
-			if (!page_cache) {
-				page_cache = page_cache_alloc();
-				if (page_cache)
-					continue;
-				status = -ENOMEM;
-				break;
-			}
-			page = page_cache_entry(page_cache);
-			add_to_page_cache(page, inode, index, hash);
-			page_cache = 0;
+			status = -ENOMEM;
+			break;
 		}
 
 		/* Get exclusive IO access to the page.. */
@@ -1603,33 +1395,29 @@
 				int new)
 {
 	struct page * page;
-	struct page ** hash;
 	unsigned long page_cache = 0;
 	unsigned long index;
+	unsigned long new_page = 0;
 
 	index = offset >> PAGE_CACHE_SHIFT;
 
-	hash = page_hash(inode, index);
-	page = __find_page(inode, index, *hash);
-	if (!page) {
-		if (!new)
-			goto out;
-		page_cache = page_cache_alloc();
-		if (!page_cache)
-			goto out;
-		clear_page(page_cache);
-		page = page_cache_entry(page_cache);
-		add_to_page_cache(page, inode, index, hash);
-	}
-	if (atomic_read(&page->count) != 2)
-		printk(KERN_ERR "get_cached_page: page count=%d\n",
-			atomic_read(&page->count));
-	if (test_bit(PG_locked, &page->flags))
-		printk(KERN_ERR "get_cached_page: page already locked!\n");
-	set_bit(PG_locked, &page->flags);
-	page_cache = page_address(page);
-
-out:
+	if (new) {
+		page = get_store_page(inode->vm_store, index, &new_page);
+	} else {
+		page = find_page(inode->vm_store, index);
+	}
+	if (page) {
+		if (atomic_read(&page->count) != 2)
+			printk(KERN_ERR "get_cached_page: page count=%d\n",
+				atomic_read(&page->count));
+		if (test_bit(PG_locked, &page->flags))
+			printk(KERN_ERR "get_cached_page: page already locked!\n");
+		set_bit(PG_locked, &page->flags);
+		page_cache = page_address(page);
+	}
+	if (new_page) {
+		free_page(new_page);
+	}
 	return page_cache;
 }
 
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb5/mm/memory.c linux-2.3.3.eb6/mm/memory.c
--- linux-2.3.3.eb5/mm/memory.c	Sat May 22 17:16:55 1999
+++ linux-2.3.3.eb6/mm/memory.c	Sat May 22 18:19:40 1999
@@ -649,7 +649,7 @@
 			break;
 		if (swap_count(page_map->key) != 1)
 			break;
-		delete_from_swap_cache(page_map);
+		remove_store_page(page_map);
 		/* FallThrough */
 	case 1:
 		/* We can release the kernel lock now.. */
@@ -740,13 +740,13 @@
 	struct vm_area_struct * mpnt;
 
 	truncate_inode_pages(inode, offset);
-	if ((!inode->i_mmap) || (offset > PAGE_MAX_FILE_OFFSET)) {
+	if ((!inode->vm_store->st_mmap) || (offset > PAGE_MAX_FILE_OFFSET)) {
 		return;
 	}
 	index = offset >> PAGE_CACHE_SHIFT;
 	partial = offset & PAGE_CACHE_MASK;
 	trunk_index = index + (partial)? 1 : 0;
-	mpnt = inode->i_mmap;
+	mpnt = inode->vm_store->st_mmap;
 	do {
 		struct mm_struct *mm = mpnt->vm_mm;
 		unsigned long start = mpnt->vm_start;
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb5/mm/mmap.c linux-2.3.3.eb6/mm/mmap.c
--- linux-2.3.3.eb5/mm/mmap.c	Sat May 22 17:16:56 1999
+++ linux-2.3.3.eb6/mm/mmap.c	Sat May 22 18:19:40 1999
@@ -74,10 +74,13 @@
 static inline void remove_shared_vm_struct(struct vm_area_struct *vma)
 {
 	struct file * file = vma->vm_file;
+	struct vm_store *store = vma->vm_store;
 
 	if (file) {
 		if (vma->vm_flags & VM_DENYWRITE)
 			file->f_dentry->d_inode->i_writecount++;
+	}
+	if (store) {
 		if(vma->vm_next_share)
 			vma->vm_next_share->vm_pprev_share = vma->vm_pprev_share;
 		*vma->vm_pprev_share = vma->vm_next_share;
@@ -280,6 +283,7 @@
 	vma->vm_ops = NULL;
 	vma->vm_index = 0;
 	vma->vm_file = NULL;
+	vma->vm_store = NULL;
 	vma->vm_pte = 0;
 
 	/* Clear old maps */
@@ -530,6 +534,7 @@
 		mpnt->vm_ops = area->vm_ops;
 		mpnt->vm_index = area->vm_index + ((end - area->vm_start) >> PAGE_SHIFT);
 		mpnt->vm_file = area->vm_file;
+		mpnt->vm_store = area->vm_store;
 		mpnt->vm_pte = area->vm_pte;
 		if (mpnt->vm_file)
 			mpnt->vm_file->f_count++;
@@ -755,6 +760,7 @@
 {
 	struct vm_area_struct **pprev;
 	struct file * file;
+	struct vm_store *store;
 
 	if (!mm->mmap_avl) {
 		pprev = &mm->mmap;
@@ -779,12 +785,14 @@
 		struct inode * inode = file->f_dentry->d_inode;
 		if (vmp->vm_flags & VM_DENYWRITE)
 			inode->i_writecount--;
-      
-		/* insert vmp into inode's share list */
-		if((vmp->vm_next_share = inode->i_mmap) != NULL)
-			inode->i_mmap->vm_pprev_share = &vmp->vm_next_share;
-		inode->i_mmap = vmp;
-		vmp->vm_pprev_share = &inode->i_mmap;
+	}
+	store = vmp->vm_store;
+	if (store) {
+      		/* insert vmp into store's share list */
+		if((vmp->vm_next_share = store->st_mmap) != NULL)
+			store->st_mmap->vm_pprev_share = &vmp->vm_next_share;
+		store->st_mmap = vmp;
+		vmp->vm_pprev_share = &store->st_mmap;
 	}
 }
 
@@ -818,7 +826,8 @@
 		next = mpnt->vm_next;
 
 		/* To share, we must have the same file, operations.. */
-		if ((mpnt->vm_file != prev->vm_file)||
+		if ((mpnt->vm_file != prev->vm_file)	||
+		    (mpnt->vm_store != prev->vm_store)	||
 		    (mpnt->vm_pte != prev->vm_pte)	||
 		    (mpnt->vm_ops != prev->vm_ops)	||
 		    (mpnt->vm_flags != prev->vm_flags)	||
@@ -829,6 +838,7 @@
 		 * If we have a file or it's a shared memory area
 		 * the offsets must be contiguous..
 		 */
+		/*  use VM_SPARCE_MERGE here? */
 		if ((mpnt->vm_file != NULL) || (mpnt->vm_flags & VM_SHM)) {
 			unsigned long off = prev->vm_index + 
 				((prev->vm_end - prev->vm_start) >> PAGE_SHIFT);
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb5/mm/page_alloc.c linux-2.3.3.eb6/mm/page_alloc.c
--- linux-2.3.3.eb5/mm/page_alloc.c	Sat May 22 16:10:03 1999
+++ linux-2.3.3.eb6/mm/page_alloc.c	Sat May 22 18:19:40 1999
@@ -425,7 +425,7 @@
 	 * down the swap cache and give exclusive access to the page to
 	 * this process.
 	 */
-	delete_from_swap_cache(page_map);
+	remove_store_page(page_map);
 	set_pte(page_table, pte_mkwrite(pte_mkdirty(mk_pte(page, vma->vm_page_prot))));
   	return;
 }
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb5/mm/page_io.c linux-2.3.3.eb6/mm/page_io.c
--- linux-2.3.3.eb5/mm/page_io.c	Sat May 22 17:16:37 1999
+++ linux-2.3.3.eb6/mm/page_io.c	Sat May 22 18:19:40 1999
@@ -237,7 +237,7 @@
 {
 	struct page *page = mem_map + MAP_NR(buf);
 
-	if (page->inode && page->inode != &swapper_inode)
+	if (page->store && page->store != &swapper_store)
 		panic ("Tried to swap a non-swapper page");
 
 	/*
@@ -274,16 +274,16 @@
 		printk ("VM: read_swap_page: page already in swap cache!\n");
 		return;
 	}
-	if (page->inode) {
+	if (page->store) {
 		printk ("VM: read_swap_page: page already in page cache!\n");
 		return;
 	}
-	page->inode = &swapper_inode;
+	page->store = &swapper_store;
 	page->key = entry;
 	atomic_inc(&page->count);	/* Protect from shrink_mmap() */
 	rw_swap_page(rw, entry, buffer, 1);
 	atomic_dec(&page->count);
-	page->inode = 0;
+	page->store = 0;
 	clear_bit(PG_swap_cache, &page->flags);
 }
 
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb5/mm/swap_state.c linux-2.3.3.eb6/mm/swap_state.c
--- linux-2.3.3.eb5/mm/swap_state.c	Sat May 22 17:16:37 1999
+++ linux-2.3.3.eb6/mm/swap_state.c	Sat May 22 18:19:40 1999
@@ -13,9 +13,16 @@
 #include <linux/swapctl.h>
 #include <linux/init.h>
 #include <linux/pagemap.h>
+#include <linux/vm_store.h>
 
 #include <asm/pgtable.h>
 
+static void clear_swap_page(struct vm_store *, struct page *, unsigned long, void **);
+struct vm_store_operations swap_operations = {
+	NULL,
+	clear_swap_page
+};
+		
 /* 
  * Keep a reserved false inode which we will use to mark pages in the
  * page cache are acting as swap cache instead of file cache. 
@@ -25,7 +32,11 @@
  * ensure that any mistaken dereferences of this structure cause a
  * kernel oops.
  */
-struct inode swapper_inode;
+struct vm_store swapper_store =
+{
+	NULL, NULL, 0, &swap_operations,
+	NULL, NULL, 0, NULL
+};
 
 #ifdef SWAP_CACHE_INFO
 unsigned long swap_cache_add_total = 0;
@@ -57,16 +68,12 @@
 		       page->key, page_address(page));
 		return 0;
 	}
-	if (page->inode) {
+	if (page->store) {
 		printk(KERN_ERR "swap_cache: replacing page-cached entry "
 		       "on page %08lx\n", page_address(page));
 		return 0;
 	}
-	atomic_inc(&page->count);
-	page->inode = &swapper_inode;
-	page->key = entry;
-	add_page_to_hash_queue(page, &swapper_inode, entry);
-	add_page_to_inode_queue(&swapper_inode, page);
+	add_to_page_cache(page, &swapper_store, entry, page_hash(&swapper_store, entry));
 	return 1;
 }
 
@@ -176,45 +183,14 @@
 	goto out;
 }
 
-static inline void remove_from_swap_cache(struct page *page)
-{
-	if (!page->inode) {
-		printk ("VM: Removing swap cache page with zero inode hash "
-			"on page %08lx\n", page_address(page));
-		return;
-	}
-	if (page->inode != &swapper_inode) {
-		printk ("VM: Removing swap cache page with wrong inode hash "
-			"on page %08lx\n", page_address(page));
-	}
-
-#ifdef DEBUG_SWAP
-	printk("DebugVM: remove_from_swap_cache(%08lx count %d)\n",
-	       page_address(page), atomic_read(&page->count));
-#endif
-	PageClearSwapCache (page);
-	remove_inode_page(page);
-}
-
-
-/*
- * This must be called only on pages that have
- * been verified to be in the swap cache.
- */
-void delete_from_swap_cache(struct page *page)
+static void clear_swap_page(
+	struct vm_store *store, struct page *page, unsigned long entry, void **generic_stpp)
 {
-	long entry = page->key;
-
 #ifdef SWAP_CACHE_INFO
 	swap_cache_del_total++;
 #endif
-#ifdef DEBUG_SWAP
-	printk("DebugVM: delete_from_swap_cache(%08lx count %d, "
-	       "entry %08lx)\n",
-	       page_address(page), atomic_read(&page->count), entry);
-#endif
-	remove_from_swap_cache (page);
-	swap_free (entry);
+	PageClearSwapCache(page);
+	swap_free(entry);
 }
 
 /* 
@@ -230,7 +206,7 @@
 	 * If we are the only user, then free up the swap cache. 
 	 */
 	if (PageSwapCache(page) && !is_page_shared(page)) {
-		delete_from_swap_cache(page);
+		remove_store_page(page);
 	}
 	
 	__free_page(page);
@@ -251,10 +227,10 @@
 	swap_cache_find_total++;
 #endif
 	while (1) {
-		found = find_page(&swapper_inode, entry);
+		found = find_page(&swapper_store, entry);
 		if (!found)
 			return 0;
-		if (found->inode != &swapper_inode || !PageSwapCache(found))
+		if (found->store != &swapper_store || !PageSwapCache(found))
 			goto out_bad;
 		if (!PageLocked(found)) {
 #ifdef SWAP_CACHE_INFO
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb5/mm/swap_syms.c linux-2.3.3.eb6/mm/swap_syms.c
--- linux-2.3.3.eb5/mm/swap_syms.c	Sat May 22 17:09:32 1999
+++ linux-2.3.3.eb6/mm/swap_syms.c	Sat May 22 18:19:40 1999
@@ -13,4 +13,4 @@
 EXPORT_SYMBOL(si_swapinfo);
 EXPORT_SYMBOL(register_swap_unuse_function);
 EXPORT_SYMBOL(unregister_swap_unuse_function);
-EXPORT_SYMBOL(swapper_inode);
+EXPORT_SYMBOL(swapper_store);
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb5/mm/swapfile.c linux-2.3.3.eb6/mm/swapfile.c
--- linux-2.3.3.eb5/mm/swapfile.c	Sat May 22 17:09:32 1999
+++ linux-2.3.3.eb6/mm/swapfile.c	Sat May 22 18:19:40 1999
@@ -447,7 +447,7 @@
 		/* Now get rid of the extra reference to the temporary
                    page we've been using. */
 		if (PageSwapCache(page_map))
-			delete_from_swap_cache(page_map);
+			remove_store_page(page_map);
 		__free_page(page_map);
 		/*
 		 * Check for and clear any overflowed swap map counts.
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb5/mm/vm_store.c linux-2.3.3.eb6/mm/vm_store.c
--- linux-2.3.3.eb5/mm/vm_store.c	Wed Dec 31 18:00:00 1969
+++ linux-2.3.3.eb6/mm/vm_store.c	Sat May 22 18:19:40 1999
@@ -0,0 +1,254 @@
+#include <linux/vm_store.h>
+#include <linux/pagemap.h>
+#include <linux/mm.h>
+#include <linux/fs.h>
+#include <linux/malloc.h>
+#include <linux/swap.h>
+#include <linux/swapctl.h>
+
+#include <asm/pgtable.h>
+
+/* add a page to the page cache on a specific vm_store */
+void add_to_page_cache(struct page * page,
+	struct vm_store * store, unsigned long key,
+	struct page **hash)
+{
+	atomic_inc(&page->count);
+	page->flags = (page->flags & ~((1 << PG_uptodate) | (1 << PG_error))) | (1 << PG_referenced);
+	page->key = key;
+	add_page_to_store_queue(store, page);
+	__add_page_to_hash_queue(page, hash);
+}
+
+/*
+ * Get a store page allocating a new one if necessary.
+ * "page_cache" is a potentially free page that we could use for the
+ * cache (if it is 0 we can try to create one)
+ * If we can't find or allocate the page we return NULL;
+ */
+
+struct page *get_store_page(struct vm_store *store,
+	unsigned long index, unsigned long *page_cache_ptr)
+{
+	struct page * page;
+	struct page ** hash;
+	unsigned long page_cache;
+
+	page = 0;
+	page_cache = *page_cache_ptr;
+	
+	hash = page_hash(store, index);
+	page = __find_page(store, index, *hash);
+
+	if (!page && !page_cache) {
+		page_cache = page_cache_alloc();
+	}
+	if (!page && page_cache) {
+		page = __find_page(store, index, *hash);
+		if (!page) {
+			/*
+			 * Ok, add the new page to the hash-queues...
+			 */
+			page = mem_map + MAP_NR(page_cache);
+			add_to_page_cache(page, store, index, hash);
+			page_cache = 0;
+		} 
+	}
+	*page_cache_ptr = page_cache;
+	return page;
+}
+
+/*
+ * Remove a page from the page cache and free it.
+ */
+void remove_store_page(struct page *page)
+{
+	struct vm_store *store = page->store;
+	if (store && store->st_ops && store->st_ops->clear_page) {
+		(store->st_ops->clear_page)(store, page, page->key, &page->generic_pp);
+	}
+	remove_page_from_hash_queue(page);
+	remove_page_from_store_queue(page);
+	page_cache_release(page);
+}
+
+/*
+ * Invalidate the pages of a store, removing all pages that aren't
+ * locked down (those are sure to be up-to-date anyway, so we shouldn't
+ * invalidate them).
+ */
+void invalidate_store_pages(struct vm_store * store)
+{
+	struct page ** p;
+	struct page * page;
+
+	p = &store->st_pages;
+	while ((page = *p) != NULL) {
+		if (PageLocked(page)) {
+			p = &page->next;
+			continue;
+		}
+		remove_store_page(page);
+		continue;
+	}
+}
+
+/*
+ * Truncate the page cache at a set offset, removing the pages
+ * that are beyond that offset (and zeroing out partial pages).
+ */
+void zap_store_pages(struct vm_store * store, unsigned long low, unsigned long high)
+{
+	struct page ** p;
+	struct page * page;
+
+repeat:
+	p = &store->st_pages;
+	while ((page = *p) != NULL) {
+		unsigned long index = page->key;
+
+		/* page zapped - free it */
+		if ((index >= low) && (index <= high)){
+			if (PageLocked(page)) {
+				wait_on_page(page);
+				goto repeat;
+			}
+			remove_store_page(page);
+			continue;
+		}
+		p = &page->next;
+	}
+}
+
+
+/*
+ * Update a page cache copy, when we're doing a "write()" system call
+ * See also "update_vm_cache()".
+ */
+
+void update_vm_store_cache(struct vm_store *store,
+	unsigned long index, unsigned long offset, const char * buf, int count)
+{
+	unsigned long len;
+
+	len = PAGE_CACHE_SIZE - offset;
+	do {
+		struct page * page;
+
+		if (len > count)
+			len = count;
+		page = find_page(store, index);
+		if (page) {
+			wait_on_page(page);
+			memcpy((void *) (offset + page_address(page)), buf, len);
+			page_cache_release(page);
+		}
+		count -= len;
+		buf += len;
+		len = PAGE_CACHE_SIZE;
+		offset = 0;
+		index++;
+	} while (count);
+}
+
+
+/* 
+ * Wait for IO to complete on a locked page.
+ *
+ * This must be called with the caller "holding" the page,
+ * ie with increased "page->count" so that the page won't
+ * go away during the wait..
+ */
+void __wait_on_page(struct page *page)
+{
+	struct task_struct *tsk = current;
+	DECLARE_WAITQUEUE(wait, tsk);
+
+	add_wait_queue(&page->wait, &wait);
+repeat:
+	tsk->state = TASK_UNINTERRUPTIBLE;
+	run_task_queue(&tq_disk);
+	if (PageLocked(page)) {
+		schedule();
+		goto repeat;
+	}
+	tsk->state = TASK_RUNNING;
+	remove_wait_queue(&page->wait, &wait);
+}
+
+int shrink_mmap(int priority, int gfp_mask)
+{
+	static unsigned long clock = 0;
+	unsigned long limit = num_physpages;
+	struct page * page;
+	int count;
+
+	count = limit >> priority;
+
+	page = mem_map + clock;
+	do {
+		int referenced;
+
+		/* This works even in the presence of PageSkip because
+		 * the first two entries at the beginning of a hole will
+		 * be marked, not just the first.
+		 */
+		page++;
+		clock++;
+		if (clock >= max_mapnr) {
+			clock = 0;
+			page = mem_map;
+		}
+		if (PageSkip(page)) {
+			/* next_hash is overloaded for PageSkip */
+			page = page->next_hash;
+			clock = page - mem_map;
+		}
+		
+		referenced = test_and_clear_bit(PG_referenced, &page->flags);
+
+		if (PageLocked(page))
+			continue;
+
+		if ((gfp_mask & __GFP_DMA) && !PageDMA(page))
+			continue;
+
+		/* We can't free pages unless there's just one user */
+		if (atomic_read(&page->count) != 1)
+			continue;
+
+		count--;
+
+		/*
+		 * Is it a page swap page? If so, we want to
+		 * drop it if it is no longer used, even if it
+		 * were to be marked referenced..
+		 */
+		if (referenced && PageSwapCache(page) && 
+			(swap_count(page->key) == 1)) {
+			referenced = 0;
+
+		}
+		if (referenced)
+			continue;
+
+		/* Is it a buffer page? */
+		if (PageBuffer(page)) {
+			if (buffer_under_min())
+				continue;
+			if (!try_to_free_buffers(page))
+				continue;
+			return 1;
+		}
+
+		/* is it a page-cache page? */
+		if (page->store) {
+			if (!PageSwapCache(page) && pgcache_under_min())
+				continue;
+			remove_store_page(page);
+			return 1;
+		}
+
+	} while (count > 0);
+	return 0;
+}




--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
