From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
Date: Wed, 5 Sep 2007 02:20:53 -0700
References: <20070814142103.204771292@sgi.com>
In-Reply-To: <20070814142103.204771292@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200709050220.53801.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tuesday 14 August 2007 07:21, Christoph Lameter wrote:
> The following patchset implements recursive reclaim. Recursive
> reclaim is necessary if we run out of memory in the writeout patch
> from reclaim.
>
> This is f.e. important for stacked filesystems or anything that does
> complicated processing in the writeout path.
>
> Recursive reclaim works because it limits itself to only reclaim
> pages that do not require writeout. It will only remove clean pages
> from the LRU. The dirty throttling of the VM during regular reclaim
> insures that the amount of dirty pages is limited. If recursive
> reclaim causes too many clean pages to be removed then regular
> reclaim will throttle all processes until the dirty ratio is
> restored. This means that the amount of memory that can be reclaimed
> via recursive reclaim is limited to clean memory. The default ratio
> is 10%. This means that recursive reclaim can reclaim 90% of memory
> before failing. Reclaiming excessive amounts of clean pages may have
> a significant performance impact because this means that executable
> pages will be removed. However, it ensures that we will no longer
> fail in the writeout path.
>
> A patch is included to test this functionality. The test involved
> allocating 12 Megabytes from the reclaim paths when __PF_MEMALLOC is
> set. This is enough to exhaust the reserves.

Hi Christoph,

Over the last two weeks we have tested your patch set in the context of 
ddsnap, which used to be prone to deadlock before we added a series of 
anti-deadlock measures, including Peter's anti-deadlock patch set, our 
own bio throttling code and judicious use of PF_MEMALLOC mode.  This 
cocktail of patches finally banished the deadlocks, none of which have 
been seen during several months of heavy testing.  The question in 
which you are interested no doubt, is whether your patch set also 
solves the same deadlocks.

The results are mixed.  I will briefly describe the test setup now.  If 
you are interested in specific details for independent verification, we 
can provide the full recipe separately.  We used the patches here:

   http://zumastor.googlecode.com/svn/trunk/ddsnap/patches/2.6.21.1/

driven by the scripted storage application here:

   http://zumastor.googlecode.com/svn/trunk/zumastor/

If we remove our anti-deadlock measures, including the ddsnap.vm.fixes 
(a roll-up of Peter's patch set) and the request throttling code in 
dm-ddsnap.c, and apply your patch set instead, we hit deadlock on the 
socket write path after a few hours (traceback tomorrow).  So your 
patch set by itself is a stability regression.

There is also some good news for you here.  The combination of our 
throttling code, plus your recursive reclaim patches and some fiddling 
with PF_LESS_THROTTLE has so far survived testing without deadlocking.  
In other words, as far as we have tested it, your patch set can 
substitute for Peter's and produce the same effect, provided that we 
throttle the block IO traffic.

Just to recap, we have identified two essential ingredients in the 
recipe for writeout deadlock prevention:

   1) Throttle block IO traffic to a bounded maximum memory use.

   2) Guarantee availability of the required amount of memory.

Now we have learned that (1) is not optional with either the peterz or 
the clameter approach, and we are wondering which is the better way to
handle (2).

If we accept for the moment that both approaches to (2) are equally 
effective at preventing deadlock (this is debatable) then the next 
criterion on the list for deciding the winner would be efficiency.  A 
slight oversimplification to be sure, since we are also interested in 
issues of maintainability, provability and general forward progress.  
However, since none of the latter is directly measurable, efficiency is 
a good place to start.

It is clear which approach is more efficient: Peter's.  This is because 
no scanning is required to pop a free page off a free list, so scanning 
work is not duplicated.  How much more efficient is an open question.  
Hopefully we will measure that soon.

Briefly touching on other factors:

  * Peter's patch set is much bigger than yours.  The active ingredients
    need to be separated out from the other peterz bits such as reserve
    management APIs so we can make a fairer comparison.

  * Your patch set here does not address the question of atomic
     allocation, though I see you have been busy with that elsewhere.
     Adding code to take care of this means you will start catching up
     with Peter in complexity.

  * The questions Peter raised about how you will deal with loads
     involving heavy anonymous allocations are still open.   This looks
     like more complexity on the way.

  * You depend on maintaining a global dirty page limit while Peter's
     approach does not.  So we see the peterz approach as progress
     towards eliminating one of the great thorns in our side:
     congestion_wait deadlocks, which we currently hack around in a
     thoroughly disgusting way (PF_LESS_THROTTLE abuse).

  * Which approach allows us to run with a higher dirty page threshold?
     More dirty page caching is better.  We will test the two approaches
     head to head on this issue pretty soon.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
