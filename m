Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5F9D76B0216
	for <linux-mm@kvack.org>; Fri, 14 May 2010 05:55:12 -0400 (EDT)
Date: Fri, 14 May 2010 10:54:50 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/7] hugetlb, rmap: add reverse mapping for hugepage
Message-ID: <20100514095449.GB21481@csn.ul.ie>
References: <1273737326-21211-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1273737326-21211-2-git-send-email-n-horiguchi@ah.jp.nec.com> <20100513152737.GE27949@csn.ul.ie> <20100514074641.GD10000@spritzerA.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100514074641.GD10000@spritzerA.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, May 14, 2010 at 04:46:41PM +0900, Naoya Horiguchi wrote:
> On Thu, May 13, 2010 at 04:27:37PM +0100, Mel Gorman wrote:
> > On Thu, May 13, 2010 at 04:55:20PM +0900, Naoya Horiguchi wrote:
> > > While hugepage is not currently swappable, rmapping can be useful
> > > for memory error handler.
> > > Using rmap, memory error handler can collect processes affected
> > > by hugepage errors and unmap them to contain error's effect.
> > > 
> > 
> > As a verification point, can you ensure that the libhugetlbfs "make
> > func" tests complete successfully with this patch applied? It's also
> > important that there is no oddness in the Hugepage-related counters in
> > /proc/meminfo. I'm not in the position to test it now unfortunately as
> > I'm on the road.
> 
> Yes. Thanks for the good test-set.
> 
> Hmm. I failed libhugetlbfs test with a oops in "private mapped" test :(
> 

That's not a disaster - it's what the regression test is for. I haven't
restarted the review in this case. I'll wait for another version that
passes those regression tests.

> <OOPS SNIP>
> 
> Someone seems to call hugetlb_fault() with anon_vma == NULL.
> For more detail, I'm investigating it.
> 

Sure.

> > > Current status of hugepage rmap differs depending on mapping mode:
> > > - for shared hugepage:
> > >   we can collect processes using a hugepage through pagecache,
> > >   but can not unmap the hugepage because of the lack of mapcount.
> > > - for privately mapped hugepage:
> > >   we can neither collect processes nor unmap the hugepage.
> > > 
> > > To realize hugepage rmapping, this patch introduces mapcount for
> > > shared/private-mapped hugepage and anon_vma for private-mapped hugepage.
> > > 
> > > This patch can be the replacement of the following bug fix.
> > > 
> > 
> > Actually, you replace chunks but not all of that fix with this patch.
> > After this patch HUGETLB_POISON is never assigned but the definition still
> > exists in poison.h. You should also remove it if it is unnecessary.
> 
> OK. I'll remove HUGETLB_POISON in the next post.
> 

Thanks

> <SNIP>
> > For ordinary anon_vma's, there
> > is a chain of related vma's chained together via the anon_vma's. It's so
> > in the event of an unmapping, all the PTEs related to the page can be
> > found. Where are we doing the same here?
> 
> Finding all processes using a hugepage is done by try_to_unmap() as usual.
> Among callers of this function, only memory error handler calls it for
> hugepage for now.

Ok, my bad, it's anon_vma_prepare that does most of the linkages.
However, there still appears to be logic missing between how anon rmap
pages are setup and hugetlb anon rmap pages. See __page_set_anon_rmap
for example and what it does with chains and compare it to
hugetlb_add_anon_rmap. There are some important differences.


> What this patch does is to enable try_to_unmap() to be called for hugepages
> by setting up anon_vma in hugetlb code.
> 
> > I think what you're getting with this is the ability to unmap MAP_PRIVATE pages
> > from one process but if there are multiple processes, the second process could
> > still end up referencing the poisoned MAP_PRIVATE page. Is this accurate? Even
> > if it is, I guess it's still an improvement over what currently happens.
> 
> Try_to_unmap_anon() runs for each vma belonging to the anon_vma associated
> with the error hugepage. So it works for multiple processes.
> 

Yep, as long as anon_vma_prepare is called in all the correct cases. I
haven't double checked you have and will wait until you pin down why
anon_vma is NULL in the next version.

> > > +
> > >  static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
> > >  			unsigned long address, pte_t *ptep, pte_t pte,
> > >  			struct page *pagecache_page)
> > > @@ -2348,6 +2371,12 @@ retry_avoidcopy:
> > >  		huge_ptep_clear_flush(vma, address, ptep);
> > >  		set_huge_pte_at(mm, address, ptep,
> > >  				make_huge_pte(vma, new_page, 1));
> > > +		page_remove_rmap(old_page);
> > > +		/*
> > > +		 * We need not call anon_vma_prepare() because anon_vma
> > > +		 * is already prepared when the process fork()ed.
> > > +		 */
> > > +		hugepage_add_anon_rmap(new_page, vma, address);
> > 
> > This means that the anon_vma is shared between parent and child even
> > after fork. Does this not mean that the behaviour of anon_vma differs
> > between the core VM and hugetlb?
> 
> No. IIUC, anon_vma associated with (non-huge) anonymous page is also shared
> between parent and child until COW.
> 

In the base page case, it does but where is a new anon_vma being
allocated here and the rmap moved with page_move_anon_rmap?

> > >  		/* Make the old page be freed below */
> > >  		new_page = old_page;
> > >  	}
> > > @@ -2450,7 +2479,11 @@ retry:
> > >  			spin_unlock(&inode->i_lock);
> > >  		} else {
> > >  			lock_page(page);
> > > -			page->mapping = HUGETLB_POISON;
> > > +			if (unlikely(anon_vma_prepare(vma))) {
> > > +				ret = VM_FAULT_OOM;
> > > +				goto backout_unlocked;
> > > +			}
> > > +			hugepage_add_anon_rmap(page, vma, address);
> > 
> > Seems ok for private pages at least.
> > 
> > >  		}
> > >  	}
> > >  
> > > @@ -2479,6 +2512,13 @@ retry:
> > >  				&& (vma->vm_flags & VM_SHARED)));
> > >  	set_huge_pte_at(mm, address, ptep, new_pte);
> > >  
> > > +	/*
> > > +	 * For privately mapped hugepage, _mapcount is incremented
> > > +	 * in hugetlb_cow(), so only increment for shared hugepage here.
> > > +	 */
> > > +	if (vma->vm_flags & VM_MAYSHARE)
> > > +		page_dup_rmap(page);
> > > +
> > 
> > What happens when try_to_unmap_file is called on a hugetlb page?
> 
> Try_to_unmap_file() is called for shared hugepages, so it tracks all vmas
> sharing one hugepage through pagecache pointed to by page->mapping,
> and sets all ptes into hwpoison swap entries instead of flushing them.
> Curiously file backed pte is changed to swap entry, but it's OK because
> hwpoison hugepage should not be touched afterward.
> 

Grand.

> > >  	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
> > >  		/* Optimization, do the COW without a second fault */
> > >  		ret = hugetlb_cow(mm, vma, address, ptep, new_pte, page);
> > > diff --git v2.6.34-rc7/mm/rmap.c v2.6.34-rc7/mm/rmap.c
> > > index 0feeef8..58cd2f9 100644
> > > --- v2.6.34-rc7/mm/rmap.c
> > > +++ v2.6.34-rc7/mm/rmap.c
> > > @@ -56,6 +56,7 @@
> > >  #include <linux/memcontrol.h>
> > >  #include <linux/mmu_notifier.h>
> > >  #include <linux/migrate.h>
> > > +#include <linux/hugetlb.h>
> > >  
> > >  #include <asm/tlbflush.h>
> > >  
> > > @@ -326,6 +327,8 @@ vma_address(struct page *page, struct vm_area_struct *vma)
> > >  	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> > >  	unsigned long address;
> > >  
> > > +	if (unlikely(is_vm_hugetlb_page(vma)))
> > > +		pgoff = page->index << compound_order(page);
> > 
> > Again, it would be nice to use hstate information if possible just so
> > how the pagesize is discovered is consistent.
> 
> OK.
> 
> > >  	address = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
> > >  	if (unlikely(address < vma->vm_start || address >= vma->vm_end)) {
> > >  		/* page should be within @vma mapping range */
> > > @@ -369,6 +372,12 @@ pte_t *page_check_address(struct page *page, struct mm_struct *mm,
> > >  	pte_t *pte;
> > >  	spinlock_t *ptl;
> > >  
> > > +	if (unlikely(PageHuge(page))) {
> > > +		pte = huge_pte_offset(mm, address);
> > > +		ptl = &mm->page_table_lock;
> > > +		goto check;
> > > +	}
> > > +
> > >  	pgd = pgd_offset(mm, address);
> > >  	if (!pgd_present(*pgd))
> > >  		return NULL;
> > > @@ -389,6 +398,7 @@ pte_t *page_check_address(struct page *page, struct mm_struct *mm,
> > >  	}
> > >  
> > >  	ptl = pte_lockptr(mm, pmd);
> > > +check:
> > >  	spin_lock(ptl);
> > >  	if (pte_present(*pte) && page_to_pfn(page) == pte_pfn(*pte)) {
> > >  		*ptlp = ptl;
> > > @@ -873,6 +883,12 @@ void page_remove_rmap(struct page *page)
> > >  		page_clear_dirty(page);
> > >  		set_page_dirty(page);
> > >  	}
> > > +	/*
> > > +	 * Mapping for Hugepages are not counted in NR_ANON_PAGES nor
> > > +	 * NR_FILE_MAPPED and no charged by memcg for now.
> > > +	 */
> > > +	if (unlikely(PageHuge(page)))
> > > +		return;
> > >  	if (PageAnon(page)) {
> > >  		mem_cgroup_uncharge_page(page);
> > >  		__dec_zone_page_state(page, NR_ANON_PAGES);
> > 
> > I don't see anything obviously wrong with this but it's a bit rushed and
> > there are a few snarls that I pointed out above. I'd like to hear it passed
> > the libhugetlbfs regression tests for different sizes without any oddness
> > in the counters.
> 
> Since there exists regression as described above, I'll fix it first of all.
> 

Sure. As it is, the hugetlb parts of this patch to my eye are not ready yet
with some snags that need ironing out. That said, I see nothing fundamentally
wrong with the approach as such.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
