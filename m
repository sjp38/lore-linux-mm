Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 99F0D6B04F0
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 01:56:22 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id t25so6768251pfg.15
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 22:56:22 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id b68si17196168pfa.605.2017.07.31.22.56.20
        for <linux-mm@kvack.org>;
        Mon, 31 Jul 2017 22:56:21 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 4/4] mm: fix KSM data corruption
Date: Tue,  1 Aug 2017 14:56:17 +0900
Message-Id: <1501566977-20293-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1501566977-20293-1-git-send-email-minchan@kernel.org>
References: <1501566977-20293-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>

Nadav reported KSM can corrupt the user data by the TLB batching race[1].
That means data user written can be lost.

Quote from Nadav Amit
"
For this race we need 4 CPUs:

CPU0: Caches a writable and dirty PTE entry, and uses the stale value for
write later.

CPU1: Runs madvise_free on the range that includes the PTE. It would clear
the dirty-bit. It batches TLB flushes.

CPU2: Writes 4 to /proc/PID/clear_refs , clearing the PTEs soft-dirty. We
care about the fact that it clears the PTE write-bit, and of course, batches
TLB flushes.

CPU3: Runs KSM. Our purpose is to pass the following test in
write_protect_page():

	if (pte_write(*pvmw.pte) || pte_dirty(*pvmw.pte) ||
	    (pte_protnone(*pvmw.pte) && pte_savedwrite(*pvmw.pte)))

Since it will avoid TLB flush. And we want to do it while the PTE is stale.
Later, and before replacing the page, we would be able to change the page.

Note that all the operations the CPU1-3 perform canhappen in parallel since
they only acquire mmap_sem for read.

We start with two identical pages. Everything below regards the same
page/PTE.

CPU0		CPU1		CPU2		CPU3
----		----		----		----
Write the same
value on page

[cache PTE as
 dirty in TLB]

		MADV_FREE
		pte_mkclean()

				4 > clear_refs
				pte_wrprotect()

						write_protect_page()
						[ success, no flush ]

						pages_indentical()
						[ ok ]

Write to page
different value

[Ok, using stale
 PTE]

						replace_page()

Later, CPU1, CPU2 and CPU3 would flush the TLB, but that is too late. CPU0
already wrote on the page, but KSM ignored this write, and it got lost.
"

In above scenario, MADV_FREE is fixed by changing TLB batching API
including [set|clear]_tlb_flush_pending. Remained thing is soft-dirty part.

This patch changes soft-dirty uses TLB batching API instead of flush_tlb_mm
and KSM checks pending TLB flush by using mm_tlb_flush_pending so that
it will flush TLB to avoid data lost if there are other parallel threads
pending TLB flush.

[1] http://lkml.kernel.org/r/BD3A0EBE-ECF4-41D4-87FA-C755EA9AB6BD@gmail.com

Note:
I failed to reproduce this problem through Nadav's test program which
need to tune timing in my system speed so didn't confirm it work.
Nadav, Could you test this patch on your test machine?

Thanks!

Cc: Nadav Amit <nadav.amit@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 fs/proc/task_mmu.c | 4 +++-
 mm/ksm.c           | 3 ++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 9782dedeead7..58ef3a6abbc0 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1018,6 +1018,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 	enum clear_refs_types type;
 	int itype;
 	int rv;
+	struct mmu_gather tlb;
 
 	memset(buffer, 0, sizeof(buffer));
 	if (count > sizeof(buffer) - 1)
@@ -1062,6 +1063,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 		}
 
 		down_read(&mm->mmap_sem);
+		tlb_gather_mmu(&tlb, mm, 0, -1);
 		if (type == CLEAR_REFS_SOFT_DIRTY) {
 			for (vma = mm->mmap; vma; vma = vma->vm_next) {
 				if (!(vma->vm_flags & VM_SOFTDIRTY))
@@ -1083,7 +1085,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 		walk_page_range(0, mm->highest_vm_end, &clear_refs_walk);
 		if (type == CLEAR_REFS_SOFT_DIRTY)
 			mmu_notifier_invalidate_range_end(mm, 0, -1);
-		flush_tlb_mm(mm);
+		tlb_finish_mmu(&tlb, 0, -1);
 		up_read(&mm->mmap_sem);
 out_mm:
 		mmput(mm);
diff --git a/mm/ksm.c b/mm/ksm.c
index 0c927e36a639..15dd7415f7b3 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1038,7 +1038,8 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 		goto out_unlock;
 
 	if (pte_write(*pvmw.pte) || pte_dirty(*pvmw.pte) ||
-	    (pte_protnone(*pvmw.pte) && pte_savedwrite(*pvmw.pte))) {
+	    (pte_protnone(*pvmw.pte) && pte_savedwrite(*pvmw.pte)) ||
+						mm_tlb_flush_pending(mm)) {
 		pte_t entry;
 
 		swapped = PageSwapCache(page);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
