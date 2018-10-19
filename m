Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 523846B0003
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 11:01:23 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id h10-v6so969597ybc.14
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 08:01:23 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id x187-v6si10140749ybb.370.2018.10.19.08.01.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Oct 2018 08:01:21 -0700 (PDT)
Date: Fri, 19 Oct 2018 08:00:53 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [RFC v4 PATCH 2/5] mm/__free_one_page: skip merge for order-0
 page unless compaction failed
Message-ID: <20181019150053.iaubsdtcsi64mqb7@ca-dmjordan1.us.oracle.com>
References: <20181017063330.15384-1-aaron.lu@intel.com>
 <20181017063330.15384-3-aaron.lu@intel.com>
 <20181017104427.GJ5819@techsingularity.net>
 <20181017131059.GA9167@intel.com>
 <20181017135807.GL5819@techsingularity.net>
 <20181017145904.GC9167@intel.com>
 <20181018111632.GM5819@techsingularity.net>
 <20181019055703.GA2401@intel.com>
 <20181019085435.GR5819@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181019085435.GR5819@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Aaron Lu <aaron.lu@intel.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Fri, Oct 19, 2018 at 09:54:35AM +0100, Mel Gorman wrote:
> On Fri, Oct 19, 2018 at 01:57:03PM +0800, Aaron Lu wrote:
> > > 
> > > I don't think this is the right way of thinking about it because it's
> > > possible to have the system split in such a way so that the migration
> > > scanner only encounters unmovable pages before it meets the free scanner
> > > where unmerged buddies were in the higher portion of the address space.
> > 
> > Yes it is possible unmerged pages are in the higher portion.
> > 
> > My understanding is, when the two scanners meet, all unmerged pages will
> > be either used by the free scanner as migrate targets or sent to merge
> > by the migration scanner.
> > 
> 
> It's not guaranteed if the lower portion of the address space consisted
> entirely of pages that cannot migrate (because they are unmovable or because
> migration failed due to pins). It's actually a fundamental limitation
> of compaction that it can miss migration and compaction opportunities
> due to how the scanners are implemented. It was designed that way to
> avoid pageblocks being migrated unnecessarily back and forth but the
> downside is missed opportunities.
> 
> > > You either need to keep unmerged buddies on a separate list or search
> > > the order-0 free list for merge candidates prior to compaction.
> > > 
> > > > > It's needed to form them efficiently but excessive reclaim or writing 3
> > > > > to drop_caches can also do it. Be careful of tying lazy buddy too
> > > > > closely to compaction.
> > > > 
> > > > That's the current design of this patchset, do you see any immediate
> > > > problem of this? Is it that you are worried about high-order allocation
> > > > success rate using this design?
> > > 
> > > I've pointed out what I see are the design flaws but yes, in general, I'm
> > > worried about the high order allocation success rate using this design,
> > > the reliance on compaction and the fact that the primary motivation is
> > > when THP is disabled.
> > 
> > When THP is in use, zone lock contention is pretty much nowhere :-)
> > 
> > I'll see what I can get with 'address space range' lock first and will
> > come back to 'lazy buddy' if it doesn't work out.

With the address space range idea, wouldn't the zone free_area require changes
too?  I can't see how locking by address range could synchronize it as it
exists now otherwise, with per order/mt list heads.

One idea is to further subdivide the free area according to how the locking
works and find some reasonable way to handle having to search for pages of a
given order/mt in multiple places.
