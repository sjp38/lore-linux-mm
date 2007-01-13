From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:45:56 +1100
Message-Id: <20070113024556.29682.39765.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 3/29] Abstract current page table implementation
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 03
 * Continues to move default page table functionality from mm.h to
 pt-default-mm.h.
   * moves macros eg: pte_offset_map_lock, pte_alloc_map etc.

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 mm.h            |   50 ++------------------------------------------------
 pt-default-mm.h |   49 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 51 insertions(+), 48 deletions(-)
Index: linux-2.6.20-rc4/include/linux/mm.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/mm.h	2007-01-11 13:11:05.387868000 +1100
+++ linux-2.6.20-rc4/include/linux/mm.h	2007-01-11 13:11:10.387868000 +1100
@@ -851,55 +851,9 @@
 
 extern pte_t *FASTCALL(get_locked_pte(struct mm_struct *mm, unsigned long addr, spinlock_t **ptl));
 
+#ifdef CONFIG_PT_DEFAULT
 #include <linux/pt-default-mm.h>
-
-#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
-/*
- * We tuck a spinlock to guard each pagetable page into its struct page,
- * at page->private, with BUILD_BUG_ON to make sure that this will not
- * overflow into the next struct page (as it might with DEBUG_SPINLOCK).
- * When freeing, reset page->mapping so free_pages_check won't complain.
- */
-#define __pte_lockptr(page)	&((page)->ptl)
-#define pte_lock_init(_page)	do {					\
-	spin_lock_init(__pte_lockptr(_page));				\
-} while (0)
-#define pte_lock_deinit(page)	((page)->mapping = NULL)
-#define pte_lockptr(mm, pmd)	({(void)(mm); __pte_lockptr(pmd_page(*(pmd)));})
-#else
-/*
- * We use mm->page_table_lock to guard all pagetable pages of the mm.
- */
-#define pte_lock_init(page)	do {} while (0)
-#define pte_lock_deinit(page)	do {} while (0)
-#define pte_lockptr(mm, pmd)	({(void)(pmd); &(mm)->page_table_lock;})
-#endif /* NR_CPUS < CONFIG_SPLIT_PTLOCK_CPUS */
-
-#define pte_offset_map_lock(mm, pmd, address, ptlp)	\
-({							\
-	spinlock_t *__ptl = pte_lockptr(mm, pmd);	\
-	pte_t *__pte = pte_offset_map(pmd, address);	\
-	*(ptlp) = __ptl;				\
-	spin_lock(__ptl);				\
-	__pte;						\
-})
-
-#define pte_unmap_unlock(pte, ptl)	do {		\
-	spin_unlock(ptl);				\
-	pte_unmap(pte);					\
-} while (0)
-
-#define pte_alloc_map(mm, pmd, address)			\
-	((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, pmd, address))? \
-		NULL: pte_offset_map(pmd, address))
-
-#define pte_alloc_map_lock(mm, pmd, address, ptlp)	\
-	((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, pmd, address))? \
-		NULL: pte_offset_map_lock(mm, pmd, address, ptlp))
-
-#define pte_alloc_kernel(pmd, address)			\
-	((unlikely(!pmd_present(*(pmd))) && __pte_alloc_kernel(pmd, address))? \
-		NULL: pte_offset_kernel(pmd, address))
+#endif
 
 extern void free_area_init(unsigned long * zones_size);
 extern void free_area_init_node(int nid, pg_data_t *pgdat,
Index: linux-2.6.20-rc4/include/linux/pt-default-mm.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/pt-default-mm.h	2007-01-11 13:09:08.155868000 +1100
+++ linux-2.6.20-rc4/include/linux/pt-default-mm.h	2007-01-11 13:11:10.391868000 +1100
@@ -24,4 +24,53 @@
 }
 #endif /* CONFIG_MMU && !__ARCH_HAS_4LEVEL_HACK */
 
+#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
+/*
+ * We tuck a spinlock to guard each pagetable page into its struct page,
+ * at page->private, with BUILD_BUG_ON to make sure that this will not
+ * overflow into the next struct page (as it might with DEBUG_SPINLOCK).
+ * When freeing, reset page->mapping so free_pages_check won't complain.
+ */
+#define __pte_lockptr(page)	&((page)->ptl)
+#define pte_lock_init(_page)	do {					\
+	spin_lock_init(__pte_lockptr(_page));				\
+} while (0)
+#define pte_lock_deinit(page)	((page)->mapping = NULL)
+#define pte_lockptr(mm, pmd)	({(void)(mm); __pte_lockptr(pmd_page(*(pmd)));})
+#else
+/*
+ * We use mm->page_table_lock to guard all pagetable pages of the mm.
+ */
+#define pte_lock_init(page)	do {} while (0)
+#define pte_lock_deinit(page)	do {} while (0)
+#define pte_lockptr(mm, pmd)	({(void)(pmd); &(mm)->page_table_lock;})
+#endif /* NR_CPUS < CONFIG_SPLIT_PTLOCK_CPUS */
+
+#define pte_offset_map_lock(mm, pmd, address, ptlp)	\
+({							\
+	spinlock_t *__ptl = pte_lockptr(mm, pmd);	\
+	pte_t *__pte = pte_offset_map(pmd, address);	\
+	*(ptlp) = __ptl;				\
+	spin_lock(__ptl);				\
+	__pte;						\
+})
+
+#define pte_unmap_unlock(pte, ptl)	do {		\
+	spin_unlock(ptl);				\
+	pte_unmap(pte);					\
+} while (0)
+
+#define pte_alloc_map(mm, pmd, address)			\
+	((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, pmd, address))? \
+		NULL: pte_offset_map(pmd, address))
+
+#define pte_alloc_map_lock(mm, pmd, address, ptlp)	\
+	((unlikely(!pmd_present(*(pmd))) && __pte_alloc(mm, pmd, address))? \
+		NULL: pte_offset_map_lock(mm, pmd, address, ptlp))
+
+#define pte_alloc_kernel(pmd, address)			\
+	((unlikely(!pmd_present(*(pmd))) && __pte_alloc_kernel(pmd, address))? \
+		NULL: pte_offset_kernel(pmd, address))
+
+
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
