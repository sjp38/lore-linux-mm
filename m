Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id A33066B0033
	for <linux-mm@kvack.org>; Fri, 31 May 2013 12:15:10 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id t59so1424112wes.16
        for <linux-mm@kvack.org>; Fri, 31 May 2013 09:15:09 -0700 (PDT)
Date: Fri, 31 May 2013 18:15:04 +0200
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: Re: [PATCH v2 07/13] x86, numa, mem-hotplug: Mark nodes which the
 kernel resides in.
Message-ID: <20130531161504.GA29043@dhcp-192-168-178-175.profitbricks.localdomain>
References: <1367313683-10267-1-git-send-email-tangchen@cn.fujitsu.com>
 <1367313683-10267-8-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1367313683-10267-8-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, tj@kernel.org, laijs@cn.fujitsu.com, davem@davemloft.net, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

On Tue, Apr 30, 2013 at 05:21:17PM +0800, Tang Chen wrote:
> If all the memory ranges in SRAT are hotpluggable, we should not
> arrange them all in ZONE_MOVABLE. Otherwise the kernel won't have
> enough memory to boot.
> 
> This patch introduce a global variable kernel_nodemask to mark
> all the nodes the kernel resides in. And no matter if they are
> hotpluggable, we arrange them as un-hotpluggable.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> ---
>  arch/x86/mm/numa.c       |    6 ++++++
>  include/linux/memblock.h |    1 +
>  mm/memblock.c            |   20 ++++++++++++++++++++
>  3 files changed, 27 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
> index 26d1800..105b092 100644
> --- a/arch/x86/mm/numa.c
> +++ b/arch/x86/mm/numa.c
> @@ -658,6 +658,12 @@ static bool srat_used __initdata;
>   */
>  static void __init early_x86_numa_init(void)
>  {
> +	/*
> +	 * Need to find out which nodes the kernel resides in, and arrange
> +	 * them as un-hotpluggable when parsing SRAT.
> +	 */
> +	memblock_mark_kernel_nodes();
> +
>  	if (!numa_off) {
>  #ifdef CONFIG_X86_NUMAQ
>  		if (!numa_init(numaq_numa_init))
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index c63a66e..5064eed 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -66,6 +66,7 @@ int memblock_remove(phys_addr_t base, phys_addr_t size);
>  int memblock_free(phys_addr_t base, phys_addr_t size);
>  int memblock_reserve(phys_addr_t base, phys_addr_t size);
>  void memblock_trim_memory(phys_addr_t align);
> +void memblock_mark_kernel_nodes(void);
>  
>  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>  void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 63924ae..1b93a5d 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -35,6 +35,9 @@ struct memblock memblock __initdata_memblock = {
>  	.current_limit		= MEMBLOCK_ALLOC_ANYWHERE,
>  };
>  
> +/* Mark which nodes the kernel resides in. */
> +static nodemask_t memblock_kernel_nodemask __initdata_memblock;
> +
>  int memblock_debug __initdata_memblock;
>  static int memblock_can_resize __initdata_memblock;
>  static int memblock_memory_in_slab __initdata_memblock = 0;
> @@ -787,6 +790,23 @@ int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
>  	memblock_merge_regions(type);
>  	return 0;
>  }
> +
> +void __init_memblock memblock_mark_kernel_nodes()
> +{
> +	int i, nid;
> +	struct memblock_type *reserved = &memblock.reserved;
> +
> +	for (i = 0; i < reserved->cnt; i++)
> +		if (reserved->regions[i].flags == MEMBLK_FLAGS_DEFAULT) {
> +			nid = memblock_get_region_node(&reserved->regions[i]);
> +			node_set(nid, memblock_kernel_nodemask);
> +		}
> +}

I think there is a problem here because memblock_set_region_node is sometimes
called with nid == MAX_NUMNODES. This means the correct node is not properly
masked in the memblock_kernel_nodemask bitmap.
E.g. in a VM test, memblock_mark_kernel_nodes with extra pr_warn calls iterates
over the following memblocks (ranges below are memblks base-(base+size)):

[    0.000000] memblock_mark_kernel_nodes nid=64 0x00000000000000-0x00000000010000
[    0.000000] memblock_mark_kernel_nodes nid=64 0x00000000098000-0x00000000100000
[    0.000000] memblock_mark_kernel_nodes nid=64 0x00000001000000-0x00000001a5a000
[    0.000000] memblock_mark_kernel_nodes nid=64 0x00000037000000-0x000000377f8000

where MAX_NUMNODES is 64 because CONFIG_NODES_SHIFT=6.
The ranges above belong to node 0, but the node's bit is never marked.

With a buggy bios that marks all memory as hotpluggable, this results in a
panic, because both checks against hotpluggable bit and memblock_kernel_bitmask
(in early_mem_hotplug_init) fail, the numa regions have all been merged together
and memblock_reserve_hotpluggable is called for all memory. 

With a correct bios (some part of initial memory is not hotplug-able) the kernel
can boot since the hotpluggable bit check works ok, but extra dimms on node 0
will still be allowed to be in MOVABLE_ZONE.

Actually this behaviour (being able to have MOVABLE memory on nodes with kernel
reserved memblocks) sort of matches the policy I requested in v2 :). But i
suspect that is not your intent i.e. you want memblock_kernel_nodemask_bitmap to
prevent movable reservations for the whole node where kernel has reserved
memblocks.

Is there a way to get accurate nid information for memblocks at early boot? I
suspect pfn_to_nid doesn't work yet at this stage (i got a panic when I
attempted iirc)

I used the hack below but it depends on CONFIG_NUMA, hopefully there is a
cleaner general way:

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index cfd8c2f..af8ad2a 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -133,6 +133,19 @@ void __init setup_node_to_cpumask_map(void)
 	pr_debug("Node to cpumask map for %d nodes\n", nr_node_ids);
 }
 
+int __init numa_find_range_nid(u64 start, u64 size)
+{
+	unsigned int i;
+	struct numa_meminfo *mi = &numa_meminfo;
+
+	for (i = 0; i < mi->nr_blks; i++) {
+		if (start >= mi->blk[i].start && start + size -1 <= mi->blk[i].end)
+		 return mi->blk[i].nid;
+	}
+	return -1;
+}
+EXPORT_SYMBOL(numa_find_range_nid);
+
 static int __init numa_add_memblk_to(int nid, u64 start, u64 end,
 				     bool hotpluggable,
 				     struct numa_meminfo *mi)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 77a71fb..194b7c7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1600,6 +1600,9 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
 			unsigned long start, unsigned long end);
 #endif
 
+#ifdef CONFIG_NUMA
+int __init numa_find_range_nid(u64 start, u64 size);
+#endif
 struct vm_area_struct *find_extend_vma(struct mm_struct *, unsigned long addr);
 int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 			unsigned long pfn, unsigned long size, pgprot_t);
diff --git a/mm/memblock.c b/mm/memblock.c
index a6b7845..284aced 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -834,15 +834,26 @@ int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
 
 void __init_memblock memblock_mark_kernel_nodes()
 {
-	int i, nid;
+	int i, nid, tmpnid;
 	struct memblock_type *reserved = &memblock.reserved;
 
 	for (i = 0; i < reserved->cnt; i++)
 		if (reserved->regions[i].flags == MEMBLK_FLAGS_DEFAULT) {
 			nid = memblock_get_region_node(&reserved->regions[i]);
+		if (nid == MAX_NUMNODES) {
+			tmpnid = numa_find_range_nid(reserved->regions[i].base,
+				reserved->regions[i].size);
+			if (tmpnid >= 0)
+				nid = tmpnid;
+		}

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index e862311..84d6e64 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -667,11 +667,7 @@ static bool srat_used __initdata;
  */
 static void __init early_x86_numa_init(void)
 {
-	/*
-	 * Need to find out which nodes the kernel resides in, and arrange
-	 * them as un-hotpluggable when parsing SRAT.
-	 */
-	memblock_mark_kernel_nodes();
 
 	if (!numa_off) {
 #ifdef CONFIG_X86_NUMAQ
@@ -779,6 +775,12 @@ void __init early_initmem_init(void)
 	load_cr3(swapper_pg_dir);
 	__flush_tlb_all();
 
+	/*
+	 * Need to find out which nodes the kernel resides in, and arrange
+	 * them as un-hotpluggable when parsing SRAT.
+	 */
+
+	memblock_mark_kernel_nodes();
 	early_mem_hotplug_init();
 
 	early_memtest(0, max_pfn_mapped<<PAGE_SHIFT);
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
