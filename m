Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 42C776B0069
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 11:24:30 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id 186so68393252yby.5
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 08:24:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l5si3772397ywg.332.2017.01.13.08.24.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 08:24:29 -0800 (PST)
Date: Fri, 13 Jan 2017 17:24:26 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [LSF/MM ATTEND] 2017 userfaultfd-WP, node reclaim vs zone
 compaction, THP
Message-ID: <20170113162426.GA20475@redhat.com>
References: <20170112192611.GO4947@redhat.com>
 <73b60b0a-33c2-739c-3d1e-d74b73f204e9@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <73b60b0a-33c2-739c-3d1e-d74b73f204e9@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Thu, Jan 12, 2017 at 10:58:46PM +0100, Vlastimil Babka wrote:
> On 01/12/2017 08:26 PM, Andrea Arcangeli wrote:
> >    To avoid dropping some patches that implement "compaction aware
> >    zone_reclaim_mode" (i.e. now node_reclaim_mode) I'm still running
> >    with zone LRU, although I don't disagree with the node LRU per se,
> >    my only issue is that compaction still work zone based and that
> >    collides with those changes.
> >
> >    With reclaim working node based and compaction working zone
> >    based, I would need to call a blind for_each_zone(node)
> >    compaction() loop which is far from ideal compared to compaction
> >    crossing the zone boundary.
> 
> Compaction does a lot of watermark checking, which is also per-zone based, so we 
> would likely have to do these for_each_zone() dances for the watermark checks, 
> I'm afraid. At the same time it should make sure that it doesn't exhaust free 
> pages of each single zone below the watermark. The result would look ugly, 
> unless we switch to per-node watermarks.

compaction aware zone_reclaim looks like this:

static int zone_reclaim_compact(struct zone *preferred_zone,
				struct zone *zone, gfp_t gfp_mask,
				unsigned int order,
				bool sync_compaction,
				bool *need_compaction,
				int alloc_flags, int classzone_idx)
{
	if (compaction_deferred(preferred_zone, order) ||
	    !order ||
	    (gfp_mask & (__GFP_FS|__GFP_IO)) != (__GFP_FS|__GFP_IO)) {
		*need_compaction = false;
		return COMPACT_SKIPPED;
	}

	if (!zone_reclaimable(zone))
		return ZONE_RECLAIM_FULL;

	*need_compaction = true;
	return compact_zone_order(zone, order, gfp_mask,
				  sync_compaction ? DEF_COMPACT_PRIORITY :
				  COMPACT_PRIO_ASYNC, alloc_flags,
				  classzone_idx);
}

int zone_reclaim(struct zone *preferred_zone, struct zone *zone,
		 gfp_t gfp_mask, unsigned int order,
		 unsigned long mark, int alloc_flags, int classzone_idx)
{
	int node_id;
	int ret, c_ret;
	bool sync_compaction = false, need_compaction = false;

	/*
	 * Do not scan if the allocation should not be delayed.
	 */
	if (!gfpflags_allow_blocking(gfp_mask) || (current->flags & PF_MEMALLOC))
		return ZONE_RECLAIM_NOSCAN;

	/*
	 * Only run zone reclaim on the local zone or on zones that do not
	 * have associated processors. This will favor the local processor
	 * over remote processors and spread off node memory allocations
	 * as wide as possible.
	 */
	node_id = zone_to_nid(zone);
	if (node_state(node_id, N_CPU) && node_id != numa_node_id())
		return ZONE_RECLAIM_NOSCAN;

repeat_compaction:
	/*
	 * If this allocation may be satisfied by memory compaction,
	 * run compaction before reclaim.
	 */
	c_ret = zone_reclaim_compact(preferred_zone, zone, gfp_mask, order,
				     sync_compaction, &need_compaction,
				     alloc_flags, classzone_idx);
	if (need_compaction &&
	    c_ret != COMPACT_SKIPPED &&
	    zone_watermark_ok(zone, order, mark,
			      classzone_idx,
			      alloc_flags)) {
#ifdef CONFIG_COMPACTION
		zone->compact_considered = 0;
		zone->compact_defer_shift = 0;
#endif
		return ZONE_RECLAIM_SUCCESS;
	}

	/*
	 * reclaim if compaction failed because not enough memory was
	 * available or if compaction didn't run (order 0) or didn't
	 * succeed.
	 */
	ret = __zone_reclaim(zone, gfp_mask, order);
	if (ret == ZONE_RECLAIM_SUCCESS) {
		if (zone_watermark_ok(zone, order, mark,
				      classzone_idx,
				      alloc_flags))
			return ZONE_RECLAIM_SUCCESS;

		/*
		 * If compaction run but it was skipped and reclaim was
		 * successful keep going.
		 */
		if (need_compaction && c_ret == COMPACT_SKIPPED) {
			/*
			 * If it's ok to wait for I/O we can as well run sync
			 * compaction
			 */
			sync_compaction = !!(zone_reclaim_mode &
					     (RECLAIM_WRITE|RECLAIM_UNMAP));
			cond_resched();
			goto repeat_compaction;
		}
	}
	if (need_compaction)
		defer_compaction(preferred_zone, order);

	if (!ret)
		count_vm_event(PGSCAN_ZONE_RECLAIM_FAILED);

	return ret;
}

In principle it's:

repeat_compaction:
   zone_reclaim_compact(zone)
   if still not enough high order pages in zone:
	ret = __zone_reclaim(zone, gfp_mask, order);
	if still not enough high order pages in zone but order 0
	   reclaim was successful and compaction was skipped because
	   not enough order 0 free pages:
	       goto repeat_compaction;
  
And actually this isn't different than what happens all the time just
this has to happen within same reclaim code because zone_reclaim_mode
> 0 requires it to stay aggressively within the node. This is why it
is not ok in this case to invoke compaction only in page_alloc.c
before getting into reclaim, and let reclaim go through the whole
zonelist. zone_reclaim_mode > 0 has to shrink the current node before
it moves to the next node in the zonelist. The zonelist of course must
also be ordered node based for zone_reclaim_mode > 0 (now would be
node_reclaim_mode but zone/node doesn't matter here) to be effective,
with the proper boot option (normally the default).

The watermark mess you mention about doing node-compaction I'm afraid
exists already in turn also breaking stuff. page_alloc.c is not
fundamentally different from the above loop, simply the current
watermark mess will emerge as worsened compaction behavior and it's
not as visible as it gets visible if you try to fix the above
compaction-aware code on the node LRU model.

And I wouldn't be surprised if the bzip2 regression is just because
compaction got worse as result of not being node based when reclaim is
node based, and nobody solved the watermark mess, and instead of a
failure this just results in lower THP utilization.

When compaction fails because of zone watermark checks and you call
reclaim on the node, the zone watermarks don't improve and then
compaction fails again despite you called reclaim in between.

Reclaim has classzone concept so it can concentrate in lower zones
only (i.e. the classzone of the allocation), it won't ever concentrate
on the higher zone only, but that's needed if compaction shall succeed
when tried again on the highest zone. The RAM freed in the lower zones
won't help when compaction can't cross the zone boundary.

So short of doing the blind unconditional for_each_zone(node)
compact_zone() after reclaim succeeds on the node, I'm not sure how
else to fix this fundamental watermark inaccuracy in compaction. If
compaction worked node based and could cross the zone boundary this
watermark mess wouldn't exist, freeing memory in lower zones would
still allow the next invocation of compaction to succeed and see the
freed memory in the lower zones.

> >    Most pages that can be migrated by
> >    compaction can go in any zone, not all but we could record the page
> >    classzone.
> 
> Finding space for that in struct page also wouldn't be easy.

We'd need to find a way not to store that in the page struct indeed.

I'm not sure if that is a concern though, I think that classzone
restriction applies only to some buffer header or extreme cases, that
should be possible to single out by finding they're not standard user
memory or normal pagecache. For example they will have a
page->mapping->gfp_mask too that we can check if needed and will tell
which classzone they're part of. The vast majority of movable memory
can cross the zone boundary with no problem.

I already mentioned this issue once but nothing happened and the idea
of doing a blind for_each_zone() compact_zone() loop to solve this and
then break the loop if compaction succeeded in any of the lower zones
(because node based reclaim actually freed memory in the lower zones),
didn't feel optimal. However if you're sure that's the way to go I'll
have to think some more about it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
