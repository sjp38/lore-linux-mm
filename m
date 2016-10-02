Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 67EAB6B0069
	for <linux-mm@kvack.org>; Sat,  1 Oct 2016 20:34:22 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id l68so59971546qkf.2
        for <linux-mm@kvack.org>; Sat, 01 Oct 2016 17:34:22 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id v186si7703523qkh.148.2016.10.01.17.34.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 01 Oct 2016 17:34:21 -0700 (PDT)
Subject: Re: [PATCH v2 1/1] mm/percpu.c: fix potential memory leakage for
 pcpu_embed_first_chunk()
References: <a93334ae-d0f2-957c-e1e5-8a5963d3d4c1@zoho.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <e5e25bfe-ca0c-b20e-0d2d-0f52b018161a@zoho.com>
Date: Sun, 2 Oct 2016 08:34:07 +0800
MIME-Version: 1.0
In-Reply-To: <a93334ae-d0f2-957c-e1e5-8a5963d3d4c1@zoho.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, akpm@linux-foundation.org
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com

Hi Tejun,
  as we discussed, i include some discussion content in the commit message.
could you give some new comments or acknowledgment for this patch?

On 2016/9/30 19:30, zijun_hu wrote:
> From: zijun_hu <zijun_hu@htc.com>
> 
> it will cause memory leakage for pcpu_embed_first_chunk() to go to
> label @out_free if the chunk spans over 3/4 VMALLOC area. all memory
> are allocated and recorded into array @areas for each CPU group, but
> the memory allocated aren't be freed before returning after going to
> label @out_free.
> 
> in order to fix this bug, we check chunk spanned area immediately
> after completing memory allocation for all CPU group, we go to label
> @out_free_areas other than @out_free to free all memory allocated if
> the checking is failed.
> 
> in order to verify the approach, we dump all memory allocated then
> enforce the jump then dump all memory freed, the result is okay after
> checking whether we free all memory we allocate in this function.
> 
> BTW, The approach is chosen after thinking over the below scenes
>  - we don't go to label @out_free directly to fix this issue since we
>    maybe free several allocated memory blocks twice
>  - the aim of jumping after pcpu_setup_first_chunk() is bypassing free
>    usable memory other than handling error, moreover, the function does
>    not return error code in any case, it either panics due to BUG_ON()
>    or return 0.
> 
> Signed-off-by: zijun_hu <zijun_hu@htc.com>
> Tested-by: zijun_hu <zijun_hu@htc.com>
> ---
>  this patch is based on mmotm/linux-next branch so can be
>  applied to them directly
> 
>  Changes in v2: 
>   - more detailed commit message is provided as discussed
>     with tj@kernel.org
> 
>  mm/percpu.c | 36 ++++++++++++++++++------------------
>  1 file changed, 18 insertions(+), 18 deletions(-)
> 
> diff --git a/mm/percpu.c b/mm/percpu.c
> index 41d9d0b35801..7a5dae185ce1 100644
> --- a/mm/percpu.c
> +++ b/mm/percpu.c
> @@ -1963,7 +1963,7 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
>  	struct pcpu_alloc_info *ai;
>  	size_t size_sum, areas_size;
>  	unsigned long max_distance;
> -	int group, i, rc;
> +	int group, i, j, rc;
>  
>  	ai = pcpu_build_alloc_info(reserved_size, dyn_size, atom_size,
>  				   cpu_distance_fn);
> @@ -1979,7 +1979,8 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
>  		goto out_free;
>  	}
>  
> -	/* allocate, copy and determine base address */
> +	/* allocate, copy and determine base address & max_distance */
> +	j = 0;
>  	for (group = 0; group < ai->nr_groups; group++) {
>  		struct pcpu_group_info *gi = &ai->groups[group];
>  		unsigned int cpu = NR_CPUS;
> @@ -2000,6 +2001,21 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
>  		areas[group] = ptr;
>  
>  		base = min(ptr, base);
> +		if (ptr > areas[j])
> +			j = group;
> +	}
> +	max_distance = areas[j] - base;
> +	max_distance += ai->unit_size * ai->groups[j].nr_units;
> +
> +	/* warn if maximum distance is further than 75% of vmalloc space */
> +	if (max_distance > VMALLOC_TOTAL * 3 / 4) {
> +		pr_warn("max_distance=0x%lx too large for vmalloc space 0x%lx\n",
> +				max_distance, VMALLOC_TOTAL);
> +#ifdef CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK
> +		/* and fail if we have fallback */
> +		rc = -EINVAL;
> +		goto out_free_areas;
> +#endif
>  	}
>  
>  	/*
> @@ -2024,24 +2040,8 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
>  	}
>  
>  	/* base address is now known, determine group base offsets */
> -	i = 0;
>  	for (group = 0; group < ai->nr_groups; group++) {
>  		ai->groups[group].base_offset = areas[group] - base;
> -		if (areas[group] > areas[i])
> -			i = group;
> -	}
> -	max_distance = ai->groups[i].base_offset +
> -		(unsigned long)ai->unit_size * ai->groups[i].nr_units;
> -
> -	/* warn if maximum distance is further than 75% of vmalloc space */
> -	if (max_distance > VMALLOC_TOTAL * 3 / 4) {
> -		pr_warn("max_distance=0x%lx too large for vmalloc space 0x%lx\n",
> -			max_distance, VMALLOC_TOTAL);
> -#ifdef CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK
> -		/* and fail if we have fallback */
> -		rc = -EINVAL;
> -		goto out_free;
> -#endif
>  	}
>  
>  	pr_info("Embedded %zu pages/cpu @%p s%zu r%zu d%zu u%zu\n",
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
