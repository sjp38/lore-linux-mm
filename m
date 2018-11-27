Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A2FF06B4629
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 01:25:17 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c18so10037410edt.23
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 22:25:17 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d13si1402867edl.8.2018.11.26.22.25.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 22:25:15 -0800 (PST)
Date: Tue, 27 Nov 2018 07:25:14 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, sparse: drop pgdat_resize_lock in
 sparse_add/remove_one_section()
Message-ID: <20181127062514.GJ12455@dhcp22.suse.cz>
References: <20181127023630.9066-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181127023630.9066-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>

[Cc Dave who has added the lock into this path. Maybe he remembers why]

On Tue 27-11-18 10:36:30, Wei Yang wrote:
> pgdat_resize_lock is used to protect pgdat's memory region information
> like: node_start_pfn, node_present_pages, etc.
> 
> In function sparse_add/remove_one_section(), those data is not touched.
> This means it is not necessary to acquire pgdat_resize_lock to protect
> this area.
> 
> Since the information needed in sparse_add_one_section() is node id to
> allocate proper memory. This patch also changes the prototype of
> sparse_add_one_section() to pass node id directly. This is intended to
> reduce misleading that sparse_add_one_section() would touch pgdat.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  include/linux/memory_hotplug.h |  2 +-
>  mm/memory_hotplug.c            |  2 +-
>  mm/sparse.c                    | 17 +++++------------
>  3 files changed, 7 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 45a5affcab8a..3787d4e913e6 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -333,7 +333,7 @@ extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
>  		unsigned long nr_pages, struct vmem_altmap *altmap);
>  extern int offline_pages(unsigned long start_pfn, unsigned long nr_pages);
>  extern bool is_memblock_offlined(struct memory_block *mem);
> -extern int sparse_add_one_section(struct pglist_data *pgdat,
> +extern int sparse_add_one_section(int nid,
>  		unsigned long start_pfn, struct vmem_altmap *altmap);
>  extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
>  		unsigned long map_offset, struct vmem_altmap *altmap);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index f626e7e5f57b..5b3a3d7b4466 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -253,7 +253,7 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
>  	if (pfn_valid(phys_start_pfn))
>  		return -EEXIST;
>  
> -	ret = sparse_add_one_section(NODE_DATA(nid), phys_start_pfn, altmap);
> +	ret = sparse_add_one_section(nid, phys_start_pfn, altmap);
>  	if (ret < 0)
>  		return ret;
>  
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 33307fc05c4d..a4fdbcb21514 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -662,25 +662,24 @@ static void free_map_bootmem(struct page *memmap)
>   * set.  If this is <=0, then that means that the passed-in
>   * map was not consumed and must be freed.
>   */
> -int __meminit sparse_add_one_section(struct pglist_data *pgdat,
> -		unsigned long start_pfn, struct vmem_altmap *altmap)
> +int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
> +				     struct vmem_altmap *altmap)
>  {
>  	unsigned long section_nr = pfn_to_section_nr(start_pfn);
>  	struct mem_section *ms;
>  	struct page *memmap;
>  	unsigned long *usemap;
> -	unsigned long flags;
>  	int ret;
>  
>  	/*
>  	 * no locking for this, because it does its own
>  	 * plus, it does a kmalloc
>  	 */
> -	ret = sparse_index_init(section_nr, pgdat->node_id);
> +	ret = sparse_index_init(section_nr, nid);
>  	if (ret < 0 && ret != -EEXIST)
>  		return ret;
>  	ret = 0;
> -	memmap = kmalloc_section_memmap(section_nr, pgdat->node_id, altmap);
> +	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
>  	if (!memmap)
>  		return -ENOMEM;
>  	usemap = __kmalloc_section_usemap();
> @@ -689,8 +688,6 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
>  		return -ENOMEM;
>  	}
>  
> -	pgdat_resize_lock(pgdat, &flags);
> -
>  	ms = __pfn_to_section(start_pfn);
>  	if (ms->section_mem_map & SECTION_MARKED_PRESENT) {
>  		ret = -EEXIST;
> @@ -707,7 +704,6 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
>  	sparse_init_one_section(ms, section_nr, memmap, usemap);
>  
>  out:
> -	pgdat_resize_unlock(pgdat, &flags);
>  	if (ret < 0) {
>  		kfree(usemap);
>  		__kfree_section_memmap(memmap, altmap);
> @@ -769,10 +765,8 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
>  		unsigned long map_offset, struct vmem_altmap *altmap)
>  {
>  	struct page *memmap = NULL;
> -	unsigned long *usemap = NULL, flags;
> -	struct pglist_data *pgdat = zone->zone_pgdat;
> +	unsigned long *usemap = NULL;
>  
> -	pgdat_resize_lock(pgdat, &flags);
>  	if (ms->section_mem_map) {
>  		usemap = ms->pageblock_flags;
>  		memmap = sparse_decode_mem_map(ms->section_mem_map,
> @@ -780,7 +774,6 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
>  		ms->section_mem_map = 0;
>  		ms->pageblock_flags = NULL;
>  	}
> -	pgdat_resize_unlock(pgdat, &flags);
>  
>  	clear_hwpoisoned_pages(memmap + map_offset,
>  			PAGES_PER_SECTION - map_offset);
> -- 
> 2.15.1
> 

-- 
Michal Hocko
SUSE Labs
