Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 81E5C6B02AB
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 12:17:35 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id b1so226717273pgc.5
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 09:17:35 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id e4si19083968plj.170.2016.12.19.09.17.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 09:17:34 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 4/4] oom-reaper: use madvise_dontneed() logic to decide if unmap the VMA
Date: Mon, 19 Dec 2016 20:17:22 +0300
Message-Id: <20161219171722.77995-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161219171722.77995-1-kirill.shutemov@linux.intel.com>
References: <20161219171722.77995-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Logic on whether we can reap pages from the VMA should match what we
have in madvise_dontneed(). In particular, we should skip, VM_PFNMAP
VMAs, but we don't now.

Let's just extract condition on which we can shoot down pagesi from a
VMA with MADV_DONTNEED into separate function and use it in both places.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/internal.h | 5 +++++
 mm/madvise.c  | 2 +-
 mm/oom_kill.c | 9 +--------
 3 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 44d68895a9b9..7430628bff34 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -41,6 +41,11 @@ int do_swap_page(struct vm_fault *vmf);
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
index aa4c502caecb..20200dfbd1bb 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -473,7 +473,7 @@ static long madvise_dontneed(struct vm_area_struct *vma,
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
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
