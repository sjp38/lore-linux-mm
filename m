Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f171.google.com (mail-ea0-f171.google.com [209.85.215.171])
	by kanga.kvack.org (Postfix) with ESMTP id 884B26B0031
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 21:56:04 -0500 (EST)
Received: by mail-ea0-f171.google.com with SMTP id h10so2339405eak.16
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 18:56:03 -0800 (PST)
Received: from jenni2.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id c5si3232588eeb.133.2014.01.10.18.56.03
        for <linux-mm@kvack.org>;
        Fri, 10 Jan 2014 18:56:03 -0800 (PST)
Date: Sat, 11 Jan 2014 04:55:58 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] Memory management -- THP, hugetlb,
 scalability
Message-ID: <20140111025558.GA10312@node.dhcp.inet.fi>
References: <20140103122509.GA18786@node.dhcp.inet.fi>
 <20140108151321.GI27046@suse.de>
 <20140110174204.GA5228@node.dhcp.inet.fi>
 <20140110225116.GA5722@linux.intel.com>
 <20140110225934.GA8951@node.dhcp.inet.fi>
 <20140111014924.GB5722@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140111014924.GB5722@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jan 10, 2014 at 08:49:24PM -0500, Matthew Wilcox wrote:
> > I also want to drop PAGE_CACHE_*. It's on my todo list almost a year now ;)
> 
> I dno't necessarily want to drop the concept of having 'the size of
> memory referenced by struct page' != 'the size of memory pointed at
> by a single PTE'.  I just want to see it *implemented* for at least one
> architecture if we're going to have the distinction.  It's one way of
> solving the problem that Mel mentioned (dealing with a large number of
> struct pages).

Okay. But I don't think it's going to happen.

> > > > Sibling topic is THP for XIP (see Matthew's patchset). Guys want to manage
> > > > persistent memory in 2M chunks where it's possible. And THP (but without
> > > > struct page in this case) is the obvious solution.
> > > 
> > > Not just 2MB, we also want 1GB pages for some special cases.  It looks
> > > doable (XFS can allocate aligned 1GB blocks).  I've written some
> > > supporting code that will at least get us to the point where we can
> > > insert a 1GB page.  I haven't been able to test anything yet.
> > 
> > It's probably doable from fs point of view, but adding PUD-level THP page
> > is not trivial at all. I think it's more productive better to concentrate
> > on 2M for now.
> 
> It's clearly Hard to get to a point where we're inserting PUD entries
> for anonymous pages.  While I don't think it's trivial to get to PUD entries
> for PFNMAP, I think it is doable.
> 
> Last time we discussed this, your concern was around splitting a PUD entry
> down into PTEs and having to preallocate all the memory required to do that.

Other thing is dealing with PMD vs PTE races (due splitting or
MADV_DONTNEED or something else). Adding PUD to the picture doesn't make
it easier.

> We can't possibly need to call split_huge_page() for the PFNMAP case
> because we don't have a struct page, so none of those code paths can
> be run.  I think that leaves split_huge_page_pmd() as the only place
> where we can try to split a huge PFNMAP PMD.
>
> That's called from:
> 
> mem_cgroup_count_precharge_pte_range()
> mem_cgroup_move_charge_pte_range()
> 	These two look like they need to be converted to work on unsplit
> 	PMDs anyway, for efficiency reasons.  Perhaps someone who's hacked
> 	on this file as recently as 2009 would care to do that work?  :-)

:) May be. I don't really remember anything there.

> zap_pmd_range() does this:
> 
>                if (pmd_trans_huge(*pmd)) {
>                         if (next-addr != HPAGE_PMD_SIZE) {
>                                 VM_BUG_ON(!rwsem_is_locked(&tlb->mm->mmap_sem));
>                                 split_huge_page_pmd(vma->vm_mm, pmd);
>                         } else if (zap_huge_pmd(tlb, vma, pmd))
>                                 continue;
>                         /* fall through */
>                 }
> 
> I don't understand why it bothers to split rather than just zapping the
> PMD and allowing refaults to populate the PTEs later.

Because with anon-pages you don't have a backing storage to repopulate
from: it will free the memory and you will end up with clear pages after
next page fault.

Yeah, it's not relevant for file pages, you can just unmap the pmd.

> follow_page() calls it, but I think we can give up way earlier in this
> function, since we know there's no struct page to return.  We can put
> in something like:
> 
> 	if (IS_XIP(file_inode(vma->vm_file)))
> 		return ERR_PTR(-Ewhatever);

Are you sure you will not need a temporary struct page here to show to
caller or something like this?

> check_pmd_range() calls it, but this is NUMA policy for the page cache.
> We should be skipping this code for XIP files too, if we aren't already.

Okay.

> change_pmd_range() calls split_huge_page_pmd() if an mprotect call lands
> in the middle of a PMD range.  Again, I'd be *fine* with just dropping the
> PMD entry here and allowing faults to repopulate the PTEs.

Do you have a way to store info that the area should be repopulated with
PTEs, not PMD?

> Looks like the mremap code may need some work.  I'm not sure what that
> work is right now.

You probably may unmap there too and handle as !old_pmd.

> That leaves us with walk_page_range() ... which also looks like it's
> going to need some work in the callers.
> 
> So yeah, not trivial at all, but doable with a few weeks of work,
> I think.  Unless there's some other major concern that I've missed
> (which is possible since I'm not a MM hacker).

Okay, doable. I guess.

The general approach is replace split with unmap. unmap_mapping_range() takes
->i_mmap_mutex and we probably will hit locking ordering issues.

But I would suggest to take more conservative approach first: leave 1G
pages aside, use 2M pages with page table pre-allocation and implement
proper splitting in split_huge_page_pmd() for this case. It should be
much easier then fix all split_huge_page_pmd() callers.

After getting this work we can look how to eliminate memory overhead on
preallocated page tables and bring 1G pages.

By the time you probably will have some performance data to say that you
don't really need 1G pages that much. ;)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
