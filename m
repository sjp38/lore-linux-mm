Date: Tue, 10 Jul 2007 20:03:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: zone movable patches comments
Message-Id: <20070710200321.e8b38a7a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <469355D4.1070008@shadowen.org>
References: <4691E8D1.4030507@yahoo.com.au>
	<20070709110457.GB9305@skynet.ie>
	<469226CB.4010900@yahoo.com.au>
	<20070709132140.GC9305@skynet.ie>
	<20070710180845.ee1de048.kamezawa.hiroyu@jp.fujitsu.com>
	<469355D4.1070008@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Mel Gorman <mel@skynet.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jul 2007 10:48:04 +0100
Andy Whitcroft <apw@shadowen.org> wrote:


> I would have expected all of the is_zonename() checks to include the
> zone_is_configured() checks, to allow the optimiser to catch on and
> elide the code.
> 
>     if (zone_is_configured(ZONE_DMA32)
> 	return zone == zone->zone_pgdat->node_zones + ZONE_DMA32;
>     else
> 	return 0;
> 
> Perhaps a little helper:
> 
> static inline zone_idx_is(int idx, int target)
> {
> 	if (zone_is_configured(target))
> 		return idx == target;
> 	else
> 		return 0;
> }
> 
Ah, this looks nice. 


> You are able to always assign these as the array is sized on
> MAX_POSSIBLE_ZONES, so I would have thought that these could be
> statically initialised right?
> 
> static char * const zone_names = {
> [ZONE_DMA] = "DMA",
> [ZONE_DMA32] = "DMA32",
> ...
> };
> 
> 
> And in fact if you were to simply size sysctl_lowmem_reserve_ratio at
> MAX_POSSIBLE_ZONES could you not do the same there too?  Then you would
> not need to introduce zone_variables_init().
> 
> int sysctl_lowmem_reserve_ratio[MAX_POSSIBLE_ZONES] = {
> [ZONE_DMA] = 256,
> [ZONE_DMA32] = 256,
> [ZONE_HIGHMEM] = 32
> };
> 
Oh, it's simpler. thank you.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
