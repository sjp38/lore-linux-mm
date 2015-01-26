Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2606D6B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 17:12:02 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id y10so14460036pdj.9
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 14:12:01 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x10si13932620pdk.16.2015.01.26.14.12.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 14:12:01 -0800 (PST)
Date: Mon, 26 Jan 2015 14:11:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: vmscan: fix the page state calculation in
 too_many_isolated
Message-Id: <20150126141159.cfb8357352e044f5d6f66369@linux-foundation.org>
In-Reply-To: <20150126172832.GC22681@dhcp22.suse.cz>
References: <1421235419-30736-1-git-send-email-vinmenon@codeaurora.org>
	<20150114165036.GI4706@dhcp22.suse.cz>
	<54B7F7C4.2070105@codeaurora.org>
	<20150116154922.GB4650@dhcp22.suse.cz>
	<54BA7D3A.40100@codeaurora.org>
	<alpine.DEB.2.11.1501171347290.25464@gentwo.org>
	<20150126172832.GC22681@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Christoph Lameter <cl@linux.com>, Vinayak Menon <vinmenon@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, vdavydov@parallels.com, mgorman@suse.de, minchan@kernel.org

On Mon, 26 Jan 2015 18:28:32 +0100 Michal Hocko <mhocko@suse.cz> wrote:

> Subject: [PATCH] vmstat: Do not use deferrable delayed work for vmstat_update
> 
> Vinayak Menon has reported that excessive number of tasks was throttled
> in the direct reclaim inside too_many_isolated because NR_ISOLATED_FILE
> was relatively high compared to NR_INACTIVE_FILE. However it turned out
> that the real number of NR_ISOLATED_FILE was 0 and the per-cpu
> vm_stat_diff wasn't transfered into the global counter.
> 
> vmstat_work which is responsible for the sync is defined as deferrable
> delayed work which means that the defined timeout doesn't wake up an
> idle CPU. A CPU might stay in an idle state for a long time and general
> effort is to keep such a CPU in this state as long as possible which
> might lead to all sorts of troubles for vmstat consumers as can be seen
> with the excessive direct reclaim throttling.
> 
> This patch basically reverts 39bf6270f524 (VM statistics: Make timer
> deferrable) but it shouldn't cause any problems for idle CPUs because
> only CPUs with an active per-cpu drift are woken up since 7cc36bbddde5
> (vmstat: on-demand vmstat workers v8) and CPUs which are idle for a
> longer time shouldn't have per-cpu drift.

So do we drop
mm-vmscan-fix-the-page-state-calculation-in-too_many_isolated.patch?


From: Vinayak Menon <vinmenon@codeaurora.org>
Subject: mm: vmscan: fix the page state calculation in too_many_isolated

It is observed that sometimes multiple tasks get blocked for long in the
congestion_wait loop below, in shrink_inactive_list.  This is because of
vm_stat values not being synced.

(__schedule) from [<c0a03328>]
(schedule_timeout) from [<c0a04940>]
(io_schedule_timeout) from [<c01d585c>]
(congestion_wait) from [<c01cc9d8>]
(shrink_inactive_list) from [<c01cd034>]
(shrink_zone) from [<c01cdd08>]
(try_to_free_pages) from [<c01c442c>]
(__alloc_pages_nodemask) from [<c01f1884>]
(new_slab) from [<c09fcf60>]
(__slab_alloc) from [<c01f1a6c>]

In one such instance, zone_page_state(zone, NR_ISOLATED_FILE) had returned
14, zone_page_state(zone, NR_INACTIVE_FILE) returned 92, and GFP_IOFS was
set, and this resulted in too_many_isolated returning true.  But one of
the CPU's pageset vm_stat_diff had NR_ISOLATED_FILE as "-14".  So the
actual isolated count was zero.  As there weren't any more updates to
NR_ISOLATED_FILE and vmstat_update deffered work had not been scheduled
yet, 7 tasks were spinning in the congestion wait loop for around 4
seconds, in the direct reclaim path.

This patch uses zone_page_state_snapshot instead, but restricts its usage
to avoid performance penalty.


The vmstat sync interval is HZ (sysctl_stat_interval), but since the
vmstat_work is declared as a deferrable work, the timer trigger can be
deferred to the next non-defferable timer expiry on the CPU which is in
idle.  This results in the vmstat syncing on an idle CPU being delayed by
seconds.  May be in most cases this behavior is fine, except in cases like
this.

Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/vmscan.c |   56 +++++++++++++++++++++++++++++++++-----------------
 1 file changed, 37 insertions(+), 19 deletions(-)

diff -puN mm/vmscan.c~mm-vmscan-fix-the-page-state-calculation-in-too_many_isolated mm/vmscan.c
--- a/mm/vmscan.c~mm-vmscan-fix-the-page-state-calculation-in-too_many_isolated
+++ a/mm/vmscan.c
@@ -1401,6 +1401,32 @@ int isolate_lru_page(struct page *page)
 	return ret;
 }
 
+static int __too_many_isolated(struct zone *zone, int file,
+	struct scan_control *sc, int safe)
+{
+	unsigned long inactive, isolated;
+
+	if (safe) {
+		inactive = zone_page_state_snapshot(zone,
+				NR_INACTIVE_ANON + 2 * file);
+		isolated = zone_page_state_snapshot(zone,
+				NR_ISOLATED_ANON + file);
+	} else {
+		inactive = zone_page_state(zone, NR_INACTIVE_ANON + 2 * file);
+		isolated = zone_page_state(zone, NR_ISOLATED_ANON + file);
+	}
+
+	/*
+	 * GFP_NOIO/GFP_NOFS callers are allowed to isolate more pages, so they
+	 * won't get blocked by normal direct-reclaimers, forming a circular
+	 * deadlock.
+	 */
+	if ((sc->gfp_mask & GFP_IOFS) == GFP_IOFS)
+		inactive >>= 3;
+
+	return isolated > inactive;
+}
+
 /*
  * A direct reclaimer may isolate SWAP_CLUSTER_MAX pages from the LRU list and
  * then get resheduled. When there are massive number of tasks doing page
@@ -1409,33 +1435,22 @@ int isolate_lru_page(struct page *page)
  * unnecessary swapping, thrashing and OOM.
  */
 static int too_many_isolated(struct zone *zone, int file,
-		struct scan_control *sc)
+		struct scan_control *sc, int safe)
 {
-	unsigned long inactive, isolated;
-
 	if (current_is_kswapd())
 		return 0;
 
 	if (!global_reclaim(sc))
 		return 0;
 
-	if (file) {
-		inactive = zone_page_state(zone, NR_INACTIVE_FILE);
-		isolated = zone_page_state(zone, NR_ISOLATED_FILE);
-	} else {
-		inactive = zone_page_state(zone, NR_INACTIVE_ANON);
-		isolated = zone_page_state(zone, NR_ISOLATED_ANON);
+	if (unlikely(__too_many_isolated(zone, file, sc, 0))) {
+		if (safe)
+			return __too_many_isolated(zone, file, sc, safe);
+		else
+			return 1;
 	}
 
-	/*
-	 * GFP_NOIO/GFP_NOFS callers are allowed to isolate more pages, so they
-	 * won't get blocked by normal direct-reclaimers, forming a circular
-	 * deadlock.
-	 */
-	if ((sc->gfp_mask & GFP_IOFS) == GFP_IOFS)
-		inactive >>= 3;
-
-	return isolated > inactive;
+	return 0;
 }
 
 static noinline_for_stack void
@@ -1525,15 +1540,18 @@ shrink_inactive_list(unsigned long nr_to
 	unsigned long nr_immediate = 0;
 	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
+	int safe = 0;
 	struct zone *zone = lruvec_zone(lruvec);
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 
-	while (unlikely(too_many_isolated(zone, file, sc))) {
+	while (unlikely(too_many_isolated(zone, file, sc, safe))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 		/* We are about to die and free our memory. Return now. */
 		if (fatal_signal_pending(current))
 			return SWAP_CLUSTER_MAX;
+
+		safe = 1;
 	}
 
 	lru_add_drain();
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
