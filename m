Date: Wed, 9 Apr 2008 13:55:00 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 0 of 9] mmu notifier #v12
Message-ID: <20080409185500.GT11364@sgi.com>
References: <patchbomb.1207669443@duo.random> <20080409131709.GR11364@sgi.com> <20080409144401.GT10133@duo.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080409144401.GT10133@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 09, 2008 at 04:44:01PM +0200, Andrea Arcangeli wrote:
> BTW, how did you implement invalidate_page? As this?
> 
>        	invalidate_page() {
>        		invalidate_range_begin()
> 		invalidate_range_end()
> 	}

Essentially, I did the work of each step without releasing and
reacquiring locks.

> If yes, I prefer to remind you that normally invalidate_range_begin is
> always called before zapping the pte. In the invalidate_page case
> instead, invalidate_range_begin is called _after_ the pte has been
> zapped already.
> 
> Now there's no problem if the pte is established and the spte isn't
> established. But it must never happen that the spte is established and
> the pte isn't established (with page-pinning that means unswappable
> memlock leak, without page-pinning it would mean memory corruption).

I am not sure I follow what you are saying.  Here is a very terse
breakdown of how PFNs flow through xpmem's structures.

We have a PFN table associated with our structure describing a grant.
We use get_user_pages() to acquire information for that table and we
fill the table in under a mutex.  Remote hosts (on the same numa network
so they have direct access to the users memory) have a PROXY version of
that structure.  It is filled out in a similar fashion to the local
table.  PTEs are created for the other processes while holding the mutex
for this table (either local or remote).  During the process of
faulting, we have a simple linked list of ongoing faults that is
maintained whenever the mutex is going to be released.

Our version of a zap_page_range is called recall_PFNs.  The recall
process grabs the mutex, scans the faulters list for any that cover the
range and mark them as needing a retry.  It then calls zap_page_range
for any processes that have attached the granted memory to clear out
their page tables.  Finally, we release the mutex and proceed.

The locking is more complex than this, but that is the essential idea.


What that means for mmu_notifiers is we have a single reference on the
page for all the remote processes using it.  When the callout to
invalidate_page() is made, we will still have processes with that PTE in
their page tables and potentially TLB entries.  When we return from the
invalidate_page() callout, we will have removed all those page table
entries, we will have no in-progress page table or tlb insertions that
will complete, and we will have released all our references to the page.

Does that meet your expectations?

Thanks,
Robin
> 
> So the range_begin must serialize against the secondary mmu page fault
> so that it can't establish the spte on a pte that was zapped by the
> rmap code after get_user_pages/follow_page returned. I think your
> range_begin already does that so you should be ok but I wanted to
> remind about this slight difference in implementing invalidate_page as
> I suggested above in previous email just to be sure ;).
> 
> This is the race you must guard against in invalidate_page:
> 
> 
>    	 CPU0 	     	      CPU1
> 	 try_to_unmap on page
> 			      secondary mmu page fault
> 			      get_user_pages()/follow_page found a page
>          ptep_clear_flush
> 	 invalidate_page()
> 	  invalidate_range_begin()
>           invalidate_range_end()
>           return from invalidate_page
> 			      establish spte on page
> 			      return from secodnary mmu page fault
> 
> If your range_begin already serializes in a hard way against the
> secondary mmu page fault, my previously "trivial" suggested
> implementation for invalidate_page should work just fine and this this
> saves 1 branch for each try_to_unmap_one if compared to the emm
> implementation. The branch check is inlined and it checks against the
> mmu_notifier_head that is the hot cacheline, no new cachline is
> checked just one branch is saved and so it worth it IMHO even if it
> doesn't provide any other advantage if you implement it the way above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
