Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E6E5C6B0005
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 06:45:00 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w21-v6so780890wmc.4
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 03:45:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y4-v6sor4462331wrp.59.2018.06.29.03.44.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Jun 2018 03:44:59 -0700 (PDT)
Date: Fri, 29 Jun 2018 12:44:57 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v1 1/2] mm/sparse: add sparse_init_nid()
Message-ID: <20180629104457.GA23043@techadventures.net>
References: <20180628173010.23849-1-pasha.tatashin@oracle.com>
 <20180628173010.23849-2-pasha.tatashin@oracle.com>
 <20180629100413.GA21540@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180629100413.GA21540@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org

On Fri, Jun 29, 2018 at 12:04:13PM +0200, Oscar Salvador wrote:
> On Thu, Jun 28, 2018 at 01:30:09PM -0400, Pavel Tatashin wrote:
> > sparse_init() requires to temporary allocate two large buffers:
> > usemap_map and map_map. Baoquan He has identified that these buffers are so
> > large that Linux is not bootable on small memory machines, such as a kdump
> > boot.
> > 
> > Baoquan provided a fix, which reduces these sizes of these buffers, but it
> > is much better to get rid of them entirely.
> > 
> > Add a new way to initialize sparse memory: sparse_init_nid(), which only
> > operates within one memory node, and thus allocates memory either in large
> > contiguous block or allocates section by section. This eliminates the need
> > for use of temporary buffers.
> > 
> > For simplified bisecting and review, the new interface is going to be
> > enabled as well as old code removed in the next patch.
> > 
> > Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> > ---
> >  include/linux/mm.h  |  8 ++++
> >  mm/sparse-vmemmap.c | 49 ++++++++++++++++++++++++
> >  mm/sparse.c         | 90 +++++++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 147 insertions(+)
> > 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index a0fbb9ffe380..ba200808dd5f 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -2651,6 +2651,14 @@ void sparse_mem_maps_populate_node(struct page **map_map,
> >  				   unsigned long pnum_end,
> >  				   unsigned long map_count,
> >  				   int nodeid);
> > +struct page * sparse_populate_node(unsigned long pnum_begin,
> > +				   unsigned long pnum_end,
> > +				   unsigned long map_count,
> > +				   int nid);
> > +struct page * sprase_populate_node_section(struct page *map_base,
> > +				   unsigned long map_index,
> > +				   unsigned long pnum,
> > +				   int nid);
> 
> s/sprase/sparse ?
> 
> >  
> >  struct page *sparse_mem_map_populate(unsigned long pnum, int nid,
> >  		struct vmem_altmap *altmap);
> > diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
> > index e1a54ba411ec..4655503bdc66 100644
> > --- a/mm/sparse-vmemmap.c
> > +++ b/mm/sparse-vmemmap.c
> > @@ -311,3 +311,52 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
> >  		vmemmap_buf_end = NULL;
> >  	}
> >  }
> > +
> > +struct page * __init sparse_populate_node(unsigned long pnum_begin,
> > +					  unsigned long pnum_end,
> > +					  unsigned long map_count,
> > +					  int nid)
> > +{
> > +	unsigned long size = sizeof(struct page) * PAGES_PER_SECTION;
> > +	unsigned long pnum, map_index = 0;
> > +	void *vmemmap_buf_start;
> > +
> > +	size = ALIGN(size, PMD_SIZE) * map_count;
> > +	vmemmap_buf_start = __earlyonly_bootmem_alloc(nid, size,
> > +						      PMD_SIZE,
> > +						      __pa(MAX_DMA_ADDRESS));
> > +	if (vmemmap_buf_start) {
> > +		vmemmap_buf = vmemmap_buf_start;
> > +		vmemmap_buf_end = vmemmap_buf_start + size;
> > +	}
> > +
> > +	for (pnum = pnum_begin; map_index < map_count; pnum++) {
> > +		if (!present_section_nr(pnum))
> > +			continue;
> > +		if (!sparse_mem_map_populate(pnum, nid, NULL))
> > +			break;
> > +		map_index++;
> > +		BUG_ON(pnum >= pnum_end);
> > +	}
> > +
> > +	if (vmemmap_buf_start) {
> > +		/* need to free left buf */
> > +		memblock_free_early(__pa(vmemmap_buf),
> > +				    vmemmap_buf_end - vmemmap_buf);
> > +		vmemmap_buf = NULL;
> > +		vmemmap_buf_end = NULL;
> > +	}
> > +	return pfn_to_page(section_nr_to_pfn(pnum_begin));
> > +}
> > +
> > +/*
> > + * Return map for pnum section. sparse_populate_node() has populated memory map
> > + * in this node, we simply do pnum to struct page conversion.
> > + */
> > +struct page * __init sprase_populate_node_section(struct page *map_base,
> > +						  unsigned long map_index,
> > +						  unsigned long pnum,
> > +						  int nid)
> > +{
> > +	return pfn_to_page(section_nr_to_pfn(pnum));
> > +}
> 
> s/sprase/sparse ?
> 
> > diff --git a/mm/sparse.c b/mm/sparse.c
> > index d18e2697a781..60eaa2a4842a 100644
> > --- a/mm/sparse.c
> > +++ b/mm/sparse.c
> > @@ -456,6 +456,43 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
> >  		       __func__);
> >  	}
> >  }
> > +
> > +static unsigned long section_map_size(void)
> > +{
> > +	return PAGE_ALIGN(sizeof(struct page) * PAGES_PER_SECTION);
> > +}
> > +
> > +/*
> > + * Try to allocate all struct pages for this node, if this fails, we will
> > + * be allocating one section at a time in sprase_populate_node_section().
> > + */
> > +struct page * __init sparse_populate_node(unsigned long pnum_begin,
> > +					  unsigned long pnum_end,
> > +					  unsigned long map_count,
> > +					  int nid)
> > +{
> > +	return memblock_virt_alloc_try_nid_raw(section_map_size() * map_count,
> > +					       PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
> > +					       BOOTMEM_ALLOC_ACCESSIBLE, nid);
> > +}
> > +
> > +/*
> > + * Return map for pnum section. map_base is not NULL if we could allocate map
> > + * for this node together. Otherwise we allocate one section at a time.
> > + * map_index is the index of pnum in this node counting only present sections.
> > + */
> > +struct page * __init sprase_populate_node_section(struct page *map_base,
> > +						  unsigned long map_index,
> > +						  unsigned long pnum,
> > +						  int nid)
> 
> s/sprase/sparse ?
> 
> > +{
> > +	if (map_base) {
> > +		unsigned long offset = section_map_size() * map_index;
> > +
> > +		return (struct page *)((char *)map_base + offset);
> > +	}
> > +	return sparse_mem_map_populate(pnum, nid, NULL);
> > +}
> >  #endif /* !CONFIG_SPARSEMEM_VMEMMAP */
> >  
> >  static void __init sparse_early_mem_maps_alloc_node(void *data,
> > @@ -520,6 +557,59 @@ static void __init alloc_usemap_and_memmap(void (*alloc_func)
> >  						map_count, nodeid_begin);
> >  }
> >  
> > +/*
> > + * Initialize sparse on a specific node. The node spans [pnum_begin, pnum_end)
> > + * And number of present sections in this node is map_count.
> > + */
> > +void __init sparse_init_nid(int nid, unsigned long pnum_begin,
> > +				   unsigned long pnum_end,
> > +				   unsigned long map_count)
> > +{
> > +	unsigned long pnum, usemap_longs, *usemap, map_index;
> > +	struct page *map, *map_base;
> > +	struct mem_section *ms;
> > +
> > +	usemap_longs = BITS_TO_LONGS(SECTION_BLOCKFLAGS_BITS);
> > +	usemap = sparse_early_usemaps_alloc_pgdat_section(NODE_DATA(nid),
> > +							  usemap_size() *
> > +							  map_count);
> > +	if (!usemap) {
> > +		pr_err("%s: usemap allocation failed", __func__);
> > +		goto failed;
> > +	}
> > +	map_base = sparse_populate_node(pnum_begin, pnum_end,
> > +					map_count, nid);
> > +	map_index = 0;
> > +	for_each_present_section_nr(pnum_begin, pnum) {
> > +		if (pnum >= pnum_end)
> > +			break;
> > +
> > +		BUG_ON(map_index == map_count);
> > +		map = sprase_populate_node_section(map_base, map_index,
> > +						   pnum, nid);
> 
> s/sprase/sparse ?
> 
> > +		if (!map) {
> > +			pr_err("%s: memory map backing failed. Some memory will not be available.",
> > +			       __func__);
> > +			pnum_begin = pnum;
> > +			goto failed;
> > +		}
> > +		check_usemap_section_nr(nid, usemap);
> > +		sparse_init_one_section(__nr_to_section(pnum), pnum, map,
> > +					usemap);
> > +		map_index++;
> > +		usemap += usemap_longs;
> 
> Hi Pavel,
> 
> uhm, maybe I am mistaken, but should not this be:
> 
> usemap += usemap_size(); ?
> 
> usermap_size() = 32 bytes
> while 
> usemap_longs = 4 bytes
> 
> AFAIK, each section->pageblock_flags holds 4 words, each word covers 16 pageblocks.
> So 16 * 4 = 64 pageblocks, and each pageblock is 512 pfns.
> So 64 * 512 = 32768 (PAGES_PER_SECTION).
> 
> Am I wrong?


Scratch that.
I forgot that incrementing the pointer will add up the right bytes.


-- 
Oscar Salvador
SUSE L3
