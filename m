Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id C27906B029C
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 03:09:16 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id s2so174149007iod.0
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 00:09:16 -0700 (PDT)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTP id vk8si2000314igb.26.2016.04.21.00.09.14
        for <linux-mm@kvack.org>;
        Thu, 21 Apr 2016 00:09:16 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org> <1461181647-8039-5-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461181647-8039-5-git-send-email-mhocko@kernel.org>
Subject: Re: [PATCH 04/14] mm, compaction: distinguish COMPACT_DEFERRED from COMPACT_SKIPPED
Date: Thu, 21 Apr 2016 15:08:55 +0800
Message-ID: <02d501d19b9c$ab7fd4e0$027f7ea0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'David Rientjes' <rientjes@google.com>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'Joonsoo Kim' <js1304@gmail.com>, 'Vlastimil Babka' <vbabka@suse.cz>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>

> 
> From: Michal Hocko <mhocko@suse.com>
> 
> try_to_compact_pages can currently return COMPACT_SKIPPED even when the
> compaction is defered for some zone just because zone DMA is skipped
> in 99% of cases due to watermark checks. This makes COMPACT_DEFERRED
> basically unusable for the page allocator as a feedback mechanism.
> 
> Make sure we distinguish those two states properly and switch their
> ordering in the enum. This would mean that the COMPACT_SKIPPED will be
> returned only when all eligible zones are skipped.
> 
> As a result COMPACT_DEFERRED handling for THP in __alloc_pages_slowpath
> will be more precise and we would bail out rather than reclaim.
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  include/linux/compaction.h        | 7 +++++--
>  include/trace/events/compaction.h | 2 +-
>  mm/compaction.c                   | 8 +++++---
>  3 files changed, 11 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index 4458fd94170f..7e177d111c39 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -4,13 +4,16 @@
>  /* Return values for compact_zone() and try_to_compact_pages() */
>  /* When adding new states, please adjust include/trace/events/compaction.h */
>  enum compact_result {
> -	/* compaction didn't start as it was deferred due to past failures */
> -	COMPACT_DEFERRED,
>  	/*
>  	 * compaction didn't start as it was not possible or direct reclaim
>  	 * was more suitable
>  	 */
>  	COMPACT_SKIPPED,
> +	/* compaction didn't start as it was deferred due to past failures */
> +	COMPACT_DEFERRED,
> +	/* compaction not active last round */
> +	COMPACT_INACTIVE = COMPACT_DEFERRED,
> +
>  	/* compaction should continue to another pageblock */
>  	COMPACT_CONTINUE,
>  	/*
> diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
> index e215bf68f521..6ba16c86d7db 100644
> --- a/include/trace/events/compaction.h
> +++ b/include/trace/events/compaction.h
> @@ -10,8 +10,8 @@
>  #include <trace/events/mmflags.h>
> 
>  #define COMPACTION_STATUS					\
> -	EM( COMPACT_DEFERRED,		"deferred")		\
>  	EM( COMPACT_SKIPPED,		"skipped")		\
> +	EM( COMPACT_DEFERRED,		"deferred")		\
>  	EM( COMPACT_CONTINUE,		"continue")		\
>  	EM( COMPACT_PARTIAL,		"partial")		\
>  	EM( COMPACT_COMPLETE,		"complete")		\
> diff --git a/mm/compaction.c b/mm/compaction.c
> index b06de27b7f72..13709e33a2fc 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1637,7 +1637,7 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
>  	int may_perform_io = gfp_mask & __GFP_IO;
>  	struct zoneref *z;
>  	struct zone *zone;
> -	enum compact_result rc = COMPACT_DEFERRED;
> +	enum compact_result rc = COMPACT_SKIPPED;
>  	int all_zones_contended = COMPACT_CONTENDED_LOCK; /* init for &= op */
> 
>  	*contended = COMPACT_CONTENDED_NONE;
> @@ -1654,8 +1654,10 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
>  		enum compact_result status;
>  		int zone_contended;
> 
> -		if (compaction_deferred(zone, order))
> +		if (compaction_deferred(zone, order)) {
> +			rc = max_t(enum compact_result, COMPACT_DEFERRED, rc);
>  			continue;
> +		}
> 
>  		status = compact_zone_order(zone, order, gfp_mask, mode,
>  				&zone_contended, alloc_flags,
> @@ -1726,7 +1728,7 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
>  	 * If at least one zone wasn't deferred or skipped, we report if all
>  	 * zones that were tried were lock contended.
>  	 */
> -	if (rc > COMPACT_SKIPPED && all_zones_contended)
> +	if (rc > COMPACT_INACTIVE && all_zones_contended)
>  		*contended = COMPACT_CONTENDED_LOCK;
> 
>  	return rc;
> --
> 2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
