Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 413616B0005
	for <linux-mm@kvack.org>; Fri, 13 May 2016 09:09:57 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 4so204023856pfw.0
        for <linux-mm@kvack.org>; Fri, 13 May 2016 06:09:57 -0700 (PDT)
Received: from mail-pf0-f194.google.com (mail-pf0-f194.google.com. [209.85.192.194])
        by mx.google.com with ESMTPS id c127si24432240pfa.69.2016.05.13.06.09.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 06:09:56 -0700 (PDT)
Received: by mail-pf0-f194.google.com with SMTP id 145so9381037pfz.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 06:09:56 -0700 (PDT)
Date: Fri, 13 May 2016 15:09:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 08/13] mm, compaction: simplify contended compaction
 handling
Message-ID: <20160513130950.GN20141@dhcp22.suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-9-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462865763-22084-9-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Tue 10-05-16 09:35:58, Vlastimil Babka wrote:
> Async compaction detects contention either due to failing trylock on zone->lock
> or lru_lock, or by need_resched(). Since 1f9efdef4f3f ("mm, compaction:
> khugepaged should not give up due to need_resched()") the code got quite
> complicated to distinguish these two up to the __alloc_pages_slowpath() level,
> so different decisions could be taken for khugepaged allocations.
> 
> After the recent changes, khugepaged allocations don't check for contended
> compaction anymore, so we again don't need to distinguish lock and sched
> contention, and simplify the current convoluted code a lot.
> 
> However, I believe it's also possible to simplify even more and completely
> remove the check for contended compaction after the initial async compaction
> for costly orders, which was originally aimed at THP page fault allocations.
> There are several reasons why this can be done now:
> 
> - with the new defaults, THP page faults no longer do reclaim/compaction at
>   all, unless the system admin has overriden the default, or application has
>   indicated via madvise that it can benefit from THP's. In both cases, it
>   means that the potential extra latency is expected and worth the benefits.

Yes this sounds reasonable to me. Especially when we consider the code bloat
size this is causing.

> - even if reclaim/compaction proceeds after this patch where it previously
>   wouldn't, the second compaction attempt is still async and will detect the
>   contention and back off, if the contention persists

MIGRATE_ASYNC still backs off after this patch so I would be surprise to
see more latency issues from this change.

> - there are still heuristics like deferred compaction and pageblock skip bits
>   in place that prevent excessive THP page fault latencies
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

I hope I haven't missed anything because the compaction is full of
subtle traps but this seems the changes seem ok to me.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/compaction.h | 10 +------
>  mm/compaction.c            | 72 +++++++++-------------------------------------
>  mm/internal.h              |  5 +---
>  mm/page_alloc.c            | 28 +-----------------
>  4 files changed, 16 insertions(+), 99 deletions(-)

This is really nice cleanup considering it doesn't introduce big
behavior changes which is my understanding from the code.

[...]
> @@ -1564,14 +1564,11 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
>  	trace_mm_compaction_end(start_pfn, cc->migrate_pfn,
>  				cc->free_pfn, end_pfn, sync, ret);
>  
> -	if (ret == COMPACT_CONTENDED)
> -		ret = COMPACT_PARTIAL;
> -
>  	return ret;
>  }

This took me a while to grasp but then I realized this is correct
because we shouldn't pretend progress when there was none in fact,
especially when __alloc_pages_direct_compact basically replaced this
"fake" COMPACT_PARTIAL by COMPACT_CONTENDED anyway.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
