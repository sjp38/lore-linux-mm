Date: Wed, 1 Aug 2007 00:40:52 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: make swappiness safer to use
Message-ID: <20070731224052.GW6910@v2.random>
References: <20070731215228.GU6910@v2.random> <20070731151244.3395038e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070731151244.3395038e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi Andrew!

On Tue, Jul 31, 2007 at 03:12:44PM -0700, Andrew Morton wrote:
> On Tue, 31 Jul 2007 23:52:28 +0200
> Andrea Arcangeli <andrea@suse.de> wrote:
> 
> > +		swap_tendency += zone_page_state(zone, NR_ACTIVE) /
> > +			(zone_page_state(zone, NR_INACTIVE) + 1)
> > +			* (vm_swappiness + 1) / 100
> > +			* mapped_ratio / 100;
> 
> I must say, that's a pretty ugly-looking statement.  For a start, the clause
> 
> 			* (vm_swappiness + 1) / 100
> 
> always evaluates to zero.  The L->R associativity prevents that, but the
> layout is super-misleading, no?

I can split into multiple lines if you prefer, but it wouldn't make
much difference.

The basic idea is that the feedback provided by priority is
cpu-wasteful, if we have an active list large 8000000 and inactive
being 0, it's absolutely pointless to do what mainline does i.e. wait
priority to go down to zero before refiling mapped page down to the
inactive list. We clearly can get a better feedback loop by checking
for insane balances of the two lists.

> And it matters - the potential for overflow and rounding errors here is
> considerable.  Let's go through it.  Probably 32-bit is the problem.
> 
> 
> 	zone_page_state(zone, NR_ACTIVE) /
> 
> 	0 -> 8,000,000
> 
> 		(zone_page_state(zone, NR_INACTIVE) + 1)
> 
> min: 1, max: 8,000,000
> 
> 		* (vm_swappiness + 1)
> 
> min: 1, max: 101
> 
> total min: 1, total max: 800,000,000
> 
> 	/ 100
> 
> 
> total min: 0, total max: 8,000,000
> 
> 		* mapped_ratio
> 
> total min: 0, total max: 800,000,000
> 
> 		/ 100;
> 
> total min: 0, total max: 8,000,000
> 
> then we divide zone_page_state(zone, NR_ACTIVE) by this value.

Hmm no. we divide zone_page_state(zone, NR_ACTIVE) immediately by
zone_page_state(zone, NR_INACTIVE)+1. So in the extreme case that
inactive is 0 and active is 8000000 we get this:

8000000 / 1 * (swappiness+1)/100 * mapped_ratio / 100

8000000 / 1 = 8000000
8000000 * 100 = 800000000
800000000 / 100 = 8000000
8000000 * 100 = 800000000
800000000 / 100 = 8000000

So in the most extreme case swap_tendency will be 8000000 + the
previous swap_tendency value which is fine.

> We can get a divide-by-zero if zone_page_state(zone, NR_INACTIVE) is
> sufficiently small, I think?  At least, it isn't obvious that we cannot.

I think gcc should be guaranteed to go from left to right like you
said (I don't think we're required to put it in separate local
variables to get that guarantee from gcc). "zone_page_state(zone,
NR_INACTIVE) + 1" min value is 1. For this to generate a divide by
zero zone_page_state(zone, NR_INACTIVE) should return ~1UL which will
never happen due to ram constraints.

> I suspect that we can get a value >100, too.  Especially when we add it to
> the existing value of swap_tendency, but I didn't think about it too hard.

swap_tendency can already be > 100 of course no problem with that. The
idea is to easily boost swap_tendency when there is memory pressure
and a tiny inactive list and swappiness close to 0, without waiting
distress to hit the breakpoint after waste of cpu touching all those
ptes marked young in the failure attempt to find some unmapped page.

distress is a last resort to avoid hitting oom early, depending on it
doesn't provide for a graceful behavior when swappiness is zero or
close to zero (swappiness zero truly deadlocks actually).

> Want to see if we can present that expression in a more logical fashion, and
> be more careful about the underflows and overflows, and fix the potential
> divide-by-zero?

I may be missing something, ff I would see it I could fix it. how to
express it more logical way I guess all I can do is to split in
different lines. As far as I can tell this is already the correct way
to compute it w.r.t. to divide by zero and making sure to avoid
overflows. We multiply by 100 and then shrink it immediately every
time. We want only the effect to be visible when active is
significantly larger (order of 100 times larger) than inactive. In all
normal conditions with quite some pagecache and not 100% mapped, the
effect shouldn't be visible at all. It's only the currently too rought
corner cases that we intend to smooth with this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
