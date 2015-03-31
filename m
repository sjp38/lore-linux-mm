Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 252226B0032
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 05:48:34 -0400 (EDT)
Received: by wixo5 with SMTP id o5so7004761wix.1
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 02:48:33 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n14si22854307wjq.60.2015.03.31.02.48.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 31 Mar 2015 02:48:32 -0700 (PDT)
Date: Tue, 31 Mar 2015 11:48:29 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] mm: vmscan: do not throttle based on pfmemalloc
 reserves if node has no reclaimable pages
Message-ID: <20150331094829.GE9589@dhcp22.suse.cz>
References: <20150327192850.GA18701@linux.vnet.ibm.com>
 <5515BAF7.6070604@intel.com>
 <20150327222350.GA22887@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150327222350.GA22887@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, anton@sambar.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dan Streetman <ddstreet@ieee.org>

On Fri 27-03-15 15:23:50, Nishanth Aravamudan wrote:
> On 27.03.2015 [13:17:59 -0700], Dave Hansen wrote:
> > On 03/27/2015 12:28 PM, Nishanth Aravamudan wrote:
> > > @@ -2585,7 +2585,7 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
> > >  
> > >         for (i = 0; i <= ZONE_NORMAL; i++) {
> > >                 zone = &pgdat->node_zones[i];
> > > -               if (!populated_zone(zone))
> > > +               if (!populated_zone(zone) || !zone_reclaimable(zone))
> > >                         continue;
> > >  
> > >                 pfmemalloc_reserve += min_wmark_pages(zone);
> > 
> > Do you really want zone_reclaimable()?  Or do you want something more
> > direct like "zone_reclaimable_pages(zone) == 0"?
> 
> Yeah, I guess in my testing this worked out to be the same, since
> zone_reclaimable_pages(zone) is 0 and so zone_reclaimable(zone) will
> always be false. Thanks!
> 
> Based upon 675becce15 ("mm: vmscan: do not throttle based on pfmemalloc
> reserves if node has no ZONE_NORMAL") from Mel.
> 
> We have a system with the following topology:
> 
> # numactl -H
> available: 3 nodes (0,2-3)
> node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22
> 23 24 25 26 27 28 29 30 31
> node 0 size: 28273 MB
> node 0 free: 27323 MB
> node 2 cpus:
> node 2 size: 16384 MB
> node 2 free: 0 MB
> node 3 cpus: 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47
> node 3 size: 30533 MB
> node 3 free: 13273 MB
> node distances:
> node   0   2   3
>   0:  10  20  20
>   2:  20  10  20
>   3:  20  20  10
> 
> Node 2 has no free memory, because:
> # cat /sys/devices/system/node/node2/hugepages/hugepages-16777216kB/nr_hugepages
> 1
> 
> This leads to the following zoneinfo:
> 
> Node 2, zone      DMA
>   pages free     0
>         min      1840
>         low      2300
>         high     2760
>         scanned  0
>         spanned  262144
>         present  262144
>         managed  262144
> ...
>   all_unreclaimable: 1

Blee, this is a weird configuration.

> If one then attempts to allocate some normal 16M hugepages via
> 
> echo 37 > /proc/sys/vm/nr_hugepages
> 
> The echo never returns and kswapd2 consumes CPU cycles.
> 
> This is because throttle_direct_reclaim ends up calling
> wait_event(pfmemalloc_wait, pfmemalloc_watermark_ok...).
> pfmemalloc_watermark_ok() in turn checks all zones on the node if there
> are any reserves, and if so, then indicates the watermarks are ok, by
> seeing if there are sufficient free pages.
> 
> 675becce15 added a condition already for memoryless nodes. In this case,
> though, the node has memory, it is just all consumed (and not
> reclaimable). Effectively, though, the result is the same on this call
> to pfmemalloc_watermark_ok() and thus seems like a reasonable additional
> condition.
> 
> With this change, the afore-mentioned 16M hugepage allocation attempt
> succeeds and correctly round-robins between Nodes 1 and 3.

I am just wondering whether this is the right/complete fix. Don't we
need a similar treatment at more places?
I would expect kswapd would be looping endlessly because the zone
wouldn't be balanced obviously. But I would be wrong... because
pgdat_balanced is doing this:
		/*
		 * A special case here:
		 *
		 * balance_pgdat() skips over all_unreclaimable after
		 * DEF_PRIORITY. Effectively, it considers them balanced so
		 * they must be considered balanced here as well!
		 */
		if (!zone_reclaimable(zone)) {
			balanced_pages += zone->managed_pages;
			continue;
		}

and zone_reclaimable is false for you as you didn't have any
zone_reclaimable_pages(). But wakeup_kswapd doesn't do this check so it
would see !zone_balanced() AFAICS (build_zonelists doesn't ignore those
zones right?) and so the kswapd would be woken up easily. So it looks
like a mess.

There are possibly other places which rely on populated_zone or
for_each_populated_zone without checking reclaimability. Are those
working as expected?

That being said. I am not objecting to this patch. I am just trying to
wrap my head around possible issues from such a weird configuration and
all the consequences.

> Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>

The patch as is doesn't seem to be harmful.

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
> v1 -> v2:
>   Check against zone_reclaimable_pages, rather zone_reclaimable, based
>   upon feedback from Dave Hansen.

Dunno, but shouldn't we use the same thing here and in pgdat_balanced?
zone_reclaimable_pages seems to be used only from zone_reclaimable().

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 5e8eadd71bac..c627fa4c991f 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2646,7 +2646,8 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
>  
>  	for (i = 0; i <= ZONE_NORMAL; i++) {
>  		zone = &pgdat->node_zones[i];
> -		if (!populated_zone(zone))
> +		if (!populated_zone(zone) ||
> +		    zone_reclaimable_pages(zone) == 0)
>  			continue;
>  
>  		pfmemalloc_reserve += min_wmark_pages(zone);
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
