Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id 138B76B0253
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 10:15:01 -0500 (EST)
Received: by oixx65 with SMTP id x65so10873972oix.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 07:15:00 -0800 (PST)
Received: from m50-135.163.com (m50-135.163.com. [123.125.50.135])
        by mx.google.com with ESMTP id h2si3294990oeq.93.2015.12.08.07.14.58
        for <linux-mm@kvack.org>;
        Tue, 08 Dec 2015 07:15:00 -0800 (PST)
From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH] mm/ksm.c: use list_for_each_entry_safe
Date: Tue,  8 Dec 2015 23:12:18 +0800
Message-Id: <cc05942081a468570047a00a08020faca477603b.1449587435.git.geliangtang@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jerome Marchand <jmarchan@redhat.com>
Cc: Geliang Tang <geliangtang@163.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Use list_for_each_entry_safe() instead of list_for_each_safe() to
simplify the code.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 mm/ksm.c | 20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 5e96753..ca6d2a0 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -726,8 +726,7 @@ static int remove_stable_node(struct stable_node *stable_node)
 
 static int remove_all_stable_nodes(void)
 {
-	struct stable_node *stable_node;
-	struct list_head *this, *next;
+	struct stable_node *stable_node, *next;
 	int nid;
 	int err = 0;
 
@@ -742,8 +741,7 @@ static int remove_all_stable_nodes(void)
 			cond_resched();
 		}
 	}
-	list_for_each_safe(this, next, &migrate_nodes) {
-		stable_node = list_entry(this, struct stable_node, list);
+	list_for_each_entry_safe(stable_node, next, &migrate_nodes, list) {
 		if (remove_stable_node(stable_node))
 			err = -EBUSY;
 		cond_resched();
@@ -1553,13 +1551,11 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 		 * so prune them once before each full scan.
 		 */
 		if (!ksm_merge_across_nodes) {
-			struct stable_node *stable_node;
-			struct list_head *this, *next;
+			struct stable_node *stable_node, *next;
 			struct page *page;
 
-			list_for_each_safe(this, next, &migrate_nodes) {
-				stable_node = list_entry(this,
-						struct stable_node, list);
+			list_for_each_entry_safe(stable_node, next,
+						 &migrate_nodes, list) {
 				page = get_ksm_page(stable_node, false);
 				if (page)
 					put_page(page);
@@ -1981,8 +1977,7 @@ static void wait_while_offlining(void)
 static void ksm_check_stable_tree(unsigned long start_pfn,
 				  unsigned long end_pfn)
 {
-	struct stable_node *stable_node;
-	struct list_head *this, *next;
+	struct stable_node *stable_node, *next;
 	struct rb_node *node;
 	int nid;
 
@@ -2003,8 +1998,7 @@ static void ksm_check_stable_tree(unsigned long start_pfn,
 			cond_resched();
 		}
 	}
-	list_for_each_safe(this, next, &migrate_nodes) {
-		stable_node = list_entry(this, struct stable_node, list);
+	list_for_each_entry_safe(stable_node, next, &migrate_nodes, list) {
 		if (stable_node->kpfn >= start_pfn &&
 		    stable_node->kpfn < end_pfn)
 			remove_node_from_stable_tree(stable_node);
-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
