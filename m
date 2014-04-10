Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 3A97D6B0037
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 13:59:18 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id cc10so5445023wib.10
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 10:59:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id qk5si1818998wjc.30.2014.04.10.10.59.16
        for <linux-mm@kvack.org>;
        Thu, 10 Apr 2014 10:59:16 -0700 (PDT)
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [PATCH 4/5] hugetlb: move helpers up in the file
Date: Thu, 10 Apr 2014 13:58:44 -0400
Message-Id: <1397152725-20990-5-git-send-email-lcapitulino@redhat.com>
In-Reply-To: <1397152725-20990-1-git-send-email-lcapitulino@redhat.com>
References: <1397152725-20990-1-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, riel@redhat.com, n-horiguchi@ah.jp.nec.com, kirill@shutemov.name

Next commit will add new code which will want to call
for_each_node_mask_to_alloc() macro. Move it, its buddy
for_each_node_mask_to_free() and their dependencies up in the file so
the new code can use them. This is just code movement, no logic change.

Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
 mm/hugetlb.c | 146 +++++++++++++++++++++++++++++------------------------------
 1 file changed, 73 insertions(+), 73 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 8cbaa97..6f1ca74 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -607,6 +607,79 @@ err:
 	return NULL;
 }
 
+/*
+ * common helper functions for hstate_next_node_to_{alloc|free}.
+ * We may have allocated or freed a huge page based on a different
+ * nodes_allowed previously, so h->next_node_to_{alloc|free} might
+ * be outside of *nodes_allowed.  Ensure that we use an allowed
+ * node for alloc or free.
+ */
+static int next_node_allowed(int nid, nodemask_t *nodes_allowed)
+{
+	nid = next_node(nid, *nodes_allowed);
+	if (nid == MAX_NUMNODES)
+		nid = first_node(*nodes_allowed);
+	VM_BUG_ON(nid >= MAX_NUMNODES);
+
+	return nid;
+}
+
+static int get_valid_node_allowed(int nid, nodemask_t *nodes_allowed)
+{
+	if (!node_isset(nid, *nodes_allowed))
+		nid = next_node_allowed(nid, nodes_allowed);
+	return nid;
+}
+
+/*
+ * returns the previously saved node ["this node"] from which to
+ * allocate a persistent huge page for the pool and advance the
+ * next node from which to allocate, handling wrap at end of node
+ * mask.
+ */
+static int hstate_next_node_to_alloc(struct hstate *h,
+					nodemask_t *nodes_allowed)
+{
+	int nid;
+
+	VM_BUG_ON(!nodes_allowed);
+
+	nid = get_valid_node_allowed(h->next_nid_to_alloc, nodes_allowed);
+	h->next_nid_to_alloc = next_node_allowed(nid, nodes_allowed);
+
+	return nid;
+}
+
+/*
+ * helper for free_pool_huge_page() - return the previously saved
+ * node ["this node"] from which to free a huge page.  Advance the
+ * next node id whether or not we find a free huge page to free so
+ * that the next attempt to free addresses the next node.
+ */
+static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
+{
+	int nid;
+
+	VM_BUG_ON(!nodes_allowed);
+
+	nid = get_valid_node_allowed(h->next_nid_to_free, nodes_allowed);
+	h->next_nid_to_free = next_node_allowed(nid, nodes_allowed);
+
+	return nid;
+}
+
+#define for_each_node_mask_to_alloc(hs, nr_nodes, node, mask)		\
+	for (nr_nodes = nodes_weight(*mask);				\
+		nr_nodes > 0 &&						\
+		((node = hstate_next_node_to_alloc(hs, mask)) || 1);	\
+		nr_nodes--)
+
+#define for_each_node_mask_to_free(hs, nr_nodes, node, mask)		\
+	for (nr_nodes = nodes_weight(*mask);				\
+		nr_nodes > 0 &&						\
+		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
+		nr_nodes--)
+
 static void update_and_free_page(struct hstate *h, struct page *page)
 {
 	int i;
@@ -786,79 +859,6 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
 	return page;
 }
 
-/*
- * common helper functions for hstate_next_node_to_{alloc|free}.
- * We may have allocated or freed a huge page based on a different
- * nodes_allowed previously, so h->next_node_to_{alloc|free} might
- * be outside of *nodes_allowed.  Ensure that we use an allowed
- * node for alloc or free.
- */
-static int next_node_allowed(int nid, nodemask_t *nodes_allowed)
-{
-	nid = next_node(nid, *nodes_allowed);
-	if (nid == MAX_NUMNODES)
-		nid = first_node(*nodes_allowed);
-	VM_BUG_ON(nid >= MAX_NUMNODES);
-
-	return nid;
-}
-
-static int get_valid_node_allowed(int nid, nodemask_t *nodes_allowed)
-{
-	if (!node_isset(nid, *nodes_allowed))
-		nid = next_node_allowed(nid, nodes_allowed);
-	return nid;
-}
-
-/*
- * returns the previously saved node ["this node"] from which to
- * allocate a persistent huge page for the pool and advance the
- * next node from which to allocate, handling wrap at end of node
- * mask.
- */
-static int hstate_next_node_to_alloc(struct hstate *h,
-					nodemask_t *nodes_allowed)
-{
-	int nid;
-
-	VM_BUG_ON(!nodes_allowed);
-
-	nid = get_valid_node_allowed(h->next_nid_to_alloc, nodes_allowed);
-	h->next_nid_to_alloc = next_node_allowed(nid, nodes_allowed);
-
-	return nid;
-}
-
-/*
- * helper for free_pool_huge_page() - return the previously saved
- * node ["this node"] from which to free a huge page.  Advance the
- * next node id whether or not we find a free huge page to free so
- * that the next attempt to free addresses the next node.
- */
-static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
-{
-	int nid;
-
-	VM_BUG_ON(!nodes_allowed);
-
-	nid = get_valid_node_allowed(h->next_nid_to_free, nodes_allowed);
-	h->next_nid_to_free = next_node_allowed(nid, nodes_allowed);
-
-	return nid;
-}
-
-#define for_each_node_mask_to_alloc(hs, nr_nodes, node, mask)		\
-	for (nr_nodes = nodes_weight(*mask);				\
-		nr_nodes > 0 &&						\
-		((node = hstate_next_node_to_alloc(hs, mask)) || 1);	\
-		nr_nodes--)
-
-#define for_each_node_mask_to_free(hs, nr_nodes, node, mask)		\
-	for (nr_nodes = nodes_weight(*mask);				\
-		nr_nodes > 0 &&						\
-		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
-		nr_nodes--)
-
 static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
 {
 	struct page *page;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
