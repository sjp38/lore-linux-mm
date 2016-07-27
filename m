Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 34A1C6B0253
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 12:33:55 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 33so584909lfw.1
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 09:33:55 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id r19si36177511wme.34.2016.07.27.09.33.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 09:33:53 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id x83so7251038wma.3
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 09:33:53 -0700 (PDT)
Date: Wed, 27 Jul 2016 18:33:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: page_alloc.c: Add tracepoints for slowpath
Message-ID: <20160727163351.GC21859@dhcp22.suse.cz>
References: <cover.1469629027.git.janani.rvchndrn@gmail.com>
 <6b12aed89ad75cb2b3525a24265fa1d622409b42.1469629027.git.janani.rvchndrn@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6b12aed89ad75cb2b3525a24265fa1d622409b42.1469629027.git.janani.rvchndrn@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@linux-foundation.org, hannes@compxchg.org, vdavydov@virtuozzo.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com, rostedt@goodmis.org

On Wed 27-07-16 10:47:59, Janani Ravichandran wrote:
> Add tracepoints to the slowpath code to gather some information.
> The tracepoints can also be used to find out how much time was spent in
> the slowpath.

I do not think this is a right thing to measure. __alloc_pages_slowpath
is more a code organization thing. The fast path might perform an
expensive operations like zone reclaim (if node_reclaim_mode > 0) so
these trace point would miss it.

__alloc_pages_nodemask already has a trace point after the allocation
request is done. This alone is not sufficient to measure the allocation
latency which is the main point of this patch AFAIU. Wouldn't it be
better to add another trace point when we enter __alloc_pages_nodemask?

> Signed-off-by: Janani Ravichandran <janani.rvchndrn@gmail.com>
> ---
>  include/trace/events/kmem.h | 40 ++++++++++++++++++++++++++++++++++++++++
>  mm/page_alloc.c             |  5 +++++
>  2 files changed, 45 insertions(+)
> 
> diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
> index 6b2e154..c19ab9f 100644
> --- a/include/trace/events/kmem.h
> +++ b/include/trace/events/kmem.h
> @@ -169,6 +169,46 @@ TRACE_EVENT(mm_page_free,
>  			__entry->order)
>  );
>  
> +TRACE_EVENT(mm_slowpath_begin,
> +
> +	TP_PROTO(gfp_t gfp_mask, int order),
> +
> +	TP_ARGS(gfp_mask, order),
> +
> +	TP_STRUCT__entry(
> +		__field(gfp_t, gfp_mask)
> +		__field(int, order)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->gfp_mask = gfp_mask;
> +		__entry->order = order;
> +	),
> +
> +	TP_printk("gfp_mask:%s order=%d",
> +		show_gfp_flags(__entry->gfp_mask),
> +		__entry->order)
> +);
> +
> +TRACE_EVENT(mm_slowpath_end,
> +
> +	TP_PROTO(struct page *page),
> +
> +	TP_ARGS(page),
> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long, pfn)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->pfn = page ? page_to_pfn(page) : -1UL;
> +	),
> +
> +	TP_printk("page=%p pfn=%lu",
> +		__entry->pfn != -1UL ? pfn_to_page(__entry->pfn) : NULL,
> +		__entry->pfn != -1UL ? __entry->pfn : 0)
> +);
> +
>  TRACE_EVENT(mm_page_free_batched,
>  
>  	TP_PROTO(struct page *page, int cold),
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8b3e134..be9c688 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3595,6 +3595,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  				(__GFP_ATOMIC|__GFP_DIRECT_RECLAIM)))
>  		gfp_mask &= ~__GFP_ATOMIC;
>  
> +	trace_mm_slowpath_begin(gfp_mask, order);
> +
>  retry:
>  	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
>  		wake_all_kswapds(order, ac);
> @@ -3769,6 +3771,9 @@ noretry:
>  nopage:
>  	warn_alloc_failed(gfp_mask, order, NULL);
>  got_pg:
> +
> +	trace_mm_slowpath_end(page);
> +
>  	return page;
>  }
>  
> -- 
> 2.7.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
