Message-Id: <20080328015422.124542000@nick.local0.net>
References: <20080328015238.519230000@nick.local0.net>
Date: Fri, 28 Mar 2008 12:52:41 +1100
From: npiggin@suse.de
Subject: [patch 3/7] mm: add vm_insert_mixed
Content-Disposition: inline; filename=mm-insert_mixed.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jared Hulbert <jaredeh@gmail.com>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

vm_insert_mixed will insert either a raw pfn or a refcounted struct page
into the page tables, depending on whether vm_normal_page() will return
the page or not. With the introduction of the new pte bit, this is now
a too tricky for drivers to be doing themselves.

filemap_xip uses this in a subsequent patch.

Signed-off-by: Nick Piggin <npiggin@suse.de>
Cc: Jared Hulbert <jaredeh@gmail.com>
Cc: Carsten Otte <cotte@de.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm@kvack.org
---
 include/linux/mm.h |    2 +
 mm/memory.c        |   79 ++++++++++++++++++++++++++++++++++++-----------------
 2 files changed, 57 insertions(+), 24 deletions(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -1148,6 +1148,8 @@ int remap_pfn_range(struct vm_area_struc
 int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
 int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
+int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
+			unsigned long pfn);
 
 struct page *follow_page(struct vm_area_struct *, unsigned long address,
 			unsigned int foll_flags);
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1176,8 +1176,10 @@ pte_t *get_locked_pte(struct mm_struct *
  * old drivers should use this, and they needed to mark their
  * pages reserved for the old functions anyway.
  */
-static int insert_page(struct mm_struct *mm, unsigned long addr, struct page *page, pgprot_t prot)
+static int insert_page(struct vm_area_struct *vma, unsigned long addr,
+			struct page *page, pgprot_t prot)
 {
+	struct mm_struct *mm = vma->vm_mm;
 	int retval;
 	pte_t *pte;
 	spinlock_t *ptl;
@@ -1237,17 +1239,46 @@ out:
  *
  * The page does not need to be reserved.
  */
-int vm_insert_page(struct vm_area_struct *vma, unsigned long addr, struct page *page)
+int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
+			struct page *page)
 {
 	if (addr < vma->vm_start || addr >= vma->vm_end)
 		return -EFAULT;
 	if (!page_count(page))
 		return -EINVAL;
 	vma->vm_flags |= VM_INSERTPAGE;
-	return insert_page(vma->vm_mm, addr, page, vma->vm_page_prot);
+	return insert_page(vma, addr, page, vma->vm_page_prot);
 }
 EXPORT_SYMBOL(vm_insert_page);
 
+static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
+			unsigned long pfn, pgprot_t prot)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	int retval;
+	pte_t *pte, entry;
+	spinlock_t *ptl;
+
+	retval = -ENOMEM;
+	pte = get_locked_pte(mm, addr, &ptl);
+	if (!pte)
+		goto out;
+	retval = -EBUSY;
+	if (!pte_none(*pte))
+		goto out_unlock;
+
+	/* Ok, finally just insert the thing.. */
+	entry = pte_mkspecial(pfn_pte(pfn, prot));
+	set_pte_at(mm, addr, pte, entry);
+	update_mmu_cache(vma, addr, entry); /* XXX: why not for insert_page? */
+
+	retval = 0;
+out_unlock:
+	pte_unmap_unlock(pte, ptl);
+out:
+	return retval;
+}
+
 /**
  * vm_insert_pfn - insert single pfn into user vma
  * @vma: user vma to map to
@@ -1261,13 +1292,8 @@ EXPORT_SYMBOL(vm_insert_page);
  * in that case the handler should return NULL.
  */
 int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
-		unsigned long pfn)
+			unsigned long pfn)
 {
-	struct mm_struct *mm = vma->vm_mm;
-	int retval;
-	pte_t *pte, entry;
-	spinlock_t *ptl;
-
 	/*
 	 * Technically, architectures with pte_special can avoid all these
 	 * restrictions (same for remap_pfn_range).  However we would like
@@ -1280,27 +1306,35 @@ int vm_insert_pfn(struct vm_area_struct 
 	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
 	BUG_ON((vma->vm_flags & VM_MIXEDMAP) && pfn_valid(pfn));
 
-	retval = -ENOMEM;
-	pte = get_locked_pte(mm, addr, &ptl);
-	if (!pte)
-		goto out;
-	retval = -EBUSY;
-	if (!pte_none(*pte))
-		goto out_unlock;
+	if (addr < vma->vm_start || addr >= vma->vm_end)
+		return -EFAULT;
+	return insert_pfn(vma, addr, pfn, vma->vm_page_prot);
+}
+EXPORT_SYMBOL(vm_insert_pfn);
 
-	/* Ok, finally just insert the thing.. */
-	entry = pte_mkspecial(pfn_pte(pfn, vma->vm_page_prot));
-	set_pte_at(mm, addr, pte, entry);
-	update_mmu_cache(vma, addr, entry);
+int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
+			unsigned long pfn)
+{
+	BUG_ON(!(vma->vm_flags & VM_MIXEDMAP));
 
-	retval = 0;
-out_unlock:
-	pte_unmap_unlock(pte, ptl);
+	if (addr < vma->vm_start || addr >= vma->vm_end)
+		return -EFAULT;
 
-out:
-	return retval;
+	/*
+	 * If we don't have pte special, then we have to use the pfn_valid()
+	 * based VM_MIXEDMAP scheme (see vm_normal_page), and thus we *must*
+	 * refcount the page if pfn_valid is true (hence insert_page rather
+	 * than insert_pfn).
+	 */
+	if (!HAVE_PTE_SPECIAL && pfn_valid(pfn)) {
+		struct page *page;
+
+		page = pfn_to_page(pfn);
+		return insert_page(vma, addr, page, vma->vm_page_prot);
+	}
+	return insert_pfn(vma, addr, pfn, vma->vm_page_prot);
 }
-EXPORT_SYMBOL(vm_insert_pfn);
+EXPORT_SYMBOL(vm_insert_mixed);
 
 /*
  * maps a range of physical memory into the requested pages. the old

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
