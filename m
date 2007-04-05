Message-Id: <20070405174320.373513202@programming.kicks-ass.net>
References: <20070405174209.498059336@programming.kicks-ass.net>
Date: Thu, 05 Apr 2007 19:42:20 +0200
From: root@programming.kicks-ass.net
Subject: [PATCH 11/12] mm: accurate pageout congestion wait
Content-Disposition: inline; filename=kswapd-writeout-wait.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com
List-ID: <linux-mm.kvack.org>

Only do the congestion wait when we actually encountered congestion.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---

 include/linux/swap.h |    1 +
 mm/page_io.c         |    9 +++++++++
 mm/vmscan.c          |   25 ++++++++++++++++++++-----
 3 files changed, 30 insertions(+), 5 deletions(-)

Index: linux-2.6-mm/mm/vmscan.c
===================================================================
--- linux-2.6-mm.orig/mm/vmscan.c	2007-04-05 16:29:49.000000000 +0200
+++ linux-2.6-mm/mm/vmscan.c	2007-04-05 16:35:36.000000000 +0200
@@ -70,6 +70,8 @@ struct scan_control {
 	int all_unreclaimable;
 
 	int order;
+
+	int encountered_congestion;
 };
 
 /*
@@ -315,7 +317,8 @@ typedef enum {
  * pageout is called by shrink_page_list() for each dirty page.
  * Calls ->writepage().
  */
-static pageout_t pageout(struct page *page, struct address_space *mapping)
+static pageout_t pageout(struct page *page, struct address_space *mapping,
+		struct scan_control *sc)
 {
 	/*
 	 * If the page is dirty, only perform writeback if that write
@@ -357,6 +360,7 @@ static pageout_t pageout(struct page *pa
 
 	if (clear_page_dirty_for_io(page)) {
 		int res;
+		struct backing_dev_info *bdi;
 		struct writeback_control wbc = {
 			.sync_mode = WB_SYNC_NONE,
 			.nr_to_write = SWAP_CLUSTER_MAX,
@@ -366,6 +370,14 @@ static pageout_t pageout(struct page *pa
 			.for_reclaim = 1,
 		};
 
+		if (mapping == &swapper_space)
+			bdi = swap_bdi(page);
+		else
+			bdi = mapping->backing_dev_info;
+
+		if (bdi_congested(bdi, WRITE))
+			sc->encountered_congestion = 1;
+
 		SetPageReclaim(page);
 		res = mapping->a_ops->writepage(page, &wbc);
 		if (res < 0)
@@ -533,7 +545,7 @@ static unsigned long shrink_page_list(st
 				goto keep_locked;
 
 			/* Page is dirty, try to write it out here */
-			switch(pageout(page, mapping)) {
+			switch(pageout(page, mapping, sc)) {
 			case PAGE_KEEP:
 				goto keep_locked;
 			case PAGE_ACTIVATE:
@@ -1141,6 +1153,7 @@ unsigned long try_to_free_pages(struct z
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		sc.nr_scanned = 0;
+		sc.encountered_congestion = 0;
 		if (!priority)
 			disable_swap_token();
 		nr_reclaimed += shrink_zones(priority, zones, &sc);
@@ -1169,7 +1182,7 @@ unsigned long try_to_free_pages(struct z
 		}
 
 		/* Take a nap, wait for some writeback to complete */
-		if (sc.nr_scanned && priority < DEF_PRIORITY - 2)
+		if (sc.encountered_congestion)
 			congestion_wait(WRITE, HZ/10);
 	}
 	/* top priority shrink_caches still had more to do? don't OOM, then */
@@ -1250,6 +1263,7 @@ loop_again:
 		int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 		unsigned long lru_pages = 0;
 
+		sc.encountered_congestion = 0;
 		/* The swap token gets in the way of swapout... */
 		if (!priority)
 			disable_swap_token();
@@ -1337,7 +1351,7 @@ loop_again:
 		 * OK, kswapd is getting into trouble.  Take a nap, then take
 		 * another pass across the zones.
 		 */
-		if (total_scanned && priority < DEF_PRIORITY - 2)
+		if (sc.encountered_congestion)
 			congestion_wait(WRITE, HZ/10);
 
 		/*
@@ -1580,6 +1594,7 @@ unsigned long shrink_all_memory(unsigned
 			unsigned long nr_to_scan = nr_pages - ret;
 
 			sc.nr_scanned = 0;
+			sc.encountered_congestion = 0;
 			ret += shrink_all_zones(nr_to_scan, prio, pass, &sc);
 			if (ret >= nr_pages)
 				goto out;
@@ -1591,7 +1606,7 @@ unsigned long shrink_all_memory(unsigned
 			if (ret >= nr_pages)
 				goto out;
 
-			if (sc.nr_scanned && prio < DEF_PRIORITY - 2)
+			if (sc.encountered_congestion)
 				congestion_wait(WRITE, HZ / 10);
 		}
 	}
Index: linux-2.6-mm/include/linux/swap.h
===================================================================
--- linux-2.6-mm.orig/include/linux/swap.h	2007-04-05 16:24:02.000000000 +0200
+++ linux-2.6-mm/include/linux/swap.h	2007-04-05 16:35:36.000000000 +0200
@@ -220,6 +220,7 @@ extern void swap_unplug_io_fn(struct bac
 
 #ifdef CONFIG_SWAP
 /* linux/mm/page_io.c */
+extern struct backing_dev_info *swap_bdi(struct page *);
 extern int swap_readpage(struct file *, struct page *);
 extern int swap_writepage(struct page *page, struct writeback_control *wbc);
 extern int end_swap_bio_read(struct bio *bio, unsigned int bytes_done, int err);
Index: linux-2.6-mm/mm/page_io.c
===================================================================
--- linux-2.6-mm.orig/mm/page_io.c	2007-04-05 16:24:02.000000000 +0200
+++ linux-2.6-mm/mm/page_io.c	2007-04-05 16:36:26.000000000 +0200
@@ -19,6 +19,15 @@
 #include <linux/writeback.h>
 #include <asm/pgtable.h>
 
+struct backing_dev_info *swap_bdi(struct page *page)
+{
+	struct swap_info_struct *sis;
+	swp_entry_t entry = { .val = page_private(page), };
+
+	sis = get_swap_info_struct(swp_type(entry));
+	return blk_get_backing_dev_info(sis->bdev);
+}
+
 static struct bio *get_swap_bio(gfp_t gfp_flags, pgoff_t index,
 				struct page *page, bio_end_io_t end_io)
 {

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
