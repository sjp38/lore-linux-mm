Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id C55F4440D03
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 13:52:03 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id b49so1822117otj.11
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 10:52:03 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n11si3449981oib.80.2017.11.09.10.52.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 10:52:02 -0800 (PST)
Date: Thu, 9 Nov 2017 13:51:58 -0500 (EST)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [dm-devel] [PATCH] vmalloc: introduce vmap_pfn for persistent
 memory
In-Reply-To: <CAPcyv4jsUuROY9Bk8xXupuJq22xRUDoiiTSqegv-njUR6MxeYw@mail.gmail.com>
Message-ID: <alpine.LRH.2.02.1711091340140.5328@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1711071645240.1339@file01.intranet.prod.int.rdu2.redhat.com> <20171108095909.GA7390@infradead.org> <alpine.LRH.2.02.1711080725490.12294@file01.intranet.prod.int.rdu2.redhat.com> <20171108150447.GA10374@infradead.org>
 <alpine.LRH.2.02.1711081007570.8618@file01.intranet.prod.int.rdu2.redhat.com> <20171108153522.GB24548@infradead.org> <alpine.LRH.2.02.1711081236570.1168@file01.intranet.prod.int.rdu2.redhat.com> <20171108174747.GA12199@infradead.org>
 <alpine.LRH.2.02.1711081516010.29922@file01.intranet.prod.int.rdu2.redhat.com> <CAPcyv4hR7DQ98ZCqqeyD2ihO0jWpQqPv_+s4v6iVaiNWrv96vw@mail.gmail.com> <alpine.LRH.2.02.1711091130070.9079@file01.intranet.prod.int.rdu2.redhat.com>
 <CAPcyv4jb4UW_qjzenyKCbbufSL0rHGBU4OHDQo9BH212Kjtppg@mail.gmail.com> <alpine.LRH.2.02.1711091231240.28067@file01.intranet.prod.int.rdu2.redhat.com> <CAPcyv4jsUuROY9Bk8xXupuJq22xRUDoiiTSqegv-njUR6MxeYw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, dm-devel@redhat.com, Ross Zwisler <ross.zwisler@linux.intel.com>, Laura Abbott <labbott@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>



On Thu, 9 Nov 2017, Dan Williams wrote:

> On Thu, Nov 9, 2017 at 10:13 AM, Mikulas Patocka <mpatocka@redhat.com> wrote:
> >
> >
> > On Thu, 9 Nov 2017, Dan Williams wrote:
> >
> >> On Thu, Nov 9, 2017 at 8:37 AM, Mikulas Patocka <mpatocka@redhat.com> wrote:
> >> >
> >> >
> >> > On Wed, 8 Nov 2017, Dan Williams wrote:
> >> >
> >> >> On Wed, Nov 8, 2017 at 12:26 PM, Mikulas Patocka <mpatocka@redhat.com> wrote:
> >> >> > On Wed, 8 Nov 2017, Christoph Hellwig wrote:
> >> >> >
> >> >> >> Can you start by explaining what you actually need the vmap for?
> >> >> >
> >> >> > It is possible to use lvm on persistent memory. You can create linear or
> >> >> > striped logical volumes on persistent memory and these volumes still have
> >> >> > the direct_access method, so they can be mapped with the function
> >> >> > dax_direct_access().
> >> >> >
> >> >> > If we create logical volumes on persistent memory, the method
> >> >> > dax_direct_access() won't return the whole device, it will return only a
> >> >> > part. When dax_direct_access() returns the whole device, my driver just
> >> >> > uses it without vmap. When dax_direct_access() return only a part of the
> >> >> > device, my driver calls it repeatedly to get all the parts and then
> >> >> > assembles the parts into a linear address space with vmap.
> >> >>
> >> >> I know I proposed "call dax_direct_access() once" as a strawman for an
> >> >> in-kernel driver user, but it's better to call it per access so you
> >> >> can better stay in sync with base driver events like new media errors
> >> >> and unplug / driver-unload. Either that, or at least have a plan how
> >> >> to handle those events.
> >> >
> >> > Calling it on every access would be inacceptable performance overkill. How
> >> > is it supposed to work anyway? - if something intends to move data on
> >> > persistent memory while some driver accesse it, then we need two functions
> >> > - dax_direct_access() and dax_relinquish_direct_access(). The current
> >> > kernel lacks a function dax_relinquish_direct_access() that would mark a
> >> > region of data as moveable, so we can't move the data anyway.
> >>
> >> We take a global reference on the hosting device while pages are
> >> registered, see the percpu_ref usage in kernel/memremap.c, and we hold
> >> the dax_read_lock() over calls to dax_direct_access() to temporarily
> >> hold the device alive for the duration of the call.
> >
> > If would be good if you provided some function that locks down persistent
> > memory in the long-term. Locking it on every access just kills performance
> > unacceptably.
> >
> > For changing mapping, you could provide a callback. When the callback is
> > called, the driver that uses persistent memory could quiesce itself,
> > release the long-term lock and let the system change the mapping.
> 
> I'll take a look at this. It dovetails with some of the discussions we
> are having about how to support RDMA to persistent memory and
> notification/callback to tear down memory registrations.

If you come up with some design, post it also to dm-devel@redhat.com and 
to me. Device mapper can also change mapping of devices, so it will need 
to participate in long-term locking too.

> >> While pages are pinned for DMA the devm_memremap_pages() mapping is
> >> pinned. Otherwise, an error reading persistent memory is identical to
> >> an error reading DRAM.
> >
> > The question is if storage controllers and their drivers can react to this
> > in a sensible way. Did someone test it?
> 
> The drivers don't need to react, once the pages are pinned for dma the
> hot-unplug will not progress until all those page references are
> dropped.

I am not talking about moving pages here, I'm talking about possible 
hardware errors in persistent memory. In this situation, the storage 
controller receives an error on the bus - and the question is, how will it 
react. Ideally, it should abort just this transfer and return an error 
that the driver will propagate up. But I'm skeptical that someone is 
really testing the controllers and drivers for this possiblity.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
