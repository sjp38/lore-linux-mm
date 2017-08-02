Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5E9F8280310
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 02:13:46 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id l3so4766185wrc.12
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 23:13:46 -0700 (PDT)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id 137si2632117wmh.138.2017.08.01.23.13.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 23:13:44 -0700 (PDT)
Subject: Re: [PATCH v4 2/3] powerpc/mm/hugetlb: Add support for reserving
 gigantic huge pages via kernel command line
References: <20170728050127.28338-1-aneesh.kumar@linux.vnet.ibm.com>
 <20170728050127.28338-2-aneesh.kumar@linux.vnet.ibm.com>
From: Christophe LEROY <christophe.leroy@c-s.fr>
Message-ID: <64014b48-a04f-92a7-f561-7ffd386fabc6@c-s.fr>
Date: Wed, 2 Aug 2017 08:13:43 +0200
MIME-Version: 1.0
In-Reply-To: <20170728050127.28338-2-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Scott Wood <oss@buserror.net>

Hi,

Le 28/07/2017 A  07:01, Aneesh Kumar K.V a A(C)crit :
> With commit aa888a74977a8 ("hugetlb: support larger than MAX_ORDER") we added
> support for allocating gigantic hugepages via kernel command line. Switch
> ppc64 arch specific code to use that.
> 
> W.r.t FSL support, we now limit our allocation range using BOOTMEM_ALLOC_ACCESSIBLE.
> 
> We use the kernel command line to do reservation of hugetlb pages on powernv
> platforms. On pseries hash mmu mode the supported gigantic huge page size is
> 16GB and that can only be allocated with hypervisor assist. For pseries the
> command line option doesn't do the allocation. Instead pseries does gigantic
> hugepage allocation based on hypervisor hint that is specified via
> "ibm,expected#pages" property of the memory node.

It looks like it doesn't work on the 8xx:

root@vgoip:~# dmesg | grep -i huge
[    0.000000] Kernel command line: console=ttyCPM0,115200N8 
ip=172.25.231.25:172.25.231.1::255.0.0.0:vgoip:eth0:off hugepagesz=8M 
hugepages=4
[    0.416722] HugeTLB registered 8.00 MiB page size, pre-allocated 4 pages
[    0.423184] HugeTLB registered 512 KiB page size, pre-allocated 0 pages
root@vgoip:~# cat /proc/meminfo
MemTotal:         123388 kB
MemFree:           77900 kB
MemAvailable:      78412 kB
Buffers:               0 kB
Cached:             3964 kB
SwapCached:            0 kB
Active:             3788 kB
Inactive:           1680 kB
Active(anon):       1636 kB
Inactive(anon):       20 kB
Active(file):       2152 kB
Inactive(file):     1660 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:             0 kB
SwapFree:              0 kB
Dirty:                 0 kB
Writeback:             0 kB
AnonPages:          1552 kB
Mapped:             2404 kB
Shmem:               152 kB
Slab:                  0 kB
SReclaimable:          0 kB
SUnreclaim:            0 kB
KernelStack:         304 kB
PageTables:          208 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:       45308 kB
Committed_AS:      16664 kB
VmallocTotal:     866304 kB
VmallocUsed:           0 kB
VmallocChunk:          0 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:        512 kB

Christophe
> 
> Cc: Scott Wood <oss@buserror.net>
> Cc: Christophe Leroy <christophe.leroy@c-s.fr>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>   arch/powerpc/include/asm/book3s/64/mmu-hash.h |   2 +-
>   arch/powerpc/include/asm/hugetlb.h            |  14 --
>   arch/powerpc/kernel/setup-common.c            |   7 -
>   arch/powerpc/mm/hash_utils_64.c               |   2 +-
>   arch/powerpc/mm/hugetlbpage.c                 | 177 +++-----------------------
>   arch/powerpc/mm/init_32.c                     |   2 -
>   6 files changed, 22 insertions(+), 182 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/book3s/64/mmu-hash.h b/arch/powerpc/include/asm/book3s/64/mmu-hash.h
> index 6981a52b3887..f28d21c69f79 100644
> --- a/arch/powerpc/include/asm/book3s/64/mmu-hash.h
> +++ b/arch/powerpc/include/asm/book3s/64/mmu-hash.h
> @@ -468,7 +468,7 @@ extern int htab_bolt_mapping(unsigned long vstart, unsigned long vend,
>   			     int psize, int ssize);
>   int htab_remove_mapping(unsigned long vstart, unsigned long vend,
>   			int psize, int ssize);
> -extern void add_gpage(u64 addr, u64 page_size, unsigned long number_of_pages);
> +extern void pseries_add_gpage(u64 addr, u64 page_size, unsigned long number_of_pages);
>   extern void demote_segment_4k(struct mm_struct *mm, unsigned long addr);
>   
>   #ifdef CONFIG_PPC_PSERIES
> diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
> index 7f4025a6c69e..b8a0fb442c64 100644
> --- a/arch/powerpc/include/asm/hugetlb.h
> +++ b/arch/powerpc/include/asm/hugetlb.h
> @@ -218,18 +218,4 @@ static inline pte_t *hugepte_offset(hugepd_t hpd, unsigned long addr,
>   }
>   #endif /* CONFIG_HUGETLB_PAGE */
>   
> -/*
> - * FSL Book3E platforms require special gpage handling - the gpages
> - * are reserved early in the boot process by memblock instead of via
> - * the .dts as on IBM platforms.
> - */
> -#if defined(CONFIG_HUGETLB_PAGE) && (defined(CONFIG_PPC_FSL_BOOK3E) || \
> -    defined(CONFIG_PPC_8xx))
> -extern void __init reserve_hugetlb_gpages(void);
> -#else
> -static inline void reserve_hugetlb_gpages(void)
> -{
> -}
> -#endif
> -
>   #endif /* _ASM_POWERPC_HUGETLB_H */
> diff --git a/arch/powerpc/kernel/setup-common.c b/arch/powerpc/kernel/setup-common.c
> index 94a948207cd2..0f896f17d5ab 100644
> --- a/arch/powerpc/kernel/setup-common.c
> +++ b/arch/powerpc/kernel/setup-common.c
> @@ -916,13 +916,6 @@ void __init setup_arch(char **cmdline_p)
>   	/* Reserve large chunks of memory for use by CMA for KVM. */
>   	kvm_cma_reserve();
>   
> -	/*
> -	 * Reserve any gigantic pages requested on the command line.
> -	 * memblock needs to have been initialized by the time this is
> -	 * called since this will reserve memory.
> -	 */
> -	reserve_hugetlb_gpages();
> -
>   	klp_init_thread_info(&init_thread_info);
>   
>   	init_mm.start_code = (unsigned long)_stext;
> diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
> index 7a20669c19e7..2f1f6bc04012 100644
> --- a/arch/powerpc/mm/hash_utils_64.c
> +++ b/arch/powerpc/mm/hash_utils_64.c
> @@ -509,7 +509,7 @@ static int __init htab_dt_scan_hugepage_blocks(unsigned long node,
>   			phys_addr, block_size, expected_pages);
>   	if (phys_addr + (16 * GB) <= memblock_end_of_DRAM()) {
>   		memblock_reserve(phys_addr, block_size * expected_pages);
> -		add_gpage(phys_addr, block_size, expected_pages);
> +		pseries_add_gpage(phys_addr, block_size, expected_pages);
>   	}
>   	return 0;
>   }
> diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
> index e1bf5ca397fe..a0271d738a30 100644
> --- a/arch/powerpc/mm/hugetlbpage.c
> +++ b/arch/powerpc/mm/hugetlbpage.c
> @@ -36,26 +36,6 @@
>   unsigned int HPAGE_SHIFT;
>   EXPORT_SYMBOL(HPAGE_SHIFT);
>   
> -/*
> - * Tracks gpages after the device tree is scanned and before the
> - * huge_boot_pages list is ready.  On non-Freescale implementations, this is
> - * just used to track 16G pages and so is a single array.  FSL-based
> - * implementations may have more than one gpage size, so we need multiple
> - * arrays
> - */
> -#if defined(CONFIG_PPC_FSL_BOOK3E) || defined(CONFIG_PPC_8xx)
> -#define MAX_NUMBER_GPAGES	128
> -struct psize_gpages {
> -	u64 gpage_list[MAX_NUMBER_GPAGES];
> -	unsigned int nr_gpages;
> -};
> -static struct psize_gpages gpage_freearray[MMU_PAGE_COUNT];
> -#else
> -#define MAX_NUMBER_GPAGES	1024
> -static u64 gpage_freearray[MAX_NUMBER_GPAGES];
> -static unsigned nr_gpages;
> -#endif
> -
>   #define hugepd_none(hpd)	(hpd_val(hpd) == 0)
>   
>   pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr, unsigned long sz)
> @@ -210,145 +190,20 @@ pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz
>   	return hugepte_offset(*hpdp, addr, pdshift);
>   }
>   
> -#if defined(CONFIG_PPC_FSL_BOOK3E) || defined(CONFIG_PPC_8xx)
> -/* Build list of addresses of gigantic pages.  This function is used in early
> - * boot before the buddy allocator is setup.
> - */
> -void add_gpage(u64 addr, u64 page_size, unsigned long number_of_pages)
> -{
> -	unsigned int idx = shift_to_mmu_psize(__ffs(page_size));
> -	int i;
> -
> -	if (addr == 0)
> -		return;
> -
> -	gpage_freearray[idx].nr_gpages = number_of_pages;
> -
> -	for (i = 0; i < number_of_pages; i++) {
> -		gpage_freearray[idx].gpage_list[i] = addr;
> -		addr += page_size;
> -	}
> -}
> -
> -/*
> - * Moves the gigantic page addresses from the temporary list to the
> - * huge_boot_pages list.
> - */
> -int alloc_bootmem_huge_page(struct hstate *hstate)
> -{
> -	struct huge_bootmem_page *m;
> -	int idx = shift_to_mmu_psize(huge_page_shift(hstate));
> -	int nr_gpages = gpage_freearray[idx].nr_gpages;
> -
> -	if (nr_gpages == 0)
> -		return 0;
> -
> -#ifdef CONFIG_HIGHMEM
> -	/*
> -	 * If gpages can be in highmem we can't use the trick of storing the
> -	 * data structure in the page; allocate space for this
> -	 */
> -	m = memblock_virt_alloc(sizeof(struct huge_bootmem_page), 0);
> -	m->phys = gpage_freearray[idx].gpage_list[--nr_gpages];
> -#else
> -	m = phys_to_virt(gpage_freearray[idx].gpage_list[--nr_gpages]);
> -#endif
> -
> -	list_add(&m->list, &huge_boot_pages);
> -	gpage_freearray[idx].nr_gpages = nr_gpages;
> -	gpage_freearray[idx].gpage_list[nr_gpages] = 0;
> -	m->hstate = hstate;
> -
> -	return 1;
> -}
> +#ifdef CONFIG_PPC_BOOK3S_64
>   /*
> - * Scan the command line hugepagesz= options for gigantic pages; store those in
> - * a list that we use to allocate the memory once all options are parsed.
> + * Tracks gpages after the device tree is scanned and before the
> + * huge_boot_pages list is ready on pSeries.
>    */
> -
> -unsigned long gpage_npages[MMU_PAGE_COUNT];
> -
> -static int __init do_gpage_early_setup(char *param, char *val,
> -				       const char *unused, void *arg)
> -{
> -	static phys_addr_t size;
> -	unsigned long npages;
> -
> -	/*
> -	 * The hugepagesz and hugepages cmdline options are interleaved.  We
> -	 * use the size variable to keep track of whether or not this was done
> -	 * properly and skip over instances where it is incorrect.  Other
> -	 * command-line parsing code will issue warnings, so we don't need to.
> -	 *
> -	 */
> -	if ((strcmp(param, "default_hugepagesz") == 0) ||
> -	    (strcmp(param, "hugepagesz") == 0)) {
> -		size = memparse(val, NULL);
> -	} else if (strcmp(param, "hugepages") == 0) {
> -		if (size != 0) {
> -			if (sscanf(val, "%lu", &npages) <= 0)
> -				npages = 0;
> -			if (npages > MAX_NUMBER_GPAGES) {
> -				pr_warn("MMU: %lu pages requested for page "
> -#ifdef CONFIG_PHYS_ADDR_T_64BIT
> -					"size %llu KB, limiting to "
> -#else
> -					"size %u KB, limiting to "
> -#endif
> -					__stringify(MAX_NUMBER_GPAGES) "\n",
> -					npages, size / 1024);
> -				npages = MAX_NUMBER_GPAGES;
> -			}
> -			gpage_npages[shift_to_mmu_psize(__ffs(size))] = npages;
> -			size = 0;
> -		}
> -	}
> -	return 0;
> -}
> -
> +#define MAX_NUMBER_GPAGES	1024
> +__initdata static u64 gpage_freearray[MAX_NUMBER_GPAGES];
> +__initdata static unsigned nr_gpages;
>   
>   /*
> - * This function allocates physical space for pages that are larger than the
> - * buddy allocator can handle.  We want to allocate these in highmem because
> - * the amount of lowmem is limited.  This means that this function MUST be
> - * called before lowmem_end_addr is set up in MMU_init() in order for the lmb
> - * allocate to grab highmem.
> - */
> -void __init reserve_hugetlb_gpages(void)
> -{
> -	static __initdata char cmdline[COMMAND_LINE_SIZE];
> -	phys_addr_t size, base;
> -	int i;
> -
> -	strlcpy(cmdline, boot_command_line, COMMAND_LINE_SIZE);
> -	parse_args("hugetlb gpages", cmdline, NULL, 0, 0, 0,
> -			NULL, &do_gpage_early_setup);
> -
> -	/*
> -	 * Walk gpage list in reverse, allocating larger page sizes first.
> -	 * Skip over unsupported sizes, or sizes that have 0 gpages allocated.
> -	 * When we reach the point in the list where pages are no longer
> -	 * considered gpages, we're done.
> -	 */
> -	for (i = MMU_PAGE_COUNT-1; i >= 0; i--) {
> -		if (mmu_psize_defs[i].shift == 0 || gpage_npages[i] == 0)
> -			continue;
> -		else if (mmu_psize_to_shift(i) < (MAX_ORDER + PAGE_SHIFT))
> -			break;
> -
> -		size = (phys_addr_t)(1ULL << mmu_psize_to_shift(i));
> -		base = memblock_alloc_base(size * gpage_npages[i], size,
> -					   MEMBLOCK_ALLOC_ANYWHERE);
> -		add_gpage(base, size, gpage_npages[i]);
> -	}
> -}
> -
> -#else /* !PPC_FSL_BOOK3E */
> -
> -/* Build list of addresses of gigantic pages.  This function is used in early
> + * Build list of addresses of gigantic pages.  This function is used in early
>    * boot before the buddy allocator is setup.
>    */
> -void add_gpage(u64 addr, u64 page_size, unsigned long number_of_pages)
> +void __init pseries_add_gpage(u64 addr, u64 page_size, unsigned long number_of_pages)
>   {
>   	if (!addr)
>   		return;
> @@ -360,10 +215,7 @@ void add_gpage(u64 addr, u64 page_size, unsigned long number_of_pages)
>   	}
>   }
>   
> -/* Moves the gigantic page addresses from the temporary list to the
> - * huge_boot_pages list.
> - */
> -int alloc_bootmem_huge_page(struct hstate *hstate)
> +int __init pseries_alloc_bootmem_huge_page(struct hstate *hstate)
>   {
>   	struct huge_bootmem_page *m;
>   	if (nr_gpages == 0)
> @@ -376,6 +228,17 @@ int alloc_bootmem_huge_page(struct hstate *hstate)
>   }
>   #endif
>   
> +
> +int __init alloc_bootmem_huge_page(struct hstate *h)
> +{
> +
> +#ifdef CONFIG_PPC_BOOK3S_64
> +	if (firmware_has_feature(FW_FEATURE_LPAR) && !radix_enabled())
> +		return pseries_alloc_bootmem_huge_page(h);
> +#endif
> +	return __alloc_bootmem_huge_page(h);
> +}
> +
>   #if defined(CONFIG_PPC_FSL_BOOK3E) || defined(CONFIG_PPC_8xx)
>   #define HUGEPD_FREELIST_SIZE \
>   	((PAGE_SIZE - sizeof(struct hugepd_freelist)) / sizeof(pte_t))
> diff --git a/arch/powerpc/mm/init_32.c b/arch/powerpc/mm/init_32.c
> index 8a7c38b8d335..436d9721ab63 100644
> --- a/arch/powerpc/mm/init_32.c
> +++ b/arch/powerpc/mm/init_32.c
> @@ -132,8 +132,6 @@ void __init MMU_init(void)
>   	 * Reserve gigantic pages for hugetlb.  This MUST occur before
>   	 * lowmem_end_addr is initialized below.
>   	 */
> -	reserve_hugetlb_gpages();
> -
>   	if (memblock.memory.cnt > 1) {
>   #ifndef CONFIG_WII
>   		memblock_enforce_memory_limit(memblock.memory.regions[0].size);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
