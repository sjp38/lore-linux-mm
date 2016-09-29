Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id EDA9128024C
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 06:35:09 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w84so69165339wmg.1
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 03:35:09 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id v10si13987582wja.54.2016.09.29.03.35.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 03:35:08 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id b184so10035563wma.3
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 03:35:08 -0700 (PDT)
Date: Thu, 29 Sep 2016 12:35:07 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RESEND PATCH 1/1] mm/percpu.c: correct max_distance calculation
 for pcpu_embed_first_chunk()
Message-ID: <20160929103507.GA25170@mtj.duckdns.org>
References: <7180d3c9-45d3-ffd2-cf8c-0d925f888a4d@zoho.com>
 <0310bf92-c8da-459f-58e3-40b8bfbb7223@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0310bf92-c8da-459f-58e3-40b8bfbb7223@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, zijun_hu@htc.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, cl@linux.com

Hello,

On Sat, Sep 24, 2016 at 07:20:49AM +0800, zijun_hu wrote:
> it is error to represent the max range max_distance spanned by all the
> group areas as the offset of the highest group area plus unit size in
> pcpu_embed_first_chunk(), it should equal to the offset plus the size
> of the highest group area
> 
> in order to fix this issue,let us find the highest group area who has the
> biggest base address among all the ones, then max_distance is formed by
> add it's offset and size value

 [PATCH] percpu: fix max_distance calculation in pcpu_embed_first_chunk()

 pcpu_embed_first_chunk() calculates the range a percpu chunk spans
 into max_distance and uses it to ensure that a chunk is not too big
 compared to the total vmalloc area.  However, during calculation, it
 used incorrect top address by adding a unit size to the higest
 group's base address.

 This can make the calculated max_distance slightly smaller than the
 actual distance although given the scale of values involved the error
 is very unlikely to have an actual impact.

 Fix this issue by adding the group's size instead of a unit size.

> the type of variant max_distance is changed from size_t to unsigned long
> to prevent potential overflow

This doesn't make any sense.  All the values involved are valid
addresses (or +1 of it), they can't overflow and size_t is the same
size as ulong.

> @@ -2025,17 +2026,18 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
>  	}
>  
>  	/* base address is now known, determine group base offsets */
> -	max_distance = 0;
> +	i = 0;
>  	for (group = 0; group < ai->nr_groups; group++) {
>  		ai->groups[group].base_offset = areas[group] - base;
> -		max_distance = max_t(size_t, max_distance,
> -				     ai->groups[group].base_offset);
> +		if (areas[group] > areas[i])
> +			i = group;
>  	}
> -	max_distance += ai->unit_size;
> +	max_distance = ai->groups[i].base_offset +
> +		(unsigned long)ai->unit_size * ai->groups[i].nr_units;

I don't think you need ulong cast here.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
