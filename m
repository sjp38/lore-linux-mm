Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 48E0C6B0007
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:55:38 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id t11-v6so7257198iog.15
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 08:55:38 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id y124-v6si1899087iof.225.2018.06.29.08.55.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 08:55:37 -0700 (PDT)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5TFrejd014266
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 15:55:36 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2jukmu75qe-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 15:55:36 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w5TFtZNY029526
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 15:55:35 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w5TFtYif024670
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 15:55:34 GMT
Received: by mail-ot0-f178.google.com with SMTP id l15-v6so10430719oth.6
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 08:55:34 -0700 (PDT)
MIME-Version: 1.0
References: <20180628173010.23849-1-pasha.tatashin@oracle.com>
 <20180628173010.23849-2-pasha.tatashin@oracle.com> <20180629143527.GA23545@techadventures.net>
In-Reply-To: <20180629143527.GA23545@techadventures.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 29 Jun 2018 11:54:57 -0400
Message-ID: <CAGM2reaW94eNnz20FoSnocoXFPUV1_fCbKwj6+Q5EzqCoKE8uQ@mail.gmail.com>
Subject: Re: [PATCH v1 1/2] mm/sparse: add sparse_init_nid()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, bhe@redhat.com, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org

On Fri, Jun 29, 2018 at 10:35 AM Oscar Salvador
<osalvador@techadventures.net> wrote:
>
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
> >                                  unsigned long pnum_end,
> >                                  unsigned long map_count,
> >                                  int nodeid);
> > +struct page * sparse_populate_node(unsigned long pnum_begin,
> > +                                unsigned long pnum_end,
> > +                                unsigned long map_count,
> > +                                int nid);
> > +struct page * sprase_populate_node_section(struct page *map_base,
> > +                                unsigned long map_index,
> > +                                unsigned long pnum,
> > +                                int nid);
> >
> >  struct page *sparse_mem_map_populate(unsigned long pnum, int nid,
> >               struct vmem_altmap *altmap);
> > diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
> > index e1a54ba411ec..4655503bdc66 100644
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
>
> Besides the typos, I could not find anything wrong in the patch.
> Only cosmetic:
>
> Could not the loop above be converted to a for_each_present_section_nr() or would it be
> less readable?

for_each_present_section_nr is defined in sparse.c, so I decided to
use what is used in other places in sparse-vmemmap.c

>
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
> > +struct page * __init sprase_populate_node_section(struct page *map_base,
> > +                                               unsigned long map_index,
> > +                                               unsigned long pnum,
> > +                                               int nid)
> > +{
> > +     return pfn_to_page(section_nr_to_pfn(pnum));
> > +}
> > diff --git a/mm/sparse.c b/mm/sparse.c
> > index d18e2697a781..60eaa2a4842a 100644
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
> > + * be allocating one section at a time in sprase_populate_node_section().
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
> > +struct page * __init sprase_populate_node_section(struct page *map_base,
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
> > @@ -520,6 +557,59 @@ static void __init alloc_usemap_and_memmap(void (*alloc_func)
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
> > +     struct mem_section *ms;
>
> What about moving "struct mem_section" into the second for_each_present_section_nr() loop.
> It is only being used there.
> And we could move "struct page *map" into the first loop as well.

Thank you for the review, I will move the declarations into loops.

>
> But the patch looks good to me anyway.
> Maybe I am missing something, but so far:
>
> Reviewed-by: Oscar Salvador <osalvador@suse.de>
>
> --
> Oscar Salvador
> SUSE L3
>
