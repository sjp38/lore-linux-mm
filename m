Date: Wed, 4 Aug 1999 20:05:00 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] minimal page-LRU
In-Reply-To: <Pine.LNX.4.10.9908041725380.401-100000@laser.random>
Message-ID: <Pine.LNX.4.10.9908041946030.404-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, MOLNAR Ingo <mingo@redhat.com>, "David S. Miller" <davem@redhat.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Aug 1999, Andrea Arcangeli wrote:

>Continuing thinking about the code I just found a race condition between
>the page-LRU shrink_mmap and truncate_inode_pages() ;).

I did some more profiling and I noticed a performance problem.

I had to join the two global page-lru headers into one, since in the
lru-patch I am proposing for inclusion I removed the code to take the
pages mapped in process space (so unfreeable from shrink_mmap) out of the
lru list (since it was increasing a lot the complxity of the code now that
everything is SMP threaded).

So with the current code that still uses the double lru-lists but is not
capable to skip the mapped-pages, if there would be 10mbyte of swap cache
mapped in process space I would end up trying to free such 10mbyte of
memory at each shrink_mmap pass... not good. NOTE: this performance
problem can trigger only with swap cache mapped in the process space (I
couldn't notice that with the kernel compile bench).

The reason I was using two lists is that shrinking the swap cache before
touching the page-cache _far_ better preserve the working set.

So here it is a strighforward patch (incremental to the second I posted
today) to take all pages queued in the same lru list. These are only
details, the core of the code doesn't change at all:

diff -ur 2.3.12-lruswap/fs/buffer.c 2.3.12-lru/fs/buffer.c
--- 2.3.12-lruswap/fs/buffer.c	Wed Aug  4 19:17:22 1999
+++ 2.3.12-lru/fs/buffer.c	Wed Aug  4 19:24:08 1999
@@ -1953,7 +1953,7 @@
 
 	page_map = mem_map + MAP_NR(page);
 	page_map->buffers = bh;
-	lru_cache_add(page_map, 0);
+	lru_cache_add(page_map);
 	atomic_add(PAGE_SIZE, &buffermem);
 	return 1;
 }
diff -ur 2.3.12-lruswap/include/linux/swap.h 2.3.12-lru/include/linux/swap.h
--- 2.3.12-lruswap/include/linux/swap.h	Wed Aug  4 19:17:22 1999
+++ 2.3.12-lru/include/linux/swap.h	Wed Aug  4 19:15:26 1999
@@ -65,7 +65,7 @@
 extern int nr_swap_pages;
 extern int nr_free_pages;
 extern int nr_lru_pages;
-extern struct list_head lru_cache, lru_swap_cache;
+extern struct list_head lru_cache;
 extern atomic_t nr_async_pages;
 extern struct inode swapper_inode;
 extern atomic_t page_cache_size;
@@ -168,12 +168,12 @@
 /*
  * Helper macros for lru_pages handling.
  */
-#define	lru_cache_add(page, swap_cache)					     \
-do {									     \
-	spin_lock(&pagemap_lru_lock);					     \
-	list_add(&(page)->lru, !(swap_cache) ? &lru_cache:&lru_swap_cache); \
-	nr_lru_pages++;							     \
-	spin_unlock(&pagemap_lru_lock);					     \
+#define	lru_cache_add(page)			\
+do {						\
+	spin_lock(&pagemap_lru_lock);		\
+	list_add(&(page)->lru, &lru_cache);	\
+	nr_lru_pages++;				\
+	spin_unlock(&pagemap_lru_lock);		\
 } while (0)
 
 #define	lru_cache_del(page)			\
diff -ur 2.3.12-lruswap/mm/filemap.c 2.3.12-lru/mm/filemap.c
--- 2.3.12-lruswap/mm/filemap.c	Wed Aug  4 19:17:23 1999
+++ 2.3.12-lru/mm/filemap.c	Wed Aug  4 19:23:14 1999
@@ -223,22 +223,25 @@
 
 extern atomic_t too_many_dirty_buffers;
 
-static inline int shrink_mmap_lru(struct list_head * lru, int * count,
-				  int gfp_mask)
+int shrink_mmap(int priority, int gfp_mask)
 {
-	int ret = 0;
+	int ret = 0, count;
 	LIST_HEAD(young);
 	LIST_HEAD(old);
 	LIST_HEAD(forget);
 	struct list_head * page_lru, * dispose;
 	struct page * page;
 
-	while (*count > 0 && (page_lru = lru->prev) != lru)
+	count = nr_lru_pages / (priority+1);
+
+	spin_lock(&pagemap_lru_lock);
+
+	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache)
 	{
 		page = list_entry(page_lru, struct page, lru);
 		list_del(page_lru);
 
-		dispose = lru;
+		dispose = &lru_cache;
 		if (test_and_clear_bit(PG_referenced, &page->flags))
 			/* Roll the page at the top of the lru list,
 			 * we could also be more aggressive putting
@@ -252,7 +255,7 @@
 		if ((gfp_mask & __GFP_DMA) && !PageDMA(page))
 			goto dispose_continue;
 
-		(*count)--;
+		count--;
 
 		dispose = &young;
 		if (TryLockPage(page))
@@ -362,23 +365,8 @@
 	nr_lru_pages--;
 
 out:
-	list_splice(&young, lru);
-	list_splice(&old, lru->prev);
-
-	return ret;
-}
-
-int shrink_mmap(int priority, int gfp_mask)
-{
-	int ret = 0, count, i;
-	struct list_head * lru[2] = { &lru_swap_cache, &lru_cache, };
-
-	count = nr_lru_pages / (priority+1);
-
-	spin_lock(&pagemap_lru_lock);
-
-	for (i=0; count > 0 && !ret && i<2; i++)
-		ret = shrink_mmap_lru(lru[i], &count, gfp_mask);
+	list_splice(&young, &lru_cache);
+	list_splice(&old, lru_cache.prev);
 
 	spin_unlock(&pagemap_lru_lock);
 
@@ -506,7 +494,7 @@
 	page->offset = offset;
 	add_page_to_inode_queue(inode, page);
 	__add_page_to_hash_queue(page, hash);
-	lru_cache_add(page, PageSwapCache(page));
+	lru_cache_add(page);
 }
 
 void add_to_page_cache(struct page * page, struct inode * inode, unsigned long offset)
diff -ur 2.3.12-lruswap/mm/page_alloc.c 2.3.12-lru/mm/page_alloc.c
--- 2.3.12-lruswap/mm/page_alloc.c	Wed Aug  4 19:17:23 1999
+++ 2.3.12-lru/mm/page_alloc.c	Wed Aug  4 19:16:33 1999
@@ -22,7 +22,6 @@
 int nr_free_pages = 0;
 int nr_lru_pages;
 LIST_HEAD(lru_cache);
-LIST_HEAD(lru_swap_cache);
 
 /*
  * Free area management



Now the profile numbers are fine. With 6mbyte of swap cache mapped in
memory I am running in background `cat /usr/bin/* /usr/X11R6/bin/*
>/dev/null` and a `cp /dev/hda /dev/null` and these are the profiling
numbers I get:

andrea@laser:~ > readprofile -m /System.map |sort -nr | head -20
 12536 total                                      0.0193
 12236 cpu_idle                                 145.6667
    62 file_read_actor                            0.8158
    21 ide_set_handler                            0.2917
    16 startup_32                                 0.0976
    12 try_to_free_buffers                        0.0246
    12 kmem_cache_free                            0.0280
    12 do_rw_disk                                 0.0175
    10 ide_do_request                             0.0072
     8 do_generic_file_read                       0.0036
     7 shrink_mmap                                0.0068
     6 free_pages                                 0.0174
     6 block_read_full_page                       0.0118
     5 schedule                                   0.0034
     5 remove_page_from_inode_queue               0.0833
     5 ide_wait_stat                              0.0231
     5 ide_dmaproc                                0.0137
     5 get_unused_buffer_head                     0.0192
     5 get_hash_table                             0.0291
     5 ext2_get_block                             0.0037

As you can see try_to_free_buffers is eating far more CPU than
shrink_mmap.

I also uploaded a whole patch against clean 2.3.12 that merges all the
three patches here, if somebody would try it out please feedback ;).

	ftp://e-mind.com/pub/andrea/kernel-patches/2.3.12/page_lru-2.3.12-H
	ftp://ftp.suse.com/pub/people/andrea/kernel-patches/2.3.12/page_lru-2.3.12-H

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
