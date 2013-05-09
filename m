Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 2C7C56B0039
	for <linux-mm@kvack.org>; Thu,  9 May 2013 14:08:37 -0400 (EDT)
Date: Thu, 9 May 2013 18:08:35 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 09/22] mm: page allocator: Allocate/free order-0 pages
 from a per-zone magazine
In-Reply-To: <20130509172721.GG11497@suse.de>
Message-ID: <0000013e8a7afa80-34067330-12df-4b7e-a2b7-d298c78d3630-000000@email.amazonses.com>
References: <1368028987-8369-1-git-send-email-mgorman@suse.de> <1368028987-8369-10-git-send-email-mgorman@suse.de> <0000013e85732d03-05e35c8e-205e-4242-98f5-2ae7bda64c5c-000000@email.amazonses.com> <20130509152318.GD11497@suse.de>
 <0000013e8a189d6a-efcf99b5-c620-4882-8faf-8187ec243b2c-000000@email.amazonses.com> <20130509172721.GG11497@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, LKML <linux-kernel@vger.kernel.org>

On Thu, 9 May 2013, Mel Gorman wrote:

> > I would be useful if the allocator would hand out pages from the
> > same physical area first. This would reduce fragmentation as well and
> > since it is likely that numerous pages are allocated for some purpose
> > (given that that the page sizes of 4k are rather tiny compared to the data
> > needs these day) would reduce TLB pressure.
> >
>
> It already does this via the buddy allocator and the treatment of
> migratetypes.

Well it only does if it breaks larger sized pages from the buddy
allocator. If large page lists aggregate in the per cpu lists then we have
a LIFO order.

> > Yes. But we have lots of memory in machines these days. Why would that be
> > an issue?
> Because the embedded people will have a fit if the page allocator needs
> an additional 1K+ of memory just to turn on.

Why enlarge the existing per cpu areas? The size could
be restricted if we reduce the types of pages supported and/or if we do
not use double linked lists but single linked lists within say a PMD area.

> With this approach the lock can be made more fine or coarse based on the
> number of CPUs, the queues can be made arbitrarily large and if necessary,
> per-process magazines for heavily contended workloads could be added.

Arbitrarily large queues cause references to pointers all over memory. No
good.

> A fixed-size array like you propose would be only marginally better than
> what is implemented today as far as I can see because it still smacks into
> the irq-safe zone->lock and pages can be pinned in inaccessible per-cpu
> queues unless a global IPI is sent.

We do not send global IPIs but IPIs only to processors that have something
cached.

The fixed size array or constrained single linked list would be better
since it caches better and it is possible to avoid spin lock operations.

> > The problem with the page allocator is that it can serve various types of
> > pages. If one wants to setup caches for all of those then these caches are
> > replicated for each processor or whatever higher unit we decide to use. I
> > think one of the first moves need to be to identify which types of pages
> > are actually useful to serve in a fast way. Higher order pages are already
> > out but what about the different zone types, migration types etc?
> >
>
> What tpyes of pages are useful to serve in a fast way is workload
> dependenat and besides the per-cpu allocator as it exists today already
> has separate queues for migration types.
>
> I strongly suspect that your proposal would end up performing roughly the
> same as what exists today except that it'll be more complex because it'll
> have to deal with the race-prone array accesses.

The problems of the current scheme are the proliferation of page types,
the serving of pages in a random mix from all over memory, the heavy high
latency processing in the "fast" paths (these paths seem to accumulate
more and more procesing in each kernel version) and the disabling of
interrupts (which may be the least latency causing issue).

A solution without using locks cannot simply be a modification of the
existing scheme that you envison. The amount of processing in the fastpaths must be
significantly reduced and the data layout needs to be more cache friendly.
Only with these changes will make the use of fast cpu local instructions
sense.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
