Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3D5F79000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 02:17:40 -0400 (EDT)
Received: by bkbzs2 with SMTP id zs2so7008540bkb.14
        for <linux-mm@kvack.org>; Sun, 25 Sep 2011 23:17:37 -0700 (PDT)
Date: Mon, 26 Sep 2011 09:17:29 +0300 (EEST)
From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [RFC][PATCH] slab: fix caller tracking on
 CONFIG_OPTIMIZE_INLINING.
In-Reply-To: <201109241208.IEH26037.FtSVLJOOQHMFFO@I-love.SAKURA.ne.jp>
Message-ID: <alpine.LFD.2.02.1109260917080.1943@tux.localdomain>
References: <201109241208.IEH26037.FtSVLJOOQHMFFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: cl@linux-foundation.org, mpm@selenic.com, vegard.nossum@gmail.com, dmonakhov@openvz.org, catalin.marinas@arm.com, rientjes@google.com, dfeng@redhat.com, linux-mm@kvack.org

On Sat, 24 Sep 2011, Tetsuo Handa wrote:
> If CONFIG_OPTIMIZE_INLINING=y, /proc/slab_allocators shows entries like
>
>  size-512: 5 kzalloc+0xb/0x10
>  size-256: 31 kzalloc+0xb/0x10
>
> which are useless for debugging.
> Use "__always_inline" rather than "inline" in order to make
> /proc/slab_allocators show caller of kzalloc() if caller tracking is enabled.
>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ----------
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 573c809..2b745c0 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -188,6 +188,18 @@ size_t ksize(const void *);
> #else
> #include <linux/slab_def.h>
> #endif
> +/*
> + * /proc/slab_allocator needs _RET_IP_ value. If CONFIG_OPTIMIZE_INLINING=y,
> + * use of "inline" causes compilers to pass address of kzalloc() etc. rather
> + * than address of caller. Thus, use "__always_inline" if _RET_IP_ value is
> + * needed.
> + */
> +#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB) || \
> +	(defined(CONFIG_SLAB) && defined(CONFIG_TRACING))
> +#define slabtrace_inline __always_inline
> +#else
> +#define slabtrace_inline inline
> +#endif
>
> /**
>  * kcalloc - allocate memory for an array. The memory is set to zero.
> @@ -240,7 +252,7 @@ size_t ksize(const void *);
>  * for general use, and so are not documented here. For a full list of
>  * potential flags, always refer to linux/gfp.h.
>  */
> -static inline void *kcalloc(size_t n, size_t size, gfp_t flags)
> +static slabtrace_inline void *kcalloc(size_t n, size_t size, gfp_t flags)

So who don't we just make these __always_inline and leave it at that?

> {
> 	if (size != 0 && n > ULONG_MAX / size)
> 		return NULL;
> @@ -258,19 +270,19 @@ static inline void *kcalloc(size_t n, size_t size, gfp_t flags)
>  * if available. Equivalent to kmalloc() in the non-NUMA single-node
>  * case.
>  */
> -static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
> +static slabtrace_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
> {
> 	return kmalloc(size, flags);
> }
>
> -static inline void *__kmalloc_node(size_t size, gfp_t flags, int node)
> +static slabtrace_inline void *__kmalloc_node(size_t size, gfp_t flags, int node)
> {
> 	return __kmalloc(size, flags);
> }
>
> void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
>
> -static inline void *kmem_cache_alloc_node(struct kmem_cache *cachep,
> +static slabtrace_inline void *kmem_cache_alloc_node(struct kmem_cache *cachep,
> 					gfp_t flags, int node)
> {
> 	return kmem_cache_alloc(cachep, flags);
> @@ -325,7 +337,7 @@ extern void *__kmalloc_node_track_caller(size_t, gfp_t, int, unsigned long);
> /*
>  * Shortcuts
>  */
> -static inline void *kmem_cache_zalloc(struct kmem_cache *k, gfp_t flags)
> +static slabtrace_inline void *kmem_cache_zalloc(struct kmem_cache *k, gfp_t flags)
> {
> 	return kmem_cache_alloc(k, flags | __GFP_ZERO);
> }
> @@ -335,7 +347,7 @@ static inline void *kmem_cache_zalloc(struct kmem_cache *k, gfp_t flags)
>  * @size: how many bytes of memory are required.
>  * @flags: the type of memory to allocate (see kmalloc).
>  */
> -static inline void *kzalloc(size_t size, gfp_t flags)
> +static slabtrace_inline void *kzalloc(size_t size, gfp_t flags)
> {
> 	return kmalloc(size, flags | __GFP_ZERO);
> }
> @@ -346,7 +358,7 @@ static inline void *kzalloc(size_t size, gfp_t flags)
>  * @flags: the type of memory to allocate (see kmalloc).
>  * @node: memory node from which to allocate
>  */
> -static inline void *kzalloc_node(size_t size, gfp_t flags, int node)
> +static slabtrace_inline void *kzalloc_node(size_t size, gfp_t flags, int node)
> {
> 	return kmalloc_node(size, flags | __GFP_ZERO, node);
> }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
