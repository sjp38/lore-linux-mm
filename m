Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 10DB06B02D1
	for <linux-mm@kvack.org>; Fri,  3 May 2013 06:50:46 -0400 (EDT)
Received: by mail-bk0-f44.google.com with SMTP id jk13so653389bkc.17
        for <linux-mm@kvack.org>; Fri, 03 May 2013 03:50:42 -0700 (PDT)
Date: Fri, 3 May 2013 12:50:37 +0200
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: Re: [PATCH v2 10/13] x86, acpi, numa, mem-hotplug: Introduce
 MEMBLK_HOTPLUGGABLE to mark and reserve hotpluggable memory.
Message-ID: <20130503105037.GA4533@dhcp-192-168-178-175.profitbricks.localdomain>
References: <1367313683-10267-1-git-send-email-tangchen@cn.fujitsu.com>
 <1367313683-10267-11-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1367313683-10267-11-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, tj@kernel.org, laijs@cn.fujitsu.com, davem@davemloft.net, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

On Tue, Apr 30, 2013 at 05:21:20PM +0800, Tang Chen wrote:
> We mark out movable memory ranges and reserve them with MEMBLK_HOTPLUGGABLE flag in
> memblock.reserved. This should be done after the memory mapping is initialized
> because the kernel now supports allocate pagetable pages on local node, which
> are kernel pages.
> 
> The reserved hotpluggable will be freed to buddy when memory initialization
> is done.
> 
> This idea is from Wen Congyang <wency@cn.fujitsu.com> and Jiang Liu <jiang.liu@huawei.com>.
> 
> Suggested-by: Jiang Liu <jiang.liu@huawei.com>
> Suggested-by: Wen Congyang <wency@cn.fujitsu.com>
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> ---
>  arch/x86/mm/numa.c       |   28 ++++++++++++++++++++++++++++
>  include/linux/memblock.h |    3 +++
>  mm/memblock.c            |   19 +++++++++++++++++++
>  3 files changed, 50 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> index 1367fe4..a1f1f90 100644
> --- a/arch/x86/mm/numa.c
> +++ b/arch/x86/mm/numa.c
> @@ -731,6 +731,32 @@ static void __init early_x86_numa_init_mapping(void)
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
> +		if (!numa_meminfo.blk[i].hotpluggable)
> +			continue;
> +
> +		nid = numa_meminfo.blk[i].nid;

Should we skip ranges on nodes that the kernel uses? e.g. with

        if (memblock_is_kernel_node(nid))
            continue;

> +		start = numa_meminfo.blk[i].start;
> +		end = numa_meminfo.blk[i].end;
> +
> +		memblock_reserve_hotpluggable(start, end - start, nid);
> +	}
> +}

- I am getting a "PANIC: early exception" when rebooting with movablecore=acpi
after hotplugging memory on node0 or node1 of a 2-node VM. The guest kernel is
based on
git://git.kernel.org/pub/scm/linux/kernel/git/yinghai/linux-yinghai.git
for-x86-mm (e9058baf) + these v2 patches.

This happens with or without the above memblock_is_kernel_node(nid) check.
Perhaps I am missing something or I need a newer "ACPI, numa: Parse numa info
early" patch-set?

A general question: Disabling hot-pluggability/zone-movable eligibility for a
whole node sounds a bit inflexible, if the machine only has one node to begin
with.  Would it be possible to keep movable information per SRAT entry? I.e
if the BIOS presents multiple SRAT entries for one node/PXM (say node 0), and
there is no memblock/kernel allocation on one of these SRAT entries, could
we still mark this SRAT entry's range as hot-pluggable/movable?  Not sure if
many real machine BIOSes would do this, but seabios could.  This implies that
SRAT entries are processed for movable-zone eligilibity before they are merged
on node/PXM basis entry-granularity (I think numa_cleanup_meminfo currently does
this merge).

Of course the kernel should still have enough memory(i.e. non movable zone) to
boot. Can we ensure that at least certain amount of memory is non-movable, and
then, given more separate SRAT entries for node0 not used by kernel, treat
these rest entries as movable?

thanks,

- Vasilis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
