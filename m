Date: Wed, 20 Feb 2008 11:00:54 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
In-Reply-To: <47BBCAFB.4080302@linux.vnet.ibm.com>
Message-ID: <Pine.LNX.4.64.0802201023510.30466@blonde.site>
References: <Pine.LNX.4.64.0802191449490.6254@blonde.site>
 <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
 <17878602.1203436460680.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0802191605500.16579@blonde.site> <47BBCAFB.4080302@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008, Balbir Singh wrote:
> 
> The changes look good and clean overall. I'll apply the patch, test it.

Thanks, yes, it's fine for applying as a patch for testing;
just don't send it up the line until I've split and commented it.

> I have
> some review comments below. I'll review it again to check for locking issues
...
> 
> > -void page_assign_page_cgroup(struct page *page, struct page_cgroup *pc)
> > +static void page_assign_page_cgroup(struct page *page, struct page_cgroup *pc)
> >  {
> > -	int locked;
> > -
> > -	/*
> > -	 * While resetting the page_cgroup we might not hold the
> > -	 * page_cgroup lock. free_hot_cold_page() is an example
> > -	 * of such a scenario
> > -	 */
> > -	if (pc)
> > -		VM_BUG_ON(!page_cgroup_locked(page));
> > -	locked = (page->page_cgroup & PAGE_CGROUP_LOCK);
> > -	page->page_cgroup = ((unsigned long)pc | locked);
> > +	page->page_cgroup = ((unsigned long)pc | PAGE_CGROUP_LOCK);
> 
> We are explicitly setting the PAGE_CGROUP_LOCK bit, shouldn't we keep the
> VM_BUG_ON(!page_cgroup_locked(page))?

Could do, but it seemed quite unnecessary to me now that it's a static
function with the obvious rule everywhere that you call it holding lock,
no matter whether pc is or isn't NULL.  If somewhere in memcontrol.c
did call it without holding the lock, it'd also have to bizarrely
remember to unlock while forgetting to lock, for it to escape notice.

(I did say earlier that I was reversing making it static, but that
didn't work out so well: ended up adding a specific page_reset_bad_cgroup
inline in memcontrol.h, just for the bad_page case.)

> > @@ -2093,12 +2093,9 @@ static int do_swap_page(struct mm_struct
> >  	unlock_page(page);
> > 
> >  	if (write_access) {
> > -		/* XXX: We could OR the do_wp_page code with this one? */
> > -		if (do_wp_page(mm, vma, address,
> > -				page_table, pmd, ptl, pte) & VM_FAULT_OOM) {
> > -			mem_cgroup_uncharge_page(page);
> > -			ret = VM_FAULT_OOM;
> > -		}
> > +		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte);
> > +		if (ret & VM_FAULT_ERROR)
> > +			ret &= VM_FAULT_ERROR;
> 
> I am afraid, I do not understand this change (may be I need to look at the final
> code and not the diff). We no longer uncharge the charged page here.

The page that was charged is there in the pagetable, and will be
uncharged as usual when that area is unmapped.  What has failed here
is just the COWing of that page.  You could argue that we should ignore
the retval from do_wp_page and return our own retval: I hesitated over
that, but since we skip do_swap_page's update_mmu_cache here, it seems
conceivable that some architecture might loop endlessly if we claimed
success when do_wp_page has skipped it too.

This is of course an example of why I didn't post the patch originally,
just when Kame asked for a copy for testing: it badly needs the split
and comments.  You're brave to be reviewing it at all - thanks!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
