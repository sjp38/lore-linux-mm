Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D8A156B0261
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 07:25:10 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id t6so14570400pgt.6
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 04:25:10 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id k76si76895pfg.249.2017.01.18.04.25.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 04:25:09 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RESEND 4/4] oom-reaper: use madvise_dontneed() logic to decide if unmap the VMA
Date: Wed, 18 Jan 2017 15:24:29 +0300
Message-Id: <20170118122429.43661-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170118122429.43661-1-kirill.shutemov@linux.intel.com>
References: <20170118122429.43661-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Logic on whether we can reap pages from the VMA should match what we
have in madvise_dontneed(). In particular, we should skip, VM_PFNMAP
VMAs, but we don't now.

Let's just extract condition on which we can shoot down pagesi from a
VMA with MADV_DONTNEED into separate function and use it in both places.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/internal.h | 5 +++++
 mm/madvise.c  | 4 +++-
 mm/oom_kill.c | 9 +--------
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 7aa2ea0a8623..03763f5c42c5 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -43,6 +43,11 @@ int do_swap_page(struct vm_fault *vmf);
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 
+static inline bool can_madv_dontneed_vma(struct vm_area_struct *vma)
+{
+	return !(vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP));
+}
+
 void unmap_page_range(struct mmu_gather *tlb,
 			     struct vm_area_struct *vma,
 			     unsigned long addr, unsigned long end,
diff --git a/mm/madvise.c b/mm/madvise.c
index aa4c502caecb..c53d8da9c8e6 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -24,6 +24,8 @@
 
 #include <asm/tlb.h>
 
+#include "internal.h"
+
 /*
  * Any behaviour which results in changes to the vma->vm_flags needs to
  * take mmap_sem for writing. Others, which simply traverse vmas, need
@@ -473,7 +475,7 @@ static long madvise_dontneed(struct vm_area_struct *vma,
 			     unsigned long start, unsigned long end)
 {
 	*prev = vma;
-	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
+	if (!can_madv_dontneed_vma(vma))
 		return -EINVAL;
 
 	zap_page_range(vma, start, end - start);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 96a53ab0c9eb..b6d8ac4948db 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -508,14 +508,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 
 	tlb_gather_mmu(&tlb, mm, 0, -1);
 	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
-		if (is_vm_hugetlb_page(vma))
-			continue;
-
-		/*
-		 * mlocked VMAs require explicit munlocking before unmap.
-		 * Let's keep it simple here and skip such VMAs.
-		 */
-		if (vma->vm_flags & VM_LOCKED)
+		if (!can_madv_dontneed_vma(vma))
 			continue;
 
 		/*
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
