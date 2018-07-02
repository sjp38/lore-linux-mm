Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F5E96B000D
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 21:44:02 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id n11-v6so12146552ioa.23
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 18:44:02 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 2-v6si9904038ioy.106.2018.07.01.18.44.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 18:44:01 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w621eJYU062592
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 01:44:00 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2jx2gptg5r-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 02 Jul 2018 01:44:00 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w621hxP9019492
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 01:43:59 GMT
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w621hwRW023369
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 01:43:58 GMT
Received: by mail-oi0-f50.google.com with SMTP id w126-v6so6171902oie.7
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 18:43:58 -0700 (PDT)
MIME-Version: 1.0
References: <20180630030944.9335-1-pasha.tatashin@oracle.com>
 <20180630030944.9335-2-pasha.tatashin@oracle.com> <20180702012933.GH3223@MiWiFi-R3L-srv>
In-Reply-To: <20180702012933.GH3223@MiWiFi-R3L-srv>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Sun, 1 Jul 2018 21:43:20 -0400
Message-ID: <CAGM2reYuyhRhmkmtxO1G933OwkC1=2t9pZqWops4gv-VBseQdQ@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] mm/sparse: add sparse_init_nid()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bhe@redhat.com
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

On Sun, Jul 1, 2018 at 9:29 PM Baoquan He <bhe@redhat.com> wrote:
>
> On 06/29/18 at 11:09pm, Pavel Tatashin wrote:
> > sparse_init() requires to temporary allocate two large buffers:
> > usemap_map and map_map. Baoquan He has identified that these buffers are so
> > large that Linux is not bootable on small memory machines, such as a kdump
> > boot.
>
> These two temporary buffers are large when CONFIG_X86_5LEVEL is enabled.
> Otherwise it's OK.

Thank you. I will add CONFIG_X86_5LEVEL to the commit log.

Pavel

>
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
> > Reviewed-by: Oscar Salvador <osalvador@suse.de>
> > ---
> >  include/linux/mm.h  |  8 ++++
> >  mm/sparse-vmemmap.c | 49 ++++++++++++++++++++++++
> >  mm/sparse.c         | 91 +++++++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 148 insertions(+)
> >
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index a0fbb9ffe380..85530fdfb1f2 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -2651,6 +2651,14 @@ void sparse_mem_maps_populate_node(struct page **map_map,
> >                                  unsigned long pnum_end,
> >                                  unsigned long map_count,
> >                                  int nodeid);
> > +struct page * sparse_populate_node(unsigned long pnum_begin,
> > +                                unsigned long pnum_end,
> > +                                unsigned long map_count,
> > +                                int nid);
> > +struct page * sparse_populate_node_section(struct page *map_base,
> > +                                unsigned long map_index,
> > +                                unsigned long pnum,
> > +                                int nid);
> >
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
> > +     unsigned long size = sizeof(struct page) * PAGES_PER_SECTION;
> > +     unsigned long pnum, map_index = 0;
> > +     void *vmemmap_buf_start;
> > +
> > +     size = ALIGN(size, PMD_SIZE) * map_count;
> > +     vmemmap_buf_start = __earlyonly_bootmem_alloc(nid, size,
> > +                                                   PMD_SIZE,
> > +                                                   __pa(MAX_DMA_ADDRESS));
> > +     if (vmemmap_buf_start) {
> > +             vmemmap_buf = vmemmap_buf_start;
> > +             vmemmap_buf_end = vmemmap_buf_start + size;
> > +     }
> > +
> > +     for (pnum = pnum_begin; map_index < map_count; pnum++) {
> > +             if (!present_section_nr(pnum))
> > +                     continue;
> > +             if (!sparse_mem_map_populate(pnum, nid, NULL))
> > +                     break;
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
> > +
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
> > +}
> >  #endif /* !CONFIG_SPARSEMEM_VMEMMAP */
> >
> >  static void __init sparse_early_mem_maps_alloc_node(void *data,
> > @@ -520,6 +557,60 @@ static void __init alloc_usemap_and_memmap(void (*alloc_func)
> >                                               map_count, nodeid_begin);
> >  }
> >
> > +/*
> > + * Initialize sparse on a specific node. The node spans [pnum_begin, pnum_end)
> > + * And number of present sections in this node is map_count.
> > + */
> > +void __init sparse_init_nid(int nid, unsigned long pnum_begin,
> > +                                unsigned long pnum_end,
> > +                                unsigned long map_count)
> > +{
> > +     unsigned long pnum, usemap_longs, *usemap, map_index;
> > +     struct page *map, *map_base;
> > +
> > +     usemap_longs = BITS_TO_LONGS(SECTION_BLOCKFLAGS_BITS);
> > +     usemap = sparse_early_usemaps_alloc_pgdat_section(NODE_DATA(nid),
> > +                                                       usemap_size() *
> > +                                                       map_count);
> > +     if (!usemap) {
> > +             pr_err("%s: usemap allocation failed", __func__);
> > +             goto failed;
> > +     }
> > +     map_base = sparse_populate_node(pnum_begin, pnum_end,
> > +                                     map_count, nid);
> > +     map_index = 0;
> > +     for_each_present_section_nr(pnum_begin, pnum) {
> > +             if (pnum >= pnum_end)
> > +                     break;
> > +
> > +             BUG_ON(map_index == map_count);
> > +             map = sparse_populate_node_section(map_base, map_index,
> > +                                                pnum, nid);
> > +             if (!map) {
> > +                     pr_err("%s: memory map backing failed. Some memory will not be available.",
> > +                            __func__);
> > +                     pnum_begin = pnum;
> > +                     goto failed;
>
> If one memmap is unavailable, do we need to jump to 'failed' to mark all
> sections of the node as not present? E.g the last section of one node
> failed to populate memmap?
>
>
> > +             }
> > +             check_usemap_section_nr(nid, usemap);
> > +             sparse_init_one_section(__nr_to_section(pnum), pnum, map,
> > +                                     usemap);
> > +             map_index++;
> > +             usemap += usemap_longs;
> > +     }
> > +     return;
> > +failed:
> > +     /* We failed to allocate, mark all the following pnums as not present */
> > +     for_each_present_section_nr(pnum_begin, pnum) {
> > +             struct mem_section *ms;
> > +
> > +             if (pnum >= pnum_end)
> > +                     break;
> > +             ms = __nr_to_section(pnum);
> > +             ms->section_mem_map = 0;
> > +     }
> > +}
> > +
> >  /*
> >   * Allocate the accumulated non-linear sections, allocate a mem_map
> >   * for each and record the physical to section mapping.
> > --
> > 2.18.0
> >
>
