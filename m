Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 252266B0055
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 11:29:06 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 02/25] Do not sanity check order in the fast path
Date: Fri, 20 Mar 2009 10:02:49 +0000
Message-Id: <1237543392-11797-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237543392-11797-1-git-send-email-mel@csn.ul.ie>
References: <1237543392-11797-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

No user of the allocator API should be passing in an order >= MAX_ORDER
but we check for it on each and every allocation. Delete this check and
make it a VM_BUG_ON check further down the call path.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
---
 include/linux/gfp.h |    6 ------
 mm/page_alloc.c     |    2 ++
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index dcf0ab8..8736047 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -181,9 +181,6 @@ __alloc_pages(gfp_t gfp_mask, unsigned int order,
 static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 						unsigned int order)
 {
-	if (unlikely(order >= MAX_ORDER))
-		return NULL;
-
 	/* Unknown node is current node */
 	if (nid < 0)
 		nid = numa_node_id();
@@ -197,9 +194,6 @@ extern struct page *alloc_pages_current(gfp_t gfp_mask, unsigned order);
 static inline struct page *
 alloc_pages(gfp_t gfp_mask, unsigned int order)
 {
-	if (unlikely(order >= MAX_ORDER))
-		return NULL;
-
 	return alloc_pages_current(gfp_mask, order);
 }
 extern struct page *alloc_page_vma(gfp_t gfp_mask,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0671b3f..dd87dad 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1407,6 +1407,8 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 
 	classzone_idx = zone_idx(preferred_zone);
 
+	VM_BUG_ON(order >= MAX_ORDER);
+
 zonelist_scan:
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
