Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id A5B316B0253
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 11:07:20 -0400 (EDT)
Received: by mail-wm0-f50.google.com with SMTP id n3so108892607wmn.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:07:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a66si18856983wma.67.2016.04.11.08.07.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Apr 2016 08:07:19 -0700 (PDT)
Subject: Re: [PATCH 11/11] mm: consider compaction feedback also for costly
 allocation
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
 <1459855533-4600-12-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <570BBDA3.8030708@suse.cz>
Date: Mon, 11 Apr 2016 17:07:15 +0200
MIME-Version: 1.0
In-Reply-To: <1459855533-4600-12-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 04/05/2016 01:25 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> PAGE_ALLOC_COSTLY_ORDER retry logic is mostly handled inside
> should_reclaim_retry currently where we decide to not retry after at
> least order worth of pages were reclaimed or the watermark check for at
> least one zone would succeed after reclaiming all pages if the reclaim
> hasn't made any progress. Compaction feedback is mostly ignored and we
> just try to make sure that the compaction did at least something before
> giving up.
>
> The first condition was added by a41f24ea9fd6 ("page allocator: smarter
> retry of costly-order allocations) and it assumed that lumpy reclaim
> could have created a page of the sufficient order. Lumpy reclaim,
> has been removed quite some time ago so the assumption doesn't hold
> anymore. Remove the check for the number of reclaimed pages and rely
> on the compaction feedback solely. should_reclaim_retry now only
> makes sure that we keep retrying reclaim for high order pages only
> if they are hidden by watermaks so order-0 reclaim makes really sense.
>
> should_compact_retry now keeps retrying even for the costly allocations.
> The number of retries is reduced wrt. !costly requests because they are
> less important and harder to grant and so their pressure shouldn't cause
> contention for other requests or cause an over reclaim. We also do not
> reset no_progress_loops for costly request to make sure we do not keep
> reclaiming too agressively.

[...]

> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
