Date: Wed, 9 Apr 2008 16:44:01 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 0 of 9] mmu notifier #v12
Message-ID: <20080409144401.GT10133@duo.random>
References: <patchbomb.1207669443@duo.random> <20080409131709.GR11364@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080409131709.GR11364@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 09, 2008 at 08:17:09AM -0500, Robin Holt wrote:
> I applied this patch set with the xpmem version I am working up for
> submission and the basic level-1 and level-2 tests passed.  The full mpi
> regression test still tends to hang, but that appears to be a common
> problem failure affecting either emm or mmu notifiers and therefore, I
> am certain is a problem in my code.
> 
> Please note this is not an endorsement of one method over the other,
> merely that under conditions where we would expect xpmem to pass the
> regression tests, it does pass those tests.

Thanks a lot for testing! #v12 works great with KVM too. (I'm now in
the process of chagning the KVM patch to drop the page pinning)

BTW, how did you implement invalidate_page? As this?

       	invalidate_page() {
       		invalidate_range_begin()
		invalidate_range_end()
	}

If yes, I prefer to remind you that normally invalidate_range_begin is
always called before zapping the pte. In the invalidate_page case
instead, invalidate_range_begin is called _after_ the pte has been
zapped already.

Now there's no problem if the pte is established and the spte isn't
established. But it must never happen that the spte is established and
the pte isn't established (with page-pinning that means unswappable
memlock leak, without page-pinning it would mean memory corruption).

So the range_begin must serialize against the secondary mmu page fault
so that it can't establish the spte on a pte that was zapped by the
rmap code after get_user_pages/follow_page returned. I think your
range_begin already does that so you should be ok but I wanted to
remind about this slight difference in implementing invalidate_page as
I suggested above in previous email just to be sure ;).

This is the race you must guard against in invalidate_page:


   	 CPU0 	     	      CPU1
	 try_to_unmap on page
			      secondary mmu page fault
			      get_user_pages()/follow_page found a page
         ptep_clear_flush
	 invalidate_page()
	  invalidate_range_begin()
          invalidate_range_end()
          return from invalidate_page
			      establish spte on page
			      return from secodnary mmu page fault

If your range_begin already serializes in a hard way against the
secondary mmu page fault, my previously "trivial" suggested
implementation for invalidate_page should work just fine and this this
saves 1 branch for each try_to_unmap_one if compared to the emm
implementation. The branch check is inlined and it checks against the
mmu_notifier_head that is the hot cacheline, no new cachline is
checked just one branch is saved and so it worth it IMHO even if it
doesn't provide any other advantage if you implement it the way above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
