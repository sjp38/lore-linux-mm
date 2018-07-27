Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 74AEB6B0003
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 13:26:27 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id n68-v6so5915484ite.8
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 10:26:27 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id w124-v6si3170616itg.35.2018.07.27.10.26.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jul 2018 10:26:26 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6RHNaQZ055206
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 17:26:25 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2kbwfq82gd-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 17:26:25 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w6RHQNF7012022
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 17:26:24 GMT
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w6RHQNRh026953
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 17:26:23 GMT
Received: by mail-oi0-f45.google.com with SMTP id k81-v6so10377920oib.4
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 10:26:23 -0700 (PDT)
MIME-Version: 1.0
References: <20180727165454.27292-1-david@redhat.com>
In-Reply-To: <20180727165454.27292-1-david@redhat.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 27 Jul 2018 13:25:45 -0400
Message-ID: <CAGM2reYOat1bxBi0KCZAKrh0YS2PX=w-AkpesuuNVY26SSDu9A@mail.gmail.com>
Subject: Re: [PATCH v1] mm: inititalize struct pages when adding a section
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@redhat.com
Cc: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, gregkh@linuxfoundation.org, mingo@kernel.org, Andrew Morton <akpm@linux-foundation.org>, dan.j.williams@intel.com, Michal Hocko <mhocko@suse.com>, jack@suse.cz, mawilcox@microsoft.com, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, kirill.shutemov@linux.intel.com, Vlastimil Babka <vbabka@suse.cz>, osalvador@techadventures.net, yasu.isimatu@gmail.com, malat@debian.org, Mel Gorman <mgorman@suse.de>, iamjoonsoo.kim@lge.com

Hi David,

On Fri, Jul 27, 2018 at 12:55 PM David Hildenbrand <david@redhat.com> wrote:
>
> Right now, struct pages are inititalized when memory is onlined, not
> when it is added (since commit d0dc12e86b31 ("mm/memory_hotplug: optimize
> memory hotplug")).
>
> remove_memory() will call arch_remove_memory(). Here, we usually access
> the struct page to get the zone of the pages.
>
> So effectively, we access stale struct pages in case we remove memory that
> was never onlined.

Yeah, this is a bug, thank you for catching it.

> So let's simply inititalize them earlier, when the
> memory is added. We only have to take care of updating the zone once we
> know it. We can use a dummy zone for that purpose.
>
> So effectively, all pages will already be initialized and set to
> reserved after memory was added but before it was onlined (and even the
> memblock is added). We only inititalize pages once, to not degrade
> performance.

Yes, but we still add one more npages loop, so there will be some
performance degradation, but not severe.

There are many conflicts with linux-next, please sync before sending
out next patch.

> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1162,7 +1162,15 @@ static inline void set_page_address(struct page *page, void *address)
>  {
>         page->virtual = address;
>  }
> +static void set_page_virtual(struct page *page, and enum zone_type zone)
> +{
> +       /* The shift won't overflow because ZONE_NORMAL is below 4G. */
> +       if (!is_highmem_idx(zone))
> +               set_page_address(page, __va(pfn << PAGE_SHIFT));
> +}
>  #define page_address_init()  do { } while(0)
> +#else
> +#define set_page_virtual(page, zone)  do { } while(0)
>  #endif

Please use inline functions for both if WANT_PAGE_VIRTUAL case and else case.

>  #if defined(HASHED_PAGE_VIRTUAL)
> @@ -2116,6 +2124,8 @@ extern unsigned long find_min_pfn_with_active_regions(void);
>  extern void free_bootmem_with_active_regions(int nid,
>                                                 unsigned long max_low_pfn);
>  extern void sparse_memory_present_with_active_regions(int nid);
> +extern void __meminit init_single_page(struct page *page, unsigned long pfn,
> +                                      unsigned long zone, int nid);

I do not like making init_single_page() public. There is less chance
it is going to be inlined. I think a better way is to have a new
variant of memmap_init_zone that will handle hotplug case.

>
>  #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 7deb49f69e27..3f28ca3c3a33 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -250,6 +250,7 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
>                 struct vmem_altmap *altmap, bool want_memblock)
>  {
>         int ret;
> +       int i;
>
>         if (pfn_valid(phys_start_pfn))
>                 return -EEXIST;
> @@ -258,6 +259,23 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
>         if (ret < 0)
>                 return ret;
>
> +       /*
> +        * Initialize all pages in the section before fully exposing them to the
> +        * system so nobody will stumble over a half inititalized state.
> +        */
> +       for (i = 0; i < PAGES_PER_SECTION; i++) {
> +               unsigned long pfn = phys_start_pfn + i;
> +               struct page *page;
> +
> +               if (!pfn_valid(pfn))
> +                       continue;
> +               page = pfn_to_page(pfn);
> +
> +               /* dummy zone, the actual one will be set when onlining pages */
> +               init_single_page(page, pfn, ZONE_NORMAL, nid);
> +               SetPageReserved(page);
> +       }

Please move all of the above into a new memmap_init_hotplug() that
should be located in page_alloc.c


> @@ -5519,9 +5515,12 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>
>  not_early:
>                 page = pfn_to_page(pfn);
> -               __init_single_page(page, pfn, zone, nid);
> -               if (context == MEMMAP_HOTPLUG)
> -                       SetPageReserved(page);
> +               if (context == MEMMAP_HOTPLUG) {
> +                       /* everything but the zone was inititalized */
> +                       set_page_zone(page, zone);
> +                       set_page_virtual(page, zone);
> +               } else
> +                       init_single_page(page, pfn, zone, nid);
>

Please add a new function:
memmap_init_zone_hotplug() that will handle only the zone and virtual
fields for onlined hotplug memory.

Please remove: "enum memmap_context context" from everywhere.

Thank you,
Pavel
