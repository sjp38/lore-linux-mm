Date: Wed, 16 Jan 2008 15:29:15 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [rft] updated xip patch rollup
Message-ID: <20080116142915.GA19162@wotan.suse.de>
References: <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com> <1199891032.28689.9.camel@cotte.boeblingen.de.ibm.com> <1199891645.28689.22.camel@cotte.boeblingen.de.ibm.com> <6934efce0801091017t7f9041abs62904de3722cadc@mail.gmail.com> <4785D064.1040501@de.ibm.com> <6934efce0801101201t72e9b7c4ra88d6fda0f08b1b2@mail.gmail.com> <47872CA7.40802@de.ibm.com> <20080113024410.GA22285@wotan.suse.de> <1200402350.27120.28.camel@cotte.boeblingen.de.ibm.com> <20080116042205.GB29681@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080116042205.GB29681@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Carsten Otte <cotte@de.ibm.com>
Cc: carsteno@de.ibm.com, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 16, 2008 at 05:22:06AM +0100, Nick Piggin wrote:
> 
> Although it could be *possible* to implement pfn_valid as such, I
> agree that we should allow the option of using pte_special. I think it
> is quite reasonable to want to have a runtime-dynamic data structure
> of memory regions like s390, and I don't think VM_MIXEDMAP is such a
> slowpath that we can just say "it's fine to take a global lock and
> search a long list for each fault". Eg. because if you have your
> distro running out of there, then every exec()/exit()/etc is going to
> do this hundreds of times.
> 
> So I'm convinced. And thanks for spending the time to help me with
> that ;)

Hi guys,

I'm just lumping all these patches together, sorry... I just want to
get something out that can be tested, and it is time for bed so I didn't
get around to making a proper patchset. It's against mainline.

Nothing major changed since you've last seen it. It is a rollup of
everything, with vm_normal_page and vm_insert_mixed etc. stuff in
mm/memory.c, and the vm_insert_mixed caller in mm/filemap_xip.c having
all the real changes.

I've tested it with XIP on brd on x86, both with and without pte_special.
This covers many (but not all) cases of refcounting.

Anyway, here it is... assuming no problems, I'll work on making the
patchset. I'm still hoping we can convince Linus to like it ;)

Is this all still looking OK for you, Jared?

Thanks,
Nick


Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -361,55 +361,97 @@ static inline int is_cow_mapping(unsigne
 }
 
 /*
- * This function gets the "struct page" associated with a pte.
+ * vm_normal_page -- This function gets the "struct page" associated with a pte.
  *
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
+ * "Special" mappings do not wish to be associated with a "struct page" (either
+ * it doesn't exist, or it exists but they don't want to touch it). In this
+ * case, NULL is returned here. "Normal" mappings do have a struct page.
+ *
+ * There are 2 broad cases. Firstly, an architecture may define a pte_special()
+ * pte bit, in which case this function is trivial. Secondly, an architecture
+ * may not have a spare pte bit, which requires a more complicated scheme,
+ * described below.
+ *
+ * A raw VM_PFNMAP mapping (ie. one that is not COWed) is always considered a
+ * special mapping (even if there are underlying and valid "struct pages").
+ * COWed pages of a VM_PFNMAP are always normal.
+ *
+ * The way we recognize COWed pages within VM_PFNMAP mappings is through the
+ * rules set up by "remap_pfn_range()": the vma will have the VM_PFNMAP bit
+ * set, and the vm_pgoff will point to the first PFN mapped: thus every special
+ * mapping will always honor the rule
  *
  *	pfn_of_page == vma->vm_pgoff + ((addr - vma->vm_start) >> PAGE_SHIFT)
  *
- * and if that isn't true, the page has been COW'ed (in which case it
- * _does_ have a "struct page" associated with it even if it is in a
- * VM_PFNMAP range).
+ * And for normal mappings this is false.
+ *
+ * This restricts such mappings to be a linear translation from virtual address
+ * to pfn. To get around this restriction, we allow arbitrary mappings so long
+ * as the vma is not a COW mapping; in that case, we know that all ptes are
+ * special (because none can have been COWed).
+ *
+ *
+ * In order to support COW of arbitrary special mappings, we have VM_MIXEDMAP.
+ *
+ * VM_MIXEDMAP mappings can likewise contain memory with or without "struct
+ * page" backing, however the difference is that _all_ pages with a struct
+ * page (that is, those where pfn_valid is true) are refcounted and considered
+ * normal pages by the VM. The disadvantage is that pages are refcounted
+ * (which can be slower and simply not an option for some PFNMAP users). The
+ * advantage is that we don't have to follow the strict linearity rule of
+ * PFNMAP mappings in order to support COWable mappings.
+ *
  */
+#ifdef __HAVE_ARCH_PTE_SPECIAL
+# define __HAVE_PTE_SPECIAL 1
+#else
+# define __HAVE_PTE_SPECIAL 0
+#endif
 struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr, pte_t pte)
 {
-	unsigned long pfn = pte_pfn(pte);
+	unsigned long pfn;
+
+	if (__HAVE_PTE_SPECIAL) {
+		if (likely(!pte_special(pte))) {
+			VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
+			return pte_page(pte);
+		}
+		VM_BUG_ON(!(vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP)));
+		return NULL;
+	}
+
+	/* !__HAVE_PTE_SPECIAL case follows: */
+
+	pfn = pte_pfn(pte);
 
-	if (unlikely(vma->vm_flags & VM_PFNMAP)) {
-		unsigned long off = (addr - vma->vm_start) >> PAGE_SHIFT;
-		if (pfn == vma->vm_pgoff + off)
-			return NULL;
-		if (!is_cow_mapping(vma->vm_flags))
-			return NULL;
+	if (unlikely(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP))) {
+		if (vma->vm_flags & VM_MIXEDMAP) {
+			if (!pfn_valid(pfn))
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
 
-	/*
-	 * Add some anal sanity checks for now. Eventually,
-	 * we should just do "return pfn_to_page(pfn)", but
-	 * in the meantime we check that we get a valid pfn,
-	 * and that the resulting page looks ok.
-	 */
+#ifdef CONFIG_DEBUG_VM
+	/* Check that we get a valid pfn. */
 	if (unlikely(!pfn_valid(pfn))) {
 		print_bad_pte(vma, pte, addr);
 		return NULL;
 	}
+#endif
 
 	/*
-	 * NOTE! We still have PageReserved() pages in the page 
-	 * tables. 
+	 * NOTE! We still have PageReserved() pages in the page tables.
 	 *
-	 * The PAGE_ZERO() pages and various VDSO mappings can
-	 * cause them to exist.
+	 * eg. VDSO mappings can cause them to exist.
 	 */
+out:
 	return pfn_to_page(pfn);
 }
 
@@ -1127,8 +1169,9 @@ pte_t * fastcall get_locked_pte(struct m
  * old drivers should use this, and they needed to mark their
  * pages reserved for the old functions anyway.
  */
-static int insert_page(struct mm_struct *mm, unsigned long addr, struct page *page, pgprot_t prot)
+static int insert_page(struct vm_area_struct *vma, unsigned long addr, struct page *page, pgprot_t prot)
 {
+	struct mm_struct *mm = vma->vm_mm;
 	int retval;
 	pte_t *pte;
 	spinlock_t *ptl;  
@@ -1187,33 +1230,17 @@ int vm_insert_page(struct vm_area_struct
 	if (!page_count(page))
 		return -EINVAL;
 	vma->vm_flags |= VM_INSERTPAGE;
-	return insert_page(vma->vm_mm, addr, page, vma->vm_page_prot);
+	return insert_page(vma, addr, page, vma->vm_page_prot);
 }
 EXPORT_SYMBOL(vm_insert_page);
 
-/**
- * vm_insert_pfn - insert single pfn into user vma
- * @vma: user vma to map to
- * @addr: target user address of this page
- * @pfn: source kernel pfn
- *
- * Similar to vm_inert_page, this allows drivers to insert individual pages
- * they've allocated into a user vma. Same comments apply.
- *
- * This function should only be called from a vm_ops->fault handler, and
- * in that case the handler should return NULL.
- */
-int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
-		unsigned long pfn)
+static int insert_pfn(struct vm_area_struct *vma, unsigned long addr, unsigned long pfn, pgprot_t prot)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	int retval;
 	pte_t *pte, entry;
 	spinlock_t *ptl;
 
-	BUG_ON(!(vma->vm_flags & VM_PFNMAP));
-	BUG_ON(is_cow_mapping(vma->vm_flags));
-
 	retval = -ENOMEM;
 	pte = get_locked_pte(mm, addr, &ptl);
 	if (!pte)
@@ -1223,19 +1250,74 @@ int vm_insert_pfn(struct vm_area_struct 
 		goto out_unlock;
 
 	/* Ok, finally just insert the thing.. */
-	entry = pfn_pte(pfn, vma->vm_page_prot);
+	entry = pte_mkspecial(pfn_pte(pfn, prot));
 	set_pte_at(mm, addr, pte, entry);
-	update_mmu_cache(vma, addr, entry);
+	update_mmu_cache(vma, addr, entry); /* XXX: why not for insert_page? */
 
 	retval = 0;
 out_unlock:
 	pte_unmap_unlock(pte, ptl);
-
 out:
 	return retval;
 }
+
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
+int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
+		unsigned long pfn)
+{
+	/*
+	 * Technically, architectures with pte_special can avoid all these
+	 * restrictions (same for remap_pfn_range).  However we would like
+	 * consistency in testing and feature parity among all, so we should
+	 * try to keep these invariants in place for everybody.
+	 */
+	BUG_ON(!(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)));
+	BUG_ON((vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) ==
+						(VM_PFNMAP|VM_MIXEDMAP));
+	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
+	BUG_ON((vma->vm_flags & VM_MIXEDMAP) && pfn_valid(pfn));
+
+	if (addr < vma->vm_start || addr >= vma->vm_end)
+		return -EFAULT;
+	return insert_pfn(vma, addr, pfn, vma->vm_page_prot);
+}
 EXPORT_SYMBOL(vm_insert_pfn);
 
+int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
+			unsigned long pfn)
+{
+	BUG_ON(!(vma->vm_flags & VM_MIXEDMAP));
+
+	if (addr < vma->vm_start || addr >= vma->vm_end)
+		return -EFAULT;
+
+	/*
+	 * If we don't have pte special, then we have to use the pfn_valid()
+	 * based VM_MIXEDMAP scheme (see vm_normal_page), and thus we *must*
+	 * refcount the page if pfn_valid is true (hence insert_page rather
+	 * than insert_pfn).
+	 */
+	if (!__HAVE_PTE_SPECIAL && pfn_valid(pfn)) {
+		struct page *page;
+
+		page = pfn_to_page(pfn);
+		return insert_page(vma, addr, page, vma->vm_page_prot);
+	}
+	return insert_pfn(vma, addr, pfn, vma->vm_page_prot);
+}
+EXPORT_SYMBOL(vm_insert_mixed);
+
 /*
  * maps a range of physical memory into the requested pages. the old
  * mappings are removed. any references to nonexistent pages results
@@ -1254,7 +1336,7 @@ static int remap_pte_range(struct mm_str
 	arch_enter_lazy_mmu_mode();
 	do {
 		BUG_ON(!pte_none(*pte));
-		set_pte_at(mm, addr, pte, pfn_pte(pfn, prot));
+		set_pte_at(mm, addr, pte, pte_mkspecial(pfn_pte(pfn, prot)));
 		pfn++;
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	arch_leave_lazy_mmu_mode();
@@ -2386,10 +2468,13 @@ static noinline int do_no_pfn(struct mm_
 	unsigned long pfn;
 
 	pte_unmap(page_table);
-	BUG_ON(!(vma->vm_flags & VM_PFNMAP));
-	BUG_ON(is_cow_mapping(vma->vm_flags));
+	BUG_ON(!(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)));
+	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
 
 	pfn = vma->vm_ops->nopfn(vma, address & PAGE_MASK);
+
+	BUG_ON((vma->vm_flags & VM_MIXEDMAP) && pfn_valid(pfn));
+
 	if (unlikely(pfn == NOPFN_OOM))
 		return VM_FAULT_OOM;
 	else if (unlikely(pfn == NOPFN_SIGBUS))
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
@@ -698,7 +699,8 @@ struct zap_details {
 	unsigned long truncate_count;		/* Compare vm_truncate_count */
 };
 
-struct page *vm_normal_page(struct vm_area_struct *, unsigned long, pte_t);
+struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr, pte_t pte);
+
 unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *);
 unsigned long unmap_vmas(struct mmu_gather **tlb,
@@ -1095,6 +1097,8 @@ int remap_pfn_range(struct vm_area_struc
 int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
 int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
+int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
+			unsigned long pfn);
 
 struct page *follow_page(struct vm_area_struct *, unsigned long address,
 			unsigned int foll_flags);
Index: linux-2.6/include/asm-um/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-um/pgtable.h
+++ linux-2.6/include/asm-um/pgtable.h
@@ -21,6 +21,8 @@
 #define _PAGE_USER	0x040
 #define _PAGE_ACCESSED	0x080
 #define _PAGE_DIRTY	0x100
+#define _PAGE_SPECIAL	0x200
+#define __HAVE_ARCH_PTE_SPECIAL
 /* If _PAGE_PRESENT is clear, we use these: */
 #define _PAGE_FILE	0x008	/* nonlinear file mapping, saved PTE; unset:swap */
 #define _PAGE_PROTNONE	0x010	/* if the user mapped it with PROT_NONE;
@@ -220,6 +222,11 @@ static inline int pte_newprot(pte_t pte)
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
@@ -288,6 +295,12 @@ static inline pte_t pte_mknewpage(pte_t 
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
@@ -115,6 +116,8 @@ void paging_init(void);
 #define _PAGE_UNUSED1	0x200	/* available for programmer */
 #define _PAGE_UNUSED2	0x400
 #define _PAGE_UNUSED3	0x800
+#define _PAGE_SPECIAL	PAGE_UNUSED1
+#define __HAVE_ARCH_PTE_SPECIAL
 
 /* If _PAGE_PRESENT is clear, we use these: */
 #define _PAGE_FILE	0x040	/* nonlinear file mapping, saved PTE; unset:swap */
@@ -219,6 +222,7 @@ static inline int pte_dirty(pte_t pte)		
 static inline int pte_young(pte_t pte)		{ return (pte).pte_low & _PAGE_ACCESSED; }
 static inline int pte_write(pte_t pte)		{ return (pte).pte_low & _PAGE_RW; }
 static inline int pte_huge(pte_t pte)		{ return (pte).pte_low & _PAGE_PSE; }
+static inline int pte_special(pte_t pte)	{ return (pte).pte_low & _PAGE_SPECIAL; }
 
 /*
  * The following only works if pte_present() is not true.
@@ -232,6 +236,7 @@ static inline pte_t pte_mkdirty(pte_t pt
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
@@ -163,6 +164,8 @@ static inline pte_t ptep_get_and_clear_f
 #define _PAGE_PSE	0x080	/* 2MB page */
 #define _PAGE_FILE	0x040	/* nonlinear file mapping, saved PTE; unset:swap */
 #define _PAGE_GLOBAL	0x100	/* Global TLB entry */
+#define _PAGE_SPECIAL	0x200
+#define __HAVE_ARCH_PTE_SPECIAL
 
 #define _PAGE_PROTNONE	0x080	/* If not present */
 #define _PAGE_NX        (_AC(1,UL)<<_PAGE_BIT_NX)
@@ -272,6 +275,7 @@ static inline int pte_young(pte_t pte)		
 static inline int pte_write(pte_t pte)		{ return pte_val(pte) & _PAGE_RW; }
 static inline int pte_file(pte_t pte)		{ return pte_val(pte) & _PAGE_FILE; }
 static inline int pte_huge(pte_t pte)		{ return pte_val(pte) & _PAGE_PSE; }
+static inline int pte_special(pte_t pte)	{ return pte_val(pte) & _PAGE_SPECIAL; }
 
 static inline pte_t pte_mkclean(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_DIRTY)); return pte; }
 static inline pte_t pte_mkold(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_ACCESSED)); return pte; }
@@ -282,6 +286,7 @@ static inline pte_t pte_mkyoung(pte_t pt
 static inline pte_t pte_mkwrite(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_RW)); return pte; }
 static inline pte_t pte_mkhuge(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_PSE)); return pte; }
 static inline pte_t pte_clrhuge(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_PSE)); return pte; }
+static inline pte_t pte_mkspecial(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_SPECIAL)); return pte; }
 
 struct vm_area_struct;
 
Index: linux-2.6/include/asm-alpha/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-alpha/pgtable.h
+++ linux-2.6/include/asm-alpha/pgtable.h
@@ -268,6 +268,7 @@ extern inline int pte_write(pte_t pte)		
 extern inline int pte_dirty(pte_t pte)		{ return pte_val(pte) & _PAGE_DIRTY; }
 extern inline int pte_young(pte_t pte)		{ return pte_val(pte) & _PAGE_ACCESSED; }
 extern inline int pte_file(pte_t pte)		{ return pte_val(pte) & _PAGE_FILE; }
+extern inline int pte_special(pte_t pte)	{ return 0; }
 
 extern inline pte_t pte_wrprotect(pte_t pte)	{ pte_val(pte) |= _PAGE_FOW; return pte; }
 extern inline pte_t pte_mkclean(pte_t pte)	{ pte_val(pte) &= ~(__DIRTY_BITS); return pte; }
@@ -275,6 +276,7 @@ extern inline pte_t pte_mkold(pte_t pte)
 extern inline pte_t pte_mkwrite(pte_t pte)	{ pte_val(pte) &= ~_PAGE_FOW; return pte; }
 extern inline pte_t pte_mkdirty(pte_t pte)	{ pte_val(pte) |= __DIRTY_BITS; return pte; }
 extern inline pte_t pte_mkyoung(pte_t pte)	{ pte_val(pte) |= __ACCESS_BITS; return pte; }
+extern inline pte_t pte_mkspecial(pte_t pte)	{ return pte; }
 
 #define PAGE_DIR_OFFSET(tsk,address) pgd_offset((tsk),(address))
 
Index: linux-2.6/include/asm-avr32/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-avr32/pgtable.h
+++ linux-2.6/include/asm-avr32/pgtable.h
@@ -211,6 +211,10 @@ static inline int pte_young(pte_t pte)
 {
 	return pte_val(pte) & _PAGE_ACCESSED;
 }
+static inline int pte_special(pte_t pte)
+{
+	return 0;
+}
 
 /*
  * The following only work if pte_present() is not true.
@@ -251,6 +255,10 @@ static inline pte_t pte_mkyoung(pte_t pt
 	set_pte(&pte, __pte(pte_val(pte) | _PAGE_ACCESSED));
 	return pte;
 }
+static inline pte_t pte_mkspecial(pte_t pte)
+{
+	return pte;
+}
 
 #define pmd_none(x)	(!pmd_val(x))
 #define pmd_present(x)	(pmd_val(x) & _PAGE_PRESENT)
Index: linux-2.6/include/asm-cris/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-cris/pgtable.h
+++ linux-2.6/include/asm-cris/pgtable.h
@@ -115,6 +115,7 @@ static inline int pte_write(pte_t pte)  
 static inline int pte_dirty(pte_t pte)          { return pte_val(pte) & _PAGE_MODIFIED; }
 static inline int pte_young(pte_t pte)          { return pte_val(pte) & _PAGE_ACCESSED; }
 static inline int pte_file(pte_t pte)           { return pte_val(pte) & _PAGE_FILE; }
+static inline int pte_special(pte_t pte)	{ return 0; }
 
 static inline pte_t pte_wrprotect(pte_t pte)
 {
@@ -162,6 +163,7 @@ static inline pte_t pte_mkyoung(pte_t pt
         }
         return pte;
 }
+static inline pte_t pte_mkspecial(pte_t pte)	{ return pte; }
 
 /*
  * Conversion functions: convert a page and protection to a page entry,
Index: linux-2.6/include/asm-frv/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-frv/pgtable.h
+++ linux-2.6/include/asm-frv/pgtable.h
@@ -380,6 +380,7 @@ static inline pmd_t *pmd_offset(pud_t *d
 static inline int pte_dirty(pte_t pte)		{ return (pte).pte & _PAGE_DIRTY; }
 static inline int pte_young(pte_t pte)		{ return (pte).pte & _PAGE_ACCESSED; }
 static inline int pte_write(pte_t pte)		{ return !((pte).pte & _PAGE_WP); }
+static inline int pte_special(pte_t pte)	{ return 0; }
 
 static inline pte_t pte_mkclean(pte_t pte)	{ (pte).pte &= ~_PAGE_DIRTY; return pte; }
 static inline pte_t pte_mkold(pte_t pte)	{ (pte).pte &= ~_PAGE_ACCESSED; return pte; }
@@ -387,6 +388,7 @@ static inline pte_t pte_wrprotect(pte_t 
 static inline pte_t pte_mkdirty(pte_t pte)	{ (pte).pte |= _PAGE_DIRTY; return pte; }
 static inline pte_t pte_mkyoung(pte_t pte)	{ (pte).pte |= _PAGE_ACCESSED; return pte; }
 static inline pte_t pte_mkwrite(pte_t pte)	{ (pte).pte &= ~_PAGE_WP; return pte; }
+static inline pte_t pte_mkspecial(pte_t pte)	{ return pte; }
 
 static inline int ptep_test_and_clear_young(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
 {
Index: linux-2.6/include/asm-ia64/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-ia64/pgtable.h
+++ linux-2.6/include/asm-ia64/pgtable.h
@@ -302,6 +302,8 @@ ia64_phys_addr_valid (unsigned long addr
 #define pte_dirty(pte)		((pte_val(pte) & _PAGE_D) != 0)
 #define pte_young(pte)		((pte_val(pte) & _PAGE_A) != 0)
 #define pte_file(pte)		((pte_val(pte) & _PAGE_FILE) != 0)
+#define pte_special(pte)	0
+
 /*
  * Note: we convert AR_RWX to AR_RX and AR_RW to AR_R by clearing the 2nd bit in the
  * access rights:
@@ -313,6 +315,7 @@ ia64_phys_addr_valid (unsigned long addr
 #define pte_mkclean(pte)	(__pte(pte_val(pte) & ~_PAGE_D))
 #define pte_mkdirty(pte)	(__pte(pte_val(pte) | _PAGE_D))
 #define pte_mkhuge(pte)		(__pte(pte_val(pte)))
+#define pte_mkspecial(pte)	(pte)
 
 /*
  * Because ia64's Icache and Dcache is not coherent (on a cpu), we need to
Index: linux-2.6/include/asm-m32r/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-m32r/pgtable.h
+++ linux-2.6/include/asm-m32r/pgtable.h
@@ -214,6 +214,11 @@ static inline int pte_file(pte_t pte)
 	return pte_val(pte) & _PAGE_FILE;
 }
 
+static inline int pte_special(pte_t pte)
+{
+	return 0;
+}
+
 static inline pte_t pte_mkclean(pte_t pte)
 {
 	pte_val(pte) &= ~_PAGE_DIRTY;
@@ -250,6 +255,11 @@ static inline pte_t pte_mkwrite(pte_t pt
 	return pte;
 }
 
+static inline pte_t pte_mkspecial(pte_t pte)
+{
+	return pte;
+}
+
 static inline  int ptep_test_and_clear_young(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
 {
 	return test_and_clear_bit(_PAGE_BIT_ACCESSED, ptep);
Index: linux-2.6/include/asm-m68k/motorola_pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-m68k/motorola_pgtable.h
+++ linux-2.6/include/asm-m68k/motorola_pgtable.h
@@ -168,6 +168,7 @@ static inline int pte_write(pte_t pte)		
 static inline int pte_dirty(pte_t pte)		{ return pte_val(pte) & _PAGE_DIRTY; }
 static inline int pte_young(pte_t pte)		{ return pte_val(pte) & _PAGE_ACCESSED; }
 static inline int pte_file(pte_t pte)		{ return pte_val(pte) & _PAGE_FILE; }
+static inline int pte_special(pte_t pte)	{ return 0; }
 
 static inline pte_t pte_wrprotect(pte_t pte)	{ pte_val(pte) |= _PAGE_RONLY; return pte; }
 static inline pte_t pte_mkclean(pte_t pte)	{ pte_val(pte) &= ~_PAGE_DIRTY; return pte; }
@@ -185,6 +186,7 @@ static inline pte_t pte_mkcache(pte_t pt
 	pte_val(pte) = (pte_val(pte) & _CACHEMASK040) | m68k_supervisor_cachemode;
 	return pte;
 }
+static inline pte_t pte_mkspecial(pte_t pte)	{ return pte; }
 
 #define PAGE_DIR_OFFSET(tsk,address) pgd_offset((tsk),(address))
 
Index: linux-2.6/include/asm-m68k/sun3_pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-m68k/sun3_pgtable.h
+++ linux-2.6/include/asm-m68k/sun3_pgtable.h
@@ -169,6 +169,7 @@ static inline int pte_write(pte_t pte)		
 static inline int pte_dirty(pte_t pte)		{ return pte_val(pte) & SUN3_PAGE_MODIFIED; }
 static inline int pte_young(pte_t pte)		{ return pte_val(pte) & SUN3_PAGE_ACCESSED; }
 static inline int pte_file(pte_t pte)		{ return pte_val(pte) & SUN3_PAGE_ACCESSED; }
+static inline int pte_special(pte_t pte)	{ return 0; }
 
 static inline pte_t pte_wrprotect(pte_t pte)	{ pte_val(pte) &= ~SUN3_PAGE_WRITEABLE; return pte; }
 static inline pte_t pte_mkclean(pte_t pte)	{ pte_val(pte) &= ~SUN3_PAGE_MODIFIED; return pte; }
@@ -181,6 +182,7 @@ static inline pte_t pte_mknocache(pte_t 
 //static inline pte_t pte_mkcache(pte_t pte)	{ pte_val(pte) &= SUN3_PAGE_NOCACHE; return pte; }
 // until then, use:
 static inline pte_t pte_mkcache(pte_t pte)	{ return pte; }
+static inline pte_t pte_mkspecial(pte_t pte)	{ return pte; }
 
 extern pgd_t swapper_pg_dir[PTRS_PER_PGD];
 extern pgd_t kernel_pg_dir[PTRS_PER_PGD];
Index: linux-2.6/include/asm-mips/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-mips/pgtable.h
+++ linux-2.6/include/asm-mips/pgtable.h
@@ -285,6 +285,8 @@ static inline pte_t pte_mkyoung(pte_t pt
 	return pte;
 }
 #endif
+static inline int pte_special(pte_t pte)	{ return 0; }
+static inline pte_t pte_mkspecial(pte_t pte)	{ return pte; }
 
 /*
  * Macro to make mark a page protection value as "uncacheable".  Note
Index: linux-2.6/include/asm-parisc/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-parisc/pgtable.h
+++ linux-2.6/include/asm-parisc/pgtable.h
@@ -331,6 +331,7 @@ static inline int pte_dirty(pte_t pte)		
 static inline int pte_young(pte_t pte)		{ return pte_val(pte) & _PAGE_ACCESSED; }
 static inline int pte_write(pte_t pte)		{ return pte_val(pte) & _PAGE_WRITE; }
 static inline int pte_file(pte_t pte)		{ return pte_val(pte) & _PAGE_FILE; }
+static inline int pte_special(pte_t pte)	{ return 0; }
 
 static inline pte_t pte_mkclean(pte_t pte)	{ pte_val(pte) &= ~_PAGE_DIRTY; return pte; }
 static inline pte_t pte_mkold(pte_t pte)	{ pte_val(pte) &= ~_PAGE_ACCESSED; return pte; }
@@ -338,6 +339,7 @@ static inline pte_t pte_wrprotect(pte_t 
 static inline pte_t pte_mkdirty(pte_t pte)	{ pte_val(pte) |= _PAGE_DIRTY; return pte; }
 static inline pte_t pte_mkyoung(pte_t pte)	{ pte_val(pte) |= _PAGE_ACCESSED; return pte; }
 static inline pte_t pte_mkwrite(pte_t pte)	{ pte_val(pte) |= _PAGE_WRITE; return pte; }
+static inline pte_t pte_mkspecial(pte_t pte)	{ return pte; }
 
 /*
  * Conversion functions: convert a page and protection to a page entry,
Index: linux-2.6/include/asm-powerpc/pgtable-ppc32.h
===================================================================
--- linux-2.6.orig/include/asm-powerpc/pgtable-ppc32.h
+++ linux-2.6/include/asm-powerpc/pgtable-ppc32.h
@@ -514,6 +514,7 @@ static inline int pte_write(pte_t pte)		
 static inline int pte_dirty(pte_t pte)		{ return pte_val(pte) & _PAGE_DIRTY; }
 static inline int pte_young(pte_t pte)		{ return pte_val(pte) & _PAGE_ACCESSED; }
 static inline int pte_file(pte_t pte)		{ return pte_val(pte) & _PAGE_FILE; }
+static inline int pte_special(pte_t pte)	{ return 0; }
 
 static inline void pte_uncache(pte_t pte)       { pte_val(pte) |= _PAGE_NO_CACHE; }
 static inline void pte_cache(pte_t pte)         { pte_val(pte) &= ~_PAGE_NO_CACHE; }
@@ -531,6 +532,8 @@ static inline pte_t pte_mkdirty(pte_t pt
 	pte_val(pte) |= _PAGE_DIRTY; return pte; }
 static inline pte_t pte_mkyoung(pte_t pte) {
 	pte_val(pte) |= _PAGE_ACCESSED; return pte; }
+static inline pte_t pte_mkspecial(pte_t pte) {
+	return pte; }
 
 static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 {
Index: linux-2.6/include/asm-powerpc/pgtable-ppc64.h
===================================================================
--- linux-2.6.orig/include/asm-powerpc/pgtable-ppc64.h
+++ linux-2.6/include/asm-powerpc/pgtable-ppc64.h
@@ -239,6 +239,7 @@ static inline int pte_write(pte_t pte) {
 static inline int pte_dirty(pte_t pte) { return pte_val(pte) & _PAGE_DIRTY;}
 static inline int pte_young(pte_t pte) { return pte_val(pte) & _PAGE_ACCESSED;}
 static inline int pte_file(pte_t pte) { return pte_val(pte) & _PAGE_FILE;}
+static inline int pte_special(pte_t pte) { return 0; }
 
 static inline void pte_uncache(pte_t pte) { pte_val(pte) |= _PAGE_NO_CACHE; }
 static inline void pte_cache(pte_t pte)   { pte_val(pte) &= ~_PAGE_NO_CACHE; }
@@ -257,6 +258,8 @@ static inline pte_t pte_mkyoung(pte_t pt
 	pte_val(pte) |= _PAGE_ACCESSED; return pte; }
 static inline pte_t pte_mkhuge(pte_t pte) {
 	return pte; }
+static inline pte_t pte_mkspecial(pte_t pte) {
+	return pte; }
 
 /* Atomic PTE updates */
 static inline unsigned long pte_update(struct mm_struct *mm,
Index: linux-2.6/include/asm-ppc/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-ppc/pgtable.h
+++ linux-2.6/include/asm-ppc/pgtable.h
@@ -537,6 +537,7 @@ static inline int pte_write(pte_t pte)		
 static inline int pte_dirty(pte_t pte)		{ return pte_val(pte) & _PAGE_DIRTY; }
 static inline int pte_young(pte_t pte)		{ return pte_val(pte) & _PAGE_ACCESSED; }
 static inline int pte_file(pte_t pte)		{ return pte_val(pte) & _PAGE_FILE; }
+static inline int pte_special(pte_t pte)	{ return 0; }
 
 static inline void pte_uncache(pte_t pte)       { pte_val(pte) |= _PAGE_NO_CACHE; }
 static inline void pte_cache(pte_t pte)         { pte_val(pte) &= ~_PAGE_NO_CACHE; }
@@ -554,6 +555,8 @@ static inline pte_t pte_mkdirty(pte_t pt
 	pte_val(pte) |= _PAGE_DIRTY; return pte; }
 static inline pte_t pte_mkyoung(pte_t pte) {
 	pte_val(pte) |= _PAGE_ACCESSED; return pte; }
+static inline pte_t pte_mkspecial(pte_t pte) {
+	return pte; }
 
 static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 {
Index: linux-2.6/include/asm-s390/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-s390/pgtable.h
+++ linux-2.6/include/asm-s390/pgtable.h
@@ -228,6 +228,8 @@ extern unsigned long vmalloc_end;
 /* Software bits in the page table entry */
 #define _PAGE_SWT	0x001		/* SW pte type bit t */
 #define _PAGE_SWX	0x002		/* SW pte type bit x */
+#define _PAGE_SPECIAL	0x004		/* SW associated with special page */
+#define __HAVE_ARCH_PTE_SPECIAL
 
 /* Six different types of pages. */
 #define _PAGE_TYPE_EMPTY	0x400
@@ -504,6 +506,11 @@ static inline int pte_file(pte_t pte)
 	return (pte_val(pte) & mask) == _PAGE_TYPE_FILE;
 }
 
+static inline int pte_special(pte_t pte)
+{
+	return (pte_val(pte) & _PAGE_SPECIAL);
+}
+
 #define __HAVE_ARCH_PTE_SAME
 #define pte_same(a,b)  (pte_val(a) == pte_val(b))
 
@@ -654,6 +661,12 @@ static inline pte_t pte_mkyoung(pte_t pt
 	return pte;
 }
 
+static inline pte_t pte_mkspecial(pte_t pte)
+{
+	pte_val(pte) |= _PAGE_SPECIAL;
+	return pte;
+}
+
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
 static inline int ptep_test_and_clear_young(struct vm_area_struct *vma,
 					    unsigned long addr, pte_t *ptep)
Index: linux-2.6/include/asm-sh64/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-sh64/pgtable.h
+++ linux-2.6/include/asm-sh64/pgtable.h
@@ -419,6 +419,7 @@ static inline int pte_dirty(pte_t pte){ 
 static inline int pte_young(pte_t pte){ return pte_val(pte) & _PAGE_ACCESSED; }
 static inline int pte_file(pte_t pte) { return pte_val(pte) & _PAGE_FILE; }
 static inline int pte_write(pte_t pte){ return pte_val(pte) & _PAGE_WRITE; }
+static inline int pte_special(pte_t pte)	{ return 0; }
 
 static inline pte_t pte_wrprotect(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_WRITE)); return pte; }
 static inline pte_t pte_mkclean(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_DIRTY)); return pte; }
@@ -427,6 +428,7 @@ static inline pte_t pte_mkwrite(pte_t pt
 static inline pte_t pte_mkdirty(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_DIRTY)); return pte; }
 static inline pte_t pte_mkyoung(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_ACCESSED)); return pte; }
 static inline pte_t pte_mkhuge(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_SZHUGE)); return pte; }
+static inline pte_t pte_mkspecial(pte_t pte)	{ return pte; }
 
 
 /*
Index: linux-2.6/include/asm-sparc/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-sparc/pgtable.h
+++ linux-2.6/include/asm-sparc/pgtable.h
@@ -219,6 +219,11 @@ static inline int pte_file(pte_t pte)
 	return pte_val(pte) & BTFIXUP_HALF(pte_filei);
 }
 
+static inline int pte_special(pte_t pte)
+{
+	return 0;
+}
+
 /*
  */
 BTFIXUPDEF_HALF(pte_wrprotecti)
@@ -251,6 +256,8 @@ BTFIXUPDEF_CALL_CONST(pte_t, pte_mkyoung
 #define pte_mkdirty(pte) BTFIXUP_CALL(pte_mkdirty)(pte)
 #define pte_mkyoung(pte) BTFIXUP_CALL(pte_mkyoung)(pte)
 
+#define pte_mkspecial(pte_t pte)    (pte)
+
 #define pfn_pte(pfn, prot)		mk_pte(pfn_to_page(pfn), prot)
 
 BTFIXUPDEF_CALL(unsigned long,	 pte_pfn, pte_t)
Index: linux-2.6/include/asm-sparc64/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-sparc64/pgtable.h
+++ linux-2.6/include/asm-sparc64/pgtable.h
@@ -506,6 +506,11 @@ static inline pte_t pte_mkyoung(pte_t pt
 	return __pte(pte_val(pte) | mask);
 }
 
+static inline pte_t pte_mkspecial(pte_t pte)
+{
+	return pte;
+}
+
 static inline unsigned long pte_young(pte_t pte)
 {
 	unsigned long mask;
@@ -608,6 +613,11 @@ static inline unsigned long pte_present(
 	return val;
 }
 
+static inline int pte_special(pte_t pte)
+{
+	return 0;
+}
+
 #define pmd_set(pmdp, ptep)	\
 	(pmd_val(*(pmdp)) = (__pa((unsigned long) (ptep)) >> 11UL))
 #define pud_set(pudp, pmdp)	\
Index: linux-2.6/include/asm-xtensa/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-xtensa/pgtable.h
+++ linux-2.6/include/asm-xtensa/pgtable.h
@@ -212,6 +212,8 @@ static inline int pte_write(pte_t pte) {
 static inline int pte_dirty(pte_t pte) { return pte_val(pte) & _PAGE_DIRTY; }
 static inline int pte_young(pte_t pte) { return pte_val(pte) & _PAGE_ACCESSED; }
 static inline int pte_file(pte_t pte)  { return pte_val(pte) & _PAGE_FILE; }
+static inline int pte_special(pte_t pte) { return 0; }
+
 static inline pte_t pte_wrprotect(pte_t pte)	
 	{ pte_val(pte) &= ~(_PAGE_WRITABLE | _PAGE_HW_WRITE); return pte; }
 static inline pte_t pte_mkclean(pte_t pte)
@@ -224,6 +226,8 @@ static inline pte_t pte_mkyoung(pte_t pt
 	{ pte_val(pte) |= _PAGE_ACCESSED; return pte; }
 static inline pte_t pte_mkwrite(pte_t pte)
 	{ pte_val(pte) |= _PAGE_WRITABLE; return pte; }
+static inline pte_t pte_mkspecial(pte_t pte)
+	{ return pte; }
 
 /*
  * Conversion functions: convert a page and protection to a page entry,
Index: linux-2.6/fs/ext2/super.c
===================================================================
--- linux-2.6.orig/fs/ext2/super.c
+++ linux-2.6/fs/ext2/super.c
@@ -844,8 +844,7 @@ static int ext2_fill_super(struct super_
 
 	blocksize = BLOCK_SIZE << le32_to_cpu(sbi->s_es->s_log_block_size);
 
-	if ((ext2_use_xip(sb)) && ((blocksize != PAGE_SIZE) ||
-				  (sb->s_blocksize != blocksize))) {
+	if (ext2_use_xip(sb) && blocksize != PAGE_SIZE) {
 		if (!silent)
 			printk("XIP: Unsupported blocksize\n");
 		goto failed_mount;
Index: linux-2.6/fs/ext2/inode.c
===================================================================
--- linux-2.6.orig/fs/ext2/inode.c
+++ linux-2.6/fs/ext2/inode.c
@@ -800,7 +800,7 @@ const struct address_space_operations ex
 
 const struct address_space_operations ext2_aops_xip = {
 	.bmap			= ext2_bmap,
-	.get_xip_page		= ext2_get_xip_page,
+	.get_xip_address	= ext2_get_xip_address,
 };
 
 const struct address_space_operations ext2_nobh_aops = {
Index: linux-2.6/fs/ext2/xip.c
===================================================================
--- linux-2.6.orig/fs/ext2/xip.c
+++ linux-2.6/fs/ext2/xip.c
@@ -15,24 +15,25 @@
 #include "xip.h"
 
 static inline int
-__inode_direct_access(struct inode *inode, sector_t sector,
-		      unsigned long *data)
+__inode_direct_access(struct inode *inode, sector_t block, unsigned long *data)
 {
+	sector_t sector;
 	BUG_ON(!inode->i_sb->s_bdev->bd_disk->fops->direct_access);
+
+	sector = block * (PAGE_SIZE / 512); /* ext2 block to bdev sector */
 	return inode->i_sb->s_bdev->bd_disk->fops
-		->direct_access(inode->i_sb->s_bdev,sector,data);
+		->direct_access(inode->i_sb->s_bdev, sector, data);
 }
 
 static inline int
-__ext2_get_sector(struct inode *inode, sector_t offset, int create,
+__ext2_get_block(struct inode *inode, pgoff_t pgoff, int create,
 		   sector_t *result)
 {
 	struct buffer_head tmp;
 	int rc;
 
 	memset(&tmp, 0, sizeof(struct buffer_head));
-	rc = ext2_get_block(inode, offset/ (PAGE_SIZE/512), &tmp,
-			    create);
+	rc = ext2_get_block(inode, pgoff, &tmp, create);
 	*result = tmp.b_blocknr;
 
 	/* did we get a sparse block (hole in the file)? */
@@ -45,13 +46,12 @@ __ext2_get_sector(struct inode *inode, s
 }
 
 int
-ext2_clear_xip_target(struct inode *inode, int block)
+ext2_clear_xip_target(struct inode *inode, sector_t block)
 {
-	sector_t sector = block * (PAGE_SIZE/512);
 	unsigned long data;
 	int rc;
 
-	rc = __inode_direct_access(inode, sector, &data);
+	rc = __inode_direct_access(inode, block, &data);
 	if (!rc)
 		clear_page((void*)data);
 	return rc;
@@ -69,24 +69,24 @@ void ext2_xip_verify_sb(struct super_blo
 	}
 }
 
-struct page *
-ext2_get_xip_page(struct address_space *mapping, sector_t offset,
-		   int create)
+void *
+ext2_get_xip_address(struct address_space *mapping, pgoff_t pgoff, int create)
 {
 	int rc;
 	unsigned long data;
-	sector_t sector;
+	sector_t block;
 
 	/* first, retrieve the sector number */
-	rc = __ext2_get_sector(mapping->host, offset, create, &sector);
+	rc = __ext2_get_block(mapping->host, pgoff, create, &block);
 	if (rc)
 		goto error;
 
 	/* retrieve address of the target data */
-	rc = __inode_direct_access
-		(mapping->host, sector * (PAGE_SIZE/512), &data);
-	if (!rc)
-		return virt_to_page(data);
+	rc = __inode_direct_access(mapping->host, block, &data);
+	if (rc)
+		goto error;
+
+	return (void *)data;
 
  error:
 	return ERR_PTR(rc);
Index: linux-2.6/fs/ext2/xip.h
===================================================================
--- linux-2.6.orig/fs/ext2/xip.h
+++ linux-2.6/fs/ext2/xip.h
@@ -7,19 +7,19 @@
 
 #ifdef CONFIG_EXT2_FS_XIP
 extern void ext2_xip_verify_sb (struct super_block *);
-extern int ext2_clear_xip_target (struct inode *, int);
+extern int ext2_clear_xip_target (struct inode *, sector_t);
 
 static inline int ext2_use_xip (struct super_block *sb)
 {
 	struct ext2_sb_info *sbi = EXT2_SB(sb);
 	return (sbi->s_mount_opt & EXT2_MOUNT_XIP);
 }
-struct page* ext2_get_xip_page (struct address_space *, sector_t, int);
-#define mapping_is_xip(map) unlikely(map->a_ops->get_xip_page)
+void *ext2_get_xip_address(struct address_space *, sector_t, int);
+#define mapping_is_xip(map) unlikely(map->a_ops->get_xip_address)
 #else
 #define mapping_is_xip(map)			0
 #define ext2_xip_verify_sb(sb)			do { } while (0)
 #define ext2_use_xip(sb)			0
 #define ext2_clear_xip_target(inode, chain)	0
-#define ext2_get_xip_page			NULL
+#define ext2_get_xip_address			NULL
 #endif
Index: linux-2.6/fs/open.c
===================================================================
--- linux-2.6.orig/fs/open.c
+++ linux-2.6/fs/open.c
@@ -778,7 +778,7 @@ static struct file *__dentry_open(struct
 	if (f->f_flags & O_DIRECT) {
 		if (!f->f_mapping->a_ops ||
 		    ((!f->f_mapping->a_ops->direct_IO) &&
-		    (!f->f_mapping->a_ops->get_xip_page))) {
+		    (!f->f_mapping->a_ops->get_xip_address))) {
 			fput(f);
 			f = ERR_PTR(-EINVAL);
 		}
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h
+++ linux-2.6/include/linux/fs.h
@@ -473,8 +473,7 @@ struct address_space_operations {
 	int (*releasepage) (struct page *, gfp_t);
 	ssize_t (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
 			loff_t offset, unsigned long nr_segs);
-	struct page* (*get_xip_page)(struct address_space *, sector_t,
-			int);
+	void * (*get_xip_address)(struct address_space *, pgoff_t, int);
 	/* migrate the contents of a page to the specified target */
 	int (*migratepage) (struct address_space *,
 			struct page *, struct page *);
Index: linux-2.6/mm/fadvise.c
===================================================================
--- linux-2.6.orig/mm/fadvise.c
+++ linux-2.6/mm/fadvise.c
@@ -49,7 +49,7 @@ asmlinkage long sys_fadvise64_64(int fd,
 		goto out;
 	}
 
-	if (mapping->a_ops->get_xip_page)
+	if (mapping->a_ops->get_xip_address)
 		/* no bad return value, but ignore advice */
 		goto out;
 
Index: linux-2.6/mm/filemap_xip.c
===================================================================
--- linux-2.6.orig/mm/filemap_xip.c
+++ linux-2.6/mm/filemap_xip.c
@@ -15,6 +15,7 @@
 #include <linux/rmap.h>
 #include <linux/sched.h>
 #include <asm/tlbflush.h>
+#include <asm/io.h>
 
 /*
  * We do use our own empty page to avoid interference with other users
@@ -42,36 +43,39 @@ static struct page *xip_sparse_page(void
 
 /*
  * This is a file read routine for execute in place files, and uses
- * the mapping->a_ops->get_xip_page() function for the actual low-level
+ * the mapping->a_ops->get_xip_address() function for the actual low-level
  * stuff.
  *
  * Note the struct file* is not used at all.  It may be NULL.
  */
-static void
+static ssize_t
 do_xip_mapping_read(struct address_space *mapping,
 		    struct file_ra_state *_ra,
 		    struct file *filp,
-		    loff_t *ppos,
-		    read_descriptor_t *desc,
-		    read_actor_t actor)
+		    char __user *buf,
+		    size_t len,
+		    loff_t *ppos)
 {
 	struct inode *inode = mapping->host;
 	unsigned long index, end_index, offset;
-	loff_t isize;
+	loff_t isize, pos;
+	size_t copied = 0, error = 0;
 
-	BUG_ON(!mapping->a_ops->get_xip_page);
+	BUG_ON(!mapping->a_ops->get_xip_address);
 
-	index = *ppos >> PAGE_CACHE_SHIFT;
-	offset = *ppos & ~PAGE_CACHE_MASK;
+	pos = *ppos;
+	index = pos >> PAGE_CACHE_SHIFT;
+	offset = pos & ~PAGE_CACHE_MASK;
 
 	isize = i_size_read(inode);
 	if (!isize)
 		goto out;
 
 	end_index = (isize - 1) >> PAGE_CACHE_SHIFT;
-	for (;;) {
-		struct page *page;
-		unsigned long nr, ret;
+	do {
+		unsigned long nr, left;
+		void *xip_mem;
+		int zero = 0;
 
 		/* nr is the maximum number of bytes to copy from this page */
 		nr = PAGE_CACHE_SIZE;
@@ -84,17 +88,20 @@ do_xip_mapping_read(struct address_space
 			}
 		}
 		nr = nr - offset;
+		if (nr > len)
+			nr = len;
 
-		page = mapping->a_ops->get_xip_page(mapping,
-			index*(PAGE_SIZE/512), 0);
-		if (!page)
-			goto no_xip_page;
-		if (unlikely(IS_ERR(page))) {
-			if (PTR_ERR(page) == -ENODATA) {
+		xip_mem = mapping->a_ops->get_xip_address(mapping, index, 0);
+		if (!xip_mem) {
+			error = -EIO;
+			goto out;
+		}
+		if (unlikely(IS_ERR(xip_mem))) {
+			if (PTR_ERR(xip_mem) == -ENODATA) {
 				/* sparse */
-				page = ZERO_PAGE(0);
+				zero = 1;
 			} else {
-				desc->error = PTR_ERR(page);
+				error = PTR_ERR(xip_mem);
 				goto out;
 			}
 		}
@@ -104,10 +111,10 @@ do_xip_mapping_read(struct address_space
 		 * before reading the page on the kernel side.
 		 */
 		if (mapping_writably_mapped(mapping))
-			flush_dcache_page(page);
+			/* address based flush */ ;
 
 		/*
-		 * Ok, we have the page, so now we can copy it to user space...
+		 * Ok, we have the mem, so now we can copy it to user space...
 		 *
 		 * The actor routine returns how many bytes were actually used..
 		 * NOTE! This may not be the same as how much of a user buffer
@@ -115,47 +122,38 @@ do_xip_mapping_read(struct address_space
 		 * "pos" here (the actor routine has to update the user buffer
 		 * pointers and the remaining count).
 		 */
-		ret = actor(desc, page, offset, nr);
-		offset += ret;
-		index += offset >> PAGE_CACHE_SHIFT;
-		offset &= ~PAGE_CACHE_MASK;
+		if (!zero)
+			left = __copy_to_user(buf+copied, xip_mem+offset, nr);
+		else
+			left = __clear_user(buf + copied, nr);
 
-		if (ret == nr && desc->count)
-			continue;
-		goto out;
+		if (left) {
+			error = -EFAULT;
+			goto out;
+		}
 
-no_xip_page:
-		/* Did not get the page. Report it */
-		desc->error = -EIO;
-		goto out;
-	}
+		copied += (nr - left);
+		offset += (nr - left);
+		index += offset >> PAGE_CACHE_SHIFT;
+		offset &= ~PAGE_CACHE_MASK;
+	} while (copied < len);
 
 out:
-	*ppos = ((loff_t) index << PAGE_CACHE_SHIFT) + offset;
+	*ppos = pos + copied;
 	if (filp)
 		file_accessed(filp);
+
+	return (copied ? copied : error);
 }
 
 ssize_t
 xip_file_read(struct file *filp, char __user *buf, size_t len, loff_t *ppos)
 {
-	read_descriptor_t desc;
-
 	if (!access_ok(VERIFY_WRITE, buf, len))
 		return -EFAULT;
 
-	desc.written = 0;
-	desc.arg.buf = buf;
-	desc.count = len;
-	desc.error = 0;
-
-	do_xip_mapping_read(filp->f_mapping, &filp->f_ra, filp,
-			    ppos, &desc, file_read_actor);
-
-	if (desc.written)
-		return desc.written;
-	else
-		return desc.error;
+	return do_xip_mapping_read(filp->f_mapping, &filp->f_ra, filp,
+			    buf, len, ppos);
 }
 EXPORT_SYMBOL_GPL(xip_file_read);
 
@@ -210,13 +208,14 @@ __xip_unmap (struct address_space * mapp
  *
  * This function is derived from filemap_fault, but used for execute in place
  */
-static int xip_file_fault(struct vm_area_struct *area, struct vm_fault *vmf)
+static int xip_file_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	struct file *file = area->vm_file;
+	struct file *file = vma->vm_file;
 	struct address_space *mapping = file->f_mapping;
 	struct inode *inode = mapping->host;
-	struct page *page;
 	pgoff_t size;
+	void *xip_mem;
+	struct page *page;
 
 	/* XXX: are VM_FAULT_ codes OK? */
 
@@ -224,35 +223,43 @@ static int xip_file_fault(struct vm_area
 	if (vmf->pgoff >= size)
 		return VM_FAULT_SIGBUS;
 
-	page = mapping->a_ops->get_xip_page(mapping,
-					vmf->pgoff*(PAGE_SIZE/512), 0);
-	if (!IS_ERR(page))
-		goto out;
-	if (PTR_ERR(page) != -ENODATA)
+	xip_mem = mapping->a_ops->get_xip_address(mapping, vmf->pgoff, 0);
+	if (!IS_ERR(xip_mem))
+		goto found;
+	if (PTR_ERR(xip_mem) != -ENODATA)
 		return VM_FAULT_OOM;
 
 	/* sparse block */
-	if ((area->vm_flags & (VM_WRITE | VM_MAYWRITE)) &&
-	    (area->vm_flags & (VM_SHARED| VM_MAYSHARE)) &&
+	if ((vma->vm_flags & (VM_WRITE | VM_MAYWRITE)) &&
+	    (vma->vm_flags & (VM_SHARED| VM_MAYSHARE)) &&
 	    (!(mapping->host->i_sb->s_flags & MS_RDONLY))) {
+		unsigned long pfn;
+		int err;
+
 		/* maybe shared writable, allocate new block */
-		page = mapping->a_ops->get_xip_page(mapping,
-					vmf->pgoff*(PAGE_SIZE/512), 1);
-		if (IS_ERR(page))
+		xip_mem = mapping->a_ops->get_xip_address(mapping,vmf->pgoff,1);
+		if (IS_ERR(xip_mem))
 			return VM_FAULT_SIGBUS;
-		/* unmap page at pgoff from all other vmas */
+		/* unmap sparse mappings at pgoff from all other vmas */
 		__xip_unmap(mapping, vmf->pgoff);
+
+found:
+		pfn = virt_to_phys(xip_mem) >> PAGE_SHIFT;
+		err = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address, pfn);
+		if (err == -ENOMEM)
+			return VM_FAULT_OOM;
+		BUG_ON(err);
+		return VM_FAULT_NOPAGE;
 	} else {
 		/* not shared and writable, use xip_sparse_page() */
 		page = xip_sparse_page();
 		if (!page)
 			return VM_FAULT_OOM;
-	}
 
-out:
-	page_cache_get(page);
-	vmf->page = page;
-	return 0;
+		page_cache_get(page);
+		vmf->page = page;
+		return 0;
+	}
 }
 
 static struct vm_operations_struct xip_file_vm_ops = {
@@ -261,11 +268,11 @@ static struct vm_operations_struct xip_f
 
 int xip_file_mmap(struct file * file, struct vm_area_struct * vma)
 {
-	BUG_ON(!file->f_mapping->a_ops->get_xip_page);
+	BUG_ON(!file->f_mapping->a_ops->get_xip_address);
 
 	file_accessed(file);
 	vma->vm_ops = &xip_file_vm_ops;
-	vma->vm_flags |= VM_CAN_NONLINEAR;
+	vma->vm_flags |= VM_CAN_NONLINEAR | VM_MIXEDMAP;
 	return 0;
 }
 EXPORT_SYMBOL_GPL(xip_file_mmap);
@@ -278,17 +285,16 @@ __xip_file_write(struct file *filp, cons
 	const struct address_space_operations *a_ops = mapping->a_ops;
 	struct inode 	*inode = mapping->host;
 	long		status = 0;
-	struct page	*page;
 	size_t		bytes;
 	ssize_t		written = 0;
 
-	BUG_ON(!mapping->a_ops->get_xip_page);
+	BUG_ON(!mapping->a_ops->get_xip_address);
 
 	do {
 		unsigned long index;
 		unsigned long offset;
 		size_t copied;
-		char *kaddr;
+		void *xip_mem;
 
 		offset = (pos & (PAGE_CACHE_SIZE -1)); /* Within page */
 		index = pos >> PAGE_CACHE_SHIFT;
@@ -296,28 +302,22 @@ __xip_file_write(struct file *filp, cons
 		if (bytes > count)
 			bytes = count;
 
-		page = a_ops->get_xip_page(mapping,
-					   index*(PAGE_SIZE/512), 0);
-		if (IS_ERR(page) && (PTR_ERR(page) == -ENODATA)) {
+		xip_mem = a_ops->get_xip_address(mapping, index, 0);
+		if (IS_ERR(xip_mem) && (PTR_ERR(xip_mem) == -ENODATA)) {
 			/* we allocate a new page unmap it */
-			page = a_ops->get_xip_page(mapping,
-						   index*(PAGE_SIZE/512), 1);
-			if (!IS_ERR(page))
+			xip_mem = a_ops->get_xip_address(mapping, index, 1);
+			if (!IS_ERR(xip_mem))
 				/* unmap page at pgoff from all other vmas */
 				__xip_unmap(mapping, index);
 		}
 
-		if (IS_ERR(page)) {
-			status = PTR_ERR(page);
+		if (IS_ERR(xip_mem)) {
+			status = PTR_ERR(xip_mem);
 			break;
 		}
 
-		fault_in_pages_readable(buf, bytes);
-		kaddr = kmap_atomic(page, KM_USER0);
 		copied = bytes -
-			__copy_from_user_inatomic_nocache(kaddr + offset, buf, bytes);
-		kunmap_atomic(kaddr, KM_USER0);
-		flush_dcache_page(page);
+			__copy_from_user_nocache(xip_mem + offset, buf, bytes);
 
 		if (likely(copied > 0)) {
 			status = copied;
@@ -397,7 +397,7 @@ EXPORT_SYMBOL_GPL(xip_file_write);
 
 /*
  * truncate a page used for execute in place
- * functionality is analog to block_truncate_page but does use get_xip_page
+ * functionality is analog to block_truncate_page but does use get_xip_adddress
  * to get the page instead of page cache
  */
 int
@@ -407,9 +407,9 @@ xip_truncate_page(struct address_space *
 	unsigned offset = from & (PAGE_CACHE_SIZE-1);
 	unsigned blocksize;
 	unsigned length;
-	struct page *page;
+	void *xip_mem;
 
-	BUG_ON(!mapping->a_ops->get_xip_page);
+	BUG_ON(!mapping->a_ops->get_xip_address);
 
 	blocksize = 1 << mapping->host->i_blkbits;
 	length = offset & (blocksize - 1);
@@ -420,18 +420,17 @@ xip_truncate_page(struct address_space *
 
 	length = blocksize - length;
 
-	page = mapping->a_ops->get_xip_page(mapping,
-					    index*(PAGE_SIZE/512), 0);
-	if (!page)
+	xip_mem = mapping->a_ops->get_xip_address(mapping, index, 0);
+	if (!xip_mem)
 		return -ENOMEM;
-	if (unlikely(IS_ERR(page))) {
-		if (PTR_ERR(page) == -ENODATA)
+	if (unlikely(IS_ERR(xip_mem))) {
+		if (PTR_ERR(xip_mem) == -ENODATA)
 			/* Hole? No need to truncate */
 			return 0;
 		else
-			return PTR_ERR(page);
+			return PTR_ERR(xip_mem);
 	}
-	zero_user_page(page, offset, length, KM_USER0);
+	memset(xip_mem + offset, 0, length);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(xip_truncate_page);
Index: linux-2.6/mm/madvise.c
===================================================================
--- linux-2.6.orig/mm/madvise.c
+++ linux-2.6/mm/madvise.c
@@ -112,7 +112,7 @@ static long madvise_willneed(struct vm_a
 	if (!file)
 		return -EBADF;
 
-	if (file->f_mapping->a_ops->get_xip_page) {
+	if (file->f_mapping->a_ops->get_xip_address) {
 		/* no bad return value, but ignore advice */
 		return 0;
 	}
Index: linux-2.6/arch/s390/mm/vmem.c
===================================================================
--- linux-2.6.orig/arch/s390/mm/vmem.c
+++ linux-2.6/arch/s390/mm/vmem.c
@@ -310,8 +310,6 @@ out:
 int add_shared_memory(unsigned long start, unsigned long size)
 {
 	struct memory_segment *seg;
-	struct page *page;
-	unsigned long pfn, num_pfn, end_pfn;
 	int ret;
 
 	mutex_lock(&vmem_mutex);
@@ -326,24 +324,10 @@ int add_shared_memory(unsigned long star
 	if (ret)
 		goto out_free;
 
-	ret = vmem_add_mem(start, size);
+	ret = vmem_add_range(start, size);
 	if (ret)
 		goto out_remove;
 
-	pfn = PFN_DOWN(start);
-	num_pfn = PFN_DOWN(size);
-	end_pfn = pfn + num_pfn;
-
-	page = pfn_to_page(pfn);
-	memset(page, 0, num_pfn * sizeof(struct page));
-
-	for (; pfn < end_pfn; pfn++) {
-		page = pfn_to_page(pfn);
-		init_page_count(page);
-		reset_page_mapcount(page);
-		SetPageReserved(page);
-		INIT_LIST_HEAD(&page->lru);
-	}
 	goto out;
 
 out_remove:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
