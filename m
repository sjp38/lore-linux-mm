Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 252EC6B0087
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 16:07:34 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id d23so1311427fga.8
        for <linux-mm@kvack.org>; Tue, 24 Nov 2009 13:07:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1259090615.17871.696.camel@calx>
References: <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com>
	 <1258729748.4104.223.camel@laptop>
	 <1259002800.5630.1.camel@penberg-laptop>
	 <1259003425.17871.328.camel@calx> <4B0ADEF5.9040001@cs.helsinki.fi>
	 <1259080406.4531.1645.camel@laptop>
	 <20091124170032.GC6831@linux.vnet.ibm.com>
	 <1259082756.17871.607.camel@calx> <1259086459.4531.1752.camel@laptop>
	 <1259090615.17871.696.camel@calx>
Date: Tue, 24 Nov 2009 23:07:30 +0200
Message-ID: <84144f020911241307u14cd2cf0h614827137e42378e@mail.gmail.com>
Subject: Re: lockdep complaints in slab allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: Peter Zijlstra <peterz@infradead.org>, paulmck@linux.vnet.ibm.com, linux-mm@kvack.org, cl@linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 24, 2009 at 9:23 PM, Matt Mackall <mpm@selenic.com> wrote:
> On Tue, 2009-11-24 at 19:14 +0100, Peter Zijlstra wrote:
>> On Tue, 2009-11-24 at 11:12 -0600, Matt Mackall wrote:
>> > On Tue, 2009-11-24 at 09:00 -0800, Paul E. McKenney wrote:
>> > > On Tue, Nov 24, 2009 at 05:33:26PM +0100, Peter Zijlstra wrote:
>> > > > On Mon, 2009-11-23 at 21:13 +0200, Pekka Enberg wrote:
>> > > > > Matt Mackall wrote:
>> > > > > > This seems like a lot of work to paper over a lockdep false positive in
>> > > > > > code that should be firmly in the maintenance end of its lifecycle? I'd
>> > > > > > rather the fix or papering over happen in lockdep.
>> > > > >
>> > > > > True that. Is __raw_spin_lock() out of question, Peter?-) Passing the
>> > > > > state is pretty invasive because of the kmem_cache_free() call in
>> > > > > slab_destroy(). We re-enter the slab allocator from the outer edges
>> > > > > which makes spin_lock_nested() very inconvenient.
>> > > >
>> > > > I'm perfectly fine with letting the thing be as it is, its apparently
>> > > > not something that triggers very often, and since slab will be killed
>> > > > off soon, who cares.
>> > >
>> > > Which of the alternatives to slab should I be testing with, then?
>> >
>> > I'm guessing your system is in the minority that has more than $10 worth
>> > of RAM, which means you should probably be evaluating SLUB.
>>
>> Well, I was rather hoping that'd die too ;-)
>>
>> Weren't we going to go with SLQB?
>
> News to me. Perhaps it was discussed at KS.

Yes, we discussed this at KS. The plan was to merge SLQB to mainline
so people can test it more easily but unfortunately it hasn't gotten
any loving from Nick recently which makes me think it's going to miss
the merge window for .33 as well.

> My understanding of the current state of play is:
>
> SLUB: default allocator
> SLAB: deep maintenance, will be removed if SLUB ever covers remaining
> performance regressions
> SLOB: useful for low-end (but high-volume!) embedded
> SLQB: sitting in slab.git#for-next for months, has some ground to cover
>
> SLQB and SLUB have pretty similar target audiences, so I agree we should
> eventually have only one of them. But I strongly expect performance
> results to be mixed, just as they have been comparing SLUB/SLAB.
> Similarly, SLQB still has of room for tuning left compared to SLUB, as
> SLUB did compared to SLAB when it first emerged. It might be a while
> before a clear winner emerges.

Yeah, something like that. I don't think we were really able to decide
anything at the KS. IIRC Christoph was in favor of having multiple
slab allocators in the tree whereas I, for example, would rather have
only one. The SLOB allocator is bit special here because it's for
embedded. However, I also talked to some embedded folks at the summit
and none of them were using SLOB because the gains weren't big enough.
So I don't know if it's being used that widely.

I personally was hoping for SLUB or SLQB to emerge as a clear winner
so we could delete the rest but that hasn't really happened.

                         Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
