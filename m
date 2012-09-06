Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 9AE246B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 18:36:20 -0400 (EDT)
Date: Thu, 6 Sep 2012 15:36:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/7] mm: vmscan: Scale number of pages reclaimed by
 reclaim/compaction based on failures
Message-Id: <20120906153619.b0df4bd8.akpm@linux-foundation.org>
In-Reply-To: <1345212873-22447-7-git-send-email-mgorman@suse.de>
References: <1345212873-22447-1-git-send-email-mgorman@suse.de>
	<1345212873-22447-7-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Jim Schutt <jaschut@sandia.gov>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 17 Aug 2012 15:14:32 +0100
Mel Gorman <mgorman@suse.de> wrote:

> If allocation fails after compaction then compaction may be deferred for
> a number of allocation attempts. If there are subsequent failures,
> compact_defer_shift is increased to defer for longer periods. This patch
> uses that information to scale the number of pages reclaimed with
> compact_defer_shift until allocations succeed again. The rationale is
> that reclaiming the normal number of pages still allowed compaction to
> fail and its success depends on the number of pages. If it's failing,
> reclaim more pages until it succeeds again.
> 
> Note that this is not implying that VM reclaim is not reclaiming enough
> pages or that its logic is broken. try_to_free_pages() always asks for
> SWAP_CLUSTER_MAX pages to be reclaimed regardless of order and that is
> what it does. Direct reclaim stops normally with this check.
> 
> 	if (sc->nr_reclaimed >= sc->nr_to_reclaim)
> 		goto out;
> 
> should_continue_reclaim delays when that check is made until a minimum number
> of pages for reclaim/compaction are reclaimed. It is possible that this patch
> could instead set nr_to_reclaim in try_to_free_pages() and drive it from
> there but that's behaves differently and not necessarily for the better. If
> driven from do_try_to_free_pages(), it is also possible that priorities
> will rise. When they reach DEF_PRIORITY-2, it will also start stalling
> and setting pages for immediate reclaim which is more disruptive than not
> desirable in this case. That is a more wide-reaching change that could
> cause another regression related to THP requests causing interactive jitter.
> 
> ...
>
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1743,6 +1743,7 @@ static inline bool should_continue_reclaim(struct lruvec *lruvec,
>  {
>  	unsigned long pages_for_compaction;
>  	unsigned long inactive_lru_pages;
> +	struct zone *zone;
>  
>  	/* If not in reclaim/compaction mode, stop */
>  	if (!in_reclaim_compaction(sc))
> @@ -1776,6 +1777,15 @@ static inline bool should_continue_reclaim(struct lruvec *lruvec,
>  	 * inactive lists are large enough, continue reclaiming
>  	 */
>  	pages_for_compaction = (2UL << sc->order);
> +
> +	/*
> +	 * If compaction is deferred for sc->order then scale the number of
> +	 * pages reclaimed based on the number of consecutive allocation
> +	 * failures
> +	 */
> +	zone = lruvec_zone(lruvec);
> +	if (zone->compact_order_failed <= sc->order)
> +		pages_for_compaction <<= zone->compact_defer_shift;
>  	inactive_lru_pages = get_lru_size(lruvec, LRU_INACTIVE_FILE);
>  	if (nr_swap_pages > 0)
>  		inactive_lru_pages += get_lru_size(lruvec, LRU_INACTIVE_ANON);

y'know, allnoconfig builds are really fast.

mm/vmscan.c: In function 'should_continue_reclaim':
mm/vmscan.c:1787: error: 'struct zone' has no member named 'compact_order_failed'
mm/vmscan.c:1788: error: 'struct zone' has no member named 'compact_defer_shift'

This fix seems a rather overly ornate way of avoiding an ifdef :(


From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-vmscan-scale-number-of-pages-reclaimed-by-reclaim-compaction-based-on-failures-fix

fix build

Cc: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/vmscan.c |   33 ++++++++++++++++++++++++---------
 1 file changed, 24 insertions(+), 9 deletions(-)

diff -puN mm/vmscan.c~mm-vmscan-scale-number-of-pages-reclaimed-by-reclaim-compaction-based-on-failures-fix mm/vmscan.c
--- a/mm/vmscan.c~mm-vmscan-scale-number-of-pages-reclaimed-by-reclaim-compaction-based-on-failures-fix
+++ a/mm/vmscan.c
@@ -1729,6 +1729,28 @@ static bool in_reclaim_compaction(struct
 	return false;
 }
 
+#ifdef CONFIG_COMPACTION
+/*
+ * If compaction is deferred for sc->order then scale the number of pages
+ * reclaimed based on the number of consecutive allocation failures
+ */
+static unsigned long scale_for_compaction(unsigned long pages_for_compaction,
+			struct lruvec *lruvec, struct scan_control *sc)
+{
+	struct zone *zone = lruvec_zone(lruvec);
+
+	if (zone->compact_order_failed <= sc->order)
+		pages_for_compaction <<= zone->compact_defer_shift;
+	return pages_for_compaction;
+}
+#else
+static unsigned long scale_for_compaction(unsigned long pages_for_compaction,
+			struct lruvec *lruvec, struct scan_control *sc)
+{
+	return pages_for_compaction;
+}
+#endif
+
 /*
  * Reclaim/compaction is used for high-order allocation requests. It reclaims
  * order-0 pages before compacting the zone. should_continue_reclaim() returns
@@ -1743,7 +1765,6 @@ static inline bool should_continue_recla
 {
 	unsigned long pages_for_compaction;
 	unsigned long inactive_lru_pages;
-	struct zone *zone;
 
 	/* If not in reclaim/compaction mode, stop */
 	if (!in_reclaim_compaction(sc))
@@ -1778,14 +1799,8 @@ static inline bool should_continue_recla
 	 */
 	pages_for_compaction = (2UL << sc->order);
 
-	/*
-	 * If compaction is deferred for sc->order then scale the number of
-	 * pages reclaimed based on the number of consecutive allocation
-	 * failures
-	 */
-	zone = lruvec_zone(lruvec);
-	if (zone->compact_order_failed <= sc->order)
-		pages_for_compaction <<= zone->compact_defer_shift;
+	pages_for_compaction = scale_for_compaction(pages_for_compaction,
+						    lruvec, sc);
 	inactive_lru_pages = get_lru_size(lruvec, LRU_INACTIVE_FILE);
 	if (nr_swap_pages > 0)
 		inactive_lru_pages += get_lru_size(lruvec, LRU_INACTIVE_ANON);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
