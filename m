Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id C01F76B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 14:29:12 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so1698072pbc.14
        for <linux-mm@kvack.org>; Fri, 20 Apr 2012 11:29:12 -0700 (PDT)
Date: Fri, 20 Apr 2012 11:29:07 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: Weirdness in __alloc_bootmem_node_high
Message-ID: <20120420182907.GG32324@google.com>
References: <20120417155502.GE22687@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120417155502.GE22687@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: yinghai@kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 17, 2012 at 05:55:02PM +0200, Michal Hocko wrote:
> Hi,
> I just come across the following condition in __alloc_bootmem_node_high
> which I have hard times to understand. I guess it is a bug and we need
> something like the following. But, to be honest, I have no idea why we
> care about those 128MB above MAX_DMA32_PFN.
> ---
>  mm/bootmem.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/bootmem.c b/mm/bootmem.c
> index 0131170..5adb072 100644
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c
> @@ -737,7 +737,7 @@ void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
>  	/* update goal according ...MAX_DMA32_PFN */
>  	end_pfn = pgdat->node_start_pfn + pgdat->node_spanned_pages;
>  
> -	if (end_pfn > MAX_DMA32_PFN + (128 >> (20 - PAGE_SHIFT)) &&
> +	if (end_pfn > MAX_DMA32_PFN + (128 << (20 - PAGE_SHIFT)) &&
>  	    (goal >> PAGE_SHIFT) < MAX_DMA32_PFN) {
>  		void *ptr;
>  		unsigned long new_goal;

Regardless of x86 not using it, this is a bug fix and this code path
seems to be used by mips at least.  Michal, can you please post proper
signed-off patch?  The code is simply trying to use memory above DMA32
limit if there seems to be enough space (128M) to avoid unnecessarily
using DMA32 memory.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
