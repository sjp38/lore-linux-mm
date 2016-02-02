Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id E938A6B0009
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 00:39:25 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id w123so4154471pfb.0
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 21:39:25 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id tw5si29013077pac.131.2016.02.01.21.39.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Feb 2016 21:39:25 -0800 (PST)
Date: Mon, 1 Feb 2016 21:42:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH] mm: CONFIG_NR_ZONES_EXTENDED
Message-Id: <20160201214213.2bdf9b4e.akpm@linux-foundation.org>
In-Reply-To: <20160128061914.32541.97351.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20160128061914.32541.97351.stgit@dwillia2-desk3.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Mark <markk@clara.co.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Sudip Mukherjee <sudipm.mukherjee@gmail.com>

On Wed, 27 Jan 2016 22:19:14 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

> ZONE_DEVICE (merged in 4.3) and ZONE_CMA (proposed) are examples of new
> mm zones that are bumping up against the current maximum limit of 4
> zones, i.e. 2 bits in page->flags.  When adding a zone this equation
> still needs to be satisified:
> 
>     SECTIONS_WIDTH + ZONES_WIDTH + NODES_SHIFT + LAST_CPUPID_SHIFT
> 	  <= BITS_PER_LONG - NR_PAGEFLAGS
> 
> ZONE_DEVICE currently tries to satisfy this equation by requiring that
> ZONE_DMA be disabled, but this is untenable given generic kernels want
> to support ZONE_DEVICE and ZONE_DMA simultaneously.  ZONE_CMA would like
> to increase the amount of memory covered per section, but that limits
> the minimum granularity at which consecutive memory ranges can be added
> via devm_memremap_pages().
> 
> The trade-off of what is acceptable to sacrifice depends heavily on the
> platform.  For example, ZONE_CMA is targeted for 32-bit platforms where
> page->flags is constrained, but those platforms likely do not care about
> the minimum granularity of memory hotplug.  A big iron machine with 1024
> numa nodes can likely sacrifice ZONE_DMA where a general purpose
> distribution kernel can not.
> 
> CONFIG_NR_ZONES_EXTENDED is a configuration symbol that gets selected
> when the number of configured zones exceeds 4.  It documents the
> configuration symbols and definitions that get modified when ZONES_WIDTH
> is greater than 2.
> 
> For now, it steals a bit from NODES_SHIFT.  Later on it can be used to
> document the definitions that get modified when a 32-bit configuration
> wants more zone bits.

So if you want ZONE_DMA, you're limited to 512 NUMA nodes?

That seems reasonable.

> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -1409,8 +1409,10 @@ config NUMA_EMU
>  
>  config NODES_SHIFT
>  	int "Maximum NUMA Nodes (as a power of 2)" if !MAXSMP
> -	range 1 10
> -	default "10" if MAXSMP
> +	range 1 10 if !NR_ZONES_EXTENDED
> +	range 1 9 if NR_ZONES_EXTENDED
> +	default "10" if MAXSMP && !NR_ZONES_EXTENDED
> +	default "9" if MAXSMP && NR_ZONES_EXTENDED
>  	default "6" if X86_64
>  	default "3"
>  	depends on NEED_MULTIPLE_NODES
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 28ad5f6494b0..5979c2c80140 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -329,22 +329,29 @@ static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
>   *       0xe    => BAD (MOVABLE+DMA32+HIGHMEM)
>   *       0xf    => BAD (MOVABLE+DMA32+HIGHMEM+DMA)
>   *
> - * ZONES_SHIFT must be <= 2 on 32 bit platforms.
> + * GFP_ZONES_SHIFT must be <= 2 on 32 bit platforms.
>   */
>  
> -#if 16 * ZONES_SHIFT > BITS_PER_LONG
> -#error ZONES_SHIFT too large to create GFP_ZONE_TABLE integer
> +#if defined(CONFIG_ZONE_DEVICE) && (MAX_NR_ZONES-1) <= 4
> +/* ZONE_DEVICE is not a valid GFP zone specifier */
> +#define GFP_ZONES_SHIFT 2
> +#else
> +#define GFP_ZONES_SHIFT ZONES_SHIFT
> +#endif
> +
> +#if 16 * GFP_ZONES_SHIFT > BITS_PER_LONG
> +#error GFP_ZONES_SHIFT too large to create GFP_ZONE_TABLE integer
>  #endif
>  
>  #define GFP_ZONE_TABLE ( \
> -	(ZONE_NORMAL << 0 * ZONES_SHIFT)				      \
> -	| (OPT_ZONE_DMA << ___GFP_DMA * ZONES_SHIFT)			      \
> -	| (OPT_ZONE_HIGHMEM << ___GFP_HIGHMEM * ZONES_SHIFT)		      \
> -	| (OPT_ZONE_DMA32 << ___GFP_DMA32 * ZONES_SHIFT)		      \
> -	| (ZONE_NORMAL << ___GFP_MOVABLE * ZONES_SHIFT)			      \
> -	| (OPT_ZONE_DMA << (___GFP_MOVABLE | ___GFP_DMA) * ZONES_SHIFT)	      \
> -	| (ZONE_MOVABLE << (___GFP_MOVABLE | ___GFP_HIGHMEM) * ZONES_SHIFT)   \
> -	| (OPT_ZONE_DMA32 << (___GFP_MOVABLE | ___GFP_DMA32) * ZONES_SHIFT)   \
> +	(ZONE_NORMAL << 0 * GFP_ZONES_SHIFT)					\
> +	| (OPT_ZONE_DMA << ___GFP_DMA * GFP_ZONES_SHIFT)			\
> +	| (OPT_ZONE_HIGHMEM << ___GFP_HIGHMEM * GFP_ZONES_SHIFT)		\
> +	| (OPT_ZONE_DMA32 << ___GFP_DMA32 * GFP_ZONES_SHIFT)		      	\
> +	| (ZONE_NORMAL << ___GFP_MOVABLE * GFP_ZONES_SHIFT)			\
> +	| (OPT_ZONE_DMA << (___GFP_MOVABLE | ___GFP_DMA) * GFP_ZONES_SHIFT)	\
> +	| (ZONE_MOVABLE << (___GFP_MOVABLE | ___GFP_HIGHMEM) * GFP_ZONES_SHIFT)	\
> +	| (OPT_ZONE_DMA32 << (___GFP_MOVABLE | ___GFP_DMA32) * GFP_ZONES_SHIFT)	\
>  )

Geeze.  Congrats on decrypting this stuff.  I hope.  Do you think it's
possible to comprehensibly document it all for the next poor soul who
ventures into it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
