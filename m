Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5B35F6B009F
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 01:00:57 -0500 (EST)
Message-ID: <4B21E00D.1040103@cs.helsinki.fi>
Date: Fri, 11 Dec 2009 08:00:45 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] tracing: Fix no callsite ifndef CONFIG_KMEMTRACE
References: <4B21DD88.7080806@cn.fujitsu.com> <4B21DDAF.90307@cn.fujitsu.com>
In-Reply-To: <4B21DDAF.90307@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Ingo Molnar <mingo@elte.hu>, Christoph Lameter <cl@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Frederic Weisbecker <fweisbec@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

Li Zefan wrote:
> For slab, if CONFIG_KMEMTRACE and CONFIG_DEBUG_SLAB are not set,
> __do_kmalloc() will not track callers:
> 
>  # ./perf record -f -a -R -e kmem:kmalloc
>  ^C
>  # ./perf trace
>  ...
>           perf-2204  [000]   147.376774: kmalloc: call_site=c0529d2d ...
>           perf-2204  [000]   147.400997: kmalloc: call_site=c0529d2d ...
>           Xorg-1461  [001]   147.405413: kmalloc: call_site=0 ...
>           Xorg-1461  [001]   147.405609: kmalloc: call_site=0 ...
>        konsole-1776  [001]   147.405786: kmalloc: call_site=0 ...
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

> ---
>  mm/slab.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index e556380..eacf7f0 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3637,7 +3637,7 @@ __do_kmalloc_node(size_t size, gfp_t flags, int node, void *caller)
>  	return ret;
>  }
>  
> -#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_KMEMTRACE)
> +#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_TRACING)
>  void *__kmalloc_node(size_t size, gfp_t flags, int node)
>  {
>  	return __do_kmalloc_node(size, flags, node,
> @@ -3657,7 +3657,7 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node)
>  	return __do_kmalloc_node(size, flags, node, NULL);
>  }
>  EXPORT_SYMBOL(__kmalloc_node);
> -#endif /* CONFIG_DEBUG_SLAB */
> +#endif /* CONFIG_DEBUG_SLAB || CONFIG_TRACING */
>  #endif /* CONFIG_NUMA */
>  
>  /**
> @@ -3689,7 +3689,7 @@ static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
>  }
>  
>  
> -#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_KMEMTRACE)
> +#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_TRACING)
>  void *__kmalloc(size_t size, gfp_t flags)
>  {
>  	return __do_kmalloc(size, flags, __builtin_return_address(0));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
