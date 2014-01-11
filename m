Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id BC85B6B0031
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 20:49:30 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id up15so5121460pbc.24
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 17:49:29 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id ot3si8811689pac.311.2014.01.10.17.49.27
        for <linux-mm@kvack.org>;
        Fri, 10 Jan 2014 17:49:28 -0800 (PST)
Date: Fri, 10 Jan 2014 20:49:24 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] Memory management -- THP, hugetlb,
 scalability
Message-ID: <20140111014924.GB5722@linux.intel.com>
References: <20140103122509.GA18786@node.dhcp.inet.fi>
 <20140108151321.GI27046@suse.de>
 <20140110174204.GA5228@node.dhcp.inet.fi>
 <20140110225116.GA5722@linux.intel.com>
 <20140110225934.GA8951@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140110225934.GA8951@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Mel Gorman <mgorman@suse.de>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Sat, Jan 11, 2014 at 12:59:34AM +0200, Kirill A. Shutemov wrote:
> On Fri, Jan 10, 2014 at 05:51:16PM -0500, Matthew Wilcox wrote:
> > On Fri, Jan 10, 2014 at 07:42:04PM +0200, Kirill A. Shutemov wrote:
> > > On Wed, Jan 08, 2014 at 03:13:21PM +0000, Mel Gorman wrote:
> > > > I think transparent huge pagecache is likely to crop up for more than one
> > > > reason. There is the TLB issue and the motivation that i-TLB pressure is
> > > > a problem in some specialised cases. Whatever the merits of that case,
> > > > transparent hugepage cache has been raised as a potential solution for
> > > > some VM scalability problems. I recognise that dealing with large numbers
> > > > of struct pages is now a problem on larger machines (although I have not
> > > > seen quantified data on the problem nor do I have access to a machine large
> > > > enough to measure it myself) but I'm wary of transparent hugepage cache
> > > > being treated as a primary solution for VM scalability problems. Lacking
> > > > performance data I have no suggestions on what these alternative solutions
> > > > might look like.
> > 
> > Something I'd like to see discussed (but don't have the MM chops to
> > lead a discussion on myself) is the PAGE_CACHE_SIZE vs PAGE_SIZE split.
> > This needs to be either fixed or removed, IMO.  It's been in the tree
> > since before git history began (ie before 2005), it imposes a reasonably
> > large cognitive burden on programmers ("what kind of page size do I want
> > here?"), it's not intuitively obvious (to a non-mm person) which page
> > size is which, and it's never actually bought us anything because it's
> > always been the same!
> 
> I also want to drop PAGE_CACHE_*. It's on my todo list almost a year now ;)

I dno't necessarily want to drop the concept of having 'the size of
memory referenced by struct page' != 'the size of memory pointed at
by a single PTE'.  I just want to see it *implemented* for at least one
architecture if we're going to have the distinction.  It's one way of
solving the problem that Mel mentioned (dealing with a large number of
struct pages).

> > > Sibling topic is THP for XIP (see Matthew's patchset). Guys want to manage
> > > persistent memory in 2M chunks where it's possible. And THP (but without
> > > struct page in this case) is the obvious solution.
> > 
> > Not just 2MB, we also want 1GB pages for some special cases.  It looks
> > doable (XFS can allocate aligned 1GB blocks).  I've written some
> > supporting code that will at least get us to the point where we can
> > insert a 1GB page.  I haven't been able to test anything yet.
> 
> It's probably doable from fs point of view, but adding PUD-level THP page
> is not trivial at all. I think it's more productive better to concentrate
> on 2M for now.

It's clearly Hard to get to a point where we're inserting PUD entries
for anonymous pages.  While I don't think it's trivial to get to PUD entries
for PFNMAP, I think it is doable.

Last time we discussed this, your concern was around splitting a PUD entry
down into PTEs and having to preallocate all the memory required to do that.

We can't possibly need to call split_huge_page() for the PFNMAP case
because we don't have a struct page, so none of those code paths can
be run.  I think that leaves split_huge_page_pmd() as the only place
where we can try to split a huge PFNMAP PMD.  That's called from:

mem_cgroup_count_precharge_pte_range()
mem_cgroup_move_charge_pte_range()
	These two look like they need to be converted to work on unsplit
	PMDs anyway, for efficiency reasons.  Perhaps someone who's hacked
	on this file as recently as 2009 would care to do that work?  :-)

zap_pmd_range() does this:

               if (pmd_trans_huge(*pmd)) {
                        if (next-addr != HPAGE_PMD_SIZE) {
                                VM_BUG_ON(!rwsem_is_locked(&tlb->mm->mmap_sem));
                                split_huge_page_pmd(vma->vm_mm, pmd);
                        } else if (zap_huge_pmd(tlb, vma, pmd))
                                continue;
                        /* fall through */
                }

I don't understand why it bothers to split rather than just zapping the
PMD and allowing refaults to populate the PTEs later.

follow_page() calls it, but I think we can give up way earlier in this
function, since we know there's no struct page to return.  We can put
in something like:

	if (IS_XIP(file_inode(vma->vm_file)))
		return ERR_PTR(-Ewhatever);

check_pmd_range() calls it, but this is NUMA policy for the page cache.
We should be skipping this code for XIP files too, if we aren't already.

change_pmd_range() calls split_huge_page_pmd() if an mprotect call lands
in the middle of a PMD range.  Again, I'd be *fine* with just dropping the
PMD entry here and allowing faults to repopulate the PTEs.

Looks like the mremap code may need some work.  I'm not sure what that
work is right now.

That leaves us with walk_page_range() ... which also looks like it's
going to need some work in the callers.

So yeah, not trivial at all, but doable with a few weeks of work,
I think.  Unless there's some other major concern that I've missed
(which is possible since I'm not a MM hacker).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
