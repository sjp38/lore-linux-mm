Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7EBFC6B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 16:57:11 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 89so15211990wrr.1
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 13:57:11 -0800 (PST)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id 18si2810976wmq.73.2017.02.10.13.57.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Feb 2017 13:57:09 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id DA45499306
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 21:57:08 +0000 (UTC)
Date: Fri, 10 Feb 2017 21:57:08 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: PCID review?
Message-ID: <20170210215708.j54cawm23nepgimd@techsingularity.net>
References: <CALCETrVSiS22KLvYxZarexFHa3C7Z-ys_Lt2WV_63b4-tuRpQA@mail.gmail.com>
 <CALCETrVfah6AFG5mZDjVcRrdXKL=07+WC9ES9ZKU90XqVpWCOg@mail.gmail.com>
 <20170209001042.ahxmoqegr6h74mle@techsingularity.net>
 <CALCETrUiUnZ1AWHjx8-__t0DUwryys9O95GABhhpG9AnHwrg9Q@mail.gmail.com>
 <20170210110157.dlejz7szrj3r3pwq@techsingularity.net>
 <CALCETrVjhVqpHTpQ--AVDpWQAb44b265sesou50wSec4rs9sRw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CALCETrVjhVqpHTpQ--AVDpWQAb44b265sesou50wSec4rs9sRw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Borislav Petkov <bp@alien8.de>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Fri, Feb 10, 2017 at 08:44:04AM -0800, Andy Lutomirski wrote:
> On Fri, Feb 10, 2017 at 3:01 AM, Mel Gorman <mgorman@techsingularity.net> wrote:
> > On Thu, Feb 09, 2017 at 06:46:57PM -0800, Andy Lutomirski wrote:
> >> > try_to_unmap_flush then flushes the entire TLB as the cost of targetted
> >> > a specific page to flush was so high (both maintaining the PFNs and the
> >> > individual flush operations).
> >>
> >> I could just maybe make it possible to remotely poke a CPU to record
> >> which mms need flushing, but the possible races there are a bit
> >> terrifying.
> >>
> >
> > The overhead is concerning. You may incur a remote cache miss accessing the
> > data which is costly or you have to send an IPI which is also severe. You
> > could attempt to do the same as the scheduler and directly modify if the
> > CPUs share cache and IPI otherwise but you're looking at a lot of overhead
> > either way.
> 
> I think all of these approaches suck and I'll give up on this particular avenue.
> 

Ok, probably for the best albeit that is based on an inability to figure
out how it could be done efficiently and a suspicion that if it could be
done, the scheduler would be doing it already.

> >> Anyway, I need to rework the arch code to make this work at all.
> >> Currently I'm taking a spinlock per mm when flushing that mm, but that
> >> would mean I need to *sort* the list to flush more than one at a time,
> >> and that just sounds nasty.  I can probably get rid of the spinlock.
> >>
> >
> > That all sounds fairly nasty. Don't get me wrong, I think you can make
> > it functionally work but it's a severe uphill battle.
> >
> > The key concern that it'll be evaluated against is that any complexity has
> > to be less than doing a "batched full TLB flush and refill". The refill is
> > expected to be cheap as the page table structures are likely to be cache hot.
> > It was way cheaper than trying to be clever about flushing individual TLB
> > entries.
> 
> You're assuming that Intel CPUs are more sensible than they really
> are.  My suspicion, based on some benchmarking, is that "switch pgd
> and clear the TLB" is very slow because of the "clear the TLB bit" --
> that is, above and beyond the refill cost, merely clearing the TLB
> takes hundreds of cycles.  So I'd like to minimize unnecessary
> flushes.  Unfortunately, "flush the TLB for all ASIDs" and "flush
> everything" are also both very very slow.
> 

And so is flushing per page. However, you make an interesting point.
Based on previous benchmarks and evaluation, the conclusion was reached
that targeted per-page flushing was too slow and a full flush was
faster. Several hazards were identified on how it could be even measured
on out-of-order processors and other difficulties so your benchmark will
be called into question [1]. MMtests has reference to an old tlb benchmark
(config-global-dhp__tlbflush-performance) but even that was considered
to be flawed but there were not any alternatives. I have not used it in
a long time due to the level of uncertainity it had.

There was the caveat that processors like Atom cared and this was dismissed
on the grounds the processor was "crippled" (at the time) and such concerns
just didn't apply on the general case. Other concerns were raised that
Knights Landing might care but that was conference talk and it was never
pushed hard that I can recall.

If you have a methodology that proves that the fullflush+refill is
a terrible idea (even if it's CPU-specific) then it'll be important to
include it in the changelog. There will be some attacking on the benchmark
and the methodology but that's to be expected. If you're right for the
processors that are capable then it'll be fine.

But the starting point of the discussionm, not necessarily from me, will be
that Intel CPUs are super fast at refills and the flush cost doesn't matter
because the context switch clears it anyway so complexity should be as low
as possible. There may be some comments that things like ASID were great on
processors that had crippled TLBs (rightly or wrongly).  ASIDs alter the
equation but then you'll be tackled on how often the ASIDs is preserved
and that it may be workload dependant and you may get some hand waving
about how many ASIDs are available[2]. It depends on the specifics of the
Intel implementation which I haven't looked up but it will need to be in
the changelog or you'll get bogged down in "this doesn't matter" discussions.

It's possible that covering all of this is overkill but it's the avenues
of concern I'd expect if I was working on ASID support.

[1] I could be completely wrong, I'm basing this on how people have
    behaved in the past during TLB-flush related discussions. They
    might have changed their mind.

[2] This could be covered already in the specifications and other
    discussions. Again, I didn't actually look into what's truly new with
    the Intel ASID.

> > I recognise that you'll be trying to balance this against processes
> > that are carefully isolated that do not want interference from unrelated
> > processes doing a TLB flush but it'll be hard to prove that it's worth it.
> >
> > It's almost certain that this will be Linus' primary concern
> > given his contributions to similar conversations in the past
> > (e.g. https://lkml.org/lkml/2015/6/25/666). It's also likely to be of
> > major concern to Ingo (e.g. https://lkml.org/lkml/2015/6/9/276) as he had
> > valid objections against clever flushing at the time the batching was
> > introduced. Based on previous experience, I have my own concerns but I
> > don't count as I'm highlighing them now :P
> 
> I fully agree with those objections, but back then we didn't have the
> capability to avoid a flush when switching mms.
> 

True, so watch for questions on what the odds are of switching an MM will
flush the TLB information anyway due to replacement policies.

> >
> > The outcome of the TLB batch flushiing discussion was that it was way
> > cheaper to flush the full TLB and take the refill cost than flushing
> > individual pages which had the cost of tracking the PFNs and the cost of
> > each individual page flush operation.
> >
> > The current code is basically "build a cpumask and flush the TLB for
> > multiple entries". We're talking about complex tracking of mm's with
> > difficult locking, potential remote cache misses, potentially more IPIs or
> > alternatively doing allocations from reclaim context. It'll be difficult
> > to prove that doing this in the name of flushing ASID is cheaper and
> > universally a good idea than just flushing the entire TLB.
> >
> 
> Maybe there's a middle ground.  I could keep track of whether more
> than one mm is targetted in a deferred flush and just flush everything
> if so.

That would work and side-steps much of the state tracking concerns. It
might even be a good fit for use cases like "limited number of VMs on a
machine" or "one major application that must be isolated and some admin
processes with little CPU time or kthreads" because you don't want to get
burned with the "only a microbenchmark sees any benefit" hammer[3].

> As a future improvement, I or someone else could add:
> 
> struct mm_struct *mms[16];
> int num_mms;
> 
> to struct tlbflush_unmap_batch.  if num_mms > 16, then this just means
> that we've given up on tracking them all and we do the global flush,
> and, if not, we could teach the IPI handler to understand a list of
> target mms.

I *much* prefer a fallback of a full flush than kmallocing additional
space. It's also something that feasibly could be switchable at runtime with
a union of cpumask and an array of mms depending on the CPU capabilities with
static branches determining which is used to minimise overhead.  That would
have only minor overhead and with a debugging patch could allow switching
between them at boot-time for like-like comparisons on a range of workloads.

[3] Can you tell I've been burned a few times by the "only
    microbenchmarks care" feedback?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
