Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B85766B007E
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 04:59:25 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e201so59879802wme.1
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 01:59:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n125si1095473wmn.11.2016.04.28.01.59.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 28 Apr 2016 01:59:24 -0700 (PDT)
Subject: Re: [PATCH 14/14] mm, oom, compaction: prevent from
 should_compact_retry looping for ever for costly orders
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
 <1461181647-8039-15-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5721D0EA.3020205@suse.cz>
Date: Thu, 28 Apr 2016 10:59:22 +0200
MIME-Version: 1.0
In-Reply-To: <1461181647-8039-15-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 04/20/2016 09:47 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> "mm: consider compaction feedback also for costly allocation" has
> removed the upper bound for the reclaim/compaction retries based on the
> number of reclaimed pages for costly orders. While this is desirable
> the patch did miss a mis interaction between reclaim, compaction and the
> retry logic.

Hmm perhaps reversing the order of patches 13 and 14 would be a bit 
safer wrt future bisections then? Add compaction_zonelist_suitable() 
first with the reasoning, and then immediately use it in the other patch.

> The direct reclaim tries to get zones over min watermark
> while compaction backs off and returns COMPACT_SKIPPED when all zones
> are below low watermark + 1<<order gap. If we are getting really close
> to OOM then __compaction_suitable can keep returning COMPACT_SKIPPED a
> high order request (e.g. hugetlb order-9) while the reclaim is not able
> to release enough pages to get us over low watermark. The reclaim is
> still able to make some progress (usually trashing over few remaining
> pages) so we are not able to break out from the loop.
>
> I have seen this happening with the same test described in "mm: consider
> compaction feedback also for costly allocation" on a swapless system.
> The original problem got resolved by "vmscan: consider classzone_idx in
> compaction_ready" but it shows how things might go wrong when we
> approach the oom event horizont.
>
> The reason why compaction requires being over low rather than min
> watermark is not clear to me. This check was there essentially since
> 56de7263fcf3 ("mm: compaction: direct compact when a high-order
> allocation fails"). It is clearly an implementation detail though and we
> shouldn't pull it into the generic retry logic while we should be able
> to cope with such eventuality. The only place in should_compact_retry
> where we retry without any upper bound is for compaction_withdrawn()
> case.
>
> Introduce compaction_zonelist_suitable function which checks the given
> zonelist and returns true only if there is at least one zone which would
> would unblock __compaction_suitable if more memory got reclaimed. In
> this implementation it checks __compaction_suitable with NR_FREE_PAGES
> plus part of the reclaimable memory as the target for the watermark check.
> The reclaimable memory is reduced linearly by the allocation order. The
> idea is that we do not want to reclaim all the remaining memory for a
> single allocation request just unblock __compaction_suitable which
> doesn't guarantee we will make a further progress.
>
> The new helper is then used if compaction_withdrawn() feedback was
> provided so we do not retry if there is no outlook for a further
> progress. !costly requests shouldn't be affected much - e.g. order-2
> pages would require to have at least 64kB on the reclaimable LRUs while
> order-9 would need at least 32M which should be enough to not lock up.
>
> [vbabka@suse.cz: fix classzone_idx vs. high_zoneidx usage in
> compaction_zonelist_suitable]
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
