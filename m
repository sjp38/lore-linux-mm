Date: Tue, 19 Feb 2008 23:59:23 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] my mmu notifiers
Message-ID: <20080219225923.GA18912@wotan.suse.de>
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080219135851.GI7128@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2008 at 02:58:51PM +0100, Andrea Arcangeli wrote:
> On Tue, Feb 19, 2008 at 09:43:57AM +0100, Nick Piggin wrote:
> > are rather similar. However I have tried to make a point of minimising the
> > impact the the core mm/. I don't see why we need to invalidate or flush
> 
> I also tried hard to minimise the impact of the core mm/, I also
> argued with Christoph that cluttering mm/ wasn't a good idea for
> things like age_page that could be a 1 liner change instead of a
> multiple-liner change, without any loss of flexibility or readability.
> 
> > anything when changing the pte to be _more_ permissive, and I don't
> 
> Note that in my patch the invalidate_pages in mprotect can be
> trivially switched to a mprotect_pages with proper params. This will
> prevent page faults completely in the secondary MMU (there will only
> be tlb misses after the tlb flush just like for the core linux pte),
> and it'll allow all the secondary MMU pte blocks (512/1024 at time
> with my PT lock design) to be updated to have proper permissions
> matching the core linux pte.
> 
> > understand the need for invalidate_begin/invalidate_end pairs at all.
> 
> The need of the pairs is crystal clear to me: range_begin is needed
> for GRU _but_only_if_ range_end is called after releasing the
> reference that the VM holds on the page. _begin will flush the GRU tlb
> and at the same time it will take a mutex that will block further GRU
> tlb-miss-interrupts (no idea how they manange those nightmare locking,
> I didn't even try to add more locking to KVM and I get away with the
> fact KVM takes the pin on the page itself).
> 
> My patch calls invalidate_page/pages before the reference is released
> on the page, so GRU will work fine despite lack of
> range_begin. Furthermore with my patch GRU will be auto-serialized by
> the PT lock w/o the need of any additional locking.

That's why I don't understand the need for the pairs: it should be
done like this.


> > What I have done is basically create it so that the notifiers get called
> > basically in the same place as the normal TLB flushing is done, and nowhere
> > else.
> 
> That was one of my objectives too.
> 
> > I also wanted to avoid calling notifier code from inside eg. hardware TLB
> > or pte manipulation primitives. These things are already pretty well
> > spaghetti, so I'd like to just place them right where needed first... I
> > think eventually it will need a bit of a rethink to make it more consistent
> > and more general. But I prefer to do put them in the caller for the moment.
> 
> Your patch should also work for KVM but it's suboptimal, my patch can
> be orders of magnitude more efficient for GRU thanks to the
> invalidate_pages optimization. Christoph complained about having to
> call one method per pte.

OK, I didn't see the invalidate_pages call...

 
> And adding invalidate_range is useless unless you fully support
> xpmem. You're calling invalidate_range in places that can't sleep...

I thought that could be used by a non-sleeping user (not intending
to try supporting sleeping users). If it is useless then it should
go away (BTW. I didn't see your recent patch, some of my confusion
I think stems from Christoph's novel way of merging and splitting
patches).


> No idea why xpmem needs range_begin, I perfectly understand why GRU
> needs _begin with Chrisotph's patch (gru lacks the page pin) but I
> dunno why xpmem needs range_begin (xpmem has the page pin so I also
> think it could avoid using range_begin). Still to support GRU you need
> both to call invalidate_range in places that can sleep and you need
> the external rmap notifier. The moment you add xpmem into the equation
> your and my clean patches become Christoph's one...

Sorry, I kind of didn't have time to follow the conversation so well
before; are there patches posted for gru and/or xpmem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
