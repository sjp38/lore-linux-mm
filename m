Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 178406B02FD
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 22:58:11 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id 63so2816466otc.5
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 19:58:11 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w24si80682otw.114.2017.06.21.19.58.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 19:58:10 -0700 (PDT)
Received: from mail-ua0-f174.google.com (mail-ua0-f174.google.com [209.85.217.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 715D22199D
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 02:58:09 +0000 (UTC)
Received: by mail-ua0-f174.google.com with SMTP id z22so3631776uah.1
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 19:58:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1706211159430.2328@nanos>
References: <cover.1498022414.git.luto@kernel.org> <a8cdfbbb17785aed10980d24692745f68615a584.1498022414.git.luto@kernel.org>
 <alpine.DEB.2.20.1706211159430.2328@nanos>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 21 Jun 2017 19:57:47 -0700
Message-ID: <CALCETrUrwyMt+k4a-Tyh85Xiidr3zgEW7LKLnGDz90Z6jL9XtA@mail.gmail.com>
Subject: Re: [PATCH v3 11/11] x86/mm: Try to preserve old TLB entries using PCID
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Jun 21, 2017 at 6:38 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Tue, 20 Jun 2017, Andy Lutomirski wrote:
>> This patch uses PCID differently.  We use a PCID to identify a
>> recently-used mm on a per-cpu basis.  An mm has no fixed PCID
>> binding at all; instead, we give it a fresh PCID each time it's
>> loaded except in cases where we want to preserve the TLB, in which
>> case we reuse a recent value.
>>
>> This seems to save about 100ns on context switches between mms.
>
> Depending on the work load I assume. For a CPU switching between a large
> number of processes consecutively it won't make a change. In fact it will
> be slower due to the extra few cycles required for rotating the asid, but I
> doubt that this can be measured.

True.  I suspect this can be improved -- see below.

>
>> +/*
>> + * 6 because 6 should be plenty and struct tlb_state will fit in
>> + * two cache lines.
>> + */
>> +#define NR_DYNAMIC_ASIDS 6
>
> That requires a conditional branch
>
>         if (asid >= NR_DYNAMIC_ASIDS) {
>                 asid = 0;
>                 ....
>         }
>
> The question is whether 4 IDs would be sufficient which trades the branch
> for a mask operation. Or you go for 8 and spend another cache line.

Interesting.  I'm inclined to either leave it at 6 or reduce it to 4
for now and to optimize later.

>
>>  atomic64_t last_mm_ctx_id = ATOMIC64_INIT(1);
>>
>> +static void choose_new_asid(struct mm_struct *next, u64 next_tlb_gen,
>> +                         u16 *new_asid, bool *need_flush)
>> +{
>> +     u16 asid;
>> +
>> +     if (!static_cpu_has(X86_FEATURE_PCID)) {
>> +             *new_asid = 0;
>> +             *need_flush = true;
>> +             return;
>> +     }
>> +
>> +     for (asid = 0; asid < NR_DYNAMIC_ASIDS; asid++) {
>> +             if (this_cpu_read(cpu_tlbstate.ctxs[asid].ctx_id) !=
>> +                 next->context.ctx_id)
>> +                     continue;
>> +
>> +             *new_asid = asid;
>> +             *need_flush = (this_cpu_read(cpu_tlbstate.ctxs[asid].tlb_gen) <
>> +                            next_tlb_gen);
>> +             return;
>> +     }
>
> Hmm. So this loop needs to be taken unconditionally even if the task stays
> on the same CPU. And of course the number of dynamic IDs has to be short in
> order to makes this loop suck performance wise.
>
> Something like the completely disfunctional below might be worthwhile to
> explore. At least arch/x86/mm/ compiles :)
>
> It gets rid of the loop search and lifts the limit of dynamic ids by
> trading it with a percpu variable in mm_context_t.

That would work, but it would take a lot more memory on large systems
with lots of processes, and I'd also be concerned that we might run
out of dynamic percpu space.

How about a different idea: make the percpu data structure look like a
4-way set associative cache.  The ctxs array could be, say, 1024
entries long without using crazy amounts of memory.  We'd divide it
into 256 buckets, so you'd index it like ctxs[4*bucket + slot].  For
each mm, we choose a random bucket (from 0 through 256), and then we'd
just loop over the four slots in the bucket in choose_asid().  This
would require very slightly more arithmetic (I'd guess only one or two
cycles, though) but, critically, wouldn't touch any more cachelines.

The downside of both of these approaches over the one in this patch is
that the change that the percpu cacheline we need is not in the cache
is quite a bit higher since it's potentially a different cacheline for
each mm.  It would probably still be a win because avoiding the flush
is really quite valuable.

What do you think?  The added code would be tiny.

(P.S. Why doesn't random_p32() try arch_random_int()?)

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
