Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id EE3656B0268
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 17:56:49 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id z24so7169412pgu.20
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 14:56:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f89sor4388624plb.112.2018.01.08.14.56.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jan 2018 14:56:48 -0800 (PST)
From: Yu Zhao <yuzhao@google.com>
Subject: [PATCH] mm: don't expose page to fast gup before it's ready
Date: Mon,  8 Jan 2018 14:56:32 -0800
Message-Id: <20180108225632.16332-1-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Yu Zhao <yuzhao@google.com>

We don't want to expose page before it's properly setup. During
page setup, we may call page_add_new_anon_rmap() which uses non-
atomic bit op. If page is exposed before it's done, we could
overwrite page flags that are set by get_user_pages_fast() or
it's callers. Here is a non-fatal scenario (there might be other
fatal problems that I didn't look into):

	CPU 1				CPU1
set_pte_at()			get_user_pages_fast()
page_add_new_anon_rmap()		gup_pte_range()
	__SetPageSwapBacked()			SetPageReferenced()

Fix the problem by delaying set_pte_at() until page is ready.

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 mm/memory.c   | 2 +-
 mm/swapfile.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index ca5674cbaff2..b8be1a4adf93 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3010,7 +3010,6 @@ int do_swap_page(struct vm_fault *vmf)
 	flush_icache_page(vma, page);
 	if (pte_swp_soft_dirty(vmf->orig_pte))
 		pte = pte_mksoft_dirty(pte);
-	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, pte);
 	vmf->orig_pte = pte;
 
 	/* ksm created a completely new copy */
@@ -3023,6 +3022,7 @@ int do_swap_page(struct vm_fault *vmf)
 		mem_cgroup_commit_charge(page, memcg, true, false);
 		activate_page(page);
 	}
+	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, pte);
 
 	swap_free(entry);
 	if (mem_cgroup_swap_full(page) ||
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 3074b02eaa09..bd49da2b5221 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1800,8 +1800,6 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
 	dec_mm_counter(vma->vm_mm, MM_SWAPENTS);
 	inc_mm_counter(vma->vm_mm, MM_ANONPAGES);
 	get_page(page);
-	set_pte_at(vma->vm_mm, addr, pte,
-		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
 	if (page == swapcache) {
 		page_add_anon_rmap(page, vma, addr, false);
 		mem_cgroup_commit_charge(page, memcg, true, false);
@@ -1810,6 +1808,8 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
 		mem_cgroup_commit_charge(page, memcg, false, false);
 		lru_cache_add_active_or_unevictable(page, vma);
 	}
+	set_pte_at(vma->vm_mm, addr, pte,
+		   pte_mkold(mk_pte(page, vma->vm_page_prot)));
 	swap_free(entry);
 	/*
 	 * Move the page to the active list so it is not
-- 
2.16.0.rc0.223.g4a4ac83678-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
