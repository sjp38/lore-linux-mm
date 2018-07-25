Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5FA0E6B000E
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 21:31:58 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 136-v6so4287385itw.5
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 18:31:58 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id w55-v6si9794119jaj.91.2018.07.24.18.31.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 18:31:57 -0700 (PDT)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6P1TS5i160288
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 01:31:56 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2130.oracle.com with ESMTP id 2kbv8t3e6v-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 01:31:56 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w6P1VtMk014875
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 01:31:55 GMT
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w6P1VtqL006712
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 01:31:55 GMT
Received: by mail-oi0-f43.google.com with SMTP id s198-v6so11009263oih.11
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 18:31:55 -0700 (PDT)
MIME-Version: 1.0
References: <20180724235520.10200-1-pasha.tatashin@oracle.com>
 <20180724235520.10200-4-pasha.tatashin@oracle.com> <20180724181800.3f25fdf8bcf0d8fd05ea1f43@linux-foundation.org>
In-Reply-To: <20180724181800.3f25fdf8bcf0d8fd05ea1f43@linux-foundation.org>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 24 Jul 2018 21:31:18 -0400
Message-ID: <CAGM2reaV09L0EVXa=3Ja4sjcEVCjXq0=iCxkruYLgqsxJaAo7g@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm: move mirrored memory specific code outside of memmap_init_zone
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, bhe@redhat.com, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

On Tue, Jul 24, 2018 at 9:18 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Tue, 24 Jul 2018 19:55:20 -0400 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:
>
> > memmap_init_zone, is getting complex, because it is called from different
> > contexts: hotplug, and during boot, and also because it must handle some
> > architecture quirks. One of them is mirroed memory.
> >
> > Move the code that decides whether to skip mirrored memory outside of
> > memmap_init_zone, into a separate function.
>
> Conflicts a bit with the page_alloc.c hunk from
> http://ozlabs.org/~akpm/mmots/broken-out/mm-page_alloc-remain-memblock_next_valid_pfn-on-arm-arm64.patch.  Please check my fixup:

The merge looks good to me. Thank you.

>
> void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>                 unsigned long start_pfn, enum memmap_context context,
>                 struct vmem_altmap *altmap)
> {
>         unsigned long pfn, end_pfn = start_pfn + size;
>         struct page *page;
>
>         if (highest_memmap_pfn < end_pfn - 1)
>                 highest_memmap_pfn = end_pfn - 1;
>
>         /*
>          * Honor reservation requested by the driver for this ZONE_DEVICE
>          * memory
>          */
>         if (altmap && start_pfn == altmap->base_pfn)
>                 start_pfn += altmap->reserve;
>
>         for (pfn = start_pfn; pfn < end_pfn; pfn++) {
>                 /*
>                  * There can be holes in boot-time mem_map[]s handed to this
>                  * function.  They do not exist on hotplugged memory.
>                  */
>                 if (context == MEMMAP_EARLY) {
>                         if (!early_pfn_valid(pfn)) {
>                                 pfn = next_valid_pfn(pfn) - 1;

I wish we did not have to do next_valid_pfn(pfn) - 1, and instead
could do something like:
for (pfn = start_pfn; pfn < end_pfn; pfn = next_valid_pfn(pfn))

Of course the performance of next_valid_pfn() should be optimized on
arm for the common case where next valid pfn is pfn++.

Pavel
