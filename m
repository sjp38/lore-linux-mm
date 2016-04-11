Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 02A4F6B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 15:27:07 -0400 (EDT)
Received: by mail-qk0-f176.google.com with SMTP id n130so2517352qke.3
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 12:27:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s205si21454302qhs.37.2016.04.11.12.27.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 12:27:06 -0700 (PDT)
Date: Mon, 11 Apr 2016 21:26:59 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle
 facility?
Message-ID: <20160411212659.175befaa@redhat.com>
In-Reply-To: <20160411180703.GA27534@suse.de>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	<20160407161715.52635cac@redhat.com>
	<20160411085819.GE21128@suse.de>
	<20160411142639.1c5e520b@redhat.com>
	<20160411130826.GB32073@techsingularity.net>
	<20160411181907.15fdb8b9@redhat.com>
	<20160411180703.GA27534@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Mel Gorman <mgorman@techsingularity.net>, James Bottomley <James.Bottomley@HansenPartnership.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Brenden Blanco <bblanco@plumgrid.com>, lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Tom Herbert <tom@herbertland.com>, lsf-pc@lists.linux-foundation.org, Alexei Starovoitov <alexei.starovoitov@gmail.com>, brouer@redhat.com

On Mon, 11 Apr 2016 19:07:03 +0100
Mel Gorman <mgorman@suse.de> wrote:

> On Mon, Apr 11, 2016 at 06:19:07PM +0200, Jesper Dangaard Brouer wrote:
> > > http://git.kernel.org/cgit/linux/kernel/git/mel/linux.git/log/?h=mm-vmscan-node-lru-v4r5
> > >   
> > 
> > The cost decreased to: 228 cycles(tsc), but there are some variations,
> > sometimes it increase to 238 cycles(tsc).
> >   
> 
> In the free path, a bulk pcp free adds to the cycles. In the alloc path,
> a refill of the pcp lists costs quite a bit. Either option introduces
> variances. The bulk free path can be optimised a little so I chucked
> some additional patches at it that are not released yet but I suspect the
> benefit will be marginal. The real heavy costs there are splitting/merging
> buddies. Fixing that is much more fundamental but even fronting the allocator
> with a new recycle allocator would not offset that as the refill of the
> page-recycling thing would incur high costs.
>

Yes, re-filling page-pool (in the non-steady state) could be
problematic for performance.  That is why I'm very motivated in helping
out with a bulk alloc/free scheme for the page allocator.

 
> > Nice, but there is still a looong way to my performance target, where I
> > can spend 201 cycles for the entire forwarding path....
> >   
> 
> While I accept the cost is still too high, I think the effort should still
> be spent on improving the allocator in general than trying to bypass it.
> 

I do think improving the page allocator is very important work.
I just don't see how we can ever reach my performance target, without a
page-pool recycle facility.

I work in the area, where I think the cost of a single atomic operation
is too high.  I work on amortizing the individual atomic operations.
That is what I did for the SLUB allocator, with the bulk API. see:

Commit d0ecd894e3d5 ("slub: optimize bulk slowpath free by detached freelist")
 https://git.kernel.org/torvalds/c/d0ecd894e3d5

Commit fbd02630c6e3 ("slub: initial bulk free implementation")
 https://git.kernel.org/torvalds/c/fbd02630c6e3
 
This is now also used in the network stack:
 Commit 3134b9f019f2 ("Merge branch 'net-mitigate-kmem_free-slowpath'")
 Commit a3a8749d34d8 ("ixgbe: bulk free SKBs during TX completion cleanup cycle")


> > > This is an unreleased series that contains both the page allocator
> > > optimisations and the one-LRU-per-node series which in combination remove a
> > > lot of code from the page allocator fast paths. I have no data on how the
> > > combined series behaves but each series individually is known to improve
> > > page allocator performance.
> > >
> > > Once you have that, do a hackjob to remove the debugging checks from both the
> > > alloc and free path and see what that leaves. They could be bypassed properly
> > > with a __GFP_NOACCT flag used only by drivers that absolutely require pages
> > > as quickly as possible and willing to be less safe to get that performance.  
> > 
> > I would be interested in testing/benchmarking a patch where you remove
> > the debugging checks...
> >   
> 
> Right now, I'm not proposing to remove the debugging checks despite their
> cost. They catch really difficult problems in the field unfortunately
> including corruption from buggy hardware. A GFP flag that disables them
> for a very specific case would be ok but I expect it to be resisted by
> others if it's done for the general case. Even a static branch for runtime
> debugging checks may be resisted.
> 
> Even if GFP flags are tight, I have a patch that deletes __GFP_COLD on
> the grounds it is of questionable value. Applying that would free a flag
> for __GFP_NOACCT that bypasses debugging checks and statistic updates.
> That would work for the allocation side at least but doing the same for
> the free side would be hard (potentially impossible) to do transparently
> for drivers.

Before spending too much work on something, I usually try to determine
what the maximum benefit of something would be.  Thus, I propose you
create a patch that hack remove all the debug checks that you think
could be beneficial to remove.  And then benchmark it yourself or send
it to me for benchmarking... that is the quickest way to determine if
this is worth spending time on.


 
> > You are also welcome to try out my benchmarking modules yourself:
> >  https://github.com/netoptimizer/prototype-kernel/blob/master/getting_started.rst
> >   
> 
> I took a quick look and functionally it's similar to the systemtap-based
> microbenchmark I'm using in mmtests so I don't think we have a problem
> with reproduction at the moment.
> 
> > > Be aware that compound order allocs like this are a double edged sword as
> > > it'll be fast sometimes and other times require reclaim/compaction which
> > > can stall for prolonged periods of time.  
> > 
> > Yes, I've notice that there can be a fairly high variation, when doing
> > compound order allocs, which is not so nice!  I really don't like these
> > variations....
> >   
> 
> They can cripple you which is why I'm very wary of performance patches that
> require compound pages. It tends to look great only on benchmarks and then
> the corner cases hit in the real world and the bug reports are unpleasant.

That confirms Eric's experience at Google, where they disabled this
compound order page feature in the driver...


> > Drivers also do tricks where they fallback to smaller order pages. E.g.
> > lookup function mlx4_alloc_pages().  I've tried to simulate that
> > function here:
> > https://github.com/netoptimizer/prototype-kernel/blob/91d323fc53/kernel/mm/bench/page_bench01.c#L69
> > 
> > It does not seem very optimal. I tried to mem pressure the system a bit
> > to cause the alloc_pages() to fail, and then the result were very bad,
> > something like 2500 cycles, and it usually got the next order pages.  
> 
> The options for fallback tend to have one hazard after the next. It's
> partially why the last series focused on order-0 pages only.

Other places in the network stack, this falling down through the
order's got removed, and replaced with a single "falldown" to order-0
pages. (due to people reporting bad experiences of latency spikes)

 
> > > > I've measured order 3 (32KB) alloc_pages(order=3) + __free_pages() to
> > > > cost approx 500 cycles(tsc).  That was more expensive, BUT an order=3
> > > > page 32Kb correspond to 8 pages (32768/4096), thus 500/8 = 62.5
> > > > cycles.  Usually a network RX-frame only need to be 2048 bytes, thus
> > > > the "bulk" effect speed up is x16 (32768/2048), thus 31.25 cycles.  
> > 
> > The order=3 cost were reduced to: 417 cycles(tsc), nice!  But I've also
> > seen it jump to 611 cycles.
> >   
> 
> The corner cases can be minimised to some extent -- lazy buddy merging for
> example but it unfortunately has other consequences for users that require
> high-order pages for functional reasons. I tried something like that once
> (http://thread.gmane.org/gmane.linux.kernel/807683) but didn't pursue it
> to the end as it was a small part of the problem I was dealing with at the
> time. It shouldn't be ruled out but it should be considered a last resort.
> 



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
