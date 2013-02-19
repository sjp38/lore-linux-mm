Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 036466B0005
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 05:07:49 -0500 (EST)
Received: by mail-gh0-f171.google.com with SMTP id r17so750747ghr.16
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 02:07:49 -0800 (PST)
Message-ID: <51234EEC.3010700@gmail.com>
Date: Tue, 19 Feb 2013 18:07:40 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] zsmalloc: Fix TLB coherency and build problem
References: <1359334808-19794-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1359334808-19794-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Matt Sealey <matt@genesi-usa.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Russell King <linux@arm.linux.org.uk>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>

On 01/28/2013 09:00 AM, Minchan Kim wrote:
> Recently, Matt Sealey reported he fail to build zsmalloc caused by
> using of local_flush_tlb_kernel_range which are architecture dependent
> function so !CONFIG_SMP in ARM couldn't implement it so it ends up
> build error following as.

Confuse me!

1) Why I see flush_tlb_kernel_range is different in different architecture?
2) Does local here means local cpu? If the answer is yes, why ARM 
doesn't support it?

>
>    MODPOST 216 modules
>    LZMA    arch/arm/boot/compressed/piggy.lzma
>    AS      arch/arm/boot/compressed/lib1funcs.o
> ERROR: "v7wbi_flush_kern_tlb_range"
> [drivers/staging/zsmalloc/zsmalloc.ko] undefined!
> make[1]: *** [__modpost] Error 1
> make: *** [modules] Error 2
> make: *** Waiting for unfinished jobs....
>
> The reason we used that function is copy method by [1]
> was really slow in ARM but at that time.
>
> More severe problem is ARM can prefetch speculatively on other CPUs
> so under us, other TLBs can have an entry only if we do flush local
> CPU. Russell King pointed that. Thanks!
> We don't have many choices except using flush_tlb_kernel_range.
>
> My experiment in ARMv7 processor 4 core didn't make any difference with
> zsmapbench[2] between local_flush_tlb_kernel_range and flush_tlb_kernel_range
> but still page-table based is much better than copy-based.
>
> * bigger is better.
>
> 1. local_flush_tlb_kernel_range: 3918795 mappings
> 2. flush_tlb_kernel_range : 3989538 mappings
> 3. copy-based: 635158 mappings
>
> This patch replace local_flush_tlb_kernel_range with
> flush_tlb_kernel_range which are avaialbe in all architectures
> because we already have used it in vmalloc allocator which are
> generic one so build problem should go away and performane loss
> shoud be void.
>
> [1] f553646, zsmalloc: add page table mapping method
> [2] https://github.com/spartacus06/zsmapbench
>
> Cc: stable@vger.kernel.org
> Cc: Dan Magenheimer <dan.magenheimer@oracle.com>
> Cc: Russell King <linux@arm.linux.org.uk>
> Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Reported-by: Matt Sealey <matt@genesi-usa.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>
> Matt, Could you test this patch?
>
>   drivers/staging/zsmalloc/zsmalloc-main.c |   10 ++++------
>   1 file changed, 4 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
> index eb00772..82e627c 100644
> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
> @@ -222,11 +222,9 @@ struct zs_pool {
>   /*
>    * By default, zsmalloc uses a copy-based object mapping method to access
>    * allocations that span two pages. However, if a particular architecture
> - * 1) Implements local_flush_tlb_kernel_range() and 2) Performs VM mapping
> - * faster than copying, then it should be added here so that
> - * USE_PGTABLE_MAPPING is defined. This causes zsmalloc to use page table
> - * mapping rather than copying
> - * for object mapping.
> + * performs VM mapping faster than copying, then it should be added here
> + * so that USE_PGTABLE_MAPPING is defined. This causes zsmalloc to use
> + * page table mapping rather than copying for object mapping.
>   */
>   #if defined(CONFIG_ARM)
>   #define USE_PGTABLE_MAPPING
> @@ -663,7 +661,7 @@ static inline void __zs_unmap_object(struct mapping_area *area,
>   
>   	flush_cache_vunmap(addr, end);
>   	unmap_kernel_range_noflush(addr, PAGE_SIZE * 2);
> -	local_flush_tlb_kernel_range(addr, end);
> +	flush_tlb_kernel_range(addr, end);
>   }
>   
>   #else /* USE_PGTABLE_MAPPING */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
