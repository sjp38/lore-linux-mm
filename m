Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7F27A6B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 07:43:26 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id w16so13111026plp.20
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 04:43:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b89-v6si2786795plb.809.2018.02.15.04.43.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Feb 2018 04:43:25 -0800 (PST)
Date: Thu, 15 Feb 2018 13:43:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 4/4] mm/memory_hotplug: optimize memory hotplug
Message-ID: <20180215124320.GE7275@dhcp22.suse.cz>
References: <20180213193159.14606-1-pasha.tatashin@oracle.com>
 <20180213193159.14606-5-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180213193159.14606-5-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, vbabka@suse.cz, bharata@linux.vnet.ibm.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

On Tue 13-02-18 14:31:59, Pavel Tatashin wrote:
[...]
> @@ -201,21 +202,24 @@ static bool pages_correctly_reserved(unsigned long start_pfn)
>  	 * SPARSEMEM_VMEMMAP. We lookup the page once per section
>  	 * and assume memmap is contiguous within each section
>  	 */
> -	for (i = 0; i < sections_per_block; i++, pfn += PAGES_PER_SECTION) {
> +	for (; section_nr < section_nr_end; section_nr++) {
>  		if (WARN_ON_ONCE(!pfn_valid(pfn)))
>  			return false;
> -		page = pfn_to_page(pfn);
> -
> -		for (j = 0; j < PAGES_PER_SECTION; j++) {
> -			if (PageReserved(page + j))
> -				continue;
> -
> -			printk(KERN_WARNING "section number %ld page number %d "
> -				"not reserved, was it already online?\n",
> -				pfn_to_section_nr(pfn), j);
>  
> +		if (!present_section_nr(section_nr)) {
> +			pr_warn("section %ld pfn[%lx, %lx) not present",
> +				section_nr, pfn, pfn + PAGES_PER_SECTION);
> +			return false;
> +		} else if (!valid_section_nr(section_nr)) {
> +			pr_warn("section %ld pfn[%lx, %lx) no valid memmap",
> +				section_nr, pfn, pfn + PAGES_PER_SECTION);
> +			return false;
> +		} else if (online_section_nr(section_nr)) {
> +			pr_warn("section %ld pfn[%lx, %lx) is already online",
> +				section_nr, pfn, pfn + PAGES_PER_SECTION);
>  			return false;
>  		}
> +		pfn += PAGES_PER_SECTION;
>  	}

This should be a separate patch IMHO. It is an optimization on its
own. The original code tries to be sparse neutral but we do depend on
sparse anyway.

[...]
>  /* register memory section under specified node if it spans that node */
> -int register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
> +int register_mem_sect_under_node(struct memory_block *mem_blk, int nid,
> +				 bool check_nid)

This check_nid begs for a documentation. When do we need to set it? I
can see that register_new_memory path doesn't check node id. It is quite
reasonable to expect that a new memblock doesn't span multiple numa
nodes which can be the case for register_one_node but a word or two are
really due.

>  {
>  	int ret;
>  	unsigned long pfn, sect_start_pfn, sect_end_pfn;
> @@ -423,11 +424,13 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
>  			continue;
>  		}
>  
> -		page_nid = get_nid_for_pfn(pfn);
> -		if (page_nid < 0)
> -			continue;
> -		if (page_nid != nid)
> -			continue;
> +		if (check_nid) {
> +			page_nid = get_nid_for_pfn(pfn);
> +			if (page_nid < 0)
> +				continue;
> +			if (page_nid != nid)
> +				continue;
> +		}
>  		ret = sysfs_create_link_nowarn(&node_devices[nid]->dev.kobj,
>  					&mem_blk->dev.kobj,
>  					kobject_name(&mem_blk->dev.kobj));
> @@ -502,7 +505,7 @@ int link_mem_sections(int nid, unsigned long start_pfn, unsigned long nr_pages)
>  
>  		mem_blk = find_memory_block_hinted(mem_sect, mem_blk);
>  
> -		ret = register_mem_sect_under_node(mem_blk, nid);
> +		ret = register_mem_sect_under_node(mem_blk, nid, true);
>  		if (!err)
>  			err = ret;
>  

I would be tempted to split this into a separate patch as well. The
review will be much easier.

[...]
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 7af5e7a92528..d7808307023b 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -30,11 +30,14 @@ struct mem_section mem_section[NR_SECTION_ROOTS][SECTIONS_PER_ROOT]
>  #endif
>  EXPORT_SYMBOL(mem_section);
>  
> -#ifdef NODE_NOT_IN_PAGE_FLAGS
> +#if defined(NODE_NOT_IN_PAGE_FLAGS) || defined(CONFIG_MEMORY_HOTPLUG)
>  /*
>   * If we did not store the node number in the page then we have to
>   * do a lookup in the section_to_node_table in order to find which
>   * node the page belongs to.
> + *
> + * We also use this data in case memory hotplugging is enabled to be
> + * able to determine nid while struct pages are not yet initialized.
>   */
>  #if MAX_NUMNODES <= 256
>  static u8 section_to_node_table[NR_MEM_SECTIONS] __cacheline_aligned;
> @@ -42,17 +45,28 @@ static u8 section_to_node_table[NR_MEM_SECTIONS] __cacheline_aligned;
>  static u16 section_to_node_table[NR_MEM_SECTIONS] __cacheline_aligned;
>  #endif
>  
> +#ifdef NODE_NOT_IN_PAGE_FLAGS
>  int page_to_nid(const struct page *page)
>  {
>  	return section_to_node_table[page_to_section(page)];
>  }
>  EXPORT_SYMBOL(page_to_nid);
> +#endif /* NODE_NOT_IN_PAGE_FLAGS */

This is quite ugly. You allocate 256MB for small numa systems and 512MB
for larger NUMAs unconditionally for MEMORY_HOTPLUG. I see you need it
to safely replace page_to_nid by get_section_nid but this is just too
high of the price. Please note that this shouldn't be really needed. At
least not for onlining. We already _do_ know the node association with
the pfn range. So we should be able to get the nid from memblock.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
