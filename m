From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:49:12 +1100
Message-Id: <20070113024912.29682.33155.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 6/12] Alternate page table implementation cont...
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH GPT 06
 * Adds more GPT implementation.

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 include/asm-ia64/kregs.h       |    4 +
 include/asm-ia64/mmu_context.h |    1 
 mm/pt-gpt-core.c               |  101 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 106 insertions(+)
Index: linux-2.6.20-rc1/include/asm-ia64/kregs.h
===================================================================
--- linux-2.6.20-rc1.orig/include/asm-ia64/kregs.h	2007-01-03 15:34:29.855180000 +1100
+++ linux-2.6.20-rc1/include/asm-ia64/kregs.h	2007-01-03 15:34:36.303180000 +1100
@@ -20,6 +20,10 @@
 #define IA64_KR_CURRENT		6	/* ar.k6: "current" task pointer */
 #define IA64_KR_PT_BASE		7	/* ar.k7: page table base address (physical) */
 
+#ifdef CONFIG_GPT
+#define IA64_KR_CURRENT_MM	7
+#endif
+
 #define _IA64_KR_PASTE(x,y)	x##y
 #define _IA64_KR_PREFIX(n)	_IA64_KR_PASTE(ar.k, n)
 #define IA64_KR(n)		_IA64_KR_PREFIX(IA64_KR_##n)
Index: linux-2.6.20-rc1/include/asm-ia64/mmu_context.h
===================================================================
--- linux-2.6.20-rc1.orig/include/asm-ia64/mmu_context.h	2007-01-03 15:34:29.859180000 +1100
+++ linux-2.6.20-rc1/include/asm-ia64/mmu_context.h	2007-01-03 15:34:36.303180000 +1100
@@ -197,6 +197,7 @@
 #ifdef CONFIG_GPT
 	ia64_set_kr(IA64_KR_CURRENT_MM, __pa(next));
 #endif
+
 	activate_context(next);
 }
 
Index: linux-2.6.20-rc1/mm/pt-gpt-core.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc1/mm/pt-gpt-core.c	2007-01-03 15:35:25.427180000 +1100
@@ -0,0 +1,101 @@
+/**
+ *  mm/pt-gpt.c
+ *
+ *  Copyright (C) 2005 - 2006 University of New South Wales, Australia
+ *      Adam 'WeirdArms' Wiggins <awiggins@cse.unsw.edu.au,
+ *      Paul Davies <pauld@cse.unsw.edu.au>.
+ */
+
+#include <linux/types.h>
+#include <linux/bootmem.h>
+#include <linux/gpt.h>
+
+#include <linux/mm.h>
+#include <linux/hugetlb.h>
+#include <linux/mman.h>
+#include <linux/swap.h>
+#include <linux/highmem.h>
+#include <linux/pagemap.h>
+#include <linux/rmap.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/pt.h>
+
+#include <asm/uaccess.h>
+#include <asm/tlb.h>
+#include <asm/tlbflush.h>
+#include <asm/pgtable.h>
+
+#include <linux/swapops.h>
+#include <linux/elf.h>
+#include <linux/pt-iterator-ops.h>
+
+#define GPT_ITERATOR_INRANGE 0
+#define GPT_ITERATOR_START   1
+#define GPT_ITERATOR_LIMIT   (-1)
+
+/*******************************************************************************
+* Local function prototypes.                                                   *
+*******************************************************************************/
+
+static inline void gpt_iterator_inspect_init_all(gpt_iterator_t* iterator_r,
+                                                 gpt_t* trie_p);
+static inline void gpt_iterator_inspect_init_range(gpt_iterator_t* iterator_r,
+                                                   gpt_t* trie_p,
+                                                   unsigned long addr,
+                                                   unsigned long end);
+static inline int gpt_iterator_free_pgtables(gpt_iterator_t* iterator_u,
+                                             gpt_node_t** node_p_r,
+                                             unsigned long floor,
+                                             unsigned long ceiling);
+static inline int gpt_iterator_inspect_internals_all(gpt_iterator_t* iterator,
+                                                     gpt_key_t* key_r,
+                                                     gpt_node_t** node_p_r);
+static inline int gpt_iterator_inspect_leaves_range(gpt_iterator_t* iterator_u,
+                                                    gpt_key_t* key_r,
+                                                    gpt_node_t** node_p_r);
+static inline int gpt_iterator_leaf_visit_range(gpt_iterator_t* iterator_u,
+                                                gpt_key_t* key_r,
+                                                gpt_node_t** node_p_r);
+static inline int gpt_iterator_internal_free_pgtables(gpt_iterator_t* iterator_u,
+                                                      gpt_node_t**node_p_r,
+                                                      unsigned long floor,
+                                                      unsigned long ceiling);
+static inline int gpt_iterator_internal_visit_range(gpt_iterator_t* iterator_u,
+                                                    gpt_node_t** node_p_r);
+static inline int gpt_iterator_internal_visit_all(gpt_iterator_t* iterator_u,
+                                                  gpt_key_t* key_r,
+                                                  gpt_node_t** node_p_r);
+static inline void gpt_iterator_terminal_free_pgtables(gpt_iterator_t* iterator_u);
+static inline void gpt_iterator_terminal_skip_range(gpt_iterator_t* iterator_u);
+static inline void gpt_iterator_terminal_skip_all(gpt_iterator_t* iterator_u);
+static inline void gpt_iterator_internal_skip_range(gpt_iterator_t* iterator_u);
+static inline int gpt_iterator_check_bounds(gpt_iterator_t* iterator_u,
+                                            int8_t* replication_r);
+static inline void gpt_iterator_inspect_push_range(gpt_iterator_t* iterator_u);
+static inline void gpt_iterator_inspect_push_all(gpt_iterator_t* iterator_u);
+static inline void gpt_iterator_inspect_next(gpt_iterator_t* iterator_u,
+                                              int8_t replication);
+
+static int gpt_iterator_internal(gpt_iterator_t* iterator_u, gpt_key_t* key_r,
+                                 gpt_node_t** node_p_r);
+static int gpt_iterator_leaf(gpt_iterator_t* iterator_u, gpt_key_t* key_r,
+                             gpt_node_t** node_p_r);
+static inline int gpt_iterator_invalid(gpt_iterator_t* iterator_u,
+                                       gpt_key_t* key_r, gpt_node_t** node_p_r);
+static inline void gpt_iterator_inspect_pop(gpt_iterator_t* iterator_u);
+static inline gpt_node_t* gpt_iterator_parent(gpt_iterator_t iterator);
+static inline void gpt_iterator_return(gpt_iterator_t iterator,
+                                       gpt_key_t* key_r, gpt_node_t** node_p_r);
+
+static inline int gpt_node_delete_single(gpt_thunk_t delete_thunk,
+                                         gpt_node_t delete_node);
+static int gpt_node_delete_replicate(gpt_thunk_t delete_thunk,
+                                     gpt_node_t delete_node);
+static inline int gpt_node_internal_delete(gpt_thunk_t delete_thunk,
+                                           gpt_node_t delete_node);
+static inline void gpt_node_insert_single(gpt_node_t new_node,
+                                          gpt_thunk_t insert_thunk);
+static int gpt_node_insert_replicate(gpt_node_t new_node,
+                                     gpt_thunk_t insert_thunk,
+                                     gpt_node_t insert_node);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
