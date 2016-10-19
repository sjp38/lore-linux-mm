Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id D351F6B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 18:55:00 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id l84so78957718ywe.5
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 15:55:00 -0700 (PDT)
Received: from gateway24.websitewelcome.com (gateway24.websitewelcome.com. [192.185.50.73])
        by mx.google.com with ESMTPS id r199si16727092oie.156.2016.10.19.15.54.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 15:54:59 -0700 (PDT)
Received: from cm7.websitewelcome.com (cm7.websitewelcome.com [108.167.139.20])
	by gateway24.websitewelcome.com (Postfix) with ESMTP id 72302924CADFA
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 17:54:59 -0500 (CDT)
Date: Wed, 19 Oct 2016 16:54:54 -0600
From: Stephen Bates <sbates@raithlin.com>
Subject: Re: [PATCH 0/3] iopmem : A block device for PCIe memory
Message-ID: <20161019225454.GA17086@cgy1-donard.priv.deltatee.com>
References: <1476826937-20665-1-git-send-email-sbates@raithlin.com>
 <CAPcyv4gJ_c-6s2BUjsu6okR1EF53R+KNuXnOc5jv0fuwJaa3cQ@mail.gmail.com>
 <20161019184814.GC16550@cgy1-donard.priv.deltatee.com>
 <CAPcyv4ht=ZtQOyUp8khzzJtZhWcsaCgQi=feEuaj1AY3f9wd=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4ht=ZtQOyUp8khzzJtZhWcsaCgQi=feEuaj1AY3f9wd=g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-rdma@vger.kernel.org, linux-block@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, haggaie@mellanox.com, Christoph Hellwig <hch@infradead.org>, Jens Axboe <axboe@fb.com>, Jonathan Corbet <corbet@lwn.net>, jim.macdonald@everspin.com, sbates@raithin.com, Logan Gunthorpe <logang@deltatee.com>, David Woodhouse <dwmw2@infradead.org>, "Raj, Ashok" <ashok.raj@intel.com>

> >>
> >> If you're only using the block-device as a entry-point to create
> >> dax-mappings then a device-dax (drivers/dax/) character-device might
> >> be a better fit.
> >>
> >
> > We chose a block device because we felt it was intuitive for users to
> > carve up a memory region but putting a DAX filesystem on it and creating
> > files on that DAX aware FS. It seemed like a convenient way to
> > partition up the region and to be easily able to get the DMA address
> > for the memory backing the device.
> >
> > That said I would be very keen to get other peoples thoughts on how
> > they would like to see this done. And I know some people have had some
> > reservations about using DAX mounted FS to do this in the past.
>
> I guess it depends on the expected size of these devices BARs, but I
> get the sense they may be smaller / more precious such that you
> wouldn't want to spend capacity on filesystem metadata? For the target
> use case is it assumed that these device BARs are always backed by
> non-volatile memory?  Otherwise this is a mkfs each boot for a
> volatile device.

Dan

Fair point and this is a concern I share. We are not assuming that all
iopmem devices are backed by non-volatile memory so the mkfs
recreation comment is valid. All in all I think you are persuading us
to take a look at /dev/dax ;-). I will see if anyone else chips in
with their thoughts on this.

>
> >>
> >> > 2. Memory Segment Spacing. This patch has the same limitations that
> >> > ZONE_DEVICE does in that memory regions must be spaces at least
> >> > SECTION_SIZE bytes part. On x86 this is 128MB and there are cases where
> >> > BARs can be placed closer together than this. Thus ZONE_DEVICE would not
> >> > be usable on neighboring BARs. For our purposes, this is not an issue as
> >> > we'd only be looking at enabling a single BAR in a given PCIe device.
> >> > More exotic use cases may have problems with this.
> >>
> >> I'm working on patches for 4.10 to allow mixing multiple
> >> devm_memremap_pages() allocations within the same physical section.
> >> Hopefully this won't be a problem going forward.
> >>
> >
> > Thanks Dan. Your patches will help address the problem of how to
> > partition a /dev/dax device but they don't help the case then BARs
> > themselves are small, closely spaced and non-segment aligned. However
> > I think most people using iopmem will want to use reasonbly large
> > BARs so I am not sure item 2 is that big of an issue.
>
> I think you might have misunderstood what I'm proposing.  The patches
> I'm working on are separate from a facility to carve up a /dev/dax
> device.  The effort is to allow devm_memremap_pages() to maintain
> several allocations within the same 128MB section.  I need this for
> persistent memory to handle platforms that mix pmem and system-ram in
> the same section.  I want to be able to map ZONE_DEVICE pages for a
> portion of a section and be able to remove portions of section that
> may collide with allocations of a different lifetime.

Oh I did misunderstand. This is very cool and would be useful to us.
One more reason to consider moving to /dev/dax in the next spin of
this patchset ;-).

Thanks

Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
