Message-ID: <396D1817.108394F5@norran.net>
Date: Thu, 13 Jul 2000 03:15:03 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [PATCH] page ageing with lists
Content-Type: multipart/mixed;
 boundary="------------319943ED734170757B27737D"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------319943ED734170757B27737D
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

This is a patch with page ageing for 2.4.0-test4-pre1.

Performance, unoptimized filesystem:
* streamed write is as good as 2.2.14
* streamed copy is 3/4 of 2.2.14
* streamed read is close to 2.2.14

Potential problems:
* Got a BUG mm.h:321 while running this patch,
  unrelated? (more about this in another email)
  

Features:
* does NOT add any field in page structure.
* round robin lists is used to simulate ageing.
* referenced pages are moved 2 steps forward.
* multi used paged are moved 4 steps forward.
* non free able, tryagain, are moved 1 steps forward.
* new pages are inserted 3 steps forward.
* no pages are moved backward or to currently scanned.
and new in this release:
* pages failing zone test are moved to a list per zone.
  This lists are searched first!
* removed one unnecessary cause for SetPageReferenced


Future work:
* trim offsets / size / priority
* remove code that unnecessary sets page as referenced (Riel?)
* split pagemap_lru_lock (if wanted on SMP)
* move pages of zones with pressure less forward...
* ...
additional idea:
* periodically check pages for referenced - move forward.

/RogerL


--
Home page:
  http://www.norran.net/nra02596/
--------------319943ED734170757B27737D
Content-Type: text/plain; charset=us-ascii;
 name="patch-2.4.0-test4-pre1-filemap.age+zone.3"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-2.4.0-test4-pre1-filemap.age+zone.3"

--- linux/mm/page_alloc.c.orig	Tue Jul 11 23:50:58 2000
+++ linux/mm/page_alloc.c	Wed Jul 12 17:37:06 2000
@@ -516,7 +516,7 @@ void __init free_area_init_core(int nid,
 	freepages.min += i;
 	freepages.low += i * 2;
 	freepages.high += i * 3;
-	memlist_init(&lru_cache);
+	init_lru_cache();
 
 	/*
 	 * Some architectures (with lots of mem and discontinous memory
@@ -562,6 +562,11 @@ void __init free_area_init_core(int nid,
 		zone->lock = SPIN_LOCK_UNLOCKED;
 		zone->zone_pgdat = pgdat;
 		zone->free_pages = 0;
+
+		memlist_init(&zone->lru_cache[0]);
+		memlist_init(&zone->lru_cache[1]);
+		zone->lru_insert = 0;
+
 		if (!size)
 			continue;
 
--- linux/mm/filemap.c.orig	Tue Jul 11 23:50:27 2000
+++ linux/mm/filemap.c	Thu Jul 13 02:12:08 2000
@@ -44,7 +44,26 @@
 atomic_t page_cache_size = ATOMIC_INIT(0);
 unsigned int page_hash_bits;
 struct page **page_hash_table;
-struct list_head lru_cache;
+
+/* Note: optimization possibility - spit pagemap_lru_lock!
+ * iff LRU_INSERT_OFFSET != 0 and != all other offsets */
+#define NO_LRU_CACHES 8 /* power of two, greater than biggest offset */
+#define LRU_SCAN_INIT 0
+#define LRU_ZONE_OFFSET 0
+#define LRU_INSERT_OFFSET 3
+#define LRU_LOCKED_OFFSET 1     /* shouldn't be locked a long time  */
+#define LRU_MULTIUSE_OFFSET 4   /* rare, what to do but wait. [shorter=1?] */
+#define LRU_BUFFER_OFFSET 1     /* freeing - will take some time */
+#define LRU_MAPPED_OFFSET 0     /* rare, only last test rejected freeing */
+#define LRU_REFERENCED_OFFSET 2
+#define MAX_LRU_OFFSET 4
+
+static struct list_head lru_caches[NO_LRU_CACHES];
+static unsigned lru_scan = LRU_SCAN_INIT;
+struct list_head *lru_cache_insert =
+        &lru_caches[(LRU_SCAN_INIT + LRU_INSERT_OFFSET) % NO_LRU_CACHES];
+static int lru_histogram[MAX_LRU_OFFSET + 1];
+static int lru_histogram_total;
 
 static spinlock_t pagecache_lock = SPIN_LOCK_UNLOCKED;
 /*
@@ -245,26 +264,54 @@ repeat:
 	spin_unlock(&pagecache_lock);
 }
 
+static void reset_lru_histogram(void)
+{
+  int ix;
+  for (ix = 0; ix <= MAX_LRU_OFFSET; ix++)
+    lru_histogram[ix] = 0;
+  lru_histogram_total = 0;
+}
+
+static void print_lru_histogram(void)
+{
+  int ix;
+  printk(  "lru_histogram_total =     %5d\n", lru_histogram_total);
+  for (ix = 0; ix <= MAX_LRU_OFFSET; ix++)
+    printk("lru_histogram[%2d] = %5d\n", ix, lru_histogram[ix]);
+} 
+
+void init_lru_cache(void)
+{
+  int ix;
+
+  for (ix = 0; ix < NO_LRU_CACHES; ix++)
+      INIT_LIST_HEAD(&lru_caches[ix]);
+}
+
 /*
- * nr_dirty represents the number of dirty pages that we will write async
- * before doing sync writes.  We can only do sync writes if we can
- * wait for IO (__GFP_IO set).
+ * Return: true if successful
+ * Precond: lock held: pagemap_lru_lock
+ * Note: releases the lock regulary
+ * Note: *lru_cache_scan_ref may change when lock is released
  */
-int shrink_mmap(int priority, int gfp_mask)
+int shrink_mmap_specific(
+			 struct list_head **lru_cache_scan_ref,
+			 int gfp_mask,
+			 int *count_ref,
+			 int *nr_dirty)
 {
-	int ret = 0, count, nr_dirty;
 	struct list_head * page_lru;
 	struct page * page = NULL;
-	
-	count = nr_lru_pages / (priority + 1);
-	nr_dirty = priority;
+	int count = *count_ref;
 
-	/* we need pagemap_lru_lock for list_del() ... subtle code below */
-	spin_lock(&pagemap_lru_lock);
-	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
+	while (count > 0 &&
+	       (page_lru = (*lru_cache_scan_ref)->prev) != *lru_cache_scan_ref) {
+	        unsigned dispose_offset;
 		page = list_entry(page_lru, struct page, lru);
 		list_del(page_lru);
 
+		lru_histogram_total++;
+		dispose_offset = LRU_REFERENCED_OFFSET;
 		if (PageTestandClearReferenced(page))
 			goto dispose_continue;
 
@@ -273,9 +320,11 @@ int shrink_mmap(int priority, int gfp_ma
 		 * Avoid unscalable SMP locking for pages we can
 		 * immediate tell are untouchable..
 		 */
+		dispose_offset = LRU_MULTIUSE_OFFSET;
 		if (!page->buffers && page_count(page) > 1)
 			goto dispose_continue;
 
+		dispose_offset = LRU_LOCKED_OFFSET;
 		if (TryLockPage(page))
 			goto dispose_continue;
 
@@ -293,8 +342,10 @@ int shrink_mmap(int priority, int gfp_ma
 		 * Is it a buffer page? Try to clean it up regardless
 		 * of zone - it's old.
 		 */
+		dispose_offset = LRU_BUFFER_OFFSET;
 		if (page->buffers) {
-			int wait = ((gfp_mask & __GFP_IO) && (nr_dirty-- < 0));
+			int wait = ((gfp_mask & __GFP_IO) &&
+				    (*nr_dirty-- < 0));
 			if (!try_to_free_buffers(page, wait))
 				goto unlock_continue;
 			/* page was locked, inode can't go away under us */
@@ -314,6 +365,7 @@ int shrink_mmap(int priority, int gfp_ma
 		 * We can't free pages unless there's just one user
 		 * (count == 2 because we added one ourselves above).
 		 */
+		dispose_offset = LRU_MULTIUSE_OFFSET;
 		if (page_count(page) != 2)
 			goto cache_unlock_continue;
 
@@ -332,9 +384,11 @@ int shrink_mmap(int priority, int gfp_ma
 		 * Page is from a zone we don't care about.
 		 * Don't drop page cache entries in vain.
 		 */
+		dispose_offset = LRU_ZONE_OFFSET;
 		if (page->zone->free_pages > page->zone->pages_high)
 			goto cache_unlock_continue;
 
+		dispose_offset = LRU_MAPPED_OFFSET;
 		/* is it a page-cache page? */
 		if (page->mapping) {
 			if (!PageDirty(page) && !pgcache_under_min()) {
@@ -354,21 +408,164 @@ unlock_continue:
 		UnlockPage(page);
 		page_cache_release(page);
 dispose_continue:
-		list_add(page_lru, &lru_cache);
+		lru_histogram[dispose_offset]++;
+
+		if (dispose_offset > 0)
+		{
+		  /* TODO CHECK OPTIMIZATION
+		   * should become
+		   *   (lru_scan + dispose_offset) & (NO_LRU_CACHES - 1)
+		   * since both lru_scan and dispose_offset are unsigned
+		   * and NO_LRU_CACHES is a power of two.
+		   */
+		  unsigned dispose;
+		  dispose = (lru_scan + dispose_offset) % NO_LRU_CACHES;
+
+		  list_add(page_lru, 
+			   &lru_caches[dispose]);
+		}
+		else {
+		  /* dispose to zone lru */
+		  list_add(page_lru, 
+			   &page->zone->lru_cache[page->zone->lru_insert]);
+		}
 	}
-	goto out;
+	*count_ref = count;
+	return 0;
+
 
+	/*
+	 * Successful returns follows
+	 */
 made_inode_progress:
 	page_cache_release(page);
 made_buffer_progress:
 	UnlockPage(page);
 	page_cache_release(page);
-	ret = 1;
 	spin_lock(&pagemap_lru_lock);
 	/* nr_lru_pages needs the spinlock */
 	nr_lru_pages--;
 
-out:
+	*count_ref = count;
+	return 1;
+}
+
+
+
+static inline int shrink_mmap_zone(
+		     int gfp_mask,
+		     int *count_ref,
+		     int *nr_dirty_ref)
+{
+  int ret = 1;
+
+  /*
+   * alternative... from page_alloc.c
+   *
+   * for (i = 0; i < NUMNODES; i++)
+   *   for (zone = NODE_DATA(i)->node_zones;
+   *	 zone < NODE_DATA(i)->node_zones + MAX_NR_ZONES;
+   *     zone++)
+   */
+
+  pg_data_t *pgdat = pgdat_list;
+
+  do {
+    int i;
+    for(i = 0; i < MAX_NR_ZONES; i++) {
+      zone_t *zone = pgdat->node_zones + i;
+      
+      /*
+       * do stuff, if from a zone we care about
+       */
+      if (zone->zone_wake_kswapd) {
+	  struct list_head *lru_zone_cache_scan;
+	  int retries = 2;
+
+	  while (--retries) {
+	    int success = 0;
+
+	    /* non insert zone lru empty? try the other one */ 
+	    int lru_scan = !zone->lru_insert;
+	    lru_zone_cache_scan = &zone->lru_cache[lru_scan];
+	    if (!success && list_empty(&zone->lru_cache[lru_scan])) {
+	      /* swap insert and scan */
+	      zone->lru_insert = lru_scan;
+	      lru_scan = !lru_scan;
+	    }
+
+	    success = shrink_mmap_specific(&lru_zone_cache_scan,
+					   gfp_mask,
+					   count_ref,
+					   nr_dirty_ref);
+
+	    if (success)
+	      return 1;
+	  }
+
+	  ret = 0;
+      }
+      else if (zone->free_pages < zone->pages_high &&
+	  list_empty(&zone->lru_cache[0]) &&
+	  list_empty(&zone->lru_cache[1])) {
+	/* Some preassure (same test as in shrink_mmap_specific)
+	 * and there are no pages one zone lru lists */
+	ret = 0;
+      }
+
+    }
+    pgdat = pgdat->node_next;
+  } while (pgdat);
+
+  return ret;
+}
+
+
+static inline int shrink_mmap_age(
+		    int gfp_mask,
+		    int *count_ref,
+		    int *nr_dirty_ref,
+		    int *success_ref)
+{
+	static struct list_head *lru_cache_scan = &lru_caches[LRU_SCAN_INIT];
+
+	if (list_empty(lru_cache_scan)) {
+	  print_lru_histogram();
+	  reset_lru_histogram();
+
+	  lru_scan = (lru_scan + 1) % NO_LRU_CACHES;
+	  
+	  lru_cache_scan = &lru_caches[lru_scan];
+	  lru_cache_insert =
+	    &lru_caches[(lru_scan + LRU_INSERT_OFFSET) % NO_LRU_CACHES];
+	}
+
+	return shrink_mmap_specific(&lru_cache_scan, gfp_mask,
+				    count_ref, nr_dirty_ref);
+}
+
+/*
+ * nr_dirty represents the number of dirty pages that we will write async
+ * before doing sync writes.  We can only do sync writes if we can
+ * wait for IO (__GFP_IO set).
+ */
+int shrink_mmap(int priority, int gfp_mask)
+{
+	int ret = 0, count, nr_dirty;
+
+	
+	count = nr_lru_pages / (priority + 1);
+	nr_dirty = priority;
+
+	/* we need pagemap_lru_lock for subroutines */
+	spin_lock(&pagemap_lru_lock);
+
+	ret = shrink_mmap_zone(gfp_mask, &count, &nr_dirty);
+
+	if (!ret) {
+	    ret = shrink_mmap_age(gfp_mask, &count, &nr_dirty, &ret);
+	};
+
 	spin_unlock(&pagemap_lru_lock);
 
 	return ret;
@@ -507,7 +704,6 @@ static inline void __add_to_page_cache(s
 	struct address_space *mapping, unsigned long offset,
 	struct page **hash)
 {
-	struct page *alias;
 	unsigned long flags;
 
 	if (PageLocked(page))
@@ -520,9 +716,6 @@ static inline void __add_to_page_cache(s
 	add_page_to_inode_queue(mapping, page);
 	__add_page_to_hash_queue(page, hash);
 	lru_cache_add(page);
-	alias = __find_page_nolock(mapping, offset, *hash);
-	if (alias != page)
-		BUG();
 }
 
 void add_to_page_cache(struct page * page, struct address_space * mapping, unsigned long offset)
--- linux/include/linux/mm.h.orig	Tue Jul 11 23:58:33 2000
+++ linux/include/linux/mm.h	Wed Jul 12 19:34:10 2000
@@ -15,7 +15,7 @@ extern unsigned long max_mapnr;
 extern unsigned long num_physpages;
 extern void * high_memory;
 extern int page_cluster;
-extern struct list_head lru_cache;
+extern struct list_head *lru_cache_insert;
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -456,6 +456,7 @@ struct zone_t;
 /* filemap.c */
 extern void remove_inode_page(struct page *);
 extern unsigned long page_unuse(struct page *);
+extern void init_lru_cache(void);
 extern int shrink_mmap(int, int);
 extern void truncate_inode_pages(struct address_space *, loff_t);
 
--- linux/include/linux/swap.h.orig	Tue Jul 11 23:58:51 2000
+++ linux/include/linux/swap.h	Wed Jul 12 10:08:03 2000
@@ -166,7 +166,7 @@ extern spinlock_t pagemap_lru_lock;
 #define	lru_cache_add(page)			\
 do {						\
 	spin_lock(&pagemap_lru_lock);		\
-	list_add(&(page)->lru, &lru_cache);	\
+	list_add(&(page)->lru, lru_cache_insert);	\
 	nr_lru_pages++;				\
 	spin_unlock(&pagemap_lru_lock);		\
 } while (0)
--- linux/include/linux/mmzone.h.orig	Wed Jul 12 16:24:59 2000
+++ linux/include/linux/mmzone.h	Wed Jul 12 17:39:12 2000
@@ -32,6 +32,12 @@ typedef struct zone_struct {
 	char			zone_wake_kswapd;
 	unsigned long		pages_min, pages_low, pages_high;
 
+        /*
+	 * zone lru - really old pages
+	 */
+        int                     lru_insert;
+        struct list_head        lru_cache[2];
+
 	/*
 	 * free areas of different sizes
 	 */

--------------319943ED734170757B27737D--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
