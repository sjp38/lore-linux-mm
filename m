From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:49:17 +1100
Message-Id: <20070113024917.29682.82377.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 7/12] Alternate page table implementation cont...
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH GPT 07
 * Adding GPT implementation

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 pt-gpt-core.c |  180 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 180 insertions(+)
Index: linux-2.6.20-rc1/mm/pt-gpt-core.c
===================================================================
--- linux-2.6.20-rc1.orig/mm/pt-gpt-core.c	2007-01-03 15:35:25.427180000 +1100
+++ linux-2.6.20-rc1/mm/pt-gpt-core.c	2007-01-03 15:42:21.973271000 +1100
@@ -99,3 +99,183 @@
 static int gpt_node_insert_replicate(gpt_node_t new_node,
                                      gpt_thunk_t insert_thunk,
                                      gpt_node_t insert_node);
+
+/*******************************************************************************
+ * Exported functions.                                                         *
+ *******************************************************************************/
+
+void
+gptKeyCutMSB(int8_t length_msb, gpt_key_t* key_u, gpt_key_t* key_msb_r)
+{
+	int8_t length;
+	gpt_key_value_t value;
+
+	value = gpt_key_read_value(*key_u);
+	length = gpt_key_read_length(*key_u);
+	if(length_msb > length) length_msb = length;
+	length -= length_msb;
+	if(key_msb_r) {
+		*key_msb_r = ((length_msb == 0) ? gpt_key_null() :
+					  gpt_key_init(value >> length, length_msb));
+	}
+	if(length == GPT_KEY_LENGTH_MAX) return;
+	*key_u = gpt_key_init(value & (((gpt_key_value_t)1 << length) - 1),
+						  length);
+}
+
+void
+gptKeyCutLSB(int8_t length_lsb, gpt_key_t* key_u, gpt_key_t* key_lsb_r)
+{
+	int8_t length;
+	gpt_key_value_t value;
+
+	value = gpt_key_read_value(*key_u);
+	length = gpt_key_read_length(*key_u);
+	if(length_lsb > length) length_lsb = length;
+	length -= length_lsb;
+	if(key_lsb_r) {
+		*key_lsb_r = gpt_key_init(value & ~gpt_key_value_mask(length_lsb),
+								  length_lsb);
+	}
+	*key_u = ((length == 0) ? gpt_key_null() :
+			  gpt_key_init(value >> length_lsb, length));
+}
+
+void
+gptKeysMergeMSB(gpt_key_t key_lsb, gpt_key_t* key_u)
+{
+	int8_t length, length_lsb;
+	gpt_key_value_t value;
+
+	value = gpt_key_read_value(*key_u);
+	length = gpt_key_read_length(*key_u);
+	length_lsb = gpt_key_read_length(key_lsb);
+	value = (value << length_lsb) + gpt_key_read_value(key_lsb);
+	length += length_lsb;
+	*key_u = gpt_key_init(value, length);
+}
+
+void
+gptKeysMergeLSB(gpt_key_t key_msb, gpt_key_t* key_u)
+{
+	gpt_key_value_t value;
+	int8_t length;
+
+	value = gpt_key_read_value(*key_u);
+	length = gpt_key_read_length(*key_u);
+	value = (gpt_key_read_value(key_msb) << length) + value;
+	length += gpt_key_read_length(key_msb);
+	*key_u = gpt_key_init(value, length);
+}
+
+/* awiggins (2006-02-07): I'd like to simplify this function if possible. */
+int8_t
+gptKeysCompareStripPrefix(gpt_key_t* key1_u, gpt_key_t* key2_u)
+{
+	int8_t length, key1_length, key2_length;
+	gpt_key_value_t value1, value2;
+
+	key1_length = key1_u->length; key2_length = key2_u->length;
+	if(key1_length < key2_length) {
+		length = key1_length;
+		value1 = key1_u->value;
+		value2 = key2_u->value >> (key2_length - length);
+	} else {
+		length = key2_length;
+		value1 = key2_u->value;
+		value2 = key1_u->value >> (key1_length - length);
+	}
+	if(length == 0) return 0;
+	length = gpt_ctlz(value1 ^ value2, length - 1);
+
+	/* Strip matching prefix from keys. */
+	gptKeyCutMSB(length, key1_u, NULL);
+	gptKeyCutMSB(length, key2_u, NULL);
+
+	return length;
+}
+
+int8_t
+gptNodeReplication(gpt_node_t node, int8_t coverage)
+{
+	gpt_key_t guard;
+	int8_t leaf_coverage, guard_length;
+
+	switch(gpt_node_type(node)) {
+	case GPT_NODE_TYPE_INTERNAL:
+	case GPT_NODE_TYPE_INVALID:
+		return 0; /* These nodes are never replicated. */
+	case GPT_NODE_TYPE_LEAF:
+		guard = gpt_node_read_guard(node);
+		leaf_coverage = gpt_node_leaf_read_coverage(node);
+		guard_length = gpt_key_read_length(guard);
+		coverage -= guard_length;
+		return leaf_coverage - coverage;
+	default: panic("Invalid GPT node encountered\n");
+	}
+}
+
+int
+gpt_node_inspect_find(gpt_thunk_t* inspect_thunk_u)
+{
+	int8_t guard_length, key_length;
+	gpt_key_t guard, key, temp_key;
+	gpt_node_t node;
+	gpt_thunk_t temp_thunk = *inspect_thunk_u;
+
+	/* Travrse to inspection node. */
+	while(gpt_node_internal_traverse(&temp_thunk) == GPT_TRAVERSED_FULL) {
+		inspect_thunk_u->key = temp_thunk.key;
+	}
+	key = inspect_thunk_u->key;
+	node = gpt_node_get(temp_thunk.node_p);
+	/* Only guardable entries are valid nodes. */
+	if(!gpt_node_valid(node)) {
+		return 0;
+	}
+	guard = gpt_node_read_guard(node);
+	inspect_thunk_u->node_p = temp_thunk.node_p;
+	key_length = gpt_key_read_length(key);
+	guard_length = gpt_key_read_length(guard);
+	/* Split the larger keys msb's off for comparison. */
+	if(key_length < guard_length) {
+		/* Cut the guard for checking. */
+		gptKeyCutMSB(key_length, &guard, &temp_key);
+		return gptKeysCompareEqual(key, temp_key);
+	} else if(key_length > guard_length) {
+		/* Cut the key for checking. */
+		gptKeyCutMSB(guard_length, &key, &temp_key);
+		return gptKeysCompareEqual(temp_key, guard);
+	}else {
+		return gptKeysCompareEqual(key, guard);
+	}
+}
+
+int
+gpt_node_update_find(gpt_thunk_t* update_thunk_u)
+{
+	gpt_traversed_t traversed;
+	gpt_thunk_t temp_thunk1, temp_thunk2;
+
+	/* Check if the deletion/insertion window covers the root node. */
+	temp_thunk1 = *update_thunk_u;
+	traversed = gpt_node_internal_traverse(&temp_thunk1);
+	if(traversed == GPT_TRAVERSED_NONE ||
+	   traversed == GPT_TRAVERSED_MISMATCH) {
+		return 1;
+	} else if (traversed == GPT_TRAVERSED_GUARD) {
+		return 0;
+	}
+	/* Traverse to update-node. */
+	temp_thunk2 = temp_thunk1;
+	while((traversed = gpt_node_internal_traverse(&temp_thunk2)) ==
+		  GPT_TRAVERSED_FULL) {
+		*update_thunk_u = temp_thunk1;
+		temp_thunk1 = temp_thunk2;
+	}
+	if(traversed == GPT_TRAVERSED_GUARD) {
+		*update_thunk_u = temp_thunk1;
+	}
+	return 0; /* Deletion/insertion window dose not cover root node. */
+}
+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
