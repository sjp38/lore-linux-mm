Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 041FB6B025E
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:10:31 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id l6so142976403wml.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 05:10:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cd8si28501517wjc.91.2016.04.11.05.10.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Apr 2016 05:10:29 -0700 (PDT)
Subject: Re: [PATCH 06/11] mm, compaction: distinguish between full and
 partial COMPACT_COMPLETE
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
 <1459855533-4600-7-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <570B9432.9090600@suse.cz>
Date: Mon, 11 Apr 2016 14:10:26 +0200
MIME-Version: 1.0
In-Reply-To: <1459855533-4600-7-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 04/05/2016 01:25 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> COMPACT_COMPLETE now means that compaction and free scanner met. This is
> not very useful information if somebody just wants to use this feedback
> and make any decisions based on that. The current caller might be a poor
> guy who just happened to scan tiny portion of the zone and that could be
> the reason no suitable pages were compacted. Make sure we distinguish
> the full and partial zone walks.
>
> Consumers should treat COMPACT_PARTIAL_SKIPPED as a potential success
> and be optimistic in retrying.
>
> The existing users of COMPACT_COMPLETE are conservatively changed to
> use COMPACT_PARTIAL_SKIPPED as well but some of them should be probably
> reconsidered and only defer the compaction only for COMPACT_COMPLETE
> with the new semantic.
>
> This patch shouldn't introduce any functional changes.
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

With some notes:

> @@ -1463,6 +1466,10 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
>   		zone->compact_cached_migrate_pfn[0] = cc->migrate_pfn;
>   		zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
>   	}
> +
> +	if (cc->migrate_pfn == start_pfn)
> +		cc->whole_zone = true;
> +

This assumes that migrate scanner at initial position implies also free 
scanner at the initial position. That should be true, because migration 
scanner is the first to run. But getting the zone->compact_cached_*_pfn 
is racy. Worse, zone->compact_cached_migrate_pfn is array distinguishing 
sync and async compaction, so it's possible that async compaction has 
advanced both its own migrate scanner cached position, and the shared 
free scanner cached position, and then sync compaction starts migrate 
scanner at start_pfn, but free scanner has already advanced.
So you might still see a false positive COMPACT_COMPLETE, just less 
frequently and probably with much lower impact.
But if you need to be truly reliable, check also that cc->free_pfn == 
round_down(end_pfn - 1, pageblock_nr_pages)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
