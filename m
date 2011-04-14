Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2D027900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 17:55:57 -0400 (EDT)
Date: Thu, 14 Apr 2011 14:54:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: fail GFP_DMA allocations when ZONE_DMA is not
 configured
Message-Id: <20110414145458.f9bb7744.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1104141443260.13286@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1104141443260.13286@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

On Thu, 14 Apr 2011 14:46:56 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> The page allocator will improperly return a page from ZONE_NORMAL even 
> when __GFP_DMA is passed if CONFIG_ZONE_DMA is disabled.  The caller 
> expects DMA memory, perhaps for ISA devices with 16-bit address 
> registers, and may get higher memory resulting in undefined behavior.
> 
> This patch causes the page allocator to return NULL in such circumstances 
> with a warning emitted to the kernel log on the first occurrence.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/page_alloc.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2225,6 +2225,10 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  
>  	if (should_fail_alloc_page(gfp_mask, order))
>  		return NULL;
> +#ifndef CONFIG_ZONE_DMA
> +	if (WARN_ON_ONCE(gfp_mask & __GFP_DMA))
> +		return NULL;
> +#endif

Worried.  We have a large number of drivers which use GFP_DMA and I bet
some of them didn't really need to set it, and can use DMA32 memory. 
They will now break.

What is drivers/pci/intel-iommu.c doing with GFP_DMA btw?

How commonly are people disabling ZONE_DMA?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
