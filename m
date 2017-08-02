Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 02F6E6B0550
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 03:19:07 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id a186so41532078pge.7
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 00:19:06 -0700 (PDT)
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id f11si11871153pln.472.2017.08.02.00.19.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 02 Aug 2017 00:19:05 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: [PATCH v6 7/7] mm: fix KSM data corruption
Date: Tue, 1 Aug 2017 17:08:18 -0700
Message-ID: <20170802000818.4760-8-namit@vmware.com>
In-Reply-To: <20170802000818.4760-1-namit@vmware.com>
References: <20170802000818.4760-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: nadav.amit@gmail.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Nadav Amit <namit@vmware.com>

From: Minchan Kim <minchan@kernel.org>

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
care about the fact that it clears the PTE write-bit, and of course,
batches TLB flushes.

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
and KSM checks pending TLB flush by using mm_tlb_flush_pending so that it
will flush TLB to avoid data lost if there are other parallel threads
pending TLB flush.

[1] http://lkml.kernel.org/r/BD3A0EBE-ECF4-41D4-87FA-C755EA9AB6BD@gmail.com

Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Reported-by: Nadav Amit <namit@vmware.com>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
Tested-by: Nadav Amit <namit@vmware.com>
---
 fs/proc/task_mmu.c | 7 +++++--
 mm/ksm.c           | 3 ++-
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 520802da059c..aa20da220973 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -16,9 +16,10 @@
 #include <linux/mmu_notifier.h>
 #include <linux/page_idle.h>
 #include <linux/shmem_fs.h>
+#include <linux/uaccess.h>
 
 #include <asm/elf.h>
-#include <linux/uaccess.h>
+#include <asm/tlb.h>
 #include <asm/tlbflush.h>
 #include "internal.h"
 
@@ -1009,6 +1010,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	enum clear_refs_types type;
+	struct mmu_gather tlb;
 	int itype;
 	int rv;
 
@@ -1055,6 +1057,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 		}
 
 		down_read(&mm->mmap_sem);
+		tlb_gather_mmu(&tlb, mm, 0, -1);
 		if (type == CLEAR_REFS_SOFT_DIRTY) {
 			for (vma = mm->mmap; vma; vma = vma->vm_next) {
 				if (!(vma->vm_flags & VM_SOFTDIRTY))
@@ -1076,7 +1079,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 		walk_page_range(0, mm->highest_vm_end, &clear_refs_walk);
 		if (type == CLEAR_REFS_SOFT_DIRTY)
 			mmu_notifier_invalidate_range_end(mm, 0, -1);
-		flush_tlb_mm(mm);
+		tlb_finish_mmu(&tlb, 0, -1);
 		up_read(&mm->mmap_sem);
 out_mm:
 		mmput(mm);
diff --git a/mm/ksm.c b/mm/ksm.c
index 216184af0e19..e5bf02e39752 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -883,7 +883,8 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 		goto out_unlock;
 
 	if (pte_write(*pvmw.pte) || pte_dirty(*pvmw.pte) ||
-	    (pte_protnone(*pvmw.pte) && pte_savedwrite(*pvmw.pte))) {
+	    (pte_protnone(*pvmw.pte) && pte_savedwrite(*pvmw.pte)) ||
+						mm_tlb_flush_pending(mm)) {
 		pte_t entry;
 
 		swapped = PageSwapCache(page);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
