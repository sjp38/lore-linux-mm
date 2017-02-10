Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3CFBA6B0389
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 17:07:42 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id 123so28123300vkm.4
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 14:07:42 -0800 (PST)
Received: from mail-vk0-x22f.google.com (mail-vk0-x22f.google.com. [2607:f8b0:400c:c05::22f])
        by mx.google.com with ESMTPS id s125si976097vkh.1.2017.02.10.14.07.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 14:07:41 -0800 (PST)
Received: by mail-vk0-x22f.google.com with SMTP id k127so35418766vke.0
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 14:07:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170210215708.j54cawm23nepgimd@techsingularity.net>
References: <CALCETrVSiS22KLvYxZarexFHa3C7Z-ys_Lt2WV_63b4-tuRpQA@mail.gmail.com>
 <CALCETrVfah6AFG5mZDjVcRrdXKL=07+WC9ES9ZKU90XqVpWCOg@mail.gmail.com>
 <20170209001042.ahxmoqegr6h74mle@techsingularity.net> <CALCETrUiUnZ1AWHjx8-__t0DUwryys9O95GABhhpG9AnHwrg9Q@mail.gmail.com>
 <20170210110157.dlejz7szrj3r3pwq@techsingularity.net> <CALCETrVjhVqpHTpQ--AVDpWQAb44b265sesou50wSec4rs9sRw@mail.gmail.com>
 <20170210215708.j54cawm23nepgimd@techsingularity.net>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 10 Feb 2017 14:07:19 -0800
Message-ID: <CALCETrWToSZZsXHyrXg+YRiyvjRtWd7J0Myvn_mjJJdJoCXr+w@mail.gmail.com>
Subject: Re: PCID review?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Borislav Petkov <bp@alien8.de>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Fri, Feb 10, 2017 at 1:57 PM, Mel Gorman <mgorman@techsingularity.net> wrote:
> On Fri, Feb 10, 2017 at 08:44:04AM -0800, Andy Lutomirski wrote:
>> On Fri, Feb 10, 2017 at 3:01 AM, Mel Gorman <mgorman@techsingularity.net> wrote:
>> > On Thu, Feb 09, 2017 at 06:46:57PM -0800, Andy Lutomirski wrote:
>> >> > try_to_unmap_flush then flushes the entire TLB as the cost of targetted
>> >> > a specific page to flush was so high (both maintaining the PFNs and the
>> >> > individual flush operations).
>> >>
>> >> I could just maybe make it possible to remotely poke a CPU to record
>> >> which mms need flushing, but the possible races there are a bit
>> >> terrifying.
>> >>
>> >
>> > The overhead is concerning. You may incur a remote cache miss accessing the
>> > data which is costly or you have to send an IPI which is also severe. You
>> > could attempt to do the same as the scheduler and directly modify if the
>> > CPUs share cache and IPI otherwise but you're looking at a lot of overhead
>> > either way.
>>
>> I think all of these approaches suck and I'll give up on this particular avenue.
>>
>
> Ok, probably for the best albeit that is based on an inability to figure
> out how it could be done efficiently and a suspicion that if it could be
> done, the scheduler would be doing it already.
>

FWIW, I am doing a bit of this.  For remote CPUs that aren't currently
running a given mm, I just bump a per-mm generation count so that they
know to flush next time around in switch_mm().  I'll need to add a new
hook to the batched flush code to get this right, and I'll cc you on
that.  Stay tuned.

> It's possible that covering all of this is overkill but it's the avenues
> of concern I'd expect if I was working on ASID support.

Agreed.

>
> [1] I could be completely wrong, I'm basing this on how people have
>     behaved in the past during TLB-flush related discussions. They
>     might have changed their mind.

We'll see.  The main benchmark that I'm relying on (so far) is that
context switches get way faster, just ping ponging back and forth.  I
suspect that the TLB refill cost is only a small part.

>
> [2] This could be covered already in the specifications and other
>     discussions. Again, I didn't actually look into what's truly new with
>     the Intel ASID.

I suspect I could find out how many ASIDs there really are under NDA,
but even that would be challenging and only dubiously useful.  For
now, I'm using a grand total of four ASIDs. :)

>
>> > I recognise that you'll be trying to balance this against processes
>> > that are carefully isolated that do not want interference from unrelated
>> > processes doing a TLB flush but it'll be hard to prove that it's worth it.
>> >
>> > It's almost certain that this will be Linus' primary concern
>> > given his contributions to similar conversations in the past
>> > (e.g. https://lkml.org/lkml/2015/6/25/666). It's also likely to be of
>> > major concern to Ingo (e.g. https://lkml.org/lkml/2015/6/9/276) as he had
>> > valid objections against clever flushing at the time the batching was
>> > introduced. Based on previous experience, I have my own concerns but I
>> > don't count as I'm highlighing them now :P
>>
>> I fully agree with those objections, but back then we didn't have the
>> capability to avoid a flush when switching mms.
>>
>
> True, so watch for questions on what the odds are of switching an MM will
> flush the TLB information anyway due to replacement policies.
>
>> >
>> > The outcome of the TLB batch flushiing discussion was that it was way
>> > cheaper to flush the full TLB and take the refill cost than flushing
>> > individual pages which had the cost of tracking the PFNs and the cost of
>> > each individual page flush operation.
>> >
>> > The current code is basically "build a cpumask and flush the TLB for
>> > multiple entries". We're talking about complex tracking of mm's with
>> > difficult locking, potential remote cache misses, potentially more IPIs or
>> > alternatively doing allocations from reclaim context. It'll be difficult
>> > to prove that doing this in the name of flushing ASID is cheaper and
>> > universally a good idea than just flushing the entire TLB.
>> >
>>
>> Maybe there's a middle ground.  I could keep track of whether more
>> than one mm is targetted in a deferred flush and just flush everything
>> if so.
>
> That would work and side-steps much of the state tracking concerns. It
> might even be a good fit for use cases like "limited number of VMs on a
> machine" or "one major application that must be isolated and some admin
> processes with little CPU time or kthreads" because you don't want to get
> burned with the "only a microbenchmark sees any benefit" hammer[3].
>
>> As a future improvement, I or someone else could add:
>>
>> struct mm_struct *mms[16];
>> int num_mms;
>>
>> to struct tlbflush_unmap_batch.  if num_mms > 16, then this just means
>> that we've given up on tracking them all and we do the global flush,
>> and, if not, we could teach the IPI handler to understand a list of
>> target mms.
>
> I *much* prefer a fallback of a full flush than kmallocing additional
> space. It's also something that feasibly could be switchable at runtime with
> a union of cpumask and an array of mms depending on the CPU capabilities with
> static branches determining which is used to minimise overhead.  That would
> have only minor overhead and with a debugging patch could allow switching
> between them at boot-time for like-like comparisons on a range of workloads.

Sounds good.  This means I need to make my code understand the concept
of a full flush, but that's manageable.

>
> [3] Can you tell I've been burned a few times by the "only
>     microbenchmarks care" feedback?
>

:)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
