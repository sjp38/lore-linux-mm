Date: Mon, 8 May 2006 23:52:02 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060509065202.24194.21864.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060509065146.24194.47401.sendpatchset@schroedinger.engr.sgi.com>
References: <20060509065146.24194.47401.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 4/5] page migration: Fix up remove_migration_ptes()
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Fix up remove_migration_ptes()

Add the update_mmu/lazy_mmu_update() calls that most arches need
and that IA64 needs for executable pages.

Also move the call to page_address_in_vma into remove_migrate_pte()
and check for the possible -EFAULT return code.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc3-mm1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc3-mm1.orig/mm/migrate.c	2006-05-08 01:46:23.369211137 -0700
+++ linux-2.6.17-rc3-mm1/mm/migrate.c	2006-05-08 23:11:42.859814459 -0700
@@ -123,7 +123,7 @@ static inline int is_swap_pte(pte_t pte)
 /*
  * Restore a potential migration pte to a working pte entry
  */
-static void remove_migration_pte(struct vm_area_struct *vma, unsigned long addr,
+static void remove_migration_pte(struct vm_area_struct *vma,
 		struct page *old, struct page *new)
 {
 	struct mm_struct *mm = vma->vm_mm;
@@ -133,6 +133,10 @@ static void remove_migration_pte(struct 
  	pmd_t *pmd;
 	pte_t *ptep, pte;
  	spinlock_t *ptl;
+	unsigned long addr = page_address_in_vma(new, vma);
+
+	if (addr == -EFAULT)
+		return;
 
  	pgd = pgd_offset(mm, addr);
 	if (!pgd_present(*pgd))
@@ -175,6 +179,10 @@ static void remove_migration_pte(struct 
 	else
 		page_add_file_rmap(new);
 
+	/* No need to invalidate - it was non-present before */
+	update_mmu_cache(vma, addr, pte);
+	lazy_mmu_prot_update(pte);
+
 out:
 	pte_unmap_unlock(ptep, ptl);
 }
@@ -196,7 +204,7 @@ static void remove_file_migration_ptes(s
 	spin_lock(&mapping->i_mmap_lock);
 
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff)
-		remove_migration_pte(vma, page_address_in_vma(new, vma), old, new);
+		remove_migration_pte(vma, old, new);
 
 	spin_unlock(&mapping->i_mmap_lock);
 }
@@ -223,8 +231,7 @@ static void remove_anon_migration_ptes(s
 	spin_lock(&anon_vma->lock);
 
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
-		remove_migration_pte(vma, page_address_in_vma(new, vma),
-					old, new);
+		remove_migration_pte(vma, old, new);
 
 	spin_unlock(&anon_vma->lock);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
