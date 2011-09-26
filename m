Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 76AD19000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 09:23:24 -0400 (EDT)
Date: Mon, 26 Sep 2011 15:23:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch]mm: initialize zone all_unreclaimable
Message-ID: <20110926132320.GA4206@tiehlicka.suse.cz>
References: <1317024712.29510.178.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1317024712.29510.178.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

On Mon 26-09-11 16:11:52, Shaohua Li wrote:
> I saw DMA zone is always unreclaimable in my system. 
> zone->all_unreclaimable isn't initialized till a page from the zone is
> freed. This isn't a big problem normally, but a little confused, so
> fix here.

The value is initialized when a node is allocated. setup_node_data uses
alloc_remap which memsets the whole structure or memblock allocation
which is initialized to 0 as well AFAIK and memory hotplug uses
arch_alloc_nodedata which is kzalloc.

> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6e8ecb6..1facc05 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4335,6 +4335,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
>  		zone_pcp_init(zone);
>  		for_each_lru(l)
>  			INIT_LIST_HEAD(&zone->lru[l].list);
> +		zone->all_unreclaimable = 0;
>  		zone->reclaim_stat.recent_rotated[0] = 0;
>  		zone->reclaim_stat.recent_rotated[1] = 0;
>  		zone->reclaim_stat.recent_scanned[0] = 0;
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
