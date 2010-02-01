Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2F9A96B004D
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 17:57:14 -0500 (EST)
Date: Mon, 1 Feb 2010 23:56:24 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 32 of 32] khugepaged
Message-ID: <20100201225624.GB4135@random.random>
References: <patchbomb.1264969631@v2.random>
 <51b543fab38b1290f176.1264969663@v2.random>
 <alpine.DEB.2.00.1002011551560.2384@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002011551560.2384@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 01, 2010 at 04:18:19PM -0600, Christoph Lameter wrote:
> On Sun, 31 Jan 2010, Andrea Arcangeli wrote:
> 
> > +static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
> > +					unsigned long address,
> > +					pte_t *pte)
> > +{
> > +	struct page *page;
> > +	pte_t *_pte;
> > +	int referenced = 0, isolated = 0;
> > +	for (_pte = pte; _pte < pte+HPAGE_PMD_NR;
> > +	     _pte++, address += PAGE_SIZE) {
> > +		pte_t pteval = *_pte;
> > +		if (!pte_present(pteval) || !pte_write(pteval)) {
> > +			release_pte_pages(pte, _pte);
> > +			goto out;
> > +		}
> > +		/* If there is no mapped pte young don't collapse the page */
> > +		if (pte_young(pteval))
> > +			referenced = 1;
> > +		page = vm_normal_page(vma, address, pteval);
> > +		if (unlikely(!page)) {
> > +			release_pte_pages(pte, _pte);
> > +			goto out;
> > +		}
> > +		VM_BUG_ON(PageCompound(page));
> > +		BUG_ON(!PageAnon(page));
> > +		VM_BUG_ON(!PageSwapBacked(page));
> > +
> > +		/* cannot use mapcount: can't collapse if there's a gup pin */
> > +		if (page_count(page) != 1) {
> > +			release_pte_pages(pte, _pte);
> > +			goto out;
> > +		}
> 
> Ok you hold mmap_sem locked the pte_lock and we know that there is/was
> only one refcount. However, this does not mean that nothing can reach the
> page. The hardware tlb lookup / tlb walker can still reach the page and
> potentially modify bits. follow_page() can still reach the page. LRU is
> also possible?

Check this:

	spin_lock(&mm->page_table_lock); /* probably unnecessary */
	/* after this gup_fast can't run anymore */
	_pmd = pmdp_clear_flush_notify(vma, address, pmd);
	spin_unlock(&mm->page_table_lock);

This already stopped gup_fast and tlb/mmu before the above code could
run. Otherwise the page_count check is meaningless if gup_fast can
run.

> > +		/*
> > +		 * We can do it before isolate_lru_page because the
> > +		 * page can't be freed from under us. NOTE: PG_lock
> > +		 * seems entirely unnecessary but in doubt this is
> > +		 * safer. If proven unnecessary it can be removed.
> > +		 */
> > +		if (!trylock_page(page)) {
> > +			release_pte_pages(pte, _pte);
> > +			goto out;
> > +		}
> 
> Who could be locking the page if the only ref is the page table and we
> hold the pte lock?

split_huge_page through rmap. Maybe the comment should be removed as
it's misleading and probably not accurate. I'll remove the "if proven
unnecessary" because comment is misleading.

> Is this for the case that someone does a follow_page() and lock?

follow_page can't run, it's only to serialize against split_huge_page
running through rmap code, and the VM takes the lock on the page
before it can split_huge_page.

> The page migration code puts migration ptes in there to stop access to the
> page.

No need of that when pmdp_clear_flush_notify is enough and it has to
invoke mmu notifier to be safe so sptes are dropped too.


> > +		/*
> > +		 * Isolate the page to avoid collapsing an hugepage
> > +		 * currently in use by the VM.
> > +		 */
> > +		if (isolate_lru_page(page)) {
> > +			unlock_page(page);
> > +			release_pte_pages(pte, _pte);
> > +			goto out;
> > +		}
> 
> The page can also be reached via the LRU until here? Reclaim code?

Yes. If it's already taken by it, we just abort and try later.

> Note the requirement in the comments for isolate_lru_page() for an
> elevated refcount.

The refcount is elevated by the fact the pte mapping can't go away
from under us (we only invalidated the pmd the pte still there).

> Seems to rely on the teardown of a pte before release of a page in
> reclaim.

Not sure I get this, we simply take the lock on the page to serialize
against split_huge_page, if we arrived first we try to isolate the
page by relaying on the refcount of the page_mapcount == 1, and if we
again arrived first again we collapsed the pages.

> Would it not be better and safer to use and extend the existing
> page migration code for this purpose?
>
> You are performing almost the same activities.
> 
> 1. Isolation
> 
> 2. Copying
> 
> 3. Reestablish reachability.

KSM also works exactly the same as khugepaged and migration but we
solved it without migration pte and apparently nobody wants to deal
with that special migration pte logic. So before worrying about
khugepaged out of the tree, you should actively go fix ksm that works
exactly the same and it's in mainline. Until you don't fix ksm I think
I should be allowed to keep khugepaged simple and lightweight without
being forced to migration pte.

Thanks for the review!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
