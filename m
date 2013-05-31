Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id D7FF96B0034
	for <linux-mm@kvack.org>; Fri, 31 May 2013 12:15:21 -0400 (EDT)
Received: by mail-wg0-f42.google.com with SMTP id n12so876024wgh.5
        for <linux-mm@kvack.org>; Fri, 31 May 2013 09:15:20 -0700 (PDT)
Date: Fri, 31 May 2013 18:15:16 +0200
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: Re: [PATCH v3 10/13] x86, acpi, numa, mem-hotplug: Introduce
 MEMBLK_HOTPLUGGABLE to mark and reserve hotpluggable memory.
Message-ID: <20130531161516.GA4407@dhcp-192-168-178-175.profitbricks.localdomain>
References: <1369387762-17865-1-git-send-email-tangchen@cn.fujitsu.com>
 <1369387762-17865-11-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1369387762-17865-11-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, tj@kernel.org, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 24, 2013 at 05:29:19PM +0800, Tang Chen wrote:
> We mark out movable memory ranges and reserve them with MEMBLK_HOTPLUGGABLE flag in
> memblock.reserved. This should be done after the memory mapping is initialized
> because the kernel now supports allocate pagetable pages on local node, which
> are kernel pages.
> 
> The reserved hotpluggable will be freed to buddy when memory initialization
> is done.
> 
> And also, ensure all the nodes which the kernel resides in are un-hotpluggable.
> 
> This idea is from Wen Congyang <wency@cn.fujitsu.com> and Jiang Liu <jiang.liu@huawei.com>.
> 
> Suggested-by: Jiang Liu <jiang.liu@huawei.com>
> Suggested-by: Wen Congyang <wency@cn.fujitsu.com>
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Reviewed-by: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
> ---
>  arch/x86/mm/numa.c       |   29 +++++++++++++++++++++++++++++
>  include/linux/memblock.h |    3 +++
>  mm/memblock.c            |   19 +++++++++++++++++++
>  3 files changed, 51 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> index b28baf3..73f9ade 100644
> --- a/arch/x86/mm/numa.c
> +++ b/arch/x86/mm/numa.c
> @@ -727,6 +727,33 @@ static void __init early_x86_numa_init_mapping(void)
>  }
>  #endif
>  
> +#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
> +static void __init early_mem_hotplug_init()
> +{
> +	int i, nid;
> +	phys_addr_t start, end;
> +
> +	if (!movablecore_enable_srat)
> +		return;
> +
> +	for (i = 0; i < numa_meminfo.nr_blks; i++) {
> +		nid = numa_meminfo.blk[i].nid;
> +		start = numa_meminfo.blk[i].start;
> +		end = numa_meminfo.blk[i].end;
> +
> +		if (!numa_meminfo.blk[i].hotpluggable ||
> +		    memblock_is_kernel_node(nid))
> +			continue;

In my v2 testing, I had a seabios bug: *all* memory was marked as hotpluggable
and the first if condition clause above always returned true.
I have a fixed seabios version that only sets hotplug bit to 1 for extra dimms
(see my v2 reply on how to use it with qemu):
https://github.com/vliaskov/seabios/commits/memhp-v4

I think there is another problem with mark_kernel_nodes though, see my comment
for 7/13.

thanks,

- Vasilis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
