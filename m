Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 8BD1A6B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 20:59:34 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id fa1so587914pad.7
        for <linux-mm@kvack.org>; Fri, 25 Jan 2013 17:59:33 -0800 (PST)
Date: Fri, 25 Jan 2013 17:59:35 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 4/11] ksm: reorganize ksm_check_stable_tree
In-Reply-To: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
Message-ID: <alpine.LNX.2.00.1301251758190.29196@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Memory hotremove's ksm_check_stable_tree() is pitifully inefficient
(restarting whenever it finds a stale node to remove), but rearrange
so that at least it does not needlessly restart from nid 0 each time.
And add a couple of comments: here is why we keep pfn instead of page.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/ksm.c |   38 ++++++++++++++++++++++----------------
 1 file changed, 22 insertions(+), 16 deletions(-)

--- mmotm.orig/mm/ksm.c	2013-01-25 14:36:52.152205940 -0800
+++ mmotm/mm/ksm.c	2013-01-25 14:36:53.244205966 -0800
@@ -1830,31 +1830,36 @@ void ksm_migrate_page(struct page *newpa
 #endif /* CONFIG_MIGRATION */
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-static struct stable_node *ksm_check_stable_tree(unsigned long start_pfn,
-						 unsigned long end_pfn)
+static void ksm_check_stable_tree(unsigned long start_pfn,
+				  unsigned long end_pfn)
 {
+	struct stable_node *stable_node;
 	struct rb_node *node;
 	int nid;
 
-	for (nid = 0; nid < nr_node_ids; nid++)
-		for (node = rb_first(&root_stable_tree[nid]); node;
-				node = rb_next(node)) {
-			struct stable_node *stable_node;
-
+	for (nid = 0; nid < nr_node_ids; nid++) {
+		node = rb_first(&root_stable_tree[nid]);
+		while (node) {
 			stable_node = rb_entry(node, struct stable_node, node);
 			if (stable_node->kpfn >= start_pfn &&
-			    stable_node->kpfn < end_pfn)
-				return stable_node;
+			    stable_node->kpfn < end_pfn) {
+				/*
+				 * Don't get_ksm_page, page has already gone:
+				 * which is why we keep kpfn instead of page*
+				 */
+				remove_node_from_stable_tree(stable_node);
+				node = rb_first(&root_stable_tree[nid]);
+			} else
+				node = rb_next(node);
+			cond_resched();
 		}
-
-	return NULL;
+	}
 }
 
 static int ksm_memory_callback(struct notifier_block *self,
 			       unsigned long action, void *arg)
 {
 	struct memory_notify *mn = arg;
-	struct stable_node *stable_node;
 
 	switch (action) {
 	case MEM_GOING_OFFLINE:
@@ -1874,11 +1879,12 @@ static int ksm_memory_callback(struct no
 		/*
 		 * Most of the work is done by page migration; but there might
 		 * be a few stable_nodes left over, still pointing to struct
-		 * pages which have been offlined: prune those from the tree.
+		 * pages which have been offlined: prune those from the tree,
+		 * otherwise get_ksm_page() might later try to access a
+		 * non-existent struct page.
 		 */
-		while ((stable_node = ksm_check_stable_tree(mn->start_pfn,
-					mn->start_pfn + mn->nr_pages)) != NULL)
-			remove_node_from_stable_tree(stable_node);
+		ksm_check_stable_tree(mn->start_pfn,
+				      mn->start_pfn + mn->nr_pages);
 		/* fallthrough */
 
 	case MEM_CANCEL_OFFLINE:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
