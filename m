Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 877B56B0008
	for <linux-mm@kvack.org>; Wed, 23 May 2018 05:28:04 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id d82-v6so2088097wmd.4
        for <linux-mm@kvack.org>; Wed, 23 May 2018 02:28:04 -0700 (PDT)
Received: from techadventures.net (techadventures.net. [62.201.165.239])
        by mx.google.com with ESMTP id v16-v6si16548846wrv.356.2018.05.23.02.28.03
        for <linux-mm@kvack.org>;
        Wed, 23 May 2018 02:28:03 -0700 (PDT)
Date: Wed, 23 May 2018 11:28:02 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC] Checking for error code in __offline_pages
Message-ID: <20180523092802.GB31306@techadventures.net>
References: <20180523073547.GA29266@techadventures.net>
 <20180523075239.GF20441@dhcp22.suse.cz>
 <20180523081609.GG20441@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523081609.GG20441@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, vbabka@suse.cz, pasha.tatashin@oracle.com, akpm@linux-foundation.org

On Wed, May 23, 2018 at 10:16:09AM +0200, Michal Hocko wrote:
> On Wed 23-05-18 09:52:39, Michal Hocko wrote:
> [...]
> > Yeah, the current code is far from optimal. We
> > used to have a retry count but that one was removed exactly because of
> > premature failures. There are three things here
> > 1) zone_movable should contain any bootmem or otherwise non-migrateable
> >    pages
> > 2) start_isolate_page_range should fail when seeing such pages - maybe
> >    has_unmovable_pages is overly optimistic and it should check all
> >    pages even in movable zones.
> > 3) migrate_pages should really tell us whether the failure is temporal
> >    or permanent. I am not sure we can do that easily though.
> 
> 2) should be the most simple one for now. Could you give it a try? Btw.
> the exact configuration that led to boothmem pages in zone_movable would
> be really appreciated:
> --- 
> From 6aa144a9b1c01255c89a4592221d706ccc4b4eea Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Wed, 23 May 2018 10:04:20 +0200
> Subject: [PATCH] mm, memory_hotplug: make has_unmovable_pages more robust
> 
> Oscar has reported:
> : Due to an unfortunate setting with movablecore, memblocks containing bootmem
> : memory (pages marked by get_page_bootmem()) ended up marked in zone_movable.
> : So while trying to remove that memory, the system failed in do_migrate_range
> : and __offline_pages never returned.
> 
> This is because we rely on start_isolate_page_range resp. has_unmovable_pages
> to do their jobb. The first one isolates the whole range to be offlined
> so that we do not allocate from it anymore and the later makes sure we
> are not stumbling over non-migrateable pages.
> 
> has_unmovable_pages is overly optimistic, however. It doesn't check all
> the pages if we are withing zone_movable because we rely that those
> pages will be always migrateable. As it turns out we are still not
> perfect there. While bootmem pages in zonemovable sound like a clear bug
> which should be fixed let's remove the optimization for now and warn if
> we encounter unmovable pages in zone_movable in the meantime. That
> should help for now at least.
> 
> Btw. this wasn't a real problem until 72b39cfc4d75 ("mm, memory_hotplug:
> do not fail offlining too early") because we used to have a small number
> of retries and then failed. This turned out to be too fragile though.
> 
> Reported-by: Oscar Salvador <osalvador@techadventures.net>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/page_alloc.c | 16 ++++++++++------
>  1 file changed, 10 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3c6f4008ea55..b9a45753244d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7629,11 +7629,12 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  	unsigned long pfn, iter, found;
>  
>  	/*
> -	 * For avoiding noise data, lru_add_drain_all() should be called
> -	 * If ZONE_MOVABLE, the zone never contains unmovable pages
> +	 * TODO we could make this much more efficient by not checking every
> +	 * page in the range if we know all of them are in MOVABLE_ZONE and
> +	 * that the movable zone guarantees that pages are migratable but
> +	 * the later is not the case right now unfortunatelly. E.g. movablecore
> +	 * can still lead to having bootmem allocations in zone_movable.
>  	 */
> -	if (zone_idx(zone) == ZONE_MOVABLE)
> -		return false;
>  
>  	/*
>  	 * CMA allocations (alloc_contig_range) really need to mark isolate
> @@ -7654,7 +7655,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  		page = pfn_to_page(check);
>  
>  		if (PageReserved(page))
> -			return true;
> +			goto unmovable;
>  
>  		/*
>  		 * Hugepages are not in LRU lists, but they're movable.
> @@ -7704,9 +7705,12 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  		 * page at boot.
>  		 */
>  		if (found > count)
> -			return true;
> +			goto unmovable;
>  	}
>  	return false;
> +unmovable:
> +	WARN_ON_ONCE(zone_idx(zone) == ZONE_MOVABLE);
> +	return true;
>  }
>  
>  #if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
> -- 
> 2.17.0

Tested-by: Oscar Salvador <osalvador@techadventures.net>

thanks!
Oscar Salvador
