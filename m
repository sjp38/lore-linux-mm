Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2ECDD6B0047
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 08:19:57 -0400 (EDT)
Date: Wed, 1 Sep 2010 14:19:51 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] Make is_mem_section_removable more conformable with
 offlining code
Message-ID: <20100901121951.GC6663@tiehlicka.suse.cz>
References: <20100820141400.GD4636@tiehlicka.suse.cz>
 <20100822004232.GA11007@localhost>
 <20100823092246.GA25772@tiehlicka.suse.cz>
 <20100831141942.GA30353@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100831141942.GA30353@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kleen, Andi" <andi.kleen@intel.com>, Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue 31-08-10 22:19:42, Wu Fengguang wrote:
> On Mon, Aug 23, 2010 at 05:22:46PM +0800, Michal Hocko wrote:
> > On Sun 22-08-10 08:42:32, Wu Fengguang wrote:
> > > Hi Michal,
> > 
> > Hi,
> > 
> > > 
> > > It helps to explain in changelog/code
> > > 
> > > - in what situation a ZONE_MOVABLE will contain !MIGRATE_MOVABLE
> > >   pages? 
> > 
> > page can be MIGRATE_RESERVE IIUC.
> 
> Yup, it may also be set to MIGRATE_ISOLATE by soft_offline_page().

Doesn't it make sense to check for !MIGRATE_UNMOVABLE then?

> 
> > >   And why the MIGRATE_MOVABLE test is still necessary given the
> > >   ZONE_MOVABLE check?
> > 
> > I would assume that the MIGRATE_MOVABLE test is not necessary (given that
> > the whole zone is set as movable) but this test is used also in the
> > offlining path (in set_migratetype_isolate) and the primary reason for
> > this patch is to sync those two checks. 
> 
> Merge the two checks into an inline function?

This sounds reasonable. I will update my patch as soon as I find a
proper place for the function (I guess include/linux/mmzone.h is the
best place).

> 
> > I am not familiar with all the possible cases for migrate flags so the
> > test reduction should be better done by someone more familiar with the
> > code (the zone flag test is much more easier than the whole
> > get_pageblock_migratetype so this could be a win in the end).
> 
> Feel free to swap the order of tests :)
> 
> > > 
> > > - why do you think free pages are not removeable? Simply to cater for
> > >   the set_migratetype_isolate() logic, or there are more fundamental
> > >   reasons?
> > 
> > Free pages can be from non movable zone, right? I know that having a
> > zone with the free page blocks in non-movable zone is extremely 
> > improbable but what is the point of this check anyway? So yes, this is
> > more to be in sync than anything more fundamental.
> 
> You don't have strong reasons to remove the free pages test, so why
> not keep it? 

OK, I think I do understand the free pages test. It just says that
everyting that is free is potentially movable by definition because
nobody uses this memory, right?

> We never know what the user will do. He may regretted
> immediately after onlining a node, and want to offline it..  Some
> hackers may want to offline some 128MB memory blocks (by chance) with
> the help of drop_caches.

I am not sure I understand what you are saying here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
