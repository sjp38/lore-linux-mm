Date: Mon, 23 Jun 2008 09:00:48 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/2] hugetlb reservations: fix hugetlb MAP_PRIVATE reservations across vma splits
Message-ID: <20080623080048.GJ21597@csn.ul.ie>
References: <1213989474-5586-1-git-send-email-apw@shadowen.org> <1213989474-5586-3-git-send-email-apw@shadowen.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1213989474-5586-3-git-send-email-apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Jon Tollefson <kniht@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Typical. I spotted this after I pushed send.....

> <SNIP>

> @@ -266,14 +326,19 @@ static void decrement_hugepage_resv_vma(struct hstate *h,
>  		 * private mappings.
>  		 */
>  		if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
> -			unsigned long flags, reserve;
> +			unsigned long idx = vma_pagecache_offset(h,
> +							vma, address);
> +			struct resv_map *reservations = vma_resv_map(vma);
> +
>  			h->resv_huge_pages--;
> -			flags = (unsigned long)vma->vm_private_data &
> -							HPAGE_RESV_MASK;
> -			reserve = (unsigned long)vma->vm_private_data - 1;
> -			vma->vm_private_data = (void *)(reserve | flags);
> +
> +			/* Mark this page used in the map. */
> +			if (region_chg(&reservations->regions, idx, idx + 1) < 0)
> +				return -1;
> +			region_add(&reservations->regions, idx, idx + 1);
>  		}

decrement_hugepage_resv_vma() is called with hugetlb_lock held and region_chg
calls kmalloc(GFP_KERNEL).  Hence it's possible we would sleep with that
spinlock held which is a bit uncool. The allocation needs to happen outside
the lock. Right?

> <SNIP>

-- 
Mel Gorman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
