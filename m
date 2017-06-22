Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id A64CB6B0313
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 14:13:08 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id f20so15626295otd.9
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 11:13:08 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g49si380842otc.210.2017.06.22.11.13.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 11:13:07 -0700 (PDT)
Received: from mail-ua0-f171.google.com (mail-ua0-f171.google.com [209.85.217.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DD4D522B70
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 18:13:06 +0000 (UTC)
Received: by mail-ua0-f171.google.com with SMTP id g40so23473373uaa.3
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 11:13:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1706221037320.1885@nanos>
References: <cover.1498022414.git.luto@kernel.org> <a8cdfbbb17785aed10980d24692745f68615a584.1498022414.git.luto@kernel.org>
 <alpine.DEB.2.20.1706211159430.2328@nanos> <CALCETrUrwyMt+k4a-Tyh85Xiidr3zgEW7LKLnGDz90Z6jL9XtA@mail.gmail.com>
 <alpine.DEB.2.20.1706221037320.1885@nanos>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 22 Jun 2017 11:12:45 -0700
Message-ID: <CALCETrVm9oQCpovr0aZcDXoG-8hOoYPMDyhYZJPSBNFGemXQNg@mail.gmail.com>
Subject: Re: [PATCH v3 11/11] x86/mm: Try to preserve old TLB entries using PCID
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Thu, Jun 22, 2017 at 5:21 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Wed, 21 Jun 2017, Andy Lutomirski wrote:
>> On Wed, Jun 21, 2017 at 6:38 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
>> > That requires a conditional branch
>> >
>> >         if (asid >= NR_DYNAMIC_ASIDS) {
>> >                 asid = 0;
>> >                 ....
>> >         }
>> >
>> > The question is whether 4 IDs would be sufficient which trades the branch
>> > for a mask operation. Or you go for 8 and spend another cache line.
>>
>> Interesting.  I'm inclined to either leave it at 6 or reduce it to 4
>> for now and to optimize later.
>
> :)
>
>> > Hmm. So this loop needs to be taken unconditionally even if the task stays
>> > on the same CPU. And of course the number of dynamic IDs has to be short in
>> > order to makes this loop suck performance wise.
>> >
>> > Something like the completely disfunctional below might be worthwhile to
>> > explore. At least arch/x86/mm/ compiles :)
>> >
>> > It gets rid of the loop search and lifts the limit of dynamic ids by
>> > trading it with a percpu variable in mm_context_t.
>>
>> That would work, but it would take a lot more memory on large systems
>> with lots of processes, and I'd also be concerned that we might run
>> out of dynamic percpu space.
>
> Yeah, did not think about the dynamic percpu space.
>
>> How about a different idea: make the percpu data structure look like a
>> 4-way set associative cache.  The ctxs array could be, say, 1024
>> entries long without using crazy amounts of memory.  We'd divide it
>> into 256 buckets, so you'd index it like ctxs[4*bucket + slot].  For
>> each mm, we choose a random bucket (from 0 through 256), and then we'd
>> just loop over the four slots in the bucket in choose_asid().  This
>> would require very slightly more arithmetic (I'd guess only one or two
>> cycles, though) but, critically, wouldn't touch any more cachelines.
>>
>> The downside of both of these approaches over the one in this patch is
>> that the change that the percpu cacheline we need is not in the cache
>> is quite a bit higher since it's potentially a different cacheline for
>> each mm.  It would probably still be a win because avoiding the flush
>> is really quite valuable.
>>
>> What do you think?  The added code would be tiny.
>
> That might be worth a try.
>
> Now one other optimization which should be trivial to add is to keep the 4
> asid context entries in cpu_tlbstate and cache the last asid in thread
> info. If that's still valid then use it otherwise unconditionally get a new
> one. That avoids the whole loop machinery and thread info is cache hot in
> the context switch anyway. Delta patch on top of your version below.

I'm not sure I understand.  If an mm has ASID 0 on CPU 0 and ASID 1 on
CPU 1 and a thread in that mm bounces back and forth between those
CPUs, won't your patch cause it to flush every time?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
