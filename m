Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7CD8C90000D
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:28:12 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so2601896pdj.32
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:28:12 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 18/63] sched: numa: Slow scan rate if no NUMA hinting faults are being recorded
Date: Fri, 27 Sep 2013 14:27:03 +0100
Message-Id: <1380288468-5551-19-git-send-email-mgorman@suse.de>
In-Reply-To: <1380288468-5551-1-git-send-email-mgorman@suse.de>
References: <1380288468-5551-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

NUMA PTE scanning slows if a NUMA hinting fault was trapped and no page
was migrated. For long-lived but idle processes there may be no faults
but the scan rate will be high and just waste CPU. This patch will slow
the scan rate for processes that are not trapping faults.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 8b71a5e..cdd656c 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1039,6 +1039,18 @@ void task_numa_work(struct callback_head *work)
 
 out:
 	/*
+	 * If the whole process was scanned without updates then no NUMA
+	 * hinting faults are being recorded and scan rate should be lower.
+	 */
+	if (mm->numa_scan_offset == 0 && !nr_pte_updates) {
+		p->numa_scan_period = min(p->numa_scan_period_max,
+			p->numa_scan_period << 1);
+
+		next_scan = now + msecs_to_jiffies(p->numa_scan_period);
+		mm->numa_next_scan = next_scan;
+	}
+
+	/*
 	 * It is possible to reach the end of the VMA list but the last few
 	 * VMAs are not guaranteed to the vma_migratable. If they are not, we
 	 * would find the !migratable VMA on the next scan but not reset the
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
