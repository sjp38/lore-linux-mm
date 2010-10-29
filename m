Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 196078D0030
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 08:27:18 -0400 (EDT)
Date: Fri, 29 Oct 2010 14:29:28 +0200
From: Andi Kleen <andi.kleen@intel.com>
Subject: Re: [RFC][PATCH 0/3] big chunk memory allocator v2
Message-ID: <20101029122928.GA17792@gargoyle.fritz.box>
References: <20101026190042.57f30338.kamezawa.hiroyu@jp.fujitsu.com>
 <AANLkTim4fFXQKqmFCeR8pvi0SZPXpjDqyOkbV6PYJYkR@mail.gmail.com>
 <op.vlbywq137p4s8u@pikus>
 <20101029103154.GA10823@gargoyle.fritz.box>
 <20101029195900.88559162.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101029195900.88559162.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: =?utf-8?Q?Micha=C5=82?= Nazarewicz <m.nazarewicz@samsung.com>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "fujita.tomonori@lab.ntt.co.jp" <fujita.tomonori@lab.ntt.co.jp>, "felipe.contreras@gmail.com" <felipe.contreras@gmail.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Russell King <linux@arm.linux.org.uk>, Pawel Osciak <pawel@osciak.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 29, 2010 at 11:59:00AM +0100, KAMEZAWA Hiroyuki wrote:
> On Fri, 29 Oct 2010 12:31:54 +0200
> Andi Kleen <andi.kleen@intel.com> wrote:
> 
> > > When I was posting CMA, it had been suggested to create a new migration type
> > > dedicated to contiguous allocations.  I think I already did that and thanks to
> > > this new migration type we have (i) an area of memory that only accepts movable
> > > and reclaimable pages and 
> > 
> > Aka highmem next generation :-(
> > 
> 
> yes. But Nick's new shrink_slab() may be a new help even without
> new zone.

You would really need callbacks into lots of code. Christoph
used to have some patches for directed shrink of dcache/icache,
but they are currently not on the table.

I don't think Nick's patch does that, he simply optimizes the existing
shrinker (which in practice tends to not shrink a lot) to be a bit
less wasteful.

The coverage will never be 100% in any case. So you always have to
make a choice between movable or fully usable. That's essentially
highmem with most of its problems.

> 
> 
> > > (ii) is used only if all other (non-reserved) pages have
> > > been allocated.
> > 
> > That will be near always the case after some uptime, as memory fills up
> > with caches. Unless you do early reclaim? 
> > 
> 
> memory migration always do work with alloc_page() for getting migration target
> pages. So, memory will be reclaimed if filled by cache.

Was talking about that paragraph CMA, not your patch. 

If I understand it correctly CMA wants to define
a new zone which is somehow similar to movable, but only sometimes used
when another zone is full (which is the usual state in normal
operation actually)

It was unclear to me how this was all supposed to work. At least
as described in the paragraph it cannot I think.


> About my patch, I may have to prealloc all required pages before start.
> But I didn't do that at this time.

preallocate when? I thought the whole point of the large memory allocator
was to not have to pre-allocate.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
