Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id A08946B0038
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 22:30:04 -0500 (EST)
Received: by oies6 with SMTP id s6so20587985oie.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 19:30:04 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id r5si1525189obf.99.2015.12.08.19.30.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 19:30:04 -0800 (PST)
Message-ID: <56679FDC.1080800@huawei.com>
Date: Wed, 9 Dec 2015 11:28:28 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/2] mm: Introduce kernelcore=mirror option
References: <1449631109-14756-1-git-send-email-izumi.taku@jp.fujitsu.com> <1449631177-14863-1-git-send-email-izumi.taku@jp.fujitsu.com>
In-Reply-To: <1449631177-14863-1-git-send-email-izumi.taku@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, tony.luck@intel.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, dave.hansen@intel.com, matt@codeblueprint.co.uk

On 2015/12/9 11:19, Taku Izumi wrote:

> This patch extends existing "kernelcore" option and
> introduces kernelcore=mirror option. By specifying
> "mirror" instead of specifying the amount of memory,
> non-mirrored (non-reliable) region will be arranged
> into ZONE_MOVABLE.
> 
> v1 -> v2:
>  - Refine so that the following case also can be
>    handled properly:
> 
>  Node X:  |MMMMMM------MMMMMM--------|
>    (legend) M: mirrored  -: not mirrrored
> 
>  In this case, ZONE_NORMAL and ZONE_MOVABLE are
>  arranged like bellow:
> 
>  Node X:  |MMMMMM------MMMMMM--------|
>           |ooooooxxxxxxooooooxxxxxxxx| ZONE_NORMAL
>                 |ooooooxxxxxxoooooooo| ZONE_MOVABLE
>    (legend) o: present  x: absent
> 
> v2 -> v3:
>  - change the option name from kernelcore=reliable
>    into kernelcore=mirror
>  - documentation fix so that users can understand
>    nn[KMS] and mirror are exclusive
> 
> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
> ---
>  Documentation/kernel-parameters.txt |  11 +++-
>  mm/page_alloc.c                     | 110 ++++++++++++++++++++++++++++++++++--
>  2 files changed, 114 insertions(+), 7 deletions(-)
> 
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index f8aae63..b0ffc76 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -1695,7 +1695,8 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>  
>  	keepinitrd	[HW,ARM]
>  
> -	kernelcore=nn[KMG]	[KNL,X86,IA-64,PPC] This parameter
> +	kernelcore=	Format: nn[KMG] | "mirror"
> +			[KNL,X86,IA-64,PPC] This parameter
>  			specifies the amount of memory usable by the kernel
>  			for non-movable allocations.  The requested amount is
>  			spread evenly throughout all nodes in the system. The
> @@ -1711,6 +1712,14 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>  			use the HighMem zone if it exists, and the Normal
>  			zone if it does not.
>  
> +			Instead of specifying the amount of memory (nn[KMS]),
> +			you can specify "mirror" option. In case "mirror"
> +			option is specified, mirrored (reliable) memory is used
> +			for non-movable allocations and remaining memory is used
> +			for Movable pages. nn[KMS] and "mirror" are exclusive,
> +			so you can NOT specify nn[KMG] and "mirror" at the same
> +			time.
> +

Hi Taku,

How about add some comment, if mirrored memroy is too small, then the
normal zone is small, so it may be oom.
The mirrored memory is at least 1/64 of whole memory, because struct
pages usually take 64 bytes per page.

Thanks,
Xishi Qiu

>  	kgdbdbgp=	[KGDB,HW] kgdb over EHCI usb debug port.
>  			Format: <Controller#>[,poll interval]
>  			The controller # is the number of the ehci usb debug
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index acb0b4e..4157476 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -251,6 +251,7 @@ static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
>  static unsigned long __initdata required_kernelcore;
>  static unsigned long __initdata required_movablecore;
>  static unsigned long __meminitdata zone_movable_pfn[MAX_NUMNODES];
> +static bool mirrored_kernelcore;
>  
>  /* movable_zone is the "real" zone pages in ZONE_MOVABLE are taken from */
>  int movable_zone;
> @@ -4472,6 +4473,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>  	unsigned long pfn;
>  	struct zone *z;
>  	unsigned long nr_initialised = 0;
> +	struct memblock_region *r = NULL, *tmp;
>  
>  	if (highest_memmap_pfn < end_pfn - 1)
>  		highest_memmap_pfn = end_pfn - 1;
> @@ -4491,6 +4493,38 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>  			if (!update_defer_init(pgdat, pfn, end_pfn,
>  						&nr_initialised))
>  				break;
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
>  		}
>  
>  		/*
> @@ -4909,11 +4943,6 @@ static void __meminit adjust_zone_range_for_zone_movable(int nid,
>  			*zone_end_pfn = min(node_end_pfn,
>  				arch_zone_highest_possible_pfn[movable_zone]);
>  
> -		/* Adjust for ZONE_MOVABLE starting within this range */
> -		} else if (*zone_start_pfn < zone_movable_pfn[nid] &&
> -				*zone_end_pfn > zone_movable_pfn[nid]) {
> -			*zone_end_pfn = zone_movable_pfn[nid];
> -
>  		/* Check if this whole range is within ZONE_MOVABLE */
>  		} else if (*zone_start_pfn >= zone_movable_pfn[nid])
>  			*zone_start_pfn = *zone_end_pfn;
> @@ -4998,6 +5027,7 @@ static unsigned long __meminit zone_absent_pages_in_node(int nid,
>  	unsigned long zone_low = arch_zone_lowest_possible_pfn[zone_type];
>  	unsigned long zone_high = arch_zone_highest_possible_pfn[zone_type];
>  	unsigned long zone_start_pfn, zone_end_pfn;
> +	unsigned long nr_absent;
>  
>  	/* When hotadd a new node from cpu_up(), the node should be empty */
>  	if (!node_start_pfn && !node_end_pfn)
> @@ -5009,7 +5039,39 @@ static unsigned long __meminit zone_absent_pages_in_node(int nid,
>  	adjust_zone_range_for_zone_movable(nid, zone_type,
>  			node_start_pfn, node_end_pfn,
>  			&zone_start_pfn, &zone_end_pfn);
> -	return __absent_pages_in_range(nid, zone_start_pfn, zone_end_pfn);
> +	nr_absent = __absent_pages_in_range(nid, zone_start_pfn, zone_end_pfn);
> +
> +	/*
> +	 * ZONE_MOVABLE handling.
> +	 * Treat pages to be ZONE_MOVABLE in ZONE_NORMAL as absent pages
> +	 * and vice versa.
> +	 */
> +	if (zone_movable_pfn[nid]) {
> +		if (mirrored_kernelcore) {
> +			unsigned long start_pfn, end_pfn;
> +			struct memblock_region *r;
> +
> +			for_each_memblock(memory, r) {
> +				start_pfn = clamp(memblock_region_memory_base_pfn(r),
> +						  zone_start_pfn, zone_end_pfn);
> +				end_pfn = clamp(memblock_region_memory_end_pfn(r),
> +						zone_start_pfn, zone_end_pfn);
> +
> +				if (zone_type == ZONE_MOVABLE &&
> +				    memblock_is_mirror(r))
> +					nr_absent += end_pfn - start_pfn;
> +
> +				if (zone_type == ZONE_NORMAL &&
> +				    !memblock_is_mirror(r))
> +					nr_absent += end_pfn - start_pfn;
> +			}
> +		} else {
> +			if (zone_type == ZONE_NORMAL)
> +				nr_absent += node_end_pfn - zone_movable_pfn[nid];
> +		}
> +	}
> +
> +	return nr_absent;
>  }
>  
>  #else /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
> @@ -5507,6 +5569,36 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>  	}
>  
>  	/*
> +	 * If kernelcore=mirror is specified, ignore movablecore option
> +	 */
> +	if (mirrored_kernelcore) {
> +		bool mem_below_4gb_not_mirrored = false;
> +
> +		for_each_memblock(memory, r) {
> +			if (memblock_is_mirror(r))
> +				continue;
> +
> +			nid = r->nid;
> +
> +			usable_startpfn = memblock_region_memory_base_pfn(r);
> +
> +			if (usable_startpfn < 0x100000) {
> +				mem_below_4gb_not_mirrored = true;
> +				continue;
> +			}
> +
> +			zone_movable_pfn[nid] = zone_movable_pfn[nid] ?
> +				min(usable_startpfn, zone_movable_pfn[nid]) :
> +				usable_startpfn;
> +		}
> +
> +		if (mem_below_4gb_not_mirrored)
> +			pr_warn("This configuration results in unmirrored kernel memory.");
> +
> +		goto out2;
> +	}
> +
> +	/*
>  	 * If movablecore=nn[KMG] was specified, calculate what size of
>  	 * kernelcore that corresponds so that memory usable for
>  	 * any allocation type is evenly spread. If both kernelcore
> @@ -5766,6 +5858,12 @@ static int __init cmdline_parse_core(char *p, unsigned long *core)
>   */
>  static int __init cmdline_parse_kernelcore(char *p)
>  {
> +	/* parse kernelcore=mirror */
> +	if (parse_option_str(p, "mirror")) {
> +		mirrored_kernelcore = true;
> +		return 0;
> +	}
> +
>  	return cmdline_parse_core(p, &required_kernelcore);
>  }
>  



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
