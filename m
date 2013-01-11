Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 4E6A66B005D
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 23:43:29 -0500 (EST)
Date: Fri, 11 Jan 2013 13:43:27 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] mm: forcely swapout when we are out of page cache
Message-ID: <20130111044327.GB6183@blaptop>
References: <1357712474-27595-1-git-send-email-minchan@kernel.org>
 <1357712474-27595-3-git-send-email-minchan@kernel.org>
 <20130109162602.53a60e77.akpm@linux-foundation.org>
 <20130110022306.GB14685@blaptop>
 <20130110135828.c88bcaf1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130110135828.c88bcaf1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Sonny Rao <sonnyrao@google.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

Hi Andrew,

On Thu, Jan 10, 2013 at 01:58:28PM -0800, Andrew Morton wrote:
> On Thu, 10 Jan 2013 11:23:06 +0900
> Minchan Kim <minchan@kernel.org> wrote:
> 
> > > I have a feeling that laptop mode has bitrotted and these patches are
> > > kinda hacking around as-yet-not-understood failures...
> > 
> > Absolutely, this patch is last guard for unexpectable behavior.
> > As I mentioned in cover-letter, Luigi's problem could be solved either [1/2]
> > or [2/2] but I wanted to add this as last resort in case of unexpected
> > emergency. But you're right. It's not good to hide the problem like this path
> > so let's drop [2/2].
> > 
> > Also, I absolutely agree it has bitrotted so for correcting it, we need a
> > volunteer who have to inverstigate power saveing experiment with long time.
> > So [1/2] would be band-aid until that.
> 
> I'm inclined to hold off on 1/2 as well, really.

Then, what's your plan?

It's real bug since f80c067[mm: zone_reclaim: make isolate_lru_page() filter-aware]
was introduced. Some portable device could use laptop_mode to save batter power.
AFAIK, the usecase was trial of ChromeOS and Luigi reported this problem although
they decided to disable laptop_mode due to other reason which laptop_mode burns out
power for a very long time in their some workload.

Another problem of laptop_mode isn't aware of in-memory swap, like zram.
So unconditionally, prevent to swap out. :( Yeb. it's another story to be fixed.

If you hate this version, how about this?
This version does following as.

1. get_scan_count forces only file-backed pages reclaiming if may_writepage is false.
   It prevents unnecessary CPU consumption and LRU churing with anon pages.
2. If memory reclaim suffers(ie, below DEF_PRIORITY - 2), may_writepage would be true
   in only direct reclaim path.

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 73b64a3..695b907 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -550,6 +550,8 @@ static inline int zone_is_oom_locked(const struct zone *zone)
  */
 #define DEF_PRIORITY 12
 
+#define HARD_TO_RECLAIM_PRIO (DEF_PRIORITY - 2)
+
 /* Maximum number of zones on a zonelist */
 #define MAX_ZONES_PER_ZONELIST (MAX_NUMNODES * MAX_NR_ZONES)
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ff869d2..4c63bda 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -814,7 +814,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			 */
 			if (page_is_file_cache(page) &&
 					(!current_is_kswapd() ||
-					 sc->priority >= DEF_PRIORITY - 2)) {
+					 sc->priority >= HARD_TO_RECLAIM_PRIO)) {
 				/*
 				 * Immediately reclaim when written back.
 				 * Similar in principal to deactivate_page()
@@ -1683,8 +1683,11 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 	if (!global_reclaim(sc))
 		force_scan = true;
 
-	/* If we have no swap space, do not bother scanning anon pages. */
-	if (!sc->may_swap || (nr_swap_pages <= 0)) {
+	/*
+	 * If we have no swap space or may_writepage is false,
+	 * do not bother scanning anon pages.
+	 */
+	if (!sc->may_swap || !sc->may_writepage || (nr_swap_pages <= 0)) {
 		scan_balance = SCAN_FILE;
 		goto out;
 	}
@@ -1879,7 +1882,7 @@ static bool in_reclaim_compaction(struct scan_control *sc)
 {
 	if (IS_ENABLED(CONFIG_COMPACTION) && sc->order &&
 			(sc->order > PAGE_ALLOC_COSTLY_ORDER ||
-			 sc->priority < DEF_PRIORITY - 2))
+			 sc->priority < HARD_TO_RECLAIM_PRIO))
 		return true;
 
 	return false;
@@ -2215,9 +2218,16 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 			sc->may_writepage = 1;
 		}
 
+		/*
+		 * This is a safety belt to prevent OOM kill through reclaiming
+		 * pages with sacrificing the power.
+		 */
+		if (sc->priority < HARD_TO_RECLAIM_PRIO)
+			sc->may_writepage = 1;
+
 		/* Take a nap, wait for some writeback to complete */
 		if (!sc->hibernation_mode && sc->nr_scanned &&
-		    sc->priority < DEF_PRIORITY - 2) {
+		    sc->priority < HARD_TO_RECLAIM_PRIO) {
 			struct zone *preferred_zone;
 
 			first_zones_zonelist(zonelist, gfp_zone(sc->gfp_mask),
@@ -2824,7 +2834,7 @@ loop_again:
 		 * OK, kswapd is getting into trouble.  Take a nap, then take
 		 * another pass across the zones.
 		 */
-		if (total_scanned && (sc.priority < DEF_PRIORITY - 2)) {
+		if (total_scanned && (sc.priority < HARD_TO_RECLAIM_PRIO)) {
 			if (has_under_min_watermark_zone)
 				count_vm_event(KSWAPD_SKIP_CONGESTION_WAIT);
 			else if (unbalanced_zone)

> 
> The point of laptop_mode isn't to save power btw - it is to minimise
> the frequency with which the disk drive is spun up.  By deferring and
> then batching writeout operations, basically.

I don't get it. Why should we minimise such frequency?
It's for saving the power to increase batter life.
As I real all document about laptop_mode, they all said about the power
or battery life saving.

1. Documentation/laptops/laptop-mode.txt
2. http://linux.die.net/man/8/laptop_mode
3. http://samwel.tk/laptop_mode/
3. http://www.thinkwiki.org/wiki/Laptop-mode 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
