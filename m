Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8E2AC6B004A
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 01:50:20 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o825oHJv003728
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 2 Sep 2010 14:50:17 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0545D45DE53
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 14:50:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CAB7245DE4D
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 14:50:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AE3D51DB803F
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 14:50:16 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 540531DB803C
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 14:50:13 +0900 (JST)
Date: Thu, 2 Sep 2010 14:45:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Make is_mem_section_removable more conformable with
 offlining code
Message-Id: <20100902144500.a0d05b08.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100901124138.GD6663@tiehlicka.suse.cz>
References: <20100820141400.GD4636@tiehlicka.suse.cz>
	<20100822004232.GA11007@localhost>
	<20100823092246.GA25772@tiehlicka.suse.cz>
	<20100831141942.GA30353@localhost>
	<20100901121951.GC6663@tiehlicka.suse.cz>
	<20100901124138.GD6663@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kleen, Andi" <andi.kleen@intel.com>, Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 1 Sep 2010 14:41:38 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Wed 01-09-10 14:19:51, Michal Hocko wrote:
> > On Tue 31-08-10 22:19:42, Wu Fengguang wrote:
> > > On Mon, Aug 23, 2010 at 05:22:46PM +0800, Michal Hocko wrote:
> > > > On Sun 22-08-10 08:42:32, Wu Fengguang wrote:
> > > > > Hi Michal,
> > > > 
> > > > Hi,
> > > > 
> > > > > 
> > > > > It helps to explain in changelog/code
> > > > > 
> > > > > - in what situation a ZONE_MOVABLE will contain !MIGRATE_MOVABLE
> > > > >   pages? 
> > > > 
> > > > page can be MIGRATE_RESERVE IIUC.
> > > 
> > > Yup, it may also be set to MIGRATE_ISOLATE by soft_offline_page().
> > 
> > Doesn't it make sense to check for !MIGRATE_UNMOVABLE then?
> 
> Something like the following patch.
> 
> 
> From de85f1aa42115678d3340f0448cd798577036496 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Fri, 20 Aug 2010 15:39:16 +0200
> Subject: [PATCH] Make is_mem_section_removable more conformable with offlining code
> 
> Currently is_mem_section_removable checks whether each pageblock from
> the given pfn range is of MIGRATE_MOVABLE type or if it is free. If both
> are false then the range is considered non removable.
> 
> On the other hand, offlining code (more specifically
> set_migratetype_isolate) doesn't care whether a page is free and instead
> it just checks the migrate type of the page and whether the page's zone
> is movable.
> 
> This can lead into a situation when we can mark a node as not removable
> just because a pageblock is MIGRATE_RESERVE and it is not free.
> 
> Let's make a common helper is_page_removable which unifies both tests
> at one place. Also let's check for MIGRATE_UNMOVABLE rather than all
> possible MIGRATEable types.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Hmm..Why MIGRATE_RECLAIMABLE is included ?

If MIGRATE_RCLAIMABLE is included, set_migrate_type() should check the
range of pages. Because it makes the pageblock as MIGRAGE_MOVABLE after
failure of memory hotplug.

Original code checks.

 - the range is MIGRAGE_MOVABLE or
 - the range includes only free pages and LRU pages.

Then, moving them back to MIGRAGE_MOVABLE after failure was correct.
Doesn't this makes changes MIGRATE_RECALIMABLE to be MIGRATE_MOVABLE and
leads us to more fragmentated situation ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
