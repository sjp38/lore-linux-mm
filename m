Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 39B8D6B0008
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 21:39:25 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id h67-v6so5336943qke.18
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 18:39:25 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id w3-v6si2508185qto.309.2018.07.01.18.39.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 18:39:24 -0700 (PDT)
Date: Mon, 2 Jul 2018 09:39:18 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH v2 2/2] mm/sparse: start using sparse_init_nid(), and
 remove old code
Message-ID: <20180702013918.GJ3223@MiWiFi-R3L-srv>
References: <20180630030944.9335-1-pasha.tatashin@oracle.com>
 <20180630030944.9335-3-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180630030944.9335-3-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

On 06/29/18 at 11:09pm, Pavel Tatashin wrote:
> Change sprase_init() to only find the pnum ranges that belong to a specific
> node and call sprase_init_nid() for that range from sparse_init().
> 
> Delete all the code that became obsolete with this change.
>  void __init sparse_init(void)
>  {
> -	unsigned long pnum;
> -	struct page *map;
> -	struct page **map_map;
> -	unsigned long *usemap;
> -	unsigned long **usemap_map;
> -	int size, size2;
> -	int nr_consumed_maps = 0;
> -
> -	/* see include/linux/mmzone.h 'struct mem_section' definition */
> -	BUILD_BUG_ON(!is_power_of_2(sizeof(struct mem_section)));
> +	unsigned long pnum_begin = first_present_section_nr();
> +	int nid_begin = sparse_early_nid(__nr_to_section(pnum_begin));
> +	unsigned long pnum_end, map_count = 1;
>  
> -	/* Setup pageblock_order for HUGETLB_PAGE_SIZE_VARIABLE */
> -	set_pageblock_order();
> +	for_each_present_section_nr(pnum_begin + 1, pnum_end) {
> +		int nid = sparse_early_nid(__nr_to_section(pnum_end));
>  
> -	/*
> -	 * map is using big page (aka 2M in x86 64 bit)
> -	 * usemap is less one page (aka 24 bytes)
> -	 * so alloc 2M (with 2M align) and 24 bytes in turn will
> -	 * make next 2M slip to one more 2M later.
> -	 * then in big system, the memory will have a lot of holes...
> -	 * here try to allocate 2M pages continuously.
> -	 *
> -	 * powerpc need to call sparse_init_one_section right after each
> -	 * sparse_early_mem_map_alloc, so allocate usemap_map at first.
> -	 */
> -	size = sizeof(unsigned long *) * nr_present_sections;
> -	usemap_map = memblock_virt_alloc(size, 0);
> -	if (!usemap_map)
> -		panic("can not allocate usemap_map\n");
> -	alloc_usemap_and_memmap(sparse_early_usemaps_alloc_node,
> -				(void *)usemap_map,
> -				sizeof(usemap_map[0]));
> -
> -	size2 = sizeof(struct page *) * nr_present_sections;
> -	map_map = memblock_virt_alloc(size2, 0);
> -	if (!map_map)
> -		panic("can not allocate map_map\n");
> -	alloc_usemap_and_memmap(sparse_early_mem_maps_alloc_node,
> -				(void *)map_map,
> -				sizeof(map_map[0]));
> -
> -	/* The numner of present sections stored in nr_present_sections
> -	 * are kept the same since mem sections are marked as present in
> -	 * memory_present(). In this for loop, we need check which sections
> -	 * failed to allocate memmap or usemap, then clear its
> -	 * ->section_mem_map accordingly. During this process, we need
> -	 * increase 'nr_consumed_maps' whether its allocation of memmap
> -	 * or usemap failed or not, so that after we handle the i-th
> -	 * memory section, can get memmap and usemap of (i+1)-th section
> -	 * correctly. */
> -	for_each_present_section_nr(0, pnum) {
> -		struct mem_section *ms;
> -
> -		if (nr_consumed_maps >= nr_present_sections) {
> -			pr_err("nr_consumed_maps goes beyond nr_present_sections\n");
> -			break;
> -		}
> -		ms = __nr_to_section(pnum);
> -		usemap = usemap_map[nr_consumed_maps];
> -		if (!usemap) {
> -			ms->section_mem_map = 0;
> -			nr_consumed_maps++;
> -			continue;
> -		}
> -
> -		map = map_map[nr_consumed_maps];
> -		if (!map) {
> -			ms->section_mem_map = 0;
> -			nr_consumed_maps++;
> +		if (nid == nid_begin) {
> +			map_count++;
>  			continue;
>  		}
> -
> -		sparse_init_one_section(__nr_to_section(pnum), pnum, map,
> -								usemap);
> -		nr_consumed_maps++;
> +		sparse_init_nid(nid, pnum_begin, pnum_end, map_count);
				~~~
Here, node id passed to sparse_init_nid() should be 'nid_begin', but not
'nid'. When you found out the current section's 'nid' is diferent than
'nid_begin', handle node 'nid_begin', then start to next node 'nid'.


> +		nid_begin = nid;
> +		pnum_begin = pnum_end;
> +		map_count = 1;
>  	}
> -
> +	sparse_init_nid(nid_begin, pnum_begin, pnum_end, map_count);
>  	vmemmap_populate_print_last();
> -
> -	memblock_free_early(__pa(map_map), size2);
> -	memblock_free_early(__pa(usemap_map), size);
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
> -- 
> 2.18.0
> 
