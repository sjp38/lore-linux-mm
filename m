Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5C12E6B0087
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 22:52:24 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id r10so611601pdi.31
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 19:52:24 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id n7si3117076pdp.72.2014.10.23.19.52.21
        for <linux-mm@kvack.org>;
        Thu, 23 Oct 2014 19:52:23 -0700 (PDT)
Date: Fri, 24 Oct 2014 11:53:25 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 3/4] mm: cma: Ensure that reservations never cross the
 low/high mem boundary
Message-ID: <20141024025325.GB15243@js1304-P5Q-DELUXE>
References: <1414074828-4488-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
 <1414074828-4488-4-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414074828-4488-4-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>

On Thu, Oct 23, 2014 at 05:33:47PM +0300, Laurent Pinchart wrote:
> Commit 95b0e655f914 ("ARM: mm: don't limit default CMA region only to
> low memory") extended CMA memory reservation to allow usage of high
> memory. It relied on commit f7426b983a6a ("mm: cma: adjust address limit
> to avoid hitting low/high memory boundary") to ensure that the reserved
> block never crossed the low/high memory boundary. While the
> implementation correctly lowered the limit, it failed to consider the
> case where the base..limit range crossed the low/high memory boundary
> with enough space on each side to reserve the requested size on either
> low or high memory.
> 
> Rework the base and limit adjustment to fix the problem. The function
> now starts by rejecting the reservation altogether for fixed
> reservations that cross the boundary, then adjust the limit if
> reservation from high memory is impossible, and finally first try to
> reserve from high memory first and then falls back to low memory.
> 
> Signed-off-by: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
> ---
>  mm/cma.c | 58 ++++++++++++++++++++++++++++++++++++++++++++--------------
>  1 file changed, 44 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/cma.c b/mm/cma.c
> index 6b14346..b83597b 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -247,23 +247,38 @@ int __init cma_declare_contiguous(phys_addr_t base,
>  		return -EINVAL;
>  
>  	/*
> -	 * adjust limit to avoid crossing low/high memory boundary for
> +	 * Adjust limit and base to avoid crossing low/high memory boundary for
>  	 * automatically allocated regions
>  	 */
> -	if (((limit == 0 || limit > memblock_end) &&
> -	     (memblock_end - size < highmem_start &&
> -	      memblock_end > highmem_start)) ||
> -	    (!fixed && limit > highmem_start && limit - size < highmem_start)) {
> -		limit = highmem_start;
> -	}
>  
> -	if (fixed && base < highmem_start && base+size > highmem_start) {
> +	/*
> +	 * If allocating at a fixed base the request region must not cross the
> +	 * low/high memory boundary.
> +	 */
> +	if (fixed && base < highmem_start && base + size > highmem_start) {
>  		ret = -EINVAL;
>  		pr_err("Region at %08lx defined on low/high memory boundary (%08lx)\n",
>  			(unsigned long)base, (unsigned long)highmem_start);
>  		goto err;
>  	}
>  
> +	/*
> +	 * If the limit is unspecified or above the memblock end, its effective
> +	 * value will be the memblock end. Set it explicitly to simplify further
> +	 * checks.
> +	 */
> +	if (limit == 0 || limit > memblock_end)
> +		limit = memblock_end;
> +
> +	/*
> +	 * If the limit is above the highmem start by less than the reserved
> +	 * size allocation in highmem won't be possible. Lower the limit to the
> +	 * lowmem end.
> +	 */
> +	if (limit > highmem_start && limit - size < highmem_start)
> +		limit = highmem_start;
> +
> +

How about removing this check?
Without this check, memblock_alloc_range would be failed and we can
go fallback correctly. So, this is redundant, IMO.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
