Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id C168B6B0003
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 22:46:49 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id q18-v6so3325868wrr.12
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 19:46:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u185-v6sor755369wmg.63.2018.07.24.19.46.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 19:46:48 -0700 (PDT)
MIME-Version: 1.0
References: <20180724204639.26934-1-cannonmatthews@google.com> <20180724210923.GA20168@bombadil.infradead.org>
In-Reply-To: <20180724210923.GA20168@bombadil.infradead.org>
From: Cannon Matthews <cannonmatthews@google.com>
Date: Tue, 24 Jul 2018 19:46:36 -0700
Message-ID: <CAJfu=Uf5AgpM9=-+kdk6Cn=kRCUtqMjc38+K0NUSDo-QAS8=jg@mail.gmail.com>
Subject: Re: [PATCH] RFC: clear 1G pages with streaming stores on x86
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org
Cc: mhocko@kernel.org, mike.kravetz@oracle.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andres Lagar-Cavilla <andreslc@google.com>, sqazi@google.com, Paul Turner <pjt@google.com>, David Matlack <dmatlack@google.com>, Peter Feiner <pfeiner@google.com>, nullptr@google.com

On Tue, Jul 24, 2018 at 2:09 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Tue, Jul 24, 2018 at 01:46:39PM -0700, Cannon Matthews wrote:
> > Reimplement clear_gigantic_page() to clear gigabytes pages using the
> > non-temporal streaming store instructions that bypass the cache
> > (movnti), since an entire 1GiB region will not fit in the cache anyway.
> >
> > Doing an mlock() on a 512GiB 1G-hugetlb region previously would take on
> > average 134 seconds, about 260ms/GiB which is quite slow. Using `movnti`
> > and optimizing the control flow over the constituent small pages, this
> > can be improved roughly by a factor of 3-4x, with the 512GiB mlock()
> > taking only 34 seconds on average, or 67ms/GiB.
>
> This is great data ...
Thanks!
>
> > - The calls to cond_resched() have been reduced from between every 4k
> > page to every 64, as between all of the 256K page seemed overly
> > frequent.  Does this seem like an appropriate frequency? On an idle
> > system with many spare CPUs it get's rescheduled typically once or twice
> > out of the 4096 times it calls cond_resched(), which seems like it is
> > maybe the right amount, but more insight from a scheduling/latency point
> > of view would be helpful.
>
> ... which makes the lack of data here disappointing -- what're the
> comparable timings if you do check every 4kB or every 64kB instead of
> every 256kB?

Fair enough, my data was lacking in that axis. I ran a bunch of trials
with different
sizes and included that in the v2 patch description.

TL;DR: It doesn't seem to make a significant difference in
performance, but might
need more trials to know with more confidence.

>
> > The assembly code for the __clear_page_nt routine is more or less
> > taken directly from the output of gcc with -O3 for this function with
> > some tweaks to support arbitrary sizes and moving memory barriers:
> >
> > void clear_page_nt_64i (void *page)
> > {
> >   for (int i = 0; i < GiB /sizeof(long long int); ++i)
> >     {
> >       _mm_stream_si64 (((long long int*)page) + i, 0);
> >     }
> >   sfence();
> > }
> >
> > In general I would love to hear any thoughts and feedback on this
> > approach and any ways it could be improved.
> >
> > Some specific questions:
> >
> > - What is the appropriate method for defining an arch specific
> > implementation like this, is the #ifndef code sufficient, and did stuff
> > land in appropriate files?
> >
> > - Are there any obvious pitfalls or caveats that have not been
> > considered? In particular the iterator over mem_map_next() seemed like a
> > no-op on x86, but looked like it could be important in certain
> > configurations or architectures I am not familiar with.
> >
> > - Are there any x86_64 implementations that do not support SSE2
> > instructions like `movnti` ? What is the appropriate way to detect and
> > code around that if so?
>
> No.  SSE2 was introduced with the Pentium 4, before x86-64.  The XMM
> registers are used as part of the x86-64 calling conventions, so SSE2
> is mandatory for x86-64 implementations.

Awesome, good to know.

>
> > - Is there anything that could be improved about the assembly code? I
> > originally wrote it in C and don't have much experience hand writing x86
> > asm, which seems riddled with optimization pitfalls.
>
> I suspect it might be slightly faster if implemented as inline asm in the
> x86 clear_gigantic_page() implementation instead of a function call.
> Might not affect performance a lot though.

I can try to experiment with that tomorrow. Since the performance doesn't vary
much on an idle machine when you make one function call for the whole GiB
or 256K of them for each 4K page I would suspect it won't matter much.

>
> > - Is the highmem codepath really necessary? would 1GiB pages really be
> > of much use on a highmem system? We recently removed some other parts of
> > the code that support HIGHMEM for gigantic pages (see:
> > http://lkml.kernel.org/r/20180711195913.1294-1-mike.kravetz@oracle.com)
> > so this seems like a logical continuation.
>
> PAE paging doesn't support 1GB pages, so there's no need for it on x86.

Excellent. Do you happen to know if/when it is necessary on any other
architectures?

>
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 7206a634270b..2515cae4af4e 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -70,6 +70,7 @@
> >  #include <linux/dax.h>
> >  #include <linux/oom.h>
> >
> > +
> >  #include <asm/io.h>
> >  #include <asm/mmu_context.h>
> >  #include <asm/pgalloc.h>
>
> Spurious.
>
Thanks for catching that, removed.
