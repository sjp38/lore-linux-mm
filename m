Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 97BCB9003CE
	for <linux-mm@kvack.org>; Thu,  2 Jul 2015 04:47:33 -0400 (EDT)
Received: by wicgi11 with SMTP id gi11so66891561wic.0
        for <linux-mm@kvack.org>; Thu, 02 Jul 2015 01:47:33 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ga6si8291738wib.68.2015.07.02.01.47.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Jul 2015 01:47:24 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 4/4] mm, thp: check hugepage availability for fault allocations
Date: Thu,  2 Jul 2015 10:46:35 +0200
Message-Id: <1435826795-13777-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1435826795-13777-1-git-send-email-vbabka@suse.cz>
References: <1435826795-13777-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

Since we track hugepage availability for khugepaged THP collapses, we can use
it also for page fault THP allocations. If hugepages are considered unavailable
on a node, the cost of reclaim/compaction during the page fault could be easily
higher than any THP benefits (if it at all succeeds), so we better fallback to
base pages instead.

We clear the THP availability flag for a node if we do attempt and fail to
allocate during page fault. Kcompactd is woken up both in the case of attempt
skipped due to assumed non-availability, and for the truly failed allocation.
This is to fully translate the need for hugepages into kcompactd activity.

With this patch we also set the availability flag if we are freeing a large
enough page from any context, to prevent false negatives after e.g. a process
quits and another immediately starts.  This does not consider high-order pages
created by buddy merging, as that would need modifying the fast path and is
unlikely to make much difference.

Note that in case of false-positive hugepage availability, the allocation
attempt may still result in a limited direct compaction, depending on
/sys/kernel/mm/transparent_hugepage/defrag which defaults to "always". The
default could be later changed to e.g. "madvise" to eliminate all of the page
fault latency related to THP and rely exlusively on kcompactd.

Also restructure alloc_pages_vma() a bit.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/mempolicy.c  | 42 +++++++++++++++++++++++++++---------------
 mm/page_alloc.c |  3 +++
 2 files changed, 30 insertions(+), 15 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 7477432..502e173 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -94,6 +94,7 @@
 #include <linux/mm_inline.h>
 #include <linux/mmu_notifier.h>
 #include <linux/printk.h>
+#include <linux/compaction.h>
 
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
@@ -1963,17 +1964,34 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
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
+		if (hugepage && !page) {
+			thp_avail_clear(nid);
+			wakeup_kcompactd(nid, true);
+		}
+		goto out;
+	}
+
+	nmask = policy_nodemask(gfp, pol);
+	if (hugepage) {
 		/*
 		 * For hugepage allocation and non-interleave policy which
 		 * allows the current node, we only try to allocate from the
@@ -1983,25 +2001,19 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
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
+			if (!page) {
+				thp_avail_clear(node);
+				wakeup_kcompactd(node, true);
+			}
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
index d9cd834..ccd87b2 100644
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
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
