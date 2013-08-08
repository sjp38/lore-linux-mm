Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 22F1B900008
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 10:00:57 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 12/27] sched: numa: Correct adjustment of numa_scan_period
Date: Thu,  8 Aug 2013 15:00:24 +0100
Message-Id: <1375970439-5111-13-git-send-email-mgorman@suse.de>
In-Reply-To: <1375970439-5111-1-git-send-email-mgorman@suse.de>
References: <1375970439-5111-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

numa_scan_period is in milliseconds, not jiffies. Properly placed pages
slow the scanning rate but adding 10 jiffies to numa_scan_period means
that the rate scanning slows depends on HZ which is confusing. Get rid
of the jiffies_to_msec conversion and treat it as ms.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 2908b4e..d77bb32 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -914,7 +914,7 @@ void task_numa_fault(int node, int pages, bool migrated)
 			p->numa_scan_period_max = task_scan_max(p);
 
 		p->numa_scan_period = min(p->numa_scan_period_max,
-			p->numa_scan_period + jiffies_to_msecs(10));
+			p->numa_scan_period + 10);
 	}
 
 	task_numa_placement(p);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
