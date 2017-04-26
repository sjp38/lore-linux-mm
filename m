Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id BDEE46B02E1
	for <linux-mm@kvack.org>; Wed, 26 Apr 2017 10:47:53 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g67so260801wrd.0
        for <linux-mm@kvack.org>; Wed, 26 Apr 2017 07:47:53 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a82si6840127wma.159.2017.04.26.07.47.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Apr 2017 07:47:52 -0700 (PDT)
Date: Wed, 26 Apr 2017 16:47:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] Remove hardcoding of ___GFP_xxx bitmasks
Message-ID: <20170426144750.GH12504@dhcp22.suse.cz>
References: <20170426133549.22603-1-igor.stoppa@huawei.com>
 <20170426133549.22603-2-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170426133549.22603-2-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: namhyung@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 26-04-17 16:35:49, Igor Stoppa wrote:
> The bitmasks used for ___GFP_xxx can be defined in terms of an enum,
> which doesn't require manual updates to its values.

GFP masks are rarely updated so why is this worth doing?

> As bonus, __GFP_BITS_SHIFT is automatically kept consistent.

this alone doesn't sound like a huge win to me, to be honest. We already
have ___GFP_$FOO and __GFP_FOO you are adding __GFP_$FOO_SHIFT. This is
too much IMHO.

Also the current mm tree has ___GFP_NOLOCKDEP which is not addressed
here so I suspect you have based your change on the Linus tree.

> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
> ---
>  include/linux/gfp.h | 82 +++++++++++++++++++++++++++++++++++------------------
>  1 file changed, 55 insertions(+), 27 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 0fe0b62..2f894c5 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -14,33 +14,62 @@ struct vm_area_struct;
>   * include/trace/events/mmflags.h and tools/perf/builtin-kmem.c
>   */
>  
> +enum gfp_bitmask_shift {
> +	__GFP_DMA_SHIFT = 0,
> +	__GFP_HIGHMEM_SHIFT,
> +	__GFP_DMA32_SHIFT,
> +	__GFP_MOVABLE_SHIFT,
> +	__GFP_RECLAIMABLE_SHIFT,
> +	__GFP_HIGH_SHIFT,
> +	__GFP_IO_SHIFT,
> +	__GFP_FS_SHIFT,
> +	__GFP_COLD_SHIFT,
> +	__GFP_NOWARN_SHIFT,
> +	__GFP_REPEAT_SHIFT,
> +	__GFP_NOFAIL_SHIFT,
> +	__GFP_NORETRY_SHIFT,
> +	__GFP_MEMALLOC_SHIFT,
> +	__GFP_COMP_SHIFT,
> +	__GFP_ZERO_SHIFT,
> +	__GFP_NOMEMALLOC_SHIFT,
> +	__GFP_HARDWALL_SHIFT,
> +	__GFP_THISNODE_SHIFT,
> +	__GFP_ATOMIC_SHIFT,
> +	__GFP_ACCOUNT_SHIFT,
> +	__GFP_NOTRACK_SHIFT,
> +	__GFP_DIRECT_RECLAIM_SHIFT,
> +	__GFP_WRITE_SHIFT,
> +	__GFP_KSWAPD_RECLAIM_SHIFT,
> +	__GFP_BITS_SHIFT
> +};
> +
> +
>  /* Plain integer GFP bitmasks. Do not use this directly. */
> -#define ___GFP_DMA		0x01u
> -#define ___GFP_HIGHMEM		0x02u
> -#define ___GFP_DMA32		0x04u
> -#define ___GFP_MOVABLE		0x08u
> -#define ___GFP_RECLAIMABLE	0x10u
> -#define ___GFP_HIGH		0x20u
> -#define ___GFP_IO		0x40u
> -#define ___GFP_FS		0x80u
> -#define ___GFP_COLD		0x100u
> -#define ___GFP_NOWARN		0x200u
> -#define ___GFP_REPEAT		0x400u
> -#define ___GFP_NOFAIL		0x800u
> -#define ___GFP_NORETRY		0x1000u
> -#define ___GFP_MEMALLOC		0x2000u
> -#define ___GFP_COMP		0x4000u
> -#define ___GFP_ZERO		0x8000u
> -#define ___GFP_NOMEMALLOC	0x10000u
> -#define ___GFP_HARDWALL		0x20000u
> -#define ___GFP_THISNODE		0x40000u
> -#define ___GFP_ATOMIC		0x80000u
> -#define ___GFP_ACCOUNT		0x100000u
> -#define ___GFP_NOTRACK		0x200000u
> -#define ___GFP_DIRECT_RECLAIM	0x400000u
> -#define ___GFP_WRITE		0x800000u
> -#define ___GFP_KSWAPD_RECLAIM	0x1000000u
> -/* If the above are modified, __GFP_BITS_SHIFT may need updating */
> +#define ___GFP_DMA		(1u << __GFP_DMA_SHIFT)
> +#define ___GFP_HIGHMEM		(1u << __GFP_HIGHMEM_SHIFT)
> +#define ___GFP_DMA32		(1u << __GFP_DMA32_SHIFT)
> +#define ___GFP_MOVABLE		(1u << __GFP_MOVABLE_SHIFT)
> +#define ___GFP_RECLAIMABLE	(1u << __GFP_RECLAIMABLE_SHIFT)
> +#define ___GFP_HIGH		(1u << __GFP_HIGH_SHIFT)
> +#define ___GFP_IO		(1u << __GFP_IO_SHIFT)
> +#define ___GFP_FS		(1u << __GFP_FS_SHIFT)
> +#define ___GFP_COLD		(1u << __GFP_COLD_SHIFT)
> +#define ___GFP_NOWARN		(1u << __GFP_NOWARN_SHIFT)
> +#define ___GFP_REPEAT		(1u << __GFP_REPEAT_SHIFT)
> +#define ___GFP_NOFAIL		(1u << __GFP_NOFAIL_SHIFT)
> +#define ___GFP_NORETRY		(1u << __GFP_NORETRY_SHIFT)
> +#define ___GFP_MEMALLOC		(1u << __GFP_MEMALLOC_SHIFT)
> +#define ___GFP_COMP		(1u << __GFP_COMP_SHIFT)
> +#define ___GFP_ZERO		(1u << __GFP_ZERO_SHIFT)
> +#define ___GFP_NOMEMALLOC	(1u << __GFP_NOMEMALLOC_SHIFT)
> +#define ___GFP_HARDWALL		(1u << __GFP_HARDWALL_SHIFT)
> +#define ___GFP_THISNODE		(1u << __GFP_THISNODE_SHIFT)
> +#define ___GFP_ATOMIC		(1u << __GFP_ATOMIC_SHIFT)
> +#define ___GFP_ACCOUNT		(1u << __GFP_ACCOUNT_SHIFT)
> +#define ___GFP_NOTRACK		(1u << __GFP_NOTRACK_SHIFT)
> +#define ___GFP_DIRECT_RECLAIM	(1u << __GFP_DIRECT_RECLAIM_SHIFT)
> +#define ___GFP_WRITE		(1u << __GFP_WRITE_SHIFT)
> +#define ___GFP_KSWAPD_RECLAIM	(1u << __GFP_KSWAPD_RECLAIM_SHIFT)
>  
>  /*
>   * Physical address zone modifiers (see linux/mmzone.h - low four bits)
> @@ -180,7 +209,6 @@ struct vm_area_struct;
>  #define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)
>  
>  /* Room for N __GFP_FOO bits */
> -#define __GFP_BITS_SHIFT 25
>  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
>  
>  /*
> -- 
> 2.9.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
