Date: Mon, 7 Jan 2008 05:43:55 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch] mm: use a pte bit to flag normal pages
Message-ID: <20080107044355.GA11222@wotan.suse.de>
References: <20071221104701.GE28484@wotan.suse.de> <OFEC52C590.33A28896-ONC12573B8.0069F07E-C12573B8.006B1A41@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <OFEC52C590.33A28896-ONC12573B8.0069F07E-C12573B8.006B1A41@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <martin.schwidefsky@de.ibm.com>
Cc: carsteno@linux.vnet.ibm.com, Heiko Carstens <h.carstens@de.ibm.com>, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 21, 2007 at 08:29:50PM +0100, Martin Schwidefsky wrote:
> Nick Piggin <npiggin@suse.de> wrote on 12/21/2007 11:47:01 AM:
> > On Fri, Dec 21, 2007 at 11:35:02AM +0100, Carsten Otte wrote:
> > > Nick Piggin wrote:
> > > >But it doesn't still retain sparsemem sections behind that? Ie. so
> that
> > > >pfn_valid could be used? (I admittedly don't know enough eabout the
> memory
> > > >model code).
> > > Not as far as I know. But arch/s390/mm/vmem.c has:
> > >
> > > struct memory_segment {
> > >         struct list_head list;
> > >         unsigned long start;
> > >         unsigned long size;
> > > };
> > >
> > > static LIST_HEAD(mem_segs);
> > >
> > > This is maintained every time we map a segment/unmap a segment. And we
> > > could add a bit to struct memory_segment meaning "refcount this one".
> > > This way, we could tell core mm whether or not a pfn should be
> refcounted.
> >
> > Right, this should work.
> >
> > BTW. having a per-arch function sounds reasonable for a start. I'd just
> give
> > it a long name, so that people don't start using it for weird things ;)
> > mixedmap_refcount_pfn() or something.
> 
> Hmm, I would prefer to have a pte bit, it seem much more natural to me.
> We know that this is a special pte when it gets mapped, but we "forgot"
> that fact when the pte is picked up again in vm_normal_page. To search a
> list when a simple bit in the pte get the job done just feels wrong.
> By the way, for s390 the lower 8 bits of the pte are OS defined. The lowest
> two bits are used in addition to the hardware invalid and the hardware
> read-
> only bit to define the pte type. For valid ptes the remaining 6 bits are
> unused. Pick one, e.g. 2**2 for the bit that says
> "don't-refcount-this-pte".

This would be nice if we can do it, although I would prefer to make everything
work without any pte bits first, in order to make sure all architectures have a
chance at implementing it (although I guess for s390 specific memory map stuff,
it is reasonable for you to do your own thing there...).

We initially wanted to do the whole vm_normal_page thing this way, with another
pte bit, but we thought there were one or two archs with no spare bits. BTW. I
also need this bit in order to implement my lockless get_user_pages, so I do hope
to get it in. I'd like to know what architectures cannot spare a software bit in
their pte_present ptes...

---

Rather than play interesting games with vmas to work out whether the mapped page
should be refcounted or not, use a new bit in the "present" pte to distinguish
such pages.

This allows much simpler "vm_normal_page" implementation, and more flexible rules
for COW pages in pfn mappings (eg. our proposed VM_MIXEDMAP mode would becomes a noop).
It also provides one of the required pieces for the lockless get_user_pages.

Unfortunately, maybe not all architectures can spare a bit in the pte for this.
So we probably have to end up with some ifdefs (if we even want to add this
approach at all). For this reason, I would prefer for now to avoid using a new pte
bit to implement any of this stuff, and get VM_MIXEDMAP and its callers working
nicely on all architectures first.

Thanks,
Nick

---
Index: linux-2.6/include/asm-powerpc/pgtable-ppc64.h
===================================================================
--- linux-2.6.orig/include/asm-powerpc/pgtable-ppc64.h
+++ linux-2.6/include/asm-powerpc/pgtable-ppc64.h
@@ -93,6 +93,7 @@
 #define _PAGE_RW	0x0200 /* software: user write access allowed */
 #define _PAGE_HASHPTE	0x0400 /* software: pte has an associated HPTE */
 #define _PAGE_BUSY	0x0800 /* software: PTE & hash are busy */
+#define _PAGE_SPECIAL	0x1000 /* software: pte associated with special page */
 
 #define _PAGE_BASE	(_PAGE_PRESENT | _PAGE_ACCESSED | _PAGE_COHERENT)
 
@@ -233,12 +234,13 @@ static inline pte_t pfn_pte(unsigned lon
 
 /*
  * The following only work if pte_present() is true.
- * Undefined behaviour if not..
+ * Undefined behaviour if not.. (XXX: comment wrong eg. for pte_file())
  */
 static inline int pte_write(pte_t pte) { return pte_val(pte) & _PAGE_RW;}
 static inline int pte_dirty(pte_t pte) { return pte_val(pte) & _PAGE_DIRTY;}
 static inline int pte_young(pte_t pte) { return pte_val(pte) & _PAGE_ACCESSED;}
 static inline int pte_file(pte_t pte) { return pte_val(pte) & _PAGE_FILE;}
+static inline int pte_special(pte_t pte) { return pte_val(pte) & _PAGE_SPECIAL; }
 
 static inline void pte_uncache(pte_t pte) { pte_val(pte) |= _PAGE_NO_CACHE; }
 static inline void pte_cache(pte_t pte)   { pte_val(pte) &= ~_PAGE_NO_CACHE; }
@@ -257,6 +259,8 @@ static inline pte_t pte_mkyoung(pte_t pt
 	pte_val(pte) |= _PAGE_ACCESSED; return pte; }
 static inline pte_t pte_mkhuge(pte_t pte) {
 	return pte; }
+static inline pte_t pte_mkspecial(pte_t pte) {
+	pte_val(pte) |= _PAGE_SPECIAL; return pte; }
 
 /* Atomic PTE updates */
 static inline unsigned long pte_update(struct mm_struct *mm,
Index: linux-2.6/include/asm-um/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-um/pgtable.h
+++ linux-2.6/include/asm-um/pgtable.h
@@ -21,6 +21,7 @@
 #define _PAGE_USER	0x040
 #define _PAGE_ACCESSED	0x080
 #define _PAGE_DIRTY	0x100
+#define _PAGE_SPECIAL	0x200
 /* If _PAGE_PRESENT is clear, we use these: */
 #define _PAGE_FILE	0x008	/* nonlinear file mapping, saved PTE; unset:swap */
 #define _PAGE_PROTNONE	0x010	/* if the user mapped it with PROT_NONE;
@@ -220,6 +221,11 @@ static inline int pte_newprot(pte_t pte)
 	return(pte_present(pte) && (pte_get_bits(pte, _PAGE_NEWPROT)));
 }
 
+static inline int pte_special(pte_t pte)
+{
+	return pte_get_bits(pte, _PAGE_SPECIAL);
+}
+
 /*
  * =================================
  * Flags setting section.
@@ -288,6 +294,12 @@ static inline pte_t pte_mknewpage(pte_t 
 	return(pte);
 }
 
+static inline pte_t pte_mkspecial(pte_t pte)
+{
+	pte_set_bits(pte, _PAGE_SPECIAL);
+	return(pte);
+}
+
 static inline void set_pte(pte_t *pteptr, pte_t pteval)
 {
 	pte_copy(*pteptr, pteval);
Index: linux-2.6/include/asm-x86/pgtable_32.h
===================================================================
--- linux-2.6.orig/include/asm-x86/pgtable_32.h
+++ linux-2.6/include/asm-x86/pgtable_32.h
@@ -102,6 +102,7 @@ void paging_init(void);
 #define _PAGE_BIT_UNUSED2	10
 #define _PAGE_BIT_UNUSED3	11
 #define _PAGE_BIT_NX		63
+#define _PAGE_BIT_SPECIAL	_PAGE_BIT_UNUSED1
 
 #define _PAGE_PRESENT	0x001
 #define _PAGE_RW	0x002
@@ -115,6 +116,7 @@ void paging_init(void);
 #define _PAGE_UNUSED1	0x200	/* available for programmer */
 #define _PAGE_UNUSED2	0x400
 #define _PAGE_UNUSED3	0x800
+#define _PAGE_SPECIAL	PAGE_UNUSED1
 
 /* If _PAGE_PRESENT is clear, we use these: */
 #define _PAGE_FILE	0x040	/* nonlinear file mapping, saved PTE; unset:swap */
@@ -219,6 +221,7 @@ static inline int pte_dirty(pte_t pte)		
 static inline int pte_young(pte_t pte)		{ return (pte).pte_low & _PAGE_ACCESSED; }
 static inline int pte_write(pte_t pte)		{ return (pte).pte_low & _PAGE_RW; }
 static inline int pte_huge(pte_t pte)		{ return (pte).pte_low & _PAGE_PSE; }
+static inline int pte_special(pte_t pte)	{ return (pte).pte_low & _PAGE_SPECIAL; }
 
 /*
  * The following only works if pte_present() is not true.
@@ -232,6 +235,7 @@ static inline pte_t pte_mkdirty(pte_t pt
 static inline pte_t pte_mkyoung(pte_t pte)	{ (pte).pte_low |= _PAGE_ACCESSED; return pte; }
 static inline pte_t pte_mkwrite(pte_t pte)	{ (pte).pte_low |= _PAGE_RW; return pte; }
 static inline pte_t pte_mkhuge(pte_t pte)	{ (pte).pte_low |= _PAGE_PSE; return pte; }
+static inline pte_t pte_mkspecial(pte_t pte)	{ (pte).pte_low |= _PAGE_SPECIAL; return pte; }
 
 #ifdef CONFIG_X86_PAE
 # include <asm/pgtable-3level.h>
Index: linux-2.6/include/asm-x86/pgtable_64.h
===================================================================
--- linux-2.6.orig/include/asm-x86/pgtable_64.h
+++ linux-2.6/include/asm-x86/pgtable_64.h
@@ -151,6 +151,7 @@ static inline pte_t ptep_get_and_clear_f
 #define _PAGE_BIT_DIRTY		6
 #define _PAGE_BIT_PSE		7	/* 4 MB (or 2MB) page */
 #define _PAGE_BIT_GLOBAL	8	/* Global TLB entry PPro+ */
+#define _PAGE_BIT_SPECIAL	9
 #define _PAGE_BIT_NX           63       /* No execute: only valid after cpuid check */
 
 #define _PAGE_PRESENT	0x001
@@ -163,6 +164,7 @@ static inline pte_t ptep_get_and_clear_f
 #define _PAGE_PSE	0x080	/* 2MB page */
 #define _PAGE_FILE	0x040	/* nonlinear file mapping, saved PTE; unset:swap */
 #define _PAGE_GLOBAL	0x100	/* Global TLB entry */
+#define _PAGE_SPECIAL	0x200
 
 #define _PAGE_PROTNONE	0x080	/* If not present */
 #define _PAGE_NX        (_AC(1,UL)<<_PAGE_BIT_NX)
@@ -272,6 +274,7 @@ static inline int pte_young(pte_t pte)		
 static inline int pte_write(pte_t pte)		{ return pte_val(pte) & _PAGE_RW; }
 static inline int pte_file(pte_t pte)		{ return pte_val(pte) & _PAGE_FILE; }
 static inline int pte_huge(pte_t pte)		{ return pte_val(pte) & _PAGE_PSE; }
+static inline int pte_special(pte_t pte)	{ return pte_val(pte) & _PAGE_SPECIAL; }
 
 static inline pte_t pte_mkclean(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_DIRTY)); return pte; }
 static inline pte_t pte_mkold(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_ACCESSED)); return pte; }
@@ -282,6 +285,7 @@ static inline pte_t pte_mkyoung(pte_t pt
 static inline pte_t pte_mkwrite(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_RW)); return pte; }
 static inline pte_t pte_mkhuge(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_PSE)); return pte; }
 static inline pte_t pte_clrhuge(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_PSE)); return pte; }
+static inline pte_t pte_mkspecial(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_SPECIAL)); return pte; }
 
 struct vm_area_struct;
 
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -698,7 +698,20 @@ struct zap_details {
 	unsigned long truncate_count;		/* Compare vm_truncate_count */
 };
 
-struct page *vm_normal_page(struct vm_area_struct *, unsigned long, pte_t);
+/*
+ * This function gets the "struct page" associated with a pte.
+ *
+ * "Special" mappings do not wish to be associated with a "struct page" (either
+ * it doesn't exist, or it exists but they don't want to touch it). In this
+ * case, NULL is returned here.
+ */
+static inline struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr, pte_t pte)
+{
+	if (likely(!pte_special(pte)))
+		return pte_page(pte);
+	return NULL;
+}
+
 unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *);
 unsigned long unmap_vmas(struct mmu_gather **tlb,
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -361,64 +361,10 @@ static inline int is_cow_mapping(unsigne
 }
 
 /*
- * This function gets the "struct page" associated with a pte.
- *
- * NOTE! Some mappings do not have "struct pages". A raw PFN mapping
- * will have each page table entry just pointing to a raw page frame
- * number, and as far as the VM layer is concerned, those do not have
- * pages associated with them - even if the PFN might point to memory
- * that otherwise is perfectly fine and has a "struct page".
- *
- * The way we recognize those mappings is through the rules set up
- * by "remap_pfn_range()": the vma will have the VM_PFNMAP bit set,
- * and the vm_pgoff will point to the first PFN mapped: thus every
- * page that is a raw mapping will always honor the rule
- *
- *	pfn_of_page == vma->vm_pgoff + ((addr - vma->vm_start) >> PAGE_SHIFT)
- *
- * and if that isn't true, the page has been COW'ed (in which case it
- * _does_ have a "struct page" associated with it even if it is in a
- * VM_PFNMAP range).
- */
-struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr, pte_t pte)
-{
-	unsigned long pfn = pte_pfn(pte);
-
-	if (unlikely(vma->vm_flags & VM_PFNMAP)) {
-		unsigned long off = (addr - vma->vm_start) >> PAGE_SHIFT;
-		if (pfn == vma->vm_pgoff + off)
-			return NULL;
-		if (!is_cow_mapping(vma->vm_flags))
-			return NULL;
-	}
-
-	/*
-	 * Add some anal sanity checks for now. Eventually,
-	 * we should just do "return pfn_to_page(pfn)", but
-	 * in the meantime we check that we get a valid pfn,
-	 * and that the resulting page looks ok.
-	 */
-	if (unlikely(!pfn_valid(pfn))) {
-		print_bad_pte(vma, pte, addr);
-		return NULL;
-	}
-
-	/*
-	 * NOTE! We still have PageReserved() pages in the page 
-	 * tables. 
-	 *
-	 * The PAGE_ZERO() pages and various VDSO mappings can
-	 * cause them to exist.
-	 */
-	return pfn_to_page(pfn);
-}
-
-/*
  * copy one vm_area from one task to the other. Assumes the page tables
  * already present in the new task to be cleared in the whole range
  * covered by this vma.
  */
-
 static inline void
 copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		pte_t *dst_pte, pte_t *src_pte, struct vm_area_struct *vma,
@@ -1212,7 +1158,6 @@ int vm_insert_pfn(struct vm_area_struct 
 	spinlock_t *ptl;
 
 	BUG_ON(!(vma->vm_flags & VM_PFNMAP));
-	BUG_ON(is_cow_mapping(vma->vm_flags));
 
 	retval = -ENOMEM;
 	pte = get_locked_pte(mm, addr, &ptl);
@@ -1223,7 +1168,7 @@ int vm_insert_pfn(struct vm_area_struct 
 		goto out_unlock;
 
 	/* Ok, finally just insert the thing.. */
-	entry = pfn_pte(pfn, vma->vm_page_prot);
+	entry = pte_mkspecial(pfn_pte(pfn, vma->vm_page_prot));
 	set_pte_at(mm, addr, pte, entry);
 	update_mmu_cache(vma, addr, entry);
 
@@ -1254,7 +1199,7 @@ static int remap_pte_range(struct mm_str
 	arch_enter_lazy_mmu_mode();
 	do {
 		BUG_ON(!pte_none(*pte));
-		set_pte_at(mm, addr, pte, pfn_pte(pfn, prot));
+		set_pte_at(mm, addr, pte, pte_mkspecial(pfn_pte(pfn, prot)));
 		pfn++;
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	arch_leave_lazy_mmu_mode();
@@ -1321,30 +1266,6 @@ int remap_pfn_range(struct vm_area_struc
 	struct mm_struct *mm = vma->vm_mm;
 	int err;
 
-	/*
-	 * Physically remapped pages are special. Tell the
-	 * rest of the world about it:
-	 *   VM_IO tells people not to look at these pages
-	 *	(accesses can have side effects).
-	 *   VM_RESERVED is specified all over the place, because
-	 *	in 2.4 it kept swapout's vma scan off this vma; but
-	 *	in 2.6 the LRU scan won't even find its pages, so this
-	 *	flag means no more than count its pages in reserved_vm,
-	 * 	and omit it from core dump, even when VM_IO turned off.
-	 *   VM_PFNMAP tells the core MM that the base pages are just
-	 *	raw PFN mappings, and do not have a "struct page" associated
-	 *	with them.
-	 *
-	 * There's a horrible special case to handle copy-on-write
-	 * behaviour that some programs depend on. We mark the "original"
-	 * un-COW'ed pages by matching them up with "vma->vm_pgoff".
-	 */
-	if (is_cow_mapping(vma->vm_flags)) {
-		if (addr != vma->vm_start || end != vma->vm_end)
-			return -EINVAL;
-		vma->vm_pgoff = pfn;
-	}
-
 	vma->vm_flags |= VM_IO | VM_RESERVED | VM_PFNMAP;
 
 	BUG_ON(addr >= end);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
