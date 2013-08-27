Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id C3F9D6B0033
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 08:39:19 -0400 (EDT)
Message-ID: <521C9DB3.60305@huawei.com>
Date: Tue, 27 Aug 2013 20:38:11 +0800
From: leizhen <thunder.leizhen@huawei.com>
MIME-Version: 1.0
Subject: Re: [BUG] ARM64: Create 4K page size mmu memory map at init time
 will trigger exception.
References: <BFAC7FA8F7636E45AB9ECBAC17346F3434557683@SZXEML508-MBS.china.huawei.com> <20130822161614.GE1352@arm.com> <20130823171605.GH10971@arm.com>
In-Reply-To: <20130823171605.GH10971@arm.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Russell King <linux@arm.linux.org.uk>, "Liujiang (Gerry)" <jiang.liu@huawei.com>, Will Deacon <Will.Deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Huxinwei <huxinwei@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Lizefan <lizefan@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 2013/8/24 1:16, Catalin Marinas wrote:
> On Thu, Aug 22, 2013 at 05:16:14PM +0100, Catalin Marinas wrote:
>> On Thu, Aug 22, 2013 at 04:35:29AM +0100, Leizhen (ThunderTown, Euler) wrote:
>>> This problem is on ARM64. When CONFIG_ARM64_64K_PAGES is not opened, the memory
>>> map size can be 2M(section) and 4K(PAGE). First, OS will create map for pgd
>>> (level 1 table) and level 2 table which in swapper_pg_dir. Then, OS register
>>> mem block into memblock.memory according to memory node in fdt, like memory@0,
>>> and create map in setup_arch-->paging_init. If all mem block start address and
>>> size is integral multiple of 2M, there is no problem, because we will create 2M
>>> section size map whose entries locate in level 2 table. But if it is not
>>> integral multiple of 2M, we should create level 3 table, which granule is 4K.
>>> Now, current implementtion is call early_alloc-->memblock_alloc to alloc memory
>>> for level 3 table. This function will find a 4K free memory which locate in
>>> memblock.memory tail(high address), but paging_init is create map from low
>>> address to high address, so new alloced memory is not mapped, write page talbe
>>> entry to it will trigger exception.
>>
>> I see how this can happen. There is a memblock_set_current_limit to
>> PGDIR_SIZE (1GB, we have a pre-allocated pmd) and in my tests I had at
>> least 1GB of RAM which got mapped first and didn't have this problem.
>> I'll come up with a patch tomorrow.
> 
> Could you please try this patch?
> 
> -------------------------8<---------------------------------------
> 
>>From 3a35771339b7eea105925d1d573aedbeeea59ef0 Mon Sep 17 00:00:00 2001
> From: Catalin Marinas <catalin.marinas@arm.com>
> Date: Fri, 23 Aug 2013 18:04:44 +0100
> Subject: [PATCH] arm64: Fix mapping of memory banks not ending on a PMD_SIZE
>  boundary
> 
> The map_mem() function limits the current memblock limit to PGDIR_SIZE
> (the initial swapper_pg_dir mapping) to avoid create_mapping()
> allocating memory from unmapped areas. However, if the first block is
> within PGDIR_SIZE and not ending on a PMD_SIZE boundary, when 4K page
> configuration is enabled, create_mapping() will try to allocate a pte
> page. Such page may be returned by memblock_alloc() from the end of such
> bank (or any subsequent bank within PGDIR_SIZE) which is not mapped yet.
> 
> The patch limits the current memblock limit to the aligned end of the
> first bank and gradually increases it as more memory is mapped. It also
> ensures that the start of the first bank is aligned to PMD_SIZE to avoid
> pte page allocation for this mapping.
> 
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> Reported-by: "Leizhen (ThunderTown, Euler)" <thunder.leizhen@huawei.com>
> ---
>  arch/arm64/mm/mmu.c | 28 ++++++++++++++++++++++++++--
>  1 file changed, 26 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index a8d1059..49a0bc2 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -296,6 +296,7 @@ void __iomem * __init early_io_map(phys_addr_t phys, unsigned long virt)
>  static void __init map_mem(void)
>  {
>  	struct memblock_region *reg;
> +	phys_addr_t limit;
>  
>  	/*
>  	 * Temporarily limit the memblock range. We need to do this as
> @@ -303,9 +304,11 @@ static void __init map_mem(void)
>  	 * memory addressable from the initial direct kernel mapping.
>  	 *
>  	 * The initial direct kernel mapping, located at swapper_pg_dir,
> -	 * gives us PGDIR_SIZE memory starting from PHYS_OFFSET (aligned).
> +	 * gives us PGDIR_SIZE memory starting from PHYS_OFFSET (which must be
> +	 * aligned to 2MB as per Documentation/arm64/booting.txt).
>  	 */
> -	memblock_set_current_limit((PHYS_OFFSET & PGDIR_MASK) + PGDIR_SIZE);
> +	limit = PHYS_OFFSET + PGDIR_SIZE;
> +	memblock_set_current_limit(limit);
>  
>  	/* map all the memory banks */
>  	for_each_memblock(memory, reg) {
> @@ -315,7 +318,28 @@ static void __init map_mem(void)
>  		if (start >= end)
>  			break;
>  
> +#ifndef CONFIG_ARM64_64K_PAGES
> +		/*
> +		 * For the first memory bank align the start address and
> +		 * current memblock limit to prevent create_mapping() from
> +		 * allocating pte page tables from unmapped memory.
> +		 * When 64K pages are enabled, the pte page table for the
> +		 * first PGDIR_SIZE is already present in swapper_pg_dir.
> +		 */
> +		if (start < limit)
> +			start = ALIGN(start, PMD_SIZE);
> +		if (end < limit) {
> +			limit = end & PMD_MASK;
> +			memblock_set_current_limit(limit);
> +		}
> +#endif
> +
>  		create_mapping(start, __phys_to_virt(start), end - start);
> +
> +		/*
> +		 * Mapping created, extend the current memblock limit.
> +		 */
> +		memblock_set_current_limit(end);
>  	}
>  
>  	/* Limit no longer required. */
> 
> .
> 


I test this patch on my board, it's passed. But I think there still some little problem. First, we align start address and truncate last, which will cause some memory wasted. Second, if we update
current_limit after each memblock mapped, the page alloced by early_alloc will be more dispersedly. So I fix this bug like below:

If page size is 4K, a 4K size level 2 tables can map 1G, so 512G need 512 * 4K. And max level 3 tables number is (memblock num) * 2(if both head part and tail part not multiple of 2M), 2M = 256 * 2 *
4K. We first alloc 2M memory, map it, then free it, and mark current_limit at this boundary.

diff -Naur a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
--- a/arch/arm64/mm/mmu.c	2013-08-27 11:54:35.000000000 +0000
+++ b/arch/arm64/mm/mmu.c	2013-08-27 11:54:17.000000000 +0000
@@ -167,13 +167,29 @@
 	return ptr;
 }

+static void __init *table_alloc(phys_addr_t limit, unsigned long sz)
+{
+    void *ptr = early_alloc(sz);
+
+    if (!ptr) {
+        /*
+         * Mapping created, extend the current memblock limit.
+         */
+        memblock_set_current_limit(limit);
+
+        ptr = early_alloc(sz);
+    }
+
+    return ptr;
+}
+
 static void __init alloc_init_pte(pmd_t *pmd, unsigned long addr,
 				  unsigned long end, unsigned long pfn)
 {
 	pte_t *pte;

 	if (pmd_none(*pmd)) {
-		pte = early_alloc(PTRS_PER_PTE * sizeof(pte_t));
+		pte = table_alloc(__pfn_to_phys(pfn), PTRS_PER_PTE * sizeof(pte_t));
 		__pmd_populate(pmd, __pa(pte), PMD_TYPE_TABLE);
 	}
 	BUG_ON(pmd_bad(*pmd));
@@ -195,7 +211,7 @@
 	 * Check for initial section mappings in the pgd/pud and remove them.
 	 */
 	if (pud_none(*pud) || pud_bad(*pud)) {
-		pmd = early_alloc(PTRS_PER_PMD * sizeof(pmd_t));
+		pmd = table_alloc(phys, PTRS_PER_PMD * sizeof(pmd_t));
 		pud_populate(&init_mm, pud, pmd);
 	}

@@ -307,6 +323,24 @@
 	 */
 	memblock_set_current_limit((PHYS_OFFSET & PGDIR_MASK) + PGDIR_SIZE);

+#ifndef CONFIG_ARM64_64K_PAGES
+{
+    phys_addr_t table;
+    phys_addr_t tablesize = PMD_SIZE;
+
+    table = memblock_alloc(tablesize, PMD_SIZE);
+
+    if (table) {
+        create_mapping(table, __phys_to_virt(table), tablesize);
+
+        memblock_free(table, tablesize);
+        memblock_add(table, tablesize);
+
+        memblock_set_current_limit(table + tablesize);
+    }
+}
+#endif
+
 	/* map all the memory banks */
 	for_each_memblock(memory, reg) {
 		phys_addr_t start = reg->base;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
