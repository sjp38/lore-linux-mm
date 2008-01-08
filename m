Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id m089Zubm433590
	for <linux-mm@kvack.org>; Tue, 8 Jan 2008 09:35:56 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m089Zue52773170
	for <linux-mm@kvack.org>; Tue, 8 Jan 2008 10:35:56 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m089Zugs025962
	for <linux-mm@kvack.org>; Tue, 8 Jan 2008 10:35:56 +0100
Subject: [rfc][patch 1/4] mm: introduce VM_MIXEDMAP
From: Carsten Otte <cotte@de.ibm.com>
In-Reply-To: <1199784196.25114.11.camel@cotte.boeblingen.de.ibm.com>
References: <20071214133817.GB28555@wotan.suse.de>
	 <20071214134106.GC28555@wotan.suse.de> <476A73F0.4070704@de.ibm.com>
	 <476A7D21.7070607@de.ibm.com> <20071221004556.GB31040@wotan.suse.de>
	 <476B9000.2090707@de.ibm.com> <20071221102052.GB28484@wotan.suse.de>
	 <476B96D6.2010302@de.ibm.com>  <20071221104701.GE28484@wotan.suse.de>
	 <1199784196.25114.11.camel@cotte.boeblingen.de.ibm.com>
Content-Type: text/plain
Date: Tue, 08 Jan 2008 10:35:56 +0100
Message-Id: <1199784956.25114.28.camel@cotte.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Jared Hulbert <jaredeh@gmail.com>
From: Carsten Otte <cotte@de.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: carsteno@de.ibm.com, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, Heiko Carstens <h.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

mm: introduce VM_MIXEDMAP

Introduce a new type of mapping, VM_MIXEDMAP. This is unlike VM_PFNMAP in
that it can support COW mappings of arbitrary ranges including ranges without
struct page (PFNMAP can only support COW in those cases where the un-COW-ed
translations are mapped linearly in the virtual address).

VM_MIXEDMAP achieves this by refcounting pages with mixedmap_refcount_pfn(pfn)
being non-zero, and not refcounting !mixedmap_refcount_pfn(pfn) pages
(which is not an option for VM_PFNMAP, because it needs to avoid refcounting
pfn_valid pages eg. for /dev/mem mappings).

Signed-off-by: Carsten Otte <cotte@de.ibm.com>
--- 
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -106,6 +106,7 @@ extern unsigned int kobjsize(const void 
 #define VM_ALWAYSDUMP	0x04000000	/* Always include in core dumps */
 
 #define VM_CAN_NONLINEAR 0x08000000	/* Has ->fault & does nonlinear pages */
+#define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN pages */
 
 #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
 #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -361,35 +361,66 @@ static inline int is_cow_mapping(unsigne
 }
 
 /*
- * This function gets the "struct page" associated with a pte.
+ * This function gets the "struct page" associated with a pte or returns
+ * NULL if no "struct page" is associated with the pte.
  *
- * NOTE! Some mappings do not have "struct pages". A raw PFN mapping
- * will have each page table entry just pointing to a raw page frame
- * number, and as far as the VM layer is concerned, those do not have
- * pages associated with them - even if the PFN might point to memory
+ * A raw VM_PFNMAP mapping (ie. one that is not COWed) may not have any "struct
+ * page" backing, and even if they do, they are not refcounted. COWed pages of
+ * a VM_PFNMAP do always have a struct page, and they are normally refcounted
+ * (they are _normal_ pages).
+ *
+ * So a raw PFNMAP mapping will have each page table entry just pointing
+ * to a page frame number, and as far as the VM layer is concerned, those do
+ * not have pages associated with them - even if the PFN might point to memory
  * that otherwise is perfectly fine and has a "struct page".
  *
- * The way we recognize those mappings is through the rules set up
- * by "remap_pfn_range()": the vma will have the VM_PFNMAP bit set,
- * and the vm_pgoff will point to the first PFN mapped: thus every
+ * The way we recognize COWed pages within VM_PFNMAP mappings is through the
+ * rules set up by "remap_pfn_range()": the vma will have the VM_PFNMAP bit
+ * set, and the vm_pgoff will point to the first PFN mapped: thus every
  * page that is a raw mapping will always honor the rule
  *
  *	pfn_of_page == vma->vm_pgoff + ((addr - vma->vm_start) >> PAGE_SHIFT)
  *
- * and if that isn't true, the page has been COW'ed (in which case it
- * _does_ have a "struct page" associated with it even if it is in a
- * VM_PFNMAP range).
+ * A call to vm_normal_page() will return NULL for such a page.
+ *
+ * If the page doesn't follow the "remap_pfn_range()" rule in a VM_PFNMAP
+ * then the page has been COW'ed.  A COW'ed page _does_ have a "struct page"
+ * associated with it even if it is in a VM_PFNMAP range.  Calling
+ * vm_normal_page() on such a page will therefore return the "struct page".
+ *
+ *
+ * VM_MIXEDMAP mappings can likewise contain memory with or without "struct
+ * page" backing, however the difference is that _all_ pages with a struct
+ * page (that is, those where mixedmap_refcount_pfn is true) are refcounted
+ * and considered
+ * and considered normal pages by the VM. The disadvantage is that pages are
+ * refcounted (which can be slower and simply not an option for some PFNMAP
+ * users). The advantage is that we don't have to follow the strict linearity
+ * rule of PFNMAP mappings in order to support COWable mappings.
+ *
+ * A call to vm_normal_page() with a VM_MIXEDMAP mapping will return the
+ * associated "struct page" or NULL for memory not backed by a "struct page".
+ *
+ *
+ * All other mappings should have a valid struct page, which will be
+ * returned by a call to vm_normal_page().
  */
 struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr, pte_t pte)
 {
 	unsigned long pfn = pte_pfn(pte);
 
-	if (unlikely(vma->vm_flags & VM_PFNMAP)) {
-		unsigned long off = (addr - vma->vm_start) >> PAGE_SHIFT;
-		if (pfn == vma->vm_pgoff + off)
-			return NULL;
-		if (!is_cow_mapping(vma->vm_flags))
-			return NULL;
+	if (unlikely(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP))) {
+		if (vma->vm_flags & VM_MIXEDMAP) {
+			if (!mixedmap_refcount_pfn(pfn))
+				return NULL;
+			goto out;
+		} else {
+			unsigned long off = (addr-vma->vm_start) >> PAGE_SHIFT;
+			if (pfn == vma->vm_pgoff + off)
+				return NULL;
+			if (!is_cow_mapping(vma->vm_flags))
+				return NULL;
+		}
 	}
 
 	/*
@@ -410,6 +441,7 @@ struct page *vm_normal_page(struct vm_ar
 	 * The PAGE_ZERO() pages and various VDSO mappings can
 	 * cause them to exist.
 	 */
+out:
 	return pfn_to_page(pfn);
 }
 
@@ -1211,8 +1243,11 @@ int vm_insert_pfn(struct vm_area_struct 
 	pte_t *pte, entry;
 	spinlock_t *ptl;
 
-	BUG_ON(!(vma->vm_flags & VM_PFNMAP));
-	BUG_ON(is_cow_mapping(vma->vm_flags));
+	BUG_ON(!(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)));
+	BUG_ON((vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) ==
+						(VM_PFNMAP|VM_MIXEDMAP));
+	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
+	BUG_ON((vma->vm_flags & VM_MIXEDMAP) && mixedmap_refcount_pfn(pfn));
 
 	retval = -ENOMEM;
 	pte = get_locked_pte(mm, addr, &ptl);
@@ -2386,10 +2421,13 @@ static noinline int do_no_pfn(struct mm_
 	unsigned long pfn;
 
 	pte_unmap(page_table);
-	BUG_ON(!(vma->vm_flags & VM_PFNMAP));
-	BUG_ON(is_cow_mapping(vma->vm_flags));
+	BUG_ON(!(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)));
+	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
 
 	pfn = vma->vm_ops->nopfn(vma, address & PAGE_MASK);
+
+	BUG_ON((vma->vm_flags & VM_MIXEDMAP) && mixedmap_refcount_pfn(pfn));
+
 	if (unlikely(pfn == NOPFN_OOM))
 		return VM_FAULT_OOM;
 	else if (unlikely(pfn == NOPFN_SIGBUS))


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
