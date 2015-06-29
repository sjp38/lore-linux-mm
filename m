Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id A084B6B0032
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 03:40:34 -0400 (EDT)
Received: by paceq1 with SMTP id eq1so100934513pac.3
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 00:40:34 -0700 (PDT)
Received: from mgwym04.jp.fujitsu.com (mgwym04.jp.fujitsu.com. [211.128.242.43])
        by mx.google.com with ESMTPS id qz9si63130864pab.204.2015.06.29.00.40.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jun 2015 00:40:33 -0700 (PDT)
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by yt-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 13AE0AC01B7
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 16:40:29 +0900 (JST)
Message-ID: <5590F648.2080808@jp.fujitsu.com>
Date: Mon, 29 Jun 2015 16:39:52 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC v2 PATCH 4/8] mm: add mirrored memory to buddy system
References: <558E084A.60900@huawei.com> <558E09A1.2090102@huawei.com>
In-Reply-To: <558E09A1.2090102@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, leon@leon.nu, Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/06/27 11:25, Xishi Qiu wrote:
> Before free bootmem, set mirrored pageblock's migratetype to MIGRATE_MIRROR, so
> they could free to buddy system's MIGRATE_MIRROR list.
> When set reserved memory, skip the mirrored memory.
>
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>   include/linux/memblock.h |  3 +++
>   mm/memblock.c            | 21 +++++++++++++++++++++
>   mm/nobootmem.c           |  3 +++
>   mm/page_alloc.c          |  3 +++
>   4 files changed, 30 insertions(+)
>
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index 97f71ca..53be030 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -81,6 +81,9 @@ int memblock_mark_hotplug(phys_addr_t base, phys_addr_t size);
>   int memblock_clear_hotplug(phys_addr_t base, phys_addr_t size);
>   int memblock_mark_mirror(phys_addr_t base, phys_addr_t size);
>   ulong choose_memblock_flags(void);
> +#ifdef CONFIG_MEMORY_MIRROR
> +void memblock_mark_migratemirror(void);
> +#endif
>
>   /* Low level functions */
>   int memblock_add_range(struct memblock_type *type,
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 7612876..0d0b210 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -19,6 +19,7 @@
>   #include <linux/debugfs.h>
>   #include <linux/seq_file.h>
>   #include <linux/memblock.h>
> +#include <linux/page-isolation.h>
>
>   #include <asm-generic/sections.h>
>   #include <linux/io.h>
> @@ -818,6 +819,26 @@ int __init_memblock memblock_mark_mirror(phys_addr_t base, phys_addr_t size)
>   	return memblock_setclr_flag(base, size, 1, MEMBLOCK_MIRROR);
>   }
>
> +#ifdef CONFIG_MEMORY_MIRROR
> +void __init_memblock memblock_mark_migratemirror(void)
> +{
> +	unsigned long start_pfn, end_pfn, pfn;
> +	int i, node;
> +	struct page *page;
> +
> +	printk(KERN_DEBUG "Mirrored memory:\n");
> +	for_each_mirror_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn,
> +				&node) {
> +		printk(KERN_DEBUG "  node %3d: [mem %#010llx-%#010llx]\n",
> +			node, PFN_PHYS(start_pfn), PFN_PHYS(end_pfn) - 1);
> +		for (pfn = start_pfn; pfn < end_pfn;
> +				pfn += pageblock_nr_pages) {
> +			page = pfn_to_page(pfn);
> +			set_pageblock_migratetype(page, MIGRATE_MIRROR);
> +		}
> +	}
> +}
> +#endif
>
>   /**
>    * __next__mem_range - next function for for_each_free_mem_range() etc.
> diff --git a/mm/nobootmem.c b/mm/nobootmem.c
> index 5258386..31aa6d4 100644
> --- a/mm/nobootmem.c
> +++ b/mm/nobootmem.c
> @@ -129,6 +129,9 @@ static unsigned long __init free_low_memory_core_early(void)
>   	u64 i;
>
>   	memblock_clear_hotplug(0, -1);
> +#ifdef CONFIG_MEMORY_MIRROR
> +	memblock_mark_migratemirror();
> +#endif
>
>   	for_each_free_mem_range(i, NUMA_NO_NODE, MEMBLOCK_NONE, &start, &end,
>   				NULL)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6e4d79f..aea78a5 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4118,6 +4118,9 @@ static void setup_zone_migrate_reserve(struct zone *zone)
>
>   		block_migratetype = get_pageblock_migratetype(page);
>
> +		if (is_migrate_mirror(block_migratetype))
> +			continue;
> +

If mirrored area will not have reserved memory, this should break the page allocator's
logic.

I think both of mirrored and unmirrored range should have reserved area.

Thanks,
-Kame

>   		/* Only test what is necessary when the reserves are not met */
>   		if (reserve > 0) {
>   			/*
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
