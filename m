From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:48:56 +1100
Message-Id: <20070113024856.29682.96009.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 3/12] Alternate page table implementation cont...
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH GPT 03
 * Adds the GPT as a page table type
 * include the GPT in include/linux/pt.h
 * Adds some of the GPT implementation in pt-gpt.h
 and include it in pt.h

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 gpt.h     |  120 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 pt-gpt.h  |  115 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 pt-type.h |    5 ++
 pt.h      |    6 ++-
 4 files changed, 245 insertions(+), 1 deletion(-)
Index: linux-2.6.20-rc4/include/linux/pt-type.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/pt-type.h	2007-01-11 16:46:47.518747000 +1100
+++ linux-2.6.20-rc4/include/linux/pt-type.h	2007-01-11 16:58:19.345390000 +1100
@@ -5,4 +5,9 @@
 typedef struct { pgd_t *pgd; } pt_t;
 #endif
 
+#ifdef CONFIG_GPT
+#include <linux/gpt.h>
+typedef gpt_t pt_t;
+#endif
+
 #endif
Index: linux-2.6.20-rc4/include/linux/pt-gpt.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc4/include/linux/pt-gpt.h	2007-01-11 16:58:19.345390000 +1100
@@ -0,0 +1,115 @@
+#ifndef _LINUX_PT_GPT_H
+#define _LINUX_PT_GPT_H
+
+#include <asm/pgtable.h>
+
+#include <linux/hugetlb.h>
+#include <linux/gpt.h>
+
+typedef struct pt_struct { } pt_path_t;
+
+static inline int create_user_page_table(struct mm_struct *mm)
+{
+	mm->page_table = gpt_node_invalid_init();
+
+	return 0;
+}
+
+static inline void destroy_user_page_table(struct mm_struct *mm)
+{
+
+}
+
+static inline pte_t *lookup_page_table(struct mm_struct *mm,
+		unsigned long address, pt_path_t *pt_path)
+{
+	gpt_thunk_t thunk;
+
+    thunk.key = gpt_key_init(extract_key(address), GPT_KEY_LENGTH_MAX);
+    thunk.node_p = &(mm->page_table);
+    if(!gpt_node_inspect_find(&thunk) ||
+       (gpt_node_type(*thunk.node_p) != GPT_NODE_TYPE_LEAF)) {
+		return NULL;
+    }
+    return gpt_node_leaf_read_ptep(thunk.node_p);
+}
+
+static inline pte_t *build_page_table(struct mm_struct *mm,
+		unsigned long address, pt_path_t *pt_path)
+{
+	int is_root;
+	pte_t pte;
+	gpt_thunk_t update_thunk;
+	gpt_node_t leaf;
+
+	update_thunk.key = gpt_key_init(extract_key(address),
+                                        GPT_KEY_LENGTH_MAX);
+	pte_clear(mm, address, &pte); /* Should set coverage/page-size here. */
+	leaf = gpt_node_leaf_init(pte);
+
+	update_thunk.node_p = (gpt_node_t *)&mm->page_table;
+	is_root = gpt_node_update_find(&update_thunk);
+	if(gptLevelRestructureInsert(is_root, &update_thunk) < GPT_OK) {
+		return gpt_node_leaf_read_ptep(update_thunk.node_p);
+	}
+	if(gpt_node_insert(leaf, update_thunk) < GPT_OK) {
+		return NULL;
+    }
+	gpt_node_internal_traverse(&update_thunk);
+	return gpt_node_leaf_read_ptep(update_thunk.node_p);
+}
+
+#define INIT_PT
+
+#define lock_pte(mm, pt_path) \
+	({ spin_lock(&mm->page_table_lock);})
+
+/*
+ * Unlocks the ptes notionally pointed to by the
+ * page table path.
+ */
+#define unlock_pte(mm, pt_path) \
+	({ spin_unlock(&mm->page_table_lock);})
+
+/*
+ * Looks up a page table from a saved path.  It also
+ * locks the page table.
+ */
+#define lookup_page_table_lock(mm, pt_path, address) \
+	({ pte_t *__pte = lookup_page_table(mm, address, NULL);\
+	   spin_lock(&mm->page_table_lock); \
+	   __pte; })
+
+/*
+ * Check that the original pte hasn't change.
+ */
+
+#define atomic_pte_same(mm, pte, orig_pte, pt_path) \
+({ \
+	int __same; \
+	spin_lock(&mm->page_table_lock); \
+	__same = pte_same(*pte, orig_pte); \
+	spin_unlock(&mm->page_table_lock); \
+	__same; \
+})
+
+#define is_huge_page(mm, address, pt_path, flags, page) \
+({ \
+	int __ret=0; \
+  	__ret; \
+})
+
+#define set_pt_path(pt_path, ppt_path) ((pt_path) = *(ppt_path))
+
+#define CLUSTER_SIZE	min(32*PAGE_SIZE, 32*PAGE_SIZE)
+
+static inline pte_t *lookup_gate_area(struct mm_struct *mm,
+			unsigned long pg)
+{
+	panic("Implement\n");
+	return NULL;
+}
+
+#define vma_optimization do {} while(0)
+
+#endif
Index: linux-2.6.20-rc4/include/linux/pt.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/pt.h	2007-01-11 16:46:48.246747000 +1100
+++ linux-2.6.20-rc4/include/linux/pt.h	2007-01-11 16:58:19.345390000 +1100
@@ -1,6 +1,10 @@
 #ifndef _LINUX_PT_H
 #define _LINUX_PT_H
 
+#ifdef CONFIG_GPT
+#include <linux/pt-gpt.h>
+#endif
+
 #include <linux/swap.h>
 
 #ifdef CONFIG_PT_DEFAULT
@@ -48,7 +52,7 @@
 		unsigned long addr, unsigned long end, swp_entry_t entry, struct page *page);
 
 void smaps_read_iterator(struct vm_area_struct *vma,
-  unsigned long addr, unsigned long end, struct mem_size_stats *mss);
+		unsigned long addr, unsigned long end, struct mem_size_stats *mss);
 
 int check_policy_read_iterator(struct vm_area_struct *vma,
 		unsigned long addr, unsigned long end, const nodemask_t *nodes,
Index: linux-2.6.20-rc4/include/linux/gpt.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc4/include/linux/gpt.h	2007-01-11 16:58:19.349390000 +1100
@@ -0,0 +1,120 @@
+/**
+ *  include/linux/gpt.h
+ *
+ *  Copyright (C) 2005 - 2006 University of New South Wales, Australia
+ *      Adam 'WeirdArms' Wiggins <awiggins@cse.unsw.edu.au>,
+ *      Paul Davies <pauld@cse.unsw.edu.au>.
+ */
+
+#ifndef _LINUX_GPT_H
+#define _LINUX_GPT_H
+
+#include <asm/pgtable-gpt.h>
+
+#define GPT_SPECIAL 1
+#define GPT_NORMAL  2
+
+#define GPT_ORDER (PAGE_SHIFT - GPT_NODE_LOG2BYTES) // Main levels page-sized.
+
+#define GPT_KEY_VALUE_MAX ((gpt_key_value_t)((1 << GPT_KEY_LENGTH_MAX) - 1))
+
+typedef gpt_node_t gpt_t;
+
+typedef struct {
+	gpt_key_t key;
+	gpt_node_t *node_p;
+} gpt_thunk_t;
+
+typedef enum {GPT_TRAVERSED_FULL = 0, GPT_TRAVERSED_GUARD,
+              GPT_TRAVERSED_MISMATCH, GPT_TRAVERSED_NONE
+} gpt_traversed_t;
+
+#define GPT_ITERATE_INVALIDS  (1 << 0)
+#define GPT_ITERATE_LEAVES    (1 << 1)
+#define GPT_ITERATE_INTERNALS (1 << 2)
+
+#define GPT_ITERATOR_STACK_SIZE (((GPT_KEY_LENGTH_MAX - 1)/GPT_ORDER) + 1)
+
+typedef struct {
+	int8_t flags, coverage, depth, finished;
+	gpt_key_value_t start, limit;
+	gpt_key_t key;
+	gpt_node_t* node_p;
+	gpt_node_t* stack[GPT_ITERATOR_STACK_SIZE];
+} gpt_iterator_t;
+
+/****************
+* Return codes. *
+****************/
+
+#define GPT_OK            0
+#define GPT_FAILED       -1
+#define GPT_INVALID      -2
+#define GPT_NOT_FOUND    -3
+#define GPT_OCCUPIED     -4
+#define GPT_OVERLAP      -5
+#define GPT_ALLOC_FAILED -6
+
+static inline unsigned long extract_key(unsigned long address)
+{
+	address >>= PAGE_SHIFT;
+
+	return address;
+}
+
+static inline unsigned long get_real_address(unsigned long pos_value)
+{
+	pos_value <<= PAGE_SHIFT;
+
+	return pos_value;
+}
+
+int gpt_node_inspect_find(gpt_thunk_t* inspect_thunk_u);
+int gpt_node_update_find(gpt_thunk_t* update_thunk_u);
+int gpt_node_delete(int is_root, gpt_thunk_t update_thunk);
+int gpt_node_insert(gpt_node_t new_node, gpt_thunk_t update_thunk);
+gpt_traversed_t gpt_node_internal_traverse(gpt_thunk_t* thunk_u);
+void gpt_node_restructure_delete(int is_root, int8_t update_coverage,
+                                 gpt_node_t* update_node_u);
+int gpt_node_restructure_insert(int is_root, gpt_thunk_t* update_thunk_u);
+
+gpt_node_t* gpt_level_allocate(int8_t order);
+void gpt_level_deallocate(gpt_node_t* level, int8_t order);
+
+int gpt_iterator_inspect(gpt_iterator_t* iterator, gpt_key_t* key_r,
+                         gpt_node_t** node_p_r);
+
+gpt_node_t gpt_node_get(gpt_node_t* node_p);
+void gpt_node_set(gpt_node_t* node_p, gpt_node_t node);
+int gpt_node_type(gpt_node_t node);
+int gpt_node_valid(gpt_node_t node);
+gpt_node_t gpt_node_invalid_init(void);
+gpt_node_t gpt_node_leaf_init(pte_t pte);
+int8_t gpt_node_leaf_read_coverage(gpt_node_t node);
+pte_t* gpt_node_leaf_read_ptep(gpt_node_t* node_p);
+gpt_node_t gpt_node_internal_init(gpt_node_t* level, int8_t order);
+gpt_node_t gpt_node_internal_dec_children(gpt_node_t node);
+gpt_node_t gpt_node_internal_inc_children(gpt_node_t node);
+gpt_key_value_t gpt_node_internal_count_children(gpt_node_t node);
+gpt_key_value_t gpt_node_internal_first_child(gpt_node_t node);
+int gpt_node_internal_elongation(gpt_node_t node);
+gpt_node_t* gpt_node_internal_read_ptr(gpt_node_t node);
+int8_t gpt_node_internal_read_order(gpt_node_t node);
+gpt_node_t gpt_node_init_guard(gpt_node_t node, gpt_key_t guard);
+gpt_key_t gpt_node_read_guard(gpt_node_t node);
+
+int gptLevelRestructureInsert(int is_root, gpt_thunk_t* update_thunk_u);
+
+int8_t gptNodeReplication(gpt_node_t node, int8_t coverage);
+
+gpt_key_t gpt_key_null(void);
+gpt_key_t gpt_key_init(gpt_key_value_t value, int8_t length);
+gpt_key_value_t gpt_key_read_value(gpt_key_t key);
+int8_t gpt_key_read_length(gpt_key_t key);
+
+void gptKeyCutMSB(int8_t length_msb, gpt_key_t* key_u, gpt_key_t* key_msb_r);
+void gptKeyCutLSB(int8_t length_lsb, gpt_key_t* key_u, gpt_key_t* key_lsb_r);
+void gptKeysMergeLSB(gpt_key_t key_msb, gpt_key_t* key_u);
+int8_t gptKeysCompareStripPrefix(gpt_key_t* key1_u, gpt_key_t* key2_u);
+
+#endif /* !_LINUX_GPT_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
