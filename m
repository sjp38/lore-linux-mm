Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 118D69000BD
	for <linux-mm@kvack.org>; Sat, 24 Sep 2011 19:00:29 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p8ON0L7V007532
	for <linux-mm@kvack.org>; Sat, 24 Sep 2011 16:00:21 -0700
Received: from yib25 (yib25.prod.google.com [10.243.65.89])
	by hpaq7.eem.corp.google.com with ESMTP id p8ON0JIF016792
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 24 Sep 2011 16:00:20 -0700
Received: by yib25 with SMTP id 25so5173103yib.37
        for <linux-mm@kvack.org>; Sat, 24 Sep 2011 16:00:18 -0700 (PDT)
Date: Sat, 24 Sep 2011 16:00:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH] slab: fix caller tracking on
 CONFIG_OPTIMIZE_INLINING.
In-Reply-To: <201109241208.IEH26037.FtSVLJOOQHMFFO@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.00.1109241550230.14043@chino.kir.corp.google.com>
References: <201109241208.IEH26037.FtSVLJOOQHMFFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: cl@linux-foundation.org, penberg@cs.helsinki.fi, mpm@selenic.com, vegard.nossum@gmail.com, dmonakhov@openvz.org, catalin.marinas@arm.com, dfeng@redhat.com, linux-mm@kvack.org

On Sat, 24 Sep 2011, Tetsuo Handa wrote:

> If CONFIG_OPTIMIZE_INLINING=y, /proc/slab_allocators shows entries like
> 
>   size-512: 5 kzalloc+0xb/0x10
>   size-256: 31 kzalloc+0xb/0x10
> 
> which are useless for debugging.
> Use "__always_inline" rather than "inline" in order to make
> /proc/slab_allocators show caller of kzalloc() if caller tracking is enabled.
> 

This is only an issue for gcc 4.x compilers, correct?

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ----------
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 573c809..2b745c0 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -188,6 +188,18 @@ size_t ksize(const void *);
>  #else
>  #include <linux/slab_def.h>
>  #endif
> +/*
> + * /proc/slab_allocator needs _RET_IP_ value. If CONFIG_OPTIMIZE_INLINING=y,
> + * use of "inline" causes compilers to pass address of kzalloc() etc. rather
> + * than address of caller. Thus, use "__always_inline" if _RET_IP_ value is
> + * needed.
> + */
> +#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB) || \
> +	(defined(CONFIG_SLAB) && defined(CONFIG_TRACING))

/proc/slab_allocators is for CONFIG_SLAB only, so why is this being done 
for slub when it already uses trace points with _RET_IP_?

> +#define slabtrace_inline __always_inline
> +#else
> +#define slabtrace_inline inline
> +#endif
>  
>  /**
>   * kcalloc - allocate memory for an array. The memory is set to zero.
> @@ -240,7 +252,7 @@ size_t ksize(const void *);
>   * for general use, and so are not documented here. For a full list of
>   * potential flags, always refer to linux/gfp.h.
>   */
> -static inline void *kcalloc(size_t n, size_t size, gfp_t flags)
> +static slabtrace_inline void *kcalloc(size_t n, size_t size, gfp_t flags)
>  {
>  	if (size != 0 && n > ULONG_MAX / size)
>  		return NULL;
> @@ -258,19 +270,19 @@ static inline void *kcalloc(size_t n, size_t size, gfp_t flags)
>   * if available. Equivalent to kmalloc() in the non-NUMA single-node
>   * case.
>   */
> -static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
> +static slabtrace_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
>  {
>  	return kmalloc(size, flags);
>  }
>  
> -static inline void *__kmalloc_node(size_t size, gfp_t flags, int node)
> +static slabtrace_inline void *__kmalloc_node(size_t size, gfp_t flags, int node)
>  {
>  	return __kmalloc(size, flags);
>  }
>  
>  void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
>  
> -static inline void *kmem_cache_alloc_node(struct kmem_cache *cachep,
> +static slabtrace_inline void *kmem_cache_alloc_node(struct kmem_cache *cachep,
>  					gfp_t flags, int node)
>  {
>  	return kmem_cache_alloc(cachep, flags);
> @@ -325,7 +337,7 @@ extern void *__kmalloc_node_track_caller(size_t, gfp_t, int, unsigned long);
>  /*
>   * Shortcuts
>   */
> -static inline void *kmem_cache_zalloc(struct kmem_cache *k, gfp_t flags)
> +static slabtrace_inline void *kmem_cache_zalloc(struct kmem_cache *k, gfp_t flags)
>  {
>  	return kmem_cache_alloc(k, flags | __GFP_ZERO);
>  }
> @@ -335,7 +347,7 @@ static inline void *kmem_cache_zalloc(struct kmem_cache *k, gfp_t flags)
>   * @size: how many bytes of memory are required.
>   * @flags: the type of memory to allocate (see kmalloc).
>   */
> -static inline void *kzalloc(size_t size, gfp_t flags)
> +static slabtrace_inline void *kzalloc(size_t size, gfp_t flags)
>  {
>  	return kmalloc(size, flags | __GFP_ZERO);
>  }
> @@ -346,7 +358,7 @@ static inline void *kzalloc(size_t size, gfp_t flags)
>   * @flags: the type of memory to allocate (see kmalloc).
>   * @node: memory node from which to allocate
>   */
> -static inline void *kzalloc_node(size_t size, gfp_t flags, int node)
> +static slabtrace_inline void *kzalloc_node(size_t size, gfp_t flags, int node)
>  {
>  	return kmalloc_node(size, flags | __GFP_ZERO, node);
>  }
> 

So this is going against the inlining algorithms in gcc 4.x which will 
make the kernel image significantly larger even though there seems to be 
no benefit unless you have CONFIG_DEBUG_SLAB_LEAK, although this patch 
changes behavior for every system running CONFIG_SLAB with tracing 
support.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
