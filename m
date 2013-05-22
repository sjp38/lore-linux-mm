Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 59CD46B0002
	for <linux-mm@kvack.org>; Wed, 22 May 2013 00:40:27 -0400 (EDT)
Message-ID: <519C4CE2.4030204@cn.fujitsu.com>
Date: Wed, 22 May 2013 12:43:14 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 12/13] x86, numa, acpi, memory-hotplug: Make movablecore=acpi
 have higher priority.
References: <1367313683-10267-1-git-send-email-tangchen@cn.fujitsu.com> <1367313683-10267-13-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1367313683-10267-13-git-send-email-tangchen@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "vasilis.liaskovitis@profitbricks.com >> Vasilis Liaskovitis" <vasilis.liaskovitis@profitbricks.com>
Cc: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, tj@kernel.org, laijs@cn.fujitsu.com, davem@davemloft.net, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Vasilis,

Maybe the following two problems are the cause of the reboot panic
problem in qemu you mentioned.

On 04/30/2013 05:21 PM, Tang Chen wrote:
......
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index b9ea143..2fe9ebf 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4793,9 +4793,31 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>   	nodemask_t saved_node_state = node_states[N_MEMORY];
>   	unsigned long totalpages = early_calculate_totalpages();
>   	int usable_nodes = nodes_weight(node_states[N_MEMORY]);
> +	struct memblock_type *reserved =&memblock.reserved;
>

Need to call find_usable_zone_for_movable() here before goto out.

>   	/*
> -	 * If movablecore was specified, calculate what size of
> +	 * If movablecore=acpi was specified, then zone_movable_pfn[] has been
> +	 * initialized, and no more work needs to do.
> +	 * NOTE: In this case, we ignore kernelcore option.
> +	 */
> +	if (movablecore_enable_srat) {
> +		for (i = 0; i<  reserved->cnt; i++) {
> +			if (!memblock_is_hotpluggable(&reserved->regions[i]))
> +				continue;
> +
> +			nid = reserved->regions[i].nid;
> +
> +			usable_startpfn = reserved->regions[i].base;

Here, it should be PFN_DOWN(reserved->regions[i].base).

Thanks. :)

> +			zone_movable_pfn[nid] = zone_movable_pfn[nid] ?
> +				min(usable_startpfn, zone_movable_pfn[nid]) :
> +				usable_startpfn;
> +		}
> +
> +		goto out;
> +	}
> +
> +	/*
> +	 * If movablecore=nn[KMG] was specified, calculate what size of
>   	 * kernelcore that corresponds so that memory usable for
>   	 * any allocation type is evenly spread. If both kernelcore
>   	 * and movablecore are specified, then the value of kernelcore

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
