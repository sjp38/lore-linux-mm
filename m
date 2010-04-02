Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2C3F76B0207
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 02:50:55 -0400 (EDT)
Date: Fri, 2 Apr 2010 14:50:52 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
Message-ID: <20100402065052.GA28027@sli10-desk.sh.intel.com>
References: <20100331045348.GA3396@sli10-desk.sh.intel.com>
 <20100331142708.039E.A69D9226@jp.fujitsu.com>
 <20100331145030.03A1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100331145030.03A1.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 31, 2010 at 01:53:27PM +0800, KOSAKI Motohiro wrote:
> > > On Tue, Mar 30, 2010 at 02:08:53PM +0800, KOSAKI Motohiro wrote:
> > > > Hi
> > > > 
> > > > > Commit 84b18490d1f1bc7ed5095c929f78bc002eb70f26 introduces a regression.
> > > > > With it, our tmpfs test always oom. The test has a lot of rotated anon
> > > > > pages and cause percent[0] zero. Actually the percent[0] is a very small
> > > > > value, but our calculation round it to zero. The commit makes vmscan
> > > > > completely skip anon pages and cause oops.
> > > > > An option is if percent[x] is zero in get_scan_ratio(), forces it
> > > > > to 1. See below patch.
> > > > > But the offending commit still changes behavior. Without the commit, we scan
> > > > > all pages if priority is zero, below patch doesn't fix this. Don't know if
> > > > > It's required to fix this too.
> > > > 
> > > > Can you please post your /proc/meminfo and reproduce program? I'll digg it.
> > > > 
> > > > Very unfortunately, this patch isn't acceptable. In past time, vmscan 
> > > > had similar logic, but 1% swap-out made lots bug reports. 
> > > if 1% is still big, how about below patch?
> > 
> > This patch makes a lot of sense than previous. however I think <1% anon ratio
> > shouldn't happen anyway because file lru doesn't have reclaimable pages.
> > <1% seems no good reclaim rate.
> 
> Oops, the above mention is wrong. sorry. only 1 page is still too big.
> because under streaming io workload, the number of scanning anon pages should
> be zero. this is very strong requirement. if not, backup operation will makes
> a lot of swapping out.
Sounds there is no big impact for the workload which you mentioned with the patch.
please see below descriptions.
I updated the description of the patch as fengguang suggested.



Commit 84b18490d introduces a regression. With it, our tmpfs test always oom.
The test uses a 6G tmpfs in a system with 3G memory. In the tmpfs, there are
6 copies of kernel source and the test does kbuild for each copy. My
investigation shows the test has a lot of rotated anon pages and quite few
file pages, so get_scan_ratio calculates percent[0] to be zero. Actually
the percent[0] shoule be a very small value, but our calculation round it
to zero. The commit makes vmscan completely skip anon pages and cause oops.

To avoid underflow, we don't use percentage, instead we directly calculate
how many pages should be scaned. In this way, we should get several scan pages
for < 1% percent. With this fix, my test doesn't oom any more.

Note, this patch doesn't really change logics, but just increase precise. For
system with a lot of memory, this might slightly changes behavior. For example,
in a sequential file read workload, without the patch, we don't swap any anon
pages. With it, if anon memory size is bigger than 16G, we will say one anon page
swapped. The 16G is calculated as PAGE_SIZE * priority(4096) * (fp/ap). fp/ap
is assumed to be 1024 which is common in this workload. So the impact sounds not
a big deal.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 79c8098..80a7ed5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1519,27 +1519,50 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
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
+ * nr[x] specifies how many pages should be scaned
  */
-static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
-					unsigned long *percent)
+static void get_scan_count(struct zone *zone, struct scan_control *sc,
+				unsigned long *nr, int priority)
 {
 	unsigned long anon, file, free;
 	unsigned long anon_prio, file_prio;
 	unsigned long ap, fp;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
+	unsigned long fraction[2], denominator[2];
+	enum lru_list l;
 
 	/* If we have no swap space, do not bother scanning anon pages. */
 	if (!sc->may_swap || (nr_swap_pages <= 0)) {
-		percent[0] = 0;
-		percent[1] = 100;
-		return;
+		fraction[0] = 0;
+		denominator[0] = 1;
+		fraction[1] = 1;
+		denominator[1] = 1;
+		goto out;
 	}
 
 	anon  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_ANON) +
@@ -1552,9 +1575,11 @@ static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
 		/* If we have very few page cache pages,
 		   force-scan anon pages. */
 		if (unlikely(file + free <= high_wmark_pages(zone))) {
-			percent[0] = 100;
-			percent[1] = 0;
-			return;
+			fraction[0] = 1;
+			denominator[0] = 1;
+			fraction[1] = 0;
+			denominator[1] = 1;
+			goto out;
 		}
 	}
 
@@ -1601,29 +1626,29 @@ static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
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
+	fraction[0] = ap;
+	denominator[0] = ap + fp + 1;
+	fraction[1] = fp;
+	denominator[1] = ap + fp + 1;
 
-	*nr_saved_scan += nr_to_scan;
-	nr = *nr_saved_scan;
+out:
+	for_each_evictable_lru(l) {
+		int file = is_file_lru(l);
+		unsigned long scan;
 
-	if (nr >= SWAP_CLUSTER_MAX)
-		*nr_saved_scan = 0;
-	else
-		nr = 0;
+		if (fraction[file] == 0) {
+			nr[l] = 0;
+			continue;
+		}
 
-	return nr;
+		scan = zone_nr_lru_pages(zone, sc, l);
+		if (priority) {
+			scan >>= priority;
+			scan = (scan * fraction[file] / denominator[file]);
+		}
+		nr[l] = nr_scan_try_batch(scan,
+					  &reclaim_stat->nr_saved_scan[l]);
+	}
 }
 
 /*
@@ -1634,31 +1659,11 @@ static void shrink_zone(int priority, struct zone *zone,
 {
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
-	unsigned long percent[2];	/* anon @ 0; file @ 1 */
 	enum lru_list l;
 	unsigned long nr_reclaimed = sc->nr_reclaimed;
 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
-	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
-
-	get_scan_ratio(zone, sc, percent);
 
-	for_each_evictable_lru(l) {
-		int file = is_file_lru(l);
-		unsigned long scan;
-
-		if (percent[file] == 0) {
-			nr[l] = 0;
-			continue;
-		}
-
-		scan = zone_nr_lru_pages(zone, sc, l);
-		if (priority) {
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
