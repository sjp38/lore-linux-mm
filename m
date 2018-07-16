Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 287096B0003
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 16:30:53 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id j189-v6so1337881oih.11
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 13:30:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u8-v6sor21434638oia.89.2018.07.16.13.30.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Jul 2018 13:30:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGM2rea9AwQGaf1JiV_SDDKTKyP_n+dG9Z20gtTZEkuZPFnXFQ@mail.gmail.com>
References: <153176041838.12695.3365448145295112857.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAGM2rea9AwQGaf1JiV_SDDKTKyP_n+dG9Z20gtTZEkuZPFnXFQ@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 16 Jul 2018 13:30:50 -0700
Message-ID: <CAPcyv4jo91jKjwn-M7cOhG=6vJ3c-QCyp0W+T+CtmiKGyZP1ng@mail.gmail.com>
Subject: Re: [PATCH v2 00/14] mm: Asynchronous + multithreaded memmap init for ZONE_DEVICE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Luck, Tony" <tony.luck@intel.com>, Huaisheng Ye <yehs1@lenovo.com>, Vishal L Verma <vishal.l.verma@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Dave Jiang <dave.jiang@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Rich Felker <dalias@libc.org>, Fenghua Yu <fenghua.yu@intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michal Hocko <mhocko@suse.com>, Paul Mackerras <paulus@samba.org>, Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Heiko Carstens <heiko.carstens@de.ibm.com>, X86 ML <x86@kernel.org>, Logan Gunthorpe <logang@deltatee.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, jmoyer <jmoyer@redhat.com>, Johannes Thumshirn <jthumshirn@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 16, 2018 at 12:12 PM, Pavel Tatashin
<pasha.tatashin@oracle.com> wrote:
> On Mon, Jul 16, 2018 at 1:10 PM Dan Williams <dan.j.williams@intel.com> wrote:
>>
>> Changes since v1 [1]:
>> * Teach memmap_sync() to take over a sub-set of memmap initialization in
>>   the foreground. This foreground work still needs to await the
>>   completion of vmemmap_populate_hugepages(), but it will otherwise
>>   steal 1/1024th of the 'struct page' init work for the given range.
>>   (Jan)
>> * Add kernel-doc for all the new 'async' structures.
>> * Split foreach_order_pgoff() to its own patch.
>> * Add Pavel and Daniel to the cc as they have been active in the memory
>>   hotplug code.
>> * Fix a typo that prevented CONFIG_DAX_DRIVER_DEBUG=y from performing
>>   early pfn retrieval at dax-filesystem mount time.
>> * Improve some of the changelogs
>>
>> [1]: https://lwn.net/Articles/759117/
>>
>> ---
>>
>> In order to keep pfn_to_page() a simple offset calculation the 'struct
>> page' memmap needs to be mapped and initialized in advance of any usage
>> of a page. This poses a problem for large memory systems as it delays
>> full availability of memory resources for 10s to 100s of seconds.
>>
>> For typical 'System RAM' the problem is mitigated by the fact that large
>> memory allocations tend to happen after the kernel has fully initialized
>> and userspace services / applications are launched. A small amount, 2GB
>> of memory, is initialized up front. The remainder is initialized in the
>> background and freed to the page allocator over time.
>>
>> Unfortunately, that scheme is not directly reusable for persistent
>> memory and dax because userspace has visibility to the entire resource
>> pool and can choose to access any offset directly at its choosing. In
>> other words there is no allocator indirection where the kernel can
>> satisfy requests with arbitrary pages as they become initialized.
>>
>> That said, we can approximate the optimization by performing the
>> initialization in the background, allow the kernel to fully boot the
>> platform, start up pmem block devices, mount filesystems in dax mode,
>> and only incur delay at the first userspace dax fault. When that initial
>> fault occurs that process is delegated a portion of the memmap to
>> initialize in the foreground so that it need not wait for initialization
>> of resources that it does not immediately need.
>>
>> With this change an 8 socket system was observed to initialize pmem
>> namespaces in ~4 seconds whereas it was previously taking ~4 minutes.
>
> Hi Dan,
>
> I am worried that this work adds another way to multi-thread struct
> page initialization without re-use of already existing method. The
> code is already a mess, and leads to bugs [1] because of the number of
> different memory layouts, architecture specific quirks, and different
> struct page initialization methods.

Yes, the lamentations about the complexity of the memory hotplug code
are known. I didn't think this set made it irretrievably worse, but
I'm biased and otherwise certainly want to build consensus with other
mem-hotplug folks.

>
> So, when DEFERRED_STRUCT_PAGE_INIT is used we initialize struct pages
> on demand until page_alloc_init_late() is called, and at that time we
> initialize all the rest of struct pages by calling:
>
> page_alloc_init_late()
>   deferred_init_memmap() (a thread per node)
>     deferred_init_pages()
>        __init_single_page()
>
> This is because memmap_init_zone() is not multi-threaded. However,
> this work makes memmap_init_zone() multi-threaded. So, I think we
> should really be either be using deferred_init_memmap() here, or teach
> DEFERRED_STRUCT_PAGE_INIT to use new multi-threaded memmap_init_zone()
> but not both.

I agree it would be good to look at unifying the 2 async
initialization approaches, however they have distinct constraints. All
of the ZONE_DEVICE memmap initialization work happens as a hotplug
event where the deferred_init_memmap() threads have already been torn
down. For the memory capacities where it takes minutes to initialize
the memmap it is painful to incur a global flush of all initialization
work. So, I think that a move to rework deferred_init_memmap() in
terms of memmap_init_async() is warranted because memmap_init_async()
avoids a global sync and supports the hotplug case.

Unfortunately, the work to unite these 2 mechanisms is going to be
4.20 material, at least for me, since I'm taking an extended leave,
and there is little time for me to get this in shape for 4.19. I
wouldn't be opposed to someone judiciously stealing from this set and
taking a shot at the integration, I likely will not get back to this
until September.
