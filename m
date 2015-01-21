Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5E96B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 05:16:01 -0500 (EST)
Received: by mail-we0-f182.google.com with SMTP id l61so16934292wev.13
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 02:16:00 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f13si37558315wjq.94.2015.01.21.02.16.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 Jan 2015 02:16:00 -0800 (PST)
Message-ID: <54BF7C5E.6050503@suse.cz>
Date: Wed, 21 Jan 2015 11:15:58 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Don't offset memmap for flatmem
References: <1421804273-29947-1-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1421804273-29947-1-git-send-email-lauraa@codeaurora.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>, Srinivas Kandagatla <srinivas.kandagatla@linaro.org>, linux-arm-kernel@lists.infradead.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, ssantosh@kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Kevin Kilman <khilman@linaro.org>, Stephen Boyd <sboyd@codeaurora.org>, Arnd Bergman <arnd@arndb.de>, Kumar Gala <galak@codeaurora.org>, linux-mm@kvack.org

On 01/21/2015 02:37 AM, Laura Abbott wrote:
> Srinivas Kandagatla reported bad page messages when trying to
> remove the bottom 2MB on an ARM based IFC6410 board
> 
> BUG: Bad page state in process swapper  pfn:fffa8
> page:ef7fb500 count:0 mapcount:0 mapping:  (null) index:0x0
> flags: 0x96640253(locked|error|dirty|active|arch_1|reclaim|mlocked)
> page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
> bad because of flags:
> flags: 0x200041(locked|active|mlocked)
> Modules linked in:
> CPU: 0 PID: 0 Comm: swapper Not tainted 3.19.0-rc3-00007-g412f9ba-dirty #816
> Hardware name: Qualcomm (Flattened Device Tree)
> [<c0218280>] (unwind_backtrace) from [<c0212be8>] (show_stack+0x20/0x24)
> [<c0212be8>] (show_stack) from [<c0af7124>] (dump_stack+0x80/0x9c)
> [<c0af7124>] (dump_stack) from [<c0301570>] (bad_page+0xc8/0x128)
> [<c0301570>] (bad_page) from [<c03018a8>] (free_pages_prepare+0x168/0x1e0)
> [<c03018a8>] (free_pages_prepare) from [<c030369c>] (free_hot_cold_page+0x3c/0x174)
> [<c030369c>] (free_hot_cold_page) from [<c0303828>] (__free_pages+0x54/0x58)
> [<c0303828>] (__free_pages) from [<c030395c>] (free_highmem_page+0x38/0x88)
> [<c030395c>] (free_highmem_page) from [<c0f62d5c>] (mem_init+0x240/0x430)
> [<c0f62d5c>] (mem_init) from [<c0f5db3c>] (start_kernel+0x1e4/0x3c8)
> [<c0f5db3c>] (start_kernel) from [<80208074>] (0x80208074)
> Disabling lock debugging due to kernel taint
> 
> Removing the lower 2MB made the start of the lowmem zone to no longer
> be page block aligned. IFC6410 uses CONFIG_FLATMEM where
> alloc_node_mem_map allocates memory for the mem_map. alloc_node_mem_map
> will offset for unaligned nodes with the assumption the pfn/page
> translation functions will account for the offset. The functions for
> CONFIG_FLATMEM do not offset however, resulting in overrunning
> the memmap array. Just use the allocated memmap without any offset
> when running with CONFIG_FLATMEM to avoid the overrun.
> 
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
> Reported-by: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>
> ---
> Srinivas, can you test this version of the patch?
> ---
>  mm/page_alloc.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7633c50..33cef00 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5014,6 +5014,7 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
>  	if (!pgdat->node_mem_map) {
>  		unsigned long size, start, end;
>  		struct page *map;
> +		unsigned long offset = 0;
>  
>  		/*
>  		 * The zone's endpoints aren't required to be MAX_ORDER
> @@ -5021,6 +5022,8 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
>  		 * for the buddy allocator to function correctly.
>  		 */
>  		start = pgdat->node_start_pfn & ~(MAX_ORDER_NR_PAGES - 1);
> +		if (!IS_ENABLED(CONFIG_FLATMEM))
> +			offset = pgdat->node_start_pfn - start;
>  		end = pgdat_end_pfn(pgdat);
>  		end = ALIGN(end, MAX_ORDER_NR_PAGES);
>  		size =  (end - start) * sizeof(struct page);
> @@ -5028,7 +5031,7 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
>  		if (!map)
>  			map = memblock_virt_alloc_node_nopanic(size,
>  							       pgdat->node_id);
> -		pgdat->node_mem_map = map + (pgdat->node_start_pfn - start);
> +		pgdat->node_mem_map = map + offset;

Hmm, by this patch, you have changed not only mem_map, but also node_mem_map
itself. So the result of pgdat_page_nr() defined in mmzone.h will now be
different in the CONFIG_FLAT_NODE_MEM_MAP case?

#ifdef CONFIG_FLAT_NODE_MEM_MAP
#define pgdat_page_nr(pgdat, pagenr)    ((pgdat)->node_mem_map + (pagenr))
#else
#define pgdat_page_nr(pgdat, pagenr)    pfn_to_page((pgdat)->node_start_pfn +
(pagenr))
#define nid_page_nr(nid, pagenr)        pgdat_page_nr(NODE_DATA(nid),(pagenr))

It appears that nobody uses pgdat_page_nr, except nid_page_nr, which nobody
uses. But better not leave it broken, and there's also some arch-specific code
looking at node_mem_map directly (although not sure if this particular
combination of CONFIG_ parameters applies there). So it seems to me we should
rather apply the offset to node_mem_map in any case, but not apply it (i.e.
subtract it back) to mem_map for !CONFIG_FLATMEM?

Thanks.

>  	}
>  #ifndef CONFIG_NEED_MULTIPLE_NODES
>  	/*
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
