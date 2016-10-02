Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 69EC26B0069
	for <linux-mm@kvack.org>; Sun,  2 Oct 2016 05:12:15 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l138so64931009wmg.3
        for <linux-mm@kvack.org>; Sun, 02 Oct 2016 02:12:15 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id s23si13509636wma.126.2016.10.02.02.12.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Oct 2016 02:12:14 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id b201so4737278wmb.1
        for <linux-mm@kvack.org>; Sun, 02 Oct 2016 02:12:13 -0700 (PDT)
Date: Sun, 2 Oct 2016 11:12:12 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 1/1] mm/percpu.c: fix potential memory leakage for
 pcpu_embed_first_chunk()
Message-ID: <20161002091212.GB13648@mtj.duckdns.org>
References: <a93334ae-d0f2-957c-e1e5-8a5963d3d4c1@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a93334ae-d0f2-957c-e1e5-8a5963d3d4c1@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: akpm@linux-foundation.org, zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com

Hello,

Sorry about the delay, have been traveling.

On Fri, Sep 30, 2016 at 07:30:28PM +0800, zijun_hu wrote:
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

It's often helpful to include what the impact of the bug is (here it's
fairly inconsequential) so that people reading the changelog can
decide how important the commit is.

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

Generally looks good to me but it's on top of the max_distance fix
patch which isn't applied yet and I think is pending update.  Can you
please update the previous patch or merge the two into one patch?

> @@ -1979,7 +1979,8 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
>  		goto out_free;
>  	}
>  
> -	/* allocate, copy and determine base address */
> +	/* allocate, copy and determine base address & max_distance */
> +	j = 0;

It'd be great if we can use a variable name which is more descriptive.
Something like highest_idx, maybe?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
