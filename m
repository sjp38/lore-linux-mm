Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B5A646B0033
	for <linux-mm@kvack.org>; Sun, 10 Dec 2017 05:40:10 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id v184so3259736wmf.1
        for <linux-mm@kvack.org>; Sun, 10 Dec 2017 02:40:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d16si8169447wrd.331.2017.12.10.02.40.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 10 Dec 2017 02:40:09 -0800 (PST)
Date: Sun, 10 Dec 2017 11:40:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/slab: make calculate_alignment() function static
Message-ID: <20171210104007.GD20234@dhcp22.suse.cz>
References: <20171210080132.406-1-bhlee.kernel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171210080132.406-1-bhlee.kernel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byongho Lee <bhlee.kernel@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 10-12-17 17:01:32, Byongho Lee wrote:
> calculate_alignment() function is only used inside 'slab_common.c'.
> So make it static and let compiler do more optimizations.
> 
> After this patch there's small improvements in 'text' and 'data' size.
> 
> $ gcc --version
>   gcc (GCC) 7.2.1 20171128
> 
> Before:
>   text	   data	    bss	    dec	     hex	filename
>   9890457  3828702  1212364 14931523 e3d643	vmlinux
> 
> After:
>   text	   data	    bss	    dec	     hex	filename
>   9890437  3828670  1212364 14931471 e3d60f	vmlinux
> 
> Also I fixed a 'style problem' reported by 'scripts/checkpatch.pl'.
> 
>   WARNING: Missing a blank line after declarations
>   #53: FILE: mm/slab_common.c:286:
>   +		unsigned long ralign = cache_line_size();
>   +		while (size <= ralign / 2)
> 
> Signed-off-by: Byongho Lee <bhlee.kernel@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/slab.h        |  3 ---
>  mm/slab_common.c | 56 +++++++++++++++++++++++++++++---------------------------
>  2 files changed, 29 insertions(+), 30 deletions(-)
> 
> diff --git a/mm/slab.h b/mm/slab.h
> index 028cdc7df67e..e894889dc24a 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -79,9 +79,6 @@ extern const struct kmalloc_info_struct {
>  	unsigned long size;
>  } kmalloc_info[];
>  
> -unsigned long calculate_alignment(unsigned long flags,
> -		unsigned long align, unsigned long size);
> -
>  #ifndef CONFIG_SLOB
>  /* Kmalloc array related functions */
>  void setup_kmalloc_cache_index_table(void);
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 0d7fe71ff5e4..d25e7b56e20b 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -267,6 +267,35 @@ static inline void memcg_unlink_cache(struct kmem_cache *s)
>  }
>  #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
>  
> +/*
> + * Figure out what the alignment of the objects will be given a set of
> + * flags, a user specified alignment and the size of the objects.
> + */
> +static unsigned long calculate_alignment(unsigned long flags,
> +		unsigned long align, unsigned long size)
> +{
> +	/*
> +	 * If the user wants hardware cache aligned objects then follow that
> +	 * suggestion if the object is sufficiently large.
> +	 *
> +	 * The hardware cache alignment cannot override the specified
> +	 * alignment though. If that is greater then use it.
> +	 */
> +	if (flags & SLAB_HWCACHE_ALIGN) {
> +		unsigned long ralign;
> +
> +		ralign = cache_line_size();
> +		while (size <= ralign / 2)
> +			ralign /= 2;
> +		align = max(align, ralign);
> +	}
> +
> +	if (align < ARCH_SLAB_MINALIGN)
> +		align = ARCH_SLAB_MINALIGN;
> +
> +	return ALIGN(align, sizeof(void *));
> +}
> +
>  /*
>   * Find a mergeable slab cache
>   */
> @@ -337,33 +366,6 @@ struct kmem_cache *find_mergeable(size_t size, size_t align,
>  	return NULL;
>  }
>  
> -/*
> - * Figure out what the alignment of the objects will be given a set of
> - * flags, a user specified alignment and the size of the objects.
> - */
> -unsigned long calculate_alignment(unsigned long flags,
> -		unsigned long align, unsigned long size)
> -{
> -	/*
> -	 * If the user wants hardware cache aligned objects then follow that
> -	 * suggestion if the object is sufficiently large.
> -	 *
> -	 * The hardware cache alignment cannot override the specified
> -	 * alignment though. If that is greater then use it.
> -	 */
> -	if (flags & SLAB_HWCACHE_ALIGN) {
> -		unsigned long ralign = cache_line_size();
> -		while (size <= ralign / 2)
> -			ralign /= 2;
> -		align = max(align, ralign);
> -	}
> -
> -	if (align < ARCH_SLAB_MINALIGN)
> -		align = ARCH_SLAB_MINALIGN;
> -
> -	return ALIGN(align, sizeof(void *));
> -}
> -
>  static struct kmem_cache *create_cache(const char *name,
>  		size_t object_size, size_t size, size_t align,
>  		unsigned long flags, void (*ctor)(void *),
> -- 
> 2.15.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
