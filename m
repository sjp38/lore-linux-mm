Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id EDF7E6B0003
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 02:57:27 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id z10-v6so4772235qki.5
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 23:57:27 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id v50-v6si5887842qtc.125.2018.06.27.23.57.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 23:57:26 -0700 (PDT)
Date: Thu, 28 Jun 2018 14:57:22 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH v5 3/4] mm/sparse: Add a new parameter 'data_unit_size'
 for alloc_usemap_and_memmap
Message-ID: <20180628065722.GB32539@MiWiFi-R3L-srv>
References: <20180627013116.12411-1-bhe@redhat.com>
 <20180627013116.12411-4-bhe@redhat.com>
 <CAGM2reb=2fmgJQzfPGJ_bCG-317-dsFfoG8vSr9LuYit4AVsyQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reb=2fmgJQzfPGJ_bCG-317-dsFfoG8vSr9LuYit4AVsyQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com, pagupta@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com

On 06/27/18 at 11:14pm, Pavel Tatashin wrote:
> Honestly, I do not like this new agrument, but it will do for now. I
> could not think of a better way without rewriting everything.
> 
> Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> 
> However, I will submit a series of patches to cleanup sparse.c and
> completely remove large and confusing temporary buffers: map_map, and
> usemap_map. In those patches, I will remove alloc_usemap_and_memmap().

Great, look forward to seeing them, I can help review.

> On Tue, Jun 26, 2018 at 9:31 PM Baoquan He <bhe@redhat.com> wrote:
> >
> > alloc_usemap_and_memmap() is passing in a "void *" that points to
> > usemap_map or memmap_map. In next patch we will change both of the
> > map allocation from taking 'NR_MEM_SECTIONS' as the length to taking
> > 'nr_present_sections' as the length. After that, the passed in 'void*'
> > needs to update as things get consumed. But, it knows only the
> > quantity of objects consumed and not the type.  This effectively
> > tells it enough about the type to let it update the pointer as
> > objects are consumed.
> >
> > Signed-off-by: Baoquan He <bhe@redhat.com>
> > ---
> >  mm/sparse.c | 10 +++++++---
> >  1 file changed, 7 insertions(+), 3 deletions(-)
> >
> > diff --git a/mm/sparse.c b/mm/sparse.c
> > index 71ad53da2cd1..b2848cc6e32a 100644
> > --- a/mm/sparse.c
> > +++ b/mm/sparse.c
> > @@ -489,10 +489,12 @@ void __weak __meminit vmemmap_populate_print_last(void)
> >  /**
> >   *  alloc_usemap_and_memmap - memory alloction for pageblock flags and vmemmap
> >   *  @map: usemap_map for pageblock flags or mmap_map for vmemmap
> > + *  @unit_size: size of map unit
> >   */
> >  static void __init alloc_usemap_and_memmap(void (*alloc_func)
> >                                         (void *, unsigned long, unsigned long,
> > -                                       unsigned long, int), void *data)
> > +                                       unsigned long, int), void *data,
> > +                                       int data_unit_size)
> >  {
> >         unsigned long pnum;
> >         unsigned long map_count;
> > @@ -569,7 +571,8 @@ void __init sparse_init(void)
> >         if (!usemap_map)
> >                 panic("can not allocate usemap_map\n");
> >         alloc_usemap_and_memmap(sparse_early_usemaps_alloc_node,
> > -                                                       (void *)usemap_map);
> > +                               (void *)usemap_map,
> > +                               sizeof(usemap_map[0]));
> >
> >  #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
> >         size2 = sizeof(struct page *) * NR_MEM_SECTIONS;
> > @@ -577,7 +580,8 @@ void __init sparse_init(void)
> >         if (!map_map)
> >                 panic("can not allocate map_map\n");
> >         alloc_usemap_and_memmap(sparse_early_mem_maps_alloc_node,
> > -                                                       (void *)map_map);
> > +                               (void *)map_map,
> > +                               sizeof(map_map[0]));
> >  #endif
> >
> >         for_each_present_section_nr(0, pnum) {
> > --
> > 2.13.6
> >
