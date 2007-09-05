From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
Date: Wed, 5 Sep 2007 09:16:03 -0700
References: <20070814142103.204771292@sgi.com> <200709050220.53801.phillips@phunq.net> <Pine.LNX.4.64.0709050334020.8127@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0709050334020.8127@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200709050916.04477.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wednesday 05 September 2007 03:42, Christoph Lameter wrote:
> On Wed, 5 Sep 2007, Daniel Phillips wrote:
> > If we remove our anti-deadlock measures, including the
> > ddsnap.vm.fixes (a roll-up of Peter's patch set) and the request
> > throttling code in dm-ddsnap.c, and apply your patch set instead,
> > we hit deadlock on the socket write path after a few hours
> > (traceback tomorrow).  So your patch set by itself is a stability
> > regression.
>
> Na, that cannot be the case since it only activates when an OOM
> condition would otherwise result.

I did not express myself clearly then.  Compared to our current 
anti-deadlock patch set, you patch set is a regression.  Because 
without help from some of our other patches, it does deadlock.  
Obviously, we cannot have that.

> > It is clear which approach is more efficient: Peter's.  This is
> > because no scanning is required to pop a free page off a free list,
> > so scanning work is not duplicated.  How much more efficient is an
> > open question. Hopefully we will measure that soon.
>
> Efficiency is not a criterion for a rarely used emergency recovery
> measure.

That depends on how rarely used.  Under continuous, heavy load this may 
not be rare at all.  This must be measured.

> > Briefly touching on other factors:
> >
> >   * Peter's patch set is much bigger than yours.  The active
> > ingredients need to be separated out from the other peterz bits
> > such as reserve management APIs so we can make a fairer comparison.
>
> Peters patch is much more invasive and requires a coupling of various
> subsystems that is not good.

I agree that Peter's patch set is larger than necessary.  I do not agree 
that it couples subsystems unnecessarily.

> >   * Your patch set here does not address the question of atomic
> >      allocation, though I see you have been busy with that
> > elsewhere. Adding code to take care of this means you will start
> > catching up with Peter in complexity.
>
> Given your tests: It looks like we do not need it.

I do not agree with that line of thinking.  A single test load only 
provides evidence, not proof.  Your approach is not obviously correct, 
quite the contrary.  The tested patch set does not help atomic alloc at 
all, which is clearly a problem we can hit, we just did not hit it this 
time.

> >   * The questions Peter raised about how you will deal with loads
> >      involving heavy anonymous allocations are still open.   This
> > looks like more complexity on the way.
>
> Either not necessary or also needed without these patches.

Your proof?

> >   * You depend on maintaining a global dirty page limit while
> > Peter's approach does not.  So we see the peterz approach as
> > progress towards eliminating one of the great thorns in our side:
> > congestion_wait deadlocks, which we currently hack around in a
> > thoroughly disgusting way (PF_LESS_THROTTLE abuse).
>
> We have a global dirty page limit already. I fully support Peters
> work on dirty throttling.

Alas, I communicated exactly the opposite of what I intended.  We do not 
like the global dirty limit.  It makes the vm complex and fragile, 
unnecessarily.  We favor an approach that places less reliance on the 
global dirty limit so that we can remove some of the fragile and hard 
to support workarounds we have had to implement because of it.

> These results show that Peters invasive approach is not needed.
> Reclaiming easy reclaimable pages when necessary is sufficient.

These results do not show that at all, I apologize for not making that 
sufficiently clear.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
