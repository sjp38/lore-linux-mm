Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 551136B0253
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 02:50:22 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so78024271pad.1
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 23:50:22 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id r9si264374pap.24.2015.10.08.23.50.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Oct 2015 23:50:21 -0700 (PDT)
Message-ID: <561762DC.3080608@huawei.com>
Date: Fri, 9 Oct 2015 14:46:52 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC] mm: Introduce kernelcore=reliable option
References: <1444402599-15274-1-git-send-email-izumi.taku@jp.fujitsu.com>
In-Reply-To: <1444402599-15274-1-git-send-email-izumi.taku@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, akpm@linux-foundation.orgKamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave.hansen@intel.com>, Mel
 Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>

On 2015/10/9 22:56, Taku Izumi wrote:

> Xeon E7 v3 based systems supports Address Range Mirroring
> and UEFI BIOS complied with UEFI spec 2.5 can notify which
> ranges are reliable (mirrored) via EFI memory map.
> Now Linux kernel utilize its information and allocates
> boot time memory from reliable region.
> 
> My requirement is:
>   - allocate kernel memory from reliable region
>   - allocate user memory from non-reliable region
> 
> In order to meet my requirement, ZONE_MOVABLE is useful.
> By arranging non-reliable range into ZONE_MOVABLE,
> reliable memory is only used for kernel allocations.
> 

Hi Taku,

You mean set non-mirrored memory to movable zone, and set
mirrored memory to normal zone, right? So kernel allocations
will use mirrored memory in normal zone, and user allocations
will use non-mirrored memory in movable zone.

My question is:
1) do we need to change the fallback function?
2) the mirrored region should locate at the start of normal
zone, right?

I remember Kame has already suggested this idea. In my opinion,
I still think it's better to add a new migratetype or a new zone,
so both user and kernel could use mirrored memory.

Thanks,
Xishi Qiu

> This patch extends existing "kernelcore" option and
> introduces kernelcore=reliable option. By specifying
> "reliable" instead of specifying the amount of memory,
> non-reliable region will be arranged into ZONE_MOVABLE.
> 
> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
> ---
>  Documentation/kernel-parameters.txt |  9 ++++++++-
>  mm/page_alloc.c                     | 26 ++++++++++++++++++++++++++
>  2 files changed, 34 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index 50fc09b..6791cbb 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -1669,7 +1669,8 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>  
>  	keepinitrd	[HW,ARM]
>  
> -	kernelcore=nn[KMG]	[KNL,X86,IA-64,PPC] This parameter
> +	kernelcore=	Format: nn[KMG] | "reliable"
> +			[KNL,X86,IA-64,PPC] This parameter
>  			specifies the amount of memory usable by the kernel
>  			for non-movable allocations.  The requested amount is
>  			spread evenly throughout all nodes in the system. The
> @@ -1685,6 +1686,12 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>  			use the HighMem zone if it exists, and the Normal
>  			zone if it does not.
>  
> +			Instead of specifying the amount of memory (nn[KMS]),
> +			you can specify "reliable" option. In case "reliable"
> +			option is specified, reliable memory is used for
> +			non-movable allocations and remaining memory is used
> +			for Movable pages.
> +
>  	kgdbdbgp=	[KGDB,HW] kgdb over EHCI usb debug port.
>  			Format: <Controller#>[,poll interval]
>  			The controller # is the number of the ehci usb debug
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 48aaf7b..91d7556 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -242,6 +242,7 @@ static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
>  static unsigned long __initdata required_kernelcore;
>  static unsigned long __initdata required_movablecore;
>  static unsigned long __meminitdata zone_movable_pfn[MAX_NUMNODES];
> +static bool reliable_kernelcore __initdata;
>  
>  /* movable_zone is the "real" zone pages in ZONE_MOVABLE are taken from */
>  int movable_zone;
> @@ -5652,6 +5653,25 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>  	}
>  
>  	/*
> +	 * If kernelcore=reliable is specified, ignore movablecore option
> +	 */
> +	if (reliable_kernelcore) {
> +		for_each_memblock(memory, r) {
> +			if (memblock_is_mirror(r))
> +				continue;
> +
> +			nid = r->nid;
> +
> +			usable_startpfn = PFN_DOWN(r->base);
> +			zone_movable_pfn[nid] = zone_movable_pfn[nid] ?
> +				min(usable_startpfn, zone_movable_pfn[nid]) :
> +				usable_startpfn;
> +		}
> +
> +		goto out2;
> +	}
> +
> +	/*
>  	 * If movablecore=nn[KMG] was specified, calculate what size of
>  	 * kernelcore that corresponds so that memory usable for
>  	 * any allocation type is evenly spread. If both kernelcore
> @@ -5907,6 +5927,12 @@ static int __init cmdline_parse_core(char *p, unsigned long *core)
>   */
>  static int __init cmdline_parse_kernelcore(char *p)
>  {
> +	/* parse kernelcore=reliable */
> +	if (parse_option_str(p, "reliable")) {
> +		reliable_kernelcore = true;
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
