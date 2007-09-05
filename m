Date: Wed, 5 Sep 2007 13:42:43 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
Message-ID: <20070905114242.GA19938@wotan.suse.de>
References: <20070814142103.204771292@sgi.com> <200709050220.53801.phillips@phunq.net> <Pine.LNX.4.64.0709050334020.8127@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0709050334020.8127@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Daniel Phillips <phillips@phunq.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 05, 2007 at 03:42:35AM -0700, Christoph Lameter wrote:
> On Wed, 5 Sep 2007, Daniel Phillips wrote:
> 
> > If we remove our anti-deadlock measures, including the ddsnap.vm.fixes 
> > (a roll-up of Peter's patch set) and the request throttling code in 
> > dm-ddsnap.c, and apply your patch set instead, we hit deadlock on the 
> > socket write path after a few hours (traceback tomorrow).  So your 
> > patch set by itself is a stability regression.
> 
> Na, that cannot be the case since it only activates when an OOM condition 
> would otherwise result.
> 
> > There is also some good news for you here.  The combination of our 
> > throttling code, plus your recursive reclaim patches and some fiddling 
> > with PF_LESS_THROTTLE has so far survived testing without deadlocking.  
> > In other words, as far as we have tested it, your patch set can 
> > substitute for Peter's and produce the same effect, provided that we 
> > throttle the block IO traffic.
> 
> Ah. That is good news.
> 
> > It is clear which approach is more efficient: Peter's.  This is because 
> > no scanning is required to pop a free page off a free list, so scanning 
> > work is not duplicated.  How much more efficient is an open question.  
> > Hopefully we will measure that soon.
> 
> Efficiency is not a criterion for a rarely used emergency recovery 
> measure.
> 
> > Briefly touching on other factors:
> > 
> >   * Peter's patch set is much bigger than yours.  The active ingredients
> >     need to be separated out from the other peterz bits such as reserve
> >     management APIs so we can make a fairer comparison.
> 
> Peters patch is much more invasive and requires a coupling of various 
> subsystems that is not good.
> 
> >   * Your patch set here does not address the question of atomic
> >      allocation, though I see you have been busy with that elsewhere.
> >      Adding code to take care of this means you will start catching up
> >      with Peter in complexity.
> 
> Given your tests: It looks like we do not need it.
> 
> >   * The questions Peter raised about how you will deal with loads
> >      involving heavy anonymous allocations are still open.   This looks
> >      like more complexity on the way.
> 
> Either not necessary or also needed without these patches.
> 
> >   * You depend on maintaining a global dirty page limit while Peter's
> >      approach does not.  So we see the peterz approach as progress
> >      towards eliminating one of the great thorns in our side:
> >      congestion_wait deadlocks, which we currently hack around in a
> >      thoroughly disgusting way (PF_LESS_THROTTLE abuse).
> 
> We have a global dirty page limit already. I fully support Peters work on 
> dirty throttling.
> 
> These results show that Peters invasive approach is not needed. Reclaiming 
> easy reclaimable pages when necessary is sufficient.


First of all, I'm not surprised these patches solve the deadlock here.
And that's a good thing, and it means it is likely that we want to merge
it (actually, I quite like the idea in general, regardless of whether it
solves the deadlock or not).

However I really have an aversion to the near enough is good enough way of
thinking. Especially when it comes to fundamental deadlocks in the VM. I
don't know whether Peter's patch is completely clean yet, but fixing the
fundamentally broken code has my full support.

I hate it that there are theoretical bugs still left even if they would
be hit less frequently than hardware failure. And that people are really
happy to put even more of these things in :(

Anyway, as you know I like your patch and if that gives Peter a little
more breathing space then it's a good thing. But I really hope he doesn't
give up on it, and it should be merged one day.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
