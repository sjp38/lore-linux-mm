Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1106B0260
	for <linux-mm@kvack.org>; Fri, 13 May 2016 09:38:54 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r12so10215811wme.0
        for <linux-mm@kvack.org>; Fri, 13 May 2016 06:38:54 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id v132si3740573wme.82.2016.05.13.06.38.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 06:38:53 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id e201so3785963wme.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 06:38:53 -0700 (PDT)
Date: Fri, 13 May 2016 15:38:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 11/13] mm, compaction: add the ultimate direct compaction
 priority
Message-ID: <20160513133851.GP20141@dhcp22.suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-12-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462865763-22084-12-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Tue 10-05-16 09:36:01, Vlastimil Babka wrote:
> During reclaim/compaction loop, it's desirable to get a final answer from
> unsuccessful compaction so we can either fail the allocation or invoke the OOM
> killer. However, heuristics such as deferred compaction or pageblock skip bits
> can cause compaction to skip parts or whole zones and lead to premature OOM's,
> failures or excessive reclaim/compaction retries.
> 
> To remedy this, we introduce a new direct compaction priority called
> COMPACT_PRIO_SYNC_FULL, which instructs direct compaction to:
> 
> - ignore deferred compaction status for a zone
> - ignore pageblock skip hints
> - ignore cached scanner positions and scan the whole zone
> - use MIGRATE_SYNC migration mode

I do not think we can do MIGRATE_SYNC because fallback_migrate_page
would trigger pageout and we are in the allocation path and so we
could blow up the stack.

> The new priority should get eventually picked up by should_compact_retry() and
> this should improve success rates for costly allocations using __GFP_RETRY,

s@__GFP_RETRY@__GFP_REPEAT@

> such as hugetlbfs allocations, and reduce some corner-case OOM's for non-costly
> allocations.

My testing has shown that even with the current implementation with
deferring, skip hints and cached positions had (close to) 100% success
rate even with close to OOM conditions.

I am wondering whether this strongest priority should be done only for
!costly high order pages. But we probably want less special cases
between costly and !costly orders.

> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/compaction.h |  1 +
>  mm/compaction.c            | 15 ++++++++++++---
>  2 files changed, 13 insertions(+), 3 deletions(-)
> 
[...]
> @@ -1631,7 +1639,8 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
>  								ac->nodemask) {
>  		enum compact_result status;
>  
> -		if (compaction_deferred(zone, order)) {
> +		if (prio > COMPACT_PRIO_SYNC_FULL
> +					&& compaction_deferred(zone, order)) {
>  			rc = max_t(enum compact_result, COMPACT_DEFERRED, rc);
>  			continue;
>  		}

Wouldn't it be better to pull the prio check into compaction_deferred
directly? There are more callers and I am not really sure all of them
would behave consistently.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
