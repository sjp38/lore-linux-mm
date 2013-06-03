From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 12/13] x86, numa, acpi, memory-hotplug: Make
 movablecore=acpi have higher priority.
Date: Mon, 3 Jun 2013 10:59:24 +0800
Message-ID: <44161.2760689624$1370228390@news.gmane.org>
References: <1369387762-17865-1-git-send-email-tangchen@cn.fujitsu.com>
 <1369387762-17865-13-git-send-email-tangchen@cn.fujitsu.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UjKzh-0000GN-Fa
	for glkm-linux-mm-2@m.gmane.org; Mon, 03 Jun 2013 04:59:38 +0200
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 308ED6B0032
	for <linux-mm@kvack.org>; Sun,  2 Jun 2013 22:59:35 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 3 Jun 2013 08:23:13 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 4D607394005B
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 08:29:29 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r532xKWB43450416
	for <linux-mm@kvack.org>; Mon, 3 Jun 2013 08:29:20 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r532xQtb010235
	for <linux-mm@kvack.org>; Mon, 3 Jun 2013 12:59:27 +1000
Content-Disposition: inline
In-Reply-To: <1369387762-17865-13-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, tj@kernel.org, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 24, 2013 at 05:29:21PM +0800, Tang Chen wrote:
>Arrange hotpluggable memory as ZONE_MOVABLE will cause NUMA performance decreased
>because the kernel cannot use movable memory.
>
>For users who don't use memory hotplug and who don't want to lose their NUMA
>performance, they need a way to disable this functionality.
>
>So, if users specify "movablecore=acpi" in kernel commandline, the kernel will
>use SRAT to arrange ZONE_MOVABLE, and it has higher priority then original
>movablecore and kernelcore boot option.
>
>For those who don't want this, just specify nothing.
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
>---
> include/linux/memblock.h |    1 +
> mm/memblock.c            |    5 +++++
> mm/page_alloc.c          |   31 +++++++++++++++++++++++++++++--
> 3 files changed, 35 insertions(+), 2 deletions(-)
>
>diff --git a/include/linux/memblock.h b/include/linux/memblock.h
>index 08c761d..5528e8f 100644
>--- a/include/linux/memblock.h
>+++ b/include/linux/memblock.h
>@@ -69,6 +69,7 @@ int memblock_free(phys_addr_t base, phys_addr_t size);
> int memblock_reserve(phys_addr_t base, phys_addr_t size);
> int memblock_reserve_local_node(phys_addr_t base, phys_addr_t size, int nid);
> int memblock_reserve_hotpluggable(phys_addr_t base, phys_addr_t size, int nid);
>+bool memblock_is_hotpluggable(struct memblock_region *region);
> void memblock_free_hotpluggable(void);
> void memblock_trim_memory(phys_addr_t align);
> void memblock_mark_kernel_nodes(void);
>diff --git a/mm/memblock.c b/mm/memblock.c
>index 54de398..8b9a13c 100644
>--- a/mm/memblock.c
>+++ b/mm/memblock.c
>@@ -623,6 +623,11 @@ int __init_memblock memblock_reserve_hotpluggable(phys_addr_t base,
> 	return memblock_reserve_region(base, size, nid, flags);
> }
>
>+bool __init_memblock memblock_is_hotpluggable(struct memblock_region *region)
>+{
>+	return region->flags & (1 << MEMBLK_HOTPLUGGABLE);
>+}
>+
> /**
>  * __next_free_mem_range - next function for for_each_free_mem_range()
>  * @idx: pointer to u64 loop variable
>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>index b9ea143..557b21b 100644
>--- a/mm/page_alloc.c
>+++ b/mm/page_alloc.c
>@@ -4793,9 +4793,37 @@ static void __init find_zone_movable_pfns_for_nodes(void)
> 	nodemask_t saved_node_state = node_states[N_MEMORY];
> 	unsigned long totalpages = early_calculate_totalpages();
> 	int usable_nodes = nodes_weight(node_states[N_MEMORY]);
>+	struct memblock_type *reserved = &memblock.reserved;
>
> 	/*
>-	 * If movablecore was specified, calculate what size of
>+	 * Need to find movable_zone earlier in case movablecore=acpi is
>+	 * specified.
>+	 */
>+	find_usable_zone_for_movable();
>+
>+	/*
>+	 * If movablecore=acpi was specified, then zone_movable_pfn[] has been
>+	 * initialized, and no more work needs to do.
>+	 * NOTE: In this case, we ignore kernelcore option.
>+	 */
>+	if (movablecore_enable_srat) {
>+		for (i = 0; i < reserved->cnt; i++) {
>+			if (!memblock_is_hotpluggable(&reserved->regions[i]))
>+				continue;
>+
>+			nid = reserved->regions[i].nid;
>+
>+			usable_startpfn = PFN_DOWN(reserved->regions[i].base);
>+			zone_movable_pfn[nid] = zone_movable_pfn[nid] ?
>+				min(usable_startpfn, zone_movable_pfn[nid]) :
>+				usable_startpfn;
>+		}
>+
>+		goto out;
>+	}
>+
>+	/*
>+	 * If movablecore=nn[KMG] was specified, calculate what size of
> 	 * kernelcore that corresponds so that memory usable for
> 	 * any allocation type is evenly spread. If both kernelcore
> 	 * and movablecore are specified, then the value of kernelcore
>@@ -4821,7 +4849,6 @@ static void __init find_zone_movable_pfns_for_nodes(void)
> 		goto out;
>
> 	/* usable_startpfn is the lowest possible pfn ZONE_MOVABLE can be at */
>-	find_usable_zone_for_movable();
> 	usable_startpfn = arch_zone_lowest_possible_pfn[movable_zone];
>
> restart:
>-- 
>1.7.1
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
