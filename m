Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 598BF8E0001
	for <linux-mm@kvack.org>; Sun, 16 Dec 2018 07:34:48 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id y88so8823770pfi.9
        for <linux-mm@kvack.org>; Sun, 16 Dec 2018 04:34:48 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f65si9271210pfb.194.2018.12.16.04.34.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Dec 2018 04:34:46 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBGCTUor026751
	for <linux-mm@kvack.org>; Sun, 16 Dec 2018 07:34:46 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pdfcu402a-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 16 Dec 2018 07:34:45 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 16 Dec 2018 12:34:43 -0000
Date: Sun, 16 Dec 2018 14:34:35 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH v5 2/5] acpi/numa: Set the memory-side-cache size in
 memblocks
References: <154483851047.1672629.15001135860756738866.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154483852084.1672629.6281294122517430332.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154483852084.1672629.6281294122517430332.stgit@dwillia2-desk3.amr.corp.intel.com>
Message-Id: <20181216123434.GA30212@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Keith Busch <keith.busch@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 14, 2018 at 05:48:40PM -0800, Dan Williams wrote:
> From: Keith Busch <keith.busch@intel.com>
> 
> Add memblock based enumeration of memory-side-cache of System RAM.
> Detect the capability in early init through HMAT tables, and set the
> size in the address range memblocks if a direct mapped side cache is
> present.
> 
> Cc: <x86@kernel.org>
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Mike Rapoport <rppt@linux.ibm.com>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  arch/x86/Kconfig         |    1 +
>  drivers/acpi/numa.c      |   32 ++++++++++++++++++++++++++++++++
>  include/linux/memblock.h |   36 ++++++++++++++++++++++++++++++++++++
>  mm/Kconfig               |    3 +++
>  mm/memblock.c            |   20 ++++++++++++++++++++
>  5 files changed, 92 insertions(+)
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 8689e794a43c..3f9c413d8eb5 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -171,6 +171,7 @@ config X86
>  	select HAVE_KVM
>  	select HAVE_LIVEPATCH			if X86_64
>  	select HAVE_MEMBLOCK_NODE_MAP
> +	select HAVE_MEMBLOCK_CACHE_INFO		if ACPI_NUMA
>  	select HAVE_MIXED_BREAKPOINTS_REGS
>  	select HAVE_MOD_ARCH_SPECIFIC
>  	select HAVE_NMI
> diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
> index f5e09c39ff22..ec7e849f1c19 100644
> --- a/drivers/acpi/numa.c
> +++ b/drivers/acpi/numa.c
> @@ -40,6 +40,12 @@ static int pxm_to_node_map[MAX_PXM_DOMAINS]
>  static int node_to_pxm_map[MAX_NUMNODES]
>  			= { [0 ... MAX_NUMNODES - 1] = PXM_INVAL };
>  
> +struct mem_cacheinfo {
> +	phys_addr_t size;
> +	bool direct_mapped;
> +};
> +static struct mem_cacheinfo side_cached_pxms[MAX_PXM_DOMAINS] __initdata;
> +
>  unsigned char acpi_srat_revision __initdata;
>  int acpi_numa __initdata;
>  
> @@ -262,6 +268,8 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
>  	u64 start, end;
>  	u32 hotpluggable;
>  	int node, pxm;
> +	u64 cache_size;
> +	bool direct;
>  
>  	if (srat_disabled())
>  		goto out_err;
> @@ -308,6 +316,13 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
>  		pr_warn("SRAT: Failed to mark hotplug range [mem %#010Lx-%#010Lx] in memblock\n",
>  			(unsigned long long)start, (unsigned long long)end - 1);
>  
> +	cache_size = side_cached_pxms[pxm].size;
> +	direct = side_cached_pxms[pxm].direct_mapped;
> +	if (cache_size &&
> +	    memblock_set_sidecache(start, ma->length, cache_size, direct))
> +		pr_warn("SRAT: Failed to mark side cached range [mem %#010Lx-%#010Lx] in memblock\n",
> +			(unsigned long long)start, (unsigned long long)end - 1);
> +
>  	max_possible_pfn = max(max_possible_pfn, PFN_UP(end - 1));
>  
>  	return 0;
> @@ -411,6 +426,18 @@ acpi_parse_memory_affinity(union acpi_subtable_headers * header,
>  	return 0;
>  }
>  
> +static int __init
> +acpi_parse_cache(union acpi_subtable_headers *header, const unsigned long end)
> +{
> +	struct acpi_hmat_cache *c = (void *)header;
> +	u32 attrs = (c->cache_attributes & ACPI_HMAT_CACHE_ASSOCIATIVITY) >> 8;
> +
> +	if (attrs == ACPI_HMAT_CA_DIRECT_MAPPED)
> +		side_cached_pxms[c->memory_PD].direct_mapped = true;
> +	side_cached_pxms[c->memory_PD].size += c->cache_size;
> +	return 0;
> +}
> +
>  static int __init acpi_parse_srat(struct acpi_table_header *table)
>  {
>  	struct acpi_table_srat *srat = (struct acpi_table_srat *)table;
> @@ -460,6 +487,11 @@ int __init acpi_numa_init(void)
>  					sizeof(struct acpi_table_srat),
>  					srat_proc, ARRAY_SIZE(srat_proc), 0);
>  
> +		acpi_table_parse_entries(ACPI_SIG_HMAT,
> +					 sizeof(struct acpi_table_hmat),
> +					 ACPI_HMAT_TYPE_CACHE,
> +					 acpi_parse_cache, 0);
> +
>  		cnt = acpi_table_parse_srat(ACPI_SRAT_TYPE_MEMORY_AFFINITY,
>  					    acpi_parse_memory_affinity, 0);
>  	}
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
> index aee299a6aa76..169ed3dd456d 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -60,6 +60,10 @@ struct memblock_region {
>  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>  	int nid;
>  #endif
> +#ifdef CONFIG_HAVE_MEMBLOCK_CACHE_INFO
> +	phys_addr_t cache_size;
> +	bool direct_mapped;
> +#endif

Please add descriptions of the new fields to the 'struct memblock_region'
kernel-doc.

>  };
>  
>  /**
> @@ -317,6 +321,38 @@ static inline int memblock_get_region_node(const struct memblock_region *r)
>  }
>  #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>  
> +#ifdef CONFIG_HAVE_MEMBLOCK_CACHE_INFO
> +int memblock_set_sidecache(phys_addr_t base, phys_addr_t size,
> +			   phys_addr_t cache_size, bool direct_mapped);
> +
> +static inline bool memblock_sidecache_direct_mapped(struct memblock_region *m)
> +{
> +	return m->direct_mapped;
> +}
> +
> +static inline phys_addr_t memblock_sidecache_size(struct memblock_region *m)
> +{
> +	return m->cache_size;
> +}
> +#else
> +static inline int memblock_set_sidecache(phys_addr_t base, phys_addr_t size,
> +					 phys_addr_t cache_size,
> +					 bool direct_mapped)
> +{
> +	return 0;
> +}
> +
> +static inline phys_addr_t memblock_sidecache_size(struct memblock_region *m)
> +{
> +	return 0;
> +}
> +
> +static inline bool memblock_sidecache_direct_mapped(struct memblock_region *m)
> +{
> +	return false;
> +}
> +#endif /* CONFIG_HAVE_MEMBLOCK_CACHE_INFO */
> +
>  /* Flags for memblock allocation APIs */
>  #define MEMBLOCK_ALLOC_ANYWHERE	(~(phys_addr_t)0)
>  #define MEMBLOCK_ALLOC_ACCESSIBLE	0
> diff --git a/mm/Kconfig b/mm/Kconfig
> index d85e39da47ae..c7944299a89e 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -142,6 +142,9 @@ config ARCH_DISCARD_MEMBLOCK
>  config MEMORY_ISOLATION
>  	bool
>  
> +config HAVE_MEMBLOCK_CACHE_INFO
> +	bool
> +
>  #
>  # Only be set on architectures that have completely implemented memory hotplug
>  # feature. If you are not sure, don't touch it.
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 9a2d5ae81ae1..185bfd4e87bb 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -822,6 +822,26 @@ int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
>  	return memblock_add_range(&memblock.reserved, base, size, MAX_NUMNODES, 0);
>  }
>  
> +#ifdef CONFIG_HAVE_MEMBLOCK_CACHE_INFO

Kernel-doc here would be appreciated.

> +int __init_memblock memblock_set_sidecache(phys_addr_t base, phys_addr_t size,
> +			   phys_addr_t cache_size, bool direct_mapped)
> +{
> +	struct memblock_type *type = &memblock.memory;
> +	int i, ret, start_rgn, end_rgn;
> +
> +	ret = memblock_isolate_range(type, base, size, &start_rgn, &end_rgn);
> +	if (ret)
> +		return ret;
> +
> +	for (i = start_rgn; i < end_rgn; i++) {
> +		type->regions[i].cache_size = cache_size;
> +		type->regions[i].direct_mapped = direct_mapped;
> +	}
> +
> +	return 0;
> +}
> +#endif
> +
>  /**
>   * memblock_setclr_flag - set or clear flag for a memory region
>   * @base: base address of the region
> 

-- 
Sincerely yours,
Mike.
