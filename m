Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id EA97A6B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 20:01:00 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id c10-v6so13349546iob.11
        for <linux-mm@kvack.org>; Mon, 21 May 2018 17:01:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z201-v6sor8410954ioe.142.2018.05.21.17.00.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 May 2018 17:00:59 -0700 (PDT)
MIME-Version: 1.0
References: <CAKOZuetOD6MkGPVvYFLj5RXh200FaDyu3sQqZviVRhTFFS3fjA@mail.gmail.com>
 <aacd607f-4a0d-2b0a-d8d9-b57c686d24fc@intel.com> <CAKOZuetDX905PeLt5cs7e_maSeKHrP0DgM1Kr3vvOb-+n=a7Gw@mail.gmail.com>
 <e6bdfa05-fa80-41d1-7b1d-51cf7e4ac9a1@intel.com> <CAKOZuev=Pa6FkvxTPbeA1CcYG+oF2JM+JVL5ELHLZ--7wyr++g@mail.gmail.com>
 <20eeca79-0813-a921-8b86-4c2a0c98a1a1@intel.com> <CAKOZuesoh7svdmdNY9md3N+vWGurigDLZ5_xDjwgU=uYdKkwqg@mail.gmail.com>
 <2e7fb27e-90b4-38d2-8ae1-d575d62c5332@intel.com> <CAKOZueu8ckN1b-cYOxPhL5f7Bdq+LLRP20NK3x7Vtw79oUT3pg@mail.gmail.com>
 <20c9acc2-fbaf-f02d-19d7-2498f875e4c0@intel.com>
In-Reply-To: <20c9acc2-fbaf-f02d-19d7-2498f875e4c0@intel.com>
From: Daniel Colascione <dancol@google.com>
Date: Mon, 21 May 2018 17:00:47 -0700
Message-ID: <CAKOZuesScfm_5=2FYurY3ojdhQtcwPWY+=hayJ5cG7pQU1LP9g@mail.gmail.com>
Subject: Re: Why do we let munmap fail?
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: linux-mm@kvack.org, Tim Murray <timmurray@google.com>, Minchan Kim <minchan@kernel.org>

On Mon, May 21, 2018 at 4:32 PM Dave Hansen <dave.hansen@intel.com> wrote:

> On 05/21/2018 04:16 PM, Daniel Colascione wrote:
> > On Mon, May 21, 2018 at 4:02 PM Dave Hansen <dave.hansen@intel.com>
wrote:
> >
> >> On 05/21/2018 03:54 PM, Daniel Colascione wrote:
> >>>> There are also certainly denial-of-service concerns if you allow
> >>>> arbitrary numbers of VMAs.  The rbtree, for instance, is O(log(n)),
but
> >>>> I 'd be willing to be there are plenty of things that fall over if
you
> >>>> let the ~65k limit get 10x or 100x larger.
> >>> Sure. I'm receptive to the idea of having *some* VMA limit. I just
think
> >>> it's unacceptable let deallocation routines fail.
> >> If you have a resource limit and deallocation consumes resources, you
> >> *eventually* have to fail a deallocation.  Right?
> > That's why robust software sets aside at allocation time whatever
resources
> > are needed to make forward progress at deallocation time.

> I think there's still a potential dead-end here.  "Deallocation" does
> not always free resources.

Sure, but the general principle applies: reserve resources when you *can*
fail so that you don't fail where you can't fail.

> > That's what I'm trying to propose here, essentially: if we specify
> > the VMA limit in terms of pages and not the number of VMAs, we've
> > effectively "budgeted" for the worst case of VMA splitting, since in
> > the worst case, you end up with one page per VMA.
> Not a bad idea, but it's not really how we allocate VMAs today.  You
> would somehow need per-process (mm?) slabs.  Such a scheme would
> probably, on average, waste half of a page per mm.

> > Done this way, we still prevent runaway VMA tree growth, but we can also
> > make sure that anyone who's successfully called mmap can successfully
call
> > munmap.

> I'd be curious how this works out, but I bet you end up reserving a lot
> more resources than people want.

I'm not sure. We're talking about two separate goals, I think. Goal #1 is
preventing the VMA tree becoming so large that we effectively DoS the
system. Goal #2 is about ensuring that the munmap path can't fail. Right
now, the system only achieves goal #1.

All we have to do to continue to achieve goal #1 is impose *some* sanity
limit on the VMA count, right? It doesn't really matter whether the limit
is specified in pages or number-of-VMAs so long as it's larger than most
applications will need but smaller than the DoS threshold. The resource
we're allocating at mmap time isn't really bytes of
struct-vm_area_struct-backing-storage, but sort of virtual anti-DoS
credits. Right now, these anti-DoS credits are denominated in number of
VMAs, but if we changed the denomination to page counts instead, we'd still
achieve goal #1 while avoiding the munmap-failing-with-ENOMEM weirdness.
Granted, if we make only this change, then munmap internal allocations
*still* fail if the actual VMA allocation failed, but I think the default
kernel OOM killer strategy will suffice for handling this kind of global
extreme memory pressure situation. All we have to do is change the *limit
check* during VMA creation, not the actual allocation strategy.

Another way of looking at it: Linux is usually configured to overcommit
with respect to *commit charge*. This behavior is well-known and widely
understood. What the VMA limit does is effectively overcommit with respect
to *address space*, which is weird and surprising because we normally think
of address space as being strictly accounted. If we can easily and cheaply
make address space actually strictly accounted, why not give it a shot?

Goal #2 is interesting as well, and I think it's what your slab-allocation
proposal would help address. If we literally set aside memory for all
possible VMAs, we'd ensure that internal allocations on the munmap path
could never fail. In the abstract, I'd like that (I'm a fan of strict
commit accounting generally), but I don't think it's necessary for fixing
the problem that motivated this thread.
