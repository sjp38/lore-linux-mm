Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D062F6B01B2
	for <linux-mm@kvack.org>; Thu, 27 May 2010 13:01:12 -0400 (EDT)
Date: Thu, 27 May 2010 11:57:54 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
In-Reply-To: <20100527160728.GT22536@laptop>
Message-ID: <alpine.DEB.2.00.1005271149480.7221@router.home>
References: <20100525020629.GA5087@laptop> <alpine.DEB.2.00.1005250859050.28941@router.home> <20100525143409.GP5087@laptop> <alpine.DEB.2.00.1005250938300.29543@router.home> <20100525151129.GS5087@laptop> <alpine.DEB.2.00.1005251022220.30395@router.home>
 <20100525153759.GA20853@laptop> <alpine.DEB.2.00.1005270919510.5762@router.home> <20100527143754.GR22536@laptop> <alpine.DEB.2.00.1005271037060.7221@router.home> <20100527160728.GT22536@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 28 May 2010, Nick Piggin wrote:

> > > realized that incremental improvements to SLAB would likely be a
> > > far better idea.
> >
> > It looked to me as if there was a major conceptual issue with the linked
> > lists used for objects that impacted performance
>
> With SLQB's linked list? No. Single threaded cache hot performance was
> the same (+/- a couple of cycles IIRC) as SLUB on your microbenchmark.
> On Intel's OLTP workload it was as good as SLAB.
>
> The linked lists were similar to SLOB/SLUB IIRC.

Yes that is the problem. So it did not address the cache cold
regressions in SLUB. SLQB mostly addressed the slow path frequency on
free.

The design of SLAB is superior for cache cold objects since SLAB does
not touch the objects on alloc and free (if one requires similar
cache cold performance from other slab allocators) thats why I cleaned
up the per cpu queueing concept in SLAB (easy now with the percpu
allocator and operations) and came up with SLEB. At the same time this
also addresses the slowpath issues on free. I am not entirely sure how to
deal with the NUMAness but I want to focus more on machines with low node
counts.

The problem with SLAB was that so far the "incremental improvements" have
lead to more deteriorations in the maintainability of the code. There are
multiple people who have tried going this route that you propose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
