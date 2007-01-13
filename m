From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:49:38 +1100
Message-Id: <20070113024938.29682.59700.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 11/12] Alternate page table implementation cont...
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH GPT 11
 * Continue adding GPT implementation

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 pt-gpt-core.c |  205 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 205 insertions(+)
Index: linux-2.6.20-rc1/mm/pt-gpt-core.c
===================================================================
--- linux-2.6.20-rc1.orig/mm/pt-gpt-core.c	2007-01-03 16:07:14.297584000 +1100
+++ linux-2.6.20-rc1/mm/pt-gpt-core.c	2007-01-03 16:11:35.005312000 +1100
@@ -819,3 +819,208 @@
 	}
 }
 
+static inline void
+gpt_iterator_inspect_pop(gpt_iterator_t* iterator_u)
+{
+	BUG_ON(iterator_u->depth <= 0);
+	iterator_u->node_p = iterator_u->stack[--(iterator_u->depth)];
+	iterator_u->finished = 1;
+}
+
+static inline gpt_node_t*
+gpt_iterator_parent(gpt_iterator_t iterator)
+{
+	return iterator.stack[iterator.depth - 1];
+}
+
+static inline void
+gpt_iterator_return(gpt_iterator_t iterator,
+                    gpt_key_t* key_r, gpt_node_t** node_p_r)
+{
+	if(key_r) {
+		*key_r = iterator.key;
+	}
+	if(node_p_r) {
+		*node_p_r = iterator.node_p;
+	}
+}
+
+static int
+gpt_iterator_internal(gpt_iterator_t* iterator_u, gpt_key_t* key_r,
+                      gpt_node_t** node_p_r)
+{
+	int found = 0;
+	int8_t replication;
+
+	/* Process node once children have been processed. */
+	if(iterator_u->finished) {
+		if(iterator_u->flags & GPT_ITERATE_INTERNALS) {
+			gpt_iterator_return(*iterator_u, key_r, node_p_r);
+			found = 1;
+		}
+		gpt_iterator_inspect_next(iterator_u, 0);
+		return found;
+	}
+	/* If guard is in range process child nodes if guard. */
+	switch(gpt_iterator_check_bounds(iterator_u, &replication)) {
+	case GPT_ITERATOR_INRANGE:
+		gpt_iterator_inspect_push_range(iterator_u);
+		break;
+	case GPT_ITERATOR_START:
+		if(replication != 0) {
+			panic("Internal nodes should not be replicated!");
+		}
+		gpt_iterator_inspect_next(iterator_u, 0);
+		break;
+	case GPT_ITERATOR_LIMIT:
+		iterator_u->node_p = NULL;
+		break;
+	default:
+		panic("Should never get here!");
+	}
+	return 0;
+}
+
+static int
+gpt_iterator_leaf(gpt_iterator_t* iterator_u, gpt_key_t* key_r,
+                  gpt_node_t** node_p_r)
+{
+	int found = 0;
+	int8_t replication;
+
+	switch(gpt_iterator_check_bounds(iterator_u, &replication)) {
+	case GPT_ITERATOR_INRANGE:
+		if(iterator_u->flags & GPT_ITERATE_LEAVES) {
+			gpt_iterator_return(*iterator_u, key_r, node_p_r);
+			found = 1;
+		}
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
+gpt_iterator_invalid(gpt_iterator_t* iterator_u, gpt_key_t* key_r,
+                     gpt_node_t** node_p_r)
+{
+	int found = 0;
+
+	if(iterator_u->flags & GPT_ITERATE_INVALIDS) {
+		gpt_iterator_return(*iterator_u, key_r, node_p_r);
+		found = 1;
+	}
+	gpt_iterator_inspect_next(iterator_u, 0);
+	return found;
+}
+
+static inline int
+gpt_node_delete_single(gpt_thunk_t delete_thunk, gpt_node_t delete_node)
+{
+	int8_t coverage;
+	gpt_key_t guard, key = delete_thunk.key;
+
+	guard = gpt_node_read_guard(delete_node);
+	coverage = gpt_node_leaf_read_coverage(delete_node);
+	/* Check the key matches the guard and coverage of the leaf node. */
+	gptKeysCompareStripPrefix(&key, &guard);
+	if(!gpt_key_compare_null(guard)) {
+		return GPT_NOT_FOUND;
+	}
+	gpt_node_set(delete_thunk.node_p, gpt_node_invalid_init());
+	return coverage;
+}
+/* awiggins (2006-07-18): Review the use of gpt_node_delete_single, redundent?*/
+static int
+gpt_node_delete_replicate(gpt_thunk_t delete_thunk, gpt_node_t delete_node)
+{
+	int i;
+	int8_t level_order, key_length, delete_coverage;
+	gpt_key_t guard, key = delete_thunk.key;
+	gpt_node_t* level;
+	gpt_key_value_t key_value;
+
+	level = gpt_node_internal_read_ptr(delete_node);
+	level_order = gpt_node_internal_read_order(delete_node);
+	gpt_node_read_guard(delete_node);
+	gptKeysCompareStripPrefix(&guard, &key);
+	key_value = gpt_key_read_value(key);
+	key_length = gpt_key_read_length(key);
+	key_length = level_order - key_length;
+	key_value <<= key_length;
+	delete_thunk.key = gpt_key_null();
+	for(i = key_value; i < key_value + (1 << key_length); i++) {
+		delete_thunk.node_p = level + i;
+		delete_node = gpt_node_get(delete_thunk.node_p);
+		delete_coverage =
+				gpt_node_delete_single(delete_thunk, delete_node);
+	}
+	return delete_coverage;
+}
+
+static int
+gpt_node_internal_delete(gpt_thunk_t delete_thunk, gpt_node_t delete_node)
+{
+	if(!gpt_node_internal_elongation(delete_node)) {
+		return gpt_node_delete_replicate(delete_thunk, delete_node);
+	}
+	panic("Fix me! Currently don't handle elongations");
+}
+
+static inline void
+gpt_node_insert_single(gpt_node_t new_node, gpt_thunk_t insert_thunk)
+{
+	new_node = gpt_node_init_guard(new_node, insert_thunk.key);
+	gpt_node_set(insert_thunk.node_p, new_node);
+}
+
+static int
+gpt_node_insert_replicate(gpt_node_t new_node, gpt_thunk_t insert_thunk,
+                          gpt_node_t insert_node)
+{
+	int i;
+	int8_t key_length, guard_length, level_order, log2replication;
+	gpt_key_t guard, key_temp, key = insert_thunk.key;
+	gpt_node_t* level;
+	gpt_key_value_t key_value;
+	unsigned long long interval;
+
+	level = gpt_node_internal_read_ptr(insert_node);
+	level_order = gpt_node_internal_read_order(insert_node);
+	guard = gpt_node_read_guard(insert_node);
+	guard_length = gpt_key_read_length(guard);
+	gptKeyCutMSB(guard_length, &key, &key_temp);
+	key_value = gpt_key_read_value(key);
+	key_length = gpt_key_read_length(key);
+	/* The split of key and guard should match. */
+	//assert(gptKeysCompareEqual(guard, key_temp));
+	/* Insert the new replicated node. */
+	key_temp = gpt_key_null();
+	log2replication = level_order - key_length;
+	interval = 1ULL << log2replication;
+	level = level + (interval * key_value);
+	insert_thunk.key = key_temp;
+	for(i = 0; i < interval; i++) {
+		insert_thunk.node_p = level + i;
+		/* Check for overlap. */
+		insert_node = gpt_node_get(insert_thunk.node_p);
+		if(gpt_node_type(insert_node) != GPT_NODE_TYPE_INVALID) {
+			/* Clean up the entries that we set. */
+				for(i--; i >= 0; i--) {
+					gpt_node_set(level + i,
+								 gpt_node_invalid_init());
+				}
+				return GPT_OVERLAP;
+		} else {
+			gpt_node_insert_single(new_node, insert_thunk);
+		}
+	}
+	return GPT_OK;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
