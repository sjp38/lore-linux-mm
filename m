From: Nick Piggin <npiggin@suse.de>
Message-Id: <20061010121357.19693.7339.sendpatchset@linux.site>
In-Reply-To: <20061010121314.19693.75503.sendpatchset@linux.site>
References: <20061010121314.19693.75503.sendpatchset@linux.site>
Subject: [patch 4/5] mm: add vm_insert_pfn helpler
Date: Tue, 10 Oct 2006 16:22:14 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Add a vm_insert_pfn helper, so that ->fault handlers can have nopfn
functionality by installing their own pte and returning NULL.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -1121,6 +1121,7 @@ unsigned long vmalloc_to_pfn(void *addr)
 int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 			unsigned long pfn, unsigned long size, pgprot_t);
 int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
+int vm_insert_pfn(struct vm_area_struct *, unsigned long addr, unsigned long pfn);
 
 struct page *follow_page(struct vm_area_struct *, unsigned long address,
 			unsigned int foll_flags);
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1267,6 +1267,50 @@ int vm_insert_page(struct vm_area_struct
 }
 EXPORT_SYMBOL(vm_insert_page);
 
+/**
+ * vm_insert_pfn - insert single pfn into user vma
+ * @vma: user vma to map to
+ * @addr: target user address of this page
+ * @pfn: source kernel pfn
+ *
+ * Similar to vm_inert_page, this allows drivers to insert individual pages
+ * they've allocated into a user vma. Same comments apply.
+ *
+ * This function should only be called from a vm_ops->fault handler, and
+ * in that case the handler should return NULL.
+ */
+int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr, unsigned long pfn)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	int retval;
+	pte_t *pte, entry;
+	spinlock_t *ptl;
+
+	BUG_ON(!(vma->vm_flags & VM_PFNMAP));
+	BUG_ON(is_cow_mapping(vma->vm_flags));
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
+	entry = pfn_pte(pfn, vma->vm_page_prot);
+	set_pte_at(mm, addr, pte, entry);
+	update_mmu_cache(vma, addr, entry);
+
+	retval = 0;
+out_unlock:
+	pte_unmap_unlock(pte, ptl);
+
+out:
+	return retval;
+}
+EXPORT_SYMBOL(vm_insert_pfn);
+
 /*
  * maps a range of physical memory into the requested pages. the old
  * mappings are removed. any references to nonexistent pages results

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
