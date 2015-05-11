Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id BE9EF6B0071
	for <linux-mm@kvack.org>; Mon, 11 May 2015 10:36:06 -0400 (EDT)
Received: by wicmc15 with SMTP id mc15so29753663wic.1
        for <linux-mm@kvack.org>; Mon, 11 May 2015 07:36:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bj3si123948wib.3.2015.05.11.07.36.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 11 May 2015 07:36:03 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 1/4] mm, thp: stop preallocating hugepages in khugepaged
Date: Mon, 11 May 2015 16:35:37 +0200
Message-Id: <1431354940-30740-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1431354940-30740-1-git-send-email-vbabka@suse.cz>
References: <1431354940-30740-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

Khugepaged tries to preallocate a hugepage before scanning for THP collapse
candidates. If the preallocation fails, scanning is not attempted. This makes
sense, but it is only restricted to !NUMA configurations, where it does not
need to predict on which node to preallocate.

Besides the !NUMA restriction, the preallocated page may also end up being
unused and put back when no collapse candidate is found. I have observed the
thp_collapse_alloc vmstat counter to have 3+ times the value of the counter
of actually collapsed pages in /sys/.../khugepaged/pages_collapsed. On the
other hand, the periodic hugepage allocation attempts involving sync
compaction can be beneficial for the antifragmentation mechanism, but that's
however harder to evaluate.

The following patch will introduce per-node THP availability tracking, which
has more benefits than current preallocation and is applicable to CONFIG_NUMA.
We can therefore remove the preallocation, which also allows a cleanup of the
functions involved in khugepaged allocations. Another small benefit of the
patch is that NUMA configs can now reuse an allocated hugepage for another
collapse attempt, if the previous one was for the same node and failed.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/huge_memory.c | 150 ++++++++++++++++++++-----------------------------------
 1 file changed, 53 insertions(+), 97 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 078832c..565864b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -765,9 +765,9 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 	return 0;
 }
 
-static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)
+static inline gfp_t alloc_hugepage_gfpmask(int defrag)
 {
-	return (GFP_TRANSHUGE & ~(defrag ? 0 : __GFP_WAIT)) | extra_gfp;
+	return (GFP_TRANSHUGE & ~(defrag ? 0 : __GFP_WAIT));
 }
 
 /* Caller must hold page table lock. */
@@ -825,7 +825,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 		return 0;
 	}
-	gfp = alloc_hugepage_gfpmask(transparent_hugepage_defrag(vma), 0);
+	gfp = alloc_hugepage_gfpmask(transparent_hugepage_defrag(vma));
 	page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
 	if (unlikely(!page)) {
 		count_vm_event(THP_FAULT_FALLBACK);
@@ -1116,7 +1116,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 alloc:
 	if (transparent_hugepage_enabled(vma) &&
 	    !transparent_hugepage_debug_cow()) {
-		huge_gfp = alloc_hugepage_gfpmask(transparent_hugepage_defrag(vma), 0);
+		huge_gfp = alloc_hugepage_gfpmask(transparent_hugepage_defrag(vma));
 		new_page = alloc_hugepage_vma(huge_gfp, vma, haddr, HPAGE_PMD_ORDER);
 	} else
 		new_page = NULL;
@@ -2318,39 +2318,41 @@ static int khugepaged_find_target_node(void)
 	return target_node;
 }
 
-static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
+static inline struct page *alloc_hugepage_node(gfp_t gfp, int node)
 {
-	if (IS_ERR(*hpage)) {
-		if (!*wait)
-			return false;
-
-		*wait = false;
-		*hpage = NULL;
-		khugepaged_alloc_sleep();
-	} else if (*hpage) {
-		put_page(*hpage);
-		*hpage = NULL;
-	}
-
-	return true;
+	gfp |= __GFP_THISNODE | __GFP_OTHER_NODE;
+	return alloc_pages_exact_node(node, gfp, HPAGE_PMD_ORDER);
+}
+#else
+static int khugepaged_find_target_node(void)
+{
+	return 0;
 }
 
-static struct page *
-khugepaged_alloc_page(struct page **hpage, gfp_t gfp, struct mm_struct *mm,
-		       struct vm_area_struct *vma, unsigned long address,
-		       int node)
+static inline struct page *alloc_hugepage_node(gfp_t gfp, int node)
 {
-	VM_BUG_ON_PAGE(*hpage, *hpage);
+	return alloc_pages(gfp, HPAGE_PMD_ORDER);
+}
+#endif
 
+static struct page
+*khugepaged_alloc_page(struct page **hpage, gfp_t gfp, int node)
+{
 	/*
-	 * Before allocating the hugepage, release the mmap_sem read lock.
-	 * The allocation can take potentially a long time if it involves
-	 * sync compaction, and we do not need to hold the mmap_sem during
-	 * that. We will recheck the vma after taking it again in write mode.
+	 * If we allocated a hugepage previously and failed to collapse, reuse
+	 * the page, unless it's on different NUMA node.
 	 */
-	up_read(&mm->mmap_sem);
+	if (!IS_ERR_OR_NULL(*hpage)) {
+		if (IS_ENABLED(CONFIG_NUMA) && page_to_nid(*hpage) != node) {
+			put_page(*hpage);
+			*hpage = NULL;
+		} else {
+			return *hpage;
+		}
+	}
+
+	*hpage = alloc_hugepage_node(gfp, node);
 
-	*hpage = alloc_pages_exact_node(node, gfp, HPAGE_PMD_ORDER);
 	if (unlikely(!*hpage)) {
 		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 		*hpage = ERR_PTR(-ENOMEM);
@@ -2360,60 +2362,6 @@ khugepaged_alloc_page(struct page **hpage, gfp_t gfp, struct mm_struct *mm,
 	count_vm_event(THP_COLLAPSE_ALLOC);
 	return *hpage;
 }
-#else
-static int khugepaged_find_target_node(void)
-{
-	return 0;
-}
-
-static inline struct page *alloc_hugepage(int defrag)
-{
-	return alloc_pages(alloc_hugepage_gfpmask(defrag, 0),
-			   HPAGE_PMD_ORDER);
-}
-
-static struct page *khugepaged_alloc_hugepage(bool *wait)
-{
-	struct page *hpage;
-
-	do {
-		hpage = alloc_hugepage(khugepaged_defrag());
-		if (!hpage) {
-			count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
-			if (!*wait)
-				return NULL;
-
-			*wait = false;
-			khugepaged_alloc_sleep();
-		} else
-			count_vm_event(THP_COLLAPSE_ALLOC);
-	} while (unlikely(!hpage) && likely(khugepaged_enabled()));
-
-	return hpage;
-}
-
-static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
-{
-	if (!*hpage)
-		*hpage = khugepaged_alloc_hugepage(wait);
-
-	if (unlikely(!*hpage))
-		return false;
-
-	return true;
-}
-
-static struct page *
-khugepaged_alloc_page(struct page **hpage, gfp_t gfp, struct mm_struct *mm,
-		       struct vm_area_struct *vma, unsigned long address,
-		       int node)
-{
-	up_read(&mm->mmap_sem);
-	VM_BUG_ON(!*hpage);
-
-	return  *hpage;
-}
-#endif
 
 static bool hugepage_vma_check(struct vm_area_struct *vma)
 {
@@ -2449,17 +2397,25 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 
-	/* Only allocate from the target node */
-	gfp = alloc_hugepage_gfpmask(khugepaged_defrag(), __GFP_OTHER_NODE) |
-		__GFP_THISNODE;
+	/* 
+	 * Determine the flags relevant for both hugepage allocation and memcg
+	 * charge. Hugepage allocation may still add __GFP_THISNODE and
+	 * __GFP_OTHER_NODE, which memcg ignores.
+	 */
+	gfp = alloc_hugepage_gfpmask(khugepaged_defrag());
 
-	/* release the mmap_sem read lock. */
-	new_page = khugepaged_alloc_page(hpage, gfp, mm, vma, address, node);
+	/*
+	 * Before allocating the hugepage, release the mmap_sem read lock.
+	 * The allocation can take potentially a long time if it involves
+	 * sync compaction, and we do not need to hold the mmap_sem during
+	 * that. We will recheck the vma after taking it again in write mode.
+	 */
+	up_read(&mm->mmap_sem);
+	new_page = khugepaged_alloc_page(hpage, gfp, node);
 	if (!new_page)
 		return;
 
-	if (unlikely(mem_cgroup_try_charge(new_page, mm,
-					   gfp, &memcg)))
+	if (unlikely(mem_cgroup_try_charge(new_page, mm, gfp, &memcg)))
 		return;
 
 	/*
@@ -2788,15 +2744,9 @@ static void khugepaged_do_scan(void)
 {
 	struct page *hpage = NULL;
 	unsigned int progress = 0, pass_through_head = 0;
-	unsigned int pages = khugepaged_pages_to_scan;
-	bool wait = true;
-
-	barrier(); /* write khugepaged_pages_to_scan to local stack */
+	unsigned int pages = READ_ONCE(khugepaged_pages_to_scan);
 
 	while (progress < pages) {
-		if (!khugepaged_prealloc_page(&hpage, &wait))
-			break;
-
 		cond_resched();
 
 		if (unlikely(kthread_should_stop() || freezing(current)))
@@ -2812,6 +2762,12 @@ static void khugepaged_do_scan(void)
 		else
 			progress = pages;
 		spin_unlock(&khugepaged_mm_lock);
+
+		/* THP allocation has failed during collapse */
+		if (IS_ERR(hpage)) {
+			khugepaged_alloc_sleep();
+			break;
+		}
 	}
 
 	if (!IS_ERR_OR_NULL(hpage))
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
