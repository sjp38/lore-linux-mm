Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 99AE16B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 16:36:45 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w143so23316392wmw.2
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 13:36:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qn6si2093046wjc.143.2016.04.19.13.36.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Apr 2016 13:36:44 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 4.6] mm: wake kcompactd before kswapd's short sleep
Date: Tue, 19 Apr 2016 22:36:31 +0200
Message-Id: <1461098191-29304-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>

When kswapd goes to sleep it checks if the node is balanced and at first it
sleeps only for HZ/10 time, then rechecks if the node is still balanced and
nobody has woken it during the initial sleep. Only then it goes fully sleep
until an allocation slowpath wakes it up again.

For higher-order allocations, waking up kcompactd is done only before the full
sleep. This turns out to be an issue in case another high-order allocation
fails during the initial sleep. It will wake kswapd up, however kswapd
considers the zone balanced from the order-0 perspective, and will just quickly
try to sleep again. So if there's a longer stream of high-order allocations
hitting the slowpath and waking up kswapd, it might never actually wake up
kcompactd, which may be considered a regression from kswapd-based compaction.
In the worst case, it might be that a single allocation that cannot direct
reclaim/compact itself is waking kswapd in the retry loop and preventing
kcompactd from being woken up and unblocking it.

This patch makes sure kcompactd is woken up in such situations by simply moving
the wakeup before the short initial sleep. More efficient solution would be to
wake kcompactd immediately instead of kswapd if the node is already order-0
balanced, but in that case we should also move reset_isolation_suitable() call
to kcompactd so it's not adding to the allocator's latency. Since it's late in
the 4.6 cycle, let's go with the simpler change for now.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Fixes: accf62422b3a ("mm, kswapd: replace kswapd compaction with waking up kcompactd")
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b934223eaa45..e44e9435c1c4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3318,6 +3318,20 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order,
 	/* Try to sleep for a short interval */
 	if (prepare_kswapd_sleep(pgdat, order, remaining,
 						balanced_classzone_idx)) {
+		/*
+		 * Compaction records what page blocks it recently failed to
+		 * isolate pages from and skips them in the future scanning.
+		 * When kswapd is going to sleep, it is reasonable to assume
+		 * that pages and compaction may succeed so reset the cache.
+		 */
+		reset_isolation_suitable(pgdat);
+
+		/*
+		 * We have freed the memory, now we should compact it to make
+		 * allocation of the requested order possible.
+		 */
+		wakeup_kcompactd(pgdat, order, classzone_idx);
+
 		remaining = schedule_timeout(HZ/10);
 		finish_wait(&pgdat->kswapd_wait, &wait);
 		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
@@ -3341,20 +3355,6 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order,
 		 */
 		set_pgdat_percpu_threshold(pgdat, calculate_normal_threshold);
 
-		/*
-		 * Compaction records what page blocks it recently failed to
-		 * isolate pages from and skips them in the future scanning.
-		 * When kswapd is going to sleep, it is reasonable to assume
-		 * that pages and compaction may succeed so reset the cache.
-		 */
-		reset_isolation_suitable(pgdat);
-
-		/*
-		 * We have freed the memory, now we should compact it to make
-		 * allocation of the requested order possible.
-		 */
-		wakeup_kcompactd(pgdat, order, classzone_idx);
-
 		if (!kthread_should_stop())
 			schedule();
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
