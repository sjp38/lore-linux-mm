Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id C3F478E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 06:43:22 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id 128so5532750itw.8
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 03:43:22 -0800 (PST)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id b2si8500380iod.1.2018.12.12.03.43.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 03:43:21 -0800 (PST)
Date: Wed, 12 Dec 2018 11:42:36 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
Subject: Re: [PATCH v2] arm64: Add memory hotplug support
Message-ID: <20181212114236.000030c9@huawei.com>
In-Reply-To: <331db1485b4c8c3466217e16a1e1f05618e9bae8.1544553902.git.robin.murphy@arm.com>
References: <331db1485b4c8c3466217e16a1e1f05618e9bae8.1544553902.git.robin.murphy@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: will.deacon@arm.com, catalin.marinas@arm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, cyrilc@xilinx.com, james.morse@arm.com, anshuman.khandual@arm.com, linux-mm@kvack.org

On Tue, 11 Dec 2018 18:48:48 +0000
Robin Murphy <robin.murphy@arm.com> wrote:

> Wire up the basic support for hot-adding memory. Since memory hotplug
> is fairly tightly coupled to sparsemem, we tweak pfn_valid() to also
> cross-check the presence of a section in the manner of the generic
> implementation, before falling back to memblock to check for no-map
> regions within a present section as before. By having arch_add_memory(()
> create the linear mapping first, this then makes everything work in the
> way that __add_section() expects.
> 
> We expect hotplug to be ACPI-driven, so the swapper_pg_dir updates
> should be safe from races by virtue of the global device hotplug lock.
> 
> Signed-off-by: Robin Murphy <robin.murphy@arm.com>
Hi Robin,

What tree is this against?  

rodata_full doesn't seem be exist for me on 4.20-rc6. 

With v1 I did the 'new node' test and it looked good except for an
old cgroups warning that has always been there (and has been on my list
to track down for a long time).

Jonathan
> ---
> 
> v2: Handle page-mappings-only cases appropriately
> 
>  arch/arm64/Kconfig   |  3 +++
>  arch/arm64/mm/init.c |  8 ++++++++
>  arch/arm64/mm/mmu.c  | 17 +++++++++++++++++
>  arch/arm64/mm/numa.c | 10 ++++++++++
>  4 files changed, 38 insertions(+)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 4dbef530cf58..be423fda5cec 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -261,6 +261,9 @@ config ZONE_DMA32
>  config HAVE_GENERIC_GUP
>  	def_bool y
>  
> +config ARCH_ENABLE_MEMORY_HOTPLUG
> +	def_bool y
> +
>  config SMP
>  	def_bool y
>  
> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> index 6cde00554e9b..4bfe0fc9edac 100644
> --- a/arch/arm64/mm/init.c
> +++ b/arch/arm64/mm/init.c
> @@ -291,6 +291,14 @@ int pfn_valid(unsigned long pfn)
>  
>  	if ((addr >> PAGE_SHIFT) != pfn)
>  		return 0;
> +
> +#ifdef CONFIG_SPARSEMEM
> +	if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
> +		return 0;
> +
> +	if (!valid_section(__nr_to_section(pfn_to_section_nr(pfn))))
> +		return 0;
> +#endif
>  	return memblock_is_map_memory(addr);
>  }
>  EXPORT_SYMBOL(pfn_valid);
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index 674c409a8ce4..da513a1facf4 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -1046,3 +1046,20 @@ int pud_free_pmd_page(pud_t *pudp, unsigned long addr)
>  	pmd_free(NULL, table);
>  	return 1;
>  }
> +
> +#ifdef CONFIG_MEMORY_HOTPLUG
> +int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
> +		    bool want_memblock)
> +{
> +	int flags = 0;
> +
> +	if (rodata_full || debug_pagealloc_enabled())
> +		flags = NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
> +
> +	__create_pgd_mapping(swapper_pg_dir, start, __phys_to_virt(start),
> +			     size, PAGE_KERNEL, pgd_pgtable_alloc, flags);
> +
> +	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
> +			   altmap, want_memblock);
> +}
> +#endif
> diff --git a/arch/arm64/mm/numa.c b/arch/arm64/mm/numa.c
> index 27a31efd9e8e..ae34e3a1cef1 100644
> --- a/arch/arm64/mm/numa.c
> +++ b/arch/arm64/mm/numa.c
> @@ -466,3 +466,13 @@ void __init arm64_numa_init(void)
>  
>  	numa_init(dummy_numa_init);
>  }
> +
> +/*
> + * We hope that we will be hotplugging memory on nodes we already know about,
> + * such that acpi_get_node() succeeds and we never fall back to this...
> + */
> +int memory_add_physaddr_to_nid(u64 addr)
> +{
> +	pr_warn("Unknown node for memory at 0x%llx, assuming node 0\n", addr);
> +	return 0;
> +}
