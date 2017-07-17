Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 78FC76B0292
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 14:57:20 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id k2so10830617qkf.10
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 11:57:20 -0700 (PDT)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id 8si16338794qkb.152.2017.07.17.11.57.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 11:57:19 -0700 (PDT)
Received: by mail-qt0-x242.google.com with SMTP id 19so3458895qty.1
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 11:57:19 -0700 (PDT)
Date: Mon, 17 Jul 2017 14:57:06 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 06/10] percpu: modify base_addr to be region specific
Message-ID: <20170717185705.GK3519177@devbig577.frc2.facebook.com>
References: <20170716022315.19892-1-dennisz@fb.com>
 <20170716022315.19892-7-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170716022315.19892-7-dennisz@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Christoph Lameter <cl@linux.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dennis Zhou <dennisszhou@gmail.com>

Hello,

On Sat, Jul 15, 2017 at 10:23:11PM -0400, Dennis Zhou wrote:
> From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>
> 
> Originally, the first chunk is served by up to three chunks, each given
> a region they are responsible for. Despite this, the arithmetic was based
> off of the base_addr making it require offsets or be overly inclusive.
> This patch changes percpu checks for first chunk to consider the only
> the dynamic region and the reserved check to be only the reserved
> region. There is no impact here besides making these checks a little
> more accurate.
> 
> This patch also adds the ground work increasing the minimum allocation
> size to 4 bytes. The new field nr_pages in pcpu_chunk will be used to
> keep track of the number of pages the bitmap serves. The arithmetic for
> identifying first chunk and reserved chunk reflect this change.

However small the patch might end up being, I'd much prefer changing
the minimum alloc size to be a separate patch with rationale.

> diff --git a/include/linux/percpu.h b/include/linux/percpu.h
> index 98a371c..a5cedcd 100644
> --- a/include/linux/percpu.h
> +++ b/include/linux/percpu.h
> @@ -21,6 +21,10 @@
>  /* minimum unit size, also is the maximum supported allocation size */
>  #define PCPU_MIN_UNIT_SIZE		PFN_ALIGN(32 << 10)
>  
> +/* minimum allocation size and shift in bytes */
> +#define PCPU_MIN_ALLOC_SIZE		(1 << PCPU_MIN_ALLOC_SHIFT)
> +#define PCPU_MIN_ALLOC_SHIFT		2

nitpick: Put SHIFT def above SIZE def?

> +/*
> + * Static addresses should never be passed into the allocator.  They
> + * are accessed using the group_offsets and therefore do not rely on
> + * chunk->base_addr.
> + */
>  static bool pcpu_addr_in_first_chunk(void *addr)
>  {
>  	void *first_start = pcpu_first_chunk->base_addr;
>  
> -	return addr >= first_start && addr < first_start + pcpu_unit_size;
> +	return addr >= first_start &&
> +	       addr < first_start +
> +	       pcpu_first_chunk->nr_pages * PAGE_SIZE;

Does the above line need line break?  If so, it'd probably be easier
to read if the broken line is indented (preferably to align with the
start of the sub expression).  e.g.

	return addr < first_start +
		      pcpu_first_chunk->nr_pages * PAGE_SIZE;

>  static bool pcpu_addr_in_reserved_chunk(void *addr)
>  {
> -	void *first_start = pcpu_first_chunk->base_addr;
> +	void *first_start;
>  
> -	return addr >= first_start &&
> -		addr < first_start + pcpu_reserved_chunk_limit;
> +	if (!pcpu_reserved_chunk)
> +		return false;
> +
> +	first_start = pcpu_reserved_chunk->base_addr;
> +
> +	return addr >= first_start + pcpu_reserved_offset &&
> +	       addr < first_start +
> +	       pcpu_reserved_chunk->nr_pages * PAGE_SIZE;

Ditto on indentation.

> @@ -1366,10 +1388,17 @@ phys_addr_t per_cpu_ptr_to_phys(void *addr)
>  	 * The following test on unit_low/high isn't strictly
>  	 * necessary but will speed up lookups of addresses which
>  	 * aren't in the first chunk.
> +	 *
> +	 * The address check is of high granularity checking against full
> +	 * chunk sizes.  pcpu_base_addr points to the beginning of the first
> +	 * chunk including the static region.  This allows us to examine all
> +	 * regions of the first chunk. Assumes good intent as the first
> +	 * chunk may not be full (ie. < pcpu_unit_pages in size).
>  	 */
> -	first_low = pcpu_chunk_addr(pcpu_first_chunk, pcpu_low_unit_cpu, 0);
> -	first_high = pcpu_chunk_addr(pcpu_first_chunk, pcpu_high_unit_cpu,
> -				     pcpu_unit_pages);
> +	first_low = (unsigned long) pcpu_base_addr +
                                   ^
			 no space for type casts

> @@ -1575,6 +1604,8 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
>  	unsigned int cpu;
>  	int *unit_map;
>  	int group, unit, i;
> +	unsigned long tmp_addr, aligned_addr;
> +	unsigned long map_size_bytes;

How about just map_size or map_bytes?

> @@ -1678,46 +1709,66 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
>  		INIT_LIST_HEAD(&pcpu_slot[i]);
>  
>  	/*
> -	 * Initialize static chunk.  If reserved_size is zero, the
> -	 * static chunk covers static area + dynamic allocation area
> -	 * in the first chunk.  If reserved_size is not zero, it
> -	 * covers static area + reserved area (mostly used for module
> -	 * static percpu allocation).
> +	 * Initialize static chunk.
> +	 * The static region is dropped as those addresses are already
> +	 * allocated and do not rely on chunk->base_addr.
> +	 * reserved_size == 0:
> +	 *      the static chunk covers the dynamic area
> +	 * reserved_size > 0:
> +	 *      the static chunk covers the reserved area
> +	 *
> +	 * If the static area is not page aligned, the region adjacent
> +	 * to the static area must have its base_addr be offset into
> +	 * the static area to have it be page aligned.  The overlap is
> +	 * then allocated preserving the alignment in the metadata for
> +	 * the actual region.

We can address this later but static chunk not covering static area is
kinda confusing.  The original complication came from trying to make
the static chunk service either reserved or first dynamic chunk.  We
don't need that anymore and might as well use separate rchunk and
dchunk.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
