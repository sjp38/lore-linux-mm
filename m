Message-ID: <398B3946.93E167C9@norran.net>
Date: Fri, 04 Aug 2000 23:44:38 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: [PATCH] test5 vmfix attempt
Content-Type: multipart/mixed;
 boundary="------------6D78FBD61D5E97B05EC1B73A"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------6D78FBD61D5E97B05EC1B73A
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Hi,

This patch tries to improve/fix some problems with the current vm,
most notably out of memory problems.

* page_alloc.c, hunk 1
Since the balancing point is lower than on earlier kernels I think
there are reasons to keep more pages around on the special DMA zone...
(most computers has 16 MB DMA memory without this patch this gives an
 actual max of 32 pages, with this patch it gets 125 - probably more
 balanced against other zones)

* page_alloc.c, hunk 2
 More info in Sysreq-M (debug code)

* vmscan.c, hunk 1
The implemented balancing breaks stops when any zone gets out
of zone_wake_kswapd... but what about when only one zone is
really low on memory ( < pages_min ) - kswapd won't run.
This fixes that.
(I have tried to make the limit < pages_low but that disturbs
 the alternating balancing too much.)

* vmscan.c, hunk 2
After sleeping - pages might be gone, restart count.
(does not fix a resembling problem when waiting for a buffer in
shrink_mmap)

* vmscan.c, hunk 3
Actually it is not unlikely to have less than 'pages_low' free
due to the implemented balancing.


/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--------------6D78FBD61D5E97B05EC1B73A
Content-Type: text/plain; charset=us-ascii;
 name="patch-2.4.0-test5-vmfix"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-2.4.0-test5-vmfix"

--- linux-2.4/mm/page_alloc.c.orig	Wed Aug  2 17:55:53 2000
+++ linux-2.4/mm/page_alloc.c	Thu Aug  3 18:00:03 2000
@@ -29,7 +29,7 @@ int nr_lru_pages;
 pg_data_t *pgdat_list;
 
 static char *zone_names[MAX_NR_ZONES] = { "DMA", "Normal", "HighMem" };
-static int zone_balance_ratio[MAX_NR_ZONES] = { 128, 128, 128, };
+static int zone_balance_ratio[MAX_NR_ZONES] = { 32, 128, 128, };
 static int zone_balance_min[MAX_NR_ZONES] = { 10 , 10, 10, };
 static int zone_balance_max[MAX_NR_ZONES] = { 255 , 255, 255, };
 
@@ -430,7 +430,16 @@ void show_free_areas_core(int nid)
 		zone_t *zone = NODE_DATA(nid)->node_zones + type;
  		unsigned long nr, total, flags;
 
-		printk("  %s: ", zone->name);
+		printk("  %c%d%d %s: ",
+		       (zone->free_pages > zone->pages_low
+			? (zone->free_pages > zone->pages_high
+			   ? ' '
+			   : 'H')
+			: (zone->free_pages > zone->pages_min
+			   ? 'M'
+			   : 'L')),
+		       zone->zone_wake_kswapd, zone->low_on_memory,
+		       zone->name);
 
 		total = 0;
 		if (zone->size) {
--- linux-2.4/mm/vmscan.c.orig	Wed Aug  2 23:06:50 2000
+++ linux-2.4/mm/vmscan.c	Thu Aug  3 17:55:22 2000
@@ -444,20 +444,24 @@ static inline int memory_pressure(void)
  */
 static inline int keep_kswapd_awake(void)
 {
+	int all_recent = 1;
 	pg_data_t *pgdat = pgdat_list;
 
 	do {
 		int i;
 		for(i = 0; i < MAX_NR_ZONES; i++) {
 			zone_t *zone = pgdat->node_zones+ i;
-			if (zone->size &&
-			    !zone->zone_wake_kswapd)
-				return 0;
+			if (zone->size) {
+				if (zone->free_pages < zone->pages_min)
+					return 1;
+				if (!zone->zone_wake_kswapd)
+					all_recent = 0;
+			}
 		}
 		pgdat = pgdat->node_next;
 	} while (pgdat);
 
-	return 1;
+	return all_recent;
 }
 
 /*
@@ -470,6 +474,9 @@ static inline int keep_kswapd_awake(void
  *
  * Don't try _too_ hard, though. We don't want to have bad
  * latency.
+ *
+ * Note: only called by kswapd and try_to_free_pages
+ *       both can WAIT at top level.
  */
 #define FREE_COUNT	8
 #define SWAP_COUNT	16
@@ -487,8 +494,10 @@ static int do_try_to_free_pages(unsigned
 		if (current->need_resched) {
 			schedule();
 			/* time has passed - pressure too? */
			if (!memory_pressure())
 				goto done;
+			/* pages freed by me might be gone... */
+			count = FREE_COUNT;
 		}
 
 		while (shrink_mmap(priority, gfp_mask)) {
@@ -548,7 +557,7 @@ static int do_try_to_free_pages(unsigned
 	}
 	/* Return 1 if any page is freed, or
 	 * there are no more memory pressure   */
-	return (count < FREE_COUNT || !memory_pressure());
+	return (count < FREE_COUNT || !keep_kswapd_awake());
  
 done:
 	return 1;

--------------6D78FBD61D5E97B05EC1B73A--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
