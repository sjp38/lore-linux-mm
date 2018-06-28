Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7ECB36B000A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 23:15:24 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id z8-v6so4976204itc.9
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 20:15:24 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id i76-v6si3921492ioe.190.2018.06.27.20.15.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 20:15:23 -0700 (PDT)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5S3Dawk094815
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 03:15:22 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2130.oracle.com with ESMTP id 2jum57ysq2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 03:15:22 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w5S3FLDd029209
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 03:15:21 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w5S3FLKb023506
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 03:15:21 GMT
Received: by mail-oi0-f46.google.com with SMTP id k81-v6so3819919oib.4
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 20:15:21 -0700 (PDT)
MIME-Version: 1.0
References: <20180627013116.12411-1-bhe@redhat.com> <20180627013116.12411-4-bhe@redhat.com>
In-Reply-To: <20180627013116.12411-4-bhe@redhat.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 27 Jun 2018 23:14:44 -0400
Message-ID: <CAGM2reb=2fmgJQzfPGJ_bCG-317-dsFfoG8vSr9LuYit4AVsyQ@mail.gmail.com>
Subject: Re: [PATCH v5 3/4] mm/sparse: Add a new parameter 'data_unit_size'
 for alloc_usemap_and_memmap
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bhe@redhat.com
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, dave.hansen@intel.com, pagupta@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, kirill.shutemov@linux.intel.com

Honestly, I do not like this new agrument, but it will do for now. I
could not think of a better way without rewriting everything.

Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>

However, I will submit a series of patches to cleanup sparse.c and
completely remove large and confusing temporary buffers: map_map, and
usemap_map. In those patches, I will remove alloc_usemap_and_memmap().
On Tue, Jun 26, 2018 at 9:31 PM Baoquan He <bhe@redhat.com> wrote:
>
> alloc_usemap_and_memmap() is passing in a "void *" that points to
> usemap_map or memmap_map. In next patch we will change both of the
> map allocation from taking 'NR_MEM_SECTIONS' as the length to taking
> 'nr_present_sections' as the length. After that, the passed in 'void*'
> needs to update as things get consumed. But, it knows only the
> quantity of objects consumed and not the type.  This effectively
> tells it enough about the type to let it update the pointer as
> objects are consumed.
>
> Signed-off-by: Baoquan He <bhe@redhat.com>
> ---
>  mm/sparse.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
>
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 71ad53da2cd1..b2848cc6e32a 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -489,10 +489,12 @@ void __weak __meminit vmemmap_populate_print_last(void)
>  /**
>   *  alloc_usemap_and_memmap - memory alloction for pageblock flags and vmemmap
>   *  @map: usemap_map for pageblock flags or mmap_map for vmemmap
> + *  @unit_size: size of map unit
>   */
>  static void __init alloc_usemap_and_memmap(void (*alloc_func)
>                                         (void *, unsigned long, unsigned long,
> -                                       unsigned long, int), void *data)
> +                                       unsigned long, int), void *data,
> +                                       int data_unit_size)
>  {
>         unsigned long pnum;
>         unsigned long map_count;
> @@ -569,7 +571,8 @@ void __init sparse_init(void)
>         if (!usemap_map)
>                 panic("can not allocate usemap_map\n");
>         alloc_usemap_and_memmap(sparse_early_usemaps_alloc_node,
> -                                                       (void *)usemap_map);
> +                               (void *)usemap_map,
> +                               sizeof(usemap_map[0]));
>
>  #ifdef CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
>         size2 = sizeof(struct page *) * NR_MEM_SECTIONS;
> @@ -577,7 +580,8 @@ void __init sparse_init(void)
>         if (!map_map)
>                 panic("can not allocate map_map\n");
>         alloc_usemap_and_memmap(sparse_early_mem_maps_alloc_node,
> -                                                       (void *)map_map);
> +                               (void *)map_map,
> +                               sizeof(map_map[0]));
>  #endif
>
>         for_each_present_section_nr(0, pnum) {
> --
> 2.13.6
>
