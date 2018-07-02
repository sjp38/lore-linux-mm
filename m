Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 564AA6B0010
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 21:45:24 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id p12-v6so12185576iog.21
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 18:45:24 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id w83-v6si4679606itc.61.2018.07.01.18.45.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 18:45:23 -0700 (PDT)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w621i4BK092039
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 01:45:22 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2jwyccjp8q-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 02 Jul 2018 01:45:22 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w621jLx9000444
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 01:45:21 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w621jLJU025357
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 01:45:21 GMT
Received: by mail-oi0-f50.google.com with SMTP id k81-v6so13467079oib.4
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 18:45:21 -0700 (PDT)
MIME-Version: 1.0
References: <20180630030944.9335-1-pasha.tatashin@oracle.com>
 <20180630030944.9335-3-pasha.tatashin@oracle.com> <20180702013402.GI3223@MiWiFi-R3L-srv>
In-Reply-To: <20180702013402.GI3223@MiWiFi-R3L-srv>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Sun, 1 Jul 2018 21:44:44 -0400
Message-ID: <CAGM2reaoORijUVeNaeLQ075zJS737TaEhDxs3O=eMfyTUZXAdA@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] mm/sparse: start using sparse_init_nid(), and
 remove old code
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bhe@redhat.com
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net

On Sun, Jul 1, 2018 at 9:34 PM Baoquan He <bhe@redhat.com> wrote:
>
> Hi Pavel,
>
> On 06/29/18 at 11:09pm, Pavel Tatashin wrote:
> > Change sprase_init() to only find the pnum ranges that belong to a specific
> > node and call sprase_init_nid() for that range from sparse_init().
> >
> > Delete all the code that became obsolete with this change.
>
> > @@ -617,87 +491,24 @@ void __init sparse_init_nid(int nid, unsigned long pnum_begin,
> >   */
> >  void __init sparse_init(void)
> >  {
> > -     unsigned long pnum;
> > -     struct page *map;
> > -     struct page **map_map;
> > -     unsigned long *usemap;
> > -     unsigned long **usemap_map;
> > -     int size, size2;
> > -     int nr_consumed_maps = 0;
> > -
> > -     /* see include/linux/mmzone.h 'struct mem_section' definition */
> > -     BUILD_BUG_ON(!is_power_of_2(sizeof(struct mem_section)));
> > +     unsigned long pnum_begin = first_present_section_nr();
> > +     int nid_begin = sparse_early_nid(__nr_to_section(pnum_begin));
> > +     unsigned long pnum_end, map_count = 1;
> >
> > -     /* Setup pageblock_order for HUGETLB_PAGE_SIZE_VARIABLE */
> > -     set_pageblock_order();
>
> Not very sure if removing set_pageblock_order() calling here is OK. What
> if CONFIG_HUGETLB_PAGE_SIZE_VARIABLE is enabled? usemap_size() depends
> on value of 'pageblock_order'.

Hi Baoquan,

Nice catch, you are right, I incorrectly removed this call, will add
it back in the next version.

Pavel

>
> Thanks
> Baoquan
>
> > +     for_each_present_section_nr(pnum_begin + 1, pnum_end) {
> > +             int nid = sparse_early_nid(__nr_to_section(pnum_end));
> >
> > -     /*
> > -      * map is using big page (aka 2M in x86 64 bit)
> > -      * usemap is less one page (aka 24 bytes)
> > -      * so alloc 2M (with 2M align) and 24 bytes in turn will
> > -      * make next 2M slip to one more 2M later.
> > -      * then in big system, the memory will have a lot of holes...
> > -      * here try to allocate 2M pages continuously.
> > -      *
> > -      * powerpc need to call sparse_init_one_section right after each
> > -      * sparse_early_mem_map_alloc, so allocate usemap_map at first.
> > -      */
> > -     size = sizeof(unsigned long *) * nr_present_sections;
> > -     usemap_map = memblock_virt_alloc(size, 0);
> > -     if (!usemap_map)
> > -             panic("can not allocate usemap_map\n");
> > -     alloc_usemap_and_memmap(sparse_early_usemaps_alloc_node,
> > -                             (void *)usemap_map,
> > -                             sizeof(usemap_map[0]));
> > -
> > -     size2 = sizeof(struct page *) * nr_present_sections;
> > -     map_map = memblock_virt_alloc(size2, 0);
> > -     if (!map_map)
> > -             panic("can not allocate map_map\n");
> > -     alloc_usemap_and_memmap(sparse_early_mem_maps_alloc_node,
> > -                             (void *)map_map,
> > -                             sizeof(map_map[0]));
> > -
> > -     /* The numner of present sections stored in nr_present_sections
> > -      * are kept the same since mem sections are marked as present in
> > -      * memory_present(). In this for loop, we need check which sections
> > -      * failed to allocate memmap or usemap, then clear its
> > -      * ->section_mem_map accordingly. During this process, we need
> > -      * increase 'nr_consumed_maps' whether its allocation of memmap
> > -      * or usemap failed or not, so that after we handle the i-th
> > -      * memory section, can get memmap and usemap of (i+1)-th section
> > -      * correctly. */
> > -     for_each_present_section_nr(0, pnum) {
> > -             struct mem_section *ms;
> > -
> > -             if (nr_consumed_maps >= nr_present_sections) {
> > -                     pr_err("nr_consumed_maps goes beyond nr_present_sections\n");
> > -                     break;
> > -             }
> > -             ms = __nr_to_section(pnum);
> > -             usemap = usemap_map[nr_consumed_maps];
> > -             if (!usemap) {
> > -                     ms->section_mem_map = 0;
> > -                     nr_consumed_maps++;
> > -                     continue;
> > -             }
> > -
> > -             map = map_map[nr_consumed_maps];
> > -             if (!map) {
> > -                     ms->section_mem_map = 0;
> > -                     nr_consumed_maps++;
> > +             if (nid == nid_begin) {
> > +                     map_count++;
> >                       continue;
> >               }
> > -
> > -             sparse_init_one_section(__nr_to_section(pnum), pnum, map,
> > -                                                             usemap);
> > -             nr_consumed_maps++;
> > +             sparse_init_nid(nid, pnum_begin, pnum_end, map_count);
> > +             nid_begin = nid;
> > +             pnum_begin = pnum_end;
> > +             map_count = 1;
> >       }
> > -
> > +     sparse_init_nid(nid_begin, pnum_begin, pnum_end, map_count);
> >       vmemmap_populate_print_last();
> > -
> > -     memblock_free_early(__pa(map_map), size2);
> > -     memblock_free_early(__pa(usemap_map), size);
> >  }
> >
> >  #ifdef CONFIG_MEMORY_HOTPLUG
> > --
> > 2.18.0
> >
>
