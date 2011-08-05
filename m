Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 4292C6B0169
	for <linux-mm@kvack.org>; Fri,  5 Aug 2011 12:22:19 -0400 (EDT)
Date: Fri, 5 Aug 2011 18:21:51 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] THP: mremap support and TLB optimization #2
Message-ID: <20110805162151.GX9770@redhat.com>
References: <20110728142631.GI3087@redhat.com>
 <20110805152516.GI9211@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110805152516.GI9211@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Fri, Aug 05, 2011 at 04:25:16PM +0100, Mel Gorman wrote:
> > +int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
> > +		  unsigned long old_addr,
> > +		  unsigned long new_addr, unsigned long old_end,
> > +		  pmd_t *old_pmd, pmd_t *new_pmd)
> > +{
> > +	int ret = 0;
> > +	pmd_t pmd;
> > +
> > +	struct mm_struct *mm = vma->vm_mm;
> > +
> > +	if ((old_addr & ~HPAGE_PMD_MASK) ||
> > +	    (new_addr & ~HPAGE_PMD_MASK) ||
> 
> How could these conditions ever be true? We are here because it was
> pmd_trans_huge. There should be no way this can be aligned. If this
> is paranoia, make it a BUG_ON.

It actually happens. old_addr/new_addr aren't aligned to hpage
beforehand, and they just from the mremap syscall
parameters. Returning 0 is needed here.

> 
> > +	    (old_addr + HPAGE_PMD_SIZE) > old_end ||
> 
> Again, is this possible? The old addr was already huge.

This can happen too, old_end is also passed as parameter from syscall
and it's not mangled to fit an hpage, just calculated as old_addr+len
(len passed as parameter). The length of the destination vma shouldn't
be necessary to check, there's no new_end in the first place as
parameter of move_page_tables so the caller must ensure there's enough
space to copy in the destination. And if the old_end-old_addr <=
HPAGE_PMD_SIZE and the old_addr and new_addr are aligned, we're sure
the hugepmd is safe to create on the destination new_addr (if it's
aligned).

So I think all checks are needed here. In theory the caller could
check this stuff before calling move_huge_pmd but I try to be as less
invasive as possible in the common code that may be built with
TRANSPARENT_HUGEPAGE=n (these checks would still be computed in the
pmd_trans_huge(*old_pmd) case only but it's kind of nicer to hide them
in huge_memory.c).

> > +	/*
> > +	 * The destination pmd shouldn't be established, free_pgtables()
> > +	 * should have release it.
> > +	 */
> > +	if (!pmd_none(*new_pmd)) {
> > +		WARN_ON(1);
> > +		VM_BUG_ON(pmd_trans_huge(*new_pmd));
> > +		goto out;
> > +	}
> > +
> 
> Agreed that this should never happen. The mmap_sem is held for writing
> and we are remapping to what should be empty space. It should not be
> possible for a huge PMD to be established underneath us.

Yes. The code will work fine also if the new_pmd points to a pte that
wasn't freed by free_pgtables but I think it's kind of safer to have a
WARN_ON because if that really ever happens we would prefer to
release the pte here and proceed mapping the hugepmd instead of
splitting the source hugepmd.

If there's a hugepmd mapped instead it means the memory wasn't
munmapped. I could have run a mem compare of the pte against zero page
too but I didn't.. kind of overkill. But checking that there is no
hugepmd is fast.

> > +	spin_lock(&mm->page_table_lock);
> > +	if (likely(pmd_trans_huge(*old_pmd))) {
> > +		if (pmd_trans_splitting(*old_pmd)) {
> > +			spin_unlock(&mm->page_table_lock);
> > +			wait_split_huge_page(vma->anon_vma, old_pmd);
> > +			ret = -1;
> > +		} else {
> > +			pmd = pmdp_get_and_clear(mm, old_addr, old_pmd);
> > +			VM_BUG_ON(!pmd_none(*new_pmd));
> > +			set_pmd_at(mm, new_addr, new_pmd, pmd);
> > +			spin_unlock(&mm->page_table_lock);
> > +			ret = 1;
> > +		}
> > +	} else
> > +		spin_unlock(&mm->page_table_lock);
> > +
> 
> The meaning of the return values of -1, 0, 1 with the caller doing
> 
> if (err)
> ...
> else if (!err)
> 	...
> 
> is tricky to work out. split_huge_page only needs to be called if
> returning 0. Would it be possible to have the split_huge_page called in
> this function? The end of the function would then look like
> 
> return ret;
> 
> out_split:
> split_huge_page_pmd()
> return ret;
> 
> with either success or failure being returned instead of a tristate
> which is easier to understand.

So basically always return 0 regardless if it was a
pmd_trans_splitting or if we splitted it ourself. And only return 1 in
case the move_huge_pmd was successful.

I'm afraid we've other trestates returned for the other mm
methods... if we cleanup this one later we may also cleanup the
others.

I'll try to clean up this one for now ok.

> > diff --git a/mm/mremap.c b/mm/mremap.c
> > --- a/mm/mremap.c
> > +++ b/mm/mremap.c
> > @@ -41,8 +41,7 @@ static pmd_t *get_old_pmd(struct mm_stru
> >  		return NULL;
> >  
> >  	pmd = pmd_offset(pud, addr);
> > -	split_huge_page_pmd(mm, pmd);
> > -	if (pmd_none_or_clear_bad(pmd))
> > +	if (pmd_none(*pmd))
> >  		return NULL;
> >  
> 
> Ok, this is changing to pmd_none because it could be a huge PMD and
> pmd_none_or_clear_bad triggers on a huge PMD. Right?

Right. It'd bug on with a hugepmd. Maybe we could someday change
pmd_none_or_clear_bad not to choke on the PSE bit, but it was kind of
safer to keep assuming the PSE bit was "bad" in case we forgotten some
split_huge_page somewhere, better to bug in that case than to
ignore. But as time passes and THP is rock solid, I've to admit it's
becoming more a lack of reliability to consider the PSE bit "bad" and
to remove some pmd_none_clear_bad than an increase of reliability to
validate the THP case. Maybe we should change that. It's a common
problem not specific to mremap.

> > @@ -65,8 +64,6 @@ static pmd_t *alloc_new_pmd(struct mm_st
> >  		return NULL;
> >  
> >  	VM_BUG_ON(pmd_trans_huge(*pmd));
> > -	if (pmd_none(*pmd) && __pte_alloc(mm, vma, pmd, addr))
> > -		return NULL;
> >  
> >  	return pmd;
> >  }
> > @@ -80,11 +77,7 @@ static void move_ptes(struct vm_area_str
> >  	struct mm_struct *mm = vma->vm_mm;
> >  	pte_t *old_pte, *new_pte, pte;
> >  	spinlock_t *old_ptl, *new_ptl;
> > -	unsigned long old_start;
> >  
> > -	old_start = old_addr;
> > -	mmu_notifier_invalidate_range_start(vma->vm_mm,
> > -					    old_start, old_end);
> 
> The MMU notifier is now being called for a larger range. Previously it
> would usually be ranges of 64 pages and now it looks like it happens
> once for the entire range being remapped. This is not mentioned in
> the leader. What are the consequences of having a large gap between
> invalidate_start and invalidate_end? Would it be a big deal to call
> the MMU notifier within move_huge_pmd()?

Well it should improve performance. The only downside is that it will
stall secondary page faults for a longer time, but because the mremap
can now run faster with fewer IPIs, I think overall it should improve
performance. Also it's probably not too common to do much mremap on
apps with a secondary MMU attached so in this place the mmu notifier
is more about correctness I think and correctness remains. Userland
can always do mremap in smaller chunks if it needs and then it'll
really run faster with no downside. After all no app is supposed to
touch the source addresses while they're being migrated as it could
SEGFAULT at any time. So a very long mremap basically makes a mapping
"not available" for a longer time, just now it'll be shorter because
mremap will run faster. The mapping being available for the secondary
mmu was incidental implementation detail, now it's not available to
the secondary mmu during the move, like it is not available to
userland. Trapping sigsegv to modify the mapping while it's under
mremap I doubt anybody is depending on.

> If it's safe to use larger ranges, it would be preferable to see it
> in a separate patch or at the very least explained in the changelog.

I can split it off to a separate patch. I knew I should have done that
in the first place and rightfully I got caught :).

> >  	if (vma->vm_file) {
> >  		/*
> >  		 * Subtle point from Rajesh Venkatasubramanian: before
> > @@ -111,7 +104,7 @@ static void move_ptes(struct vm_area_str
> >  				   new_pte++, new_addr += PAGE_SIZE) {
> >  		if (pte_none(*old_pte))
> >  			continue;
> > -		pte = ptep_clear_flush(vma, old_addr, old_pte);
> > +		pte = ptep_get_and_clear(mm, old_addr, old_pte);
> 
> This looks like an unrelated optimisation. You hint at this in the
> patch subject but it needs a separate patch or a better explanation in
> the leader. If I'm reading this right, it looks like you are deferring
> a TLB flush on a single page and calling one call later at the end of
> move_page_tables. At a glance, that seems ok and would reduce IPIs
> but I'm not thinking about it properly because I'm trying to think
> about THP shenanigans :)

That's exactly what it does. Once I split it off you can concentrate
on the two parts separately. This is also the parts that requires
moving the mmu notifier outside along with the tlb flush outside.

The THP shenanigans don't require moving the mmu notifier outside.

The one IPI per page is a major bottleneck for java, lack of hugepmd
migrate also major bottleneck, here we get both combined so we get 1
IPI for a ton of THP. The benchmark I run was single threaded on a 12
core system (and single threaded if scheduler is doing good won't
require any IPI), you can only imagine the boost it gets on heavily
multithreaded apps that requires flooding IPI on large SMP (I didn't
measure that as I was already happy with what I got single threaded :).

> > +	mmu_notifier_invalidate_range_start(vma->vm_mm, old_addr, old_end);
> > +
> >  	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
> >  		cond_resched();
> >  		next = (old_addr + PMD_SIZE) & PMD_MASK;
> > -		if (next - 1 > old_end)
> > +		if (next > old_end)
> >  			next = old_end;
> >  		extent = next - old_addr;
> >  		old_pmd = get_old_pmd(vma->vm_mm, old_addr);
> 
> You asked if removing this "- 1" is correct. It's an overflow check for
> a situation where old_addr + PMD_SIZE overflows. On what architecture
> is it possible to call mremap() at the very top of the address space
> or am I missing the point?
> 
> Otherwise I think the existing check is harmless if obscure. It's
> reasonable to assume PAGE_SIZE will be > 1 and I'm not seeing why it is
> required by the rest of the patch.

An arch where the -TASK_SIZE is less than PMD_SIZE didn't cross my
mind sorry, Johannes also pointed it out. I'd find this more readable
than a off by one -1 that looks erroneous.

diff --git a/mm/mremap.c b/mm/mremap.c
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -136,9 +136,10 @@ unsigned long move_page_tables(struct vm
 	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
 		cond_resched();
 		next = (old_addr + PMD_SIZE) & PMD_MASK;
-		if (next > old_end)
-			next = old_end;
+		/* even if next overflowed, extent below will be ok */
 		extent = next - old_addr;
+		if (extent > old_end - old_addr)
+			extent = old_end - old_addr;
 		old_pmd = get_old_pmd(vma->vm_mm, old_addr);
 		if (!old_pmd)
 			continue;

What do you think? I can put the -1 back if you prefer. I doubt the
speed difference can matter here, all values should be in registers.

> > @@ -150,6 +145,23 @@ unsigned long move_page_tables(struct vm
> >  		new_pmd = alloc_new_pmd(vma->vm_mm, vma, new_addr);
> >  		if (!new_pmd)
> >  			break;
> > +		if (pmd_trans_huge(*old_pmd)) {
> > +			int err = 0;
> > +			if (extent == HPAGE_PMD_SIZE)
> > +				err = move_huge_pmd(vma, new_vma, old_addr,
> > +						    new_addr, old_end,
> > +						    old_pmd, new_pmd);
> > +			if (err > 0) {
> > +				need_flush = true;
> > +				continue;
> > +			} else if (!err)
> > +				split_huge_page_pmd(vma->vm_mm, old_pmd);
> > +			VM_BUG_ON(pmd_trans_huge(*old_pmd));
> 
> This tristate is hard to parse but I mentioned this already.

Yep I'll try to make it 0/1.

> Functionally, I can't see a major problem with the patch. The
> minor problems are that I'd like to see that tristate replaced for
> readability, the optimisation better explained or in a separate patch
> and an explanation why the larger ranges for mmu_notifiers is not
> a problem.

Thanks for the review, very helpful as usual, I'll try to submit a 3
patches version with the cleanups you suggested soon enough. Ideally
I'd like to replace the -1 with the above change that also should
guard against TASK_SIZE ending less than one pmd away from the end of
the address space if you like it.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
