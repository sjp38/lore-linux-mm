Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 95C1C6B0005
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 11:23:09 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id i64so8380188ith.2
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 08:23:09 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0099.hostedemail.com. [216.40.44.99])
        by mx.google.com with ESMTPS id f66si7849794ite.10.2016.07.27.08.23.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 08:23:07 -0700 (PDT)
Date: Wed, 27 Jul 2016 11:23:03 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/2] mm: page_alloc.c: Add tracepoints for slowpath
Message-ID: <20160727112303.11409a4e@gandalf.local.home>
In-Reply-To: <6b12aed89ad75cb2b3525a24265fa1d622409b42.1469629027.git.janani.rvchndrn@gmail.com>
References: <cover.1469629027.git.janani.rvchndrn@gmail.com>
	<6b12aed89ad75cb2b3525a24265fa1d622409b42.1469629027.git.janani.rvchndrn@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@linux-foundation.org, hannes@compxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On Wed, 27 Jul 2016 10:47:59 -0400
Janani Ravichandran <janani.rvchndrn@gmail.com> wrote:

> Add tracepoints to the slowpath code to gather some information.
> The tracepoints can also be used to find out how much time was spent in
> the slowpath.
> 
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

Note, userspace tools will not be able to do this conversion (like
trace-cmd or perf).

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

I'm thinking you only need one tracepoint, and use function_graph
tracer for the length of the function call.

 # cd /sys/kernel/debug/tracing
 # echo __alloc_pages_nodemask > set_ftrace_filter
 # echo function_graph > current_tracer
 # echo 1 > events/kmem/trace_mm_slowpath/enable

-- Steve


>  	return page;
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
