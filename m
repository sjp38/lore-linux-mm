Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 85B566B0038
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 01:53:08 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id e70so203112912ioi.3
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 22:53:08 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id o82si19991353itg.40.2016.08.15.22.53.06
        for <linux-mm@kvack.org>;
        Mon, 15 Aug 2016 22:53:07 -0700 (PDT)
Date: Tue, 16 Aug 2016 14:58:57 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v6 05/11] mm, compaction: add the ultimate direct
 compaction priority
Message-ID: <20160816055857.GB17448@js1304-P5Q-DELUXE>
References: <20160810091226.6709-1-vbabka@suse.cz>
 <20160810091226.6709-6-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160810091226.6709-6-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 10, 2016 at 11:12:20AM +0200, Vlastimil Babka wrote:
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
> 
> The new priority should get eventually picked up by should_compact_retry() and
> this should improve success rates for costly allocations using __GFP_REPEAT,
> such as hugetlbfs allocations, and reduce some corner-case OOM's for non-costly
> allocations.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/compaction.h | 3 ++-
>  mm/compaction.c            | 5 ++++-
>  2 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index e88c037afe47..a1fba9994728 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -6,8 +6,9 @@
>   * Lower value means higher priority, analogically to reclaim priority.
>   */
>  enum compact_priority {
> +	COMPACT_PRIO_SYNC_FULL,
> +	MIN_COMPACT_PRIORITY = COMPACT_PRIO_SYNC_FULL,
>  	COMPACT_PRIO_SYNC_LIGHT,
> -	MIN_COMPACT_PRIORITY = COMPACT_PRIO_SYNC_LIGHT,
>  	DEF_COMPACT_PRIORITY = COMPACT_PRIO_SYNC_LIGHT,
>  	COMPACT_PRIO_ASYNC,
>  	INIT_COMPACT_PRIORITY = COMPACT_PRIO_ASYNC
> diff --git a/mm/compaction.c b/mm/compaction.c
> index a144f58f7193..ae4f40afcca1 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1644,6 +1644,8 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
>  		.alloc_flags = alloc_flags,
>  		.classzone_idx = classzone_idx,
>  		.direct_compaction = true,
> +		.whole_zone = (prio == COMPACT_PRIO_SYNC_FULL),
> +		.ignore_skip_hint = (prio == COMPACT_PRIO_SYNC_FULL)
>  	};
>  	INIT_LIST_HEAD(&cc.freepages);
>  	INIT_LIST_HEAD(&cc.migratepages);
> @@ -1689,7 +1691,8 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
>  								ac->nodemask) {
>  		enum compact_result status;
>  
> -		if (compaction_deferred(zone, order)) {
> +		if (prio > COMPACT_PRIO_SYNC_FULL
> +					&& compaction_deferred(zone, order)) {
>  			rc = max_t(enum compact_result, COMPACT_DEFERRED, rc);
>  			continue;

Could we provide prio to compaction_deferred() and do the decision in
that that function?

BTW, in kcompactd, compaction_deferred() is checked but
.ignore_skip_hint=true. Is there any reason? If we can remove
compaction_deferred() for kcompactd, we can check .ignore_skip_hint
to determine if defer is needed or not.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
