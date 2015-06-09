Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3F87F6B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 02:49:21 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so8237588pdj.3
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 23:49:20 -0700 (PDT)
Received: from mgwkm04.jp.fujitsu.com (mgwkm04.jp.fujitsu.com. [202.219.69.171])
        by mx.google.com with ESMTPS id rn15si7577193pab.62.2015.06.08.23.49.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 23:49:20 -0700 (PDT)
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id AB393AC0174
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 15:49:16 +0900 (JST)
Message-ID: <55768C56.9010604@jp.fujitsu.com>
Date: Tue, 09 Jun 2015 15:48:54 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 02/12] mm: introduce mirror_info
References: <55704A7E.5030507@huawei.com> <55704B55.1020403@huawei.com>
In-Reply-To: <55704B55.1020403@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/06/04 21:57, Xishi Qiu wrote:
> This patch introduces a new struct called "mirror_info", it is used to storage
> the mirror address range which reported by EFI or ACPI.
>
> TBD: call add_mirror_info() to fill it.
>
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>   arch/x86/mm/numa.c     |  3 +++
>   include/linux/mmzone.h | 15 +++++++++++++++
>   mm/page_alloc.c        | 33 +++++++++++++++++++++++++++++++++
>   3 files changed, 51 insertions(+)
>
> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> index 4053bb5..781fd68 100644
> --- a/arch/x86/mm/numa.c
> +++ b/arch/x86/mm/numa.c
> @@ -619,6 +619,9 @@ static int __init numa_init(int (*init_func)(void))
>   	/* In case that parsing SRAT failed. */
>   	WARN_ON(memblock_clear_hotplug(0, ULLONG_MAX));
>   	numa_reset_distance();
> +#ifdef CONFIG_MEMORY_MIRROR
> +	memset(&mirror_info, 0, sizeof(mirror_info));
> +#endif
>
>   	ret = init_func();
>   	if (ret < 0)
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 54d74f6..1fae07b 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -69,6 +69,21 @@ enum {
>   #  define is_migrate_cma(migratetype) false
>   #endif
>
> +#ifdef CONFIG_MEMORY_MIRROR
> +struct numa_mirror_info {
> +	int node;
> +	unsigned long start;
> +	unsigned long size;
> +};
> +
> +struct mirror_info {
> +	int count;
> +	struct numa_mirror_info info[MAX_NUMNODES];
> +};

MAX_NUMNODE may not be enough when the firmware cannot use contiguous
address for mirroing.


> +
> +extern struct mirror_info mirror_info;
> +#endif

If this structure will not be updated after boot, read_mostly should be
helpful.


> +
>   #define for_each_migratetype_order(order, type) \
>   	for (order = 0; order < MAX_ORDER; order++) \
>   		for (type = 0; type < MIGRATE_TYPES; type++)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ebffa0e..41a95a7 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -210,6 +210,10 @@ static char * const zone_names[MAX_NR_ZONES] = {
>   int min_free_kbytes = 1024;
>   int user_min_free_kbytes = -1;
>
> +#ifdef CONFIG_MEMORY_MIRROR
> +struct mirror_info mirror_info;
> +#endif
> +
>   static unsigned long __meminitdata nr_kernel_pages;
>   static unsigned long __meminitdata nr_all_pages;
>   static unsigned long __meminitdata dma_reserve;
> @@ -545,6 +549,31 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
>   	return 0;
>   }
>
> +#ifdef CONFIG_MEMORY_MIRROR
> +static void __init add_mirror_info(int node,
> +			unsigned long start, unsigned long size)
> +{
> +	mirror_info.info[mirror_info.count].node = node;
> +	mirror_info.info[mirror_info.count].start = start;
> +	mirror_info.info[mirror_info.count].size = size;
> +
> +	mirror_info.count++;
> +}
> +
> +static void __init print_mirror_info(void)
> +{
> +	int i;
> +
> +	printk("Mirror info\n");
> +	for (i = 0; i < mirror_info.count; i++)
> +		printk("  node %3d: [mem %#010lx-%#010lx]\n",
> +			mirror_info.info[i].node,
> +			mirror_info.info[i].start,
> +			mirror_info.info[i].start +
> +				mirror_info.info[i].size - 1);
> +}
> +#endif
> +
>   /*
>    * Freeing function for a buddy system allocator.
>    *
> @@ -5438,6 +5467,10 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
>   			       (u64)zone_movable_pfn[i] << PAGE_SHIFT);
>   	}
>
> +#ifdef CONFIG_MEMORY_MIRROR
> +	print_mirror_info();
> +#endif
> +
>   	/* Print out the early node map */
>   	pr_info("Early memory node ranges\n");
>   	for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid)
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
