Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id B1F188D000E
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 17:51:25 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so3216535eaa.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2012 14:51:25 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 21/33] sched, numa, mm: Count WS scanning against present PTEs, not virtual memory ranges
Date: Thu, 22 Nov 2012 23:49:42 +0100
Message-Id: <1353624594-1118-22-git-send-email-mingo@kernel.org>
In-Reply-To: <1353624594-1118-1-git-send-email-mingo@kernel.org>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

By accounting against the present PTEs, scanning speed reflects the
actual present (mapped) memory.

Suggested-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 kernel/sched/fair.c | 37 +++++++++++++++++++++----------------
 1 file changed, 21 insertions(+), 16 deletions(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 151a3cd..da28315 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -914,8 +914,8 @@ void task_numa_work(struct callback_head *work)
 	struct task_struct *p = current;
 	struct mm_struct *mm = p->mm;
 	struct vm_area_struct *vma;
-	unsigned long offset, end;
-	long length;
+	unsigned long start, end;
+	long pages;
 
 	WARN_ON_ONCE(p != container_of(work, struct task_struct, numa_work));
 
@@ -942,30 +942,35 @@ void task_numa_work(struct callback_head *work)
 	if (cmpxchg(&mm->numa_next_scan, migrate, next_scan) != migrate)
 		return;
 
-	offset = mm->numa_scan_offset;
-	length = sysctl_sched_numa_scan_size;
-	length <<= 20;
+	start = mm->numa_scan_offset;
+	pages = sysctl_sched_numa_scan_size;
+	pages <<= 20 - PAGE_SHIFT; /* MB in pages */
+	if (!pages)
+		return;
 
 	down_write(&mm->mmap_sem);
-	vma = find_vma(mm, offset);
+	vma = find_vma(mm, start);
 	if (!vma) {
 		ACCESS_ONCE(mm->numa_scan_seq)++;
-		offset = 0;
+		start = 0;
 		vma = mm->mmap;
 	}
-	for (; vma && length > 0; vma = vma->vm_next) {
+	for (; vma; vma = vma->vm_next) {
 		if (!vma_migratable(vma))
 			continue;
 
-		offset = max(offset, vma->vm_start);
-		end = min(ALIGN(offset + length, HPAGE_SIZE), vma->vm_end);
-		length -= end - offset;
-
-		change_prot_numa(vma, offset, end);
-
-		offset = end;
+		do {
+			start = max(start, vma->vm_start);
+			end = ALIGN(start + (pages << PAGE_SHIFT), HPAGE_SIZE);
+			end = min(end, vma->vm_end);
+			pages -= change_prot_numa(vma, start, end);
+			start = end;
+			if (pages <= 0)
+				goto out;
+		} while (end != vma->vm_end);
 	}
-	mm->numa_scan_offset = offset;
+out:
+	mm->numa_scan_offset = start;
 	up_write(&mm->mmap_sem);
 }
 
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
