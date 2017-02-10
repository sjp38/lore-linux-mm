Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D0BB96B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 06:01:59 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id v77so9697578wmv.5
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 03:01:59 -0800 (PST)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id x7si777193wmf.1.2017.02.10.03.01.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 03:01:58 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id B285F1C1D7E
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 11:01:57 +0000 (GMT)
Date: Fri, 10 Feb 2017 11:01:57 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: PCID review?
Message-ID: <20170210110157.dlejz7szrj3r3pwq@techsingularity.net>
References: <CALCETrVSiS22KLvYxZarexFHa3C7Z-ys_Lt2WV_63b4-tuRpQA@mail.gmail.com>
 <CALCETrVfah6AFG5mZDjVcRrdXKL=07+WC9ES9ZKU90XqVpWCOg@mail.gmail.com>
 <20170209001042.ahxmoqegr6h74mle@techsingularity.net>
 <CALCETrUiUnZ1AWHjx8-__t0DUwryys9O95GABhhpG9AnHwrg9Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CALCETrUiUnZ1AWHjx8-__t0DUwryys9O95GABhhpG9AnHwrg9Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Borislav Petkov <bp@alien8.de>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Thu, Feb 09, 2017 at 06:46:57PM -0800, Andy Lutomirski wrote:
> > try_to_unmap_flush then flushes the entire TLB as the cost of targetted
> > a specific page to flush was so high (both maintaining the PFNs and the
> > individual flush operations).
> 
> I could just maybe make it possible to remotely poke a CPU to record
> which mms need flushing, but the possible races there are a bit
> terrifying.
> 

The overhead is concerning. You may incur a remote cache miss accessing the
data which is costly or you have to send an IPI which is also severe. You
could attempt to do the same as the scheduler and directly modify if the
CPUs share cache and IPI otherwise but you're looking at a lot of overhead
either way.

> >
> >> Would it make sense to add a new
> >> arch API to flush more than one mm?  Presumably it would take a linked
> >> list, and the batched flush code would fall back to flushing in pieces
> >> if it can't allocate a new linked list node when needed.
> >>
> >
> > Conceptually it's ok but the details are a headache.
> >
> > The defer code would need to maintain a list of mm's (or ASIDs) that is
> > unbounded in size to match the number of IPIs sent as the current code as
> > opposed to a simple cpumask. There are SWAP_CLUSTER_MAX pages to consider
> > with each page potentially mapped by an arbitrary number of MMs. The same
> > mm's could exist on multiple lists for each active kswapd instance and
> > direct reclaimer.
> >
> > As multiple reclaimers are interested in the same mm, that pretty much
> > rules out linking them off mm_struct unless the locking would serialise
> > the parallel reclaimers and prevent an mm existing on more than one list
> > at a time. You could try allowing multiple tasks to share the one list
> > (not sure how to find that list quickly) but each entry would have to
> > be locked and as each user can flush at any time, multiple reclaimers
> > potentially have to block while an IPI is being sent. It's hard to see
> > how this could be scaled to match the existing code.
> >
> > It would be easier to track via an array stored in task_struct but the
> > number of MMs is unknown in advance so all you can do is guess a reasonable
> > size. It would have to flush if the array files resulting in more IPIs
> > than the current code depending on how many MMs map the list of pages.
> 
> What if I just allocate a smallish array on the stack and then extend
> with kmalloc(GFP_ATOMIC) as needed?  An allocation failure would just
> force an immediate flush, so there shouldn't be any deadlock risk.
> 

It won't deadlock but it's an atomic allocation (which accesses reserves)
at the time when we are definitely reclaiming with a fallback being an IPI
the current code would avoid. It'll indirectly increase risks of other
atomic allocation failures although that risk is slight. The allocation
in that context will still raise eyebrows and it made me wince. I know I
recently considered doing an atomic allocation under similar circumstances
but it was fine to completely fail the allocation and a day later, I got
rid of it anyway.

> Anyway, I need to rework the arch code to make this work at all.
> Currently I'm taking a spinlock per mm when flushing that mm, but that
> would mean I need to *sort* the list to flush more than one at a time,
> and that just sounds nasty.  I can probably get rid of the spinlock.
> 

That all sounds fairly nasty. Don't get me wrong, I think you can make
it functionally work but it's a severe uphill battle.

The key concern that it'll be evaluated against is that any complexity has
to be less than doing a "batched full TLB flush and refill". The refill is
expected to be cheap as the page table structures are likely to be cache hot.
It was way cheaper than trying to be clever about flushing individual TLB
entries. I recognise that you'll be trying to balance this against processes
that are carefully isolated that do not want interference from unrelated
processes doing a TLB flush but it'll be hard to prove that it's worth it.

It's almost certain that this will be Linus' primary concern
given his contributions to similar conversations in the past
(e.g. https://lkml.org/lkml/2015/6/25/666). It's also likely to be of
major concern to Ingo (e.g. https://lkml.org/lkml/2015/6/9/276) as he had
valid objections against clever flushing at the time the batching was
introduced. Based on previous experience, I have my own concerns but I
don't count as I'm highlighing them now :P

The outcome of the TLB batch flushiing discussion was that it was way
cheaper to flush the full TLB and take the refill cost than flushing
individual pages which had the cost of tracking the PFNs and the cost of
each individual page flush operation.

The current code is basically "build a cpumask and flush the TLB for
multiple entries". We're talking about complex tracking of mm's with
difficult locking, potential remote cache misses, potentially more IPIs or
alternatively doing allocations from reclaim context. It'll be difficult
to prove that doing this in the name of flushing ASID is cheaper and
universally a good idea than just flushing the entire TLB.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
