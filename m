Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 576B36B006E
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 07:59:25 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id h11so16657976wiw.3
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 04:59:24 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ec3si17538642wib.28.2015.02.23.04.59.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Feb 2015 04:59:20 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 3/6] mm, thp: try fault allocations only if we expect them to succeed
Date: Mon, 23 Feb 2015 13:58:39 +0100
Message-Id: <1424696322-21952-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1424696322-21952-1-git-send-email-vbabka@suse.cz>
References: <1424696322-21952-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

Since we check THP availability for khugepaged THP collapses, we can use it
also for page fault THP allocations. If khugepaged with its sync compaction
is not able to allocate a hugepage, then it's unlikely that the less involved
attempt on page fault would succeed.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/huge_memory.c | 39 ++++++++++++++++++++++++++++++---------
 1 file changed, 30 insertions(+), 9 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 55846b8..1eec1a6 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -761,6 +761,32 @@ static inline gfp_t alloc_hugepage_gfpmask(int defrag)
 	return (GFP_TRANSHUGE & ~(defrag ? 0 : __GFP_WAIT));
 }
 
+//TODO: inline? check bloat-o-meter
+static inline struct page *
+fault_alloc_hugepage(struct vm_area_struct *vma, unsigned long haddr)
+{
+	struct page *hpage;
+	gfp_t gfp;
+	int nid;
+
+	nid = numa_node_id();
+	/*
+	 * This check is not exact for interleave policy, but we can leave such
+	 * cases to later scanning.
+	 * TODO: should VM_HUGEPAGE madvised vma's proceed regardless of the check?
+	 */
+	if (!node_isset(nid, thp_avail_nodes))
+		return NULL;
+
+	gfp = alloc_hugepage_gfpmask(transparent_hugepage_defrag(vma));
+	hpage = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
+
+	if (!hpage)
+		node_clear(nid, thp_avail_nodes);
+
+	return hpage;
+}
+
 /* Caller must hold page table lock. */
 static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
 		struct vm_area_struct *vma, unsigned long haddr, pmd_t *pmd,
@@ -781,7 +807,6 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			       unsigned long address, pmd_t *pmd,
 			       unsigned int flags)
 {
-	gfp_t gfp;
 	struct page *page;
 	unsigned long haddr = address & HPAGE_PMD_MASK;
 
@@ -816,8 +841,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 		return 0;
 	}
-	gfp = alloc_hugepage_gfpmask(transparent_hugepage_defrag(vma));
-	page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
+	page = fault_alloc_hugepage(vma, haddr);
 	if (unlikely(!page)) {
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
@@ -1105,12 +1129,9 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	spin_unlock(ptl);
 alloc:
 	if (transparent_hugepage_enabled(vma) &&
-	    !transparent_hugepage_debug_cow()) {
-		gfp_t gfp;
-
-		gfp = alloc_hugepage_gfpmask(transparent_hugepage_defrag(vma));
-		new_page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
-	} else
+	    !transparent_hugepage_debug_cow())
+		new_page = fault_alloc_hugepage(vma, haddr);
+	else
 		new_page = NULL;
 
 	if (unlikely(!new_page)) {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
