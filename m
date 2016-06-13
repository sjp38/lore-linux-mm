Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 18D066B0005
	for <linux-mm@kvack.org>; Sun, 12 Jun 2016 23:47:26 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id a64so11986813oii.1
        for <linux-mm@kvack.org>; Sun, 12 Jun 2016 20:47:26 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id h204si10226139itb.87.2016.06.12.20.47.24
        for <linux-mm@kvack.org>;
        Sun, 12 Jun 2016 20:47:25 -0700 (PDT)
Date: Mon, 13 Jun 2016 12:47:23 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/zsmalloc: add trace events for zs_compact
Message-ID: <20160613034723.GB23754@bbox>
References: <1465289804-4913-1-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
In-Reply-To: <1465289804-4913-1-git-send-email-opensource.ganesh@gmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com

On Tue, Jun 07, 2016 at 04:56:44PM +0800, Ganesh Mahendran wrote:
> Currently zsmalloc is widely used in android device.
> Sometimes, we want to see how frequently zs_compact is
> triggered or how may pages freed by zs_compact(), or which
> zsmalloc pool is compacted.
> 
> Most of the time, user can get the brief information from
> trace_mm_shrink_slab_[start | end], but in some senario,
> they do not use zsmalloc shrinker, but trigger compaction manually.
> So add some trace events in zs_compact is convenient. Also we
> can add some zsmalloc specific information(pool name, total compact
> pages, etc) in zsmalloc trace.
> 
> This patch add two trace events for zs_compact(), below the trace log:
> -----------------------------
> root@land:/ # cat /d/tracing/trace
>          kswapd0-125   [007] ...1   174.176979: zsmalloc_compact_start: pool zram0
>          kswapd0-125   [007] ...1   174.181967: zsmalloc_compact_end: pool zram0: 608 pages compacted(total 1794)
>          kswapd0-125   [000] ...1   184.134475: zsmalloc_compact_start: pool zram0
>          kswapd0-125   [000] ...1   184.135010: zsmalloc_compact_end: pool zram0: 62 pages compacted(total 1856)
>          kswapd0-125   [003] ...1   226.927221: zsmalloc_compact_start: pool zram0
>          kswapd0-125   [003] ...1   226.928575: zsmalloc_compact_end: pool zram0: 250 pages compacted(total 2106)
> -----------------------------
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> ---
>  include/trace/events/zsmalloc.h | 56 +++++++++++++++++++++++++++++++++++++++++
>  mm/zsmalloc.c                   | 10 ++++++++
>  2 files changed, 66 insertions(+)
>  create mode 100644 include/trace/events/zsmalloc.h
> 
> diff --git a/include/trace/events/zsmalloc.h b/include/trace/events/zsmalloc.h
> new file mode 100644
> index 0000000..3b6f14e
> --- /dev/null
> +++ b/include/trace/events/zsmalloc.h
> @@ -0,0 +1,56 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM zsmalloc
> +
> +#if !defined(_TRACE_ZSMALLOC_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_ZSMALLOC_H
> +
> +#include <linux/types.h>
> +#include <linux/tracepoint.h>
> +
> +TRACE_EVENT(zsmalloc_compact_start,

I prefer zs_compact_start.

> +
> +	TP_PROTO(const char *pool_name),
> +
> +	TP_ARGS(pool_name),
> +
> +	TP_STRUCT__entry(
> +		__field(const char *, pool_name)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->pool_name = pool_name;
> +	),
> +
> +	TP_printk("pool %s",
> +		  __entry->pool_name)
> +);
> +
> +TRACE_EVENT(zsmalloc_compact_end,
> +
> +	TP_PROTO(const char *pool_name, unsigned long pages_compacted,
> +			unsigned long pages_total_compacted),

Hmm, do we really need pages_total_compacted?

> +
> +	TP_ARGS(pool_name, pages_compacted, pages_total_compacted),
> +
> +	TP_STRUCT__entry(
> +		__field(const char *, pool_name)
> +		__field(unsigned long, pages_compacted)
> +		__field(unsigned long, pages_total_compacted)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->pool_name = pool_name;
> +		__entry->pages_compacted = pages_compacted;
> +		__entry->pages_total_compacted = pages_total_compacted;
> +	),
> +
> +	TP_printk("pool %s: %ld pages compacted(total %ld)",
> +		  __entry->pool_name,
> +		  __entry->pages_compacted,
> +		  __entry->pages_total_compacted)
> +);
> +
> +#endif /* _TRACE_ZSMALLOC_H */
> +
> +/* This part must be outside protection */
> +#include <trace/define_trace.h>
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 213d0e1..441b9f7 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -30,6 +30,8 @@
>  
>  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>  
> +#define CREATE_TRACE_POINTS
> +
>  #include <linux/module.h>
>  #include <linux/kernel.h>
>  #include <linux/sched.h>
> @@ -52,6 +54,7 @@
>  #include <linux/mount.h>
>  #include <linux/compaction.h>
>  #include <linux/pagemap.h>
> +#include <trace/events/zsmalloc.h>
>  
>  #define ZSPAGE_MAGIC	0x58
>  
> @@ -2330,6 +2333,9 @@ unsigned long zs_compact(struct zs_pool *pool)
>  {
>  	int i;
>  	struct size_class *class;
> +	unsigned long pages_compacted_before = pool->stats.pages_compacted;
> +
> +	trace_zsmalloc_compact_start(pool->name);

How about moving it into __zs_compact with size_class information?
It would be more useful, I think.

>  
>  	for (i = zs_size_classes - 1; i >= 0; i--) {
>  		class = pool->size_class[i];
> @@ -2340,6 +2346,10 @@ unsigned long zs_compact(struct zs_pool *pool)
>  		__zs_compact(pool, class);
>  	}
>  
> +	trace_zsmalloc_compact_end(pool->name,
> +		pool->stats.pages_compacted - pages_compacted_before,
> +		pool->stats.pages_compacted);
> +
>  	return pool->stats.pages_compacted;
>  }
>  EXPORT_SYMBOL_GPL(zs_compact);
> -- 
> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
