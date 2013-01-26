Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id AE2E36B0008
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 20:58:10 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fb1so578274pad.25
        for <linux-mm@kvack.org>; Fri, 25 Jan 2013 17:58:09 -0800 (PST)
Date: Fri, 25 Jan 2013 17:58:11 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 3/11] ksm: trivial tidyups
In-Reply-To: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
Message-ID: <alpine.LNX.2.00.1301251757020.29196@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Add NUMA() and DO_NUMA() macros to minimize blight of #ifdef CONFIG_NUMAs
(but indeed we don't want to expand struct rmap_item by nid when not NUMA).
Add comment, remove "unsigned" from rmap_item->nid, as "int nid" elsewhere.
Define ksm_merge_across_nodes 1U when #ifndef NUMA to help optimizing out.
Use ?: in get_kpfn_nid().  Adjust a few comments noticed in ongoing work.

Leave stable_tree_insert()'s rb_linkage until after the node has been set
up, as unstable_tree_search_insert() does: ksm_thread_mutex and page lock
make either way safe, but we're going to copy and I prefer this precedent.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/ksm.c |   48 ++++++++++++++++++++++--------------------------
 1 file changed, 22 insertions(+), 26 deletions(-)

--- mmotm.orig/mm/ksm.c	2013-01-25 14:36:38.608205618 -0800
+++ mmotm/mm/ksm.c	2013-01-25 14:36:52.152205940 -0800
@@ -41,6 +41,14 @@
 #include <asm/tlbflush.h>
 #include "internal.h"
 
+#ifdef CONFIG_NUMA
+#define NUMA(x)		(x)
+#define DO_NUMA(x)	(x)
+#else
+#define NUMA(x)		(0)
+#define DO_NUMA(x)	do { } while (0)
+#endif
+
 /*
  * A few notes about the KSM scanning process,
  * to make it easier to understand the data structures below:
@@ -130,6 +138,7 @@ struct stable_node {
  * @mm: the memory structure this rmap_item is pointing into
  * @address: the virtual address this rmap_item tracks (+ flags in low bits)
  * @oldchecksum: previous checksum of the page at that virtual address
+ * @nid: NUMA node id of unstable tree in which linked (may not match page)
  * @node: rb node of this rmap_item in the unstable tree
  * @head: pointer to stable_node heading this list in the stable tree
  * @hlist: link into hlist of rmap_items hanging off that stable_node
@@ -141,7 +150,7 @@ struct rmap_item {
 	unsigned long address;		/* + low bits used for flags below */
 	unsigned int oldchecksum;	/* when unstable */
 #ifdef CONFIG_NUMA
-	unsigned int nid;
+	int nid;
 #endif
 	union {
 		struct rb_node node;	/* when node of unstable tree */
@@ -192,8 +201,12 @@ static unsigned int ksm_thread_pages_to_
 /* Milliseconds ksmd should sleep between batches */
 static unsigned int ksm_thread_sleep_millisecs = 20;
 
+#ifdef CONFIG_NUMA
 /* Zeroed when merging across nodes is not allowed */
 static unsigned int ksm_merge_across_nodes = 1;
+#else
+#define ksm_merge_across_nodes	1U
+#endif
 
 #define KSM_RUN_STOP	0
 #define KSM_RUN_MERGE	1
@@ -456,10 +469,7 @@ out:		page = NULL;
  */
 static inline int get_kpfn_nid(unsigned long kpfn)
 {
-	if (ksm_merge_across_nodes)
-		return 0;
-	else
-		return pfn_to_nid(kpfn);
+	return ksm_merge_across_nodes ? 0 : pfn_to_nid(kpfn);
 }
 
 static void remove_node_from_stable_tree(struct stable_node *stable_node)
@@ -479,7 +489,6 @@ static void remove_node_from_stable_tree
 	}
 
 	nid = get_kpfn_nid(stable_node->kpfn);
-
 	rb_erase(&stable_node->node, &root_stable_tree[nid]);
 	free_stable_node(stable_node);
 }
@@ -578,13 +587,8 @@ static void remove_rmap_item_from_tree(s
 		age = (unsigned char)(ksm_scan.seqnr - rmap_item->address);
 		BUG_ON(age > 1);
 		if (!age)
-#ifdef CONFIG_NUMA
 			rb_erase(&rmap_item->node,
-					&root_unstable_tree[rmap_item->nid]);
-#else
-			rb_erase(&rmap_item->node, &root_unstable_tree[0]);
-#endif
-
+				 &root_unstable_tree[NUMA(rmap_item->nid)]);
 		ksm_pages_unshared--;
 		rmap_item->address &= PAGE_MASK;
 	}
@@ -604,7 +608,7 @@ static void remove_trailing_rmap_items(s
 }
 
 /*
- * Though it's very tempting to unmerge in_stable_tree(rmap_item)s rather
+ * Though it's very tempting to unmerge rmap_items from stable tree rather
  * than check every pte of a given vma, the locking doesn't quite work for
  * that - an rmap_item is assigned to the stable tree after inserting ksm
  * page and upping mmap_sem.  Nor does it fit with the way we skip dup'ing
@@ -1058,7 +1062,7 @@ static struct page *stable_tree_search(s
 }
 
 /*
- * stable_tree_insert - insert rmap_item pointing to new ksm page
+ * stable_tree_insert - insert stable tree node pointing to new ksm page
  * into the stable tree.
  *
  * This function returns the stable tree node just allocated on success,
@@ -1108,13 +1112,11 @@ static struct stable_node *stable_tree_i
 	if (!stable_node)
 		return NULL;
 
-	rb_link_node(&stable_node->node, parent, new);
-	rb_insert_color(&stable_node->node, &root_stable_tree[nid]);
-
 	INIT_HLIST_HEAD(&stable_node->hlist);
-
 	stable_node->kpfn = kpfn;
 	set_page_stable_node(kpage, stable_node);
+	rb_link_node(&stable_node->node, parent, new);
+	rb_insert_color(&stable_node->node, &root_stable_tree[nid]);
 
 	return stable_node;
 }
@@ -1170,8 +1172,6 @@ struct rmap_item *unstable_tree_search_i
 		 * If tree_page has been migrated to another NUMA node, it
 		 * will be flushed out and put into the right unstable tree
 		 * next time: only merge with it if merge_across_nodes.
-		 * Just notice, we don't have similar problem for PageKsm
-		 * because their migration is disabled now. (62b61f611e)
 		 */
 		if (!ksm_merge_across_nodes && page_to_nid(tree_page) != nid) {
 			put_page(tree_page);
@@ -1195,9 +1195,7 @@ struct rmap_item *unstable_tree_search_i
 
 	rmap_item->address |= UNSTABLE_FLAG;
 	rmap_item->address |= (ksm_scan.seqnr & SEQNR_MASK);
-#ifdef CONFIG_NUMA
-	rmap_item->nid = nid;
-#endif
+	DO_NUMA(rmap_item->nid = nid);
 	rb_link_node(&rmap_item->node, parent, new);
 	rb_insert_color(&rmap_item->node, root);
 
@@ -1213,13 +1211,11 @@ struct rmap_item *unstable_tree_search_i
 static void stable_tree_append(struct rmap_item *rmap_item,
 			       struct stable_node *stable_node)
 {
-#ifdef CONFIG_NUMA
 	/*
 	 * Usually rmap_item->nid is already set correctly,
 	 * but it may be wrong after switching merge_across_nodes.
 	 */
-	rmap_item->nid = get_kpfn_nid(stable_node->kpfn);
-#endif
+	DO_NUMA(rmap_item->nid = get_kpfn_nid(stable_node->kpfn));
 	rmap_item->head = stable_node;
 	rmap_item->address |= STABLE_FLAG;
 	hlist_add_head(&rmap_item->hlist, &stable_node->hlist);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
