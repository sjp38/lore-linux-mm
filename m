Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 682786B0033
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 08:26:53 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so8842626pad.23
        for <linux-mm@kvack.org>; Fri, 12 Jul 2013 05:26:52 -0700 (PDT)
Message-ID: <51DFF5FD.8040007@gmail.com>
Date: Fri, 12 Jul 2013 06:26:37 -0600
From: Hush Bensen <hush.bensen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/7] mm: compaction: add compaction to zone_reclaim_mode
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com> <1370445037-24144-8-git-send-email-aarcange@redhat.com> <20130606100503.GH1936@suse.de> <20130711160216.GA30320@redhat.com>
In-Reply-To: <20130711160216.GA30320@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>

ao? 2013/7/11 10:02, Andrea Arcangeli a??e??:
> On Thu, Jun 06, 2013 at 11:05:03AM +0100, Mel Gorman wrote:
>> Again be mindful that improved reliability of zone_reclaim_mode can come
>> at the cost of stalling and process interference for workloads where the
>> processes are not NUMA aware or fit in individual nodes.
> This won't risk to affect any system where NUMA locality is a
> secondary priority, unless zone_reclaim_mode is set to 1 manually, so
> it shall be ok.
>
>> Instead of moving the logic from zone_reclaim to here, why was the
>> compaction logic not moved to zone_reclaim or a separate function? This
>> patch adds a lot of logic to get_page_from_freelist() which is unused
>> for most users
> I can try to move all checks that aren't passing information
> across different passes from the caller to the callee.
>
>>> -			default:
>>> -				/* did we reclaim enough */
>>> +
>>> +			/*
>>> +			 * We're going to do reclaim so allow
>>> +			 * allocations up to the MIN watermark, so less
>>> +			 * concurrent allocation will fail.
>>> +			 */
>>> +			mark = min_wmark_pages(zone);
>>> +
>> If we arrived here from the page allocator fast path then it also means
>> that we potentially miss going into the slow patch and waking kswapd. If
>> kswapd is not woken at the low watermark as normal then there will be
>> stalls due to direct reclaim and the stalls will be abrupt.
> What is going on here without my changes is something like this:
>
> 1)   hit low wmark
> 2)   zone_reclaim()
> 3)   check if we're above low wmark
> 4)   if yes alloc memory
> 5)   if no try the next zone in the zonelist
>
> The current code is already fully synchronous in direct reclaim in the
> way it calls zone_reclaim and kswapd never gets invoked anyway.
>
> This isn't VM reclaim, we're not globally low on memory and we can't
> wake kswapd until we expired all memory from all zones or we risk to
> screw the lru rotation even further (by having kswapd and the thread

What's the meaning of lru rotation?

> allocating memory racing in a single zone, not even a single node
> which would at least be better).
>
> But the current code totally lack any kind oaf hysteresis. If
> zone_reclaim provides feedback and confirms it did progress, and
> another CPU steals the page before the current CPU has a chance to get
> it, we're going to fall in the wrong zone (point 5 above). Allowing to
> go deeper in to the "min" wmark won't change anything in kswapd wake
> cycle, and we'll still invoke zone_reclaim synchronously forever until
> the "low wmark" is restored so over time we should still linger above
> the low wmark over time. So we should still wake kswapd well before
> all zones are at the "min" (the moment all zones are below "low" we'll
> wake kswapd).
>
> So it shouldn't regress in terms of "stalls", zone_reclai is already
> fully synchronous. It should only reduce a lot the numa allocation
> false negatives. The need of hysteresis that the min wmark check
> fixes, is exactly related the generation of more than 1 hugepage
> between low-min wmarks in previous patches that altered the wmark
> calculation for high order allocations.
>
> BTW, I improved that calculation further in the meanwhile to avoid
> generating any hugepage below the min wmark (min becomes in the order
>> 0 checks, for any order > 0). You'll see it in next submit.
> Ideally in fact zone_reclaim should get a per-node zonelist, not just
> a zone, to be more fair in the lru rotations. All this code is pretty
> bad. Not trying to fix it all at once (sticking to passing a zone
> instead of a node to zone_reclaim even if it's wrong in lru terms). In
> order to pass a node to zone_reclaim I should completely drop the
> numa_zonelist_order=z mode (which happens to be the default on my
> hardware according to the flakey heuristic in default_zonelist_order()
> which should be also entirely dropped).
>
> Johannes roundrobin allocator that makes the lru rotations more fair
> in a multi-LRU VM, will completely invalidate any benefit provided by
> the (default on my NUMA hardware) numa_zonelist_order=z model. So
> that's one more reason to nuke that whole zonelist order =n badness.
>
> I introduced long time ago a lowmem reserve ratio, that is the thing
> that is supposed to avoid the OOM conditions with shortage of lowmem
> zones. We don't need to prioritize anymore on the zones that are
> aren't usable by all allocations. lowmem reserve provides a
> significant margin. And the roundrobin allocator will entirely depend
> on the lowmem reserve alone to be safe. In fact we should also add
> some lowmem reserve calculation to compaction free memory checks to be
> more accurate. (low priority)
>
>>> +			/* initialize to avoid warnings */
>>> +			c_ret = COMPACT_SKIPPED;
>>> +			ret = ZONE_RECLAIM_FULL;
>>> +
>>> +			repeated_compaction = false;
>>> +			need_compaction = false;
>>> +			if (!compaction_deferred(preferred_zone, order))
>>> +				need_compaction = order &&
>>> +					(gfp_mask & GFP_KERNEL) == GFP_KERNEL;
>> need_compaction = order will always be true. Because of the bracketing,
>> the comparison is within the conditional block so the second comparison
>> is doing nothing. Not sure what is going on there at all.
> if order is zero, need_compaction will be false. If order is not zero,
> need_compaction will be true only if it's a GFP_KERNEL
> allocation. Maybe I'm missing something, I don't see how
> need_compaction is true if order is 0 or if gfp_mask is GFP_ATOMIC.
>
>>> +			if (need_compaction) {
>>> +			repeat_compaction:
>>> +				c_ret = compact_zone_order(zone, order,
>>> +							   gfp_mask,
>>> +							   repeated_compaction,
>>> +							   &contended);
>>> +				if (c_ret != COMPACT_SKIPPED &&
>>> +				    zone_watermark_ok(zone, order, mark,
>>> +						      classzone_idx,
>>> +						      alloc_flags)) {
>>> +#ifdef CONFIG_COMPACTION
>>> +					preferred_zone->compact_considered = 0;
>>> +					preferred_zone->compact_defer_shift = 0;
>>> +#endif
>>> +					goto try_this_zone;
>>> +				}
>>> +			}
>> It's a question of taste, but overall I think this could have been done in
>> zone_reclaim and rename it to zone_reclaim_compact to match the concept
>> of reclaim/compaction if you like. Split the compaction part out to have
>> __zone_reclaim and __zone_compact if you like and it'll be hell of a lot
>> easier to follow. Right now, it's a bit twisty and while I can follow it,
>> it's headache inducing.
> I'll try to move it in a callee function and clean it up.
>
>> With that arrangement it will be a lot easier to add a new zone_reclaim
>> flag if it turns out that zone reclaim compacts too aggressively leading
>> to excessive stalls. Right now, I think this loops in compaction until
>> it gets deferred because of how need_compaction gets set which could be
>> for a long time. I'm not sure that's what you intended.
> I intended to shrink until we successfully shrink cache (zone_reclaim
> won't unmap if zone_reclaim_mode == 1 etc...), until compaction has
> enough free memory to do its work. It shouldn't require that much
> memory. After compaction has enough memory (not return COMPACT_SKIPPED
> anymore) then we stop calling zone_reclaim to shrink caches and we
> just try compaction once.
>
> This is the last patch I need to update before resending, I hope to
> clean it up for good.
>
> Thanks!
> Andrea
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
