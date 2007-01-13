From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:47:57 +1100
Message-Id: <20070113024757.29682.60793.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 26/29] Abstract mempolicy iterator cont...
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 26
 * Continue moving default page table mempolicy iterator implementation
 to pt-default.c.
 * abstracted mempolicy_one_pte and placed it in pt_iterator-ops.h
   * moved some macros from mempolicy.c to mempolicy.h to make this possible.

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 include/linux/mempolicy.h       |   10 +++++++++
 include/linux/pt-iterator-ops.h |   43 ++++++++++++++++++++++++++++++++++++++++
 mm/mempolicy.c                  |   20 +++++++-----------
 3 files changed, 61 insertions(+), 12 deletions(-)
Index: linux-2.6.20-rc4/include/linux/pt-iterator-ops.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/pt-iterator-ops.h	2007-01-11 13:38:55.488438000 +1100
+++ linux-2.6.20-rc4/include/linux/pt-iterator-ops.h	2007-01-11 13:39:01.788438000 +1100
@@ -1,6 +1,7 @@
 #include <linux/rmap.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
+#include <linux/mempolicy.h>
 #include <asm/tlb.h>
 
 static inline void add_mm_rss(struct mm_struct *mm, int file_rss, int anon_rss)
@@ -284,3 +285,45 @@
 	}
 }
 
+#ifdef CONFIG_NUMA
+static inline int mempolicy_check_one_pte(struct vm_area_struct *vma, unsigned long addr,
+				pte_t *pte, const nodemask_t *nodes, unsigned long flags,
+				void *private)
+{
+	struct page *page;
+	unsigned int nid;
+
+	if (!pte_present(*pte))
+		return 0;
+	page = vm_normal_page(vma, addr, *pte);
+	if (!page)
+		return 0;
+	if (!page)
+			return 0;
+	/*
+	 * The check for PageReserved here is important to avoid
+	 * handling zero pages and other pages that may have been
+	 * marked special by the system.
+	 *
+	 * If the PageReserved would not be checked here then f.e.
+	 * the location of the zero page could have an influence
+	 * on MPOL_MF_STRICT, zero pages would be counted for
+	 * the per node stats, and there would be useless attempts
+	 * to put zero pages on the migration list.
+	 */
+	if (PageReserved(page))
+		return 0;
+	nid = page_to_nid(page);
+	if (node_isset(nid, *nodes) == !!(flags & MPOL_MF_INVERT))
+		return 0;
+
+	if (flags & MPOL_MF_STATS)
+		gather_stats(page, private, pte_dirty(*pte));
+	else if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
+		migrate_page_add(page, private, flags);
+	else
+		return 1;
+
+	return 0;
+}
+#endif
Index: linux-2.6.20-rc4/include/linux/mempolicy.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/mempolicy.h	2007-01-11 13:30:52.128438000 +1100
+++ linux-2.6.20-rc4/include/linux/mempolicy.h	2007-01-11 13:39:01.788438000 +1100
@@ -59,6 +59,16 @@
  * Copying policy objects:
  * For MPOL_BIND the zonelist must be always duplicated. mpol_clone() does this.
  */
+
+/* Internal flags */
+#define MPOL_MF_DISCONTIG_OK (MPOL_MF_INTERNAL << 0)	/* Skip checks for continuous vmas */
+#define MPOL_MF_INVERT (MPOL_MF_INTERNAL << 1)		/* Invert check for nodemask */
+#define MPOL_MF_STATS (MPOL_MF_INTERNAL << 2)		/* Gather statistics */
+
+void gather_stats(struct page *, void *, int pte_dirty);
+void migrate_page_add(struct page *page, struct list_head *pagelist,
+				unsigned long flags);
+
 struct mempolicy {
 	atomic_t refcnt;
 	short policy; 	/* See MPOL_* above */
Index: linux-2.6.20-rc4/mm/mempolicy.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/mempolicy.c	2007-01-11 13:39:00.152438000 +1100
+++ linux-2.6.20-rc4/mm/mempolicy.c	2007-01-11 13:39:01.792438000 +1100
@@ -89,15 +89,11 @@
 #include <linux/migrate.h>
 #include <linux/rmap.h>
 #include <linux/security.h>
+#include <linux/pt.h>
 
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
 
-/* Internal flags */
-#define MPOL_MF_DISCONTIG_OK (MPOL_MF_INTERNAL << 0)	/* Skip checks for continuous vmas */
-#define MPOL_MF_INVERT (MPOL_MF_INTERNAL << 1)		/* Invert check for nodemask */
-#define MPOL_MF_STATS (MPOL_MF_INTERNAL << 2)		/* Gather statistics */
-
 static struct kmem_cache *policy_cache;
 static struct kmem_cache *sn_cache;
 
@@ -204,8 +200,8 @@
 	return policy;
 }
 
-static void gather_stats(struct page *, void *, int pte_dirty);
-static void migrate_page_add(struct page *page, struct list_head *pagelist,
+void gather_stats(struct page *, void *, int pte_dirty);
+void migrate_page_add(struct page *page, struct list_head *pagelist,
 				unsigned long flags);
 
 /* Check if a vma is migratable */
@@ -257,7 +253,7 @@
 				endvma = end;
 			if (vma->vm_start > start)
 				start = vma->vm_start;
-			err = check_pgd_range(vma, start, endvma, nodes,
+			err = check_policy_read_iterator(vma, start, endvma, nodes,
 						flags, private);
 			if (err) {
 				first = ERR_PTR(err);
@@ -478,7 +474,7 @@
 /*
  * page migration
  */
-static void migrate_page_add(struct page *page, struct list_head *pagelist,
+void migrate_page_add(struct page *page, struct list_head *pagelist,
 				unsigned long flags)
 {
 	/*
@@ -610,7 +606,7 @@
 }
 #else
 
-static void migrate_page_add(struct page *page, struct list_head *pagelist,
+void migrate_page_add(struct page *page, struct list_head *pagelist,
 				unsigned long flags)
 {
 }
@@ -1664,7 +1660,7 @@
 	unsigned long node[MAX_NUMNODES];
 };
 
-static void gather_stats(struct page *page, void *private, int pte_dirty)
+void gather_stats(struct page *page, void *private, int pte_dirty)
 {
 	struct numa_maps *md = private;
 	int count = page_mapcount(page);
@@ -1761,7 +1757,7 @@
 		check_huge_range(vma, vma->vm_start, vma->vm_end, md);
 		seq_printf(m, " huge");
 	} else {
-		check_pgd_range(vma, vma->vm_start, vma->vm_end,
+		check_policy_read_iterator(vma, vma->vm_start, vma->vm_end,
 				&node_online_map, MPOL_MF_STATS, md);
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
