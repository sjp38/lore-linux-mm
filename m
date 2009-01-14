Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 883256B0055
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 08:44:46 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 13so275478fge.4
        for <linux-mm@kvack.org>; Wed, 14 Jan 2009 05:44:44 -0800 (PST)
Message-ID: <84144f020901140544v56b856a4w80756b90f5b59f26@mail.gmail.com>
Date: Wed, 14 Jan 2009 15:44:44 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <20090114114707.GA24673@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20090114090449.GE2942@wotan.suse.de>
	 <84144f020901140253s72995188vb35a79501c38eaa3@mail.gmail.com>
	 <20090114114707.GA24673@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Wed, Jan 14, 2009 at 1:47 PM, Nick Piggin <npiggin@suse.de> wrote:
> The core allocator algorithms are so completely different that it is
> obviously as different from SLUB as SLUB is from SLAB (apart from peripheral
> support code and code structure). So it may as well be a patch against
> SLAB.
>
> I will also prefer to maintain it myself because as I've said I don't
> really agree with choices made in SLUB (and ergo SLUB developers don't
> agree with SLQB).

Just for the record, I am only interesting in getting rid of SLAB (and
SLOB if we can serve the embedded folks as well in the future, sorry
Matt). Now, if that means we have to replace SLUB with SLQB, I am fine
with that. Judging from the SLAB -> SLUB experience, though, I am not
so sure adding a completely separate allocator is the way to get
there.

On Wed, Jan 14, 2009 at 1:47 PM, Nick Piggin <npiggin@suse.de> wrote:
> Note that I'm not trying to be nasty here. Of course I raised objections
> to things I don't like, and I don't think I'm right by default. Just IMO
> SLUB has some problems. As do SLAB and SLQB of course. Nothing is
> perfect.
>
> Also, I don't want to propose replacing any of the other allocators yet,
> until more performance data is gathered. People need to compare each one.
> SLQB definitely is not a clear winner in all tests. At the moment I want
> to see healthy competition and hopefully one day decide on just one of
> the main 3.

OK, then it is really up to Andrew and Linus to decide whether they
want to merge it or not. I'm not violently against it, it's just that
there's some maintenance overhead for API changes and for external
code like kmemcheck, kmemtrace, and failslab, that need hooks in the
slab allocator.

On Wed, Jan 14, 2009 at 1:47 PM, Nick Piggin <npiggin@suse.de> wrote:
>> One thing that puzzles me a bit is that in addition to the struct
>> kmem_cache_list caching, I also see things like cache coloring, avoiding
>> page allocator pass-through, and lots of prefetch hints in the code
>> which makes evaluating the performance differences quite difficult. If
>> these optimizations *are* a win, then why don't we add them to SLUB?
>
> I don't know. I don't have enough time of day to work on SLQB enough,
> let alone attempt to do all this for SLUB as well. Especially when I
> think there are fundamental problems with the basic design of it.
>
> None of those optimisations you mention really showed a noticable win
> anywhere (except avoiding page allocator pass-through perhaps, simply
> because that is not an optimisation, rather it would be a de-optimisation
> to *add* page allocator pass-through for SLQB, so maybe it would aslow
> down some loads).
>
> Cache colouring was just brought over from SLAB. prefetching was done
> by looking at cache misses generally, and attempting to reduce them.
> But you end up barely making a significant difference or just pushing
> the cost elsewhere really. Down to the level of prefetching it is
> going to hugely depend on the exact behaviour of the workload and
> the allocator.

As far as I understood, the prefetch optimizations can produce
unexpected results on some systems (yes, bit of hand-waving here), so
I would consider ripping them out. Even if cache coloring isn't a huge
win on most systems, it's probably not going to hurt either.

On Wed, Jan 14, 2009 at 1:47 PM, Nick Piggin <npiggin@suse.de> wrote:
>> A completely different topic is memory efficiency of SLQB. The current
>> situation is that SLOB out-performs SLAB by huge margin whereas SLUB is
>> usually quite close. With the introduction of kmemtrace, I'm hopeful
>> that we will be able to fix up many of the badly fitting allocations in
>> the kernel to narrow the gap between SLUB and SLOB even more and I worry
>> SLQB will take us back to the SLAB numbers.
>
> Fundamentally it is more like SLOB and SLUB in that it uses object
> pointers and can allocate down to very small sizes. It doesn't have
> O(NR_CPUS^2) type behaviours or preallocated array caches like SLAB.
> I didn't look closely at memory efficiency, but I have no reason to
> think it would be a problem.

Right, that's nice to hear.

On Wed, Jan 14, 2009 at 1:47 PM, Nick Piggin <npiggin@suse.de> wrote:
>> > +/*
>> > + * slqb_page overloads struct page, and is used to manage some slob allocation
>> > + * aspects, however to avoid the horrible mess in include/linux/mm_types.h,
>> > + * we'll just define our own struct slqb_page type variant here.
>> > + */
>>
>> You say horrible mess, I say convenient. I think it's good that core vm
>> hackers who have no interest in the slab allocator can clearly see we're
>> overloading some of the struct page fields.
>
> Yeah, but you can't really. There are so many places that overload them
> for different things and don't tell you about it right in that file. But
> it mostly works because we have nice layering and compartmentalisation.
>
> Anyway IIRC my initial patches to do some of these conversions actually
> either put the definitions into mm_types.h or at least added references
> to them in mm_types.h. It is the better way to go really because you get
> better type checking and it is readable. You may say the horrible mess is
> readable. Barely. Imagine how it would be if we put everything in there.

Well, if we only had one slab allocator... But yeah, point taken.

On Wed, Jan 14, 2009 at 1:47 PM, Nick Piggin <npiggin@suse.de> wrote:
>> > +   object = page->freelist;
>> > +   page->freelist = get_freepointer(s, object);
>> > +   if (page->freelist)
>> > +           prefetchw(page->freelist);
>>
>> I don't understand this prefetchw(). Who exactly is going to be updating
>> contents of page->freelist?
>
> Again, it is for the next allocation. This was shown to reduce cache
> misses here in IIRC tbench, but I'm not sure if that translated to a
> significant performance improvement.

I'm not sure why you would want to optimize for the next allocation. I
mean, I'd expect us to optimize for the kmalloc() + do some work +
kfree() case where prefetching is likely to hurt more than help. Not
that I have any numbers on this.

                                       Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
