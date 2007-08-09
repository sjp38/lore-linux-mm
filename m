Date: Thu, 9 Aug 2007 14:37:09 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/4] Embed zone_id information within the zonelist->zones
 pointer
In-Reply-To: <20070809210716.14702.43074.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0708091431560.32324@schroedinger.engr.sgi.com>
References: <20070809210616.14702.73376.sendpatchset@skynet.skynet.ie>
 <20070809210716.14702.43074.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee.Schermerhorn@hp.com, ak@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 9 Aug 2007, Mel Gorman wrote:

>  }
>  
> +#if defined(CONFIG_SMP) && INTERNODE_CACHE_SHIFT > ZONES_SHIFT

Is this necessary? ZONES_SHIFT is always <= 2 so it will work with 
any pointer. Why disable this for UP?

> --- linux-2.6.23-rc1-mm2-010_use_zonelist/mm/vmstat.c	2007-08-07 14:45:11.000000000 +0100
> +++ linux-2.6.23-rc1-mm2-015_zoneid_zonelist/mm/vmstat.c	2007-08-09 15:52:12.000000000 +0100
> @@ -365,11 +365,11 @@ void refresh_cpu_vm_stats(int cpu)
>   */
>  void zone_statistics(struct zonelist *zonelist, struct zone *z)
>  {
> -	if (z->zone_pgdat == zonelist->zones[0]->zone_pgdat) {
> +	if (z->zone_pgdat == zonelist_zone(zonelist->_zones[0])->zone_pgdat) {
>  		__inc_zone_state(z, NUMA_HIT);
>  	} else {
>  		__inc_zone_state(z, NUMA_MISS);
> -		__inc_zone_state(zonelist->zones[0], NUMA_FOREIGN);
> +		__inc_zone_state(zonelist_zone(zonelist->_zones[0]), NUMA_FOREIGN);
>  	}
>  	if (z->node == numa_node_id())
>  		__inc_zone_state(z, NUMA_LOCAL);

Hmmmm. I hope the compiler does subexpression optimization on 

	zonelist_zone(zonelist->_zones[0]) 

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
