Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 693DA6B0009
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 05:16:45 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 33so13090060wrs.3
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 02:16:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k19sor9148805ede.13.2018.02.01.02.16.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Feb 2018 02:16:43 -0800 (PST)
Date: Thu, 1 Feb 2018 13:16:41 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/2] mm/sparse.c: Add nr_present_sections to change the
 mem_map allocation
Message-ID: <20180201101641.icoxv2sp6ckrjfxd@node.shutemov.name>
References: <20180201071956.14365-1-bhe@redhat.com>
 <20180201071956.14365-3-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180201071956.14365-3-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, tglx@linutronix.de, douly.fnst@cn.fujitsu.com

On Thu, Feb 01, 2018 at 03:19:56PM +0800, Baoquan He wrote:
> In sparse_init(), we allocate usemap_map and map_map which are pointer
> array with the size of NR_MEM_SECTIONS. The memory consumption can be
> ignorable in 4-level paging mode. While in 5-level paging, this costs
> much memory, 512M. Kdump kernel even can't boot up with a normal
> 'crashkernel=' setting.
> 
> Here add a new variable to record the number of present sections. Let's
> allocate the usemap_map and map_map with the size of nr_present_sections.
> We only need to make sure that for the ith present section, usemap_map[i]
> and map_map[i] store its usemap and mem_map separately.
> 
> This change can save much memory on most of systems. Anytime, we should
> avoid to define array or allocate memory with the size of NR_MEM_SECTIONS.

That's very desirable outcome. But I don't know much about sparsemem.

Dave, could you take a look?

> 
> Signed-off-by: Baoquan He <bhe@redhat.com>
> ---
>  mm/sparse-vmemmap.c |  8 +++++---
>  mm/sparse.c         | 39 +++++++++++++++++++++++++--------------
>  2 files changed, 30 insertions(+), 17 deletions(-)
> 
> diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
> index 315bea91e276..5bb7b63276b3 100644
> --- a/mm/sparse-vmemmap.c
> +++ b/mm/sparse-vmemmap.c
> @@ -302,6 +302,7 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
>  	unsigned long pnum;
>  	unsigned long size = sizeof(struct page) * PAGES_PER_SECTION;
>  	void *vmemmap_buf_start;
> +	int i = 0;
>  
>  	size = ALIGN(size, PMD_SIZE);
>  	vmemmap_buf_start = __earlyonly_bootmem_alloc(nodeid, size * map_count,
> @@ -312,14 +313,15 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
>  		vmemmap_buf_end = vmemmap_buf_start + size * map_count;
>  	}
>  
> -	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
> +	for (pnum = pnum_begin; pnum < pnum_end && i < map_count; pnum++) {
>  		struct mem_section *ms;
>  
>  		if (!present_section_nr(pnum))
>  			continue;
>  
> -		map_map[pnum] = sparse_mem_map_populate(pnum, nodeid);
> -		if (map_map[pnum])
> +		i++;
> +		map_map[i-1] = sparse_mem_map_populate(pnum, nodeid);
> +		if (map_map[i-1])
>  			continue;
>  		ms = __nr_to_section(pnum);
>  		pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 54eba92b72a1..18273261be6d 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -202,6 +202,7 @@ static inline int next_present_section_nr(int section_nr)
>  	      (section_nr <= __highest_present_section_nr));	\
>  	     section_nr = next_present_section_nr(section_nr))
>  
> +static int nr_present_sections;
>  /* Record a memory area against a node. */
>  void __init memory_present(int nid, unsigned long start, unsigned long end)
>  {
> @@ -231,6 +232,7 @@ void __init memory_present(int nid, unsigned long start, unsigned long end)
>  			ms->section_mem_map = sparse_encode_early_nid(nid) |
>  							SECTION_IS_ONLINE;
>  			section_mark_present(ms);
> +			nr_present_sections++;
>  		}
>  	}
>  }
> @@ -399,6 +401,7 @@ static void __init sparse_early_usemaps_alloc_node(void *data,
>  	unsigned long pnum;
>  	unsigned long **usemap_map = (unsigned long **)data;
>  	int size = usemap_size();
> +	int i = 0;
>  
>  	usemap = sparse_early_usemaps_alloc_pgdat_section(NODE_DATA(nodeid),
>  							  size * usemap_count);
> @@ -407,12 +410,13 @@ static void __init sparse_early_usemaps_alloc_node(void *data,
>  		return;
>  	}
>  
> -	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
> +	for (pnum = pnum_begin; pnum < pnum_end && i < usemap_count; pnum++) {
>  		if (!present_section_nr(pnum))
>  			continue;
> -		usemap_map[pnum] = usemap;
> +		usemap_map[i] = usemap;
>  		usemap += size;
> -		check_usemap_section_nr(nodeid, usemap_map[pnum]);
> +		check_usemap_section_nr(nodeid, usemap_map[i]);
> +		i++;
>  	}
>  }
>  
> @@ -440,13 +444,15 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
>  	void *map;
>  	unsigned long pnum;
>  	unsigned long size = sizeof(struct page) * PAGES_PER_SECTION;
> +	int i;
>  
>  	map = alloc_remap(nodeid, size * map_count);
>  	if (map) {
> -		for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
> +		i = 0;
> +		for (pnum = pnum_begin; pnum < pnum_end && i < map_count; pnum++) {
>  			if (!present_section_nr(pnum))
>  				continue;
> -			map_map[pnum] = map;
> +			map_map[i] = map;
>  			map += size;
>  		}
>  		return;
> @@ -457,23 +463,26 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
>  					      PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
>  					      BOOTMEM_ALLOC_ACCESSIBLE, nodeid);
>  	if (map) {
> -		for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
> +		i = 0;
> +		for (pnum = pnum_begin; pnum < pnum_end && i < map_count; pnum++) {
>  			if (!present_section_nr(pnum))
>  				continue;
> -			map_map[pnum] = map;
> +			map_map[i] = map;
>  			map += size;
>  		}
>  		return;
>  	}
>  
>  	/* fallback */
> -	for (pnum = pnum_begin; pnum < pnum_end; pnum++) {
> +	i = 0;
> +	for (pnum = pnum_begin; pnum < pnum_end && i < map_count; pnum++) {
>  		struct mem_section *ms;
>  
>  		if (!present_section_nr(pnum))
>  			continue;
> -		map_map[pnum] = sparse_mem_map_populate(pnum, nodeid);
> -		if (map_map[pnum])
> +		i++;
> +		map_map[i-1] = sparse_mem_map_populate(pnum, nodeid);
> +		if (map_map[i-1])
>  			continue;
>  		ms = __nr_to_section(pnum);
>  		pr_err("%s: sparsemem memory map backing failed some memory will not be available\n",
> @@ -552,6 +561,7 @@ static void __init alloc_usemap_and_memmap(void (*alloc_func)
>  		/* new start, update count etc*/
>  		nodeid_begin = nodeid;
>  		pnum_begin = pnum;
> +		data += map_count;
>  		map_count = 1;
>  	}
>  	/* ok, last chunk */
> @@ -570,6 +580,7 @@ void __init sparse_init(void)
>  	unsigned long *usemap;
>  	unsigned long **usemap_map;
>  	int size;
> +	int i = 0;
>  #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
>  	int size2;
>  	struct page **map_map;
> @@ -592,7 +603,7 @@ void __init sparse_init(void)
>  	 * powerpc need to call sparse_init_one_section right after each
>  	 * sparse_early_mem_map_alloc, so allocate usemap_map at first.
>  	 */
> -	size = sizeof(unsigned long *) * NR_MEM_SECTIONS;
> +	size = sizeof(unsigned long *) * nr_present_sections;
>  	usemap_map = memblock_virt_alloc(size, 0);
>  	if (!usemap_map)
>  		panic("can not allocate usemap_map\n");
> @@ -600,7 +611,7 @@ void __init sparse_init(void)
>  							(void *)usemap_map);
>  
>  #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
> -	size2 = sizeof(struct page *) * NR_MEM_SECTIONS;
> +	size2 = sizeof(struct page *) * nr_present_sections;
>  	map_map = memblock_virt_alloc(size2, 0);
>  	if (!map_map)
>  		panic("can not allocate map_map\n");
> @@ -611,7 +622,7 @@ void __init sparse_init(void)
>  	for_each_present_section_nr(0, pnum) {
>  		struct mem_section *ms;
>  		ms = __nr_to_section(pnum);
> -		usemap = usemap_map[pnum];
> +		usemap = usemap_map[i];
>  		if (!usemap) {
>  #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
>  			ms->section_mem_map = 0;
> @@ -620,7 +631,7 @@ void __init sparse_init(void)
>  		}
>  
>  #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
> -		map = map_map[pnum];
> +		map = map_map[i];
>  #else
>  		map = sparse_early_mem_map_alloc(pnum);
>  #endif
> -- 
> 2.13.6
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
