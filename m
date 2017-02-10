Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id E647D6B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 11:44:26 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id t8so22986439vke.3
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 08:44:26 -0800 (PST)
Received: from mail-ua0-x22e.google.com (mail-ua0-x22e.google.com. [2607:f8b0:400c:c08::22e])
        by mx.google.com with ESMTPS id q20si667513uaa.251.2017.02.10.08.44.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 08:44:25 -0800 (PST)
Received: by mail-ua0-x22e.google.com with SMTP id y9so32326310uae.2
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 08:44:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170210110157.dlejz7szrj3r3pwq@techsingularity.net>
References: <CALCETrVSiS22KLvYxZarexFHa3C7Z-ys_Lt2WV_63b4-tuRpQA@mail.gmail.com>
 <CALCETrVfah6AFG5mZDjVcRrdXKL=07+WC9ES9ZKU90XqVpWCOg@mail.gmail.com>
 <20170209001042.ahxmoqegr6h74mle@techsingularity.net> <CALCETrUiUnZ1AWHjx8-__t0DUwryys9O95GABhhpG9AnHwrg9Q@mail.gmail.com>
 <20170210110157.dlejz7szrj3r3pwq@techsingularity.net>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 10 Feb 2017 08:44:04 -0800
Message-ID: <CALCETrVjhVqpHTpQ--AVDpWQAb44b265sesou50wSec4rs9sRw@mail.gmail.com>
Subject: Re: PCID review?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Borislav Petkov <bp@alien8.de>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Fri, Feb 10, 2017 at 3:01 AM, Mel Gorman <mgorman@techsingularity.net> wrote:
> On Thu, Feb 09, 2017 at 06:46:57PM -0800, Andy Lutomirski wrote:
>> > try_to_unmap_flush then flushes the entire TLB as the cost of targetted
>> > a specific page to flush was so high (both maintaining the PFNs and the
>> > individual flush operations).
>>
>> I could just maybe make it possible to remotely poke a CPU to record
>> which mms need flushing, but the possible races there are a bit
>> terrifying.
>>
>
> The overhead is concerning. You may incur a remote cache miss accessing the
> data which is costly or you have to send an IPI which is also severe. You
> could attempt to do the same as the scheduler and directly modify if the
> CPUs share cache and IPI otherwise but you're looking at a lot of overhead
> either way.

I think all of these approaches suck and I'll give up on this particular avenue.

>> Anyway, I need to rework the arch code to make this work at all.
>> Currently I'm taking a spinlock per mm when flushing that mm, but that
>> would mean I need to *sort* the list to flush more than one at a time,
>> and that just sounds nasty.  I can probably get rid of the spinlock.
>>
>
> That all sounds fairly nasty. Don't get me wrong, I think you can make
> it functionally work but it's a severe uphill battle.
>
> The key concern that it'll be evaluated against is that any complexity has
> to be less than doing a "batched full TLB flush and refill". The refill is
> expected to be cheap as the page table structures are likely to be cache hot.
> It was way cheaper than trying to be clever about flushing individual TLB
> entries.

You're assuming that Intel CPUs are more sensible than they really
are.  My suspicion, based on some benchmarking, is that "switch pgd
and clear the TLB" is very slow because of the "clear the TLB bit" --
that is, above and beyond the refill cost, merely clearing the TLB
takes hundreds of cycles.  So I'd like to minimize unnecessary
flushes.  Unfortunately, "flush the TLB for all ASIDs" and "flush
everything" are also both very very slow.

Sigh.

> I recognise that you'll be trying to balance this against processes
> that are carefully isolated that do not want interference from unrelated
> processes doing a TLB flush but it'll be hard to prove that it's worth it.
>
> It's almost certain that this will be Linus' primary concern
> given his contributions to similar conversations in the past
> (e.g. https://lkml.org/lkml/2015/6/25/666). It's also likely to be of
> major concern to Ingo (e.g. https://lkml.org/lkml/2015/6/9/276) as he had
> valid objections against clever flushing at the time the batching was
> introduced. Based on previous experience, I have my own concerns but I
> don't count as I'm highlighing them now :P

I fully agree with those objections, but back then we didn't have the
capability to avoid a flush when switching mms.

All that being said, I agree: making this stuff too complicated is a bad idea.

>
> The outcome of the TLB batch flushiing discussion was that it was way
> cheaper to flush the full TLB and take the refill cost than flushing
> individual pages which had the cost of tracking the PFNs and the cost of
> each individual page flush operation.
>
> The current code is basically "build a cpumask and flush the TLB for
> multiple entries". We're talking about complex tracking of mm's with
> difficult locking, potential remote cache misses, potentially more IPIs or
> alternatively doing allocations from reclaim context. It'll be difficult
> to prove that doing this in the name of flushing ASID is cheaper and
> universally a good idea than just flushing the entire TLB.
>

Maybe there's a middle ground.  I could keep track of whether more
than one mm is targetted in a deferred flush and just flush everything
if so.  As a future improvement, I or someone else could add:

struct mm_struct *mms[16];
int num_mms;

to struct tlbflush_unmap_batch.  if num_mms > 16, then this just means
that we've given up on tracking them all and we do the global flush,
and, if not, we could teach the IPI handler to understand a list of
target mms.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
