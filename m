Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id DC616280256
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 13:15:04 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id s64so17224861lfs.1
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 10:15:04 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id b205si32836668wmh.146.2016.09.21.10.15.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 10:15:03 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id 133so9741514wmq.2
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 10:15:03 -0700 (PDT)
Date: Wed, 21 Sep 2016 19:15:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/4] mm, compaction: restrict full priority to non-costly
 orders
Message-ID: <20160921171501.GG24210@dhcp22.suse.cz>
References: <20160906135258.18335-1-vbabka@suse.cz>
 <20160906135258.18335-4-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160906135258.18335-4-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Olaf Hering <olaf@aepfle.de>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On Tue 06-09-16 15:52:57, Vlastimil Babka wrote:
> The new ultimate compaction priority disables some heuristics, which may result
> in excessive cost. This is fine for non-costly orders where we want to try hard
> before resulting for OOM, but might be disruptive for costly orders which do
> not trigger OOM and should generally have some fallback. Thus, we disable the
> full priority for costly orders.
> 
> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Rik van Riel <riel@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/compaction.h | 1 +
>  mm/page_alloc.c            | 5 ++++-
>  2 files changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index 585d55cb0dc0..0d8415820fc3 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -9,6 +9,7 @@ enum compact_priority {
>  	COMPACT_PRIO_SYNC_FULL,
>  	MIN_COMPACT_PRIORITY = COMPACT_PRIO_SYNC_FULL,
>  	COMPACT_PRIO_SYNC_LIGHT,
> +	MIN_COMPACT_COSTLY_PRIORITY = COMPACT_PRIO_SYNC_LIGHT,
>  	DEF_COMPACT_PRIORITY = COMPACT_PRIO_SYNC_LIGHT,
>  	COMPACT_PRIO_ASYNC,
>  	INIT_COMPACT_PRIORITY = COMPACT_PRIO_ASYNC
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f8bed910e3cf..ff60a2837c58 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3165,6 +3165,7 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
>  		     int compaction_retries)
>  {
>  	int max_retries = MAX_COMPACT_RETRIES;
> +	int min_priority;
>  
>  	if (!order)
>  		return false;
> @@ -3204,7 +3205,9 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
>  	 * if we exhausted all retries at the lower priorities
>  	 */
>  check_priority:
> -	if (*compact_priority > MIN_COMPACT_PRIORITY) {
> +	min_priority = (order > PAGE_ALLOC_COSTLY_ORDER) ?
> +			MIN_COMPACT_COSTLY_PRIORITY : MIN_COMPACT_PRIORITY;
> +	if (*compact_priority > min_priority) {
>  		(*compact_priority)--;
>  		return true;
>  	}
> -- 
> 2.9.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
