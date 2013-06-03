Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id E46916B0002
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 03:33:15 -0400 (EDT)
Message-ID: <51AC4759.6090101@cn.fujitsu.com>
Date: Mon, 03 Jun 2013 15:35:53 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 07/13] x86, numa, mem-hotplug: Mark nodes which the
 kernel resides in.
References: <1369387762-17865-1-git-send-email-tangchen@cn.fujitsu.com> <1369387762-17865-8-git-send-email-tangchen@cn.fujitsu.com> <20130531162401.GA31139@dhcp-192-168-178-175.profitbricks.localdomain>
In-Reply-To: <20130531162401.GA31139@dhcp-192-168-178-175.profitbricks.localdomain>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Cc: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, tj@kernel.org, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Vasilis,

On 06/01/2013 12:24 AM, Vasilis Liaskovitis wrote:
......
>> +void __init_memblock memblock_mark_kernel_nodes()
>> +{
>> +	int i, nid;
>> +	struct memblock_type *reserved =&memblock.reserved;
>> +
>> +	for (i = 0; i<  reserved->cnt; i++)
>> +		if (reserved->regions[i].flags == MEMBLK_FLAGS_DEFAULT) {
>> +			nid = memblock_get_region_node(&reserved->regions[i]);
>> +			node_set(nid, memblock_kernel_nodemask);
>> +		}
>> +}
>
> I think there is a problem here because memblock_set_region_node is sometimes
> called with nid == MAX_NUMNODES. This means the correct node is not properly
> masked in the memblock_kernel_nodemask bitmap.
> E.g. in a VM test, memblock_mark_kernel_nodes with extra pr_warn calls iterates
> over the following memblocks (ranges below are memblks base-(base+size)):
>
> [    0.000000] memblock_mark_kernel_nodes nid=64 0x00000000000000-0x00000000010000
> [    0.000000] memblock_mark_kernel_nodes nid=64 0x00000000098000-0x00000000100000
> [    0.000000] memblock_mark_kernel_nodes nid=64 0x00000001000000-0x00000001a5a000
> [    0.000000] memblock_mark_kernel_nodes nid=64 0x00000037000000-0x000000377f8000
>
> where MAX_NUMNODES is 64 because CONFIG_NODES_SHIFT=6.
> The ranges above belong to node 0, but the node's bit is never marked.
>
> With a buggy bios that marks all memory as hotpluggable, this results in a
> panic, because both checks against hotpluggable bit and memblock_kernel_bitmask
> (in early_mem_hotplug_init) fail, the numa regions have all been merged together
> and memblock_reserve_hotpluggable is called for all memory.
>
> With a correct bios (some part of initial memory is not hotplug-able) the kernel
> can boot since the hotpluggable bit check works ok, but extra dimms on node 0
> will still be allowed to be in MOVABLE_ZONE.
>

OK, I see the problem. But would you please give me a call trace that 
can show
how this could happen. I think the memory block info should be the same as
numa_meminfo. Can we fix the caller to make it set nid correctly ?

> Actually this behaviour (being able to have MOVABLE memory on nodes with kernel
> reserved memblocks) sort of matches the policy I requested in v2 :). But i
> suspect that is not your intent i.e. you want memblock_kernel_nodemask_bitmap to
> prevent movable reservations for the whole node where kernel has reserved
> memblocks.

I intended to set the whole node which the kernel resides in as 
un-hotpluggable.

>
> Is there a way to get accurate nid information for memblocks at early boot? I
> suspect pfn_to_nid doesn't work yet at this stage (i got a panic when I
> attempted iirc)

In such an early time, I think we can only get nid from numa_meminfo. So 
as I
said above, I'd like to fix this problem by making memblock has correct nid.

And I read the patch below. I think if we get nid from numa_meminfo, 
than we
don't need to call memblock_get_region_node().

Thanks. :)

>
> I used the hack below but it depends on CONFIG_NUMA, hopefully there is a
> cleaner general way:
>
> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> index cfd8c2f..af8ad2a 100644
> --- a/arch/x86/mm/numa.c
> +++ b/arch/x86/mm/numa.c
> @@ -133,6 +133,19 @@ void __init setup_node_to_cpumask_map(void)
>   	pr_debug("Node to cpumask map for %d nodes\n", nr_node_ids);
>   }
>
> +int __init numa_find_range_nid(u64 start, u64 size)
> +{
> +	unsigned int i;
> +	struct numa_meminfo *mi =&numa_meminfo;
> +
> +	for (i = 0; i<  mi->nr_blks; i++) {
> +		if (start>= mi->blk[i].start&&  start + size -1<= mi->blk[i].end)
> +		 return mi->blk[i].nid;
> +	}
> +	return -1;
> +}
> +EXPORT_SYMBOL(numa_find_range_nid);
> +
>   static int __init numa_add_memblk_to(int nid, u64 start, u64 end,
>   				     bool hotpluggable,
>   				     struct numa_meminfo *mi)
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 77a71fb..194b7c7 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1600,6 +1600,9 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
>   			unsigned long start, unsigned long end);
>   #endif
>
> +#ifdef CONFIG_NUMA
> +int __init numa_find_range_nid(u64 start, u64 size);
> +#endif
>   struct vm_area_struct *find_extend_vma(struct mm_struct *, unsigned long addr);
>   int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
>   			unsigned long pfn, unsigned long size, pgprot_t);
> diff --git a/mm/memblock.c b/mm/memblock.c
> index a6b7845..284aced 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -834,15 +834,26 @@ int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
>
>   void __init_memblock memblock_mark_kernel_nodes()
>   {
> -	int i, nid;
> +	int i, nid, tmpnid;
>   	struct memblock_type *reserved =&memblock.reserved;
>
>   	for (i = 0; i<  reserved->cnt; i++)
>   		if (reserved->regions[i].flags == MEMBLK_FLAGS_DEFAULT) {
>   			nid = memblock_get_region_node(&reserved->regions[i]);
> +		if (nid == MAX_NUMNODES) {
> +			tmpnid = numa_find_range_nid(reserved->regions[i].base,
> +				reserved->regions[i].size);
> +			if (tmpnid>= 0)
> +				nid = tmpnid;
> +		}
>
> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> index e862311..84d6e64 100644
> --- a/arch/x86/mm/numa.c
> +++ b/arch/x86/mm/numa.c
> @@ -667,11 +667,7 @@ static bool srat_used __initdata;
>    */
>   static void __init early_x86_numa_init(void)
>   {
> -	/*
> -	 * Need to find out which nodes the kernel resides in, and arrange
> -	 * them as un-hotpluggable when parsing SRAT.
> -	 */
> -	memblock_mark_kernel_nodes();
>
>   	if (!numa_off) {
>   #ifdef CONFIG_X86_NUMAQ
> @@ -779,6 +775,12 @@ void __init early_initmem_init(void)
>   	load_cr3(swapper_pg_dir);
>   	__flush_tlb_all();
>
> +	/*
> +	 * Need to find out which nodes the kernel resides in, and arrange
> +	 * them as un-hotpluggable when parsing SRAT.
> +	 */
> +
> +	memblock_mark_kernel_nodes();
>   	early_mem_hotplug_init();
>
>   	early_memtest(0, max_pfn_mapped<<PAGE_SHIFT);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
