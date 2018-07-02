Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B50006B000D
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 16:00:07 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t5-v6so6771038pgt.18
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 13:00:07 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id 25-v6si2975675pgk.438.2018.07.02.13.00.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 13:00:06 -0700 (PDT)
Subject: Re: [PATCH v3 1/2] mm/sparse: add sparse_init_nid()
References: <20180702020417.21281-1-pasha.tatashin@oracle.com>
 <20180702020417.21281-2-pasha.tatashin@oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <ba037a25-eef0-c2b1-91f2-5db5588b2881@intel.com>
Date: Mon, 2 Jul 2018 12:59:41 -0700
MIME-Version: 1.0
In-Reply-To: <20180702020417.21281-2-pasha.tatashin@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

> @@ -2651,6 +2651,14 @@ void sparse_mem_maps_populate_node(struct page **map_map,
>  				   unsigned long pnum_end,
>  				   unsigned long map_count,
>  				   int nodeid);
> +struct page * sparse_populate_node(unsigned long pnum_begin,

CodingStyle: put the "*" next to the function name, no space, please.

> +				   unsigned long pnum_end,
> +				   unsigned long map_count,
> +				   int nid);
> +struct page * sparse_populate_node_section(struct page *map_base,
> +				   unsigned long map_index,
> +				   unsigned long pnum,
> +				   int nid);

These two functions are named in very similar ways.  Do they do similar
things?

>  struct page *sparse_mem_map_populate(unsigned long pnum, int nid,
>  		struct vmem_altmap *altmap);
> diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
> index e1a54ba411ec..b3e325962306 100644
> --- a/mm/sparse-vmemmap.c
> +++ b/mm/sparse-vmemmap.c
> @@ -311,3 +311,52 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
>  		vmemmap_buf_end = NULL;
>  	}
>  }
> +
> +struct page * __init sparse_populate_node(unsigned long pnum_begin,
> +					  unsigned long pnum_end,
> +					  unsigned long map_count,
> +					  int nid)
> +{

Could you comment what the function is doing, please?

> +	unsigned long size = sizeof(struct page) * PAGES_PER_SECTION;
> +	unsigned long pnum, map_index = 0;
> +	void *vmemmap_buf_start;
> +
> +	size = ALIGN(size, PMD_SIZE) * map_count;
> +	vmemmap_buf_start = __earlyonly_bootmem_alloc(nid, size,
> +						      PMD_SIZE,
> +						      __pa(MAX_DMA_ADDRESS));

Let's not repeat the mistakes of the previous version of the code.
Please explain why we are aligning this.  Also,
__earlyonly_bootmem_alloc()->memblock_virt_alloc_try_nid_raw() claims to
be aligning the size.  Do we also need to do it here?

Yes, I know the old code did this, but this is the cost of doing a
rewrite. :)

> +	if (vmemmap_buf_start) {
> +		vmemmap_buf = vmemmap_buf_start;
> +		vmemmap_buf_end = vmemmap_buf_start + size;
> +	}

It would be nice to call out that these are globals that other code
picks up.

> +	for (pnum = pnum_begin; map_index < map_count; pnum++) {
> +		if (!present_section_nr(pnum))
> +			continue;
> +		if (!sparse_mem_map_populate(pnum, nid, NULL))
> +			break;

^ This consumes "vmemmap_buf", right?  That seems like a really nice
thing to point out here if so.

> +		map_index++;
> +		BUG_ON(pnum >= pnum_end);
> +	}
> +
> +	if (vmemmap_buf_start) {
> +		/* need to free left buf */
> +		memblock_free_early(__pa(vmemmap_buf),
> +				    vmemmap_buf_end - vmemmap_buf);
> +		vmemmap_buf = NULL;
> +		vmemmap_buf_end = NULL;
> +	}
> +	return pfn_to_page(section_nr_to_pfn(pnum_begin));
> +}
> +
> +/*
> + * Return map for pnum section. sparse_populate_node() has populated memory map
> + * in this node, we simply do pnum to struct page conversion.
> + */
> +struct page * __init sparse_populate_node_section(struct page *map_base,
> +						  unsigned long map_index,
> +						  unsigned long pnum,
> +						  int nid)
> +{
> +	return pfn_to_page(section_nr_to_pfn(pnum));
> +}

What is up with all of the unused arguments to this function?

> diff --git a/mm/sparse.c b/mm/sparse.c
> index d18e2697a781..c18d92b8ab9b 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -456,6 +456,43 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
>  		       __func__);
>  	}
>  }
> +
> +static unsigned long section_map_size(void)
> +{
> +	return PAGE_ALIGN(sizeof(struct page) * PAGES_PER_SECTION);
> +}

Seems like if we have this, we should use it wherever possible, like
sparse_populate_node().


> +/*
> + * Try to allocate all struct pages for this node, if this fails, we will
> + * be allocating one section at a time in sparse_populate_node_section().
> + */
> +struct page * __init sparse_populate_node(unsigned long pnum_begin,
> +					  unsigned long pnum_end,
> +					  unsigned long map_count,
> +					  int nid)
> +{
> +	return memblock_virt_alloc_try_nid_raw(section_map_size() * map_count,
> +					       PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
> +					       BOOTMEM_ALLOC_ACCESSIBLE, nid);
> +}
> +
> +/*
> + * Return map for pnum section. map_base is not NULL if we could allocate map
> + * for this node together. Otherwise we allocate one section at a time.
> + * map_index is the index of pnum in this node counting only present sections.
> + */
> +struct page * __init sparse_populate_node_section(struct page *map_base,
> +						  unsigned long map_index,
> +						  unsigned long pnum,
> +						  int nid)
> +{
> +	if (map_base) {
> +		unsigned long offset = section_map_size() * map_index;
> +
> +		return (struct page *)((char *)map_base + offset);
> +	}
> +	return sparse_mem_map_populate(pnum, nid, NULL);

Oh, you have a vmemmap and non-vmemmap version.

BTW, can't the whole map base calculation just be replaced with:

	return &map_base[PAGES_PER_SECTION * map_index];

?
