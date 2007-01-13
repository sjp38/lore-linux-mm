From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:49:28 +1100
Message-Id: <20070113024928.29682.73228.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 9/12] Alternate page table implementation cont...
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH GPT 09
 * Continue adding GPT implementation

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 pt-gpt-core.c |  171 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 171 insertions(+)
Index: linux-2.6.20-rc1/mm/pt-gpt-core.c
===================================================================
--- linux-2.6.20-rc1.orig/mm/pt-gpt-core.c	2007-01-03 15:46:46.657271000 +1100
+++ linux-2.6.20-rc1/mm/pt-gpt-core.c	2007-01-03 15:57:35.539309000 +1100
@@ -429,3 +429,174 @@
 	}
 	return found;
 }
+
+/******************
+* Local functions *
+******************/
+
+static inline void
+gpt_iterator_inspect_init_all(gpt_iterator_t* iterator_r, gpt_t* trie_p)
+{
+	iterator_r->coverage = GPT_KEY_LENGTH_MAX;
+	iterator_r->depth = 0;
+	iterator_r->finished = 0;
+	iterator_r->key = gpt_key_null();
+	iterator_r->node_p = trie_p;
+}
+
+static inline void
+gpt_iterator_inspect_init_range(gpt_iterator_t* iterator_r, gpt_t* trie_p,
+                                unsigned long addr, unsigned long end)
+{
+	gpt_iterator_inspect_init_all(iterator_r, trie_p);
+	iterator_r->start = extract_key(addr);
+	iterator_r->limit = extract_key(end-1);
+}
+
+static inline int
+gpt_iterator_inspect_leaves_range(gpt_iterator_t* iterator_u, gpt_key_t* key_r,
+                                  gpt_node_t** node_p_r)
+{
+	int found = 0;
+	gpt_node_t node;
+
+	/* Find the next node. */
+	while(!found && iterator_u->node_p) {
+		node = gpt_node_get(iterator_u->node_p);
+		switch(gpt_node_type(node)) {
+		case GPT_NODE_TYPE_INTERNAL:
+			gpt_iterator_internal_skip_range(iterator_u);
+			break;
+		case GPT_NODE_TYPE_LEAF:
+			found = gpt_iterator_leaf_visit_range(iterator_u, key_r,
+												  node_p_r);
+			break;
+		case GPT_NODE_TYPE_INVALID:
+			gpt_iterator_terminal_skip_range(iterator_u);
+			break;
+		default:
+			panic("Should never get here!");
+		}
+	}
+	return found;
+}
+
+static inline int
+gpt_iterator_free_pgtables(gpt_iterator_t* iterator_u, gpt_node_t** node_p_r,
+                           unsigned long floor, unsigned long ceiling)
+{
+	int found = 0;
+	gpt_node_t node;
+
+	while(!found && iterator_u->node_p) {
+		node = gpt_node_get(iterator_u->node_p);
+		switch(gpt_node_type(node)) {
+		case GPT_NODE_TYPE_INTERNAL:
+			found = gpt_iterator_internal_free_pgtables(iterator_u,
+								node_p_r, floor, ceiling);
+			break;
+		case GPT_NODE_TYPE_LEAF:
+		case GPT_NODE_TYPE_INVALID:
+			gpt_iterator_terminal_free_pgtables(iterator_u);
+			break;
+		default:
+			panic("Should never get here!");
+		}
+	}
+	return found;
+}
+
+/** awiggins (2006-09-18): Two problems to deal with with this implementation:
+ *    - Don't properly determine when an internal level should be freed.
+ *    - We should skip visiting leaf nodes, ie when we have levels that
+ *      can ONLY contain leaf nodes don't traverse any further.
+ */
+static inline int
+gpt_iterator_inspect_internals_all(gpt_iterator_t* iterator_u, gpt_key_t* key_r,
+                                   gpt_node_t** node_p_r)
+{
+	int found = 0;
+	gpt_node_t node;
+
+	/* Find the next node. */
+	while(!found && iterator_u->node_p) {
+		node = gpt_node_get(iterator_u->node_p);
+		switch(gpt_node_type(node)) {
+		case GPT_NODE_TYPE_INTERNAL:
+			gpt_iterator_internal_visit_all(iterator_u, key_r,
+											node_p_r);
+			break;
+		case GPT_NODE_TYPE_LEAF:
+		case GPT_NODE_TYPE_INVALID:
+			gpt_iterator_terminal_skip_all(iterator_u);
+			break;
+		default:
+			panic("Should never get here!");
+		}
+	}
+	return found;
+}
+
+static inline int
+gpt_iterator_leaf_visit_range(gpt_iterator_t* iterator_u, gpt_key_t* key_r,
+                              gpt_node_t** node_p_r)
+{
+	int found = 0;
+	int8_t replication;
+
+	switch(gpt_iterator_check_bounds(iterator_u, &replication)) {
+	case GPT_ITERATOR_INRANGE:
+		gpt_iterator_return(*iterator_u, key_r, node_p_r);
+		found = 1;
+		/* Fall through to update current. */
+	case GPT_ITERATOR_START:
+		gpt_iterator_inspect_next(iterator_u, replication);
+		break;
+	case GPT_ITERATOR_LIMIT:
+		iterator_u->node_p = NULL;
+		break;
+	default:
+		panic("Should never get here!");
+	}
+	return found;
+}
+
+static inline int
+gpt_iterator_internal_free_pgtables(gpt_iterator_t* iterator_u,
+                                    gpt_node_t**node_p_r,
+                                    unsigned long floor, unsigned long ceiling)
+{
+	int8_t replication;
+	gpt_key_t key, guard;
+	gpt_node_t* node_temp_p;
+
+	/* Process node once children have been processed. */
+	// DEBUG [
+	if(iterator_u->depth == 0) {
+		printk("Root");
+	}
+	gpt_iterator_return(*iterator_u, &key, &node_temp_p);
+	guard = gpt_node_read_guard(gpt_node_get(node_temp_p));
+	printk("\tinternal node (0x%lx, %d) guard (0x%lx, %d)",
+		   gpt_key_read_value(key), gpt_key_read_length(key),
+		   gpt_key_read_value(guard), gpt_key_read_length(guard));
+	printk((iterator_u->finished) ? "U\n" : "D\n");
+	// DEBUG ]
+	if(iterator_u->finished) {
+		// gpt_iterator_return(*iterator_u, &key, node_p_r);
+		//if(ceiling-1 /* inside internal using key*/) {
+		//        iterator_u->node_p = NULL; // Finished.
+		//        return 0;
+		//}
+		gpt_iterator_inspect_next(iterator_u, 0);
+		//return (floor /* inside internal using key*/) {
+		//        return 0;
+		//}
+		return 0; // Ignore then for now while debugging.
+	}
+	// add code to skip over levels containing only leaves.
+	gpt_iterator_check_bounds(iterator_u, &replication); // updates key.
+	/* If guard is in range process child nodes if guard. */
+	gpt_iterator_inspect_push_range(iterator_u);
+	return 0;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
