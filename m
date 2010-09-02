Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1756D6B004A
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 05:24:59 -0400 (EDT)
Date: Thu, 2 Sep 2010 11:24:54 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] Make is_mem_section_removable more conformable with
 offlining code
Message-ID: <20100902092454.GA17971@tiehlicka.suse.cz>
References: <20100820141400.GD4636@tiehlicka.suse.cz>
 <20100822004232.GA11007@localhost>
 <20100823092246.GA25772@tiehlicka.suse.cz>
 <20100831141942.GA30353@localhost>
 <20100901121951.GC6663@tiehlicka.suse.cz>
 <20100901124138.GD6663@tiehlicka.suse.cz>
 <20100902144500.a0d05b08.kamezawa.hiroyu@jp.fujitsu.com>
 <20100902082829.GA10265@tiehlicka.suse.cz>
 <20100902180343.f4232c6e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100902180343.f4232c6e.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kleen, Andi" <andi.kleen@intel.com>, Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu 02-09-10 18:03:43, KAMEZAWA Hiroyuki wrote:
> On Thu, 2 Sep 2010 10:28:29 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Thu 02-09-10 14:45:00, KAMEZAWA Hiroyuki wrote:
> > > On Wed, 1 Sep 2010 14:41:38 +0200
> > [...]
> > > > From de85f1aa42115678d3340f0448cd798577036496 Mon Sep 17 00:00:00 2001
> > > > From: Michal Hocko <mhocko@suse.cz>
> > > > Date: Fri, 20 Aug 2010 15:39:16 +0200
> > > > Subject: [PATCH] Make is_mem_section_removable more conformable with offlining code
> > > > 
> > > > Currently is_mem_section_removable checks whether each pageblock from
> > > > the given pfn range is of MIGRATE_MOVABLE type or if it is free. If both
> > > > are false then the range is considered non removable.
> > > > 
> > > > On the other hand, offlining code (more specifically
> > > > set_migratetype_isolate) doesn't care whether a page is free and instead
> > > > it just checks the migrate type of the page and whether the page's zone
> > > > is movable.
> > > > 
> > > > This can lead into a situation when we can mark a node as not removable
> > > > just because a pageblock is MIGRATE_RESERVE and it is not free.
> > > > 
> > > > Let's make a common helper is_page_removable which unifies both tests
> > > > at one place. Also let's check for MIGRATE_UNMOVABLE rather than all
> > > > possible MIGRATEable types.
> > > > 
> > > > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > > 
> > > Hmm..Why MIGRATE_RECLAIMABLE is included ?
> > 
> > AFAIU the code, MIGRATE_RECLAIMABLE are movable as well (at least that
> > is how I interpret #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)).
> > Why should we prevent from memory offlining if we have some reclaimable
> > pages? Or am I totally misinterpreting the meaning of this flag?
> > 
> 
> RECLAIMABLE cannot be 100% reclaimable. 

OK, I see. The name is little bit misleading then. Should we comment
that?

> Then, for memory hotlug,
> I intentionally skips it and check free_area[] and LRU.
> 
> 
> > > 
> > > If MIGRATE_RCLAIMABLE is included, set_migrate_type() should check the
> > > range of pages. Because it makes the pageblock as MIGRAGE_MOVABLE after
> > > failure of memory hotplug.
> > > 
> > > Original code checks.
> > > 
> > >  - the range is MIGRAGE_MOVABLE or
> > >  - the range includes only free pages and LRU pages.
> > > 
> > > Then, moving them back to MIGRAGE_MOVABLE after failure was correct.
> > > Doesn't this makes changes MIGRATE_RECALIMABLE to be MIGRATE_MOVABLE and
> > > leads us to more fragmentated situation ?
> > 
> > Just to be sure that I understand you concern. We are talking about hot
> > remove failure which can lead to higher fragmentation, right? 
> > 
> right. 
> 
> > By the higher fragmentation you mean that all movable pageblocks (even
> > reclaimable) gets to MIGRATE_MOVABLE until we get first failure. In the
> > worst case, if we fail near the end of the zone then there is imbalance
> > in MIGRATE_MOVABLE vs. MIGRATE_RECALIMABLE. Is that what you are
> > thinking of? Doesn't this just gets the zone to the state after
> > onlining? Or is the problem if we fail somewhere in the middle?
> > 
> 
> No. My concern is pageblock type changes before/after memory hotplug failure.
> 	before isolation: MIGRATE_RECLAIMABLE
> 	after isolation failure : MIGRATE_MOVABLE

Ahh, OK I can see your point now. unset_migratetype_isolate called on
the failure path sets migrate type unconditionally as it cannot know
what was the original migration type.

What about MIGRATE_RESERVE? Is there anything that can make those
allocations fail offlining?

Thanks!

> 
> Then, the section which was RECALAIMABLE (but caused memory hotplug failure)
> turns to be MIGRATE_MOVABLE and will continue to cause memory hotplug failure.
> (Because it contains unreclaimable(still-in-use) slab.)
> 
> That means memory-hotplug success-rate goes down because of not-important check,
> and (your) customer believe "memory hotplug never works well hahaha."
> 
> The old code checks RECLAIMABLE pageblock only contains free pages or LRU pages,
> In that meaning, MIGRATE_MOVABLE check itself should be removed. It's my fault.
> 
> 
> Thanks,
> -Kame
> 

-- 
Michal Hocko
L3 team 
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
