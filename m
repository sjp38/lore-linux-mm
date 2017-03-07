Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C33536B038A
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 08:31:04 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id h188so1313817wma.4
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 05:31:04 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id y16si12657wrd.240.2017.03.07.05.31.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 05:31:03 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id u132so1004115wmg.1
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 05:31:03 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
Date: Tue,  7 Mar 2017 14:30:57 +0100
Message-Id: <20170307133057.26182-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Tetsuo Handa has reported [1][2] that direct reclaimers might get stuck
in too_many_isolated loop basically for ever because the last few pages
on the LRU lists are isolated by the kswapd which is stuck on fs locks
when doing the pageout or slab reclaim. This in turn means that there is
nobody to actually trigger the oom killer and the system is basically
unusable.

too_many_isolated has been introduced by 35cd78156c49 ("vmscan: throttle
direct reclaim when too many pages are isolated already") to prevent
from pre-mature oom killer invocations because back then no reclaim
progress could indeed trigger the OOM killer too early. But since the
oom detection rework 0a0337e0d1d1 ("mm, oom: rework oom detection")
the allocation/reclaim retry loop considers all the reclaimable pages
and throttles the allocation at that layer so we can loosen the direct
reclaim throttling.

Make shrink_inactive_list loop over too_many_isolated bounded and returns
immediately when the situation hasn't resolved after the first sleep.
Replace congestion_wait by a simple schedule_timeout_interruptible because
we are not really waiting on the IO congestion in this path.

Please note that this patch can theoretically cause the OOM killer to
trigger earlier while there are many pages isolated for the reclaim
which makes progress only very slowly. This would be obvious from the oom
report as the number of isolated pages are printed there. If we ever hit
this should_reclaim_retry should consider those numbers in the evaluation
in one way or another.

[1] http://lkml.kernel.org/r/201602092349.ACG81273.OSVtMJQHLOFOFF@I-love.SAKURA.ne.jp
[2] http://lkml.kernel.org/r/201702212335.DJB30777.JOFMHSFtVLQOOF@I-love.SAKURA.ne.jp

Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
Tetsuo helped to test this patch [3] and couldn't reproduce the hang
inside the page allocator anymore. Thanks! He was able to see a
different lockup though. This time this is more related to how XFS is
doing the inode reclaim from the WQ context. This is being discussed [4]
and I believe it is unrelated to this change.

I believe this change is still an improvement because it reduces chances
of an unbound loop inside the reclaim path so we have a) more reliable
detection of the lockup from the allocator path and b) more deterministic
retry loop logic.

Thoughts/complains/suggestions?

[3] http://lkml.kernel.org/r/201702261530.JDD56292.OFOLFHQtVMJSOF@I-love.SAKURA.ne.jp
[4] http://lkml.kernel.org/r/20170303133950.GD31582@dhcp22.suse.cz

 mm/vmscan.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c15b2e4c47ca..4ae069060ae5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1713,9 +1713,15 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	int file = is_file_lru(lru);
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
+	bool stalled = false;
 
 	while (unlikely(too_many_isolated(pgdat, file, sc))) {
-		congestion_wait(BLK_RW_ASYNC, HZ/10);
+		if (stalled)
+			return 0;
+
+		/* wait a bit for the reclaimer. */
+		schedule_timeout_interruptible(HZ/10);
+		stalled = true;
 
 		/* We are about to die and free our memory. Return now. */
 		if (fatal_signal_pending(current))
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
