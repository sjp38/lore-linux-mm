Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 904A06B0003
	for <linux-mm@kvack.org>; Sat, 20 Oct 2018 05:00:08 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id h76-v6so34393598pfd.10
        for <linux-mm@kvack.org>; Sat, 20 Oct 2018 02:00:08 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id h185-v6si3782300pge.308.2018.10.20.02.00.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Oct 2018 02:00:07 -0700 (PDT)
Date: Sat, 20 Oct 2018 17:00:02 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC v4 PATCH 2/5] mm/__free_one_page: skip merge for order-0
 page unless compaction failed
Message-ID: <20181020090002.GA13858@intel.com>
References: <20181017063330.15384-1-aaron.lu@intel.com>
 <20181017063330.15384-3-aaron.lu@intel.com>
 <20181017104427.GJ5819@techsingularity.net>
 <20181017131059.GA9167@intel.com>
 <20181017135807.GL5819@techsingularity.net>
 <20181017145904.GC9167@intel.com>
 <20181018111632.GM5819@techsingularity.net>
 <20181019055703.GA2401@intel.com>
 <20181019085435.GR5819@techsingularity.net>
 <20181019150053.iaubsdtcsi64mqb7@ca-dmjordan1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181019150053.iaubsdtcsi64mqb7@ca-dmjordan1.us.oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>, Tariq Toukan <tariqt@mellanox.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Fri, Oct 19, 2018 at 08:00:53AM -0700, Daniel Jordan wrote:
> On Fri, Oct 19, 2018 at 09:54:35AM +0100, Mel Gorman wrote:
> > On Fri, Oct 19, 2018 at 01:57:03PM +0800, Aaron Lu wrote:
> > > > 
> > > > I don't think this is the right way of thinking about it because it's
> > > > possible to have the system split in such a way so that the migration
> > > > scanner only encounters unmovable pages before it meets the free scanner
> > > > where unmerged buddies were in the higher portion of the address space.
> > > 
> > > Yes it is possible unmerged pages are in the higher portion.
> > > 
> > > My understanding is, when the two scanners meet, all unmerged pages will
> > > be either used by the free scanner as migrate targets or sent to merge
> > > by the migration scanner.
> > > 
> > 
> > It's not guaranteed if the lower portion of the address space consisted
> > entirely of pages that cannot migrate (because they are unmovable or because
> > migration failed due to pins). It's actually a fundamental limitation
> > of compaction that it can miss migration and compaction opportunities
> > due to how the scanners are implemented. It was designed that way to
> > avoid pageblocks being migrated unnecessarily back and forth but the
> > downside is missed opportunities.
> > 
> > > > You either need to keep unmerged buddies on a separate list or search
> > > > the order-0 free list for merge candidates prior to compaction.
> > > > 
> > > > > > It's needed to form them efficiently but excessive reclaim or writing 3
> > > > > > to drop_caches can also do it. Be careful of tying lazy buddy too
> > > > > > closely to compaction.
> > > > > 
> > > > > That's the current design of this patchset, do you see any immediate
> > > > > problem of this? Is it that you are worried about high-order allocation
> > > > > success rate using this design?
> > > > 
> > > > I've pointed out what I see are the design flaws but yes, in general, I'm
> > > > worried about the high order allocation success rate using this design,
> > > > the reliance on compaction and the fact that the primary motivation is
> > > > when THP is disabled.
> > > 
> > > When THP is in use, zone lock contention is pretty much nowhere :-)
> > > 
> > > I'll see what I can get with 'address space range' lock first and will
> > > come back to 'lazy buddy' if it doesn't work out.
> 
> With the address space range idea, wouldn't the zone free_area require changes
> too?  I can't see how locking by address range could synchronize it as it
> exists now otherwise, with per order/mt list heads.
> 
> One idea is to further subdivide the free area according to how the locking
> works and find some reasonable way to handle having to search for pages of a
> given order/mt in multiple places.

I plan to create one free_are per 'address space range'. The challenge
will be how to quickly locate a free_area that has the required free
page on allocation path. Other details like how big the address space
range should be etc. will need to be explored with testing.

I think this approach is worth a try because it wouldn't cause
fragmentation.
