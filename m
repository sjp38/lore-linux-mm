Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2A1316B01F0
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 10:20:11 -0400 (EDT)
Date: Tue, 31 Aug 2010 22:19:42 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] Make is_mem_section_removable more conformable with
 offlining code
Message-ID: <20100831141942.GA30353@localhost>
References: <20100820141400.GD4636@tiehlicka.suse.cz>
 <20100822004232.GA11007@localhost>
 <20100823092246.GA25772@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100823092246.GA25772@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kleen, Andi" <andi.kleen@intel.com>, Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 23, 2010 at 05:22:46PM +0800, Michal Hocko wrote:
> On Sun 22-08-10 08:42:32, Wu Fengguang wrote:
> > Hi Michal,
> 
> Hi,
> 
> > 
> > It helps to explain in changelog/code
> > 
> > - in what situation a ZONE_MOVABLE will contain !MIGRATE_MOVABLE
> >   pages? 
> 
> page can be MIGRATE_RESERVE IIUC.

Yup, it may also be set to MIGRATE_ISOLATE by soft_offline_page().

> >   And why the MIGRATE_MOVABLE test is still necessary given the
> >   ZONE_MOVABLE check?
> 
> I would assume that the MIGRATE_MOVABLE test is not necessary (given that
> the whole zone is set as movable) but this test is used also in the
> offlining path (in set_migratetype_isolate) and the primary reason for
> this patch is to sync those two checks. 

Merge the two checks into an inline function?

> I am not familiar with all the possible cases for migrate flags so the
> test reduction should be better done by someone more familiar with the
> code (the zone flag test is much more easier than the whole
> get_pageblock_migratetype so this could be a win in the end).

Feel free to swap the order of tests :)

> > 
> > - why do you think free pages are not removeable? Simply to cater for
> >   the set_migratetype_isolate() logic, or there are more fundamental
> >   reasons?
> 
> Free pages can be from non movable zone, right? I know that having a
> zone with the free page blocks in non-movable zone is extremely 
> improbable but what is the point of this check anyway? So yes, this is
> more to be in sync than anything more fundamental.

You don't have strong reasons to remove the free pages test, so why
not keep it? We never know what the user will do. He may regretted
immediately after onlining a node, and want to offline it..  Some
hackers may want to offline some 128MB memory blocks (by chance) with
the help of drop_caches.

Thanks,
Fengguang

> > On Fri, Aug 20, 2010 at 04:14:00PM +0200, Michal Hocko wrote:
> > > Hi,
> > > what do you think about the patch below?
> > > 
> > > >From b983695b92b5be58f31c719fada1d3245f7b6768 Mon Sep 17 00:00:00 2001
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
> > > This can lead into a situation when a node is marked as removable even
> > > though all pages are neither MIGRATE_MOVABLE nor the zone is
> > > ZONE_MOVABLE.
> > > 
> > > Also we can mark a node as not removable just because a pageblock is
> > > MIGRATE_RESERVE and not free (and this situation is much more probable).
> > > ---
> > >  mm/memory_hotplug.c |    6 +++---
> > >  1 files changed, 3 insertions(+), 3 deletions(-)
> > > 
> > > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > > index a4cfcdc..da20568 100644
> > > --- a/mm/memory_hotplug.c
> > > +++ b/mm/memory_hotplug.c
> > > @@ -611,10 +611,10 @@ int is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
> > >  		type = get_pageblock_migratetype(page);
> > >  
> > >  		/*
> > > -		 * A pageblock containing MOVABLE or free pages is considered
> > > -		 * removable
> > > +		 * A pageblock containing MOVABLE or page from movable
> > > +		 * zone are considered removable
> > >  		 */
> > > -		if (type != MIGRATE_MOVABLE && !pageblock_free(page))
> > > +		if (type != MIGRATE_MOVABLE && zone_idx(page) != ZONE_MOVABLE)
> > >  			return 0;
> > >  
> > >  		/*
> > > -- 
> > > 1.7.1
> > > 
> > > 
> > > -- 
> > > Michal Hocko
> > > L3 team 
> > > SUSE LINUX s.r.o.
> > > Lihovarska 1060/12
> > > 190 00 Praha 9    
> > > Czech Republic
> > > 
> > > --
> > > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > > the body to majordomo@kvack.org.  For more info on Linux MM,
> > > see: http://www.linux-mm.org/ .
> > > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> -- 
> Michal Hocko
> L3 team 
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9    
> Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
