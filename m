Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 701136B00E9
	for <linux-mm@kvack.org>; Wed, 29 May 2013 09:59:29 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so9163805pbb.6
        for <linux-mm@kvack.org>; Wed, 29 May 2013 06:59:28 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v6, part4 22/41] mm/IA64: prepare for removing num_physpages and simplify mem_init()
Date: Wed, 29 May 2013 21:57:40 +0800
Message-Id: <1369835879-23553-23-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1369835879-23553-1-git-send-email-jiang.liu@huawei.com>
References: <1369835879-23553-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-ia64@vger.kernel.org

Prepare for removing num_physpages and simplify mem_init().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 arch/ia64/mm/contig.c    | 11 -----------
 arch/ia64/mm/discontig.c |  3 ---
 arch/ia64/mm/init.c      | 27 +--------------------------
 3 files changed, 1 insertion(+), 40 deletions(-)

diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index 955fd25..b975c8b 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -295,14 +295,6 @@ find_memory (void)
 	alloc_per_cpu_data();
 }
 
-static int count_pages(u64 start, u64 end, void *arg)
-{
-	unsigned long *count = arg;
-
-	*count += (end - start) >> PAGE_SHIFT;
-	return 0;
-}
-
 /*
  * Set up the page tables.
  */
@@ -313,9 +305,6 @@ paging_init (void)
 	unsigned long max_dma;
 	unsigned long max_zone_pfns[MAX_NR_ZONES];
 
-	num_physpages = 0;
-	efi_memmap_walk(count_pages, &num_physpages);
-
 	memset(max_zone_pfns, 0, sizeof(max_zone_pfns));
 #ifdef CONFIG_ZONE_DMA
 	max_dma = virt_to_phys((void *) MAX_DMA_ADDRESS) >> PAGE_SHIFT;
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 254ae8e..3aef17c 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -37,7 +37,6 @@ struct early_node_data {
 	struct ia64_node_data *node_data;
 	unsigned long pernode_addr;
 	unsigned long pernode_size;
-	unsigned long num_physpages;
 #ifdef CONFIG_ZONE_DMA
 	unsigned long num_dma_physpages;
 #endif
@@ -732,7 +731,6 @@ static __init int count_node_pages(unsigned long start, unsigned long len, int n
 {
 	unsigned long end = start + len;
 
-	mem_data[node].num_physpages += len >> PAGE_SHIFT;
 #ifdef CONFIG_ZONE_DMA
 	if (start <= __pa(MAX_DMA_ADDRESS))
 		mem_data[node].num_dma_physpages +=
@@ -778,7 +776,6 @@ void __init paging_init(void)
 #endif
 
 	for_each_online_node(node) {
-		num_physpages += mem_data[node].num_physpages;
 		pfn_offset = mem_data[node].min_pfn;
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index d141f7e..2d372b4 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -545,19 +545,6 @@ int __init register_active_ranges(u64 start, u64 len, int nid)
 	return 0;
 }
 
-static int __init
-count_reserved_pages(u64 start, u64 end, void *arg)
-{
-	unsigned long num_reserved = 0;
-	unsigned long *count = arg;
-
-	for (; start < end; start += PAGE_SIZE)
-		if (PageReserved(virt_to_page(start)))
-			++num_reserved;
-	*count += num_reserved;
-	return 0;
-}
-
 int
 find_max_min_low_pfn (u64 start, u64 end, void *arg)
 {
@@ -596,7 +583,6 @@ __setup("nolwsys", nolwsys_setup);
 void __init
 mem_init (void)
 {
-	long reserved_pages, codesize, datasize, initsize;
 	pg_data_t *pgdat;
 	int i;
 
@@ -624,18 +610,7 @@ mem_init (void)
 		if (pgdat->bdata->node_bootmem_map)
 			free_all_bootmem_node(pgdat);
 
-	reserved_pages = 0;
-	efi_memmap_walk(count_reserved_pages, &reserved_pages);
-
-	codesize =  (unsigned long) _etext - (unsigned long) _stext;
-	datasize =  (unsigned long) _edata - (unsigned long) _etext;
-	initsize =  (unsigned long) __init_end - (unsigned long) __init_begin;
-
-	printk(KERN_INFO "Memory: %luk/%luk available (%luk code, %luk reserved, "
-	       "%luk data, %luk init)\n", nr_free_pages() << (PAGE_SHIFT - 10),
-	       num_physpages << (PAGE_SHIFT - 10), codesize >> 10,
-	       reserved_pages << (PAGE_SHIFT - 10), datasize >> 10, initsize >> 10);
-
+	mem_init_print_info(NULL);
 
 	/*
 	 * For fsyscall entrpoints with no light-weight handler, use the ordinary
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
