Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8DE3D6B0006
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 01:57:09 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id b22-v6so31093876pfc.18
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 22:57:09 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id o12-v6si25080900pfh.9.2018.10.18.22.57.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 22:57:08 -0700 (PDT)
Date: Fri, 19 Oct 2018 13:57:03 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC v4 PATCH 2/5] mm/__free_one_page: skip merge for order-0
 page unless compaction failed
Message-ID: <20181019055703.GA2401@intel.com>
References: <20181017063330.15384-1-aaron.lu@intel.com>
 <20181017063330.15384-3-aaron.lu@intel.com>
 <20181017104427.GJ5819@techsingularity.net>
 <20181017131059.GA9167@intel.com>
 <20181017135807.GL5819@techsingularity.net>
 <20181017145904.GC9167@intel.com>
 <20181018111632.GM5819@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018111632.GM5819@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Thu, Oct 18, 2018 at 12:16:32PM +0100, Mel Gorman wrote:
> On Wed, Oct 17, 2018 at 10:59:04PM +0800, Aaron Lu wrote:
> > > Any particuular reason why? I assume it's related to the number of zone
> > > locks with the increase number of zones and the number of threads used
> > > for the test.
> > 
> > I think so too.
> > 
> > The 4 sockets server has 192 CPUs in total while the 2 sockets server
> > has 112 CPUs in total. Assume only ZONE_NORMAL are used, for the 4
> > sockets server it would be 192/4=48(CPUs per zone) while for the 2
> > sockets server it is 112/2=56(CPUs per zone). The test is started with
> > nr_task=nr_cpu so for the 2 sockets servers, it ends up having more CPUs
> > consuming one zone.
> > 
> 
> Nice that the prediction is accurate. It brings us to another option --
> breaking up the zone lock by either hash or address space ranges. The
> address space ranges would probably be easier to implement. Where it
> gets hairy is that PFN walkers would need different zone locks. However,
> overall it might be a better option because it's not order-0 specific.

I think the 'address space range' lock is worth a try.

> It would be a lot of legwork because all uses of the zone lock would
> have to be audited to see which ones protect the free lists and which
> ones protect "something else".

Yes a lot of details.

> > > That's important to know. It does reduce the utility of the patch
> > > somewhat but not all arches support THP and THP is not always enabled on
> > > x86.
> > 
> > I always wondered how systems are making use of THP.
> > After all, when system has been runing a while(days or months), file
> > cache should consumed a lot of memory and high order pages will become
> > more and more scare. If order9 page can't be reliably allocated, will
> > workload rely on it?
> > Just a thought.
> > 
> 
> File cache can usually be trivially reclaimed and moved. It's a "how
> long is a piece of string" to determine at what point a system can get
> fragmented and whether than can be prevented. It's somewhat outside the
> scope of this patch but anecdotally I'm looking at a machine with 20 days
> uptime and it still has 2390GB worth of THPs free after a large amount
> of reclaim activity over the system lifetime so fragmentation avoidance
> does work in some cases.

Good to know, thanks.

> 
> > THP is of course pretty neat that it reduced TLB cost, needs fewer page
> > table etc. I just wondered if people really rely on it, or using it
> > after their system has been up for a long time.
> > 
> 
> If people didn't rely on it then we might as well delete THP and the
> declare the whole tmpfs-backed-THP as worthless.
> 
> > > Yes, but note that the concept is still problematic.
> > > isolate_migratepages_block is not guaranteed to find a pageblock with
> > > unmerged buddies in it. If there are pageblocks towards the end of the
> > > zone with unmerged pages, they may never be found. This will be very hard
> > > to detect at runtime because it's heavily dependant on the exact state
> > > of the system.
> > 
> > Quite true.
> > 
> > The intent here though, is not to have compaction merge back all
> > unmerged pages, but did the merge for these unmerged pages in a
> > piggyback way, i.e. since isolate_migratepages_block() is doing the
> > scan, why don't we let it handle these unmerged pages when it meets
> > them?
> > 
> > If for some reason isolate_migratepages_block() didn't meet a single
> > unmerged page before compaction succeed, we probably do not need worry
> > much yet since compaction succeeded anyway.
> > 
> 
> I don't think this is the right way of thinking about it because it's
> possible to have the system split in such a way so that the migration
> scanner only encounters unmovable pages before it meets the free scanner
> where unmerged buddies were in the higher portion of the address space.

Yes it is possible unmerged pages are in the higher portion.

My understanding is, when the two scanners meet, all unmerged pages will
be either used by the free scanner as migrate targets or sent to merge
by the migration scanner.

> 
> You either need to keep unmerged buddies on a separate list or search
> the order-0 free list for merge candidates prior to compaction.
> 
> > > It's needed to form them efficiently but excessive reclaim or writing 3
> > > to drop_caches can also do it. Be careful of tying lazy buddy too
> > > closely to compaction.
> > 
> > That's the current design of this patchset, do you see any immediate
> > problem of this? Is it that you are worried about high-order allocation
> > success rate using this design?
> 
> I've pointed out what I see are the design flaws but yes, in general, I'm
> worried about the high order allocation success rate using this design,
> the reliance on compaction and the fact that the primary motivation is
> when THP is disabled.

When THP is in use, zone lock contention is pretty much nowhere :-)

I'll see what I can get with 'address space range' lock first and will
come back to 'lazy buddy' if it doesn't work out. Thank you and
Vlastimil for all the suggestions.
