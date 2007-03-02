Date: Thu, 1 Mar 2007 18:46:34 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: vma_migratable fix
Message-ID: <Pine.LNX.4.64.0703011845430.5497@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Page migration: Fix vma flag checking

Currently we do not check for vma flags if sys_move_pages is called to move
individual pages. If sys_migrate_pages is called to move pages then we
check for vm_flags that indicate a non migratable vma but that still
includes VM_LOCKED and we can migrate mlocked pages.

Extract the vma_migratable check from mm/mempolicy.c, fix it and put it
into migrate.h so that is can be used from both locations.

Problem was spotted by Lee Schermerhorn

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.21-rc2/include/linux/migrate.h
===================================================================
--- linux-2.6.21-rc2.orig/include/linux/migrate.h	2007-03-01 11:48:12.000000000 -0800
+++ linux-2.6.21-rc2/include/linux/migrate.h	2007-03-01 11:48:54.000000000 -0800
@@ -5,6 +5,14 @@
 
 typedef struct page *new_page_t(struct page *, unsigned long private, int **);
 
+/* Check if a vma is migratable */
+static inline int vma_migratable(struct vm_area_struct *vma)
+{
+	if (vma->vm_flags & (VM_IO|VM_HUGETLB|VM_PFNMAP|VM_RESERVED))
+		return 0;
+	return 1;
+}
+
 #ifdef CONFIG_MIGRATION
 extern int isolate_lru_page(struct page *p, struct list_head *pagelist);
 extern int putback_lru_pages(struct list_head *l);
Index: linux-2.6.21-rc2/mm/mempolicy.c
===================================================================
--- linux-2.6.21-rc2.orig/mm/mempolicy.c	2007-03-01 11:48:00.000000000 -0800
+++ linux-2.6.21-rc2/mm/mempolicy.c	2007-03-01 11:48:08.000000000 -0800
@@ -321,15 +321,6 @@ static inline int check_pgd_range(struct
 	return 0;
 }
 
-/* Check if a vma is migratable */
-static inline int vma_migratable(struct vm_area_struct *vma)
-{
-	if (vma->vm_flags & (
-		VM_LOCKED|VM_IO|VM_HUGETLB|VM_PFNMAP|VM_RESERVED))
-		return 0;
-	return 1;
-}
-
 /*
  * Check if all pages in a range are on a set of nodes.
  * If pagelist != NULL then isolate pages from the LRU and
Index: linux-2.6.21-rc2/mm/migrate.c
===================================================================
--- linux-2.6.21-rc2.orig/mm/migrate.c	2007-03-01 11:47:32.000000000 -0800
+++ linux-2.6.21-rc2/mm/migrate.c	2007-03-01 11:49:49.000000000 -0800
@@ -781,7 +781,7 @@ static int do_move_pages(struct mm_struc
 
 		err = -EFAULT;
 		vma = find_vma(mm, pp->addr);
-		if (!vma)
+		if (!vma || !vma_migratable(vma))
 			goto set_status;
 
 		page = follow_page(vma, pp->addr, FOLL_GET);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
