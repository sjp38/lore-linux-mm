Subject: RE: [PATCH 5/5] Light fragmentation avoidance without usemap:
	005_drainpercpu
From: Rohit Seth <rohit.seth@intel.com>
In-Reply-To: <Pine.LNX.4.58.0511230009330.31913@skynet>
References: <01EF044AAEE12F4BAAD955CB75064943053DF65D@scsmsx401.amr.corp.intel.com>
	 <Pine.LNX.4.58.0511230009330.31913@skynet>
Content-Type: text/plain
Date: Tue, 22 Nov 2005 17:22:20 -0800
Message-Id: <1132708940.12204.12.camel@akash.sc.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, nickpiggin@yahoo.com.au, ak@suse.de, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Wed, 2005-11-23 at 00:17 +0000, Mel Gorman wrote:
> On Tue, 22 Nov 2005, Seth, Rohit wrote:
> 
> >
> >
> > >requested order is greater than 3.
> >
> > Why this order limit.  Most of the previous failures seen (because of my
> > earlier patches of bigger and more physical contiguous chunks for pcps)
> > were with order 1 allocation.
> >
> 
> The order 3 is because of this block;
> 
>         if (!(gfp_mask & __GFP_NORETRY)) {
>                 if ((order <= 3) || (gfp_mask & __GFP_REPEAT))
>                         do_retry = 1;
>                 if (gfp_mask & __GFP_NOFAIL)
>                         do_retry = 1;
>         }
> 
> If it's less than 3, we are retrying anyway and it's something we are

You are retrying (for 0<order<=3) but without draining the pcps (in your
patch).

> > That code has issues with pre-emptible kernel.
> >
> 
> ok... why? I thought that we could only be preempted when we were about to
> take a spinlock but I have an imperfect understanding of preempt and
> things change quickly. The path the drain_all_local_pages() enters
> disables the local IRQs before calling __drain_pages() and when
> smp_drain_local_pages()  is called, the local IRQs are disabled again
> before releasing pages. Where can we get preempted?
> 

Basically the get_cpu(), put_cpu() needs to cover the whole scope of
smp_processor_id usage.  (When you enable CONFIG_DEBUG_PREEMPT the
kernel will barf if preempt is enabled while calling smp_processor_id).

If the interrupts are disabled all the way through then you wouldn't be
preempted though.  But get/put_cpu is the right mechanism to ensure
smp_processor_id and its derived value is used on same processor.

> > I will be shortly sending the patch to free pages from pcp when higher
> > order allocation is not able to get serviced from global list.
> >
> 
> If that works, this part of the patch can be dropped. The intention is to
> "drain the per-cpu lists by some mechanism". I am not too particular about
> how it happens. Right now, the per-cpu caches make a massive difference on
> my 4-way machine at least on whether a large number of contiguous blocks
> can be allocated or not.
> 

Please let me know if you see any issues with the patch that I sent out
a bit earlier.

Thanks,
-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
