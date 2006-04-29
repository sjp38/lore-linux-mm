Date: Fri, 28 Apr 2006 20:23:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060429032327.4999.78463.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
References: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 1/3] Swapless PM: add R/W migration entries
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

swapless page migration: Implement read/write migration ptes

We take the upper two swapfiles for the two types of migration ptes
and define a series of macros in swapops.h.

The VM is modified to handle the migration entries. migration entries
can only be encountered when the page they are pointing to is locked.
This limits the number of places one has to fix. We also check in
copy_pte_range and in mprotect_pte_range() for migration ptes.

We check for migration ptes in do_swap_cache and call a function
that will then wait on the page lock. This allows us to effectively
stop all accesses to apge.

Migration entries are created by try_to_unmap if called for migration
and removed by local functions in migrate.c


Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc3/include/linux/swap.h
===================================================================
--- linux-2.6.17-rc3.orig/include/linux/swap.h	2006-04-28 20:20:19.104969106 -0700
+++ linux-2.6.17-rc3/include/linux/swap.h	2006-04-28 20:20:35.501412608 -0700
@@ -29,7 +29,14 @@
  * the type/offset into the pte as 5/27 as well.
  */
 #define MAX_SWAPFILES_SHIFT	5
+#ifndef CONFIG_MIGRATION
 #define MAX_SWAPFILES		(1 << MAX_SWAPFILES_SHIFT)
+#else
+/* Use last entry for page migration swap entries */
+#define MAX_SWAPFILES		((1 << MAX_SWAPFILES_SHIFT)-2)
+#define SWP_MIGRATION_READ	MAX_SWAPFILES
+#define SWP_MIGRATION_WRITE	(MAX_SWAPFILES + 1)
+#endif
 
 /*
  * Magic header for a swap area. The first part of the union is
Index: linux-2.6.17-rc3/include/linux/swapops.h
===================================================================
--- linux-2.6.17-rc3.orig/include/linux/swapops.h	2006-04-26 19:19:25.000000000 -0700
+++ linux-2.6.17-rc3/include/linux/swapops.h	2006-04-28 20:20:35.502389109 -0700
@@ -67,3 +67,56 @@
 	BUG_ON(pte_file(__swp_entry_to_pte(arch_entry)));
 	return __swp_entry_to_pte(arch_entry);
 }
+
+#ifdef CONFIG_MIGRATION
+static inline swp_entry_t make_migration_entry(struct page *page, int write)
+{
+	BUG_ON(!PageLocked(page));
+	return swp_entry(write ? SWP_MIGRATION_WRITE : SWP_MIGRATION_READ,
+			page_to_pfn(page));
+}
+
+static inline int is_migration_entry(swp_entry_t entry)
+{
+	return unlikely(swp_type(entry) == SWP_MIGRATION_READ ||
+			swp_type(entry) == SWP_MIGRATION_WRITE);
+}
+
+static inline int is_write_migration_entry(swp_entry_t entry)
+{
+	return unlikely(swp_type(entry) == SWP_MIGRATION_WRITE);
+}
+
+static inline struct page *migration_entry_to_page(swp_entry_t entry)
+{
+	struct page *p = pfn_to_page(swp_offset(entry));
+	/*
+	 * Any use of migration entries may only occur while the
+	 * corresponding page is locked
+	 */
+	BUG_ON(!PageLocked(p));
+	return p;
+}
+
+static inline void make_migration_entry_read(swp_entry_t *entry)
+{
+	*entry = swp_entry(SWP_MIGRATION_READ, swp_offset(*entry));
+}
+
+extern void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
+					unsigned long address);
+#else
+
+#define make_migration_entry(page, write) swp_entry(0, 0)
+#define is_migration_entry(swp) 0
+#define migration_entry_to_page(swp) NULL
+static inline void make_migration_entry_read(swp_entry_t *entryp) { }
+static inline void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
+					 unsigned long address) { }
+static inline int is_write_migration_entry(swp_entry_t entry)
+{
+	return 0;
+}
+
+#endif
+
Index: linux-2.6.17-rc3/mm/swapfile.c
===================================================================
--- linux-2.6.17-rc3.orig/mm/swapfile.c	2006-04-28 20:20:19.487757853 -0700
+++ linux-2.6.17-rc3/mm/swapfile.c	2006-04-28 20:20:35.503365611 -0700
@@ -395,6 +395,9 @@
 	struct swap_info_struct * p;
 	struct page *page = NULL;
 
+	if (is_migration_entry(entry))
+		return;
+
 	p = swap_info_get(entry);
 	if (p) {
 		if (swap_entry_free(p, swp_offset(entry)) == 1) {
@@ -1702,6 +1705,9 @@
 	unsigned long offset, type;
 	int result = 0;
 
+	if (is_migration_entry(entry))
+		return 1;
+
 	type = swp_type(entry);
 	if (type >= nr_swapfiles)
 		goto bad_file;
Index: linux-2.6.17-rc3/mm/rmap.c
===================================================================
--- linux-2.6.17-rc3.orig/mm/rmap.c	2006-04-28 20:20:25.123150353 -0700
+++ linux-2.6.17-rc3/mm/rmap.c	2006-04-28 20:20:35.504342113 -0700
@@ -620,17 +620,27 @@
 
 	if (PageAnon(page)) {
 		swp_entry_t entry = { .val = page_private(page) };
-		/*
-		 * Store the swap location in the pte.
-		 * See handle_pte_fault() ...
-		 */
-		BUG_ON(!PageSwapCache(page));
-		swap_duplicate(entry);
-		if (list_empty(&mm->mmlist)) {
-			spin_lock(&mmlist_lock);
-			if (list_empty(&mm->mmlist))
-				list_add(&mm->mmlist, &init_mm.mmlist);
-			spin_unlock(&mmlist_lock);
+
+		if (PageSwapCache(page)) {
+			/*
+			 * Store the swap location in the pte.
+			 * See handle_pte_fault() ...
+			 */
+			swap_duplicate(entry);
+			if (list_empty(&mm->mmlist)) {
+				spin_lock(&mmlist_lock);
+				if (list_empty(&mm->mmlist))
+					list_add(&mm->mmlist, &init_mm.mmlist);
+				spin_unlock(&mmlist_lock);
+			}
+		} else {
+			/*
+			 * Store the pfn of the page in a special migration
+			 * pte. do_swap_page() will wait until the migration
+			 * pte is removed and then restart fault handling.
+			 */
+			BUG_ON(!migration);
+			entry = make_migration_entry(page, pte_write(pteval));
 		}
 		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
 		BUG_ON(pte_file(*pte));
Index: linux-2.6.17-rc3/mm/migrate.c
===================================================================
--- linux-2.6.17-rc3.orig/mm/migrate.c	2006-04-28 20:20:30.437273724 -0700
+++ linux-2.6.17-rc3/mm/migrate.c	2006-04-28 20:20:35.505318615 -0700
@@ -15,6 +15,7 @@
 #include <linux/migrate.h>
 #include <linux/module.h>
 #include <linux/swap.h>
+#include <linux/swapops.h>
 #include <linux/pagemap.h>
 #include <linux/buffer_head.h>
 #include <linux/mm_inline.h>
@@ -23,7 +24,6 @@
 #include <linux/topology.h>
 #include <linux/cpu.h>
 #include <linux/cpuset.h>
-#include <linux/swapops.h>
 
 #include "internal.h"
 
@@ -119,6 +119,136 @@
 	return count;
 }
 
+static inline int is_swap_pte(pte_t pte)
+{
+	return !pte_none(pte) && !pte_present(pte) && !pte_file(pte);
+}
+
+/*
+ * Restore a potential migration pte to a working pte entry for
+ * anonymous pages.
+ */
+static void remove_migration_pte(struct vm_area_struct *vma, unsigned long addr,
+		struct page *old, struct page *new)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	swp_entry_t entry;
+ 	pgd_t *pgd;
+ 	pud_t *pud;
+ 	pmd_t *pmd;
+	pte_t *ptep, pte;
+ 	spinlock_t *ptl;
+
+ 	pgd = pgd_offset(mm, addr);
+	if (!pgd_present(*pgd))
+                return;
+
+	pud = pud_offset(pgd, addr);
+	if (!pud_present(*pud))
+                return;
+
+	pmd = pmd_offset(pud, addr);
+	if (!pmd_present(*pmd))
+		return;
+
+	ptep = pte_offset_map(pmd, addr);
+
+	if (!is_swap_pte(*ptep)) {
+		pte_unmap(ptep);
+ 		return;
+ 	}
+
+ 	ptl = pte_lockptr(mm, pmd);
+ 	spin_lock(ptl);
+	pte = *ptep;
+	if (!is_swap_pte(pte))
+		goto out;
+
+	entry = pte_to_swp_entry(pte);
+
+	if (!is_migration_entry(entry) || migration_entry_to_page(entry) != old)
+		goto out;
+
+	inc_mm_counter(mm, anon_rss);
+	get_page(new);
+	pte = pte_mkold(mk_pte(new, vma->vm_page_prot));
+	if (is_write_migration_entry(entry))
+		pte = pte_mkwrite(pte);
+	set_pte_at(mm, addr, ptep, pte);
+	page_add_anon_rmap(new, vma, addr);
+out:
+	pte_unmap_unlock(pte, ptl);
+}
+
+/*
+ * Get rid of all migration entries and replace them by
+ * references to the indicated page.
+ *
+ * Must hold mmap_sem lock on at least one of the vmas containing
+ * the page so that the anon_vma cannot vanish.
+ */
+static void remove_migration_ptes(struct page *old, struct page *new)
+{
+	struct anon_vma *anon_vma;
+	struct vm_area_struct *vma;
+	unsigned long mapping;
+
+	mapping = (unsigned long)new->mapping;
+
+	if (!mapping || (mapping & PAGE_MAPPING_ANON) == 0)
+		return;
+
+	/*
+	 * We hold the mmap_sem lock. So no need to call page_lock_anon_vma.
+	 */
+	anon_vma = (struct anon_vma *) (mapping - PAGE_MAPPING_ANON);
+	spin_lock(&anon_vma->lock);
+
+	list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
+		remove_migration_pte(vma, page_address_in_vma(new, vma),
+					old, new);
+
+	spin_unlock(&anon_vma->lock);
+}
+
+/*
+ * Something used the pte of a page under migration. We need to
+ * get to the page and wait until migration is finished.
+ * When we return from this function the fault will be retried.
+ *
+ * This function is called from do_swap_page().
+ */
+void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
+				unsigned long address)
+{
+	pte_t *ptep, pte;
+	spinlock_t *ptl;
+	swp_entry_t entry;
+	struct page *page;
+
+	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
+	pte = *ptep;
+	if (!is_swap_pte(pte))
+		goto out;
+
+	entry = pte_to_swp_entry(pte);
+	if (!is_migration_entry(entry))
+		goto out;
+
+	page = migration_entry_to_page(entry);
+
+	/* Pages with migration entries are always locked */
+	BUG_ON(!PageLocked(page));
+
+	get_page(page);
+	pte_unmap_unlock(ptep, ptl);
+	wait_on_page_locked(page);
+	put_page(page);
+	return;
+out:
+	pte_unmap_unlock(ptep, ptl);
+}
+
 /*
  * swapout a single page
  * page is locked upon entry, unlocked on exit
Index: linux-2.6.17-rc3/mm/memory.c
===================================================================
--- linux-2.6.17-rc3.orig/mm/memory.c	2006-04-28 20:20:19.437956256 -0700
+++ linux-2.6.17-rc3/mm/memory.c	2006-04-28 20:21:17.571067703 -0700
@@ -434,7 +434,9 @@
 	/* pte contains position in swap or file, so copy. */
 	if (unlikely(!pte_present(pte))) {
 		if (!pte_file(pte)) {
-			swap_duplicate(pte_to_swp_entry(pte));
+			swp_entry_t entry = pte_to_swp_entry(pte);
+
+			swap_duplicate(entry);
 			/* make sure dst_mm is on swapoff's mmlist. */
 			if (unlikely(list_empty(&dst_mm->mmlist))) {
 				spin_lock(&mmlist_lock);
@@ -443,6 +445,19 @@
 						 &src_mm->mmlist);
 				spin_unlock(&mmlist_lock);
 			}
+			if (is_migration_entry(entry) &&
+					is_cow_mapping(vm_flags)) {
+				page = migration_entry_to_page(entry);
+
+				/*
+				 * COW mappings require pages in both parent
+				*  and child to be set to read.
+				 */
+				entry = make_migration_entry(page,
+							SWP_MIGRATION_READ);
+				pte = swp_entry_to_pte(entry);
+				set_pte_at(src_mm, addr, src_pte, pte);
+			}
 		}
 		goto out_set_pte;
 	}
@@ -1879,6 +1894,10 @@
 		goto out;
 
 	entry = pte_to_swp_entry(orig_pte);
+	if (is_migration_entry(entry)) {
+		migration_entry_wait(mm, pmd, address);
+		goto out;
+	}
 	page = lookup_swap_cache(entry);
 	if (!page) {
  		swapin_readahead(entry, address, vma);
Index: linux-2.6.17-rc3/mm/mprotect.c
===================================================================
--- linux-2.6.17-rc3.orig/mm/mprotect.c	2006-04-28 20:20:19.450650781 -0700
+++ linux-2.6.17-rc3/mm/mprotect.c	2006-04-28 20:20:35.508248121 -0700
@@ -19,7 +19,8 @@
 #include <linux/mempolicy.h>
 #include <linux/personality.h>
 #include <linux/syscalls.h>
-
+#include <linux/swap.h>
+#include <linux/swapops.h>
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
@@ -28,12 +29,13 @@
 static void change_pte_range(struct mm_struct *mm, pmd_t *pmd,
 		unsigned long addr, unsigned long end, pgprot_t newprot)
 {
-	pte_t *pte;
+	pte_t *pte, oldpte;
 	spinlock_t *ptl;
 
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	do {
-		if (pte_present(*pte)) {
+		oldpte = *pte;
+		if (pte_present(oldpte)) {
 			pte_t ptent;
 
 			/* Avoid an SMP race with hardware updated dirty/clean
@@ -43,7 +45,20 @@
 			ptent = pte_modify(ptep_get_and_clear(mm, addr, pte), newprot);
 			set_pte_at(mm, addr, pte, ptent);
 			lazy_mmu_prot_update(ptent);
+		} else if (!pte_file(oldpte)) {
+			swp_entry_t entry = pte_to_swp_entry(oldpte);
+
+			if (is_write_migration_entry(entry)) {
+				/*
+				 * A protection check is difficult so
+				 * just be safe and disable write
+				 */
+				make_migration_entry_read(&entry);
+				set_pte_at(mm, addr, pte,
+					swp_entry_to_pte(entry));
+			}
 		}
+
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	pte_unmap_unlock(pte - 1, ptl);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
