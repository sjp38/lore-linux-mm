Date: Tue, 26 Sep 2006 21:03:00 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] shared page table for hugetlb page - v2
In-Reply-To: <000001c6dd18$efc27510$ea34030a@amr.corp.intel.com>
Message-ID: <Pine.LNX.4.64.0609262018270.3857@blonde.wat.veritas.com>
References: <000001c6dd18$efc27510$ea34030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Andrew Morton' <akpm@osdl.org>, 'Dave McCracken' <dmccr@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Sep 2006, Chen, Kenneth W wrote:
> Following up with the work on shared page table, here is a re-post of
> shared page table for hugetlb memory.  Dave's latest patch restricts
> the page table sharing at pmd level in order to simplify some of the
> complexity for normal page, but that simplification cuts out all the
> performance benefit for hugetlb on x86-64 and ia32.
> 
> The following patch attempt to kick that optimization back in for hugetlb
> memory and allow pt sharing at second level.  It is nicely self-contained
> within hugetlb subsystem.  With no impact to generic VM at all, I think
> this patch is ready for mainline consideration.

I was impressed by how small and unintrusive this patch is, and how
nicely it adheres to CodingStyle throughout.  But I've spotted one
easily fixed bug, and quite a lot of raciness (depressingly, often
issues already pointed out and hopefully by now fixed in Dave's;
but one of the racinesses is already there before your patch).

Unfit for mainline until those are dealt with: though I don't think
the fixes are going to expand and complicate it terribly, so it
should remain palatable.  My main fear is that the longer I look,
the more raciness I may find: it just seems hard to get shared page
table locking right; I am hoping that once it is right, it won't be
so correspondingly fragile.

> 
> Imprecise RSS accounting is an irritating ill effect with pt sharing.
> After consulted with several VM experts, I have tried various methods to
> solve that problem: (1) iterate through all mm_structs that share the PT
> and increment count; (2) keep RSS count in page table structure and then
> sum them up at reporting time. None of the above methods yield any
> satisfactory implementation.
> 
> Since process RSS accounting is pure information only, I propose we don't
> count them at all for hugetlb page. rlimit has such field, though there is
> absolutely no enforcement on limiting that resource. One other method is
> to account all RSS at hugetlb mmap time regardless they are faulted or not.
> I opt for the simplicity of no accounting at all.

I agree with your decision here for the hugetlb case (but we won't be
able to let Dave take the same easy way out).  Imagine if we enforced
RSS limiting, and tried to swap pages out to make a process meet its
limit: wouldn't work on the hugepages anyway.  Yes, just forget RSS.

But two things on that: next time you send the patch, better to have
a 1/2 which does all that simple RSS removal from the hugetlb code;
and please also remove the call to update_hiwater_rss() - it's doing
no harm, but it's just a waste once that RSS adjustment is gone.

> 
> Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
> 
> 
>  arch/i386/mm/hugetlbpage.c |   79 ++++++++++++++++++++++++++++++++++++++++++++-
>  mm/hugetlb.c               |   14 ++++++-
>  2 files changed, 89 insertions(+), 4 deletions(-)
> 
> --- ./mm/hugetlb.c.orig	2006-09-19 20:42:06.000000000 -0700
> +++ ./mm/hugetlb.c	2006-09-20 15:36:28.000000000 -0700
...
> +__attribute__((weak))
> +int huge_pte_put(struct vm_area_struct *vma, unsigned long *addr, pte_t *ptep)
> +{
> +	return 0;
> +}
> +

Hmm, __attribute__((weak)) seems to coming into fashion, I'd better get
used to it.  But I think you did it that way, and your call to find_vma
in huge_pte_alloc, just to avoid mods to other arches for now: good way
to get it up and running, but for merging it would be better to update
all the hugetlb arches with the trivial mods required, than have this
weak default huge_pte_put here.

> --- ./arch/i386/mm/hugetlbpage.c.orig	2006-09-19 20:42:06.000000000 -0700
> +++ ./arch/i386/mm/hugetlbpage.c	2006-09-20 09:38:54.000000000 -0700
> @@ -17,16 +17,93 @@
>  #include <asm/tlb.h>
>  #include <asm/tlbflush.h>
>  
> +int page_table_shareable(struct vm_area_struct *svma,
> +			 struct vm_area_struct *vma,
> +			 unsigned long addr, unsigned long size)
> +{
> +	unsigned long base = addr & ~(size - 1);
> +	unsigned long end = base + size;
> +
> +	if (base < vma->vm_start || vma->vm_end < end)
> +		return 0;
> +
> +	if (svma->vm_flags != vma->vm_flags ||
> +	    svma->vm_start != vma->vm_start ||
> +	    svma->vm_end   != vma->vm_end)
> +		return 0;
> +
> +	return 1;
> +}

Now this isn't an arch-specific function at all, is it?  The size
passed in will be arch specific, but not the function itself.  I
think you put it here to avoid "bloating" mm/hugetlb.c for those
who don't need it; but hugetlb users are already amongst the bloaty,
and other arches would implement soon, so I think it ought to move
there (or if you disagree, then please at least make it static here).
Later, if Dave's work goes in, then perhaps it'll move again and be
shared with his.

The bug that needs fixing is that it's making no check on vm_pgoff:
your vma_prio_tree search gives you all svmas which overlap the
first page of this vma (not quite what you want, really), but
they can easily match the conditions above without matching up
at all in vm_pgoff.

Rather than just fix that, I'd prefer you or Dave to actually get
the page_table_shareable conditions right at last: it doesn't need
the vmas to match exactly, it just needs the right permissions and
the right alignment for the page table in question.  It's just better
doc of what's going on if it checks for what it's really needing.

> +
> +/*
> + * search for a shareable pmd page for hugetlb.
> + */
> +void pmd_share(struct vm_area_struct *vma, pud_t *pud, unsigned long addr)

static

> +{
> +	struct address_space *mapping = vma->vm_file->f_mapping;
> +	struct prio_tree_iter iter;
> +	struct vm_area_struct *svma;
> +	pte_t *spte = NULL;
> +
> +	if (!vma->vm_flags & VM_SHARED)
> +		return;

Better to check VM_MAYSHARE instead there: the difference is that a
PROT_READ,MAP_SHARED mapping which cannot be converted to PROT_WRITE
(file was opened readonly) comes out as VM_MAYSHARE but !VM_SHARED.

> +
> +	spin_lock(&mapping->i_mmap_lock);
> +	vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap,
> +			      vma->vm_pgoff, vma->vm_pgoff) {
> +		if (svma == vma ||
> +		    !page_table_shareable(svma, vma, addr, PUD_SIZE))
> +			continue;

No.  Holding i_mmap_lock is indeed good enough to protect against racing
changes to vm_start, vm_end, vm_pgoff (since vma_adjust has to be careful
not to undermine the prio_tree without it), but it's not enough to protect
against racing changes to vm_flags (e.g. by mprotect), and that's a part
of what page_table_shareable has to check (though you might in the end
want to separate it out, if it's going to be more efficient to check the
safe ones first before getting adequate locking for vm_flags).  We went
around this with Dave before, he now does down_read_trylock on mmap_sem
to secure vm_flags.

> +
> +		spin_lock(&svma->vm_mm->page_table_lock);
> +		spte = huge_pte_offset(svma->vm_mm, addr);
> +		if (spte)
> +			get_page(virt_to_page(spte));
> +		spin_unlock(&svma->vm_mm->page_table_lock);
> +		if (spte)
> +			break;
> +	}
> +	spin_unlock(&mapping->i_mmap_lock);
> +
> +	if (!spte)
> +		return;
> +
> +	spin_lock(&vma->vm_mm->page_table_lock);
> +	if (pud_none(*pud))
> +		pud_populate(mm, pud, (unsigned long) spte & PAGE_MASK);
> +	else
> +		put_page(virt_to_page(spte));
> +	spin_unlock(&vma->vm_mm->page_table_lock);
> +}

No, that's another race Dave had to fix months ago.  That put_page,
all you've got there is your own mm->page_table_lock: it's unlikely
but possible that you're now the sole user of that page table page
(the one you shared it from having exited meanwhile, and a racer
on your mm having done the same but picked up a different to share).
Dave now uses the lock in the page table page, you'll probably want
to and be able to keep it simpler, maybe it'll help to hold i_mmap_lock
until the end, maybe that's irrelevant and you'll just need to
huge_pte_put in case, I can't be at all sure without seeing the
totality and there's more wrong below.

> +
> +int huge_pte_put(struct vm_area_struct *vma, unsigned long *addr, pte_t *ptep)
> +{
> +	pgd_t *pgd = pgd_offset(vma->vm_mm, *addr);
> +	pud_t *pud = pud_offset(pgd, *addr);
> +
> +	if (page_count(virt_to_page(ptep)) <= 1)
> +		return 0;
> +
> +	pud_clear(pud);
> +	put_page(virt_to_page(ptep));
> +	*addr = ALIGN(*addr, HPAGE_SIZE * PTRS_PER_PTE) - HPAGE_SIZE;
> +	return 1;
> +}

Doesn't "if (page_count <= 1) return 0; blah; put_page;" scream race
to you?  If i_mmap_lock were held wherever this is called, you'd
be alright; but it isn't, and it'd be messy to arrange - because
unmap_hugepage_range is called with i_mmap_lock held when truncating,
but without it when just munmapping.

You may end up deciding that the easiest thing is to use i_mmap_lock
more widely, and somehow arrange things that way - though I don't
think we want to require it in the common path of mprotect.

More typical would be to manipulate the atomic count properly: you
could use the page table page's mapcount and do the extra work when
you atomic_add_negative(-1, &page->_mapcount) (as in mm/rmap.c), or
you could carry on using page_count, and do the extra work when
atomic_sub_return(&page->_count, 1) == 1.  Both of those involve
bumping the respective count on every hugetlb page table at that
level when it's first allocated: I don't think you can delay until
it becomes "shared"; and I don't think there's a way to do it when
page_count falls to 0, that rushes off to the freeing the page
before you're ready to do so.

> +
>  pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr)
>  {
> +	struct vm_area_struct *vma = find_vma(mm, addr);

Fine for getting this working with a minimal patch, but better to
bite the bullet and change huge_pte_alloc args to pass in vma on
all arches (either with or without mm: sometimes we use vma->vm_mm,
sometimes we pass in mm separately, there's no consistency):
the callers know the vma, better to avoid the find_vma call.

Well, no, actually copy_hugetlb_page_range knows the parent vma,
but not this child vma.  But that brings me to another point,
though it was just an optimization: silly for the huge_pte_alloc
from copy_hugetlb_page_range to be doing that pmd_share search
for a suitable page table to share, when (if VM_MAYSHARE) the
parent page table is obviously good to be shared.

>  	pgd_t *pgd;
>  	pud_t *pud;
>  	pte_t *pte = NULL;
>  
>  	pgd = pgd_offset(mm, addr);
>  	pud = pud_alloc(mm, pgd, addr);
> -	if (pud)
> +	if (pud) {
> +		if (pud_none(*pud))
> +			pmd_share(vma, pud, addr);
>  		pte = (pte_t *) pmd_alloc(mm, pud, addr);
> +	}
>  	BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));
>  
>  	return pte;

I thought for some while that there was even more raciness, but
hugetlb_fault's surprisingly global hugetlb_instantiation_mutex
protects from a lot.  Maybe some of my beliefs above are
erroneous too, please don't take my word for it.

Finally, that raciness already there before your patch.  You have
a problem which again we went over with Dave (in the non-huge case),
that as soon as unmap_hugepage_range or hugetlb_change_protection
has done its huge_pte_put on a shared page table, it's lost control
of the table, which might get independently freed and reused before
this thread does its flush_tlb_range - leaving other threads free to
abuse or suffer from the inappropriate page table.  But even without
your patch, unmap_hugepage_range is freeing hugepages (back to the
pool) before doing any TLB flush.  There needs to be more TLB care
there, and it's not your fault it's missing: either sophisticated
mmu_gather-style ordering, or earlier flush_tlb_range of each subrange.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
