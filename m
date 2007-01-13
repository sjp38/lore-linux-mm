From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:49:23 +1100
Message-Id: <20070113024923.29682.25769.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 8/12] Alternate page table implementation cont...
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH GPT 08
 * Continue adding GPT implementation.

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 pt-gpt-core.c |  150 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 150 insertions(+)
Index: linux-2.6.20-rc1/mm/pt-gpt-core.c
===================================================================
--- linux-2.6.20-rc1.orig/mm/pt-gpt-core.c	2007-01-03 15:42:21.973271000 +1100
+++ linux-2.6.20-rc1/mm/pt-gpt-core.c	2007-01-03 15:46:46.657271000 +1100
@@ -279,3 +279,153 @@
 	return 0; /* Deletion/insertion window dose not cover root node. */
 }
 
+int
+gpt_node_delete(int is_root, gpt_thunk_t update_thunk)
+{
+	int error;
+	int8_t coverage;
+	gpt_node_t delete_node, update_node;
+	gpt_thunk_t delete_thunk = update_thunk;
+
+	/* Traverse update-node to delete-node. */
+	if(gpt_node_internal_traverse(&delete_thunk) != GPT_TRAVERSED_FULL) {
+		delete_thunk.key = update_thunk.key;
+	}
+	/* Is delete-key is inside a super-keyed leaf? */
+	delete_node = gpt_node_get(delete_thunk.node_p);
+	if((gpt_node_type(delete_node) == GPT_NODE_TYPE_LEAF) &&
+	   (coverage = gpt_node_leaf_read_coverage(delete_node) > 0)) {
+		/* Adjust lookup key, and retry traverse to delete-node. */
+		gptKeyCutLSB(coverage, &(update_thunk.key), NULL);
+		delete_thunk = update_thunk;
+		if(gpt_node_internal_traverse(&delete_thunk) !=
+		   GPT_TRAVERSED_FULL) {
+			delete_thunk.key = update_thunk.key;
+		}
+		delete_node = gpt_node_get(delete_thunk.node_p);
+	}
+	/* Delete node. */
+	switch(gpt_node_type(delete_node)) {
+	case GPT_NODE_TYPE_INVALID:
+		return GPT_NOT_FOUND;
+	case GPT_NODE_TYPE_LEAF:
+		error = gpt_node_delete_single(delete_thunk, delete_node);
+		break;
+	case GPT_NODE_TYPE_INTERNAL:
+		error = gpt_node_internal_delete(delete_thunk, delete_node);
+		break;
+	default: return GPT_NOT_FOUND;
+	}
+	if(error < 0) {
+		return error;
+	}
+	/* Decrement update-node's valid children count and return coverage. */
+	if(!is_root) {
+		update_node = gpt_node_get(update_thunk.node_p);
+		gpt_node_set(update_thunk.node_p,
+					 gpt_node_internal_dec_children(update_node));
+	}
+	return error;
+}
+
+int
+gpt_node_insert(gpt_node_t new_node, gpt_thunk_t update_thunk)
+{
+	int error;
+	gpt_node_t update_node, insert_node;
+	gpt_thunk_t insert_thunk = update_thunk;
+
+	/* Traverse to insertion point. */
+	if(gpt_node_internal_traverse(&insert_thunk) != GPT_TRAVERSED_FULL)
+			insert_thunk.key = update_thunk.key;
+
+	/* Insert new node. */
+	insert_node = gpt_node_get(insert_thunk.node_p);
+	switch(gpt_node_type(insert_node)) {
+	case GPT_NODE_TYPE_INVALID:
+		gpt_node_insert_single(new_node, insert_thunk);
+		break;
+	case GPT_NODE_TYPE_LEAF:
+		return GPT_OCCUPIED;
+	case GPT_NODE_TYPE_INTERNAL:
+		error = gpt_node_insert_replicate(new_node, insert_thunk,
+                                                  insert_node);
+		if(error < 0) {
+			return error;
+		}
+		break;
+	default:
+		return GPT_FAILED;
+	}
+
+	/* Increment update-node's valid children count and return. */
+	update_node = gpt_node_get(update_thunk.node_p);
+	if(gpt_node_type(update_node) == GPT_NODE_TYPE_INTERNAL) {
+		gpt_node_set(update_thunk.node_p,
+					 gpt_node_internal_inc_children(update_node));
+	}
+	return GPT_OK;
+}
+
+gpt_traversed_t
+gpt_node_internal_traverse(gpt_thunk_t* thunk_u)
+{
+	gpt_key_t guard, key_msb;
+	gpt_node_t node;
+	gpt_node_t* level;
+	gpt_key_value_t level_index;
+	int8_t guard_length, key_length, level_order;
+
+	/* Check for internal node, match guard for key stripping match. */
+	node = gpt_node_get(thunk_u->node_p);
+	if(gpt_node_type(node) != GPT_NODE_TYPE_INTERNAL) {
+		return GPT_TRAVERSED_NONE;
+	}
+	guard = gpt_node_read_guard(node);
+	level = gpt_node_internal_read_ptr(node);
+	level_order = gpt_node_internal_read_order(node);
+	guard_length = gpt_key_read_length(guard);
+	gptKeyCutMSB(guard_length, &(thunk_u->key), &key_msb);
+	if(!gptKeysCompareEqual(guard, key_msb)) {
+		return GPT_TRAVERSED_MISMATCH;
+	}
+	/* Index internal node's level with key stripping index. */
+	gptKeyCutMSB(level_order, &(thunk_u->key), &key_msb);
+	level_index = gpt_key_read_value(key_msb);
+	key_length = gpt_key_read_length(key_msb);
+	if(key_length != level_order) {
+		return GPT_TRAVERSED_GUARD;
+	}
+	/* Return next node. */
+	thunk_u->node_p = level + level_index;
+	return GPT_TRAVERSED_FULL;
+}
+
+int
+gpt_iterator_inspect(gpt_iterator_t* iterator_u, gpt_key_t* key_r,
+                     gpt_node_t** node_p_r)
+{
+	int found = 0;
+	gpt_node_t node;
+
+	/* Find the next node. */
+	while(!found && iterator_u->node_p) {
+		node = gpt_node_get(iterator_u->node_p);
+		switch(gpt_node_type(node)) {
+		case GPT_NODE_TYPE_INTERNAL:
+			found = gpt_iterator_internal(iterator_u, key_r,
+										  node_p_r);
+			break;
+		case GPT_NODE_TYPE_LEAF:
+			found = gpt_iterator_leaf(iterator_u, key_r, node_p_r);
+			break;
+		case GPT_NODE_TYPE_INVALID:
+			found = gpt_iterator_invalid(iterator_u, key_r,
+										 node_p_r);
+			break;
+		default:
+			panic("Should never get here!");
+		}
+	}
+	return found;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
