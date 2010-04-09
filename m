Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 481CA6B0203
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 02:51:10 -0400 (EDT)
Date: Fri, 9 Apr 2010 14:51:04 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
Message-ID: <20100409065104.GA21480@sli10-desk.sh.intel.com>
References: <20100331045348.GA3396@sli10-desk.sh.intel.com>
 <20100331142708.039E.A69D9226@jp.fujitsu.com>
 <20100331145030.03A1.A69D9226@jp.fujitsu.com>
 <20100402065052.GA28027@sli10-desk.sh.intel.com>
 <20100406050325.GA17797@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100406050325.GA17797@localhost>
Sender: owner-linux-mm@kvack.org
To: "Wu, Fengguang" <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 01:03:25PM +0800, Wu, Fengguang wrote:
> Shaohua,
> 
> > +		scan = zone_nr_lru_pages(zone, sc, l);
> > +		if (priority) {
> > +			scan >>= priority;
> > +			scan = (scan * fraction[file] / denominator[file]);
> 
> Ah, the (scan * fraction[file]) may overflow in 32bit kernel!
I updated the patch to address previous issues.
is it possible to put this to -mm tree to see if there is anything wield happen?



get_scan_ratio() calculates percentage and if the percentage is < 1%, it will
round percentage down to 0% and cause we completely ignore scanning anon/file
pages to reclaim memory even the total anon/file pages are very big.

To avoid underflow, we don't use percentage, instead we directly calculate
how many pages should be scaned. In this way, we should get several scanned pages
for < 1% percent.

This has some benefits:
1. increase our calculation precision
2. making our scan more smoothly. Without this, if percent[x] is underflow,
shrink_zone() doesn't scan any pages and suddenly it scans all pages when priority
is zero. With this, even priority isn't zero, shrink_zone() gets chance to scan
some pages.

Note, this patch doesn't really change logics, but just increase precision. For
system with a lot of memory, this might slightly changes behavior. For example,
in a sequential file read workload, without the patch, we don't swap any anon
pages. With it, if anon memory size is bigger than 16G, we will see one anon page
swapped. The 16G is calculated as PAGE_SIZE * priority(4096) * (fp/ap). fp/ap
is assumed to be 1024 which is common in this workload. So the impact sounds not
a big deal.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3ff3311..1070f83 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1519,21 +1519,52 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 }
 
 /*
+ * Smallish @nr_to_scan's are deposited in @nr_saved_scan,
+ * until we collected @swap_cluster_max pages to scan.
+ */
+static unsigned long nr_scan_try_batch(unsigned long nr_to_scan,
+				       unsigned long *nr_saved_scan)
+{
+	unsigned long nr;
+
+	*nr_saved_scan += nr_to_scan;
+	nr = *nr_saved_scan;
+
+	if (nr >= SWAP_CLUSTER_MAX)
+		*nr_saved_scan = 0;
+	else
+		nr = 0;
+
+	return nr;
+}
+
+/*
  * Determine how aggressively the anon and file LRU lists should be
  * scanned.  The relative value of each set of LRU lists is determined
  * by looking at the fraction of the pages scanned we did rotate back
  * onto the active list instead of evict.
  *
- * percent[0] specifies how much pressure to put on ram/swap backed
- * memory, while percent[1] determines pressure on the file LRUs.
+ * nr[0] = anon pages to scan; nr[1] = file pages to scan
  */
-static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
-					unsigned long *percent)
+static void get_scan_count(struct zone *zone, struct scan_control *sc,
+					unsigned long *nr, int priority)
 {
 	unsigned long anon, file, free;
 	unsigned long anon_prio, file_prio;
 	unsigned long ap, fp;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
+	u64 fraction[2], denominator;
+	enum lru_list l;
+	int noswap = 0;
+
+	/* If we have no swap space, do not bother scanning anon pages. */
+	if (!sc->may_swap || (nr_swap_pages <= 0)) {
+		noswap = 1;
+		fraction[0] = 0;
+		fraction[1] = 1;
+		denominator = 1;
+		goto out;
+	}
 
 	anon  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_ANON) +
 		zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON);
@@ -1545,9 +1576,10 @@ static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
 		/* If we have very few page cache pages,
 		   force-scan anon pages. */
 		if (unlikely(file + free <= high_wmark_pages(zone))) {
-			percent[0] = 100;
-			percent[1] = 0;
-			return;
+			fraction[0] = 1;
+			fraction[1] = 0;
+			denominator = 1;
+			goto out;
 		}
 	}
 
@@ -1594,29 +1626,22 @@ static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
 	fp = (file_prio + 1) * (reclaim_stat->recent_scanned[1] + 1);
 	fp /= reclaim_stat->recent_rotated[1] + 1;
 
-	/* Normalize to percentages */
-	percent[0] = 100 * ap / (ap + fp + 1);
-	percent[1] = 100 - percent[0];
-}
-
-/*
- * Smallish @nr_to_scan's are deposited in @nr_saved_scan,
- * until we collected @swap_cluster_max pages to scan.
- */
-static unsigned long nr_scan_try_batch(unsigned long nr_to_scan,
-				       unsigned long *nr_saved_scan)
-{
-	unsigned long nr;
-
-	*nr_saved_scan += nr_to_scan;
-	nr = *nr_saved_scan;
-
-	if (nr >= SWAP_CLUSTER_MAX)
-		*nr_saved_scan = 0;
-	else
-		nr = 0;
+	fraction[0] = ap;
+	fraction[1] = fp;
+	denominator = ap + fp + 1;
+out:
+	for_each_evictable_lru(l) {
+		int file = is_file_lru(l);
+		unsigned long scan;
 
-	return nr;
+		scan = zone_nr_lru_pages(zone, sc, l);
+		if (priority || noswap) {
+			scan >>= priority;
+			scan = div64_u64(scan * fraction[file], denominator);
+		}
+		nr[l] = nr_scan_try_batch(scan,
+					  &reclaim_stat->nr_saved_scan[l]);
+	}
 }
 
 /*
@@ -1627,33 +1652,11 @@ static void shrink_zone(int priority, struct zone *zone,
 {
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
-	unsigned long percent[2];	/* anon @ 0; file @ 1 */
 	enum lru_list l;
 	unsigned long nr_reclaimed = sc->nr_reclaimed;
 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
-	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
-	int noswap = 0;
-
-	/* If we have no swap space, do not bother scanning anon pages. */
-	if (!sc->may_swap || (nr_swap_pages <= 0)) {
-		noswap = 1;
-		percent[0] = 0;
-		percent[1] = 100;
-	} else
-		get_scan_ratio(zone, sc, percent);
 
-	for_each_evictable_lru(l) {
-		int file = is_file_lru(l);
-		unsigned long scan;
-
-		scan = zone_nr_lru_pages(zone, sc, l);
-		if (priority || noswap) {
-			scan >>= priority;
-			scan = (scan * percent[file]) / 100;
-		}
-		nr[l] = nr_scan_try_batch(scan,
-					  &reclaim_stat->nr_saved_scan[l]);
-	}
+	get_scan_count(zone, sc, nr, priority);
 
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
