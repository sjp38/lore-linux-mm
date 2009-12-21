Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E58DB620001
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 15:32:17 -0500 (EST)
Date: Mon, 21 Dec 2009 20:31:50 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 25 of 28] transparent hugepage core
Message-ID: <20091221203149.GD23345@csn.ul.ie>
References: <patchbomb.1261076403@v2.random> <4d96699c8fb89a4a22eb.1261076428@v2.random> <20091218200345.GH21194@csn.ul.ie> <20091219164143.GC29790@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091219164143.GC29790@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, Dec 19, 2009 at 05:41:43PM +0100, Andrea Arcangeli wrote:
> > On Thu, Dec 17, 2009 at 07:00:28PM -0000, Andrea Arcangeli wrote:
> > > diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> > > new file mode 100644
> > > --- /dev/null
> > > +++ b/include/linux/huge_mm.h
> > > @@ -0,0 +1,110 @@
> > > +#ifndef _LINUX_HUGE_MM_H
> > > +#define _LINUX_HUGE_MM_H
> > > +
> > > +extern int do_huge_anonymous_page(struct mm_struct *mm,
> > > +				  struct vm_area_struct *vma,
> > > +				  unsigned long address, pmd_t *pmd,
> > > +				  unsigned int flags);
> > > +extern int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
> > > +			 pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
> > > +			 struct vm_area_struct *vma);
> > > +extern int do_huge_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
> > > +			   unsigned long address, pmd_t *pmd,
> > > +			   pmd_t orig_pmd);
> > > +extern pgtable_t get_pmd_huge_pte(struct mm_struct *mm);
> > 
> On Fri, Dec 18, 2009 at 08:03:46PM +0000, Mel Gorman wrote:
> > The naming of "huge" might bite in the ass later if/when transparent
> > support is applied to multiple page sizes. Granted, it's not happening
> > any time soon.
> 
> Granted ;). But why not huge? I think you just want to add "pmd" there
> maybe, like do_huge_pmd_anonymous_page and do_huge_pmd_wp_page. The
> other two already looks fine to me. Huge means it's part of the
> hugepage support so I would keep it, otherwise you'd need to like a
> name like get_pmd_pte (that is less intuitiv than get_pmd_huge_pte).
> 

My vague worry is that multiple huge page sizes are currently supported in
hugetlbfs but transparent support is obviously tied to the page-table level
it's implemented for. In the future, the term "huge" could be ambiguous . How
about instead of things like HUGE_MASK, it would be HUGE_PMD_MASK? It's not
something I feel very strongly about as eventually I'll remember what sort of
"huge" is meant in each context.

> > > +extern struct page *follow_trans_huge_pmd(struct mm_struct *mm,
> > > +					  unsigned long addr,
> > > +					  pmd_t *pmd,
> > > +					  unsigned int flags);
> > > +extern int zap_pmd_trans_huge(struct mmu_gather *tlb,
> > > +			      struct vm_area_struct *vma,
> > > +			      pmd_t *pmd);
> > > +
> > > +enum transparent_hugepage_flag {
> > > +	TRANSPARENT_HUGEPAGE_FLAG,
> > > +	TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
> > > +	TRANSPARENT_HUGEPAGE_DEFRAG_FLAG,
> > 
> > Defrag is misleading. Glancing through the rest of the patch, "try harder"
> > would be a more appropriate term because it uses __GFP_REPEAT.
> 
> No. Yes, open source has the defect that some people has nothing
> better to do so they break visible kernel APIs in /sys /proc and marks
> them obsoleted in make menuconfig and they go fixup userland often
> with little practical gain but purely aesthetical purist reasons, so
> to try to avoid that I just tried to make a visible kernel API that
> has a chance to survive 1 year of development without breaking
> userland.
> 
> That means calling it "defrag" because "defrag" eventually will
> happen. Right now the best approximation is __GFP_REPEAT, so be it,
> but the visible kernel API must be done in a way that isn't tied to
> current internal implementation or cleverness of defrag. So please
> help in fighting the constant API breakage in /sys and those OBSOLETE
> marks in menuconfig (you may disable it if your userland is uptodate,
> etc...).
> 

You've fully convinced me. Put a comment there to the effect of

/*
 * Currently uses  __GFP_REPEAT during allocation. Should be implemented
 * using page migration in the future
 */

> In fact I ask you to review from the entirely opposite side, so
> thinking more long term. Still trying not to overdesign though.
> 
> > 
> > > diff --git a/mm/Makefile b/mm/Makefile
> > > --- a/mm/Makefile
> > > +++ b/mm/Makefile
> > > @@ -40,3 +40,4 @@ obj-$(CONFIG_MEMORY_FAILURE) += memory-f
> > >  obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
> > >  obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
> > >  obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
> > > +obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o
> > > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > > new file mode 100644
> > > --- /dev/null
> > > +++ b/mm/huge_memory.c
> > 
> > Similar on naming. Later someone will get congused as to why there is
> > hugetlbfs and huge_memory.
> 
> Why? Unless you want to change HUGETLBFS name too and remove HUGE from
> there too, there's absolutely no reason to remove the huge name from
> transparent hugepages. In fact to the contrary I used HUGE exactly
> because that is how hugetlbfs call them! Otherwise I would have used
> transparent largepages. Whatever hugetlbfs uses, transparent hugepage
> also has to use that naming. Otherwise it's a mess. They're indentical
> features, one is transparent allocated, the other is not and requires
> an pseudo-fs to allocate them. The result, performance, and pagetable
> layout generated is identical too.
> 
> I've no clue what confusion you're worried about here,

I was looking at it from the wrong angle. I saw the name in the context on
mm/hugetlb.c and felt it was unclear. Now that I look at it again, I should
have seen it as a "huge" version of memory.c. Sorry for the noise.

> I didn't call
> this hugetlbfs. This is transparent_hugepage, and that seems really
> strightforwad and obvious what it means (same thing, one through fs,
> the other transparent).
> 
> You can argue I should have called it transparent_hugetlb! That one we
> can argue about, but arguing about the "huge" doesn't make sense to
> me.
> 
> If you want to rename this to transparent_hugetlb and I'll do it. So
> it's even more clear the only difference between hugetlbfs and
> transparent_hugetlb.

Leave it as-is. I'm not seeing it as a huge version of memory.c and it's
clearer.

> But personally I think hugetlb is not the
> appropriate name only for one reason: later we may want to use
> hugepages on pagecache too, but those pagecache will be hugepages, but
> not mapped by any tlb if they're the result of a read/write. In fact
> this is true for hugetlbfs too when you read/write, no tlb involvement
> at all! Which is why hugetlbfs should also renamed to hugepagefs if something!
> 
> > > +static int __do_huge_anonymous_page(struct mm_struct *mm,
> > > +				    struct vm_area_struct *vma,
> > > +				    unsigned long address, pmd_t *pmd,
> > > +				    struct page *page,
> > 
> > Maybe this should be do_pmd_anonymous page and match what do_anonymous_page
> > does as much as possible. This might offset any future problems related to
> > transparently handling pages at other page table levels.
> 
> Why not do_huge_pmd_anonymous_page. This is an huge pmd after all and
> as said above removing huge from all places it's going to screw over
> some funtions that are specific for huge pmd and not for regular pmd.
> 

do_huge_pmd_anonymous_page makes sense.

> I'll make this change, it's fine with me.
> 
> > > +				    unsigned long haddr)
> > > +{
> > > +	int ret = 0;
> > > +	pgtable_t pgtable;
> > > +
> > > +	VM_BUG_ON(!PageCompound(page));
> > > +	pgtable = pte_alloc_one(mm, address);
> > > +	if (unlikely(!pgtable)) {
> > > +		put_page(page);
> > > +		return VM_FAULT_OOM;
> > > +	}
> > > +
> > > +	clear_huge_page(page, haddr, HPAGE_NR);
> > > +
> > 
> > Ideally insead of defining things like HPAGE_NR, the existing functions for
> > multiple huge page sizes would be extended to return the "huge page size
> > corresponding to a PMD".
> 
> You mean PMD_SIZE? Again this is the whole discussion if HPAGE should
> be nuked as a whole in favour of PMD_something.
> 
> I'm unsure if favouring the PMD/PUD nomenclature is the way to go,
> considering the main complaint one can have is for archs that may have
> mixed page size that isn't a match of PMD/PUD at all!

As it's currently tied to the PMD, the naming should reflect it. If an
architecture does want to have transparent hugepage support but the target
size is not at the PMD level, they will need to make some major modifications
anyway. I'm effectively off-line in terms of access to sources and work
material so at the moment, I'm having trouble seeing how an architecture
would handle the problem.

> I'm open to
> suggestions just worrying about huge PUD seems not realistic, while a
> mixed page size that won't ever match pmd or pud is more
> realistic. power can't do it as it can't fallback, but maybe ia64 or
> others can do, I don't know.

IA-64 can't in its currently implementation. Due to the page table format
they use, huge pages can only be mapped at specific ranges in the virtual
address space. If the long-format version of the page table was used, they
would be able to but I bet it's not happening any time soon. The best bet
for other architectures supporting this would be sparc and maybe sh.
It might be worth poking Paul Mundt in particular because he expressed
an interest in transparent support of some sort in the past for sh.

> Surely anything realistic won't match
> PUD this is my main reason for disliking binding the whole patch to
> pmd sizes like if PUD sizes would be relevant.
> 

Again, I'm not going to make a major issue of it. It'd be my preference
but chances are I'll stop caring once I've read the patchset three or
four more times.

> > > +	__SetPageUptodate(page);
> > > +	smp_wmb();
> > > +
> > 
> > Need to explain why smp_wmb() is needed there. It doesn't look like
> > you're protecting the bit set itself. More likely you are making sure
> > the writes in clear_huge_page() have finished but that's a guess.
> > Comment.
> 
> Yes. Same as __pte_alloc. You're not the first asking this, I'll add
> comment.
> 

Thanks

> > > +	spin_lock(&mm->page_table_lock);
> > > +	if (unlikely(!pmd_none(*pmd))) {
> > > +		put_page(page);
> > > +		pte_free(mm, pgtable);
> > 
> > Racing fault already filled in the PTE? If so, comment please. Again,
> > matching how do_anonymous_page() does a similar job would help
> > comprehension.
> 
> Yes racing thread already mapped in a pmd large (or a pte if hugepage
> allocation failed). Adding comment... ;)
> 

Thanks

> > > +	if (haddr >= vma->vm_start && haddr + HPAGE_SIZE <= vma->vm_end) {
> > > +		if (unlikely(anon_vma_prepare(vma)))
> > > +			return VM_FAULT_OOM;
> > > +		page = alloc_pages(GFP_HIGHUSER_MOVABLE|__GFP_COMP|
> > > +				   (transparent_hugepage_defrag(vma) ?
> > 
> > GFP_HIGHUSER_MOVABLE should only be used if hugepages_treat_as_movable
> > is set in /proc/sys/vm. This should be GFP_HIGHUSER only.
> 
> Why?

Because huge pages cannot move. If the MOVABLE zone has been set up to
guarantee memory hot-plug removal, they don't want huge pages to be
getting in the way. To allow unconditional use of GFP_HIGHUSER_MOVABLE,
memory hotplug would have to know it can demote all the transparent huge
pages and migrate them that way.

> Either we move htlb_alloc_mask into common code so that it exists
> even when HUGETLBFS=n (like I had to do to share the copy_huge
> routines to share as much as possible with hugetlbfs), or this should
> remain movable to avoid crippling down the
> feature.

My preference would be to move the alloc_mask into common code or at
least make it available via mm/internal.h because otherwise this will
collide with memory hot-remove in the future.

> hugepages_treat_as_movable right now only applies to
> hugetlbfs. We've only to decide if to apply it to transparent
> hugepages too.
> 

I see no problem with applying it to transparent hugepages as well.

> > > +	if (transparent_hugepage_debug_cow() && new_page) {
> > > +		put_page(new_page);
> > > +		new_page = NULL;
> > > +	}
> > > +	if (unlikely(!new_page)) {
> > 
> > This entire block needs be in a demote_pmd_page() or something similar.
> > It's on the hefty side for being in the main function. That said, I
> > didn't spot anything wrong in there either.
> 
> Yeah this is a cleanup I should do but it's not as easy as it looks or
> I would have done it already when Adam asked me a few weeks ago.
> 

Ok.

> > > +			}
> > > +		}
> > > +
> > > +		spin_lock(&mm->page_table_lock);
> > > +		if (unlikely(!pmd_same(*pmd, orig_pmd)))
> > > +			goto out_free_pages;
> > > +		else
> > > +			get_page(page);
> > > +		spin_unlock(&mm->page_table_lock);
> > > +
> > > +		might_sleep();
> > 
> > Is this check really necessary? We could already go alseep easier when
> > allocating pages.
> 
> Ok, removed might_sleep().
> 
> > 
> > > +		for (i = 0; i < HPAGE_NR; i++) {
> > > +			copy_user_highpage(pages[i], page + i,
> > 
> > More nasty naming there. Needs to be cleared that pages is your demoted
> > base pages and page is the existing compound page.
> 
> what exactly is not clear?

Because ordinarily "pages" is just the plural of page. It was not
immediately clear that this was dest_pages and src_page. I guess if it
was in a separate function, it would have been a lot more obvious.

> You already asked to move this code into a
> separate function. What else to document this is the "fallback" copy
> to 4k pages? renaming pages[] to 4k_pages[] doesn't seem necessary to
> me, besides copy_user_highpage work on PAGE_SIZE not HPAGE_SIZE.
> 
> > > +		pmd_t _pmd;
> > > +		/*
> > > +		 * We should set the dirty bit only for FOLL_WRITE but
> > > +		 * for now the dirty bit in the pmd is meaningless.
> > > +		 * And if the dirty bit will become meaningful and
> > > +		 * we'll only set it with FOLL_WRITE, an atomic
> > > +		 * set_bit will be required on the pmd to set the
> > > +		 * young bit, instead of the current set_pmd_at.
> > > +		 */
> > > +		_pmd = pmd_mkyoung(pmd_mkdirty(*pmd));
> > > +		set_pmd_at(mm, addr & HPAGE_MASK, pmd, _pmd);
> > > +	}
> > > +	page += (addr & ~HPAGE_MASK) >> PAGE_SHIFT;
> > 
> > More HPAGE vs PMD here.
> 
> All of them or none, not sure why you mention it on the MASK, maybe
> it's just an accident. Every single HPAGE_SIZE has to be changed too!

Yes, it would. I didn't point it out every time.

> Not just HPAGE_MASK, or it's pointless.
> 
> > > +static int __split_huge_page_splitting(struct page *page,
> > > +				       struct vm_area_struct *vma,
> > > +				       unsigned long address)
> > > +{
> > > +	struct mm_struct *mm = vma->vm_mm;
> > > +	pmd_t *pmd;
> > > +	int ret = 0;
> > > +
> > > +	spin_lock(&mm->page_table_lock);
> > > +	pmd = page_check_address_pmd(page, mm, address,
> > > +				     PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG);
> > > +	if (pmd) {
> > > +		/*
> > > +		 * We can't temporarily set the pmd to null in order
> > > +		 * to split it, pmd_huge must remain on at all times.
> > > +		 */
> > 
> > Why, to avoid a double fault? Or to avoid a case where the huge page is
> > being split, another fault occurs and zero-filled pages get faulted in?
> 
> Well initially I did pmdp_clear_flush and overwritten it. It was a
> nasty race to find and fix, wasted some time on it.

Ok

> once the pmd
> is zero, anything can happen, it's like a page not faulted in yet,
> nobody will take the slow path of pmd_huge anymore to serialize
> against the split_huge_page with anon_vma->lock.
>  

Thanks for the explanation.


> > I'm afraid I ran out of time at this point. It'll be after the holidays
> > before I get time for a proper go at it. Sorry.
> 
> Understood. The main trouble I see in your comments is the pmd vs huge
> name. Please consider what I mentioned above about more realistic
> different hpage sizes that won't match either pmd/pud. And the
> pud_size being unusable until we get higher orders of magnitude of ram
> sizes. Then decide if to change every single HPAGE to PMD or to stick
> with this. I'm personally netural, I _never_ care about names, I only
> care about what assembly gcc produces.
> 

I would prefer pmd to be added to the huge names. However, this was
mostly to aid comprehension of the patchset when I was taking a quick
read. Once I get the chance to read it often enough, I'll care a lot
less.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
