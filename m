Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id CA7476B0032
	for <linux-mm@kvack.org>; Thu,  2 Apr 2015 21:41:20 -0400 (EDT)
Received: by ierf6 with SMTP id f6so82240246ier.2
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 18:41:20 -0700 (PDT)
Received: from mail-ie0-x234.google.com (mail-ie0-x234.google.com. [2607:f8b0:4001:c03::234])
        by mx.google.com with ESMTPS id kd1si500517igb.41.2015.04.02.18.41.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Apr 2015 18:41:20 -0700 (PDT)
Received: by iebmp1 with SMTP id mp1so75325255ieb.0
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 18:41:20 -0700 (PDT)
Date: Thu, 2 Apr 2015 18:41:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, memcg: sync allocation and memcg charge gfp flags for
 thp fix fix
In-Reply-To: <20150318161407.GP17241@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1504021836180.20229@chino.kir.corp.google.com>
References: <1426514892-7063-1-git-send-email-mhocko@suse.cz> <55098D0A.8090605@suse.cz> <20150318150257.GL17241@dhcp22.suse.cz> <55099C72.1080102@suse.cz> <20150318155905.GO17241@dhcp22.suse.cz> <5509A31C.3070108@suse.cz>
 <20150318161407.GP17241@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

"mm, memcg: sync allocation and memcg charge gfp flags for THP" in -mm 
introduces a formal to pass the gfp mask for khugepaged's hugepage 
allocation.  This is just too ugly to live.

alloc_hugepage_gfpmask() cannot differ between NUMA and UMA configs by 
anything in GFP_RECLAIM_MASK, which is the only thing that matters for 
memcg reclaim, so just determine the gfp flags once in 
collapse_huge_page() and avoid the complexity.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 -mm: intended to be folded into
      mm-memcg-sync-allocation-and-memcg-charge-gfp-flags-for-thp.patch

 mm/huge_memory.c | 21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2373,16 +2373,12 @@ static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
 }
 
 static struct page *
-khugepaged_alloc_page(struct page **hpage, gfp_t *gfp, struct mm_struct *mm,
+khugepaged_alloc_page(struct page **hpage, gfp_t gfp, struct mm_struct *mm,
 		       struct vm_area_struct *vma, unsigned long address,
 		       int node)
 {
 	VM_BUG_ON_PAGE(*hpage, *hpage);
 
-	/* Only allocate from the target node */
-	*gfp = alloc_hugepage_gfpmask(khugepaged_defrag(), __GFP_OTHER_NODE) |
-	        __GFP_THISNODE;
-
 	/*
 	 * Before allocating the hugepage, release the mmap_sem read lock.
 	 * The allocation can take potentially a long time if it involves
@@ -2391,7 +2387,7 @@ khugepaged_alloc_page(struct page **hpage, gfp_t *gfp, struct mm_struct *mm,
 	 */
 	up_read(&mm->mmap_sem);
 
-	*hpage = alloc_pages_exact_node(node, *gfp, HPAGE_PMD_ORDER);
+	*hpage = alloc_pages_exact_node(node, gfp, HPAGE_PMD_ORDER);
 	if (unlikely(!*hpage)) {
 		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 		*hpage = ERR_PTR(-ENOMEM);
@@ -2445,18 +2441,13 @@ static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
 }
 
 static struct page *
-khugepaged_alloc_page(struct page **hpage, gfp_t *gfp, struct mm_struct *mm,
+khugepaged_alloc_page(struct page **hpage, gfp_t gfp, struct mm_struct *mm,
 		       struct vm_area_struct *vma, unsigned long address,
 		       int node)
 {
 	up_read(&mm->mmap_sem);
 	VM_BUG_ON(!*hpage);
 
-	/*
-	 * khugepaged_alloc_hugepage is doing the preallocation, use the same
-	 * gfp flags here.
-	 */
-	*gfp = alloc_hugepage_gfpmask(khugepaged_defrag(), 0);
 	return  *hpage;
 }
 #endif
@@ -2495,8 +2486,12 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 
+	/* Only allocate from the target node */
+	gfp = alloc_hugepage_gfpmask(khugepaged_defrag(), __GFP_OTHER_NODE) |
+		__GFP_THISNODE;
+
 	/* release the mmap_sem read lock. */
-	new_page = khugepaged_alloc_page(hpage, &gfp, mm, vma, address, node);
+	new_page = khugepaged_alloc_page(hpage, gfp, mm, vma, address, node);
 	if (!new_page)
 		return;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
