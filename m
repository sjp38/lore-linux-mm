Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8DAEE6B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 09:08:30 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id f198so144873898wme.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 06:08:30 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id y184si18343277wme.54.2016.04.11.06.08.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 06:08:29 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id B67861C19A5
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 14:08:28 +0100 (IST)
Date: Mon, 11 Apr 2016 14:08:27 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle facility?
Message-ID: <20160411130826.GB32073@techsingularity.net>
References: <1460034425.20949.7.camel@HansenPartnership.com>
 <20160407161715.52635cac@redhat.com>
 <20160411085819.GE21128@suse.de>
 <20160411142639.1c5e520b@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160411142639.1c5e520b@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Brenden Blanco <bblanco@plumgrid.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Tom Herbert <tom@herbertland.com>, lsf-pc@lists.linux-foundation.org, Alexei Starovoitov <alexei.starovoitov@gmail.com>

On Mon, Apr 11, 2016 at 02:26:39PM +0200, Jesper Dangaard Brouer wrote:
> > Which bottleneck dominates -- the page allocator or the DMA API when
> > setting up coherent pages?
> >
> 
> It is actually both, but mostly DMA on non-x86 archs.  The need to
> support multiple archs, then also cause a slowdown on x86, due to a
> side-effect.
> 
> On arch's like PowerPC, the DMA API is the bottleneck.  To workaround
> the cost of DMA calls, NIC driver alloc large order (compound) pages.
> (dma_map compound page, handout page-fragments for RX ring, and later
> dma_unmap when last RX page-fragments is seen).
> 

So, IMO only holding onto the DMA pages is all that is justified but not a
recycle of order-0 pages built on top of the core allocator. For DMA pages,
it would take a bit of legwork but the per-cpu allocator could be split
and converted to hold arbitrary sized pages with a constructer/destructor
to do the DMA coherency step when pages are taken from or handed back to
the core allocator. I'm not volunteering to do that unfortunately but I
estimate it'd be a few days work unless it needs to be per-CPU and NUMA
aware in which case the memory footprint will be high.

> > I'm wary of another page allocator API being introduced if it's for
> > performance reasons. In response to this thread, I spent two days on
> > a series that boosts performance of the allocator in the fast paths by
> > 11-18% to illustrate that there was low-hanging fruit for optimising. If
> > the one-LRU-per-node series was applied on top, there would be a further
> > boost to performance on the allocation side. It could be further boosted
> > if debugging checks and statistic updates were conditionally disabled by
> > the caller.
> 
> It is always great if you can optimized the page allocator.  IMHO the
> page allocator is too slow.

It's why I spent some time on it as any improvement in the allocator is
an unconditional win without requiring driver modifications.

> At least for my performance needs (67ns
> per packet, approx 201 cycles at 3GHz).  I've measured[1]
> alloc_pages(order=0) + __free_pages() to cost 277 cycles(tsc).
> 

It'd be worth retrying this with the branch

http://git.kernel.org/cgit/linux/kernel/git/mel/linux.git/log/?h=mm-vmscan-node-lru-v4r5

This is an unreleased series that contains both the page allocator
optimisations and the one-LRU-per-node series which in combination remove a
lot of code from the page allocator fast paths. I have no data on how the
combined series behaves but each series individually is known to improve
page allocator performance.

Once you have that, do a hackjob to remove the debugging checks from both the
alloc and free path and see what that leaves. They could be bypassed properly
with a __GFP_NOACCT flag used only by drivers that absolutely require pages
as quickly as possible and willing to be less safe to get that performance.

I expect then that the free path to be dominated by zone and pageblock
lookups which are much harder to remove. The zone lookup can be removed
if the caller knows exactly where the free pages need to go which is
unlikely. The pageblock lookup could be removed if it was coming from a
dedicated pool if the allocation side refills using pageblocks that are
always MIGRATE_UNMOVABLE.

> The trick described above, of allocating a higher order page and
> handing out page-fragments, also workaround this page allocator
> bottleneck (on x86).
> 

Be aware that compound order allocs like this are a double edged sword as
it'll be fast sometimes and other times require reclaim/compaction which
can stall for prolonged periods of time.

> I've measured order 3 (32KB) alloc_pages(order=3) + __free_pages() to
> cost approx 500 cycles(tsc).  That was more expensive, BUT an order=3
> page 32Kb correspond to 8 pages (32768/4096), thus 500/8 = 62.5
> cycles.  Usually a network RX-frame only need to be 2048 bytes, thus
> the "bulk" effect speed up is x16 (32768/2048), thus 31.25 cycles.
> 
> I view this as a bulking trick... maybe the page allocator can just
> give us a bulking API? ;-)
> 

It could on the alloc side relatively easily using either a variation of
rmqueue_bulk exposed at a higher level populating a linked list (link via
page->lru) or an array supplied by the caller.  It's harder to bulk free
quickly as the pages being freed are not necessarily in the same pageblock
requiring lookups in the free path.

Tricky to get right, but preferable to a whole new allocator.

> > The main reason another allocator concerns me is that those pages
> > are effectively pinned and cannot be reclaimed by the VM in low memory
> > situations. It ends up needing its own API for tuning the size and hoping
> > all the drivers get it right without causing OOM situations. It becomes
> > a slippery slope of introducing shrinkers, locking and complexity. Then
> > callers start getting concerned about NUMA locality and having to deal
> > with multiple lists to maintain performance. Ultimately, it ends up being
> > as slow as the page allocator and back to square 1 except now with more code.
> 
> The pages assigned to the RX ring queue are pinned like today.  The
> pages avail in the pool could easily be reclaimed.
> 

How easy depends on how it's structured. If it's a global per-cpu list
then it's an IPI to all CPUs which is straight-forward to implement but
slow to execute. If it's per-driver then there needs to be a locked list
of all pools and locking on each individual pool which could offset some
of the performance benefit of using the pool in the first place.

> I actually think we are better off providing a generic page pool
> interface the drivers can use.  Instead of the situation where drivers
> and subsystems invent their own, which does not cooperate in OOM
> situations.
> 

If it's offsetting DMA setup/teardown then I'd be a bit happier. If it's
yet-another-page allocator to bypass the core allocator then I'm less happy.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
