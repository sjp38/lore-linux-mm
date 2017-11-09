Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2AADA6B033D
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 11:49:39 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id d65so896497oig.9
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 08:49:39 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q29sor2373419otc.241.2017.11.09.08.49.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 Nov 2017 08:49:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.02.1711091130070.9079@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1711071645240.1339@file01.intranet.prod.int.rdu2.redhat.com>
 <20171108095909.GA7390@infradead.org> <alpine.LRH.2.02.1711080725490.12294@file01.intranet.prod.int.rdu2.redhat.com>
 <20171108150447.GA10374@infradead.org> <alpine.LRH.2.02.1711081007570.8618@file01.intranet.prod.int.rdu2.redhat.com>
 <20171108153522.GB24548@infradead.org> <alpine.LRH.2.02.1711081236570.1168@file01.intranet.prod.int.rdu2.redhat.com>
 <20171108174747.GA12199@infradead.org> <alpine.LRH.2.02.1711081516010.29922@file01.intranet.prod.int.rdu2.redhat.com>
 <CAPcyv4hR7DQ98ZCqqeyD2ihO0jWpQqPv_+s4v6iVaiNWrv96vw@mail.gmail.com> <alpine.LRH.2.02.1711091130070.9079@file01.intranet.prod.int.rdu2.redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 9 Nov 2017 08:49:37 -0800
Message-ID: <CAPcyv4jb4UW_qjzenyKCbbufSL0rHGBU4OHDQo9BH212Kjtppg@mail.gmail.com>
Subject: Re: [dm-devel] [PATCH] vmalloc: introduce vmap_pfn for persistent memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, dm-devel@redhat.com, Ross Zwisler <ross.zwisler@linux.intel.com>, Laura Abbott <labbott@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Nov 9, 2017 at 8:37 AM, Mikulas Patocka <mpatocka@redhat.com> wrote:
>
>
> On Wed, 8 Nov 2017, Dan Williams wrote:
>
>> On Wed, Nov 8, 2017 at 12:26 PM, Mikulas Patocka <mpatocka@redhat.com> wrote:
>> > On Wed, 8 Nov 2017, Christoph Hellwig wrote:
>> >
>> >> Can you start by explaining what you actually need the vmap for?
>> >
>> > It is possible to use lvm on persistent memory. You can create linear or
>> > striped logical volumes on persistent memory and these volumes still have
>> > the direct_access method, so they can be mapped with the function
>> > dax_direct_access().
>> >
>> > If we create logical volumes on persistent memory, the method
>> > dax_direct_access() won't return the whole device, it will return only a
>> > part. When dax_direct_access() returns the whole device, my driver just
>> > uses it without vmap. When dax_direct_access() return only a part of the
>> > device, my driver calls it repeatedly to get all the parts and then
>> > assembles the parts into a linear address space with vmap.
>>
>> I know I proposed "call dax_direct_access() once" as a strawman for an
>> in-kernel driver user, but it's better to call it per access so you
>> can better stay in sync with base driver events like new media errors
>> and unplug / driver-unload. Either that, or at least have a plan how
>> to handle those events.
>
> Calling it on every access would be inacceptable performance overkill. How
> is it supposed to work anyway? - if something intends to move data on
> persistent memory while some driver accesse it, then we need two functions
> - dax_direct_access() and dax_relinquish_direct_access(). The current
> kernel lacks a function dax_relinquish_direct_access() that would mark a
> region of data as moveable, so we can't move the data anyway.

We take a global reference on the hosting device while pages are
registered, see the percpu_ref usage in kernel/memremap.c, and we hold
the dax_read_lock() over calls to dax_direct_access() to temporarily
hold the device alive for the duration of the call.

> BTW. what happens if we create a write bio that has its pages pointing to
> persistent memory and there is error when the storage controller attempts
> to do DMA from persistent memory? Will the storage controller react to the
> error in a sensible way and will the block layer report the error?

While pages are pinned for DMA the devm_memremap_pages() mapping is
pinned. Otherwise, an error reading persistent memory is identical to
an error reading DRAM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
