Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1D1EB6B006E
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 20:17:43 -0500 (EST)
Received: by mail-yk0-f170.google.com with SMTP id 200so8353578ykr.1
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 17:17:42 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 84si1296730ykz.71.2015.01.15.17.17.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jan 2015 17:17:42 -0800 (PST)
Date: Thu, 15 Jan 2015 17:17:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: vmscan: fix the page state calculation in
 too_many_isolated
Message-Id: <20150115171728.ebc77a48.akpm@linux-foundation.org>
In-Reply-To: <1421235419-30736-1-git-send-email-vinmenon@codeaurora.org>
References: <1421235419-30736-1-git-send-email-vinmenon@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, vdavydov@parallels.com, mhocko@suse.cz, mgorman@suse.de, minchan@kernel.org

On Wed, 14 Jan 2015 17:06:59 +0530 Vinayak Menon <vinmenon@codeaurora.org> wrote:

> It is observed that sometimes multiple tasks get blocked for long
> in the congestion_wait loop below, in shrink_inactive_list. This
> is because of vm_stat values not being synced.
> 
> (__schedule) from [<c0a03328>]
> (schedule_timeout) from [<c0a04940>]
> (io_schedule_timeout) from [<c01d585c>]
> (congestion_wait) from [<c01cc9d8>]
> (shrink_inactive_list) from [<c01cd034>]
> (shrink_zone) from [<c01cdd08>]
> (try_to_free_pages) from [<c01c442c>]
> (__alloc_pages_nodemask) from [<c01f1884>]
> (new_slab) from [<c09fcf60>]
> (__slab_alloc) from [<c01f1a6c>]
> 
> In one such instance, zone_page_state(zone, NR_ISOLATED_FILE)
> had returned 14, zone_page_state(zone, NR_INACTIVE_FILE)
> returned 92, and GFP_IOFS was set, and this resulted
> in too_many_isolated returning true. But one of the CPU's
> pageset vm_stat_diff had NR_ISOLATED_FILE as "-14". So the
> actual isolated count was zero. As there weren't any more
> updates to NR_ISOLATED_FILE and vmstat_update deffered work
> had not been scheduled yet, 7 tasks were spinning in the
> congestion wait loop for around 4 seconds, in the direct
> reclaim path.
> 
> This patch uses zone_page_state_snapshot instead, but restricts
> its usage to avoid performance penalty.

Seems reasonable.

>
> ...
>
> @@ -1516,15 +1531,18 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	unsigned long nr_immediate = 0;
>  	isolate_mode_t isolate_mode = 0;
>  	int file = is_file_lru(lru);
> +	int safe = 0;
>  	struct zone *zone = lruvec_zone(lruvec);
>  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
>  
> -	while (unlikely(too_many_isolated(zone, file, sc))) {
> +	while (unlikely(too_many_isolated(zone, file, sc, safe))) {
>  		congestion_wait(BLK_RW_ASYNC, HZ/10);
>  
>  		/* We are about to die and free our memory. Return now. */
>  		if (fatal_signal_pending(current))
>  			return SWAP_CLUSTER_MAX;
> +
> +		safe = 1;
>  	}

But here and under the circumstances you describe, we'll call
congestion_wait() a single time.  That shouldn't have occurred.

So how about we put the fallback logic into too_many_isolated() itself?



From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-vmscan-fix-the-page-state-calculation-in-too_many_isolated-fix

Move the zone_page_state_snapshot() fallback logic into
too_many_isolated(), so shrink_inactive_list() doesn't incorrectly call
congestion_wait().

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Vinayak Menon <vinmenon@codeaurora.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/vmscan.c |   23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

diff -puN mm/vmscan.c~mm-vmscan-fix-the-page-state-calculation-in-too_many_isolated-fix mm/vmscan.c
--- a/mm/vmscan.c~mm-vmscan-fix-the-page-state-calculation-in-too_many_isolated-fix
+++ a/mm/vmscan.c
@@ -1402,7 +1402,7 @@ int isolate_lru_page(struct page *page)
 }
 
 static int __too_many_isolated(struct zone *zone, int file,
-	struct scan_control *sc, int safe)
+			       struct scan_control *sc, int safe)
 {
 	unsigned long inactive, isolated;
 
@@ -1435,7 +1435,7 @@ static int __too_many_isolated(struct zo
  * unnecessary swapping, thrashing and OOM.
  */
 static int too_many_isolated(struct zone *zone, int file,
-		struct scan_control *sc, int safe)
+			     struct scan_control *sc)
 {
 	if (current_is_kswapd())
 		return 0;
@@ -1443,12 +1443,14 @@ static int too_many_isolated(struct zone
 	if (!global_reclaim(sc))
 		return 0;
 
-	if (unlikely(__too_many_isolated(zone, file, sc, 0))) {
-		if (safe)
-			return __too_many_isolated(zone, file, sc, safe);
-		else
-			return 1;
-	}
+	/*
+	 * __too_many_isolated(safe=0) is fast but inaccurate, because it
+	 * doesn't account for the vm_stat_diff[] counters.  So if it looks
+	 * like too_many_isolated() is about to return true, fall back to the
+	 * slower, more accurate zone_page_state_snapshot().
+	 */
+	if (unlikely(__too_many_isolated(zone, file, sc, 0)))
+		return __too_many_isolated(zone, file, sc, safe);
 
 	return 0;
 }
@@ -1540,18 +1542,15 @@ shrink_inactive_list(unsigned long nr_to
 	unsigned long nr_immediate = 0;
 	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
-	int safe = 0;
 	struct zone *zone = lruvec_zone(lruvec);
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 
-	while (unlikely(too_many_isolated(zone, file, sc, safe))) {
+	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 		/* We are about to die and free our memory. Return now. */
 		if (fatal_signal_pending(current))
 			return SWAP_CLUSTER_MAX;
-
-		safe = 1;
 	}
 
 	lru_add_drain();
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
