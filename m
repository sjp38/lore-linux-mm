Date: Wed, 4 Aug 1999 13:33:30 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: [patch] minimal page-LRU
Message-ID: <Pine.LNX.4.10.9908041310460.2739-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, MOLNAR Ingo <mingo@redhat.com>, "David S. Miller" <davem@redhat.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I cleanedup the page-LRU code and I removed everything unrelated and I
tried to stay in sync as much as possible with the current 2.3.12 VM. The
patch should be the _shorter_ as possible and it should be safe as far as
the 2.3.12 VM is safe.

The patch reduces of an order of magnitude the complexity of shrink_mmap
(that now runs in O(num_physpages)) at the expense of two more pointer in
each struct page. It also make shrink_mmap SMP threaded in respect of the
big kernel lock and of the page cache. The page-LRU now is completly
orthogonal with the pagecache_lock. The improvement should be _huge_ in
high memory machines that uses most of memory in shm or anonymous memory
and where the working set doesn't fit all in cache.

The patch is against clean 2.3.12 and just includes the shrink_mmap fix to
consider a progress the freeing of a anonymous or metadata buffer.

There are still various minor bugs and races in the current VM (unrelated
with the patch) but I'll address them leather (otherwise the patch would
grow too much and I would like to get the page-LRU code included before
the freeze ;). For example is_page_shared and do_wp_page are not aware of
the additional reference of the buffer cache, and some locking issue in
do_wp_page/free_page_and_swap_cache (they can't sleep but they uses
delete_from_swap_cache that _can_ sleep).

diff -ur 2.3.12/fs/buffer.c 2.3.12-lru/fs/buffer.c
--- 2.3.12/fs/buffer.c	Sun Aug  1 18:11:17 1999
+++ 2.3.12-lru/fs/buffer.c	Wed Aug  4 00:40:08 1999
@@ -1252,7 +1252,7 @@
 	if (!PageLocked(page))
 		BUG();
 	if (!page->buffers)
-		return 0;
+		return 1;
 
 	head = page->buffers;
 	bh = head;
@@ -1293,10 +1293,13 @@
 	 */
 	if (!offset) {
 		if (!try_to_free_buffers(page))
+		{
 			atomic_add(PAGE_CACHE_SIZE, &buffermem);
+			return 0;
+		}
 	}
 
-	return 0;
+	return 1;
 }
 
 static void create_empty_buffers(struct page *page, struct inode *inode, unsigned long blocksize)
@@ -1905,6 +1908,7 @@
 static int grow_buffers(int size)
 {
 	unsigned long page;
+	struct page * page_map;
 	struct buffer_head *bh, *tmp;
 	struct buffer_head * insert_point;
 	int isize;
@@ -1947,7 +1951,9 @@
 	free_list[isize].list = bh;
 	spin_unlock(&free_list[isize].lock);
 
-	mem_map[MAP_NR(page)].buffers = bh;
+	page_map = mem_map + MAP_NR(page);
+	page_map->buffers = bh;
+	lru_cache_add(page_map, 0);
 	atomic_add(PAGE_SIZE, &buffermem);
 	return 1;
 }
diff -ur 2.3.12/fs/dcache.c 2.3.12-lru/fs/dcache.c
--- 2.3.12/fs/dcache.c	Tue Jul 13 02:01:39 1999
+++ 2.3.12-lru/fs/dcache.c	Tue Aug  3 18:28:27 1999
@@ -20,6 +20,7 @@
 #include <linux/malloc.h>
 #include <linux/slab.h>
 #include <linux/init.h>
+#include <linux/smp_lock.h>
 
 #include <asm/uaccess.h>
 
@@ -473,9 +474,11 @@
 {
 	if (gfp_mask & __GFP_IO) {
 		int count = 0;
+		lock_kernel();
 		if (priority)
 			count = dentry_stat.nr_unused / priority;
 		prune_dcache(count);
+		unlock_kernel();
 	}
 }
 
diff -ur 2.3.12/include/linux/mm.h 2.3.12-lru/include/linux/mm.h
--- 2.3.12/include/linux/mm.h	Wed Aug  4 12:28:17 1999
+++ 2.3.12-lru/include/linux/mm.h	Wed Aug  4 12:28:42 1999
@@ -125,6 +125,7 @@
 	struct page *next_hash;
 	atomic_t count;
 	unsigned long flags;	/* atomic flags, some possibly updated asynchronously */
+	struct list_head lru;
 	wait_queue_head_t wait;
 	struct page **pprev_hash;
 	struct buffer_head * buffers;
diff -ur 2.3.12/include/linux/swap.h 2.3.12-lru/include/linux/swap.h
--- 2.3.12/include/linux/swap.h	Wed Aug  4 12:28:17 1999
+++ 2.3.12-lru/include/linux/swap.h	Wed Aug  4 12:31:15 1999
@@ -64,6 +64,8 @@
 
 extern int nr_swap_pages;
 extern int nr_free_pages;
+extern int nr_lru_pages;
+extern struct list_head lru_cache, lru_swap_cache;
 extern atomic_t nr_async_pages;
 extern struct inode swapper_inode;
 extern atomic_t page_cache_size;
@@ -160,6 +162,27 @@
 		count--;
 	return  count > 1;
 }
+
+extern spinlock_t pagemap_lru_lock;
+
+/*
+ * Helper macros for lru_pages handling.
+ */
+#define	lru_cache_add(page, swap_cache)					     \
+do {									     \
+	spin_lock(&pagemap_lru_lock);					     \
+	list_add(&(page)->lru, !(swap_cache) ? &lru_cache:&lru_swap_cache); \
+	nr_lru_pages++;							     \
+	spin_unlock(&pagemap_lru_lock);					     \
+} while (0)
+
+#define	lru_cache_del(page)			\
+do {						\
+	spin_lock(&pagemap_lru_lock);		\
+	list_del(&(page)->lru);			\
+	nr_lru_pages--;				\
+	spin_unlock(&pagemap_lru_lock);		\
+} while (0)
 
 #endif /* __KERNEL__*/
 
diff -ur 2.3.12/ipc/shm.c 2.3.12-lru/ipc/shm.c
--- 2.3.12/ipc/shm.c	Thu Jul 22 01:07:28 1999
+++ 2.3.12-lru/ipc/shm.c	Tue Aug  3 16:16:16 1999
@@ -719,10 +719,12 @@
 	int loop = 0;
 	int counter;
 	struct page * page_map;
+	int ret = 0;
 	
+	lock_kernel();
 	counter = shm_rss >> prio;
 	if (!counter || !(swap_nr = get_swap_page()))
-		return 0;
+		goto out_unlock;
 
  check_id:
 	shp = shm_segs[swap_id];
@@ -755,7 +757,7 @@
 	if (--counter < 0) { /* failed */
 		failed:
 		swap_free (swap_nr);
-		return 0;
+		goto out_unlock;
 	}
 	if (page_count(mem_map + MAP_NR(pte_page(page))) != 1)
 		goto check_table;
@@ -768,7 +770,10 @@
 	swap_successes++;
 	shm_swp++;
 	shm_rss--;
-	return 1;
+	ret = 1;
+ out_unlock:
+	unlock_kernel();
+	return ret;
 }
 
 /*
diff -ur 2.3.12/mm/filemap.c 2.3.12-lru/mm/filemap.c
--- 2.3.12/mm/filemap.c	Thu Jul 22 01:07:28 1999
+++ 2.3.12-lru/mm/filemap.c	Wed Aug  4 12:04:11 1999
@@ -33,6 +33,8 @@
  *
  * finished 'unifying' the page and buffer cache and SMP-threaded the
  * page-cache, 21.05.1999, Ingo Molnar <mingo@redhat.com>
+ *
+ * SMP-threaded pagemap-LRU 1999, Andrea Arcangeli <andrea@suse.de>
  */
 
 atomic_t page_cache_size = ATOMIC_INIT(0);
@@ -40,6 +42,11 @@
 struct page **page_hash_table;
 
 spinlock_t pagecache_lock = SPIN_LOCK_UNLOCKED;
+/*
+ * NOTE: to avoid deadlocking you must never acquire the pagecache_lock with
+ *       the pagemap_lru_lock held.
+ */
+spinlock_t pagemap_lru_lock = SPIN_LOCK_UNLOCKED;
 
 
 void __add_page_to_hash_queue(struct page * page, struct page **p)
@@ -117,6 +124,7 @@
 		}
 		if (page_count(page) != 2)
 			printk("hm, busy page invalidated? (not necesserily a bug)\n");
+		lru_cache_del(page);
 
 		remove_page_from_inode_queue(page);
 		remove_page_from_hash_queue(page);
@@ -151,8 +159,9 @@
 
 			lock_page(page);
 
-			if (inode->i_op->flushpage)
-				inode->i_op->flushpage(inode, page, 0);
+			if (!inode->i_op->flushpage ||
+			    inode->i_op->flushpage(inode, page, 0))
+				lru_cache_del(page);
 
 			/*
 			 * We remove the page from the page cache
@@ -214,91 +223,65 @@
 
 extern atomic_t too_many_dirty_buffers;
 
-int shrink_mmap(int priority, int gfp_mask)
+static inline int shrink_mmap_lru(struct list_head * lru, int * count,
+				  int gfp_mask)
 {
-	static unsigned long clock = 0;
-	unsigned long limit = num_physpages << 1;
+	int ret = 0;
+	LIST_HEAD(young);
+	LIST_HEAD(old);
+	LIST_HEAD(forget);
+	struct list_head * page_lru, * dispose;
 	struct page * page;
-	int count, users;
-
-	count = limit >> priority;
 
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
+	while (*count > 0 && (page_lru = lru->prev) != lru)
+	{
+		page = list_entry(page_lru, struct page, lru);
+		list_del(page_lru);
+
+		if (test_and_clear_bit(PG_referenced, &page->flags))
+		{
+			/* Roll the page at the top of the lru list,
+			 * we could also be more aggressive putting
+			 * the page in the young-dispose-list, so
+			 * avoiding to free young pages in each pass.
+			 */
+			list_add(page_lru, lru);
+			continue;
 		}
-		
-		referenced = test_and_clear_bit(PG_referenced, &page->flags);
+		spin_unlock(&pagemap_lru_lock);
 
+		dispose = &old;
 		if ((gfp_mask & __GFP_DMA) && !PageDMA(page))
-			continue;
+			goto dispose_continue;
 
-		count--;
+		(*count)--;
 
-		/*
-		 * Some common cases that we just short-circuit without
-		 * getting the locks - we need to re-check this once we
-		 * have the lock, but that's fine.
-		 */
-		users = page_count(page);
-		if (!users)
-			continue;
-		if (!page->buffers) {
-			if (!page->inode)
-				continue;
-			if (users > 1)
-				continue;
-		}
+		dispose = &young;
+		/* avoid unscalable SMP locking */
+		if (!page->buffers && page_count(page) > 1)
+			goto dispose_continue;
 
-		/*
-		 * ok, now the page looks interesting. Re-check things
-		 * and keep the lock.
-		 */
 		spin_lock(&pagecache_lock);
-		if (!page->inode && !page->buffers) {
-			spin_unlock(&pagecache_lock);
-			continue;
-		}
-		if (!page_count(page)) {
-			spin_unlock(&pagecache_lock);
-			BUG();
-			continue;
-		}
-		get_page(page);
-		if (TryLockPage(page)) {
+		if (TryLockPage(page))
+		{
 			spin_unlock(&pagecache_lock);
-			goto put_continue;
+			goto dispose_continue;
 		}
 
-		/*
-		 * we keep pagecache_lock locked and unlock it in
-		 * each branch, so that the page->inode case doesnt
-		 * have to re-grab it. Here comes the 'real' logic
-		 * to free memory:
-		 */
+		/* avoid freeing the page while it's locked */
+		get_page(page);
 
 		/* Is it a buffer page? */
 		if (page->buffers) {
-			int mem = page->inode ? 0 : PAGE_CACHE_SIZE;
 			spin_unlock(&pagecache_lock);
 			if (!try_to_free_buffers(page))
 				goto unlock_continue;
-			atomic_sub(mem, &buffermem);
+			/* page was locked, inode can't go away under us */
+			if (!page->inode)
+			{
+				atomic_sub(PAGE_CACHE_SIZE, &buffermem);
+				goto made_buffer_progress;
+			}
 			spin_lock(&pagecache_lock);
 		}
 
@@ -307,7 +290,7 @@
 		 * (count == 2 because we added one ourselves above).
 		 */
 		if (page_count(page) != 2)
-			goto spin_unlock_continue;
+			goto cache_unlock_continue;
 
 		/*
 		 * Is it a page swap page? If so, we want to
@@ -316,35 +299,73 @@
 		 */
 		if (PageSwapCache(page)) {
 			spin_unlock(&pagecache_lock);
-			if (referenced && swap_count(page->offset) != 2)
-				goto unlock_continue;
 			__delete_from_swap_cache(page);
-			page_cache_release(page);
-			goto made_progress;
+			goto made_inode_progress;
 		}	
 
 		/* is it a page-cache page? */
-		if (!referenced && page->inode && !pgcache_under_min()) {
-			remove_page_from_inode_queue(page);
-			remove_page_from_hash_queue(page);
-			page->inode = NULL;
-			spin_unlock(&pagecache_lock);
-
-			page_cache_release(page);
-			goto made_progress;
+		if (page->inode)
+		{
+			dispose = &old;
+			if (!pgcache_under_min())
+			{
+				remove_page_from_inode_queue(page);
+				remove_page_from_hash_queue(page);
+				page->inode = NULL;
+				spin_unlock(&pagecache_lock);
+				goto made_inode_progress;
+			}
+			goto cache_unlock_continue;
 		}
-spin_unlock_continue:
+
+		dispose = &forget;
+		printk(KERN_ERR "shrink_mmap: unknown LRU page!\n");
+
+cache_unlock_continue:
 		spin_unlock(&pagecache_lock);
 unlock_continue:
 		UnlockPage(page);
-put_continue:
 		put_page(page);
-	} while (count > 0);
-	return 0;
-made_progress:
+dispose_continue:
+		/* no need of the spinlock to play with the
+		   local dispose lists */
+		list_add(page_lru, dispose);
+		spin_lock(&pagemap_lru_lock);
+	}
+	goto out;
+
+made_inode_progress:
+	page_cache_release(page);
+made_buffer_progress:
 	UnlockPage(page);
 	put_page(page);
-	return 1;
+	ret = 1;
+	spin_lock(&pagemap_lru_lock);
+	/* nr_lru_pages needs the spinlock */
+	nr_lru_pages--;
+
+out:
+	list_splice(&young, lru);
+	list_splice(&old, lru->prev);
+
+	return ret;
+}
+
+int shrink_mmap(int priority, int gfp_mask)
+{
+	int ret = 0, count, i;
+	struct list_head * lru[2] = { &lru_swap_cache, &lru_cache, };
+
+	count = nr_lru_pages / (priority+1);
+
+	spin_lock(&pagemap_lru_lock);
+
+	for (i=0; count > 0 && !ret && i<2; i++)
+		ret = shrink_mmap_lru(lru[i], &count, gfp_mask);
+
+	spin_unlock(&pagemap_lru_lock);
+
+	return ret;
 }
 
 static inline struct page * __find_page_nolock(struct inode * inode, unsigned long offset, struct page *page)
@@ -461,13 +482,14 @@
 {
 	unsigned long flags;
 
-	flags = page->flags & ~((1 << PG_uptodate) | (1 << PG_error));
-	page->flags = flags |  ((1 << PG_locked) | (1 << PG_referenced));
+	flags = page->flags & ~((1 << PG_uptodate) | (1 << PG_error) | (1 << PG_referenced));
+	page->flags = flags | (1 << PG_locked);
 	page->owner = current;	/* REMOVEME */
 	get_page(page);
 	page->offset = offset;
 	add_page_to_inode_queue(inode, page);
 	__add_page_to_hash_queue(page, hash);
+	lru_cache_add(page, PageSwapCache(page));
 }
 
 void add_to_page_cache(struct page * page, struct inode * inode, unsigned long offset)
diff -ur 2.3.12/mm/page_alloc.c 2.3.12-lru/mm/page_alloc.c
--- 2.3.12/mm/page_alloc.c	Tue Jul 13 02:02:40 1999
+++ 2.3.12-lru/mm/page_alloc.c	Mon Aug  2 17:21:47 1999
@@ -20,6 +20,9 @@
 
 int nr_swap_pages = 0;
 int nr_free_pages = 0;
+int nr_lru_pages;
+LIST_HEAD(lru_cache);
+LIST_HEAD(lru_swap_cache);
 
 /*
  * Free area management
@@ -127,7 +130,6 @@
 		if (PageLocked(page))
 			PAGE_BUG(page);
 
-		page->flags &= ~(1 << PG_referenced);
 		free_pages_ok(page - mem_map, 0);
 		return 1;
 	}
@@ -145,7 +147,6 @@
 				PAGE_BUG(map);
 			if (PageLocked(map))
 				PAGE_BUG(map);
-			map->flags &= ~(1 << PG_referenced);
 			free_pages_ok(map_nr, order);
 			return 1;
 		}
@@ -269,8 +270,9 @@
  	unsigned long total = 0;
 
 	printk("Free pages:      %6dkB\n ( ",nr_free_pages<<(PAGE_SHIFT-10));
-	printk("Free: %d (%d %d %d)\n",
+	printk("Free: %d, lru_cache: %d (%d %d %d)\n",
 		nr_free_pages,
+		nr_lru_pages,
 		freepages.min,
 		freepages.low,
 		freepages.high);
diff -ur 2.3.12/mm/swap_state.c 2.3.12-lru/mm/swap_state.c
--- 2.3.12/mm/swap_state.c	Tue Jul 13 02:02:10 1999
+++ 2.3.12-lru/mm/swap_state.c	Wed Aug  4 13:23:04 1999
@@ -214,8 +214,6 @@
 		   page_address(page), page_count(page));
 #endif
 	PageClearSwapCache(page);
-	if (inode->i_op->flushpage)
-		inode->i_op->flushpage(inode, page, 0);
 	remove_inode_page(page);
 }
 
@@ -239,6 +237,15 @@
 	swap_free (entry);
 }
 
+static void delete_from_swap_cache_nolock(struct page *page)
+{
+	if (!swapper_inode.i_op->flushpage ||
+	    swapper_inode.i_op->flushpage(&swapper_inode, page, 0))
+		lru_cache_del(page);
+
+	__delete_from_swap_cache(page);
+}
+
 /*
  * This must be called only on pages that have
  * been verified to be in the swap cache.
@@ -247,7 +254,7 @@
 {
 	lock_page(page);
 
-	__delete_from_swap_cache(page);
+	delete_from_swap_cache_nolock(page);
 
 	UnlockPage(page);
 	page_cache_release(page);
@@ -267,9 +274,7 @@
 	 */
 	lock_page(page);
 	if (PageSwapCache(page) && !is_page_shared(page)) {
-		long entry = page->offset;
-		remove_from_swap_cache(page);
-		swap_free(entry);
+		delete_from_swap_cache_nolock(page);
 		page_cache_release(page);
 	}
 	UnlockPage(page);
diff -ur 2.3.12/mm/vmscan.c 2.3.12-lru/mm/vmscan.c
--- 2.3.12/mm/vmscan.c	Thu Jul 22 01:07:28 1999
+++ 2.3.12-lru/mm/vmscan.c	Wed Aug  4 12:16:35 1999
@@ -323,7 +323,9 @@
 {
 	struct task_struct * p, * pbest;
 	int counter, assign, max_cnt;
+	int ret = 0;
 
+	lock_kernel();
 	/* 
 	 * We make one or two passes through the task list, indexed by 
 	 * assign = {0, 1}:
@@ -373,11 +375,14 @@
 			goto out;
 		}
 
+		ret = 1;
 		if (swap_out_process(pbest, gfp_mask))
-			return 1;
+			goto out;
+		ret = 0;
 	}
 out:
-	return 0;
+	unlock_kernel();
+	return ret;
 }
 
 /*
@@ -394,8 +399,6 @@
 	int priority;
 	int count = SWAP_CLUSTER_MAX;
 
-	lock_kernel();
-
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
 
@@ -423,7 +426,6 @@
 		shrink_dcache_memory(priority, gfp_mask);
 	} while (--priority >= 0);
 done:
-	unlock_kernel();
 
 	return priority >= 0;
 }


I did only a little not interesting benchmark. I compiled the kernel with
2.3.12 and 2.3.12-LRU and these are the numbers:

2.3.12:
real    3m0.974s
user    3m22.400s
sys     0m16.350s

2.3.12-lru:
real    2m58.483s
user    3m23.350s
sys     0m15.920s

NOTE: I have 128mbyte of ram so the kernel almost fit in cache during the
compile and there isn't high I/O activity so I didn't ever expected such
two seconds improvement...

Anyway I had many old numbers about my 2.2.x lru patches that show an huge
improvement (and in 2.2.x my shrink_mmap wasn't smp-threaded...).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
