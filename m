From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:49:01 +1100
Message-Id: <20070113024901.29682.85494.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 4/12] Alternate page table implementation cont...
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH GPT 04
 * Add C files for GPT implementation and update Makefile

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 Makefile             |    7 +
 pt-gpt-alloc.c       |   38 +++++++++
 pt-gpt-restructure.c |  195 +++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 239 insertions(+), 1 deletion(-)
Index: linux-2.6.20-rc1/mm/Makefile
===================================================================
--- linux-2.6.20-rc1.orig/mm/Makefile	2007-01-03 12:30:42.879871000 +1100
+++ linux-2.6.20-rc1/mm/Makefile	2007-01-03 12:35:13.756007000 +1100
@@ -5,7 +5,12 @@
 mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= fremap.o highmem.o madvise.o memory.o mincore.o \
 			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
-			   vmalloc.o pt-default.o
+			   vmalloc.o
+
+ifdef CONFIG_MMU
+mmu-$(CONFIG_PT_DEFAULT)+= pt-default.o
+mmu-$(CONFIG_GPT) += pt-gpt-core.o pt-gpt-restructure.o pt-gpt-alloc.o
+endif
 
 obj-y			:= bootmem.o filemap.o mempool.o oom_kill.o fadvise.o \
 			   page_alloc.o page-writeback.o pdflush.o \
Index: linux-2.6.20-rc1/mm/pt-gpt-alloc.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc1/mm/pt-gpt-alloc.c	2007-01-03 12:30:46.159871000 +1100
@@ -0,0 +1,38 @@
+/**
+ *  mm/pt-gpt-alloc.c
+ *
+ *  Copyright (C) 2005 - 2006 University of New South Wales, Australia
+ *      Adam 'WeirdArms' Wiggins <awiggins@cse.unsw.edu.au>,
+ *      Paul Davies <pauld@cse.unsw.edu.au>.
+ */
+
+#include <linux/types.h>
+#include <linux/bootmem.h>
+#include <linux/gpt.h>
+
+#include <asm/pgalloc.h>
+
+int gpt_memsrc = GPT_SPECIAL;
+
+/* awiggins (2006-07-17): Currently ignores the size and allocates a page. */
+gpt_node_t*
+gpt_level_allocate(int8_t order)
+{
+        gpt_node_t* level;
+
+        if(gpt_memsrc == GPT_SPECIAL) {
+                level = (gpt_node_t*)alloc_bootmem_pages(PAGE_SIZE);
+        } else {
+                level = (gpt_node_t*)pgtable_quicklist_alloc();
+		}
+        if(!level) {
+                panic("GPT level allocation failed!\n");
+        }
+        return level;
+}
+
+void
+gpt_level_deallocate(gpt_node_t* level, int8_t order)
+{
+        pgtable_quicklist_free((void*)level);
+}
Index: linux-2.6.20-rc1/mm/pt-gpt-restructure.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc1/mm/pt-gpt-restructure.c	2007-01-03 12:40:30.841030000 +1100
@@ -0,0 +1,195 @@
+/**
+ *  mm/pt-gpt-restructure.c
+ *
+ *  Copyright (C) 2005 - 2006 University of New South Wales, Australia
+ *      Adam 'WeirdArms' Wiggins <awiggins@cse.unsw.edu.au>,
+ *      Paul Davies <pauld@cse.unsw.edu.au>.
+ */
+
+#include <linux/types.h>
+#include <linux/bootmem.h>
+#include <linux/gpt.h>
+
+/****************************
+* Local function prototypes *
+****************************/
+
+static void gpt_node_restructure_merge(gpt_key_value_t merge_index,
+                                       int8_t coverage,
+                                       gpt_node_t* update_node_u);
+static int gpt_node_restructure_cut(int8_t cut_length,
+                                    gpt_node_t* update_node_u);
+
+/*********************
+* Exported functions *
+*********************/
+
+void
+gpt_node_restructure_delete(int is_root, int8_t coverage,
+                            gpt_node_t* update_node_u)
+{
+	gpt_node_t update_node;
+	gpt_key_value_t index_value;
+
+	/* If deletion window is the root node, no restructuring possible. */
+	update_node = gpt_node_get(update_node_u);
+	if(!is_root && (gpt_node_internal_count_children(update_node) == 1)) {
+		index_value = gpt_node_internal_first_child(update_node);
+		gpt_node_restructure_merge(index_value, coverage,
+									   update_node_u);
+	}
+}
+
+int
+gpt_node_restructure_insert(int is_root, gpt_thunk_t* update_thunk_u)
+{
+	int traversed = 0;
+	int8_t match_length;
+	gpt_key_t key, guard;
+	gpt_node_t node;
+	gpt_thunk_t temp_thunk;
+
+	/* If required, traverse to the node covering the insertion window. */
+	temp_thunk = *update_thunk_u;
+	if(!is_root && !gpt_node_internal_traverse(&temp_thunk)) {
+		traversed = 1;
+	} else {
+		temp_thunk.key = update_thunk_u->key;
+	}
+	/* Find if insertion window lays on a guard, if so restructure. */
+	node = gpt_node_get(temp_thunk.node_p);
+	if(!gpt_node_valid(node)) {
+		return GPT_OK;
+	}
+	key = temp_thunk.key;
+	guard = gpt_node_read_guard(node);
+	match_length = gptKeysCompareStripPrefix(&key, &guard);
+	if(gpt_key_compare_null(key)) {
+		return GPT_OVERLAP;
+	}
+	if(gpt_key_compare_null(guard)) {
+		switch(gpt_node_type(node)) {
+		case GPT_NODE_TYPE_LEAF:
+			return GPT_OVERLAP;
+		case GPT_NODE_TYPE_INTERNAL:
+			return GPT_OK;
+		default:
+			panic("Invalid GPT node type!");
+		}
+	}
+	/* Traverse to cut node and return it cut. */
+	if(traversed) {
+		*update_thunk_u = temp_thunk;
+	}
+	return gpt_node_restructure_cut(match_length, update_thunk_u->node_p);
+}
+
+int
+gptLevelRestructureInsert(int is_root, gpt_thunk_t* update_thunk_u)
+{
+	int8_t match_length;
+	gpt_key_t key, guard;
+	gpt_node_t node;
+	gpt_thunk_t temp_thunk;
+
+	/* If required, try traversing to node covering the insert point. */
+	key = update_thunk_u->key;
+	temp_thunk = *update_thunk_u;
+	if(!is_root &&
+	   (gpt_node_internal_traverse(&temp_thunk) == GPT_TRAVERSED_FULL)) {
+			update_thunk_u->key = key = temp_thunk.key;
+	}
+	update_thunk_u->node_p = temp_thunk.node_p;
+	/* Already at the insertion point. */
+	node = gpt_node_get(update_thunk_u->node_p);
+	if(!gpt_node_valid(node)) {
+		return GPT_OK;
+	}
+	guard = gpt_node_read_guard(node);
+	match_length = gptKeysCompareStripPrefix(&key, &guard);
+	if(gpt_key_compare_null(key)) {
+		return GPT_OVERLAP;
+	}
+	if(gpt_key_compare_null(guard)) {
+		switch(gpt_node_type(node)) {
+		case GPT_NODE_TYPE_LEAF:
+			return GPT_OVERLAP;
+		case GPT_NODE_TYPE_INTERNAL:
+			return GPT_OK;
+		default:
+			panic("Should never get here\n");
+		}
+	}
+	return gpt_node_restructure_cut(match_length, update_thunk_u->node_p);
+}
+
+/******************
+* Local functions *
+******************/
+
+static void
+gpt_node_restructure_merge(gpt_key_value_t merge_index, int8_t coverage,
+                           gpt_node_t* update_node_u)
+{
+	int8_t level_order, guard_length, replication;
+	gpt_key_t guard_top, guard, index;
+	gpt_node_t temp_node, update_node;
+	gpt_node_t* level;
+
+	/* Find the merge-node, guards and index for merging. */
+	update_node = gpt_node_get(update_node_u);
+	level = gpt_node_internal_read_ptr(update_node);
+	level_order = gpt_node_internal_read_order(update_node);
+	guard = gpt_node_read_guard(update_node);
+	temp_node = level[merge_index];
+	guard = gpt_node_read_guard(temp_node);
+
+	/* Merge guards and index into a single node. */
+	guard_length = gpt_key_read_length(guard_top);
+	coverage -= (level_order + guard_length);
+	replication = gptNodeReplication(temp_node, coverage);
+	index = gpt_key_init(merge_index >> replication,
+						 level_order - replication);
+	gptKeysMergeLSB(guard_top, &index); gptKeysMergeLSB(index, &guard);
+	gpt_node_set(update_node_u, gpt_node_init_guard(temp_node, guard));
+	gpt_level_deallocate(level, level_order);
+}
+
+static int
+gpt_node_restructure_cut(int8_t cut_length, gpt_node_t* update_node_u)
+{
+	int error;
+	int8_t index_length, coverage, order = GPT_ORDER;
+	gpt_key_t guard_top, guard_bottom, index;
+	gpt_node_t node, update_node;
+	gpt_node_t* level;
+	gpt_thunk_t thunk;
+
+	/* Preserve the update-node's guard. */
+	update_node = gpt_node_get(update_node_u);
+	thunk.key = gpt_node_read_guard(update_node);
+	guard_bottom = thunk.key;
+
+	/* Seperate the node in two. */
+	cut_length -= (cut_length % order); /* Top guard must be a multiple of trie's order. */
+	gptKeyCutMSB(cut_length, &guard_bottom, &guard_top);
+	index_length = gpt_key_read_length(guard_bottom);
+	if(gpt_node_type(update_node) == GPT_NODE_TYPE_LEAF) {
+		coverage = gpt_node_leaf_read_coverage(update_node);
+	} else {
+		coverage = 0;
+	}
+	index_length = (order > index_length + coverage) ?
+			index_length + coverage : order;
+	gptKeyCutMSB(index_length, &guard_bottom, &index);
+	level = gpt_level_allocate(index_length);
+	if(!level) {
+		return GPT_ALLOC_FAILED;
+	}
+	node = gpt_node_internal_init(level, index_length);
+	node = gpt_node_init_guard(node, guard_top);
+	thunk.node_p = &node;
+	error = gpt_node_insert(update_node, thunk);
+	gpt_node_set(update_node_u, node);
+	return GPT_OK;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
