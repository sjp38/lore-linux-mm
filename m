Content-Type: text/plain;
  charset="us-ascii"
From: Ed Tomlinson <tomlins@cam.org>
Subject: [PATCH][RFC] slabnow
Date: Sat, 7 Sep 2002 10:06:18 -0400
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200209071006.18869.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@zip.com.au>, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

Hi,

Andrew took a good look at slablru and asked a few deep questions.  One was why does
slab not release pages immediately?  Since Rik explained that using a lazy reclaim of free
pages from the lru worked badly, it does not make much sense to use a lazy reclaim of
slab pages either...

Second question was can you do this without the lru?  He then suggested we think about
seeks.  If we assume a lru page takes a seek to recreate and a slab object also takes a
one to recreate we can use the percentage of pages reclaimed to drive the slab shrinking.

This has some major implications.  If it works well slab.c will get gutted.  We will no longer
need *shrink* calls in slab nor will kmem_cache_reap do anything and the slabs_free list
can go too...  This version of the patch defers the slab.c cleanup.

Here is my implementation.  There is one thing missing from it.  In shrink_cache we 
need to avoid shrinking when we are not working with ZONE_DMA or ZONE_NORMAL.  I
am not sure the best way to test this.  Andrew?  Also I need to find a better name for
nr_used_zone_pages, which should tell us the number of pages used by ZONE_DMA and
ZONE_NORMAL.

This is against Linus bk at cset 1.575.1.45 (Thusday evening).  Its been tested on UP
without highmem - it needs a the zone test for highmem to work correctly.  Testing
used:

find / -name "*" > /dev/null
multiple tiobenchs
dbench on reiserfs and tmpfs
gimp working with massive tifs
plus my normal workstation load

As always comments very welcome.

Ed Tomlinson

--------- slabasap_A0
# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.580   -> 1.584  
#	  include/linux/mm.h	1.77    -> 1.78   
#	     mm/page_alloc.c	1.96    -> 1.97   
#	         fs/dcache.c	1.29    -> 1.31   
#	         mm/vmscan.c	1.100   -> 1.102  
#	          fs/dquot.c	1.44    -> 1.46   
#	           mm/slab.c	1.26    -> 1.27   
#	          fs/inode.c	1.67    -> 1.69   
#	include/linux/dcache.h	1.15    -> 1.16   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/09/05	ed@oscar.et.ca	1.581
# free slab pages asap
# --------------------------------------------
# 02/09/07	ed@oscar.et.ca	1.584
# Here we assume one reclaimed page takes one seek to recreate.  We also
# assume a dentry or inode also takes a seek to rebuild.  With this in 
# mind we trim the cache by the same percentage we trim the lru.
# --------------------------------------------
#
diff -Nru a/fs/dcache.c b/fs/dcache.c
--- a/fs/dcache.c	Sat Sep  7 09:30:46 2002
+++ b/fs/dcache.c	Sat Sep  7 09:30:46 2002
@@ -573,19 +572,11 @@
 
 /*
  * This is called from kswapd when we think we need some
- * more memory, but aren't really sure how much. So we
- * carefully try to free a _bit_ of our dcache, but not
- * too much.
- *
- * Priority:
- *   1 - very urgent: shrink everything
- *  ...
- *   6 - base-level: try to shrink a bit.
+ * more memory. 
  */
-int shrink_dcache_memory(int priority, unsigned int gfp_mask)
+int shrink_dcache_memory(int ratio, unsigned int gfp_mask)
 {
-	int count = 0;
-
+	int entries = dentry_stat.nr_dentry / ratio + 1;
 	/*
 	 * Nasty deadlock avoidance.
 	 *
@@ -600,11 +591,8 @@
 	if (!(gfp_mask & __GFP_FS))
 		return 0;
 
-	count = dentry_stat.nr_unused / priority;
-
-	prune_dcache(count);
-	kmem_cache_shrink(dentry_cache);
-	return 0;
+	prune_dcache(entries);
+	return entries;
 }
 
 #define NAME_ALLOC_LEN(len)	((len+16) & ~15)
diff -Nru a/fs/dquot.c b/fs/dquot.c
--- a/fs/dquot.c	Sat Sep  7 09:30:46 2002
+++ b/fs/dquot.c	Sat Sep  7 09:30:46 2002
@@ -480,26 +480,17 @@
 
 /*
  * This is called from kswapd when we think we need some
- * more memory, but aren't really sure how much. So we
- * carefully try to free a _bit_ of our dqcache, but not
- * too much.
- *
- * Priority:
- *   1 - very urgent: shrink everything
- *   ...
- *   6 - base-level: try to shrink a bit.
+ * more memory
  */
 
-int shrink_dqcache_memory(int priority, unsigned int gfp_mask)
+int shrink_dqcache_memory(int ratio, unsigned int gfp_mask)
 {
-	int count = 0;
+	entries = dqstats.allocated_dquots / ratio + 1;
 
 	lock_kernel();
-	count = dqstats.free_dquots / priority;
-	prune_dqcache(count);
+	prune_dqcache(entries);
 	unlock_kernel();
-	kmem_cache_shrink(dquot_cachep);
-	return 0;
+	return entries;
 }
 
 /*
diff -Nru a/fs/inode.c b/fs/inode.c
--- a/fs/inode.c	Sat Sep  7 09:30:46 2002
+++ b/fs/inode.c	Sat Sep  7 09:30:46 2002
@@ -415,19 +415,11 @@
 
 /*
  * This is called from kswapd when we think we need some
- * more memory, but aren't really sure how much. So we
- * carefully try to free a _bit_ of our icache, but not
- * too much.
- *
- * Priority:
- *   1 - very urgent: shrink everything
- *  ...
- *   6 - base-level: try to shrink a bit.
+ * more memory. 
  */
-int shrink_icache_memory(int priority, int gfp_mask)
+int shrink_icache_memory(int ratio, unsigned int gfp_mask)
 {
-	int count = 0;
-
+	int entries = inodes_stat.nr_inodes / ratio + 1;
 	/*
 	 * Nasty deadlock avoidance..
 	 *
@@ -438,12 +430,10 @@
 	if (!(gfp_mask & __GFP_FS))
 		return 0;
 
-	count = inodes_stat.nr_unused / priority;
-
-	prune_icache(count);
-	kmem_cache_shrink(inode_cachep);
-	return 0;
+	prune_icache(entries);
+	return entries;
 }
+EXPORT_SYMBOL(shrink_icache_memory);
 
 /*
  * Called with the inode lock held.
diff -Nru a/include/linux/dcache.h b/include/linux/dcache.h
--- a/include/linux/dcache.h	Sat Sep  7 09:30:46 2002
+++ b/include/linux/dcache.h	Sat Sep  7 09:30:46 2002
@@ -186,7 +186,7 @@
 extern void prune_dcache(int);
 
 /* icache memory management (defined in linux/fs/inode.c) */
-extern int shrink_icache_memory(int, int);
+extern int shrink_icache_memory(int, unsigned int);
 extern void prune_icache(int);
 
 /* quota cache memory management (defined in linux/fs/dquot.c) */
diff -Nru a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h	Sat Sep  7 09:30:46 2002
+++ b/include/linux/mm.h	Sat Sep  7 09:30:46 2002
@@ -498,6 +498,7 @@
 
 extern struct page * vmalloc_to_page(void *addr);
 extern unsigned long get_page_cache_size(void);
+extern unsigned int nr_used_zone_pages(void);
 
 #endif /* __KERNEL__ */
 
diff -Nru a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c	Sat Sep  7 09:30:46 2002
+++ b/mm/page_alloc.c	Sat Sep  7 09:30:46 2002
@@ -486,6 +486,19 @@
 	return sum;
 }
 
+unsigned int nr_used_zone_pages(void)
+{
+	pg_data_t *pgdat;
+	unsigned int pages = 0;
+
+	for_each_pgdat(pgdat) {
+		pages += pgdat->node_zones[ZONE_DMA].nr_active;
+		pages += pgdat->node_zones[ZONE_NORMAL].nr_inactive;
+	}
+
+	return pages;
+}
+
 static unsigned int nr_free_zone_pages(int offset)
 {
 	pg_data_t *pgdat;
diff -Nru a/mm/slab.c b/mm/slab.c
--- a/mm/slab.c	Sat Sep  7 09:30:46 2002
+++ b/mm/slab.c	Sat Sep  7 09:30:46 2002
@@ -1500,7 +1500,11 @@
 		if (unlikely(!--slabp->inuse)) {
 			/* Was partial or full, now empty. */
 			list_del(&slabp->list);
-			list_add(&slabp->list, &cachep->slabs_free);
+/*			list_add(&slabp->list, &cachep->slabs_free); 		*/
+			if (unlikely(list_empty(&cachep->slabs_partial)))
+				list_add(&slabp->list, &cachep->slabs_partial);
+			else
+				kmem_slab_destroy(cachep, slabp);
 		} else if (unlikely(inuse == cachep->num)) {
 			/* Was full. */
 			list_del(&slabp->list);
@@ -1969,7 +1973,7 @@
 	}
 	list_for_each(q,&cachep->slabs_partial) {
 		slabp = list_entry(q, slab_t, list);
-		if (slabp->inuse == cachep->num || !slabp->inuse)
+		if (slabp->inuse == cachep->num)
 			BUG();
 		active_objs += slabp->inuse;
 		active_slabs++;
diff -Nru a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c	Sat Sep  7 09:30:46 2002
+++ b/mm/vmscan.c	Sat Sep  7 09:30:46 2002
@@ -464,11 +464,13 @@
 	unsigned int gfp_mask, int nr_pages)
 {
 	unsigned long ratio;
-	int max_scan;
+	int max_scan, nr_pages_in, pages, a, b;
 
-	/* This is bogus for ZONE_HIGHMEM? */
-	if (kmem_cache_reap(gfp_mask) >= nr_pages)
-  		return 0;
+	if (nr_pages <= 0)
+		return 0;
+
+	pages = nr_used_zone_pages();
+	nr_pages_in = nr_pages;
 
 	/*
 	 * Try to keep the active list 2/3 of the size of the cache.  And
@@ -483,7 +485,7 @@
 	ratio = (unsigned long)nr_pages * zone->nr_active /
 				((zone->nr_inactive | 1) * 2);
 	atomic_add(ratio+1, &zone->refill_counter);
-	if (atomic_read(&zone->refill_counter) > SWAP_CLUSTER_MAX) {
+	while (atomic_read(&zone->refill_counter) > SWAP_CLUSTER_MAX) {
 		atomic_sub(SWAP_CLUSTER_MAX, &zone->refill_counter);
 		refill_inactive_zone(zone, SWAP_CLUSTER_MAX);
 	}
@@ -492,18 +494,27 @@
 	nr_pages = shrink_cache(nr_pages, zone,
 				gfp_mask, priority, max_scan);
 
+	/*
+	 * Here we assume it costs one seek to replace a lru page and that
+	 * it also takes a seek to recreate a cache object.  With this in
+	 * mind we age equal percentages of the lru and ageable caches.
+	 * This should balance the seeks generated by these structures.
+	 */
+	if (likely(nr_pages_in > nr_pages)) {
+		ratio = pages / (nr_pages_in-nr_pages);
+		shrink_dcache_memory(ratio, gfp_mask);
+
+		/* After aging the dcache, age inodes too .. */
+		shrink_icache_memory(ratio, gfp_mask);
+#ifdef CONFIG_QUOTA
+		shrink_dqcache_memory(ratio, gfp_mask);
+#endif
+	}
+
 	if (nr_pages <= 0)
 		return 0;
 
 	wakeup_bdflush();
-
-	shrink_dcache_memory(priority, gfp_mask);
-
-	/* After shrinking the dcache, get rid of unused inodes too .. */
-	shrink_icache_memory(1, gfp_mask);
-#ifdef CONFIG_QUOTA
-	shrink_dqcache_memory(DEF_PRIORITY, gfp_mask);
-#endif
 
 	return nr_pages;
 }

---------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
