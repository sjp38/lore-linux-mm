Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E98736B0253
	for <linux-mm@kvack.org>; Sat, 28 Jan 2017 03:46:58 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c85so57314031wmi.6
        for <linux-mm@kvack.org>; Sat, 28 Jan 2017 00:46:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q192si5804265wme.11.2017.01.28.00.46.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 28 Jan 2017 00:46:57 -0800 (PST)
Subject: Re: [PATCH v2 1/3] mm: alloc_contig_range: allow to specify GFP mask
References: <20170127172328.18574-1-l.stach@pengutronix.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c0967c73-29a1-5b99-054c-9e209d4c69e4@suse.cz>
Date: Sat, 28 Jan 2017 09:46:50 +0100
MIME-Version: 1.0
In-Reply-To: <20170127172328.18574-1-l.stach@pengutronix.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lucas Stach <l.stach@pengutronix.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mips@linux-mips.org, Michal Hocko <mhocko@suse.com>, kvm@vger.kernel.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Max Filippov <jcmvbkbc@gmail.com>, "H . Peter Anvin" <hpa@zytor.com>, Joerg Roedel <joro@8bytes.org>, Russell King <linux@armlinux.org.uk>, patchwork-lst@pengutronix.de, Ingo Molnar <mingo@redhat.com>, linux-xtensa@linux-xtensa.org, kvm-ppc@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, Chris Zankel <chris@zankel.net>, linux-mm@kvack.org, Ralf Baechle <ralf@linux-mips.org>, iommu@lists.linux-foundation.org, kernel@pengutronix.de, Paolo Bonzini <pbonzini@redhat.com>, David Woodhouse <dwmw2@infradead.org>, Alexander Graf <agraf@suse.com>

On 01/27/2017 06:23 PM, Lucas Stach wrote:
> Currently alloc_contig_range assumes that the compaction should
> be done with the default GFP_KERNEL flags. This is probably
> right for all current uses of this interface, but may change as
> CMA is used in more use-cases (including being the default DMA
> memory allocator on some platforms).
>
> Change the function prototype, to allow for passing through the
> GFP mask set by upper layers.
>
> Also respect global restrictions by applying memalloc_noio_flags
> to the passed in flags.
>
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> Acked-by: Michal Hocko <mhocko@suse.com>


Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
> v2: add memalloc_noio restriction
> ---
>  include/linux/gfp.h | 2 +-
>  mm/cma.c            | 3 ++-
>  mm/hugetlb.c        | 3 ++-
>  mm/page_alloc.c     | 5 +++--
>  4 files changed, 8 insertions(+), 5 deletions(-)
>
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 4175dca4ac39..1efa221e0e1d 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -549,7 +549,7 @@ static inline bool pm_suspended_storage(void)
>  #if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
>  /* The below functions must be run on a range from a single zone. */
>  extern int alloc_contig_range(unsigned long start, unsigned long end,
> -			      unsigned migratetype);
> +			      unsigned migratetype, gfp_t gfp_mask);
>  extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
>  #endif
>
> diff --git a/mm/cma.c b/mm/cma.c
> index c960459eda7e..fbd67d866f67 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -407,7 +407,8 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align)
>
>  		pfn = cma->base_pfn + (bitmap_no << cma->order_per_bit);
>  		mutex_lock(&cma_mutex);
> -		ret = alloc_contig_range(pfn, pfn + count, MIGRATE_CMA);
> +		ret = alloc_contig_range(pfn, pfn + count, MIGRATE_CMA,
> +					 GFP_KERNEL);
>  		mutex_unlock(&cma_mutex);
>  		if (ret == 0) {
>  			page = pfn_to_page(pfn);
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 3edb759c5c7d..6ed8b160fc0d 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1051,7 +1051,8 @@ static int __alloc_gigantic_page(unsigned long start_pfn,
>  				unsigned long nr_pages)
>  {
>  	unsigned long end_pfn = start_pfn + nr_pages;
> -	return alloc_contig_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
> +	return alloc_contig_range(start_pfn, end_pfn, MIGRATE_MOVABLE,
> +				  GFP_KERNEL);
>  }
>
>  static bool pfn_range_valid_gigantic(struct zone *z,
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index eced9fee582b..c5a745b521c0 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7230,6 +7230,7 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
>   *			#MIGRATE_MOVABLE or #MIGRATE_CMA).  All pageblocks
>   *			in range must have the same migratetype and it must
>   *			be either of the two.
> + * @gfp_mask:	GFP mask to use during compaction
>   *
>   * The PFN range does not have to be pageblock or MAX_ORDER_NR_PAGES
>   * aligned, however it's the caller's responsibility to guarantee that
> @@ -7243,7 +7244,7 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
>   * need to be freed with free_contig_range().
>   */
>  int alloc_contig_range(unsigned long start, unsigned long end,
> -		       unsigned migratetype)
> +		       unsigned migratetype, gfp_t gfp_mask)
>  {
>  	unsigned long outer_start, outer_end;
>  	unsigned int order;
> @@ -7255,7 +7256,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>  		.zone = page_zone(pfn_to_page(start)),
>  		.mode = MIGRATE_SYNC,
>  		.ignore_skip_hint = true,
> -		.gfp_mask = GFP_KERNEL,
> +		.gfp_mask = memalloc_noio_flags(gfp_mask),
>  	};
>  	INIT_LIST_HEAD(&cc.migratepages);
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
