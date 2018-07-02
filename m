Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id DC3746B0271
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 16:30:02 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id z8-v6so31074itc.9
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 13:30:02 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id e81-v6si7427762jad.94.2018.07.02.13.30.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 13:30:01 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w62KSaRU084650
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 20:30:00 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2jx2gpwwcc-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 02 Jul 2018 20:30:00 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w62KTxha030147
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 20:29:59 GMT
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w62KTwwA006411
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 20:29:59 GMT
Received: by mail-oi0-f45.google.com with SMTP id k81-v6so18830881oib.4
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 13:29:58 -0700 (PDT)
MIME-Version: 1.0
References: <20180702020417.21281-1-pasha.tatashin@oracle.com>
 <20180702020417.21281-2-pasha.tatashin@oracle.com> <ba037a25-eef0-c2b1-91f2-5db5588b2881@intel.com>
In-Reply-To: <ba037a25-eef0-c2b1-91f2-5db5588b2881@intel.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 2 Jul 2018 16:29:21 -0400
Message-ID: <CAGM2reaOpSA6VjuYfMWyNqq4MrsCYdmwX7Crw_vRsBwPNHU+aA@mail.gmail.com>
Subject: Re: [PATCH v3 1/2] mm/sparse: add sparse_init_nid()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, bhe@redhat.com, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

On Mon, Jul 2, 2018 at 4:00 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> > @@ -2651,6 +2651,14 @@ void sparse_mem_maps_populate_node(struct page **map_map,
> >                                  unsigned long pnum_end,
> >                                  unsigned long map_count,
> >                                  int nodeid);
> > +struct page * sparse_populate_node(unsigned long pnum_begin,
>
> CodingStyle: put the "*" next to the function name, no space, please.

OK

>
> > +                                unsigned long pnum_end,
> > +                                unsigned long map_count,
> > +                                int nid);
> > +struct page * sparse_populate_node_section(struct page *map_base,
> > +                                unsigned long map_index,
> > +                                unsigned long pnum,
> > +                                int nid);
>
> These two functions are named in very similar ways.  Do they do similar
> things?

Yes, they do in non-vmemmap:

sparse_populate_node() -> populates the whole node if we can using a
single allocation
sparse_populate_node_section() -> populate only one section in the
given node if the whole node is not already populated.

However, vemmap variant is a little different: sparse_populate_node()
populates in a single allocation if can, and if not it still populates
the whole node but in smaller chunks, so
sparse_populate_node_section()  has nothing left to do.

>
> >  struct page *sparse_mem_map_populate(unsigned long pnum, int nid,
> >               struct vmem_altmap *altmap);
> > diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
> > index e1a54ba411ec..b3e325962306 100644
> > --- a/mm/sparse-vmemmap.c
> > +++ b/mm/sparse-vmemmap.c
> > @@ -311,3 +311,52 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
> >               vmemmap_buf_end = NULL;
> >       }
> >  }
> > +
> > +struct page * __init sparse_populate_node(unsigned long pnum_begin,
> > +                                       unsigned long pnum_end,
> > +                                       unsigned long map_count,
> > +                                       int nid)
> > +{
>
> Could you comment what the function is doing, please?

Sure, I will add comments.

>
> > +     unsigned long size = sizeof(struct page) * PAGES_PER_SECTION;
> > +     unsigned long pnum, map_index = 0;
> > +     void *vmemmap_buf_start;
> > +
> > +     size = ALIGN(size, PMD_SIZE) * map_count;
> > +     vmemmap_buf_start = __earlyonly_bootmem_alloc(nid, size,
> > +                                                   PMD_SIZE,
> > +                                                   __pa(MAX_DMA_ADDRESS));
>
> Let's not repeat the mistakes of the previous version of the code.
> Please explain why we are aligning this.  Also,
> __earlyonly_bootmem_alloc()->memblock_virt_alloc_try_nid_raw() claims to
> be aligning the size.  Do we also need to do it here?
>
> Yes, I know the old code did this, but this is the cost of doing a
> rewrite. :)

Actually, I was thinking about this particular case when I was
rewriting this code. Here we align size before multiplying by
map_count aligns after memblock_virt_alloc_try_nid_raw(). So, we must
have both as they are different.

>
> > +     if (vmemmap_buf_start) {
> > +             vmemmap_buf = vmemmap_buf_start;
> > +             vmemmap_buf_end = vmemmap_buf_start + size;
> > +     }
>
> It would be nice to call out that these are globals that other code
> picks up.

I do not like these globals, they should have specific functions that
access them only, something:
static struct {
  buffer;
  buffer_end;
} vmemmap_buffer;
vmemmap_buffer_init() allocate buffer
vmemmap_buffer_alloc()  return NULL if buffer is empty
vmemmap_buffer_fini()

Call vmemmap_buffer_init()  and vmemmap_buffer_fini()  from
sparse_populate_node() and
vmemmap_buffer_alloc() from vmemmap_alloc_block_buf().

But, it should be a separate patch. If you would like I can add it to
this series, or submit separately.

>
> > +     for (pnum = pnum_begin; map_index < map_count; pnum++) {
> > +             if (!present_section_nr(pnum))
> > +                     continue;
> > +             if (!sparse_mem_map_populate(pnum, nid, NULL))
> > +                     break;
>
> ^ This consumes "vmemmap_buf", right?  That seems like a really nice
> thing to point out here if so.

It consumes vmemmap_buf if __earlyonly_bootmem_alloc() was successful,
otherwise it allocates struct pages a section at a time.

>
> > +             map_index++;
> > +             BUG_ON(pnum >= pnum_end);
> > +     }
> > +
> > +     if (vmemmap_buf_start) {
> > +             /* need to free left buf */
> > +             memblock_free_early(__pa(vmemmap_buf),
> > +                                 vmemmap_buf_end - vmemmap_buf);
> > +             vmemmap_buf = NULL;
> > +             vmemmap_buf_end = NULL;
> > +     }
> > +     return pfn_to_page(section_nr_to_pfn(pnum_begin));
> > +}
> > +
> > +/*
> > + * Return map for pnum section. sparse_populate_node() has populated memory map
> > + * in this node, we simply do pnum to struct page conversion.
> > + */
> > +struct page * __init sparse_populate_node_section(struct page *map_base,
> > +                                               unsigned long map_index,
> > +                                               unsigned long pnum,
> > +                                               int nid)
> > +{
> > +     return pfn_to_page(section_nr_to_pfn(pnum));
> > +}
>
> What is up with all of the unused arguments to this function?

Because the same function is called from non-vmemmap sparse code.

>
> > diff --git a/mm/sparse.c b/mm/sparse.c
> > index d18e2697a781..c18d92b8ab9b 100644
> > --- a/mm/sparse.c
> > +++ b/mm/sparse.c
> > @@ -456,6 +456,43 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
> >                      __func__);
> >       }
> >  }
> > +
> > +static unsigned long section_map_size(void)
> > +{
> > +     return PAGE_ALIGN(sizeof(struct page) * PAGES_PER_SECTION);
> > +}
>
> Seems like if we have this, we should use it wherever possible, like
> sparse_populate_node().

It is used in sparse_populate_node():

401 struct page * __init sparse_populate_node(unsigned long pnum_begin,
406         return memblock_virt_alloc_try_nid_raw(section_map_size()
* map_count,
407                                                PAGE_SIZE,
__pa(MAX_DMA_ADDRESS),
408
BOOTMEM_ALLOC_ACCESSIBLE, nid);


>
>
> > +/*
> > + * Try to allocate all struct pages for this node, if this fails, we will
> > + * be allocating one section at a time in sparse_populate_node_section().
> > + */
> > +struct page * __init sparse_populate_node(unsigned long pnum_begin,
> > +                                       unsigned long pnum_end,
> > +                                       unsigned long map_count,
> > +                                       int nid)
> > +{
> > +     return memblock_virt_alloc_try_nid_raw(section_map_size() * map_count,
> > +                                            PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
> > +                                            BOOTMEM_ALLOC_ACCESSIBLE, nid);
> > +}
> > +
> > +/*
> > + * Return map for pnum section. map_base is not NULL if we could allocate map
> > + * for this node together. Otherwise we allocate one section at a time.
> > + * map_index is the index of pnum in this node counting only present sections.
> > + */
> > +struct page * __init sparse_populate_node_section(struct page *map_base,
> > +                                               unsigned long map_index,
> > +                                               unsigned long pnum,
> > +                                               int nid)
> > +{
> > +     if (map_base) {
> > +             unsigned long offset = section_map_size() * map_index;
> > +
> > +             return (struct page *)((char *)map_base + offset);
> > +     }
> > +     return sparse_mem_map_populate(pnum, nid, NULL);
>
> Oh, you have a vmemmap and non-vmemmap version.
>
> BTW, can't the whole map base calculation just be replaced with:
>
>         return &map_base[PAGES_PER_SECTION * map_index];

Unfortunately no.  Because map_base might be allocated in chunks
larger than PAGES_PER_SECTION * sizeof(struct page). See: PAGE_ALIGN()
in section_map_size

Thank you,
Pavel
