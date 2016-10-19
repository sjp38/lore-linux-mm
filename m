Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 93EA16B027C
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 15:58:31 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id g68so36873103ybi.1
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 12:58:31 -0700 (PDT)
Received: from mail-yw0-x22e.google.com (mail-yw0-x22e.google.com. [2607:f8b0:4002:c05::22e])
        by mx.google.com with ESMTPS id d16si3284778ywa.346.2016.10.19.12.58.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 12:58:30 -0700 (PDT)
Received: by mail-yw0-x22e.google.com with SMTP id u124so26006790ywg.3
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 12:58:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161019184814.GC16550@cgy1-donard.priv.deltatee.com>
References: <1476826937-20665-1-git-send-email-sbates@raithlin.com>
 <CAPcyv4gJ_c-6s2BUjsu6okR1EF53R+KNuXnOc5jv0fuwJaa3cQ@mail.gmail.com> <20161019184814.GC16550@cgy1-donard.priv.deltatee.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 19 Oct 2016 12:58:29 -0700
Message-ID: <CAPcyv4ht=ZtQOyUp8khzzJtZhWcsaCgQi=feEuaj1AY3f9wd=g@mail.gmail.com>
Subject: Re: [PATCH 0/3] iopmem : A block device for PCIe memory
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Bates <sbates@raithlin.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-rdma@vger.kernel.org, linux-block@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, haggaie@mellanox.com, Christoph Hellwig <hch@infradead.org>, Jens Axboe <axboe@fb.com>, Jonathan Corbet <corbet@lwn.net>, jim.macdonald@everspin.com, sbates@raithin.com, Logan Gunthorpe <logang@deltatee.com>, David Woodhouse <dwmw2@infradead.org>, "Raj, Ashok" <ashok.raj@intel.com>

On Wed, Oct 19, 2016 at 11:48 AM, Stephen Bates <sbates@raithlin.com> wrote:
> On Tue, Oct 18, 2016 at 08:51:15PM -0700, Dan Williams wrote:
>> [ adding Ashok and David for potential iommu comments ]
>>
>
> Hi Dan
>
> Thanks for adding Ashok and David!
>
>>
>> I agree with the motivation and the need for a solution, but I have
>> some questions about this implementation.
>>
>> >
>> > Consumers
>> > ---------
>> >
>> > We provide a PCIe device driver in an accompanying patch that can be
>> > used to map any PCIe BAR into a DAX capable block device. For
>> > non-persistent BARs this simply serves as an alternative to using
>> > system memory bounce buffers. For persistent BARs this can serve as an
>> > additional storage device in the system.
>>
>> Why block devices?  I wonder if iopmem was initially designed back
>> when we were considering enabling DAX for raw block devices.  However,
>> that support has since been ripped out / abandoned.  You currently
>> need a filesystem on top of a block-device to get DAX operation.
>> Putting xfs or ext4 on top of PCI-E memory mapped range seems awkward
>> if all you want is a way to map the bar for another PCI-E device in
>> the topology.
>>
>> If you're only using the block-device as a entry-point to create
>> dax-mappings then a device-dax (drivers/dax/) character-device might
>> be a better fit.
>>
>
> We chose a block device because we felt it was intuitive for users to
> carve up a memory region but putting a DAX filesystem on it and creating
> files on that DAX aware FS. It seemed like a convenient way to
> partition up the region and to be easily able to get the DMA address
> for the memory backing the device.
>
> That said I would be very keen to get other peoples thoughts on how
> they would like to see this done. And I know some people have had some
> reservations about using DAX mounted FS to do this in the past.

I guess it depends on the expected size of these devices BARs, but I
get the sense they may be smaller / more precious such that you
wouldn't want to spend capacity on filesystem metadata? For the target
use case is it assumed that these device BARs are always backed by
non-volatile memory?  Otherwise this is a mkfs each boot for a
volatile device.

>>
>> > 2. Memory Segment Spacing. This patch has the same limitations that
>> > ZONE_DEVICE does in that memory regions must be spaces at least
>> > SECTION_SIZE bytes part. On x86 this is 128MB and there are cases where
>> > BARs can be placed closer together than this. Thus ZONE_DEVICE would not
>> > be usable on neighboring BARs. For our purposes, this is not an issue as
>> > we'd only be looking at enabling a single BAR in a given PCIe device.
>> > More exotic use cases may have problems with this.
>>
>> I'm working on patches for 4.10 to allow mixing multiple
>> devm_memremap_pages() allocations within the same physical section.
>> Hopefully this won't be a problem going forward.
>>
>
> Thanks Dan. Your patches will help address the problem of how to
> partition a /dev/dax device but they don't help the case then BARs
> themselves are small, closely spaced and non-segment aligned. However
> I think most people using iopmem will want to use reasonbly large
> BARs so I am not sure item 2 is that big of an issue.

I think you might have misunderstood what I'm proposing.  The patches
I'm working on are separate from a facility to carve up a /dev/dax
device.  The effort is to allow devm_memremap_pages() to maintain
several allocations within the same 128MB section.  I need this for
persistent memory to handle platforms that mix pmem and system-ram in
the same section.  I want to be able to map ZONE_DEVICE pages for a
portion of a section and be able to remove portions of section that
may collide with allocations of a different lifetime.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
