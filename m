Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 487416B004D
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 08:57:53 -0500 (EST)
Date: Tue, 2 Feb 2010 14:56:34 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 32 of 32] khugepaged
Message-ID: <20100202135634.GK4135@random.random>
References: <patchbomb.1264969631@v2.random>
 <51b543fab38b1290f176.1264969663@v2.random>
 <4B670968.7090801@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B670968.7090801@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 01, 2010 at 12:03:36PM -0500, Rik van Riel wrote:
> On 01/31/2010 03:27 PM, Andrea Arcangeli wrote:
> 
> > +	/* stop anon_vma rmap pagetable access */
> > +	spin_lock(&vma->anon_vma->lock);
> 
> This is no longer enough.  The anon_vma changes that
> went into -mm recently mean that a VMA can be associated
> with multiple anon_vmas.
> 
> Of course, forcefully COW copying/writing every page in
> the VMA will ensure that they are all in the anon_vma
> you lock with the code above.
> 
> I suspect the easiest fix would be to lock all the
> anon_vmas attached to a VMA.  That should not lead to
> any deadlocks, since multiple siblings of the same
> parent process would be encountering their anon_vma
> structs in the same order, due to the way that
> anon_vma_clone and anon_vma_fork work.
> 
> This may be too subtle for lockdep, though :/

I hope I can do this in split_huge_page_mm/vma:

if (pmd_trans_huge(*pmd)) {
	spin_lock(&mm->page_table_lock); /* stop pmd updates */
	if (pmd_trans_huge(*pmd)) {
	   unsigned long anon_mapping;
	   struct page *page;
	   struct anon_vma *anon_vma;
	   page = pmd_page(*pmd); /* works even while pmd_splitting is set */
	   anon_mapping = page->mapping; /* ACCESS_ONCE not needed page has to go away before anon_vma */
	   VM_BUG_ON((anon_mapping & PAGE_MAPPING_FLAGS) != PAGE_MAPPING_ANON);
	   VM_BUG_ON(!page_mapped(page));
	   anon_vma = (struct anon_vma *)((unsigned long)page->mapping 	- PAGE_MAPPING_ANON); 
	   rcu_read_lock();
	   spin_unlock(&mm->page_table_lock);
	   spin_lock(&anon_vma->lock);
	   rcu_read_unlock();

If this only causes at most 1 more memory allocation for each new vma
created in the child, at the very first cow on the newly allocated vma
in the child (and no more memory allocation) it should be unmeasurable
overhead so it should be worth it and main downside seems to be in
making the tricky vma adjusting more complex.

I think the most urgent info that is missing is if this enough to fix
the regressions in AIM that grinds to an halt now and prevents to get
results. That is what started the development of this patch (for the
other pages not cowed there is nothing we can do about it and current
anon-vma is already as efficient as it can be in complexity
terms). Optimizing for one-process-per-connection not so important,
even if I know proprietary db do that. I've no idea how many pages
there are in AIM that are cowed and how many that are totally shared
and purely readonly for all processes in the system, and for the
latter this is a noop... If it won't be proven that this fixes AIM
we'll have to still to bisect previous patches.

So in short I recommend to test this patch on Larry's system but again
I think this change is good idea regardless (just I'm not convinced
it'll be enough to prevent aim to grind to an halt, if you call
page_referenced or try_to_unmap in a loop it won't be showing less in
the profiling just because it returns faster, still a loop that will
be and I suspect more the caller not the callee given the callee was
fine in previous kernels... but I didn't have time to look into it so
I may as well be wrong and maybe some legitimate change happened that
requires a more frequent page_referenced calls, dunno).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
