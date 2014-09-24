Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 83B696B0036
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 11:57:35 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id x13so6049008wgg.16
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 08:57:35 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
        by mx.google.com with ESMTPS id ka3si19832682wjc.127.2014.09.24.08.57.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Sep 2014 08:57:34 -0700 (PDT)
Received: by mail-wi0-f177.google.com with SMTP id q5so7606102wiv.16
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 08:57:33 -0700 (PDT)
Date: Wed, 24 Sep 2014 16:57:27 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [PATCH V3 1/6] mm: Introduce a general RCU get_user_pages_fast.
Message-ID: <20140924155726.GA28390@linaro.org>
References: <1409237107-24228-1-git-send-email-steve.capper@linaro.org>
 <1409237107-24228-2-git-send-email-steve.capper@linaro.org>
 <alpine.LSU.2.11.1409240633190.10068@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1409240633190.10068@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux@arm.linux.org.uk, linux-arch@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com, gary.robertson@linaro.org, christoffer.dall@linaro.org, peterz@infradead.org, anders.roxell@linaro.org, dann.frazier@canonical.com, mark.rutland@arm.com, mgorman@suse.de

On Wed, Sep 24, 2014 at 06:34:56AM -0700, Hugh Dickins wrote:
> On Thu, 28 Aug 2014, Steve Capper wrote:
> 
> > get_user_pages_fast attempts to pin user pages by walking the page
> > tables directly and avoids taking locks. Thus the walker needs to be
> > protected from page table pages being freed from under it, and needs
> > to block any THP splits.
> > 
> > One way to achieve this is to have the walker disable interrupts, and
> > rely on IPIs from the TLB flushing code blocking before the page table
> > pages are freed.
> > 
> > On some platforms we have hardware broadcast of TLB invalidations, thus
> > the TLB flushing code doesn't necessarily need to broadcast IPIs; and
> > spuriously broadcasting IPIs can hurt system performance if done too
> > often.
> > 
> > This problem has been solved on PowerPC and Sparc by batching up page
> > table pages belonging to more than one mm_user, then scheduling an
> > rcu_sched callback to free the pages. This RCU page table free logic
> > has been promoted to core code and is activated when one enables
> > HAVE_RCU_TABLE_FREE. Unfortunately, these architectures implement
> > their own get_user_pages_fast routines.
> > 
> > The RCU page table free logic coupled with a an IPI broadcast on THP
> > split (which is a rare event), allows one to protect a page table
> > walker by merely disabling the interrupts during the walk.
> > 
> > This patch provides a general RCU implementation of get_user_pages_fast
> > that can be used by architectures that perform hardware broadcast of
> > TLB invalidations.
> > 
> > It is based heavily on the PowerPC implementation by Nick Piggin.
> 
> That's a helpful description above, thank you; and the patch looks
> mostly good to me.  I took a look because I see time is running out,
> and you're having trouble getting review of this one: I was hoping
> to give you a quick acked-by, but cannot do so as yet.
> 
> Most of my remarks below are trivial comments on where it
> needs a little more, to be presented as a generic implementation in
> mm/gup.c.  And most come from comparing against an up-to-date version
> of arch/x86/mm/gup.c: please do the same, I may have missed some.
> 
> It would be a pity to mess up your arm schedule for lack of linkage
> to this one: maybe this patch can go in as is, and be fixed up a
> litte later (that would be up to Andrew); or maybe you'll have
> no trouble making the changes before the merge window; or maybe
> this should just be kept with arm and arm64 for now (but thank
> you for making the effort to give us a generic version).
> 
> Hugh

Hi Hugh,
A big thank you for taking a look at this.

> 
> > 
> > Signed-off-by: Steve Capper <steve.capper@linaro.org>
> > Tested-by: Dann Frazier <dann.frazier@canonical.com>
> > Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> > ---
> >  mm/Kconfig |   3 +
> >  mm/gup.c   | 278 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 281 insertions(+)
> > 
> > diff --git a/mm/Kconfig b/mm/Kconfig
> > index 886db21..0ceb8a5 100644
> > --- a/mm/Kconfig
> > +++ b/mm/Kconfig
> > @@ -137,6 +137,9 @@ config HAVE_MEMBLOCK_NODE_MAP
> >  config HAVE_MEMBLOCK_PHYS_MAP
> >  	boolean
> >  
> > +config HAVE_GENERIC_RCU_GUP
> 
> I'm not wild about that name (fast GUP does require that page tables
> cannot be freed beneath it, and RCU freeing of page tables is one way
> in which that can be guaranteed for this implementation); but I cannot
> suggest a better, so let's stick with it.
> 

Yeah, we couldn't think of a better one. :-(

> > +	boolean
> > +
> >  config ARCH_DISCARD_MEMBLOCK
> >  	boolean
> >  
> > diff --git a/mm/gup.c b/mm/gup.c
> > index 91d044b..5e6f6cb 100644
> > --- a/mm/gup.c
> > +++ b/mm/gup.c
> > @@ -10,6 +10,10 @@
> >  #include <linux/swap.h>
> >  #include <linux/swapops.h>
> >  
> > +#include <linux/sched.h>
> > +#include <linux/rwsem.h>
> > +#include <asm/pgtable.h>
> > +
> >  #include "internal.h"
> >  
> >  static struct page *no_page_table(struct vm_area_struct *vma,
> > @@ -672,3 +676,277 @@ struct page *get_dump_page(unsigned long addr)
> >  	return page;
> >  }
> >  #endif /* CONFIG_ELF_CORE */
> > +
> > +#ifdef CONFIG_HAVE_GENERIC_RCU_GUP
> 
> This desperately needs a long comment explaining the assumptions made,
> and what an architecture must supply and guarantee to use this option.
> 
> Maybe your commit message already provides a good enough comment (I
> have not now re-read it in that light) and can simply be inserted here.
> I don't think it needs to spell everything out, but it does need to
> direct a maintainer to thinking through the appropriate issues.

Agreed, I think a summary of the logic and the pre-requisites in a
comment block will make this a lot easier to adopt.

> 
> > +
> > +#ifdef __HAVE_ARCH_PTE_SPECIAL
> > +static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
> > +			 int write, struct page **pages, int *nr)
> > +{
> > +	pte_t *ptep, *ptem;
> > +	int ret = 0;
> > +
> > +	ptem = ptep = pte_offset_map(&pmd, addr);
> > +	do {
> > +		pte_t pte = ACCESS_ONCE(*ptep);
> 
> Here is my only substantive criticism.  I don't know the arm architecture,
> but my guess is that your LPAE has a similar problem to x86's PAE: that
> the pte entry is bigger than the natural word size of the architecture,
> and so cannot be safely accessed in one operation on SMP or PREEMPT -
> there's a danger that you get mismatched top and bottom halves here.
> And how serious that is depends upon the layout of the pte bits.
> 
> See comments on gup_get_pte() in arch/x86/mm/gup.c,
> and pte_unmap_same() in mm/memory.c.

Thanks, on ARM platforms with LPAE support this will be okay as 64-bit
single-copy atomicity is guaranteed for reading pagetable entries.

> 
> And even if arm's LPAE is safe, this is unsafe to present in generic
> code, or not without a big comment that GENERIC_RCU_GUP should not be
> used for such configs; or, better than a comment, a build time error
> according to sizeof(pte_t).
> 

I was thinking of introducing something like: ARCH_HAS_ATOMIC64_PTE_READS,
then putting in some compiler logic; it looked overkill to me.

Then I thought of adding a comment to this line of code and explicitly
adding a pre-requisite to the comments block that I'm about to add before
#ifdef CONFIG_HAVE_GENERIC_RCU_GUP
Hopefully that'll be okay.

> (It turns out not to be a problem at pmd, pud and pgd level: IIRC
> that's because the transitions at those levels are much more restricted,
> limited to setting, then clearing on pagetable teardown - except for
> the THP transitions which the local_irq_disable() guards against.)
> 
> Ah, enlightenment: arm (unlike arm64) does not __HAVE_ARCH_PTE_SPECIAL,
> so this "dangerous" code won't be compiled in for it, it's only using
> the stub below.  Well, you can see my point about needing more
> comments, those would have saved me a LOT of time.
> 

This is so we can cover the futex on THP tail case without the need for
__HAVE_ARCH_PTE_SPECIAL.

> > +		struct page *page;
> > +
> > +		if (!pte_present(pte) || pte_special(pte)
> > +			|| (write && !pte_write(pte)))
> 
> The " ||" at end of line above please.  And, more importantly,
> we need a pte_numa() test in here nowadays, for generic use.
> 
Will do.
Ahh, okay, apologies I didn't spot pte_numa tests being introduced.
I will check for other changes.

> > +			goto pte_unmap;
> > +
> > +		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
> > +		page = pte_page(pte);
> > +
> > +		if (!page_cache_get_speculative(page))
> > +			goto pte_unmap;
> > +
> > +		if (unlikely(pte_val(pte) != pte_val(*ptep))) {
> > +			put_page(page);
> > +			goto pte_unmap;
> > +		}
> > +
> > +		pages[*nr] = page;
> > +		(*nr)++;
> > +
> > +	} while (ptep++, addr += PAGE_SIZE, addr != end);
> > +
> > +	ret = 1;
> > +
> > +pte_unmap:
> > +	pte_unmap(ptem);
> > +	return ret;
> > +}
> > +#else
> > +
> > +/*
> > + * If we can't determine whether or not a pte is special, then fail immediately
> > + * for ptes. Note, we can still pin HugeTLB and THP as these are guaranteed not
> > + * to be special.
> 
> From that comment, I just thought it very weird that you were compiling
> in any of this HAVE_GENERIC_RCU_GUP code in the !__HAVE_ARCH_PTE_SPECIAL
> case.  But somewhere else, over in the 0/6, you have a very important
> remark about futex on THP tail which makes sense of it: please add that
> explanation here.

Sure thing, thanks.

> 
> > + */
> > +static inline int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
> 
> checkpatch.pl is noisy about that line over 80 characters, whereas
> you understandably prefer to keep the stub declaration just like the
> main declaration.  Simply omit the " inline"?  The compiler should be
> able to work that out for itself, and it doesn't matter if it cannot.
> 

Okay, thanks.

> > +			 int write, struct page **pages, int *nr)
> > +{
> > +	return 0;
> > +}
> > +#endif /* __HAVE_ARCH_PTE_SPECIAL */
> > +
> > +static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
> > +		unsigned long end, int write, struct page **pages, int *nr)
> > +{
> > +	struct page *head, *page, *tail;
> > +	int refs;
> > +
> > +	if (write && !pmd_write(orig))
> > +		return 0;
> > +
> > +	refs = 0;
> > +	head = pmd_page(orig);
> > +	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
> > +	tail = page;
> > +	do {
> > +		VM_BUG_ON(compound_head(page) != head);
> 
> VM_BUG_ON_PAGE() is the latest preference.

Cheers, I will update this...

> 
> > +		pages[*nr] = page;
> > +		(*nr)++;
> > +		page++;
> > +		refs++;
> > +	} while (addr += PAGE_SIZE, addr != end);
> > +
> > +	if (!page_cache_add_speculative(head, refs)) {
> > +		*nr -= refs;
> > +		return 0;
> > +	}
> > +
> > +	if (unlikely(pmd_val(orig) != pmd_val(*pmdp))) {
> > +		*nr -= refs;
> > +		while (refs--)
> > +			put_page(head);
> > +		return 0;
> > +	}
> > +
> > +	/*
> > +	 * Any tail pages need their mapcount reference taken before we
> > +	 * return. (This allows the THP code to bump their ref count when
> > +	 * they are split into base pages).
> > +	 */
> > +	while (refs--) {
> > +		if (PageTail(tail))
> > +			get_huge_page_tail(tail);
> > +		tail++;
> > +	}
> > +
> > +	return 1;
> > +}
> > +
> > +static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
> > +		unsigned long end, int write, struct page **pages, int *nr)
> > +{
> > +	struct page *head, *page, *tail;
> > +	int refs;
> > +
> > +	if (write && !pud_write(orig))
> > +		return 0;
> > +
> > +	refs = 0;
> > +	head = pud_page(orig);
> > +	page = head + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
> > +	tail = page;
> > +	do {
> > +		VM_BUG_ON(compound_head(page) != head);
> 
> VM_BUG_ON_PAGE() is the latest preference.
> 

... and that :-).

> > +		pages[*nr] = page;
> > +		(*nr)++;
> > +		page++;
> > +		refs++;
> > +	} while (addr += PAGE_SIZE, addr != end);
> > +
> > +	if (!page_cache_add_speculative(head, refs)) {
> > +		*nr -= refs;
> > +		return 0;
> > +	}
> > +
> > +	if (unlikely(pud_val(orig) != pud_val(*pudp))) {
> > +		*nr -= refs;
> > +		while (refs--)
> > +			put_page(head);
> > +		return 0;
> > +	}
> > +
> > +	while (refs--) {
> > +		if (PageTail(tail))
> > +			get_huge_page_tail(tail);
> > +		tail++;
> > +	}
> > +
> > +	return 1;
> > +}
> > +
> > +static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
> > +		int write, struct page **pages, int *nr)
> > +{
> > +	unsigned long next;
> > +	pmd_t *pmdp;
> > +
> > +	pmdp = pmd_offset(&pud, addr);
> > +	do {
> > +		pmd_t pmd = ACCESS_ONCE(*pmdp);
> 
> I like to do it this way too, but checkpatch.pl prefers a blank line.
> 

Okay, I will add a blank line.

> > +		next = pmd_addr_end(addr, end);
> > +		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
> > +			return 0;
> > +
> > +		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd))) {
> 
> I wonder if you spent any time pondering pmd_large() and whether to
> use it here (and define it in arm): I have forgotten its relationship
> to pmd_huge() and pmd_trans_huge(), and you are probably right to
> steer clear of it.

pmd_large is only defined by a few architectures, I opted for
generality and clarity.

> 
> A pmd_numa() test is needed here nowadays, for generic use.
> 

Thanks, I will add the logic.

> > +			if (!gup_huge_pmd(pmd, pmdp, addr, next, write,
> > +				pages, nr))
> > +				return 0;
> > +		} else {
> > +			if (!gup_pte_range(pmd, addr, next, write, pages, nr))
> > +				return 0;
> > +		}
> 
> You've chosen a different (indentation and else) style here from what
> you use below in the very similar gup_pud_range(): it's easier to see
> the differences if you keep the style the same, personally I prefer
> how you did gup_pud_range().

Okay, I will re-structure.

> 
> > +	} while (pmdp++, addr = next, addr != end);
> > +
> > +	return 1;
> > +}
> > +
> > +static int gup_pud_range(pgd_t *pgdp, unsigned long addr, unsigned long end,
> > +		int write, struct page **pages, int *nr)
> > +{
> > +	unsigned long next;
> > +	pud_t *pudp;
> > +
> > +	pudp = pud_offset(pgdp, addr);
> > +	do {
> > +		pud_t pud = ACCESS_ONCE(*pudp);
> 
> I like to do it this way too, but checkpatch.pl prefers a blank line.

I'll add a line.

> 
> > +		next = pud_addr_end(addr, end);
> > +		if (pud_none(pud))
> > +			return 0;
> > +		if (pud_huge(pud)) {
> 
> I wonder if you spent any time pondering pud_large() and whether to
> use it here (and define it in arm): I have forgotten its relationship
> to pud_huge(), and you are probably right to steer clear of it.

I preferred pud_huge, due to it being more well defined.

> 
> > +			if (!gup_huge_pud(pud, pudp, addr, next, write,
> > +					pages, nr))
> > +				return 0;
> > +		} else if (!gup_pmd_range(pud, addr, next, write, pages, nr))
> > +			return 0;
> > +	} while (pudp++, addr = next, addr != end);
> > +
> > +	return 1;
> > +}
> > +
> > +/*
> > + * Like get_user_pages_fast() except its IRQ-safe in that it won't fall
> > + * back to the regular GUP.
> > + */
> > +int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
> > +			  struct page **pages)
> > +{
> > +	struct mm_struct *mm = current->mm;
> > +	unsigned long addr, len, end;
> > +	unsigned long next, flags;
> > +	pgd_t *pgdp;
> > +	int nr = 0;
> > +
> > +	start &= PAGE_MASK;
> > +	addr = start;
> > +	len = (unsigned long) nr_pages << PAGE_SHIFT;
> > +	end = start + len;
> > +
> > +	if (unlikely(!access_ok(write ? VERIFY_WRITE : VERIFY_READ,
> > +					start, len)))
> > +		return 0;
> > +
> > +	/*
> > +	 * Disable interrupts, we use the nested form as we can already
> > +	 * have interrupts disabled by get_futex_key.
> > +	 *
> > +	 * With interrupts disabled, we block page table pages from being
> > +	 * freed from under us. See mmu_gather_tlb in asm-generic/tlb.h
> > +	 * for more details.
> > +	 *
> > +	 * We do not adopt an rcu_read_lock(.) here as we also want to
> > +	 * block IPIs that come from THPs splitting.
> > +	 */
> > +
> > +	local_irq_save(flags);
> > +	pgdp = pgd_offset(mm, addr);
> > +	do {
> > +		next = pgd_addr_end(addr, end);
> > +		if (pgd_none(*pgdp))
> > +			break;
> > +		else if (!gup_pud_range(pgdp, addr, next, write, pages, &nr))
> > +			break;
> > +	} while (pgdp++, addr = next, addr != end);
> > +	local_irq_restore(flags);
> > +
> > +	return nr;
> > +}
> > +
> 
> The x86 version has a comment on this interface:
> it would be helpful to copy that here.
> 

Thanks, I'll copy it over.

> > +int get_user_pages_fast(unsigned long start, int nr_pages, int write,
> > +			struct page **pages)
> > +{
> > +	struct mm_struct *mm = current->mm;
> > +	int nr, ret;
> > +
> > +	start &= PAGE_MASK;
> > +	nr = __get_user_pages_fast(start, nr_pages, write, pages);
> 
> The x86 version has a commit from Linus, avoiding the access_ok() check
> in __get_user_pages_fast(): I confess I just did not spend long enough
> trying to understand what that's about, and whether it would be
> important to incorporate here.
> 

Thanks, I see the commit, I will need to have a think about it as it's
not immediately obvious to me.

> > +	ret = nr;
> > +
> > +	if (nr < nr_pages) {
> > +		/* Try to get the remaining pages with get_user_pages */
> > +		start += nr << PAGE_SHIFT;
> > +		pages += nr;
> > +
> > +		down_read(&mm->mmap_sem);
> > +		ret = get_user_pages(current, mm, start,
> > +				     nr_pages - nr, write, 0, pages, NULL);
> > +		up_read(&mm->mmap_sem);
> > +
> > +		/* Have to be a bit careful with return values */
> > +		if (nr > 0) {
> > +			if (ret < 0)
> > +				ret = nr;
> > +			else
> > +				ret += nr;
> > +		}
> > +	}
> > +
> > +	return ret;
> > +}
> > +
> > +#endif /* CONFIG_HAVE_GENERIC_RCU_GUP */
> > -- 
> > 1.9.3

Thanks again Hugh for the very useful comments.

Cheers,
-- 
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
