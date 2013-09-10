Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 7DDD86B007B
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 05:33:03 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 28/50] sched: Remove check that skips small VMAs
Date: Tue, 10 Sep 2013 10:32:08 +0100
Message-Id: <1378805550-29949-29-git-send-email-mgorman@suse.de>
In-Reply-To: <1378805550-29949-1-git-send-email-mgorman@suse.de>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

task_numa_work skips small VMAs. At the time the logic was to reduce the
scanning overhead which was considerable. It is a dubious hack at best.
It would make much more sense to cache where faults have been observed
and only rescan those regions during subsequent PTE scans. Remove this
hack as motivation to do it properly in the future.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index e259241..2d04112 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1127,10 +1127,6 @@ void task_numa_work(struct callback_head *work)
 		if (!vma_migratable(vma))
 			continue;
 
-		/* Skip small VMAs. They are not likely to be of relevance */
-		if (vma->vm_end - vma->vm_start < HPAGE_SIZE)
-			continue;
-
 		do {
 			start = max(start, vma->vm_start);
 			end = ALIGN(start + (pages << PAGE_SHIFT), HPAGE_SIZE);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
