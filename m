Received: by rv-out-0910.google.com with SMTP id l15so732940rvb
        for <linux-mm@kvack.org>; Fri, 16 Nov 2007 15:42:24 -0800 (PST)
Message-ID: <6934efce0711161542n1f73d96au7d0bfababd856098@mail.gmail.com>
Date: Fri, 16 Nov 2007 15:42:24 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: [RFC] Changing VM_PFNMAP assumptions and rules
In-Reply-To: <200711140426.51614.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <6934efce0711091115i3f859a00id0b869742029b661@mail.gmail.com>
	 <200711132308.08739.nickpiggin@yahoo.com.au>
	 <6934efce0711131729i4539d1cewf84974ea459f8e0f@mail.gmail.com>
	 <200711140426.51614.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: benh@kernel.crashing.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> And because /dev/mem is out of the picture, so is the requirement of
> mapping pfn_valid() pages without refcounting them. The sketch I gave
> in the first post *should* be on the right way
>
> I can write the patch for you if you like, but if you'd like a shot at
> it, that would be great!


I haven't tested this yet and this mailer is broken, I'm just hoping
to get a little visual review.

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 520238c..bc1e627 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -105,6 +105,7 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_ALWAYSDUMP	0x04000000	/* Always include in core dumps */

 #define VM_CAN_NONLINEAR 0x08000000	/* Has ->fault & does nonlinear pages */
+#define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure
PFN pages */

 #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
 #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
diff --git a/mm/memory.c b/mm/memory.c
index 4bf0b6d..9b3a8ee 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -361,30 +361,46 @@ static inline int is_cow_mapping(unsigned int flags)
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
- * that otherwise is perfectly fine and has a "struct page".
+ * VM_PFNMAP mappings do not have "struct pages" with exception of COW'ed
+ * pages. A raw PFN mapping will have each page table entry just pointing
+ * to a raw page frame number, and as far as the VM layer is concerned,
+ * those do not have pages associated with them - even if the PFN might
+ * point to memory that otherwise is perfectly fine and has a "struct page".
  *
- * The way we recognize those mappings is through the rules set up
+ * The way we recognize VM_PFNMAP mappings is through the rules set up
  * by "remap_pfn_range()": the vma will have the VM_PFNMAP bit set,
  * and the vm_pgoff will point to the first PFN mapped: thus every
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
+ * VM_MIXEDMAP mappings can contain pages that either are raw PFN
+ * mappings or normal pages with associated "struct page".  Raw PFN mappings
+ * in a VM_MIXEDMAP do not need to follow the "remap_pfn_range()" rules.
+ * A call to vm_normal_page() with a VM_MIXEDMAP mapping will return the
+ * associated "struct page" or NULL for memory not backed by a "struct page".
  */
 struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long
addr, pte_t pte)
 {
 	unsigned long pfn = pte_pfn(pte);

-	if (unlikely(vma->vm_flags & VM_PFNMAP)) {
+	if (unlikely(vma->vm_flags & VM_PFNMAP|VM_MIXEDMAP)) {
+		if (vma->vm_flags & VM_MIXEDMAP) {
+			if (!pfn_valid(pfn))
+				return NULL;
+			return pfn_to_page(pfn);
+		}
+
 		unsigned long off = (addr - vma->vm_start) >> PAGE_SHIFT;
 		if (pfn == vma->vm_pgoff + off)
 			return NULL;
@@ -1211,8 +1227,9 @@ int vm_insert_pfn(struct vm_area_struct *vma,
unsigned long addr,
 	pte_t *pte, entry;
 	spinlock_t *ptl;

-	BUG_ON(!(vma->vm_flags & VM_PFNMAP));
-	BUG_ON(is_cow_mapping(vma->vm_flags));
+	BUG_ON(!(vma->vm_flags & VM_PFNMAP|VM_MIXEDMAP));
+	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
+	BUG_ON((vma->vm_flags & VM_MIXEDMAP) && pfn_valid(pfn));

 	retval = -ENOMEM;
 	pte = get_locked_pte(mm, addr, &ptl);
@@ -2386,8 +2403,9 @@ static noinline int do_no_pfn(struct mm_struct
*mm, struct vm_area_struct *vma,
 	unsigned long pfn;

 	pte_unmap(page_table);
-	BUG_ON(!(vma->vm_flags & VM_PFNMAP));
-	BUG_ON(is_cow_mapping(vma->vm_flags));
+	BUG_ON(!(vma->vm_flags & VM_PFNMAP|VM_MIXEDMAP));
+	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
+	BUG_ON((vma->vm_flags & VM_MIXEDMAP) && pfn_valid(pfn));

 	pfn = vma->vm_ops->nopfn(vma, address & PAGE_MASK);
 	if (unlikely(pfn == NOPFN_OOM))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
