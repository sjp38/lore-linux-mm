Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id F40E26B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 14:07:09 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id l6so156776378wml.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 11:07:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d62si17986078wme.62.2016.04.11.11.07.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Apr 2016 11:07:08 -0700 (PDT)
Date: Mon, 11 Apr 2016 19:07:03 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle facility?
Message-ID: <20160411180703.GA27534@suse.de>
References: <1460034425.20949.7.camel@HansenPartnership.com>
 <20160407161715.52635cac@redhat.com>
 <20160411085819.GE21128@suse.de>
 <20160411142639.1c5e520b@redhat.com>
 <20160411130826.GB32073@techsingularity.net>
 <20160411181907.15fdb8b9@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160411181907.15fdb8b9@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, James Bottomley <James.Bottomley@HansenPartnership.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Brenden Blanco <bblanco@plumgrid.com>, lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Tom Herbert <tom@herbertland.com>, lsf-pc@lists.linux-foundation.org, Alexei Starovoitov <alexei.starovoitov@gmail.com>

On Mon, Apr 11, 2016 at 06:19:07PM +0200, Jesper Dangaard Brouer wrote:
> > http://git.kernel.org/cgit/linux/kernel/git/mel/linux.git/log/?h=mm-vmscan-node-lru-v4r5
> > 
> 
> The cost decreased to: 228 cycles(tsc), but there are some variations,
> sometimes it increase to 238 cycles(tsc).
> 

In the free path, a bulk pcp free adds to the cycles. In the alloc path,
a refill of the pcp lists costs quite a bit. Either option introduces
variances. The bulk free path can be optimised a little so I chucked
some additional patches at it that are not released yet but I suspect the
benefit will be marginal. The real heavy costs there are splitting/merging
buddies. Fixing that is much more fundamental but even fronting the allocator
with a new recycle allocator would not offset that as the refill of the
page-recycling thing would incur high costs.

> Nice, but there is still a looong way to my performance target, where I
> can spend 201 cycles for the entire forwarding path....
> 

While I accept the cost is still too high, I think the effort should still
be spent on improving the allocator in general than trying to bypass it.

> 
> > This is an unreleased series that contains both the page allocator
> > optimisations and the one-LRU-per-node series which in combination remove a
> > lot of code from the page allocator fast paths. I have no data on how the
> > combined series behaves but each series individually is known to improve
> > page allocator performance.
> >
> > Once you have that, do a hackjob to remove the debugging checks from both the
> > alloc and free path and see what that leaves. They could be bypassed properly
> > with a __GFP_NOACCT flag used only by drivers that absolutely require pages
> > as quickly as possible and willing to be less safe to get that performance.
> 
> I would be interested in testing/benchmarking a patch where you remove
> the debugging checks...
> 

Right now, I'm not proposing to remove the debugging checks despite their
cost. They catch really difficult problems in the field unfortunately
including corruption from buggy hardware. A GFP flag that disables them
for a very specific case would be ok but I expect it to be resisted by
others if it's done for the general case. Even a static branch for runtime
debugging checks may be resisted.

Even if GFP flags are tight, I have a patch that deletes __GFP_COLD on
the grounds it is of questionable value. Applying that would free a flag
for __GFP_NOACCT that bypasses debugging checks and statistic updates.
That would work for the allocation side at least but doing the same for
the free side would be hard (potentially impossible) to do transparently
for drivers.

> You are also welcome to try out my benchmarking modules yourself:
>  https://github.com/netoptimizer/prototype-kernel/blob/master/getting_started.rst
> 

I took a quick look and functionally it's similar to the systemtap-based
microbenchmark I'm using in mmtests so I don't think we have a problem
with reproduction at the moment.

> > Be aware that compound order allocs like this are a double edged sword as
> > it'll be fast sometimes and other times require reclaim/compaction which
> > can stall for prolonged periods of time.
> 
> Yes, I've notice that there can be a fairly high variation, when doing
> compound order allocs, which is not so nice!  I really don't like these
> variations....
> 

They can cripple you which is why I'm very wary of performance patches that
require compound pages. It tends to look great only on benchmarks and then
the corner cases hit in the real world and the bug reports are unpleasant.

> Drivers also do tricks where they fallback to smaller order pages. E.g.
> lookup function mlx4_alloc_pages().  I've tried to simulate that
> function here:
> https://github.com/netoptimizer/prototype-kernel/blob/91d323fc53/kernel/mm/bench/page_bench01.c#L69
> 
> It does not seem very optimal. I tried to mem pressure the system a bit
> to cause the alloc_pages() to fail, and then the result were very bad,
> something like 2500 cycles, and it usually got the next order pages.

The options for fallback tend to have one hazard after the next. It's
partially why the last series focused on order-0 pages only.

> > > I've measured order 3 (32KB) alloc_pages(order=3) + __free_pages() to
> > > cost approx 500 cycles(tsc).  That was more expensive, BUT an order=3
> > > page 32Kb correspond to 8 pages (32768/4096), thus 500/8 = 62.5
> > > cycles.  Usually a network RX-frame only need to be 2048 bytes, thus
> > > the "bulk" effect speed up is x16 (32768/2048), thus 31.25 cycles.
> 
> The order=3 cost were reduced to: 417 cycles(tsc), nice!  But I've also
> seen it jump to 611 cycles.
> 

The corner cases can be minimised to some extent -- lazy buddy merging for
example but it unfortunately has other consequences for users that require
high-order pages for functional reasons. I tried something like that once
(http://thread.gmane.org/gmane.linux.kernel/807683) but didn't pursue it
to the end as it was a small part of the problem I was dealing with at the
time. It shouldn't be ruled out but it should be considered a last resort.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
