Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5A8346B0038
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 15:33:53 -0500 (EST)
Received: by iouu10 with SMTP id u10so67947880iou.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 12:33:53 -0800 (PST)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0065.outbound.protection.outlook.com. [157.56.112.65])
        by mx.google.com with ESMTPS id hs4si7176513igb.83.2015.11.18.12.33.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 18 Nov 2015 12:33:52 -0800 (PST)
Subject: Re: [PATCH v2] arm64: Add support for PTE contiguous bit.
References: <1445285349-13242-1-git-send-email-dwoods@ezchip.com>
 <20151020121622.GA24598@linaro.org>
From: David Woods <dwoods@ezchip.com>
Message-ID: <564CE0A2.6090808@ezchip.com>
Date: Wed, 18 Nov 2015 15:33:38 -0500
MIME-Version: 1.0
In-Reply-To: <20151020121622.GA24598@linaro.org>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, jeremy.linton@arm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cmetcalf@ezchip.com

On 10/20/2015 08:16 AM, Steve Capper wrote:
> On Mon, Oct 19, 2015 at 04:09:09PM -0400, David Woods wrote:
>> >The arm64 MMU supports a Contiguous bit which is a hint that the TTE
>> >is one of a set of contiguous entries which can be cached in a single
>> >TLB entry.  Supporting this bit adds new intermediate huge page sizes.
>> >
>> >The set of huge page sizes available depends on the base page size.
>> >Without using contiguous pages the huge page sizes are as follows.
>> >
>> >  4KB:   2MB  1GB
>> >64KB: 512MB
>> >
>> >With a 4KB granule, the contiguous bit groups together sets of 16 pages
>> >and with a 64KB granule it groups sets of 32 pages.  This enables two new
>> >huge page sizes in each case, so that the full set of available sizes
>> >is as follows.
>> >
>> >  4KB:  64KB   2MB  32MB  1GB
>> >64KB:   2MB 512MB  16GB
>> >
>> >If a 16KB granule is used then the contiguous bit groups 128 pages
>> >at the PTE level and 32 pages at the PMD level.
>> >
>> >If the base page size is set to 64KB then 2MB pages are enabled by
>> >default.  It is possible in the future to make 2MB the default huge
>> >page size for both 4KB and 64KB granules.
> Thank you for the V2 David,
> I have some comments below.
>
> I would recommend running the next version of this series through
> the libhugetlbfs test suite, as that may pick up a few things too.

Thanks Steve, for your detailed review.  I did run the libhugetlbfs test 
suite
and it turned up a bug which I'll point out below.  I'll post a V3 shortly.

>
> Cheers,
> -- Steve
> >  
> >+static inline pte_t pte_mkcont(pte_t pte)
> >+{
> >+	pte = set_pte_bit(pte, __pgprot(PTE_CONT));
> >+	return set_pte_bit(pte, __pgprot(PTE_TYPE_PAGE));
> >+	return pte;
> The second return should be removed.

Done.
>
> >  /*
> >   * Hugetlb definitions.
> >   */
> >-#define HUGE_MAX_HSTATE		2
> >+#define HUGE_MAX_HSTATE		((2 * CONFIG_PGTABLE_LEVELS) - 1)
> Not sure about this definition. I would just go with the maximum possible
> which is for a 4KB granule:
> 1 x 1GB pud
> 1 x 2MB pmd
> 16 x 2MB pmds
> 16 x 4KB ptes
>
> So 4 for now?

This made some sense when I was thinking of supporting contiguous
PUDs.  I've changed it to 4 as you suggest.
>> >  #define HPAGE_SHIFT		PMD_SHIFT
>> >  #define HPAGE_SIZE		(_AC(1, UL) << HPAGE_SHIFT)
>> >  #define HPAGE_MASK		(~(HPAGE_SIZE - 1))
>> >@@ -496,7 +509,7 @@ static inline pud_t *pud_offset(pgd_t *pgd, unsigned long addr)
>> >  static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
>> >  {
>> >  	const pteval_t mask = PTE_USER | PTE_PXN | PTE_UXN | PTE_RDONLY |
>> >-			      PTE_PROT_NONE | PTE_VALID | PTE_WRITE;
>> >+			      PTE_PROT_NONE | PTE_VALID | PTE_WRITE | PTE_CONT;
> Why has PTE_CONT been added to the pte_modify mask? This will allow
> functions such as mprotect to remove the PTE_CONT bit.
Right, this is not needed anymore.
>
>
>
> >  
> >+static inline pte_t pte_modify_pfn(pte_t pte, unsigned long newpfn)
> >+{
> >+	const pteval_t mask = PHYS_MASK & PAGE_MASK;
> >+
> >+	pte_val(pte) = pfn_pte(newpfn, (pte_val(pte) & ~mask));
> >+	return pte;
> >+}
> >+
> >+static inline pmd_t pmd_modify_pfn(pmd_t pmd, unsigned long newpfn)
> >+{
> >+	const pmdval_t mask = PHYS_MASK & PAGE_MASK;
> >+
> >+	pmd = pfn_pmd(newpfn, (pmd_val(pmd) & ~mask));
> >+	return pmd;
> >+}
> pte_modify_pfn and pmd_modify_pfn aren't referenced anywhere in the
> patch so should be removed.
Removed.
>
>> >  
>> >+static int find_num_contig(struct mm_struct *mm, unsigned long addr,
>> >+			   pte_t *ptep, pte_t pte, size_t *pgsize)
>> >+{
>> >+	pgd_t *pgd = pgd_offset(mm, addr);
>> >+	pud_t *pud;
>> >+	pmd_t *pmd;
>> >+
>> >+	if (!pte_cont(pte))
>> >+		return 1;
>> >+
>> >+	pud = pud_offset(pgd, addr);
>> >+	pmd = pmd_offset(pud, addr);
> We need to check for pgd_present and pud_present as we walk.
> I would be tempted to VM_BUG_ON if they are in an unexpected state.
Ok.
>
>> >+	if ((pte_t *)pmd == ptep) {
>> >+		*pgsize = PMD_SIZE;
>> >+		return CONT_PMDS;
>> >+	}
> I would check for pmd_present and VM_BUG_ON if it wasn't in an expected
> state.
>
>> >+	*pgsize = PAGE_SIZE;
>> >+	return CONT_PTES;
>> >+}
> Another approach would be something like:
>
> struct vm_area_struct *vma = find_vma(mm, addr);
> struct hstate *h = hstate_vma(vma);
> size_t size = hpage_size(h);
>
> But I think looking at the page table entries like you've done (with
> some checking) may be a little better as it can supply some more robust
> debugging with DEBUG_VM selected (and it doesn't need to find_vma).

I left it as-is with the appropriate checks added.
>> >+
>> >+extern void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
>> >+			    pte_t *ptep, pte_t pte)
> We don't need this extern.

Ok.
>> >+{
>> >+	size_t pgsize;
>> >+	int ncontig = find_num_contig(mm, addr, ptep, pte, &pgsize);
>> >+
>> >+	if (ncontig == 1) {
>> >+		set_pte_at(mm, addr, ptep, pte);
> We can return early here and avoid a level of indentation below.
Ok.

>> >+	} else {
>> >+		int i;
>> >+		unsigned long pfn = pte_pfn(pte);
>> >+		pgprot_t hugeprot =
>> >+			__pgprot(pte_val(pfn_pte(pfn, 0) ^ pte_val(pte)));
>> >+		for (i = 0; i < ncontig; i++) {
>> >+			pr_debug("%s: set pte %p to 0x%llx\n", __func__, ptep,
>> >+				 pfn_pte(pfn, hugeprot));
>> >+			set_pte_at(mm, addr, ptep, pfn_pte(pfn, hugeprot));
>> >+			ptep++;
>> >+			pfn += pgsize / PAGE_SIZE;
> nit: pgsize >> PAGE_SHIFT
>
>> >+			addr += pgsize;
>> >+		}
>> >+	}
>> >+}
> I see... so the contiguous pte and pmd cases are folded together.
> The pgsize variable name could be changed, perhaps something like blocksize?
> (I am terrible at picking names though :-)).

Well, isn't it still called a page even it it happens to be a
pmd level/huge page?

>
>> >+
>> >+pte_t *huge_pte_alloc(struct mm_struct *mm,
>> >+		      unsigned long addr, unsigned long sz)
>> >+{
>> >+	pgd_t *pgd;
>> >+	pud_t *pud;
>> >+	pte_t *pte = NULL;
>> >+
>> >+	pr_debug("%s: addr:0x%lx sz:0x%lx\n", __func__, addr, sz);
>> >+	pgd = pgd_offset(mm, addr);
>> >+	pud = pud_alloc(mm, pgd, addr);
> Probably better to simplify the levels of indentation with:
> 	if (!pud)
> 		return NULL;
> (or goto out before your pr_debug)

Ok.
>
>> >+	if (pud) {
> Perhaps better to do something with switch(sz) below?

The problem with using switch is that depending on the number of
page table levels, some of the cases degenerate to the same value.
So we end up with compile time errors because of duplicate case
statements.
>
>> >+		if (sz == PUD_SIZE) {
>> >+			pte = (pte_t *)pud;
>> >+		} else if (sz == (PAGE_SIZE * CONT_PTES)) {
>> >+			pmd_t *pmd = pmd_alloc(mm, pud, addr);
>> >+
>> >+			WARN_ON(addr & (sz - 1));
>> >+			pte = pte_alloc_map(mm, NULL, pmd, addr);
>> >+		} else if (sz == PMD_SIZE) {
>> >+#ifdef CONFIG_ARCH_WANT_HUGE_PMD_SHARE
>> >+			if (pud_none(*pud))
>> >+				pte = huge_pmd_share(mm, addr, pud);
>> >+			else
>> >+#endif
> This can be simplified to something like:
>
> if (IS_ENABLED(CONFIG_ARCH_WANT_HUGE_PMD_SHARE)
> 	&& pud_none(*pud))
> else
>
> So we can remove the preprocessor macros.
Ok.
> >+
> >+pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
> >+{
> >+	pgd_t *pgd;
> >+	pud_t *pud;
> >+	pmd_t *pmd = NULL;
> >+	pte_t *pte = NULL;
> >+
> >+	pgd = pgd_offset(mm, addr);
> >+	pr_debug("%s: addr:0x%lx pgd:%p\n", __func__, addr, pgd);
> >+	if (pgd_present(*pgd)) {
> Again drop a level of indentation with:
> if (!pgd_present(*pgd))
> 	return NULL;
>
> Similarly for pud_present and pmd_present.
Ok.
>
>
> >+}
> >+
> >+pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
> >+			 struct page *page, int writable)
> >+{
> >+	size_t pagesize = huge_page_size(hstate_vma(vma));
> >+
> I would go for switch(pagesize) here.
Same as above.
>
>> >+	if (pagesize == CONT_PTE_SIZE) {
>> >+		entry = pte_mkcont(entry);
>> >+	} else if (pagesize == CONT_PMD_SIZE) {
>> >+		entry = pmd_pte(pmd_mkcont(pte_pmd(entry)));
>> >+	} else if (pagesize != PUD_SIZE && pagesize != PMD_SIZE) {
>> >+		pr_warn("%s: unrecognized huge page size 0x%lx\n",
>> >+		       __func__, pagesize);
>> >+	}
>> >+	return entry;
>> >+}
>> >+
>> >+extern pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
>> >+				     unsigned long addr, pte_t *ptep)
>> >+{
>> >+	pte_t pte = {0};
> nit: Do we need an initial value for pte?

No, it's not necessary.
>
>> >+
>> >+	if (pte_cont(*ptep)) {
>> >+		int ncontig, i;
>> >+		size_t pgsize;
>> >+		pte_t *cpte;
>> >+		bool is_dirty = false;
>> >+
>> >+		cpte = huge_pte_offset(mm, addr);
>> >+		ncontig = find_num_contig(mm, addr, cpte,
>> >+					  pte_val(*cpte), &pgsize);
>> >+		/* save the 1st pte to return */
>> >+		pte = ptep_get_and_clear(mm, addr, cpte);
>> >+		for (i = 1; i < ncontig; ++i) {
>> >+			if (pte_dirty(ptep_get_and_clear(mm, addr, ++cpte)))
>> >+				is_dirty = true;
>> >+		}
This is the bug I mentioned above which was caught by the test suite.
If CONFIG_ARM64_HW_AFDBM is defined then pte_dirty() becomes a
macro which evaluates its argument twice.  I've got a side-effect in there
(++cpte) so it ends up clearing ptes that it shouldn't.

> Nice, we are keeping track of the dirty state. This looks to me like
> it*should*  work well with the dirty bit management patch that Catalin
> introduced:
> 2f4b829 arm64: Add support for hardware updates of the access and dirty pte bits
>
> Because ptep_get_and_clear will atomically get and clear the pte with
> respect to the hardware dirty bit management thus we don't lose any
> dirty information. huge_pte_dirty is then called on the extracted pte
> by core code.
>
> For a contiguous set of ptes/pmds the individual entry will be dirtied
> by DBM rather than the complete set so it's good to check them all for
> dirty when going through a get and clear.
>
> Technically we don't need to track dirty if CONFIG_ARM64_HW_AFDBM is
> not defined as the core code will fault and modify the entire set of
> ptes otherwise.
>
> I would be tempted to keep this code as is, but add a comment that
> tracking the dirty variable here helps for when we switch on
> CONFIG_ARM64_HW_AFDBM.
I added a comment to try to make all this more clear.
>> >+
>> >+#ifdef CONFIG_ARM64_64K_PAGES
>> >+static __init int add_default_hugepagesz(void)
>> >+{
>> >+	if (size_to_hstate(CONT_PTES * PAGE_SIZE) == NULL)
>> >+		hugetlb_add_hstate(CONT_PMD_SHIFT);
>> >+	return 0;
>> >+}
>> >+arch_initcall(add_default_hugepagesz);
>> >+#endif
> Why is this initcall defined? Was it for testing?
This is intentional and in a way, the motivation for these changes. We're
expecting most of our customers to run with a 64K granule, but 512M is
too big as a huge page size in many cases.  2M is a lot more useful for
these applications and it's convenient because it is also the default huge
page size with a 4K granule.  We think it's useful enough to enable by
default, but are interested to know your thoughts on that.

>
> I think we are missing a few functions:
> huge_ptep_set_access_flags
> huge_ptep_set_wrprotect
> huge_ptep_clear_flush
>
> These functions need to loop through the contiguous set of ptes
> or pmds. They should call into the ptep_ equivalents as they will
> then work with the DBM patch.
huge_ptep_set_access_flags() was there already, but I've added
the other two.
>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
