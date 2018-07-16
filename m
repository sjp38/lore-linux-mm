Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id EDA8A6B0003
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 15:13:39 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id y13-v6so23361853iop.3
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 12:13:39 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id e17-v6si19289164iob.142.2018.07.16.12.13.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 12:13:38 -0700 (PDT)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w6GJ9Gjl061756
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 19:13:37 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2130.oracle.com with ESMTP id 2k7a3swuvh-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 19:13:37 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w6GJDaOq013222
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 19:13:36 GMT
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w6GJDZSc005677
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 19:13:35 GMT
Received: by mail-oi0-f46.google.com with SMTP id l10-v6so30210166oii.0
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 12:13:35 -0700 (PDT)
MIME-Version: 1.0
References: <153176041838.12695.3365448145295112857.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153176041838.12695.3365448145295112857.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 16 Jul 2018 15:12:58 -0400
Message-ID: <CAGM2rea9AwQGaf1JiV_SDDKTKyP_n+dG9Z20gtTZEkuZPFnXFQ@mail.gmail.com>
Subject: Re: [PATCH v2 00/14] mm: Asynchronous + multithreaded memmap init for ZONE_DEVICE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.j.williams@intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>, tony.luck@intel.com, yehs1@lenovo.com, vishal.l.verma@intel.com, jack@suse.cz, willy@infradead.org, dave.jiang@intel.com, hpa@zytor.com, tglx@linutronix.de, dalias@libc.org, fenghua.yu@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>, ysato@users.sourceforge.jp, benh@kernel.crashing.org, Michal Hocko <mhocko@suse.com>, paulus@samba.org, hch@lst.de, jglisse@redhat.com, mingo@redhat.com, mpe@ellerman.id.au, Heiko Carstens <heiko.carstens@de.ibm.com>, x86@kernel.org, logang@deltatee.com, ross.zwisler@linux.intel.com, jmoyer@redhat.com, jthumshirn@suse.de, schwidefsky@de.ibm.com, Linux Memory Management List <linux-mm@kvack.org>, linux-nvdimm@lists.01.org, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 16, 2018 at 1:10 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> Changes since v1 [1]:
> * Teach memmap_sync() to take over a sub-set of memmap initialization in
>   the foreground. This foreground work still needs to await the
>   completion of vmemmap_populate_hugepages(), but it will otherwise
>   steal 1/1024th of the 'struct page' init work for the given range.
>   (Jan)
> * Add kernel-doc for all the new 'async' structures.
> * Split foreach_order_pgoff() to its own patch.
> * Add Pavel and Daniel to the cc as they have been active in the memory
>   hotplug code.
> * Fix a typo that prevented CONFIG_DAX_DRIVER_DEBUG=y from performing
>   early pfn retrieval at dax-filesystem mount time.
> * Improve some of the changelogs
>
> [1]: https://lwn.net/Articles/759117/
>
> ---
>
> In order to keep pfn_to_page() a simple offset calculation the 'struct
> page' memmap needs to be mapped and initialized in advance of any usage
> of a page. This poses a problem for large memory systems as it delays
> full availability of memory resources for 10s to 100s of seconds.
>
> For typical 'System RAM' the problem is mitigated by the fact that large
> memory allocations tend to happen after the kernel has fully initialized
> and userspace services / applications are launched. A small amount, 2GB
> of memory, is initialized up front. The remainder is initialized in the
> background and freed to the page allocator over time.
>
> Unfortunately, that scheme is not directly reusable for persistent
> memory and dax because userspace has visibility to the entire resource
> pool and can choose to access any offset directly at its choosing. In
> other words there is no allocator indirection where the kernel can
> satisfy requests with arbitrary pages as they become initialized.
>
> That said, we can approximate the optimization by performing the
> initialization in the background, allow the kernel to fully boot the
> platform, start up pmem block devices, mount filesystems in dax mode,
> and only incur delay at the first userspace dax fault. When that initial
> fault occurs that process is delegated a portion of the memmap to
> initialize in the foreground so that it need not wait for initialization
> of resources that it does not immediately need.
>
> With this change an 8 socket system was observed to initialize pmem
> namespaces in ~4 seconds whereas it was previously taking ~4 minutes.

Hi Dan,

I am worried that this work adds another way to multi-thread struct
page initialization without re-use of already existing method. The
code is already a mess, and leads to bugs [1] because of the number of
different memory layouts, architecture specific quirks, and different
struct page initialization methods.

So, when DEFERRED_STRUCT_PAGE_INIT is used we initialize struct pages
on demand until page_alloc_init_late() is called, and at that time we
initialize all the rest of struct pages by calling:

page_alloc_init_late()
  deferred_init_memmap() (a thread per node)
    deferred_init_pages()
       __init_single_page()

This is because memmap_init_zone() is not multi-threaded. However,
this work makes memmap_init_zone() multi-threaded. So, I think we
should really be either be using deferred_init_memmap() here, or teach
DEFERRED_STRUCT_PAGE_INIT to use new multi-threaded memmap_init_zone()
but not both.

I am planning to study the memmap layouts, and figure out how can we
reduce their number or merge some of the code, and also, I'd like to
simplify memmap_init_zone() by at least splitting it into two
functions: one that handles the boot case, and another that handles
the hotplug case, as those are substantially different, and make
memmap_init_zone() more complicated than needed.

Thank you,
Pavel

[1] https://www.spinics.net/lists/linux-mm/msg157271.html

>
> These patches apply on top of the HMM + devm_memremap_pages() reworks:
