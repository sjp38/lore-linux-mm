Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id CC5B16B0073
	for <linux-mm@kvack.org>; Mon, 11 May 2015 10:36:11 -0400 (EDT)
Received: by wief7 with SMTP id f7so87825508wie.0
        for <linux-mm@kvack.org>; Mon, 11 May 2015 07:36:11 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pi9si52122wic.96.2015.05.11.07.36.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 11 May 2015 07:36:03 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 3/4] mm, thp: try fault allocations only if we expect them to succeed
Date: Mon, 11 May 2015 16:35:39 +0200
Message-Id: <1431354940-30740-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1431354940-30740-1-git-send-email-vbabka@suse.cz>
References: <1431354940-30740-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

Since we track THP availability for khugepaged THP collapses, we can use it
also for page fault THP allocations. If khugepaged with its sync compaction
is not able to allocate a hugepage, then it's unlikely that the less involved
attempt on page fault would succeed, and the cost could be higher than THP
benefits. Also clear the THP availability flag if we do attempt and fail to
allocate during page fault, and set the flag if we are freeing a large enough
page from any context. The latter doesn't include merges, as that's a fast
path and unlikely to make much difference.

Also restructure alloc_pages_vma() a bit.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/huge_memory.c |  3 ++-
 mm/internal.h    | 39 +++++++++++++++++++++++++++++++++++++++
 mm/mempolicy.c   | 37 ++++++++++++++++++++++---------------
 mm/page_alloc.c  |  3 +++
 4 files changed, 66 insertions(+), 16 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b86a72a..d3081a7 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -102,7 +102,8 @@ struct khugepaged_scan {
 static struct khugepaged_scan khugepaged_scan = {
 	.mm_head = LIST_HEAD_INIT(khugepaged_scan.mm_head),
 };
-static nodemask_t thp_avail_nodes = NODE_MASK_ALL;
+
+nodemask_t thp_avail_nodes = NODE_MASK_ALL;
 
 static int set_recommended_min_free_kbytes(void)
 {
diff --git a/mm/internal.h b/mm/internal.h
index a25e359..6d9a711 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -162,6 +162,45 @@ extern bool is_free_buddy_page(struct page *page);
 #endif
 extern int user_min_free_kbytes;
 
+/*
+ * in mm/huge_memory.c
+ */
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+
+extern nodemask_t thp_avail_nodes;
+
+static inline bool thp_avail_isset(int nid)
+{
+	return node_isset(nid, thp_avail_nodes);
+}
+
+static inline void thp_avail_set(int nid)
+{
+	node_set(nid, thp_avail_nodes);
+}
+
+static inline void thp_avail_clear(int nid)
+{
+	node_clear(nid, thp_avail_nodes);
+}
+
+#else
+
+static inline bool thp_avail_isset(int nid)
+{
+	return true;
+}
+
+static inline void thp_avail_set(int nid)
+{
+}
+
+static inline void thp_avail_clear(int nid)
+{
+}
+
+#endif
+
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
 
 /*
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index ede2629..41923b0 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1963,17 +1963,32 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 		unsigned long addr, int node, bool hugepage)
 {
 	struct mempolicy *pol;
-	struct page *page;
+	struct page *page = NULL;
 	unsigned int cpuset_mems_cookie;
 	struct zonelist *zl;
 	nodemask_t *nmask;
 
+	/* Help compiler eliminate code */
+	hugepage = IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && hugepage;
+
 retry_cpuset:
 	pol = get_vma_policy(vma, addr);
 	cpuset_mems_cookie = read_mems_allowed_begin();
 
-	if (unlikely(IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && hugepage &&
-					pol->mode != MPOL_INTERLEAVE)) {
+	if (pol->mode == MPOL_INTERLEAVE) {
+		unsigned nid;
+
+		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
+		mpol_cond_put(pol);
+		if (!hugepage || thp_avail_isset(nid))
+			page = alloc_page_interleave(gfp, order, nid);
+		if (hugepage && !page)
+			thp_avail_clear(nid);
+		goto out;
+	}
+
+	nmask = policy_nodemask(gfp, pol);
+	if (hugepage) {
 		/*
 		 * For hugepage allocation and non-interleave policy which
 		 * allows the current node, we only try to allocate from the
@@ -1983,25 +1998,17 @@ retry_cpuset:
 		 * If the policy is interleave, or does not allow the current
 		 * node in its nodemask, we allocate the standard way.
 		 */
-		nmask = policy_nodemask(gfp, pol);
 		if (!nmask || node_isset(node, *nmask)) {
 			mpol_cond_put(pol);
-			page = alloc_pages_exact_node(node,
+			if (thp_avail_isset(node))
+				page = alloc_pages_exact_node(node,
 						gfp | __GFP_THISNODE, order);
+			if (!page)
+				thp_avail_clear(node);
 			goto out;
 		}
 	}
 
-	if (pol->mode == MPOL_INTERLEAVE) {
-		unsigned nid;
-
-		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
-		mpol_cond_put(pol);
-		page = alloc_page_interleave(gfp, order, nid);
-		goto out;
-	}
-
-	nmask = policy_nodemask(gfp, pol);
 	zl = policy_zonelist(gfp, pol, node);
 	mpol_cond_put(pol);
 	page = __alloc_pages_nodemask(gfp, order, zl, nmask);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ebffa0e..f7ff90e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -830,6 +830,9 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	set_freepage_migratetype(page, migratetype);
 	free_one_page(page_zone(page), page, pfn, order, migratetype);
 	local_irq_restore(flags);
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE)
+			&& order >= HPAGE_PMD_ORDER)
+		thp_avail_set(page_to_nid(page));
 }
 
 void __init __free_pages_bootmem(struct page *page, unsigned int order)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
