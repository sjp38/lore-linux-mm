Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id E75AF9C0009
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:30:01 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so7153588pad.14
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:30:01 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 18/63] sched: numa: Slow scan rate if no NUMA hinting faults are being recorded
Date: Mon,  7 Oct 2013 11:28:56 +0100
Message-Id: <1381141781-10992-19-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
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
index c0092e5..8cea7a2 100644
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
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
