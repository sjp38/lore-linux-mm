Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E1936B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 04:09:30 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q68so22081508pgq.11
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 01:09:30 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 102si8903597pld.196.2017.08.28.01.09.28
        for <linux-mm@kvack.org>;
        Mon, 28 Aug 2017 01:09:28 -0700 (PDT)
Date: Mon, 28 Aug 2017 17:09:25 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] mm: Track actual nr_scanned during shrink_slab()
Message-ID: <20170828080925.GB6309@blaptop>
References: <20170815153010.e3cfc177af0b2c0dc421b84c@linux-foundation.org>
 <20170822135325.9191-1-chris@chris-wilson.co.uk>
 <20170824051153.GB13922@bgram>
 <29aae2cd-85a8-f3c4-66e2-4d4f5a2732c1@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <29aae2cd-85a8-f3c4-66e2-4d4f5a2732c1@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mel Gorman <mgorman@techsingularity.net>, Shaohua Li <shli@fb.com>

Hi Vlastimil,

On Thu, Aug 24, 2017 at 10:00:49AM +0200, Vlastimil Babka wrote:
> On 08/24/2017 07:11 AM, Minchan Kim wrote:
> > Hello Chris,
> > 
> > On Tue, Aug 22, 2017 at 02:53:24PM +0100, Chris Wilson wrote:
> >> Some shrinkers may only be able to free a bunch of objects at a time, and
> >> so free more than the requested nr_to_scan in one pass.
> 
> Can such shrinkers reflect that in their shrinker->batch value? Or is it
> unpredictable for each scan?
> 
> >> Whilst other
> >> shrinkers may find themselves even unable to scan as many objects as
> >> they counted, and so underreport. Account for the extra freed/scanned
> >> objects against the total number of objects we intend to scan, otherwise
> >> we may end up penalising the slab far more than intended. Similarly,
> >> we want to add the underperforming scan to the deferred pass so that we
> >> try harder and harder in future passes.
> >>
> >> v2: Andrew's shrinkctl->nr_scanned
> >>
> >> Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> >> Cc: Andrew Morton <akpm@linux-foundation.org>
> >> Cc: Michal Hocko <mhocko@suse.com>
> >> Cc: Johannes Weiner <hannes@cmpxchg.org>
> >> Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
> >> Cc: Minchan Kim <minchan@kernel.org>
> >> Cc: Vlastimil Babka <vbabka@suse.cz>
> >> Cc: Mel Gorman <mgorman@techsingularity.net>
> >> Cc: Shaohua Li <shli@fb.com>
> >> Cc: linux-mm@kvack.org
> >> ---
> >>  include/linux/shrinker.h | 7 +++++++
> >>  mm/vmscan.c              | 7 ++++---
> >>  2 files changed, 11 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
> >> index 4fcacd915d45..51d189615bda 100644
> >> --- a/include/linux/shrinker.h
> >> +++ b/include/linux/shrinker.h
> >> @@ -18,6 +18,13 @@ struct shrink_control {
> >>  	 */
> >>  	unsigned long nr_to_scan;
> >>  
> >> +	/*
> >> +	 * How many objects did scan_objects process?
> >> +	 * This defaults to nr_to_scan before every call, but the callee
> >> +	 * should track its actual progress.
> > 
> > So, if shrinker scans object more than requested, it shoud add up
> > top nr_scanned?
> 
> That sounds fair.
> 
> > opposite case, if shrinker scans less than requested, it should reduce
> > nr_scanned to the value scanned real?
> 
> Unsure. If they can't scan more, the following attempt in the next
> iteration should fail and thus result in SHRINK_STOP?

What should I do if I don't scan anything for some reasons on this iteration
but don't want to stop by SHRINK_STOP because I expect I will scan them
on next iteration? Return 1 on shrinker side? It doesn't make sense.
nr_scanned represents for realy scan value so if shrinker doesn't scan
anything but want to continue the scanning, it can return 0 and VM
should take care of it to prevent infinite loop because shrinker's
expectation can be wrong so it can make the system live-lock.

> 
> > To track the progress is burden for the shrinker users.
> 
> You mean shrinker authors, not users? AFAICS this nr_scanned is opt-in,
> if they don't want to touch it, the default remains nr_to_scan.

I meant shrinker authors which is user for VM shrinker. :-D

Anyway, my point is that shrinker are already racy. IOW, the amount of
objects in a shrinker can be changed between count_object and
scan_object and I'm not sure such micro object tracking based on stale
value will help a lot in every cases.

That means it could be broken interface without guarantee helping
the system as expected.

However, with v1 from Chris, it's low hanging fruit to get without pain
so that's why I wanted to merge v1 rather than v2.

> 
> > Even if a
> > shrinker has a mistake, VM will have big trouble like infinite loop.
> 
> We could fake 0 as 1 or something, at least.

Yes, I think we need it if we want to go this way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
