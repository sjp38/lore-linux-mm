Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id C38626B004D
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 12:03:25 -0500 (EST)
Received: by mail-ee0-f43.google.com with SMTP id c41so1646573eek.30
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 09:03:25 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p46si7606580eem.231.2014.01.16.09.03.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 09:03:24 -0800 (PST)
Date: Thu, 16 Jan 2014 17:03:19 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH RESEND part2 v2 8/8] x86, numa, acpi, memory-hotplug:
 Make movable_node have higher priority
Message-ID: <20140116170253.GA24740@suse.de>
References: <529D3FC0.6000403@cn.fujitsu.com>
 <529D423F.3030200@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <529D423F.3030200@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Chen Tang <imtangchen@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>

On Tue, Dec 03, 2013 at 10:30:23AM +0800, Zhang Yanfei wrote:
> From: Tang Chen <tangchen@cn.fujitsu.com>
> 
> If users specify the original movablecore=nn@ss boot option, the kernel will
> arrange [ss, ss+nn) as ZONE_MOVABLE. The kernelcore=nn@ss boot option is similar
> except it specifies ZONE_NORMAL ranges.
> 
> Now, if users specify "movable_node" in kernel commandline, the kernel will
> arrange hotpluggable memory in SRAT as ZONE_MOVABLE. And if users do this, all
> the other movablecore=nn@ss and kernelcore=nn@ss options should be ignored.
> 
> For those who don't want this, just specify nothing. The kernel will act as
> before.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  mm/page_alloc.c |   28 ++++++++++++++++++++++++++--
>  1 files changed, 26 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index dd886fa..768ea0e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5021,9 +5021,33 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>  	nodemask_t saved_node_state = node_states[N_MEMORY];
>  	unsigned long totalpages = early_calculate_totalpages();
>  	int usable_nodes = nodes_weight(node_states[N_MEMORY]);
> +	struct memblock_type *type = &memblock.memory;
> +
> +	/* Need to find movable_zone earlier when movable_node is specified. */
> +	find_usable_zone_for_movable();
> +
> +	/*
> +	 * If movable_node is specified, ignore kernelcore and movablecore
> +	 * options.
> +	 */
> +	if (movable_node_is_enabled()) {
> +		for (i = 0; i < type->cnt; i++) {
> +			if (!memblock_is_hotpluggable(&type->regions[i]))
> +				continue;
> +
> +			nid = type->regions[i].nid;
> +
> +			usable_startpfn = PFN_DOWN(type->regions[i].base);
> +			zone_movable_pfn[nid] = zone_movable_pfn[nid] ?
> +				min(usable_startpfn, zone_movable_pfn[nid]) :
> +				usable_startpfn;
> +		}
> +
> +		goto out2;

out2 is not the most descriptive variable that ever existed. out_align?

There is an assumption here that the hot-pluggable regions of memory
are always at the upper end of the physical address space for that NUMA
node. What prevents the hardware having something like

node0:	0-4G	Not removable
node0:	4-8G	Removable
node0:	8-12G	Not removable

?

By the looks of things, the current code would make ZONE_MOVABLE for the
while 4-12G range of memory even though the 8-12G region cannot be
hot-removed. That would compound any problems related to lowmem-like
pressure as the 8-12G region cannot be used for kernel allocations like
inodes.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
