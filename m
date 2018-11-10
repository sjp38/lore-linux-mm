Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id D54126B074E
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 19:46:04 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id s141-v6so2296808pgs.23
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 16:46:04 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id u28si8806253pgn.436.2018.11.09.16.46.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 16:46:03 -0800 (PST)
Message-ID: <0d8782742d016565870c578848138aaedf873a7c.camel@linux.intel.com>
Subject: Re: [mm PATCH v5 0/7] Deferred page init improvements
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Fri, 09 Nov 2018 16:46:02 -0800
In-Reply-To: <20181110000006.tmcfnzynelaznn7u@xakep.localdomain>
References: <20181109211521.5ospn33pp552k2xv@xakep.localdomain>
	 <18b6634b912af7b4ec01396a2b0f3b31737c9ea2.camel@linux.intel.com>
	 <20181110000006.tmcfnzynelaznn7u@xakep.localdomain>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@soleen.com>, daniel.m.jordan@oracle.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, davem@davemloft.net, pavel.tatashin@microsoft.com, mhocko@suse.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, dave.jiang@intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org, vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, yi.z.zhang@linux.intel.com

On Fri, 2018-11-09 at 19:00 -0500, Pavel Tatashin wrote:
> On 18-11-09 15:14:35, Alexander Duyck wrote:
> > On Fri, 2018-11-09 at 16:15 -0500, Pavel Tatashin wrote:
> > > On 18-11-05 13:19:25, Alexander Duyck wrote:
> > > > This patchset is essentially a refactor of the page initialization logic
> > > > that is meant to provide for better code reuse while providing a
> > > > significant improvement in deferred page initialization performance.
> > > > 
> > > > In my testing on an x86_64 system with 384GB of RAM and 3TB of persistent
> > > > memory per node I have seen the following. In the case of regular memory
> > > > initialization the deferred init time was decreased from 3.75s to 1.06s on
> > > > average. For the persistent memory the initialization time dropped from
> > > > 24.17s to 19.12s on average. This amounts to a 253% improvement for the
> > > > deferred memory initialization performance, and a 26% improvement in the
> > > > persistent memory initialization performance.
> > > 
> > > Hi Alex,
> > > 
> > > Please try to run your persistent memory init experiment with Daniel's
> > > patches:
> > > 
> > > https://lore.kernel.org/lkml/20181105165558.11698-1-daniel.m.jordan@oracle.com/
> > 
> > I've taken a quick look at it. It seems like a bit of a brute force way
> > to try and speed things up. I would be worried about it potentially
> 
> There is a limit to max number of threads that ktasks start. The memory
> throughput is *much* higher than what one CPU can maxout in a node, so
> there is no reason to leave the other CPUs sit idle during boot when
> they can help to initialize.

Right, but right now that limit can still be pretty big when it is
something like 25% of all the CPUs on a 288 CPU system.

One issue is the way the code was ends up essentially blowing out the
cache over and over again. Doing things in two passes made it really
expensive as you took one cache miss to initialize it, and another to
free it. I think getting rid of that is one of the biggest gains with
my patch set.

> > introducing performance issues if the number of CPUs thrown at it end
> > up exceeding the maximum throughput of the memory.
> > 
> > The data provided with patch 11 seems to point to issues such as that.
> > In the case of the E7-8895 example cited it is increasing the numbers
> > of CPUs used from memory initialization from 8 to 72, a 9x increase in
> > the number of CPUs but it is yeilding only a 3.88x speedup.
> 
> Yes, but in both cases we are far from maxing out the memory throughput.
> The 3.88x is indeed low, and I do not know what slows it down.
> 
> Daniel,
> 
> Could you please check why multi-threading efficiency is so low here?
> 
> I bet, there is some atomic operation introduces a contention within a
> node. It should be possible to resolve.

Depending on what kernel this was based on it probably was something
like SetPageReserved triggering pipeline stalls, or maybe it is freeing
the pages themselves since I would imagine that has a pretty big
overhead an may end up serializing some things.

> > 
> > > The performance should improve by much more than 26%.
> > 
> > The 26% improvement, or speedup of 1.26x using the ktask approach, was
> > for persistent memory, not deferred memory init. The ktask patch
> > doesn't do anything for persistent memory since it is takes the hot-
> > plug path and isn't handled via the deferred memory init.
> 
> Ah, I thought in your experiment persistent memory takes deferred init
> path. So, what exactly in your patches make this 1.26x speedup?

Basically it is the folding of the reserved bit into the setting of the
rest of the values written into the page flags. With that change we are
able to tighten the memory initialization loop to the point where it
almost looks like a memset case as it will put together all of the
memory values outside of the loop and then just loop through assigning
the values for each page.

> > 
> > I had increased deferred memory init to about 3.53x the original speed
> > (3.75s to 1.06s) on the system which I was testing. I do agree the two
> > patches should be able to synergistically boost each other though as
> > this patch set was meant to make the init much more cache friendly so
> > as a result it should scale better as you add additional cores. I know
> > I had done some playing around with fake numa to split up a single node
> > into 8 logical nodes and I had seen a similar speedup of about 3.85x
> > with my test memory initializing in about 275ms.

It is also possible that the the 3.8x is an upper limit for something
on the system in terms of scaling. I just realized that the 3.85x I saw
with an 8 way split over a 4 socket system isn't too different from the
3.88x that was recorded for a 9 way split over an 8 socket system.

> > > Overall, your works looks good, but it needs to be considered how easy it will be
> > > to merge with ktask. I will try to complete the review today.
> > > 
> > > Thank you,
> > > Pasha
> > 
> > Looking over the patches they are still in the RFC stage and the data
> > is in need of updates since it is referencing 4.15-rc kernels as its
> > baseline. If anything I really think the ktask patch 11 would be easier
> > to rebase around my patch set then the other way around. Also, this
> > series is in Andrew's mmots as of a few days ago, so I think it will be
> > in the next mmotm that comes out.
> 
> I do not disagree, I think these two patch series should complement each
> other. But, if your changes make it impossible for ktask, I would strongly argue
> against it, as the potential improvements with ktasks are much higher.
> But, so far I do not see anything, so I think they can work together. I
> am still reviewing your work.

I am assuming patch 11 from the ktask set is the only one that really
touches the deferred memory init. I'm thinking that the actual patch
should be smaller if it is rebased off of this patch set. I didn't see
anything that should conflict with my patch set, and as I said the only
concern would be making certain to split the zone correctly to prevent
the free thread from hopping across the MAX_ORDER boundaries.

> > 
> > The integration with the ktask code should be pretty straight forward.
> > If anything I think my code would probably make it easier since it gets
> > rid of the need to do all this in two passes. The only new limitation
> > it would add is that you would probably want to split up the work along
> > either max order or section aligned boundaries. What it would
> 
> Which is totally OK, it should make ktasks scale even better.

Right.

> > essentially do is make things so that each of the ktask threads would
> > probably look more like deferred_grow_zone which after my patch set is
> > actually a fairly simple function.
> > 
> > Thanks.
> 
> Thank you,
> Pasha
