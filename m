Received: from norran.net (roger@t8o43p42.telia.com [194.237.168.222])
	by d1o43.telia.com (8.8.8/8.8.8) with ESMTP id AAA14975
	for <linux-mm@kvack.org>; Tue, 11 Jul 2000 00:22:06 +0200 (CEST)
Message-ID: <396A4BA1.F738D3B6@norran.net>
Date: Tue, 11 Jul 2000 00:18:09 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [PATCH] embryotic page ageing with lists
Content-Type: multipart/mixed;
 boundary="------------5C884B0A7F38D2A3C4AA5298"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------5C884B0A7F38D2A3C4AA5298
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

This is a embryotic, but with heart beats, patch of page ageing
for test3-pre6.

Features:
* does NOT add any field in page structure.
* round robin lists is used to simulate ageing.
* referenced pages are moved 5 steps forward.
* non freeable, tryagain, are moved 3 steps forward.
* new pages are inserted 2 steps forward.
* no pages are moved backward or to currently scanned.

Future work:
* trim offsets / size / priority
* remove code that unnecessary sets page as referenced (riel?)
* add more offsets depending on why the page could not
  be freed.
* split pagemap_lru_lock (if wanted on SMP)
* move pages of zones with pressure less forward...
* ...

/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--------------5C884B0A7F38D2A3C4AA5298
Content-Type: text/plain; charset=us-ascii;
 name="patch-2.4.0-test3-pre6-filemap.1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-2.4.0-test3-pre6-filemap.1"

--- linux/mm/page_alloc.c.orig	Mon Jul 10 11:46:29 2000
+++ linux/mm/page_alloc.c	Mon Jul 10 11:46:44 2000
@@ -499,7 +499,7 @@ void __init free_area_init_core(int nid,
 	freepages.min += i;
 	freepages.low += i * 2;
 	freepages.high += i * 3;
-	memlist_init(&lru_cache);
+	init_lru_cache();
 
 	/*
 	 * Some architectures (with lots of mem and discontinous memory
--- linux/include/linux/mm.h.orig	Mon Jul 10 11:38:52 2000
+++ linux/include/linux/mm.h	Mon Jul 10 11:49:07 2000
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
 
--- linux/include/linux/swap.h.orig	Mon Jul 10 11:43:03 2000
+++ linux/include/linux/swap.h	Mon Jul 10 11:44:45 2000
@@ -166,7 +166,7 @@ extern spinlock_t pagemap_lru_lock;
 #define	lru_cache_add(page)			\
 do {						\
 	spin_lock(&pagemap_lru_lock);		\
-	list_add(&(page)->lru, &lru_cache);	\
+	list_add(&(page)->lru, lru_cache_insert);	\
 	nr_lru_pages++;				\
 	spin_unlock(&pagemap_lru_lock);		\
 } while (0)
--- linux/mm/filemap.c.orig	Mon Jul 10 11:02:59 2000
+++ linux/mm/filemap.c	Mon Jul 10 23:10:08 2000
@@ -44,7 +44,17 @@
 atomic_t page_cache_size = ATOMIC_INIT(0);
 unsigned int page_hash_bits;
 struct page **page_hash_table;
-struct list_head lru_cache;
+/* Note: optimization possibility - spit pagemap_lru_lock!
+ * iff LRU_INSERT_OFFSET != 0 and != all other offsets */
+#define NO_LRU_CACHES 8 /* power of two, greater than biggest offset */
+#define LRU_SCAN_INIT 0
+#define LRU_INSERT_OFFSET 2
+#define LRU_REFERENCED_OFFSET 5
+#define LRU_TRYAGAIN_OFFSET 3
+static struct list_head lru_caches[NO_LRU_CACHES];
+static unsigned lru_scan = LRU_SCAN_INIT;
+struct list_head *lru_cache_insert =
+        &lru_caches[(LRU_SCAN_INIT + LRU_INSERT_OFFSET) % NO_LRU_CACHES];
 
 static spinlock_t pagecache_lock = SPIN_LOCK_UNLOCKED;
 /*
@@ -245,6 +255,15 @@ repeat:
 	spin_unlock(&pagecache_lock);
 }
 
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
  * nr_dirty represents the number of dirty pages that we will write async
  * before doing sync writes.  We can only do sync writes if we can
@@ -253,6 +272,7 @@ repeat:
 int shrink_mmap(int priority, int gfp_mask)
 {
 	int ret = 0, count, nr_dirty;
+	static struct list_head *lru_cache_scan = &lru_caches[LRU_SCAN_INIT];
 	struct list_head * page_lru;
 	struct page * page = NULL;
 	
@@ -261,12 +281,17 @@ int shrink_mmap(int priority, int gfp_ma
 
 	/* we need pagemap_lru_lock for list_del() ... subtle code below */
 	spin_lock(&pagemap_lru_lock);
-	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
+ again:
+	while (count > 0 &&
+	       (page_lru = lru_cache_scan->prev) != lru_cache_scan) {
+	        unsigned dispose_offset;
 		page = list_entry(page_lru, struct page, lru);
 		list_del(page_lru);
 
+		dispose_offset = LRU_REFERENCED_OFFSET;
 		if (PageTestandClearReferenced(page))
 			goto dispose_continue;
+		dispose_offset = LRU_TRYAGAIN_OFFSET;
 
 		count--;
 		/*
@@ -354,9 +379,31 @@ unlock_continue:
 		UnlockPage(page);
 		page_cache_release(page);
 dispose_continue:
-		list_add(page_lru, &lru_cache);
+		{
+		  /* TODO CHECK OPTIMIZATION
+		   * should become
+		   *   (lru_scan + dispose_offset) & (NO_LRU_CACHES - 1)
+		   * since both lru_scan and dispose_offset are unsigned
+		   * and NO_LRU_CACHES is a power of two.
+		   */
+		  unsigned dispose =
+		    (lru_scan + dispose_offset) % NO_LRU_CACHES;
+		
+		  list_add(page_lru, 
+			   &lru_caches[dispose]);
+		}
 	}
-	goto out;
+	if (count == 0)
+	  goto out;
+
+	printk(KERN_DEBUG "scan wrap\n");
+	lru_scan = (lru_scan + 1) % NO_LRU_CACHES;
+
+	lru_cache_scan = &lru_caches[lru_scan];
+	lru_cache_insert =
+	  &lru_caches[(lru_scan + LRU_INSERT_OFFSET) % NO_LRU_CACHES];
+
+	goto again;
 
 made_inode_progress:
 	page_cache_release(page);

--------------5C884B0A7F38D2A3C4AA5298--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
