Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9EA2C44043C
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 16:26:34 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id n74so1016621ota.18
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 13:26:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p23sor72151ota.82.2017.11.08.13.26.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Nov 2017 13:26:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.02.1711081516010.29922@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1711071645240.1339@file01.intranet.prod.int.rdu2.redhat.com>
 <20171108095909.GA7390@infradead.org> <alpine.LRH.2.02.1711080725490.12294@file01.intranet.prod.int.rdu2.redhat.com>
 <20171108150447.GA10374@infradead.org> <alpine.LRH.2.02.1711081007570.8618@file01.intranet.prod.int.rdu2.redhat.com>
 <20171108153522.GB24548@infradead.org> <alpine.LRH.2.02.1711081236570.1168@file01.intranet.prod.int.rdu2.redhat.com>
 <20171108174747.GA12199@infradead.org> <alpine.LRH.2.02.1711081516010.29922@file01.intranet.prod.int.rdu2.redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 8 Nov 2017 13:26:32 -0800
Message-ID: <CAPcyv4hR7DQ98ZCqqeyD2ihO0jWpQqPv_+s4v6iVaiNWrv96vw@mail.gmail.com>
Subject: Re: [dm-devel] [PATCH] vmalloc: introduce vmap_pfn for persistent memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Christoph Hellwig <hch@lst.de>, Linux MM <linux-mm@kvack.org>, dm-devel@redhat.com, Ross Zwisler <ross.zwisler@linux.intel.com>, Laura Abbott <labbott@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Nov 8, 2017 at 12:26 PM, Mikulas Patocka <mpatocka@redhat.com> wrote:
> On Wed, 8 Nov 2017, Christoph Hellwig wrote:
>
>> Can you start by explaining what you actually need the vmap for?
>
> It is possible to use lvm on persistent memory. You can create linear or
> striped logical volumes on persistent memory and these volumes still have
> the direct_access method, so they can be mapped with the function
> dax_direct_access().
>
> If we create logical volumes on persistent memory, the method
> dax_direct_access() won't return the whole device, it will return only a
> part. When dax_direct_access() returns the whole device, my driver just
> uses it without vmap. When dax_direct_access() return only a part of the
> device, my driver calls it repeatedly to get all the parts and then
> assembles the parts into a linear address space with vmap.

I know I proposed "call dax_direct_access() once" as a strawman for an
in-kernel driver user, but it's better to call it per access so you
can better stay in sync with base driver events like new media errors
and unplug / driver-unload. Either that, or at least have a plan how
to handle those events.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
