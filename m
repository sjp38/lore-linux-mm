Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 384A59C0019
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:30:18 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so7104268pab.32
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:30:17 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 35/63] sched: numa: Do not trap hinting faults for shared libraries
Date: Mon,  7 Oct 2013 11:29:13 +0100
Message-Id: <1381141781-10992-36-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-1-git-send-email-mgorman@suse.de>
References: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

NUMA hinting faults will not migrate a shared executable page mapped by
multiple processes on the grounds that the data is probably in the CPU
cache already and the page may just bounce between tasks running on multipl
nodes. Even if the migration is avoided, there is still the overhead of
trapping the fault, updating the statistics, making scheduler placement
decisions based on the information etc. If we are never going to migrate
the page, it is overhead for no gain and worse a process may be placed on
a sub-optimal node for shared executable pages. This patch avoids trapping
faults for shared libraries entirely.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 9a2e68e..8760231 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1231,6 +1231,16 @@ void task_numa_work(struct callback_head *work)
 		if (!vma_migratable(vma) || !vma_policy_mof(p, vma))
 			continue;
 
+		/*
+		 * Shared library pages mapped by multiple processes are not
+		 * migrated as it is expected they are cache replicated. Avoid
+		 * hinting faults in read-only file-backed mappings or the vdso
+		 * as migrating the pages will be of marginal benefit.
+		 */
+		if (!vma->vm_mm ||
+		    (vma->vm_file && (vma->vm_flags & (VM_READ|VM_WRITE)) == (VM_READ)))
+			continue;
+
 		do {
 			start = max(start, vma->vm_start);
 			end = ALIGN(start + (pages << PAGE_SHIFT), HPAGE_SIZE);
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
