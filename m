Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 65B636B0292
	for <linux-mm@kvack.org>; Mon, 22 May 2017 16:39:28 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p74so140756872pfd.11
        for <linux-mm@kvack.org>; Mon, 22 May 2017 13:39:28 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t76sor335255pfk.53.2017.05.22.13.39.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 May 2017 13:39:27 -0700 (PDT)
Date: Mon, 22 May 2017 13:39:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] mm/slub: Only define kmalloc_large_node_hook() for
 NUMA systems
In-Reply-To: <20170519210036.146880-2-mka@chromium.org>
Message-ID: <alpine.DEB.2.10.1705221338100.30407@chino.kir.corp.google.com>
References: <20170519210036.146880-1-mka@chromium.org> <20170519210036.146880-2-mka@chromium.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Kaehlcke <mka@chromium.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 19 May 2017, Matthias Kaehlcke wrote:

> The function is only used when CONFIG_NUMA=y. Placing it in an #ifdef
> block fixes the following warning when building with clang:
> 
> mm/slub.c:1246:20: error: unused function 'kmalloc_large_node_hook'
>     [-Werror,-Wunused-function]
> 

Is clang not inlining kmalloc_large_node_hook() for some reason?  I don't 
think this should ever warn on gcc.

> Signed-off-by: Matthias Kaehlcke <mka@chromium.org>

Acked-by: David Rientjes <rientjes@google.com>

> ---
>  mm/slub.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 57e5156f02be..66e1046435b7 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1313,11 +1313,14 @@ static inline void dec_slabs_node(struct kmem_cache *s, int node,
>   * Hooks for other subsystems that check memory allocations. In a typical
>   * production configuration these hooks all should produce no code at all.
>   */
> +
> +#ifdef CONFIG_NUMA
>  static inline void kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
>  {
>  	kmemleak_alloc(ptr, size, 1, flags);
>  	kasan_kmalloc_large(ptr, size, flags);
>  }
> +#endif
>  
>  static inline void kfree_hook(const void *x)
>  {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
