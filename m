Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id E63CE6B002B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 04:27:08 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so5443197pad.14
        for <linux-mm@kvack.org>; Tue, 09 Oct 2012 01:27:08 -0700 (PDT)
Message-ID: <5073DFC0.3010400@gmail.com>
Date: Tue, 09 Oct 2012 16:26:40 +0800
From: wujianguo <wujianguo106@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 8/10] memory-hotplug : remove page table of x86_64 architecture
References: <506E43E0.70507@jp.fujitsu.com> <506E4799.30407@jp.fujitsu.com>
In-Reply-To: <506E4799.30407@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com, wujianguo@huawei.com, qiuxishi@huawei.com, jiang.liu@huawei.com

Hi Congyang,
	I think we should also free pages which are used by page tables after removing
page tables of the memory.

From: Jianguo Wu <wujianguo@huawei.com>

Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 arch/x86/mm/init_64.c |  110 +++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 89 insertions(+), 21 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 5596dfa..81f9c3b 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -675,6 +675,74 @@ int arch_add_memory(int nid, u64 start, u64 size)
 }
 EXPORT_SYMBOL_GPL(arch_add_memory);

+static inline void free_pagetable(struct page *page)
+{
+	struct zone *zone;
+
+	__ClearPageReserved(page);
+	__free_page(page);
+
+	zone = page_zone(page);
+	zone_span_writelock(zone);
+	zone->present_pages++;
+	zone_span_writeunlock(zone);
+	totalram_pages++;
+}
+
+static void free_pte_table(pte_t *pte_start, pmd_t *pmd)
+{
+	pte_t *pte;
+	int i;
+
+	for (i = 0; i < PTRS_PER_PTE; i++) {
+		pte = pte_start + i;
+		if (pte_val(*pte))
+			break;
+	}
+
+	/* free a pte talbe */
+	if (i == PTRS_PER_PTE) {
+		free_pagetable(pmd_page(*pmd));
+		pmd_clear(pmd);
+	}
+}
+
+static void free_pmd_table(pmd_t *pmd_start, pud_t *pud)
+{
+	pmd_t *pmd;
+	int i;
+
+	for (i = 0; i < PTRS_PER_PMD; i++) {
+		pmd = pmd_start + i;
+		if (pmd_val(*pmd))
+			break;
+	}
+
+	/* free a pmd talbe */
+	if (i == PTRS_PER_PMD) {
+		free_pagetable(pud_page(*pud));
+		pud_clear(pud);
+	}
+}
+
+static void free_pud_table(pud_t *pud_start, pgd_t *pgd)
+{
+	pud_t *pud;
+	int i;
+
+	for (i = 0; i < PTRS_PER_PUD; i++) {
+		pud = pud_start + i;
+		if (pud_val(*pud))
+			break;
+	}
+
+	/* free a pud table */
+	if (i == PTRS_PER_PUD) {
+		free_pagetable(pgd_page(*pgd));
+		pgd_clear(pgd);
+	}
+}
+
 static void __meminit
 phys_pte_remove(pte_t *pte_page, unsigned long addr, unsigned long end)
 {
@@ -704,21 +772,19 @@ phys_pmd_remove(pmd_t *pmd_page, unsigned long addr, unsigned long end)
 	unsigned long pages = 0, next;
 	int i = pmd_index(addr);

-	for (; i < PTRS_PER_PMD; i++, addr = next) {
+	for (; i < PTRS_PER_PMD && addr < end; i++, addr = next) {
 		unsigned long pte_phys;
 		pmd_t *pmd = pmd_page + pmd_index(addr);
 		pte_t *pte;

-		if (addr >= end)
-			break;
-
-		next = (addr & PMD_MASK) + PMD_SIZE;
+		next = pmd_addr_end(addr, end);

 		if (!pmd_present(*pmd))
 			continue;

 		if (pmd_large(*pmd)) {
-			if ((addr & ~PMD_MASK) == 0 && next <= end) {
+			if (IS_ALIGNED(addr, PMD_SIZE) &&
+			    IS_ALIGNED(next, PMD_SIZE)) {
 				set_pmd(pmd, __pmd(0));
 				pages++;
 				continue;
@@ -729,7 +795,8 @@ phys_pmd_remove(pmd_t *pmd_page, unsigned long addr, unsigned long end)
 			 * so split 2M page to 4K page.
 			 */
 			pte = alloc_low_page(&pte_phys);
-			__split_large_page((pte_t *)pmd, addr, pte);
+			__split_large_page((pte_t *)pmd,
+					   (unsigned long)__va(addr), pte);

 			spin_lock(&init_mm.page_table_lock);
 			pmd_populate_kernel(&init_mm, pmd, __va(pte_phys));
@@ -738,7 +805,8 @@ phys_pmd_remove(pmd_t *pmd_page, unsigned long addr, unsigned long end)

 		spin_lock(&init_mm.page_table_lock);
 		pte = map_low_page((pte_t *)pmd_page_vaddr(*pmd));
-		phys_pte_remove(pte, addr, end);
+		phys_pte_remove(pte, addr, next);
+		free_pte_table(pte, pmd);
 		unmap_low_page(pte);
 		spin_unlock(&init_mm.page_table_lock);
 	}
@@ -751,21 +819,19 @@ phys_pud_remove(pud_t *pud_page, unsigned long addr, unsigned long end)
 	unsigned long pages = 0, next;
 	int i = pud_index(addr);

-	for (; i < PTRS_PER_PUD; i++, addr = next) {
+	for (; i < PTRS_PER_PUD && addr < end; i++, addr = next) {
 		unsigned long pmd_phys;
 		pud_t *pud = pud_page + pud_index(addr);
 		pmd_t *pmd;

-		if (addr >= end)
-			break;
-
-		next = (addr & PUD_MASK) + PUD_SIZE;
+		next = pud_addr_end(addr, end);

 		if (!pud_present(*pud))
 			continue;

 		if (pud_large(*pud)) {
-			if ((addr & ~PUD_MASK) == 0 && next <= end) {
+			if (IS_ALIGNED(addr, PUD_SIZE) &&
+			    IS_ALIGNED(next, PUD_SIZE)) {
 				set_pud(pud, __pud(0));
 				pages++;
 				continue;
@@ -776,15 +842,18 @@ phys_pud_remove(pud_t *pud_page, unsigned long addr, unsigned long end)
 			 * so split 1G page to 2M page.
 			 */
 			pmd = alloc_low_page(&pmd_phys);
-			__split_large_page((pte_t *)pud, addr, (pte_t *)pmd);
+			__split_large_page((pte_t *)pud,
+					   (unsigned long)__va(addr),
+					   (pte_t *)pmd);

 			spin_lock(&init_mm.page_table_lock);
 			pud_populate(&init_mm, pud, __va(pmd_phys));
 			spin_unlock(&init_mm.page_table_lock);
 		}

-		pmd = map_low_page(pmd_offset(pud, 0));
-		phys_pmd_remove(pmd, addr, end);
+		pmd = map_low_page((pmd_t *)pud_page_vaddr(*pud));
+		phys_pmd_remove(pmd, addr, next);
+		free_pmd_table(pmd, pud);
 		unmap_low_page(pmd);
 		__flush_tlb_all();
 	}
@@ -805,15 +874,14 @@ kernel_physical_mapping_remove(unsigned long start, unsigned long end)
 		pgd_t *pgd = pgd_offset_k(start);
 		pud_t *pud;

-		next = (start + PGDIR_SIZE) & PGDIR_MASK;
-		if (next > end)
-			next = end;
+		next = pgd_addr_end(start, end);

 		if (!pgd_present(*pgd))
 			continue;

 		pud = map_low_page((pud_t *)pgd_page_vaddr(*pgd));
-		phys_pud_remove(pud, __pa(start), __pa(end));
+		phys_pud_remove(pud, __pa(start), __pa(next));
+		free_pud_table(pud, pgd);
 		unmap_low_page(pud);
 	}

-- 1.7.6.1 .


On 2012-10-5 10:36, Yasuaki Ishimatsu wrote:
> From: Wen Congyang <wency@cn.fujitsu.com>
> 
> For hot removing memory, we sholud remove page table about the memory.
> So the patch searches a page table about the removed memory, and clear
> page table.
> 
> CC: David Rientjes <rientjes@google.com>
> CC: Jiang Liu <liuj97@gmail.com>
> CC: Len Brown <len.brown@intel.com>
> CC: Christoph Lameter <cl@linux.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
> ---
>  arch/x86/include/asm/pgtable_types.h |    1 
>  arch/x86/mm/init_64.c                |  147 +++++++++++++++++++++++++++++++++++
>  arch/x86/mm/pageattr.c               |   47 +++++------
>  3 files changed, 173 insertions(+), 22 deletions(-)
> 
> Index: linux-3.6/arch/x86/mm/init_64.c
> ===================================================================
> --- linux-3.6.orig/arch/x86/mm/init_64.c	2012-10-04 18:30:21.171698416 +0900
> +++ linux-3.6/arch/x86/mm/init_64.c	2012-10-04 18:30:27.317704652 +0900
> @@ -675,6 +675,151 @@ int arch_add_memory(int nid, u64 start, 
>  }
>  EXPORT_SYMBOL_GPL(arch_add_memory);
>  
> +static void __meminit
> +phys_pte_remove(pte_t *pte_page, unsigned long addr, unsigned long end)
> +{
> +	unsigned pages = 0;
> +	int i = pte_index(addr);
> +
> +	pte_t *pte = pte_page + pte_index(addr);
> +
> +	for (; i < PTRS_PER_PTE; i++, addr += PAGE_SIZE, pte++) {
> +
> +		if (addr >= end)
> +			break;
> +
> +		if (!pte_present(*pte))
> +			continue;
> +
> +		pages++;
> +		set_pte(pte, __pte(0));
> +	}
> +
> +	update_page_count(PG_LEVEL_4K, -pages);
> +}
> +
> +static void __meminit
> +phys_pmd_remove(pmd_t *pmd_page, unsigned long addr, unsigned long end)
> +{
> +	unsigned long pages = 0, next;
> +	int i = pmd_index(addr);
> +
> +	for (; i < PTRS_PER_PMD; i++, addr = next) {
> +		unsigned long pte_phys;
> +		pmd_t *pmd = pmd_page + pmd_index(addr);
> +		pte_t *pte;
> +
> +		if (addr >= end)
> +			break;
> +
> +		next = (addr & PMD_MASK) + PMD_SIZE;
> +
> +		if (!pmd_present(*pmd))
> +			continue;
> +
> +		if (pmd_large(*pmd)) {
> +			if ((addr & ~PMD_MASK) == 0 && next <= end) {
> +				set_pmd(pmd, __pmd(0));
> +				pages++;
> +				continue;
> +			}
> +
> +			/*
> +			 * We use 2M page, but we need to remove part of them,
> +			 * so split 2M page to 4K page.
> +			 */
> +			pte = alloc_low_page(&pte_phys);
> +			__split_large_page((pte_t *)pmd, addr, pte);
> +
> +			spin_lock(&init_mm.page_table_lock);
> +			pmd_populate_kernel(&init_mm, pmd, __va(pte_phys));
> +			spin_unlock(&init_mm.page_table_lock);
> +		}
> +
> +		spin_lock(&init_mm.page_table_lock);
> +		pte = map_low_page((pte_t *)pmd_page_vaddr(*pmd));
> +		phys_pte_remove(pte, addr, end);
> +		unmap_low_page(pte);
> +		spin_unlock(&init_mm.page_table_lock);
> +	}
> +	update_page_count(PG_LEVEL_2M, -pages);
> +}
> +
> +static void __meminit
> +phys_pud_remove(pud_t *pud_page, unsigned long addr, unsigned long end)
> +{
> +	unsigned long pages = 0, next;
> +	int i = pud_index(addr);
> +
> +	for (; i < PTRS_PER_PUD; i++, addr = next) {
> +		unsigned long pmd_phys;
> +		pud_t *pud = pud_page + pud_index(addr);
> +		pmd_t *pmd;
> +
> +		if (addr >= end)
> +			break;
> +
> +		next = (addr & PUD_MASK) + PUD_SIZE;
> +
> +		if (!pud_present(*pud))
> +			continue;
> +
> +		if (pud_large(*pud)) {
> +			if ((addr & ~PUD_MASK) == 0 && next <= end) {
> +				set_pud(pud, __pud(0));
> +				pages++;
> +				continue;
> +			}
> +
> +			/*
> +			 * We use 1G page, but we need to remove part of them,
> +			 * so split 1G page to 2M page.
> +			 */
> +			pmd = alloc_low_page(&pmd_phys);
> +			__split_large_page((pte_t *)pud, addr, (pte_t *)pmd);
> +
> +			spin_lock(&init_mm.page_table_lock);
> +			pud_populate(&init_mm, pud, __va(pmd_phys));
> +			spin_unlock(&init_mm.page_table_lock);
> +		}
> +
> +		pmd = map_low_page(pmd_offset(pud, 0));
> +		phys_pmd_remove(pmd, addr, end);
> +		unmap_low_page(pmd);
> +		__flush_tlb_all();
> +	}
> +	__flush_tlb_all();
> +
> +	update_page_count(PG_LEVEL_1G, -pages);
> +}
> +
> +void __meminit
> +kernel_physical_mapping_remove(unsigned long start, unsigned long end)
> +{
> +	unsigned long next;
> +
> +	start = (unsigned long)__va(start);
> +	end = (unsigned long)__va(end);
> +
> +	for (; start < end; start = next) {
> +		pgd_t *pgd = pgd_offset_k(start);
> +		pud_t *pud;
> +
> +		next = (start + PGDIR_SIZE) & PGDIR_MASK;
> +		if (next > end)
> +			next = end;
> +
> +		if (!pgd_present(*pgd))
> +			continue;
> +
> +		pud = map_low_page((pud_t *)pgd_page_vaddr(*pgd));
> +		phys_pud_remove(pud, __pa(start), __pa(end));
> +		unmap_low_page(pud);
> +	}
> +
> +	__flush_tlb_all();
> +}
> +
>  #ifdef CONFIG_MEMORY_HOTREMOVE
>  int __ref arch_remove_memory(u64 start, u64 size)
>  {
> @@ -687,6 +832,8 @@ int __ref arch_remove_memory(u64 start, 
>  	ret = __remove_pages(zone, start_pfn, nr_pages);
>  	WARN_ON_ONCE(ret);
>  
> +	kernel_physical_mapping_remove(start, start + size);
> +
>  	return ret;
>  }
>  #endif
> Index: linux-3.6/arch/x86/include/asm/pgtable_types.h
> ===================================================================
> --- linux-3.6.orig/arch/x86/include/asm/pgtable_types.h	2012-10-04 18:26:51.925486954 +0900
> +++ linux-3.6/arch/x86/include/asm/pgtable_types.h	2012-10-04 18:30:27.322704656 +0900
> @@ -334,6 +334,7 @@ static inline void update_page_count(int
>   * as a pte too.
>   */
>  extern pte_t *lookup_address(unsigned long address, unsigned int *level);
> +extern int __split_large_page(pte_t *kpte, unsigned long address, pte_t *pbase);
>  
>  #endif	/* !__ASSEMBLY__ */
>  
> Index: linux-3.6/arch/x86/mm/pageattr.c
> ===================================================================
> --- linux-3.6.orig/arch/x86/mm/pageattr.c	2012-10-04 18:26:51.923486952 +0900
> +++ linux-3.6/arch/x86/mm/pageattr.c	2012-10-04 18:30:27.328704662 +0900
> @@ -501,21 +501,13 @@ out_unlock:
>  	return do_split;
>  }
>  
> -static int split_large_page(pte_t *kpte, unsigned long address)
> +int __split_large_page(pte_t *kpte, unsigned long address, pte_t *pbase)
>  {
>  	unsigned long pfn, pfninc = 1;
>  	unsigned int i, level;
> -	pte_t *pbase, *tmp;
> +	pte_t *tmp;
>  	pgprot_t ref_prot;
> -	struct page *base;
> -
> -	if (!debug_pagealloc)
> -		spin_unlock(&cpa_lock);
> -	base = alloc_pages(GFP_KERNEL | __GFP_NOTRACK, 0);
> -	if (!debug_pagealloc)
> -		spin_lock(&cpa_lock);
> -	if (!base)
> -		return -ENOMEM;
> +	struct page *base = virt_to_page(pbase);
>  
>  	spin_lock(&pgd_lock);
>  	/*
> @@ -523,10 +515,11 @@ static int split_large_page(pte_t *kpte,
>  	 * up for us already:
>  	 */
>  	tmp = lookup_address(address, &level);
> -	if (tmp != kpte)
> -		goto out_unlock;
> +	if (tmp != kpte) {
> +		spin_unlock(&pgd_lock);
> +		return 1;
> +	}
>  
> -	pbase = (pte_t *)page_address(base);
>  	paravirt_alloc_pte(&init_mm, page_to_pfn(base));
>  	ref_prot = pte_pgprot(pte_clrhuge(*kpte));
>  	/*
> @@ -579,17 +572,27 @@ static int split_large_page(pte_t *kpte,
>  	 * going on.
>  	 */
>  	__flush_tlb_all();
> +	spin_unlock(&pgd_lock);
>  
> -	base = NULL;
> +	return 0;
> +}
>  
> -out_unlock:
> -	/*
> -	 * If we dropped out via the lookup_address check under
> -	 * pgd_lock then stick the page back into the pool:
> -	 */
> -	if (base)
> +static int split_large_page(pte_t *kpte, unsigned long address)
> +{
> +	pte_t *pbase;
> +	struct page *base;
> +
> +	if (!debug_pagealloc)
> +		spin_unlock(&cpa_lock);
> +	base = alloc_pages(GFP_KERNEL | __GFP_NOTRACK, 0);
> +	if (!debug_pagealloc)
> +		spin_lock(&cpa_lock);
> +	if (!base)
> +		return -ENOMEM;
> +
> +	pbase = (pte_t *)page_address(base);
> +	if (__split_large_page(kpte, address, pbase))
>  		__free_page(base);
> -	spin_unlock(&pgd_lock);
>  
>  	return 0;
>  }
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
