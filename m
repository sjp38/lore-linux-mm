Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6D7B36B004F
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 07:17:12 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 02/19] Do not sanity check order in the fast path
Date: Tue, 24 Feb 2009 12:16:58 +0000
Message-Id: <1235477835-14500-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1235477835-14500-1-git-send-email-mel@csn.ul.ie>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

No user of the allocator API should be passing in an order >= MAX_ORDER
but we check for it on each and every allocation. Delete this check and
make it a VM_BUG_ON check further down the call path.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
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
index 61051d5..c3842f8 100644
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
