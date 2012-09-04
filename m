Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id A22B66B0070
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 05:21:19 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id ro12so9747862pbb.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 02:21:19 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 6/7] mm: add CONFIG_DEBUG_VM_RB build option
Date: Tue,  4 Sep 2012 02:20:56 -0700
Message-Id: <1346750457-12385-7-git-send-email-walken@google.com>
In-Reply-To: <1346750457-12385-1-git-send-email-walken@google.com>
References: <1346750457-12385-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, riel@redhat.com, peterz@infradead.org, aarcange@redhat.com, hughd@google.com, daniel.santos@pobox.com
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org

Add a CONFIG_DEBUG_VM_RB build option for the previously existing
DEBUG_MM_RB code. Now that Andi Kleen modified it to avoid using
recursive algorithms, we can expose it a bit more.

Also extend this code to validate_mm() after stack expansion, and to
check that the vma's start and last pgoffs have not changed since the
nodes were inserted on the anon vma interval tree (as it is important
that the nodes be reindexed after each such update).

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 include/linux/mm.h   |    3 +++
 include/linux/rmap.h |    3 +++
 lib/Kconfig.debug    |    9 +++++++++
 mm/interval_tree.c   |   41 ++++++++++++++++++++++++++++++++++++++++-
 mm/mmap.c            |   19 +++++++++----------
 5 files changed, 64 insertions(+), 11 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 19d63ec2cbbb..1a2b1a44bd4e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1367,6 +1367,9 @@ struct anon_vma_chain *anon_vma_interval_tree_iter_first(
 	struct rb_root *root, unsigned long start, unsigned long last);
 struct anon_vma_chain *anon_vma_interval_tree_iter_next(
 	struct anon_vma_chain *node, unsigned long start, unsigned long last);
+#ifdef CONFIG_DEBUG_VM_RB
+void anon_vma_interval_tree_verify(struct anon_vma_chain *node);
+#endif
 
 #define anon_vma_interval_tree_foreach(avc, root, start, last)		 \
 	for (avc = anon_vma_interval_tree_iter_first(root, start, last); \
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index dce44f7d3ed8..b2cce644ffc7 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -66,6 +66,9 @@ struct anon_vma_chain {
 	struct list_head same_vma;   /* locked by mmap_sem & page_table_lock */
 	struct rb_node rb;			/* locked by anon_vma->mutex */
 	unsigned long rb_subtree_last;
+#ifdef CONFIG_DEBUG_VM_RB
+	unsigned long cached_vma_start, cached_vma_last;
+#endif
 };
 
 #ifdef CONFIG_MMU
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index eba4b0961187..d261b4555dc5 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -781,6 +781,15 @@ config DEBUG_VM
 
 	  If unsure, say N.
 
+config DEBUG_VM_RB
+	bool "Debug VM red-black trees"
+	depends on DEBUG_VM
+	help
+	  Enable this to turn on more extended checks in the virtual-memory
+	  system that may impact performance.
+
+	  If unsure, say N.
+
 config DEBUG_VIRTUAL
 	bool "Debug VM translations"
 	depends on DEBUG_KERNEL && X86
diff --git a/mm/interval_tree.c b/mm/interval_tree.c
index f7c72cd35e1d..4a5822a586e6 100644
--- a/mm/interval_tree.c
+++ b/mm/interval_tree.c
@@ -70,4 +70,43 @@ static inline unsigned long avc_last_pgoff(struct anon_vma_chain *avc)
 }
 
 INTERVAL_TREE_DEFINE(struct anon_vma_chain, rb, unsigned long, rb_subtree_last,
-		     avc_start_pgoff, avc_last_pgoff,, anon_vma_interval_tree)
+		     avc_start_pgoff, avc_last_pgoff,
+		     static inline, __anon_vma_interval_tree)
+
+void anon_vma_interval_tree_insert(struct anon_vma_chain *node,
+				   struct rb_root *root)
+{
+#ifdef CONFIG_DEBUG_VM_RB
+	node->cached_vma_start = avc_start_pgoff(node);
+	node->cached_vma_last = avc_last_pgoff(node);
+#endif
+	__anon_vma_interval_tree_insert(node, root);
+}
+
+void anon_vma_interval_tree_remove(struct anon_vma_chain *node,
+				   struct rb_root *root)
+{
+	__anon_vma_interval_tree_remove(node, root);
+}
+
+struct anon_vma_chain *
+anon_vma_interval_tree_iter_first(struct rb_root *root,
+				  unsigned long first, unsigned long last)
+{
+	return __anon_vma_interval_tree_iter_first(root, first, last);
+}
+
+struct anon_vma_chain *
+anon_vma_interval_tree_iter_next(struct anon_vma_chain *node,
+				 unsigned long first, unsigned long last)
+{
+	return __anon_vma_interval_tree_iter_next(node, first, last);
+}
+
+#ifdef CONFIG_DEBUG_VM_RB
+void anon_vma_interval_tree_verify(struct anon_vma_chain *node)
+{
+	WARN_ON_ONCE(node->cached_vma_start != avc_start_pgoff(node));
+	WARN_ON_ONCE(node->cached_vma_last != avc_last_pgoff(node));
+}
+#endif
diff --git a/mm/mmap.c b/mm/mmap.c
index 1a6afdb5194a..884bda4cd3ea 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -51,12 +51,6 @@ static void unmap_region(struct mm_struct *mm,
 		struct vm_area_struct *vma, struct vm_area_struct *prev,
 		unsigned long start, unsigned long end);
 
-/*
- * WARNING: the debugging will use recursive algorithms so never enable this
- * unless you know what you are doing.
- */
-#undef DEBUG_MM_RB
-
 /* description of effects of mapping type and prot in current implementation.
  * this is due to the limited x86 page protection hardware.  The expected
  * behavior is in parens:
@@ -306,7 +300,7 @@ out:
 	return retval;
 }
 
-#ifdef DEBUG_MM_RB
+#ifdef CONFIG_DEBUG_VM_RB
 static int browse_rb(struct rb_root *root)
 {
 	int i = 0, j;
@@ -340,9 +334,12 @@ void validate_mm(struct mm_struct *mm)
 {
 	int bug = 0;
 	int i = 0;
-	struct vm_area_struct *tmp = mm->mmap;
-	while (tmp) {
-		tmp = tmp->vm_next;
+	struct vm_area_struct *vma = mm->mmap;
+	while (vma) {
+		struct anon_vma_chain *avc;
+		list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
+			anon_vma_interval_tree_verify(avc);
+		vma = vma->vm_next;
 		i++;
 	}
 	if (i != mm->map_count)
@@ -1805,6 +1802,7 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 	}
 	vma_unlock_anon_vma(vma);
 	khugepaged_enter_vma_merge(vma);
+	validate_mm(vma->vm_mm);
 	return error;
 }
 #endif /* CONFIG_STACK_GROWSUP || CONFIG_IA64 */
@@ -1858,6 +1856,7 @@ int expand_downwards(struct vm_area_struct *vma,
 	}
 	vma_unlock_anon_vma(vma);
 	khugepaged_enter_vma_merge(vma);
+	validate_mm(vma->vm_mm);
 	return error;
 }
 
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
