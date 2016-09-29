Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 71CAE6B0038
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 12:44:28 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id t4so1036532ywb.0
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 09:44:28 -0700 (PDT)
Received: from mail-yw0-x242.google.com (mail-yw0-x242.google.com. [2607:f8b0:4002:c05::242])
        by mx.google.com with ESMTPS id t77si3971879ybi.142.2016.09.29.09.44.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 09:44:27 -0700 (PDT)
Received: by mail-yw0-x242.google.com with SMTP id v2so3123295ywg.3
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 09:44:27 -0700 (PDT)
Date: Thu, 29 Sep 2016 18:44:22 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH 1/1] mm/percpu.c: fix potential memory leakage for
 pcpu_embed_first_chunk()
Message-ID: <20160929164422.GA3773@mtj.duckdns.org>
References: <d6742bae-1b32-10d8-1857-9993a2d06117@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d6742bae-1b32-10d8-1857-9993a2d06117@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, zijun_hu@htc.com, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Fri, Sep 30, 2016 at 12:03:20AM +0800, zijun_hu wrote:
> From: zijun_hu <zijun_hu@htc.com>
> 
> it will cause memory leakage for pcpu_embed_first_chunk() to go to
> label @out_free if the chunk spans over 3/4 VMALLOC area. all memory
> are allocated and recorded into array @areas for each CPU group, but
> the memory allocated aren't be freed before returning after going to
> label @out_free
> 
> in order to fix this bug, we check chunk spanned area immediately
> after completing memory allocation for all CPU group, we go to label
> @out_free_areas other than @out_free to free all memory allocated if
> the checking is failed.
> 
> Signed-off-by: zijun_hu <zijun_hu@htc.com>
...
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

Isn't it way simpler to make the error path jump to out_free_areas?
There's another similar case after pcpu_setup_first_chunk() failure
too.  Also, can you please explain how you tested the changes?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
