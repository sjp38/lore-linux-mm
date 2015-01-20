Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id DDE466B0032
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 04:54:58 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id l15so13371241wiw.4
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 01:54:58 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eo6si4297017wib.75.2015.01.20.01.54.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 01:54:57 -0800 (PST)
Message-ID: <54BE25EF.3060004@suse.cz>
Date: Tue, 20 Jan 2015 10:54:55 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: Issue on reserving memory with no-map flag  in  DT
References: <54B8F63C.1060300@linaro.org> <54B9ABAA.9060908@codeaurora.org> <54BD279E.1040709@suse.cz> <54BD99F7.8050603@codeaurora.org>
In-Reply-To: <54BD99F7.8050603@codeaurora.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>, Srinivas Kandagatla <srinivas.kandagatla@linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux@arm.linux.org.uk, ssantosh@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>
Cc: Kevin Hilman <khilman@linaro.org>, Stephen Boyd <sboyd@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Kumar Gala <galak@codeaurora.org>, linux-mm@kvack.org

On 01/20/2015 12:57 AM, Laura Abbott wrote:
> On 1/19/2015 7:49 AM, Vlastimil Babka wrote:
>> On 01/17/2015 01:24 AM, Laura Abbott wrote:
>>
>> I admit I may not see clearly through all the arch-specific layers and various
>> config option combinations that are possible here, so I might be misinterpreting
>> the code. But I think the problem here is not insufficient allocation size, but
>> something else.
>>
>> The code above continues by this line:
>>
>> 		pgdat->node_mem_map = map + (pgdat->node_start_pfn - start);
>>
>> So, size for the map allocation has already been calculated aligned to
>> MAX_ORDER_NR_PAGES before your patch, and node_mem_map points to the first
>> actually present page, which might be offset from the perfect alignment. Your
>> patch adds another offset to the already aligned size (but you use
>> pageblock_nr_pages which might be lower than MAX_ORDER_NR_PAGES; this seems like
>> a mistake in itself?). So with your patch we have map of aligned size starting
>> from the node_mem_map. This means the last offset-worth of struct pages should
>> be beyond what's needed to access struct page of pgdat_end_pfn(). If we need
>> that extra padding to prevent crashing, then it looks really suspicious...
>>
>> And when I look at node_mem_map usage, I see include/asm/generic/memory_model.h
>> defines __pfn_to_page as (basically)
>>
>> NODE_DATA(__nid)->node_mem_map + arch_local_page_offset(__pfn, __nid);\
>>
>> and further above is a generic definition of arch_local_page_offset:
>>
>> #define arch_local_page_offset(pfn, nid)        \
>>          ((pfn) - NODE_DATA(nid)->node_start_pfn)
>>
>> So it looks correct to me without your patch. The map is allocated aligned,
>> node_mem_map points to this map at the offset corresponding to node_start_pfn,
>> and pfn_to_page subtracts node_start_pfn to get the offset relative to
>> node_mem_map. We shouldn't need the extra padding by the node_start_pfn offset,
>> unless something else is misbehaving here.
>>
>> In the issue fixed by 7c45512 that you refer to, the problem was basically that
>> the allocation didn't use aligned size, but this looks different to me?
>>
>>
> 
> With this hard coded debugging:
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7633c50..241b870 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5029,6 +5029,11 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
>                          map = memblock_virt_alloc_node_nopanic(size,
>                                                                 pgdat->node_id);
>                  pgdat->node_mem_map = map + (pgdat->node_start_pfn - start);
> +               pr_err(">>> node_start_pfn %lx node_end_pfn %lx\n",
> +                       pgdat->node_start_pfn, pgdat_end_pfn(pgdat));
> +               pr_err(">>> size calculated %lx\n", size);
> +               pr_err(">>> allocated region %p-%lx\n", map, ((unsigned long)map)+size);
> +
>          }
>   #ifndef CONFIG_NEED_MULTIPLE_NODES
>          /*
> @@ -5043,6 +5048,8 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
>          }
>   #endif
>   #endif /* CONFIG_FLAT_NODE_MEM_MAP */
> +       pr_err(">>> pfn %lx page %p\n", 0x200, pfn_to_page(0x200));
> +       pr_err(">>> pfn %lx page %p\n", 0xbffff, pfn_to_page(0xbffff));
>   }
>   
>   void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
> 
> I get this output:
> [    0.000000] >>> node_start_pfn 200 node_end_pfn c0000
> [    0.000000] >>> size calculated 1800000
> [    0.000000] >>> allocated region edffa000-ef7fa000
> [    0.000000] >>> pfn 200 page ee002000
> [    0.000000] >>> pfn bffff page ef7fdfe0
> 
> The start and end pfn values are correct but that page value is outside of the
> allocated region for the memory map. This is a CONFIG_FLATMEM system so we
> aren't actually using arch_local_page_offset at all:
> 
> 
> #define __pfn_to_page(pfn)      (mem_map + ((pfn) - ARCH_PFN_OFFSET))
> #define __page_to_pfn(page)     ((unsigned long)((page) - mem_map) + \
>                                   ARCH_PFN_OFFSET)

Ah, OK. I searched just for node_mem_map and didn't notice it's also assigned to
mem_map.

> If you do the math, the array size is fine if we don't offset by the
> start but alloc_node_mem_map offsets assuming pfn_to_page will offset
> as well but this doesn't happen in CONFIG_FLATMEM.
> 
> Either alloc_node_mem_map needs to drop the offset or the pfn_to_page
> functions need to start adding the offset. It's worth noting that
> this gets corrected properly if we have CONFIG_HAVE_MEMBLOCK_NODE_MAP enabled
> so perhaps the fix is to unoffset for flatmem as well:
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7633c50..271c44b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5036,7 +5036,7 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
>           */
>          if (pgdat == NODE_DATA(0)) {
>                  mem_map = NODE_DATA(0)->node_mem_map;
> -#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
> +#if defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) || defined(CONFIG_FLATMEM)
>                  if (page_to_pfn(mem_map) != pgdat->node_start_pfn)
>                          mem_map -= (pgdat->node_start_pfn - ARCH_PFN_OFFSET);

But is this correcting the same thing? The offset that's added earlier is
(pgdat->node_start_pfn - start) where "start" is just alignment of the
node_start_pfn to MAX_ORDER_NR_PAGES. But here we subtract whole
pgdat->node_start_pfn, minus a ARCH_PFN_OFFSET constant. Is the constant always
equeal to the earlier value of "start", which is calculated dynamically?.

So I agree that mem_map assignment should be fixed, but maybe not exactly like this?

>   #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
> 
> Thanks,
> Laura
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
