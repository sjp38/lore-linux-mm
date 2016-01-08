Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 394DF828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 12:02:44 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id e65so12146773pfe.0
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 09:02:44 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id be4si1419470pad.177.2016.01.08.09.02.43
        for <linux-mm@kvack.org>;
        Fri, 08 Jan 2016 09:02:43 -0800 (PST)
Subject: Re: [PATCH v4 2/2] mm/page_alloc.c: introduce kernelcore=mirror
 option
References: <1452241523-19559-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1452241613-19680-1-git-send-email-izumi.taku@jp.fujitsu.com>
From: Sudeep Holla <sudeep.holla@arm.com>
Message-ID: <568FEBAF.9040405@arm.com>
Date: Fri, 8 Jan 2016 17:02:39 +0000
MIME-Version: 1.0
In-Reply-To: <1452241613-19680-1-git-send-email-izumi.taku@jp.fujitsu.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Taku Izumi <izumi.taku@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Sudeep Holla <sudeep.holla@arm.com>, tony.luck@intel.com, qiuxishi@huawei.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, dave.hansen@intel.com, matt@codeblueprint.co.uk, arnd@arndb.de, steve.capper@linaro.org



On 08/01/16 08:26, Taku Izumi wrote:
> This patch extends existing "kernelcore" option and introduces
> kernelcore=mirror option.  By specifying "mirror" instead of specifying
> the amount of memory, non-mirrored (non-reliable) region will be arranged
> into ZONE_MOVABLE.
>
> v1 -> v2:
>   - Refine so that the following case also can be
>     handled properly:
>
>   Node X:  |MMMMMM------MMMMMM--------|
>     (legend) M: mirrored  -: not mirrrored
>
>   In this case, ZONE_NORMAL and ZONE_MOVABLE are
>   arranged like bellow:
>
>   Node X:  |MMMMMM------MMMMMM--------|
>            |ooooooxxxxxxooooooxxxxxxxx| ZONE_NORMAL
>                  |ooooooxxxxxxoooooooo| ZONE_MOVABLE
>     (legend) o: present  x: absent
>
> v2 -> v3:
>   - Fix build with CONFIG_HAVE_MEMBLOCK_NODE_MAP=n
>   - No functional change in case of CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
>
> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
> ---
>   Documentation/kernel-parameters.txt |  12 +++-
>   mm/page_alloc.c                     | 114 ++++++++++++++++++++++++++++++++++--
>   2 files changed, 119 insertions(+), 7 deletions(-)
>

[...]

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index efb8996..b528328 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -260,6 +260,7 @@ static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
>   static unsigned long __initdata required_kernelcore;
>   static unsigned long __initdata required_movablecore;
>   static unsigned long __meminitdata zone_movable_pfn[MAX_NUMNODES];
> +static bool mirrored_kernelcore;
>
>   /* movable_zone is the "real" zone pages in ZONE_MOVABLE are taken from */
>   int movable_zone;
> @@ -4613,6 +4614,9 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>   	unsigned long pfn;
>   	struct zone *z;
>   	unsigned long nr_initialised = 0;
> +#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
> +	struct memblock_region *r = NULL, *tmp;
> +#endif
>
>   	if (highest_memmap_pfn < end_pfn - 1)
>   		highest_memmap_pfn = end_pfn - 1;
> @@ -4639,6 +4643,40 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>   			if (!update_defer_init(pgdat, pfn, end_pfn,
>   						&nr_initialised))
>   				break;
> +
> +			/*
> +			 * if not mirrored_kernelcore and ZONE_MOVABLE exists,
> +			 * range from zone_movable_pfn[nid] to end of each node
> +			 * should be ZONE_MOVABLE not ZONE_NORMAL. skip it.
> +			 */
> +			if (!mirrored_kernelcore && zone_movable_pfn[nid])
> +				if (zone == ZONE_NORMAL &&
> +				    pfn >= zone_movable_pfn[nid])
> +					continue;
> +

I tried this with today's -next, the above lines gave compilation error.
Moved them below into HAVE_MEMBLOCK_NODE_MAP and tested it on ARM64.
I don't see the previous backtraces. Let me know if that's correct or
you can post a version that compiles correctly and I can give a try.

> +#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
> +			/*
> +			 * check given memblock attribute by firmware which
> +			 * can affect kernel memory layout.
> +			 * if zone==ZONE_MOVABLE but memory is mirrored,
> +			 * it's an overlapped memmap init. skip it.
> +			 */
> +			if (mirrored_kernelcore && zone == ZONE_MOVABLE) {
> +				if (!r ||
> +				    pfn >= memblock_region_memory_end_pfn(r)) {
> +					for_each_memblock(memory, tmp)
> +						if (pfn < memblock_region_memory_end_pfn(tmp))
> +							break;
> +					r = tmp;
> +				}
> +				if (pfn >= memblock_region_memory_base_pfn(r) &&
> +				    memblock_is_mirror(r)) {
> +					/* already initialized as NORMAL */
> +					pfn = memblock_region_memory_end_pfn(r);
> +					continue;
> +				}
> +			}
> +#endif
>   		}

-- 
Regards,
Sudeep

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
