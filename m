Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B80E26B004A
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 05:08:45 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8298hFp004908
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 2 Sep 2010 18:08:43 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 59C3645DE54
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 18:08:43 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BEEA45DE57
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 18:08:43 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EA2991DB8038
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 18:08:42 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8958DE08002
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 18:08:42 +0900 (JST)
Date: Thu, 2 Sep 2010 18:03:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Make is_mem_section_removable more conformable with
 offlining code
Message-Id: <20100902180343.f4232c6e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100902082829.GA10265@tiehlicka.suse.cz>
References: <20100820141400.GD4636@tiehlicka.suse.cz>
	<20100822004232.GA11007@localhost>
	<20100823092246.GA25772@tiehlicka.suse.cz>
	<20100831141942.GA30353@localhost>
	<20100901121951.GC6663@tiehlicka.suse.cz>
	<20100901124138.GD6663@tiehlicka.suse.cz>
	<20100902144500.a0d05b08.kamezawa.hiroyu@jp.fujitsu.com>
	<20100902082829.GA10265@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kleen, Andi" <andi.kleen@intel.com>, Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2 Sep 2010 10:28:29 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Thu 02-09-10 14:45:00, KAMEZAWA Hiroyuki wrote:
> > On Wed, 1 Sep 2010 14:41:38 +0200
> [...]
> > > From de85f1aa42115678d3340f0448cd798577036496 Mon Sep 17 00:00:00 2001
> > > From: Michal Hocko <mhocko@suse.cz>
> > > Date: Fri, 20 Aug 2010 15:39:16 +0200
> > > Subject: [PATCH] Make is_mem_section_removable more conformable with offlining code
> > > 
> > > Currently is_mem_section_removable checks whether each pageblock from
> > > the given pfn range is of MIGRATE_MOVABLE type or if it is free. If both
> > > are false then the range is considered non removable.
> > > 
> > > On the other hand, offlining code (more specifically
> > > set_migratetype_isolate) doesn't care whether a page is free and instead
> > > it just checks the migrate type of the page and whether the page's zone
> > > is movable.
> > > 
> > > This can lead into a situation when we can mark a node as not removable
> > > just because a pageblock is MIGRATE_RESERVE and it is not free.
> > > 
> > > Let's make a common helper is_page_removable which unifies both tests
> > > at one place. Also let's check for MIGRATE_UNMOVABLE rather than all
> > > possible MIGRATEable types.
> > > 
> > > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > 
> > Hmm..Why MIGRATE_RECLAIMABLE is included ?
> 
> AFAIU the code, MIGRATE_RECLAIMABLE are movable as well (at least that
> is how I interpret #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)).
> Why should we prevent from memory offlining if we have some reclaimable
> pages? Or am I totally misinterpreting the meaning of this flag?
> 

RECLAIMABLE cannot be 100% reclaimable. Then, for memory hotlug,
I intentionally skips it and check free_area[] and LRU.


> > 
> > If MIGRATE_RCLAIMABLE is included, set_migrate_type() should check the
> > range of pages. Because it makes the pageblock as MIGRAGE_MOVABLE after
> > failure of memory hotplug.
> > 
> > Original code checks.
> > 
> >  - the range is MIGRAGE_MOVABLE or
> >  - the range includes only free pages and LRU pages.
> > 
> > Then, moving them back to MIGRAGE_MOVABLE after failure was correct.
> > Doesn't this makes changes MIGRATE_RECALIMABLE to be MIGRATE_MOVABLE and
> > leads us to more fragmentated situation ?
> 
> Just to be sure that I understand you concern. We are talking about hot
> remove failure which can lead to higher fragmentation, right? 
> 
right. 

> By the higher fragmentation you mean that all movable pageblocks (even
> reclaimable) gets to MIGRATE_MOVABLE until we get first failure. In the
> worst case, if we fail near the end of the zone then there is imbalance
> in MIGRATE_MOVABLE vs. MIGRATE_RECALIMABLE. Is that what you are
> thinking of? Doesn't this just gets the zone to the state after
> onlining? Or is the problem if we fail somewhere in the middle?
> 

No. My concern is pageblock type changes before/after memory hotplug failure.
	before isolation: MIGRATE_RECLAIMABLE
	after isolation failure : MIGRATE_MOVABLE

Then, the section which was RECALAIMABLE (but caused memory hotplug failure)
turns to be MIGRATE_MOVABLE and will continue to cause memory hotplug failure.
(Because it contains unreclaimable(still-in-use) slab.)

That means memory-hotplug success-rate goes down because of not-important check,
and (your) customer believe "memory hotplug never works well hahaha."

The old code checks RECLAIMABLE pageblock only contains free pages or LRU pages,
In that meaning, MIGRATE_MOVABLE check itself should be removed. It's my fault.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
