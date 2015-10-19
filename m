Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id AD02082F67
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 02:28:46 -0400 (EDT)
Received: by pasz6 with SMTP id z6so20610359pas.2
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 23:28:46 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id qy2si25073176pbb.55.2015.10.18.23.28.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 18 Oct 2015 23:28:41 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 1/5] mm: MADV_FREE trivial clean up
Date: Mon, 19 Oct 2015 15:31:43 +0900
Message-Id: <1445236307-895-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1445236307-895-1-git-send-email-minchan@kernel.org>
References: <1445236307-895-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>

1. Page table waker already pass the vma it is processing
so we don't need to pass vma.

2. If page table entry is dirty in try_to_unmap_one, the dirtiness
should propagate to PG_dirty of the page. So, it's enough to check
only PageDirty without other pte dirty bit checking.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/madvise.c | 17 +++--------------
 mm/rmap.c    |  6 ++----
 2 files changed, 5 insertions(+), 18 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 7835bc1eaccb..fdfb14a78c60 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -24,11 +24,6 @@
 
 #include <asm/tlb.h>
 
-struct madvise_free_private {
-	struct vm_area_struct *vma;
-	struct mmu_gather *tlb;
-};
-
 /*
  * Any behaviour which results in changes to the vma->vm_flags needs to
  * take mmap_sem for writing. Others, which simply traverse vmas, need
@@ -269,10 +264,9 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 				unsigned long end, struct mm_walk *walk)
 
 {
-	struct madvise_free_private *fp = walk->private;
-	struct mmu_gather *tlb = fp->tlb;
+	struct mmu_gather *tlb = walk->private;
 	struct mm_struct *mm = tlb->mm;
-	struct vm_area_struct *vma = fp->vma;
+	struct vm_area_struct *vma = walk->vma;
 	spinlock_t *ptl;
 	pte_t *pte, ptent;
 	struct page *page;
@@ -365,15 +359,10 @@ static void madvise_free_page_range(struct mmu_gather *tlb,
 			     struct vm_area_struct *vma,
 			     unsigned long addr, unsigned long end)
 {
-	struct madvise_free_private fp = {
-		.vma = vma,
-		.tlb = tlb,
-	};
-
 	struct mm_walk free_walk = {
 		.pmd_entry = madvise_free_pte_range,
 		.mm = vma->vm_mm,
-		.private = &fp,
+		.private = tlb,
 	};
 
 	BUG_ON(addr >= end);
diff --git a/mm/rmap.c b/mm/rmap.c
index 6f0f9331a20f..94ee372e238b 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1380,7 +1380,6 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	spinlock_t *ptl;
 	int ret = SWAP_AGAIN;
 	enum ttu_flags flags = (enum ttu_flags)arg;
-	int dirty = 0;
 
 	pte = page_check_address(page, mm, address, &ptl, 0);
 	if (!pte)
@@ -1423,8 +1422,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	}
 
 	/* Move the dirty bit to the physical page now the pte is gone. */
-	dirty = pte_dirty(pteval);
-	if (dirty)
+	if (pte_dirty(pteval))
 		set_page_dirty(page);
 
 	/* Update high watermark before we lower rss */
@@ -1457,7 +1455,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 
 		if (flags & TTU_FREE) {
 			VM_BUG_ON_PAGE(PageSwapCache(page), page);
-			if (!dirty && !PageDirty(page)) {
+			if (!PageDirty(page)) {
 				/* It's a freeable page by MADV_FREE */
 				dec_mm_counter(mm, MM_ANONPAGES);
 				goto discard;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
