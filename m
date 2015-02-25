Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 047026B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 07:22:56 -0500 (EST)
Received: by iecrd18 with SMTP id rd18so4344932iec.5
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 04:22:55 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 65si33107418iop.81.2015.02.25.04.22.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 25 Feb 2015 04:22:54 -0800 (PST)
Subject: Re: __GFP_NOFAIL and oom_killer_disabled?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150221011907.2d26c979.akpm@linux-foundation.org>
	<201502222348.GFH13009.LOHOMFVtFQSFOJ@I-love.SAKURA.ne.jp>
	<20150223102147.GB24272@dhcp22.suse.cz>
	<201502232203.DGC60931.QVtOLSOOJFMHFF@I-love.SAKURA.ne.jp>
	<20150224181408.GD14939@dhcp22.suse.cz>
In-Reply-To: <20150224181408.GD14939@dhcp22.suse.cz>
Message-Id: <201502252022.AAH51015.OtHLOVFJSMFFQO@I-love.SAKURA.ne.jp>
Date: Wed, 25 Feb 2015 20:22:22 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: akpm@linux-foundation.org, tytso@mit.edu, david@fromorbit.com, hannes@cmpxchg.org, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org

Michal Hocko wrote:
> This commit hasn't introduced any behavior changes. GFP_NOFAIL
> allocations fail when OOM killer is disabled since beginning
> 7f33d49a2ed5 (mm, PM/Freezer: Disable OOM killer when tasks are frozen).

I thought that

-       out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false);
-       *did_some_progress = 1;
+       if (out_of_memory(ac->zonelist, gfp_mask, order, ac->nodemask, false))
+               *did_some_progress = 1;

in commit c32b3cbe0d067a9c "oom, PM: make OOM detection in the freezer
path raceless" introduced a code path which fails to set
*did_some_progress to non 0 value.

> "
> We haven't seen any bug reports since 2009 so I haven't marked the patch
> for stable. I have no problem to backport it to stable trees though if
> people think it is a good precaution.
> "

Until 3.18, GFP_NOFAIL for GFP_NOFS / GFP_NOIO did not fail with
oom_killer_disabled == true because of

----------
        if (!did_some_progress) {
                if (oom_gfp_allowed(gfp_mask)) {
                        if (oom_killer_disabled)
                                goto nopage;
			(...snipped...)
                        goto restart;
                }
        }
	(...snipped...)
	goto rebalance;
----------

and that might be the reason you did not see bug reports.
In 3.19, GFP_NOFAIL for GFP_NOFS / GFP_NOIO started to fail with
oom_killer_disabled == true because of

----------
        if (should_alloc_retry(gfp_mask, order, did_some_progress,
                                                pages_reclaimed)) {
                /*
                 * If we fail to make progress by freeing individual
                 * pages, but the allocation wants us to keep going,
                 * start OOM killing tasks.
                 */
                if (!did_some_progress) {
                        page = __alloc_pages_may_oom(gfp_mask, order, zonelist,
                                                high_zoneidx, nodemask,
                                                preferred_zone, classzone_idx,
                                                migratetype,&did_some_progress);
                        if (page)
                                goto got_pg;
                        if (!did_some_progress)
                                goto nopage;
                }
                /* Wait for some write requests to complete then retry */
                wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
                goto retry;
	} else
----------

----------
static inline struct page *
__alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
        struct zonelist *zonelist, enum zone_type high_zoneidx,
        nodemask_t *nodemask, struct zone *preferred_zone,
        int classzone_idx, int migratetype, unsigned long *did_some_progress)
{
        struct page *page;

        *did_some_progress = 0;

        if (oom_killer_disabled)
                return NULL;
----------

and thus you might start seeing bug reports.

So, it is commit 9879de7373fc "mm: page_alloc: embed OOM killing naturally
into allocation slowpath" than commit c32b3cbe0d067a9c "oom, PM: make OOM
detection in the freezer path raceless" that introduced behavior changes?

> On Mon 23-02-15 22:03:25, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > What about something like the following?
> > 
> > I'm fine with whatever approaches as long as retry is guaranteed.
> > 
> > But maybe we can use memory reserves like below?
> 
> This sounds too risky to me and not really necessary. GFP_NOFAIL
> allocations shouldn't be called while the system is not running any
> tasks (aka from pm/device code). So we are primarily trying to help
> those nofail allocations which come from kernel threads and their retry
> will fail the suspend rather than blow up because of an unexpected
> allocation failure.

I meant "After all, don't we need to recheck after setting
oom_killer_disabled to true?" as "their retry will fail the suspend".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
