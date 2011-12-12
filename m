Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 239266B0176
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:19:57 -0500 (EST)
Date: Mon, 12 Dec 2011 14:19:53 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 03/11] mm: mmzone: introduce zone_pfn_same_memmap()
Message-ID: <20111212141953.GD3277@csn.ul.ie>
References: <1321634598-16859-1-git-send-email-m.szyprowski@samsung.com>
 <1321634598-16859-4-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1321634598-16859-4-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

On Fri, Nov 18, 2011 at 05:43:10PM +0100, Marek Szyprowski wrote:
> From: Michal Nazarewicz <mina86@mina86.com>
> 
> This commit introduces zone_pfn_same_memmap() function which checkes

s/checkes/checks/

> whether two PFNs within the same zone have struct pages within the
> same memmap. 

s/memmap/same sparsemem section/

> This check is needed because in general pointer
> arithmetic on struct pages may lead to invalid pointers.
> 
> On memory models that are not affected, zone_pfn_same_memmap() is
> defined as always returning true so the call should be optimised
> at compile time.
> 
> Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> ---
>  include/linux/mmzone.h |   16 ++++++++++++++++
>  mm/compaction.c        |    5 ++++-
>  2 files changed, 20 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 188cb2f..84e07d0 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1166,6 +1166,22 @@ static inline int memmap_valid_within(unsigned long pfn,
>  }
>  #endif /* CONFIG_ARCH_HAS_HOLES_MEMORYMODEL */
>  
> +#if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
> +/*
> + * Both PFNs must be from the same zone!  If this function returns

from the same sparsemem section, not the same zone. 

> + * true, pfn_to_page(pfn1) + (pfn2 - pfn1) == pfn_to_page(pfn2).
> + */
> +static inline bool zone_pfn_same_memmap(unsigned long pfn1, unsigned long pfn2)
> +{
> +	return pfn_to_section_nr(pfn1) == pfn_to_section_nr(pfn2);
> +}
> +
> +#else
> +
> +#define zone_pfn_same_memmap(pfn1, pfn2) (true)
> +
> +#endif
> +
>  #endif /* !__GENERATING_BOUNDS.H */
>  #endif /* !__ASSEMBLY__ */
>  #endif /* _LINUX_MMZONE_H */
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 6afae0e..09c9702 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -111,7 +111,10 @@ skip:
>  
>  next:
>  		pfn += isolated;
> -		page += isolated;
> +		if (zone_pfn_same_memmap(pfn - isolated, pfn))
> +			page += isolated;
> +		else
> +			page = pfn_to_page(pfn);
>  	}

Is this necessary?

We are isolating pages, the largest of which is a MAX_ORDER_NR_PAGES
page. Sections are never smaller than MAX_ORDER_NR_PAGES so the end
of the free range of pages should never be in another section. That
should mean that the PFN walk will always consider the first
PFN of every section and you can implement a simplier check than
zone_pfn_same_memmap based on pfn & PAGE_SECTION_MASK and contain it
within mm/compaction.c

That said, everywhere else managed to avoid checks like this by always
scanning in units of pageblocks. Maybe this should be structured
the same way to guarantee pfn_valid is called at least per pageblock
(even though only once per MAX_ORDER_NR_PAGES is necessary).

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
