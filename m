Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4DDE96B02A8
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 05:08:01 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id p188so2121263oig.17
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 02:08:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c14si9435916oiy.303.2018.02.22.02.07.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 02:07:59 -0800 (PST)
Date: Thu, 22 Feb 2018 05:07:58 -0500 (EST)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <1763048150.5490642.1519294078455.JavaMail.zimbra@redhat.com>
In-Reply-To: <20180222091130.32165-4-bhe@redhat.com>
References: <20180222091130.32165-1-bhe@redhat.com> <20180222091130.32165-4-bhe@redhat.com>
Subject: Re: [PATCH v2 3/3] mm/sparse: Optimize memmap allocation during
 sparse_init()
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, dave hansen <dave.hansen@intel.com>, linux-mm@kvack.org, akpm@linux-foundation.org, kirill shutemov <kirill.shutemov@linux.intel.com>, mhocko@suse.com, tglx@linutronix.de


Hi Baoquan,

> 
> In sparse_init(), two temporary pointer arrays, usemap_map and map_map
> are allocated with the size of NR_MEM_SECTIONS. They are used to store
> each memory section's usemap and mem map if marked as present. With
> the help of these two arrays, continuous memory chunk is allocated for
> usemap and memmap for memory sections on one node. This avoids too many
> memory fragmentations. Like below diagram, '1' indicates the present
> memory section, '0' means absent one. The number 'n' could be much
> smaller than NR_MEM_SECTIONS on most of systems.
> 
> |1|1|1|1|0|0|0|0|1|1|0|0|...|1|0||1|0|...|1||0|1|...|0|
> -------------------------------------------------------
>  0 1 2 3         4 5         i   i+1     n-1   n
> 
> If fail to populate the page tables to map one section's memmap, its
> ->section_mem_map will be cleared finally to indicate that it's not present.
> After use, these two arrays will be released at the end of sparse_init().
> 
> In 4-level paging mode, each array costs 4M which can be ignorable. While
> in 5-level paging, they costs 256M each, 512M altogether. Kdump kernel
> Usually only reserves very few memory, e.g 256M. So, even thouth they are
> temporarily allocated, still not acceptable.
> 
> In fact, there's no need to allocate them with the size of NR_MEM_SECTIONS.
> Since the ->section_mem_map clearing has been deferred to the last, the
> number of present memory sections are kept the same during sparse_init()
> until we finally clear out the memory section's ->section_mem_map if its
> usemap or memmap is not correctly handled. Thus in the middle whenever
> for_each_present_section_nr() loop is taken, the i-th present memory
> section is always the same one.
> 
> Here only allocate usemap_map and map_map with the size of
> 'nr_present_sections'. For the i-th present memory section, install its
> usemap and memmap to usemap_map[i] and mam_map[i] during allocation. Then
> in the last for_each_present_section_nr() loop which clears the failed
> memory section's ->section_mem_map, fetch usemap and memmap from
> usemap_map[] and map_map[] array and set them into mem_section[]
> accordingly.
> 
> Signed-off-by: Baoquan He <bhe@redhat.com>
> 
> Signed-off-by: Baoquan He <bhe@redhat.com>
> ---
>  mm/sparse-vmemmap.c |  8 +++++---
>  mm/sparse.c         | 40 ++++++++++++++++++++++++++--------------
>  2 files changed, 31 insertions(+), 17 deletions(-)
> 
> diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
> index 640e68f8324b..f83723a49e47 100644
> --- a/mm/sparse-vmemmap.c
> +++ b/mm/sparse-vmemmap.c
> @@ -281,6 +281,7 @@ void __init sparse_mem_maps_populate_node(struct page
> **map_map,
>  	unsigned long pnum;
>  	unsigned long size = sizeof(struct page) * PAGES_PER_SECTION;
>  	void *vmemmap_buf_start;
> +	int i = 0;
>  
>  	size = ALIGN(size, PMD_SIZE);
>  	vmemmap_buf_start = __earlyonly_bootmem_alloc(nodeid, size * map_count,
> @@ -291,14 +292,15 @@ void __init sparse_mem_maps_populate_node(struct page
> **map_map,
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
> -		map_map[pnum] = sparse_mem_map_populate(pnum, nodeid, NULL);
> -		if (map_map[pnum])
> +		i++;
> +		map_map[i-1] = sparse_mem_map_populate(pnum, nodeid, NULL);
> +		if (map_map[i-1])
>  			continue;
>  		ms = __nr_to_section(pnum);
>  		pr_err("%s: sparsemem memory map backing failed some memory will not be
>  		available\n",
> diff --git a/mm/sparse.c b/mm/sparse.c
> index e9311b44e28a..aafb6d838872 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -405,6 +405,7 @@ static void __init sparse_early_usemaps_alloc_node(void
> *data,
>  	unsigned long pnum;
>  	unsigned long **usemap_map = (unsigned long **)data;
>  	int size = usemap_size();
> +	int i = 0;
>  
>  	usemap = sparse_early_usemaps_alloc_pgdat_section(NODE_DATA(nodeid),
>  							  size * usemap_count);
> @@ -413,12 +414,13 @@ static void __init sparse_early_usemaps_alloc_node(void
> *data,
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
> @@ -447,14 +449,17 @@ void __init sparse_mem_maps_populate_node(struct page
> **map_map,
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
> +			i++;
>  		}
>  		return;
>  	}
> @@ -464,23 +469,27 @@ void __init sparse_mem_maps_populate_node(struct page
> **map_map,
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
> +			i++;
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
> -		map_map[pnum] = sparse_mem_map_populate(pnum, nodeid, NULL);
> -		if (map_map[pnum])
> +		i++;
> +		map_map[i-1] = sparse_mem_map_populate(pnum, nodeid, NULL);
> +		if (map_map[i-1])
>  			continue;

Below statement will look better?

                map_map[i] = sparse_mem_map_populate(pnum, nodeid, NULL);
                if (map_map[i++])
  			continue;


>  		ms = __nr_to_section(pnum);
>  		pr_err("%s: sparsemem memory map backing failed some memory will not be
>  		available\n",
> @@ -558,6 +567,7 @@ static void __init alloc_usemap_and_memmap(void
> (*alloc_func)
>  		/* new start, update count etc*/
>  		nodeid_begin = nodeid;
>  		pnum_begin = pnum;
> +		data += map_count;
>  		map_count = 1;
>  	}
>  	/* ok, last chunk */
> @@ -576,6 +586,7 @@ void __init sparse_init(void)
>  	unsigned long *usemap;
>  	unsigned long **usemap_map;
>  	int size;
> +	int i = 0;
>  #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
>  	int size2;
>  	struct page **map_map;
> @@ -598,7 +609,7 @@ void __init sparse_init(void)
>  	 * powerpc need to call sparse_init_one_section right after each
>  	 * sparse_early_mem_map_alloc, so allocate usemap_map at first.
>  	 */
> -	size = sizeof(unsigned long *) * NR_MEM_SECTIONS;
> +	size = sizeof(unsigned long *) * nr_present_sections;
>  	usemap_map = memblock_virt_alloc(size, 0);
>  	if (!usemap_map)
>  		panic("can not allocate usemap_map\n");
> @@ -606,7 +617,7 @@ void __init sparse_init(void)
>  							(void *)usemap_map);
>  
>  #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
> -	size2 = sizeof(struct page *) * NR_MEM_SECTIONS;
> +	size2 = sizeof(struct page *) * nr_present_sections;
>  	map_map = memblock_virt_alloc(size2, 0);
>  	if (!map_map)
>  		panic("can not allocate map_map\n");
> @@ -617,14 +628,15 @@ void __init sparse_init(void)
>  	for_each_present_section_nr(0, pnum) {
>  		struct mem_section *ms;
>  		ms = __nr_to_section(pnum);
> -		usemap = usemap_map[pnum];
> +		i++;
> +		usemap = usemap_map[i-1];

Can try same as above and other places where possible

>  		if (!usemap) {
>  			ms->section_mem_map = 0;
>  			continue;
>  		}
>  
>  #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
> -		map = map_map[pnum];
> +		map = map_map[i-1];
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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
