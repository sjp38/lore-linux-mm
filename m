From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:49:33 +1100
Message-Id: <20070113024933.29682.30267.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 10/12] Alternate page table implementation cont...
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH GPT 10
 * Continue adding GPT implementation

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 pt-gpt-core.c |  219 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 219 insertions(+)
Index: linux-2.6.20-rc1/mm/pt-gpt-core.c
===================================================================
--- linux-2.6.20-rc1.orig/mm/pt-gpt-core.c	2007-01-03 15:57:35.539309000 +1100
+++ linux-2.6.20-rc1/mm/pt-gpt-core.c	2007-01-03 16:07:14.297584000 +1100
@@ -600,3 +600,222 @@
 	gpt_iterator_inspect_push_range(iterator_u);
 	return 0;
 }
+
+static inline void
+gpt_iterator_terminal_free_pgtables(gpt_iterator_t* iterator_u)
+{
+	int8_t replication;
+
+	if(gpt_iterator_check_bounds(iterator_u, &replication) ==
+	   GPT_ITERATOR_LIMIT) {
+		if(iterator_u->depth == 0) {
+			iterator_u->node_p = NULL;
+			return;
+		}
+		iterator_u->finished = 1;
+		gpt_iterator_inspect_pop(iterator_u);
+	} else {
+		gpt_iterator_inspect_next(iterator_u, replication);
+	}
+}
+
+static inline int
+gpt_iterator_internal_visit_range(gpt_iterator_t* iterator_u,
+                                                    gpt_node_t** node_p_r)
+{
+	//int8_t replication;
+
+	panic("Unimplemented!");
+	if(iterator_u->finished) {
+		gpt_iterator_return(*iterator_u, NULL, node_p_r);
+		gpt_iterator_inspect_next(iterator_u, 0);
+		return 1;
+	}
+	//gpt_iterator_check_bounds(iterator_u,
+}
+
+static inline int
+gpt_iterator_internal_visit_all(gpt_iterator_t* iterator_u, gpt_key_t* key_r,
+                                gpt_node_t** node_p_r)
+{
+	int8_t replication;
+
+	/* Process node once children have been processed. */
+	if(iterator_u->finished) {
+		gpt_iterator_return(*iterator_u, key_r, node_p_r);
+		gpt_iterator_inspect_next(iterator_u, 0);
+		return 1;
+	}
+	gpt_iterator_check_bounds(iterator_u, &replication); // updates key.
+	/* If guard is in range process child nodes if guard. */
+	gpt_iterator_inspect_push_range(iterator_u);
+	return 0;
+}
+
+static inline void
+gpt_iterator_internal_skip_range(gpt_iterator_t* iterator_u)
+{
+	int8_t replication;
+
+	/* Process node once children have been processed. */
+	if(iterator_u->finished) {
+		gpt_iterator_inspect_next(iterator_u, 0);
+		return;
+	}
+	/* If guard is in range process child nodes if guard. */
+	switch(gpt_iterator_check_bounds(iterator_u, &replication)) {
+	case GPT_ITERATOR_INRANGE:
+		gpt_iterator_inspect_push_range(iterator_u);
+		break;
+	case GPT_ITERATOR_START:
+		BUG_ON(replication != 0); // Internal nodes not be replicated.
+		gpt_iterator_inspect_next(iterator_u, 0);
+		break;
+	case GPT_ITERATOR_LIMIT:
+		iterator_u->node_p = NULL;
+		break;
+	default:
+		panic("Should never get here!");
+	}
+}
+
+static inline void
+gpt_iterator_terminal_skip_range(gpt_iterator_t* iterator_u)
+{
+	int8_t replication;
+
+	switch(gpt_iterator_check_bounds(iterator_u, &replication)) {
+	case GPT_ITERATOR_INRANGE:
+	case GPT_ITERATOR_START:
+		gpt_iterator_inspect_next(iterator_u, replication);
+		break;
+	case GPT_ITERATOR_LIMIT:
+		iterator_u->node_p = NULL;
+		break;
+	default:
+		panic("Should never get here!");
+	}
+}
+
+static inline void
+gpt_iterator_terminal_skip_all(gpt_iterator_t* iterator_u)
+{
+	int8_t replication;
+
+	// awiggins (2006-09-14) Should actually check replication of leaves.
+	gpt_iterator_check_bounds(iterator_u, &replication); // updates key.
+	gpt_iterator_inspect_next(iterator_u, replication);
+}
+
+
+static inline int
+gpt_iterator_check_bounds(gpt_iterator_t* iterator_u, int8_t* replication_r)
+{
+	int8_t coverage;
+	gpt_key_t key;
+	gpt_key_value_t key_value;
+
+	/* Construct the search-key for the current node. */
+	coverage = iterator_u->coverage - gpt_key_read_length(iterator_u->key);
+	*replication_r = gptNodeReplication(*iterator_u->node_p, coverage);
+	key = gpt_node_read_guard(gpt_node_get(iterator_u->node_p));
+	key = gpt_keys_merge_LSB(iterator_u->key, key);
+	iterator_u->key = key = gpt_key_cut_LSB(*replication_r, key);
+	/* Compare the current nodes search-key to the iterator's range. */
+	key_value = gpt_key_read_value(key);
+	coverage = iterator_u->coverage - gpt_key_read_length(key);
+	if(key_value < (iterator_u->start >> coverage)) {
+		return GPT_ITERATOR_START;
+	}
+	if(key_value > (iterator_u->limit >> coverage)) {
+		return GPT_ITERATOR_LIMIT;
+	}
+	return GPT_ITERATOR_INRANGE;
+}
+
+static inline void
+gpt_iterator_inspect_push_range(gpt_iterator_t* iterator_u)
+{
+	int8_t key_length, coverage, level_order;
+	gpt_key_t index;
+	gpt_node_t node, *level;
+	gpt_key_value_t i, key_value;
+
+	/* Get details of next level. */
+	node = gpt_node_get(iterator_u->node_p);
+	level = gpt_node_internal_read_ptr(node);
+	level_order = gpt_node_internal_read_order(node);
+	/* Find index into next level. */
+	key_value = gpt_key_read_value(iterator_u->key);
+	key_length = gpt_key_read_length(iterator_u->key);
+	coverage = iterator_u->coverage - key_length;
+	i = iterator_u->start >> (coverage - level_order);
+	if((i >> level_order) == (key_value)) {
+		i &= ~gpt_key_value_mask(level_order);
+	} else {
+		i = 0;
+	}
+	index = gpt_key_init(i, level_order);
+	/* Update iterator position. */
+	iterator_u->stack[(iterator_u->depth)++] = iterator_u->node_p;
+	iterator_u->node_p = level + i;
+	iterator_u->key = gpt_keys_merge_MSB(index, iterator_u->key);
+}
+
+static inline void
+gpt_iterator_inspect_push_all(gpt_iterator_t* iterator_u)
+{
+	int8_t level_order;
+	gpt_key_t index;
+	gpt_node_t node, *level;
+
+	/* Get details of next level. */
+	node = gpt_node_get(iterator_u->node_p);
+	level = gpt_node_internal_read_ptr(node);
+	level_order = gpt_node_internal_read_order(node);
+	/* Update iterator position. */
+	index = gpt_key_init(0, level_order);
+	iterator_u->stack[(iterator_u->depth)++] = iterator_u->node_p;
+	iterator_u->node_p = level;
+	iterator_u->key = gpt_keys_merge_MSB(index, iterator_u->key);
+}
+
+static inline void
+gpt_iterator_inspect_next(gpt_iterator_t* iterator_u, int8_t replication)
+{
+	int8_t level_order, key_length;
+	gpt_key_t guard, index;
+	gpt_node_t node, *level;
+	gpt_key_value_t i, step;
+
+	/* The root node has no siblings, iteration complete. */
+	if(iterator_u->depth == 0) {
+		iterator_u->node_p = NULL;
+		return;
+	}
+	/* Strip the current nodes guard bits from the key. */
+	node = gpt_node_get(iterator_u->node_p);
+	if(gpt_node_valid(node)) {
+		guard = gpt_node_read_guard(node);
+		key_length = gpt_key_read_length(guard);
+		iterator_u->key = gpt_key_cut_LSB(key_length, iterator_u->key);
+	}
+	/* Update index and either get next sibling or return to parent. */
+	node = gpt_node_get(gpt_iterator_parent(*iterator_u));
+	level = gpt_node_internal_read_ptr(node);
+	level_order = gpt_node_internal_read_order(node);
+	index = gpt_key_cut_LSB2(level_order - replication, &(iterator_u->key));
+	i = gpt_key_read_value(index);
+	key_length = gpt_key_read_length(index);
+	step = 1 << replication;
+	if(i < ((1 << (level_order - replication)) - 1)) {
+		i = (i + 1) << replication;
+		index = gpt_key_init(i, level_order);
+		iterator_u->key = gpt_keys_merge_MSB(index, iterator_u->key);
+		iterator_u->node_p = level + i;
+		iterator_u->finished = 0;
+	} else {
+		gpt_iterator_inspect_pop(iterator_u);
+	}
+}
+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
