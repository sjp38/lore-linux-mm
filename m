Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AB9F06B0629
	for <linux-mm@kvack.org>; Thu, 10 May 2018 12:30:27 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e20-v6so1395154pff.14
        for <linux-mm@kvack.org>; Thu, 10 May 2018 09:30:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j62-v6si954461pgd.242.2018.05.10.09.30.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 10 May 2018 09:30:26 -0700 (PDT)
Date: Thu, 10 May 2018 09:30:23 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v1] include/linux/gfp.h: getting rid of GFP_ZONE_TABLE/BAD
Message-ID: <20180510163023.GB30442@bombadil.infradead.org>
References: <1525968625-40825-1-git-send-email-yehs1@lenovo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1525968625-40825-1-git-send-email-yehs1@lenovo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huaisheng Ye <yehs1@lenovo.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, alexander.levin@verizon.com, colyli@suse.de, chengnt@lenovo.com, linux-kernel@vger.kernel.org

On Fri, May 11, 2018 at 12:10:25AM +0800, Huaisheng Ye wrote:
> -#define __GFP_DMA	((__force gfp_t)___GFP_DMA)
> -#define __GFP_HIGHMEM	((__force gfp_t)___GFP_HIGHMEM)
> -#define __GFP_DMA32	((__force gfp_t)___GFP_DMA32)
> +#define __GFP_DMA	((__force gfp_t)OPT_ZONE_DMA ^ ZONE_NORMAL)
> +#define __GFP_HIGHMEM	((__force gfp_t)ZONE_MOVABLE ^ ZONE_NORMAL)
> +#define __GFP_DMA32	((__force gfp_t)OPT_ZONE_DMA32 ^ ZONE_NORMAL)

No, you've made gfp_zone even more complex than it already is.
If you can't use OPT_ZONE_HIGHMEM here, then this is a waste of time.

>  static inline enum zone_type gfp_zone(gfp_t flags)
>  {
>  	enum zone_type z;
> -	int bit = (__force int) (flags & GFP_ZONEMASK);
> +	z = ((__force unsigned int)flags & ___GFP_ZONE_MASK) ^ ZONE_NORMAL;
> +
> +	if (z > OPT_ZONE_HIGHMEM)
> +		z = OPT_ZONE_HIGHMEM +
> +			!!((__force unsigned int)flags & ___GFP_MOVABLE);
>  
> -	z = (GFP_ZONE_TABLE >> (bit * GFP_ZONES_SHIFT)) &
> -					 ((1 << GFP_ZONES_SHIFT) - 1);
> -	VM_BUG_ON((GFP_ZONE_BAD >> bit) & 1);
> +	VM_BUG_ON(z > ZONE_MOVABLE);
>  	return z;
>  }
