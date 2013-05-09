Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 2EB536B0039
	for <linux-mm@kvack.org>; Thu,  9 May 2013 13:27:25 -0400 (EDT)
Date: Thu, 9 May 2013 18:27:21 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 09/22] mm: page allocator: Allocate/free order-0 pages
 from a per-zone magazine
Message-ID: <20130509172721.GG11497@suse.de>
References: <1368028987-8369-1-git-send-email-mgorman@suse.de>
 <1368028987-8369-10-git-send-email-mgorman@suse.de>
 <0000013e85732d03-05e35c8e-205e-4242-98f5-2ae7bda64c5c-000000@email.amazonses.com>
 <20130509152318.GD11497@suse.de>
 <0000013e8a189d6a-efcf99b5-c620-4882-8faf-8187ec243b2c-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <0000013e8a189d6a-efcf99b5-c620-4882-8faf-8187ec243b2c-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, LKML <linux-kernel@vger.kernel.org>

On Thu, May 09, 2013 at 04:21:09PM +0000, Christoph Lameter wrote:
> On Thu, 9 May 2013, Mel Gorman wrote:
> 
> > >
> > > The per cpu structure access also would not need to disable irq if the
> > > fast path would be using this_cpu ops.
> > >
> >
> > How does this_cpu protect against preemption due to interrupt?  this_read()
> > itself only disables preemption and it's explicitly documented that
> > interrupt that modifies the per-cpu data will not be reliable so the use
> > of the per-cpu lists is right out. It would require that a race-prone
> > check be used with cmpxchg which in turn would require arrays, not lists.
> 
> this_cpu uses single atomic instructions that cannot be interrupted. The
> relocation occurs through a segment prefix and therefore is not subject
> to preemption. The interrupts and rescheduling can occur between this_cpu
> ops and there races would have to be dealt with. True using cmpxchg (w/o
> lock semantics) is not that easy. But that is the fastest solution that I
> know of.
> 

And it requires moving to an array so there are going to be strong limits
on the size of the per-cpu queue.

> > I don't see how as the page allocator does not control the physical location
> > of any pages freed to it and it's the struct pages it is linking together. On
> > some systems at least with 1G pages, the struct pages will be backed by
> > memory mapped with 1G entries so the TLB pressure should be reduced but
> > the cache pressure from struct page modifications is certainly a problem.
> 
> I would be useful if the allocator would hand out pages from the
> same physical area first. This would reduce fragmentation as well and
> since it is likely that numerous pages are allocated for some purpose
> (given that that the page sizes of 4k are rather tiny compared to the data
> needs these day) would reduce TLB pressure.
> 

It already does this via the buddy allocator and the treatment of
migratetypes.

> > > > > 3. The magazine_lock is potentially hot but it can be split to have
> > > >    one lock per CPU socket to reduce contention. Draining the lists
> > > >    in this case would acquire multiple locks be acquired.
> > >
> > > IMHO the use of per cpu RMV operations would be lower latency than the use
> > > of spinlocks. There is no "lock" prefix overhead with those. Page
> > > allocation is a frequent operation that I would think needs to be as fast
> > > as possible.
> >
> > The memory requirements may be large because those per-cpu areas sized are
> > allocated depending on num_possible_cpus()s. Correct? Regardless of their
> 
> Yes. But we have lots of memory in machines these days. Why would that be
> an issue?
> 

Because the embedded people will have a fit if the page allocator needs
an additional 1K+ of memory just to turn on.

> > size, it would still be required to deal with cpu hot-plug to avoid memory
> > leaks and draining them would still require global IPIs so the overall
> > code complexity would be similar to what exists today. Ultimately all that
> > changes is that we use an array+cmpxchg instead of a list which will shave
> > a small amount of latency but it will still be regularly falling back to
> > the buddy lists and contend on the zone->lock due the limited size of the
> > per-cpu magazines and hiding the advantage of using cmpxchg in the noise.
> 
> The latency would be an order of magnitude less than the approach that you
> propose here. The magazine approach and the lockless approach both will
> require slowpaths that replenish the set of pages to be served next.
> 

With this approach the lock can be made more fine or coarse based on the
number of CPUs, the queues can be made arbitrarily large and if necessary,
per-process magazines for heavily contended workloads could be added.
A fixed-size array like you propose would be only marginally better than
what is implemented today as far as I can see because it still smacks into
the irq-safe zone->lock and pages can be pinned in inaccessible per-cpu
queues unless a global IPI is sent.

> The problem with the page allocator is that it can serve various types of
> pages. If one wants to setup caches for all of those then these caches are
> replicated for each processor or whatever higher unit we decide to use. I
> think one of the first moves need to be to identify which types of pages
> are actually useful to serve in a fast way. Higher order pages are already
> out but what about the different zone types, migration types etc?
> 

What tpyes of pages are useful to serve in a fast way is workload
dependenat and besides the per-cpu allocator as it exists today already
has separate queues for migration types.

I strongly suspect that your proposal would end up performing roughly the
same as what exists today except that it'll be more complex because it'll
have to deal with the race-prone array accesses.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
