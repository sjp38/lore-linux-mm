Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id F05F46B0044
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 06:17:57 -0500 (EST)
Date: Mon, 26 Nov 2012 12:17:54 +0100
From: Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>
Subject: Re: [PATCH] mm,vmscan: only loop back if compaction would fail in
 all zones
Message-ID: <20121126121754.1ae3b0f2@fem.tu-ilmenau.de>
In-Reply-To: <20121126041041.GD2799@cmpxchg.org>
References: <20121119202152.4B0E420004E@hpza10.eem.corp.google.com>
	<20121125175728.3db4ac6a@fem.tu-ilmenau.de>
	<20121125132950.11b15e38@annuminas.surriel.com>
	<20121125224433.GB2799@cmpxchg.org>
	<20121125191645.0ebc6d59@annuminas.surriel.com>
	<20121126031518.GC2799@cmpxchg.org>
	<20121126041041.GD2799@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, mgorman@suse.de, Valdis.Kletnieks@vt.edu, jirislaby@gmail.com, jslaby@suse.cz, zkabelac@redhat.com, mm-commits@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

Am Sun, 25 Nov 2012 23:10:41 -0500
schrieb Johannes Weiner <hannes@cmpxchg.org>:

> On Sun, Nov 25, 2012 at 10:15:18PM -0500, Johannes Weiner wrote:
> > On Sun, Nov 25, 2012 at 07:16:45PM -0500, Rik van Riel wrote:
> > > On Sun, 25 Nov 2012 17:44:33 -0500
> > > Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > > On Sun, Nov 25, 2012 at 01:29:50PM -0500, Rik van Riel wrote:
> > > 
> > > > > Could you try this patch?
> > > > 
> > > > It's not quite enough because it's not reaching the conditions
> > > > you changed, see analysis in
> > > > https://lkml.org/lkml/2012/11/20/567
> > > 
> > > Johannes,
> > > 
> > > does the patch below fix your problem?
> > 
> > I can not reproduce the problem anymore with my smoke test.
> > 
> > > I suspect it would, because kswapd should only ever run into this
> > > particular problem when we have a tiny memory zone in a pgdat,
> > > and in that case we will also have a larger zone nearby, where
> > > compaction would just succeed.
> > 
> > What if there is a higher order GFP_DMA allocation when the other
> > zones in the system meet the high watermark for this order?
> > 
> > There is something else that worries me: if the preliminary zone
> > scan finds the high watermark of all zones alright, end_zone is at
> > its initialization value, 0.  The final compaction loop at `if
> > (order)' goes through all zones up to and including end_zone, which
> > was never really set to anything meaningful(?) and the only zone
> > considered is the DMA zone again.  Very unlikely, granted, but if
> > you'd ever hit that race and kswapd gets stuck, this will be fun to
> > debug...
> 
> I actually liked your first idea better: force reclaim until the
> compaction watermark is met.  The only problem was that still not
> every check in there agreed when the zone was considered balanced and
> so no actual reclaim happened.
> 
> So how about making everybody agree?  If the high watermark is met but
> not the compaction one, keep doing reclaim AND don't consider the zone
> balanced, AND don't make it contribute to balanced_pages etc.?  This
> makes sure reclaim really does not bail and that the node is never
> considered alright when it's actually not according to compaction.
> This patch fixes the problem too (at least for the smoke test so far)
> and IMO makes the code a bit more understandable.
> 
> We may be able to drop some of the relooping conditions.  We may also
> be able to reduce the pressure from the DMA zone by passing the right
> classzone_idx in there.  Needs more thought.
> 
> ---
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch] mm: vmscan: fix endless loop in kswapd balancing
> 
> Kswapd does not in all places have the same criteria for when it
> considers a zone balanced.  This leads to zones being not reclaimed
> because they are considered just fine and the compaction checks to
> loop over the zonelist again because they are considered unbalanced,
> causing kswapd to run forever.
> 
> Add a function, zone_balanced(), that checks the watermark and if
> compaction has enough free memory to do its job.  Then use it
> uniformly for when kswapd needs to check if a zone is balanced.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/vmscan.c | 27 ++++++++++++++++++---------
>  1 file changed, 18 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 48550c6..3b0aef4 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2397,6 +2397,19 @@ static void age_active_anon(struct zone *zone,
> struct scan_control *sc) } while (memcg);
>  }
>  
> +static bool zone_balanced(struct zone *zone, int order,
> +			  unsigned long balance_gap, int
> classzone_idx) +{
> +	if (!zone_watermark_ok_safe(zone, order,
> high_wmark_pages(zone) +
> +				    balance_gap, classzone_idx, 0))
> +		return false;
> +
> +	if (COMPACTION_BUILD && order && !compaction_suitable(zone,
> order))
> +		return false;
> +
> +	return true;
> +}
> +
>  /*
>   * pgdat_balanced is used when checking if a node is balanced for
> high-order
>   * allocations. Only zones that meet watermarks and are in a zone
> allowed @@ -2475,8 +2488,7 @@ static bool
> prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
> continue; }
>  
> -		if (!zone_watermark_ok_safe(zone, order,
> high_wmark_pages(zone),
> -							i, 0))
> +		if (!zone_balanced(zone, order, 0, i))
>  			all_zones_ok = false;
>  		else
>  			balanced += zone->present_pages;
> @@ -2585,8 +2597,7 @@ static unsigned long balance_pgdat(pg_data_t
> *pgdat, int order, break;
>  			}
>  
> -			if (!zone_watermark_ok_safe(zone, order,
> -					high_wmark_pages(zone), 0,
> 0)) {
> +			if (!zone_balanced(zone, order, 0, 0)) {
>  				end_zone = i;
>  				break;
>  			} else {
> @@ -2662,9 +2673,8 @@ static unsigned long balance_pgdat(pg_data_t
> *pgdat, int order, testorder = 0;
>  
>  			if ((buffer_heads_over_limit &&
> is_highmem_idx(i)) ||
> -				    !zone_watermark_ok_safe(zone,
> testorder,
> -					high_wmark_pages(zone) +
> balance_gap,
> -					end_zone, 0)) {
> +			    !zone_balanced(zone, testorder,
> +					   balance_gap, end_zone)) {
>  				shrink_zone(zone, &sc);
>  
>  				reclaim_state->reclaimed_slab = 0;
> @@ -2691,8 +2701,7 @@ static unsigned long balance_pgdat(pg_data_t
> *pgdat, int order, continue;
>  			}
>  
> -			if (!zone_watermark_ok_safe(zone, testorder,
> -					high_wmark_pages(zone),
> end_zone, 0)) {
> +			if (!zone_balanced(zone, testorder, 0,
> end_zone)) { all_zones_ok = 0;
>  				/*
>  				 * We are still under min water
> mark.  This

I've tested both patches, this one and Riks, and they both seem to fix
the problem. kswapd didn't came up again consuming that much CPU. Feel
free to add my tested-by.

regards,
  Johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
