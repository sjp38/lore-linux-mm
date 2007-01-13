From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:48:51 +1100
Message-Id: <20070113024851.29682.52851.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 2/12] Alternate page table implementation cont...
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH GPT 02
 * Creates /include/asm-ia64/page-gpt.h for GPT specific page.h requirements.
 and includes it in page.h. (similar to page-pt-default.h)

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 page-gpt.h |  238 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 page.h     |    4 +
 2 files changed, 242 insertions(+)
Index: linux-2.6.20-rc1/include/asm-ia64/page-gpt.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc1/include/asm-ia64/page-gpt.h	2007-01-03 12:09:27.559871000 +1100
@@ -0,0 +1,238 @@
+/**
+ *  include/asm-ia64/page-gpt.h
+ *
+ *  Copyright (C) 2005 - 2006 University of New South Wales, Australia
+ *      Adam 'WeirdArms' Wiggins <awiggins@cse.unsw.edu.au>.
+ */
+
+#ifndef _ASM_IA64_PAGE_GPT_H
+#define _ASM_IA64_PAGE_GPT_H
+
+
+#define GPT_NODE_LOG2BYTES   4 /* 128 bit == 16 (2^4) bytes. */
+#define GPT_KEY_LENGTH_MAX   (64 - PAGE_SHIFT)
+#define GPT_KEY_LENGTH_STORE 52 /* 64 - 12 (Smallest page size). */
+
+#define GPT_LEVEL_ORDER_MAX 16 /* 2^4 == 16 */
+
+#define GPT_NODE_TERM_BIT 0
+#define GPT_NODE_MODE_BIT 1
+#define GPT_NODE_TYPE(t,m) ((t) << GPT_NODE_TERM_BIT | (m) << GPT_NODE_MODE_BIT)
+
+#define GPT_NODE_TYPE_INVALID  GPT_NODE_TYPE(0,0)
+#define GPT_NODE_TYPE_LEAF     GPT_NODE_TYPE(0,1)
+#define GPT_NODE_TYPE_INTERNAL GPT_NODE_TYPE(1,0)
+#define GPT_NODE_TYPE_SHARED   GPT_NODE_TYPE(1,1) // Shared sub-trees unimpl.
+
+#ifndef __ASSEMBLY__
+
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <asm/pgtable-gpt.h>
+
+/* awiggins (2006-06-27): Replace union/structs with defines/macro's for asm. */
+typedef union {
+	struct {
+		uint64_t guard_length:  6;
+		uint64_t type:          2;
+		uint64_t order:         4; /* Remove. */
+		uint64_t guard_value:  52; /* 64 - 12 (minimum page size) */
+		union {
+			struct {
+				uint64_t ptr/*:      60*/;
+				//uint64_t order:  4;
+			} level;
+			pte_t pte;
+		} entry;
+	} node ;
+        struct {
+			uint64_t guard;
+			uint64_t entry;
+        } raw;
+} gpt_node_t;
+
+/* awiggins (2006-07-06): Next 2 functions are placeholders, should be atomic.*/
+static inline gpt_node_t
+gpt_node_get(gpt_node_t* node_p)
+{
+	return *node_p;
+}
+
+static inline void
+gpt_node_set(gpt_node_t* node_p, gpt_node_t node)
+{
+	/* Invalidate entry to mark node as being updated. */
+	node_p->raw.entry = 0;
+	/* Update node. */
+	((gpt_node_t volatile *)node_p)->raw.guard = node.raw.guard;
+	((gpt_node_t volatile *)node_p)->raw.entry = node.raw.entry;
+
+	/** awiggins 2006-08-02: The volatile typecasts should preserve
+	 *  the ordering of the operations by tagging those stores as
+	 *  releases.
+	 */
+}
+
+static inline int
+gpt_node_type(gpt_node_t node)
+{
+	return node.node.type;
+}
+
+static inline int
+gpt_node_valid(gpt_node_t node)
+{
+	switch(gpt_node_type(node)) {
+	case GPT_NODE_TYPE_INTERNAL:
+	case GPT_NODE_TYPE_LEAF:
+		return 1;
+	default:
+		return 0;
+	}
+}
+
+static inline gpt_node_t
+gpt_node_invalid_init(void)
+{
+	gpt_node_t invalid;
+
+	invalid.raw.guard = 0;
+	invalid.raw.entry = 0;
+//invalid.node.type = GPT_NODE_TYPE_INVALID;
+	return invalid;
+}
+
+static inline gpt_node_t
+gpt_node_leaf_init(pte_t pte)
+{
+	gpt_node_t leaf;
+
+	leaf.node.type = GPT_NODE_TYPE_LEAF;
+	leaf.node.entry.pte = pte;
+	leaf.node.order = 0; // awiggins (2006-07-07): Should be set in pte.
+
+	return leaf;
+}
+
+static inline int8_t
+gpt_node_leaf_read_coverage(gpt_node_t node)
+{
+	return node.node.order;
+}
+
+static inline pte_t*
+gpt_node_leaf_read_ptep(gpt_node_t* node_p)
+{
+	return &(node_p->node.entry.pte);
+}
+
+static inline gpt_node_t
+gpt_node_internal_init(gpt_node_t* level, int8_t order)
+{
+	gpt_node_t internal;
+
+	internal.node.type = GPT_NODE_TYPE_INTERNAL;
+	internal.node.entry.level.ptr =
+			__pa((uint64_t)level) /*> GPT_NODE_LOG2BYTES*/;
+	internal.node.order = order;
+	return internal;
+}
+
+static inline gpt_node_t*
+gpt_node_internal_read_ptr(gpt_node_t node)
+{
+	return (gpt_node_t*)__va(node.node.entry.level.ptr
+							 /*< GPT_NODE_LOG2BYTES*/);
+}
+
+static inline int8_t
+gpt_node_internal_read_order(gpt_node_t node)
+{
+	return (int8_t)node.node.order;
+}
+
+/* Current node structure does not store the number of valid children. */
+static inline gpt_node_t
+gpt_node_internal_dec_children(gpt_node_t node)
+{
+	/* awiggins (2006-07-14): Decrement node's valid children count. */
+	return node;
+}
+
+static inline gpt_node_t
+gpt_node_internal_inc_children(gpt_node_t node)
+{
+	/* awiggins (2006-07-14): Increment node's valid children count. */
+	return node;
+}
+
+static inline gpt_key_value_t
+gpt_node_internal_count_children(gpt_node_t node)
+{
+	int8_t order;
+	gpt_node_t* level;
+	gpt_key_value_t index, valid;
+
+	level = gpt_node_internal_read_ptr(node);
+	order = gpt_node_internal_read_order(node);
+	for(index = valid = 0; index < (1 << order); index++) {
+		if(gpt_node_valid(level[index])) {
+			valid++;
+		}
+	}
+	return valid;
+}
+
+static inline gpt_key_value_t
+gpt_node_internal_first_child(gpt_node_t node)
+{
+	gpt_key_value_t index;
+	int8_t order;
+	gpt_node_t* level;
+
+	level = gpt_node_internal_read_ptr(node);
+	order = gpt_node_internal_read_order(node);
+	for(index = 0; index < (1 << order); index++) {
+		if(gpt_node_valid(level[index])) {
+			return index;
+		}
+	}
+	panic("Should empty level encountered!");
+}
+
+static inline int
+gpt_node_internal_elongation(gpt_node_t node)
+{
+	/* Elongations are unit sized levels. */
+	return gpt_node_internal_read_order(node) == 0;
+}
+
+static inline gpt_node_t
+gpt_node_init_guard(gpt_node_t node, gpt_key_t guard)
+{
+	int8_t length, shift;
+
+	length = gpt_key_read_length(guard);
+	node.node.guard_length = gpt_key_read_length(guard);
+	/* Store guard value MSB aligned for assembly walker. */
+	shift = GPT_KEY_LENGTH_STORE - length;
+	node.node.guard_value = gpt_key_read_value(guard) << shift;
+
+	return node;
+}
+
+static inline gpt_key_t
+gpt_node_read_guard(gpt_node_t node)
+{
+	int8_t length, shift;
+
+	length = node.node.guard_length;
+	shift = GPT_KEY_LENGTH_STORE - length;
+	/* Need to LSB align guard before returning. */
+	return gpt_key_init(node.node.guard_value >> shift, length);
+}
+
+#endif /* !__ASSEMBLY__ */
+
+
+#endif /* !_ASM_IA64_PAGE_GPT_H */
Index: linux-2.6.20-rc1/include/asm-ia64/page.h
===================================================================
--- linux-2.6.20-rc1.orig/include/asm-ia64/page.h	2007-01-03 11:51:37.343593000 +1100
+++ linux-2.6.20-rc1/include/asm-ia64/page.h	2007-01-03 11:58:00.191871000 +1100
@@ -217,4 +217,8 @@
 #include <asm/page-default.h>
 #endif
 
+#ifdef CONFIG_GPT
+#include <asm/page-gpt.h>
+#endif
+
 #endif /* _ASM_IA64_PAGE_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
