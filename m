Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 2D22E16B81
	for <linux-mm@kvack.org>; Fri, 25 May 2001 15:49:52 -0300 (EST)
Date: Fri, 25 May 2001 15:49:47 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] VM update
Message-ID: <Pine.LNX.4.33.0105251547290.10469-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Bulent Abali <abali@us.ibm.com>, Dave Jones <davej@powertweak.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

this patch contains:
1) yesterday's VM patch, but this time against the -ac
   kernel, cleaned up by Davej Jones to patch

2) some old cruft which can now be deleted from the -ac
   kernels, including even a whitespace change to reduce
   the differences between -linus and -ac

I guess I'll need to send a patch just like this to
Linus too, with most of the obvious -ac VM changes ;)

Please apply for the next -ac kernel.

Rik
--
Linux MM bugzilla: http://linux-mm.org/bugzilla.shtml

Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/




--- linux-2.4.4-ac17/mm/mmap.c.orig	Fri May 25 15:33:04 2001
+++ linux-2.4.4-ac17/mm/mmap.c	Fri May 25 15:42:03 2001
@@ -62,7 +62,7 @@
 	    return 1;

 	free = atomic_read(&buffermem_pages);
-	free += atomic_read(&page_cache_size) ;
+	free += atomic_read(&page_cache_size);
 	free -= atomic_read(&shmem_nrpages);
 	free += nr_free_pages();
 	free += nr_swap_pages;
--- linux-2.4.4-ac17/mm/oom_kill.c.orig	Fri May 25 15:33:04 2001
+++ linux-2.4.4-ac17/mm/oom_kill.c	Fri May 25 15:37:45 2001
@@ -188,15 +188,11 @@
  *
  * Returns 0 if there is still enough memory left,
  * 1 when we are out of memory (otherwise).
- *
- * Note that since __alloc_pages() never lets user
- * allocations go below freepages.min, we have to
- * use a slightly higher threshold here...
  */
 int out_of_memory(void)
 {
 	/* Enough free memory?  Not OOM. */
-	if (nr_free_pages() > freepages.min + 4)
+	if (nr_free_pages() > freepages.min)
 		return 0;

 	if (nr_free_pages() + nr_inactive_clean_pages() > freepages.low)
--- linux-2.4.4-ac17/mm/page_alloc.c.orig	Fri May 25 15:33:04 2001
+++ linux-2.4.4-ac17/mm/page_alloc.c	Fri May 25 15:33:10 2001
@@ -250,10 +250,10 @@
 				water_mark = z->pages_high;
 		}

-		if (z->free_pages + z->inactive_clean_pages > water_mark) {
+		if (z->free_pages + z->inactive_clean_pages >= water_mark) {
 			struct page *page = NULL;
 			/* If possible, reclaim a page directly. */
-			if (direct_reclaim && z->free_pages < z->pages_min + 8)
+			if (direct_reclaim)
 				page = reclaim_page(z);
 			/* If that fails, fall back to rmqueue. */
 			if (!page)
@@ -313,7 +313,7 @@
 		if (!z->size)
 			BUG();

-		if (z->free_pages >= z->pages_low) {
+		if (z->free_pages >= z->pages_min + 8) {
 			page = rmqueue(z, order);
 			if (page)
 				return page;
@@ -435,18 +435,26 @@
 		}
 		/*
 		 * When we arrive here, we are really tight on memory.
+		 * Since kswapd didn't succeed in freeing pages for us,
+		 * we try to help it.
 		 *
-		 * We try to free pages ourselves by:
-		 * 	- shrinking the i/d caches.
-		 * 	- reclaiming unused memory from the slab caches.
-		 * 	- swapping/syncing pages to disk (done by page_launder)
-		 * 	- moving clean pages from the inactive dirty list to
-		 * 	  the inactive clean list. (done by page_launder)
+		 * Single page allocs loop until the allocation succeeds.
+		 * Multi-page allocs can fail due to memory fragmentation;
+		 * in that case we bail out to prevent infinite loops and
+		 * hanging device drivers ...
+		 *
+		 * Another issue are GFP_BUFFER allocations; because they
+		 * do not have __GFP_IO set it's possible we cannot make
+		 * any progress freeing pages, in that case it's better
+		 * to give up than to deadlock the kernel looping here.
 		 */
 		if (gfp_mask & __GFP_WAIT) {
 			memory_pressure++;
-			try_to_free_pages(gfp_mask);
-			goto try_again;
+			if (!order || free_shortage()) {
+				int progress = try_to_free_pages(gfp_mask);
+				if (progress || gfp_mask & __GFP_IO)
+					goto try_again;
+			}
 		}
 	}

@@ -481,6 +489,10 @@
 				return page;
 		}

+		/* Don't let GFP_BUFFER allocations eat all the memory. */
+		if (gfp_mask==GFP_BUFFER && z->free_pages < z->pages_min * 3/4)
+			continue;
+
 		/* XXX: is pages_min/4 a good amount to reserve for this? */
 		if (z->free_pages < z->pages_min / 4 &&
 				!(current->flags & PF_MEMALLOC))
@@ -491,7 +503,7 @@
 	}

 	/* No luck.. */
-	printk(KERN_ERR "__alloc_pages: %lu-order allocation failed.\n", order);
+//	printk(KERN_ERR "__alloc_pages: %lu-order allocation failed.\n", order);
 	return NULL;
 }

@@ -605,6 +617,27 @@


 /*
+ * Total amount of inactive_clean (allocatable) RAM in a given zone.
+ */
+#ifdef CONFIG_HIGHMEM
+unsigned int nr_free_buffer_pages_zone (int zone_type)
+{
+	pg_data_t	*pgdat;
+	unsigned int	 sum;
+
+	sum = 0;
+	pgdat = pgdat_list;
+	while (pgdat) {
+		sum += (pgdat->node_zones+zone_type)->free_pages;
+		sum += (pgdat->node_zones+zone_type)->inactive_clean_pages;
+		sum += (pgdat->node_zones+zone_type)->inactive_dirty_pages;
+		pgdat = pgdat->node_next;
+	}
+	return sum;
+}
+#endif
+
+/*
  * Amount of free RAM allocatable as buffer memory:
  *
  * For HIGHMEM systems don't count HIGHMEM pages.
@@ -615,35 +648,35 @@
 {
 	unsigned int sum;

-#if	CONFIG_HIGHMEM
+#ifdef CONFIG_HIGHMEM
 	sum = nr_free_pages_zone(ZONE_NORMAL) +
-	      nr_free_pages_zone(ZONE_DMA) +
-	      nr_inactive_clean_pages_zone(ZONE_NORMAL) +
-	      nr_inactive_clean_pages_zone(ZONE_DMA);
+	      nr_free_pages_zone(ZONE_DMA);
 #else
 	sum = nr_free_pages() +
 	      nr_inactive_clean_pages();
-#endif
 	sum += nr_inactive_dirty_pages;
+#endif

 	/*
 	 * Keep our write behind queue filled, even if
-	 * kswapd lags a bit right now.
+	 * kswapd lags a bit right now. Make sure not
+	 * to clog up the whole inactive_dirty list with
+	 * dirty pages, though.
 	 */
-	if (sum < freepages.high + inactive_target)
-		sum = freepages.high + inactive_target;
+	if (sum < freepages.high + inactive_target / 2)
+		sum = freepages.high + inactive_target / 2;
 	/*
 	 * We don't want dirty page writebehind to put too
 	 * much pressure on the working set, but we want it
 	 * to be possible to have some dirty pages in the
 	 * working set without upsetting the writebehind logic.
 	 */
-	sum += nr_active_pages >> 4;
+	sum += nr_active_pages >> 5;

 	return sum;
 }

-#if CONFIG_HIGHMEM
+#ifdef CONFIG_HIGHMEM
 unsigned int nr_free_highpages (void)
 {
 	pg_data_t *pgdat = pgdat_list;
--- linux-2.4.4-ac17/mm/vmscan.c.orig	Fri May 25 15:33:04 2001
+++ linux-2.4.4-ac17/mm/vmscan.c	Fri May 25 15:45:23 2001
@@ -865,14 +865,18 @@

 	/*
 	 * If we're low on free pages, move pages from the
-	 * inactive_dirty list to the inactive_clean list.
+	 * inactive_dirty list to the inactive_clean list
+	 * and shrink the inode and dentry caches.
 	 *
 	 * Usually bdflush will have pre-cleaned the pages
 	 * before we get around to moving them to the other
 	 * list, so this is a relatively cheap operation.
 	 */
-	if (free_shortage())
+	if (free_shortage()) {
 		ret += page_launder(gfp_mask, user);
+		shrink_dcache_memory(DEF_PRIORITY, gfp_mask);
+		shrink_icache_memory(DEF_PRIORITY, gfp_mask);
+	}

 	/*
 	 * If needed, we move pages from the active list
@@ -882,21 +886,10 @@
 		ret += refill_inactive(gfp_mask, user);

 	/*
-	 * Delete pages from the inode and dentry caches and
-	 * reclaim unused slab cache if memory is low.
+	 * If we're still short on free pages, reclaim unused
+	 * slab cache memory.
 	 */
 	if (free_shortage()) {
-		shrink_dcache_memory(DEF_PRIORITY, gfp_mask);
-		shrink_icache_memory(DEF_PRIORITY, gfp_mask);
-	} else {
-		/*
-		 * Illogical, but true. At least for now.
-		 *
-		 * If we're _not_ under shortage any more, we
-		 * reap the caches. Why? Because a noticeable
-		 * part of the caches are the buffer-heads,
-		 * which we'll want to keep if under shortage.
-		 */
 		kmem_cache_reap(gfp_mask);
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
