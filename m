Received: by rv-out-0708.google.com with SMTP id f25so4283462rvb.26
        for <linux-mm@kvack.org>; Fri, 11 Jul 2008 01:49:27 -0700 (PDT)
Message-ID: <84144f020807110149v4806404fjdb9c3e4af3cfdb70@mail.gmail.com>
Date: Fri, 11 Jul 2008 11:49:27 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [RFC PATCH 3/5] kmemtrace: SLAB hooks.
In-Reply-To: <20080710210611.7c194a70@linux360.ro>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1215712946-23572-1-git-send-email-eduard.munteanu@linux360.ro>
	 <1215712946-23572-2-git-send-email-eduard.munteanu@linux360.ro>
	 <1215712946-23572-3-git-send-email-eduard.munteanu@linux360.ro>
	 <20080710210611.7c194a70@linux360.ro>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Eduard-Gabriel,

On Thu, Jul 10, 2008 at 9:06 PM, Eduard - Gabriel Munteanu
<eduard.munteanu@linux360.ro> wrote:
> This adds hooks for the SLAB allocator, to allow tracing with kmemtrace.
>
> Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
>  static inline void *kmalloc(size_t size, gfp_t flags)
>  {
> +       void *ret;
> +
>        if (__builtin_constant_p(size)) {
>                int i = 0;
>
> @@ -50,10 +53,17 @@ static inline void *kmalloc(size_t size, gfp_t flags)
>  found:
>  #ifdef CONFIG_ZONE_DMA
>                if (flags & GFP_DMA)
> -                       return kmem_cache_alloc(malloc_sizes[i].cs_dmacachep,
> -                                               flags);
> +                       ret = kmem_cache_alloc(malloc_sizes[i].cs_dmacachep,
> +                                              flags | __GFP_NOTRACE);
> +               else
>  #endif
> -               return kmem_cache_alloc(malloc_sizes[i].cs_cachep, flags);
> +                       ret = kmem_cache_alloc(malloc_sizes[i].cs_cachep,
> +                                              flags | __GFP_NOTRACE);
> +
> +               kmemtrace_mark_alloc(KMEMTRACE_KIND_KERNEL, _THIS_IP_, ret,
> +                                    size, malloc_sizes[i].cs_size, flags);
> +
> +               return ret;

I think this would be cleaner if you'd simply add a new
__kmem_cache_alloc() entry point in SLAB that takes the "kind" as an
argument. That way you wouldn't have to play tricks with GFP flags.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
