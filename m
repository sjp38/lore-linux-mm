Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 145C06B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 09:51:01 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c206so3486687wme.3
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 06:51:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n26si2643606wmi.51.2017.01.18.06.50.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 06:50:59 -0800 (PST)
Date: Wed, 18 Jan 2017 14:50:56 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 2/2] mm, vmscan: do not loop on too_many_isolated for
 ever
Message-ID: <20170118145056.3y72yy3dew46ypor@suse.de>
References: <20170118134453.11725-1-mhocko@kernel.org>
 <20170118134453.11725-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170118134453.11725-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, Jan 18, 2017 at 02:44:53PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Tetsuo Handa has reported [1] that direct reclaimers might get stuck in
> too_many_isolated loop basically for ever because the last few pages on
> the LRU lists are isolated by the kswapd which is stuck on fs locks when
> doing the pageout. This in turn means that there is nobody to actually
> trigger the oom killer and the system is basically unusable.
> 
> too_many_isolated has been introduced by 35cd78156c49 ("vmscan: throttle
> direct reclaim when too many pages are isolated already") to prevent
> from pre-mature oom killer invocations because back then no reclaim
> progress could indeed trigger the OOM killer too early. But since the
> oom detection rework 0a0337e0d1d1 ("mm, oom: rework oom detection")
> the allocation/reclaim retry loop considers all the reclaimable pages
> including those which are isolated - see 9f6c399ddc36 ("mm, vmscan:
> consider isolated pages in zone_reclaimable_pages") so we can loosen
> the direct reclaim throttling and instead rely on should_reclaim_retry
> logic which is the proper layer to control how to throttle and retry
> reclaim attempts.
> 
> Move the too_many_isolated check outside shrink_inactive_list because
> in fact active list might theoretically see too many isolated pages as
> well.
> 

No major objections in general. It's a bit odd you have a while loop for
something that will only loop once.

As for the TODO, one approach would be to use a waitqueue when too many
pages are isolated. Wake them one at a time when isolated pages drops
below the threshold.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
