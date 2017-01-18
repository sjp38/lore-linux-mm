Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 76A1B6B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 09:47:00 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id t18so3434235wmt.7
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 06:47:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w70si567463wrc.109.2017.01.18.06.46.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 06:46:59 -0800 (PST)
Date: Wed, 18 Jan 2017 14:46:55 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170118144655.3lra7xgdcl2awgjd@suse.de>
References: <20170118134453.11725-1-mhocko@kernel.org>
 <20170118134453.11725-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170118134453.11725-2-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, Jan 18, 2017 at 02:44:52PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> 599d0c954f91 ("mm, vmscan: move LRU lists to node") has moved
> NR_ISOLATED* counters from zones to nodes. This is not the best fit
> especially for systems with high/lowmem because a heavy memory pressure
> on the highmem zone might block lowmem requests from making progress. Or
> we might allow to reclaim lowmem zone even though there are too many
> pages already isolated from the eligible zones just because highmem
> pages will easily bias too_many_isolated to say no.
> 
> Fix these potential issues by moving isolated stats back to zones and
> teach too_many_isolated to consider only eligible zones. Per zone
> isolation counters are a bit tricky with the node reclaim because
> we have to track each page separatelly.
> 

I'm quite unhappy with this. Each move back increases the cache footprint
because of the counters but it's not clear at all this patch actually
helps anything.

Heavy memory pressure on highmem should be spread across the whole node as
we no longer are applying the fair zone allocation policy. The processes
with highmem requirements will be reclaiming from all zones and when it
finishes, it's possible that a lowmem-specific request will be clear to make
progress. It's all the same LRU so if there are too many pages isolated,
it makes sense to wait regardless of the allocation request.

More importantly, this patch may make things worse and delay reclaim. If
this patch allowed a lowmem request to make progress that would have
previously stalled, it's going to spend time skipping pages in the LRU
instead of letting kswapd and the highmem pressured processes make progress.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
