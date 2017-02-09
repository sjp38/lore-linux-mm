Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 926E26B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 07:20:10 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r18so3456965wmd.1
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 04:20:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 125si5953550wmg.106.2017.02.09.04.20.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Feb 2017 04:20:09 -0800 (PST)
Date: Thu, 9 Feb 2017 13:20:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2 v5] mm: vmscan: do not pass reclaimed slab to
 vmpressure
Message-ID: <20170209122007.GG10257@dhcp22.suse.cz>
References: <1486641577-11685-1-git-send-email-vinmenon@codeaurora.org>
 <1486641577-11685-2-git-send-email-vinmenon@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1486641577-11685-2-git-send-email-vinmenon@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, riel@redhat.com, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, minchan@kernel.org, shashim@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 09-02-17 17:29:37, Vinayak Menon wrote:
> During global reclaim, the nr_reclaimed passed to vmpressure includes the
> pages reclaimed from slab.  But the corresponding scanned slab pages is
> not passed. There is an impact to the vmpressure values because of this.
> While moving from kernel version 3.18 to 4.4, a difference is seen
> in the vmpressure values for the same workload resulting in a different
> behaviour of the vmpressure consumer. One such case is of a vmpressure
> based lowmemorykiller. It is observed that the vmpressure events are
> received late and less in number resulting in tasks not being killed at
> the right time. The following numbers show the impact on reclaim activity
> due to the change in behaviour of lowmemorykiller on a 4GB device. The test
> launches a number of apps in sequence and repeats it multiple times.

this is really vague description of your workload and doesn't really
explain why getting critical events later is a bad thing.

> 
>                       v4.4           v3.18
> pgpgin                163016456      145617236
> pgpgout               4366220        4188004
> workingset_refault    29857868       26781854
> workingset_activate   6293946        5634625
> pswpin                1327601        1133912
> pswpout               3593842        3229602
> pgalloc_dma           99520618       94402970
> pgalloc_normal        104046854      98124798
> pgfree                203772640      192600737
> pgmajfault            2126962        1851836
> pgsteal_kswapd_dma    19732899       18039462
> pgsteal_kswapd_normal 19945336       17977706
> pgsteal_direct_dma    206757         131376
> pgsteal_direct_normal 236783         138247
> pageoutrun            116622         108370
> allocstall            7220           4684
> compact_stall         931            856

this is missing any vmpressure events data and so it is not very useful
on its own

> This is a regression introduced by commit 6b4f7799c6a5 ("mm: vmscan:
> invoke slab shrinkers from shrink_zone()").
> 
> So do not consider reclaimed slab pages for vmpressure calculation. The
> reclaimed pages from slab can be excluded because the freeing of a page
> by slab shrinking depends on each slab's object population, making the
> cost model (i.e. scan:free) different from that of LRU.  Also, not every
> shrinker accounts the pages it reclaims. But ideally the pages reclaimed
> from slab should be passed to vmpressure, otherwise higher vmpressure
> levels can be triggered even when there is a reclaim progress. But
> accounting only the reclaimed slab pages without the scanned, and adding
> something which does not fit into the cost model just adds noise to the
> vmpressure values.
> 
> Fixes: 6b4f7799c6a5 ("mm: vmscan: invoke slab shrinkers from shrink_zone()")
> Acked-by: Minchan Kim <minchan@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Anton Vorontsov <anton.vorontsov@linaro.org>
> Cc: Shiraz Hashim <shashim@codeaurora.org>
> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>

I have already said I will _not_ NAK the patch but we need a much better
description and justification why the older behavior was better to
consider this a regression before this can be merged. It is hard to
expect that the underlying implementation of the vmpressure will stay
carved in stone and there might be changes in this area in the future. I
want to hear why we believe that the tested workload is sufficiently
universal and we won't see another report in few months because somebody
else will see higher vmpressure levels even though we make reclaim
progress. I have asked those questions already but it seems those were
ignored.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
