Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 482D16B0269
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 19:33:21 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n85so37740893pfi.7
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 16:33:21 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id h8si39190355pao.135.2016.10.20.16.33.19
        for <linux-mm@kvack.org>;
        Thu, 20 Oct 2016 16:33:20 -0700 (PDT)
Date: Fri, 21 Oct 2016 10:22:39 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 0/3] iopmem : A block device for PCIe memory
Message-ID: <20161020232239.GQ23194@dastard>
References: <1476826937-20665-1-git-send-email-sbates@raithlin.com>
 <CAPcyv4gJ_c-6s2BUjsu6okR1EF53R+KNuXnOc5jv0fuwJaa3cQ@mail.gmail.com>
 <20161019184814.GC16550@cgy1-donard.priv.deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161019184814.GC16550@cgy1-donard.priv.deltatee.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Bates <sbates@raithlin.com>
Cc: Dan Williams <dan.j.williams@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-rdma@vger.kernel.org, linux-block@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, jgunthorpe@obsidianresearch.com, haggaie@mellanox.com, Christoph Hellwig <hch@infradead.org>, Jens Axboe <axboe@fb.com>, Jonathan Corbet <corbet@lwn.net>, jim.macdonald@everspin.com, sbates@raithin.com, Logan Gunthorpe <logang@deltatee.com>, David Woodhouse <dwmw2@infradead.org>, "Raj, Ashok" <ashok.raj@intel.com>

On Wed, Oct 19, 2016 at 12:48:14PM -0600, Stephen Bates wrote:
> On Tue, Oct 18, 2016 at 08:51:15PM -0700, Dan Williams wrote:
> > [ adding Ashok and David for potential iommu comments ]
> >
> 
> Hi Dan
> 
> Thanks for adding Ashok and David!
> 
> >
> > I agree with the motivation and the need for a solution, but I have
> > some questions about this implementation.
> >
> > >
> > > Consumers
> > > ---------
> > >
> > > We provide a PCIe device driver in an accompanying patch that can be
> > > used to map any PCIe BAR into a DAX capable block device. For
> > > non-persistent BARs this simply serves as an alternative to using
> > > system memory bounce buffers. For persistent BARs this can serve as an
> > > additional storage device in the system.
> >
> > Why block devices?  I wonder if iopmem was initially designed back
> > when we were considering enabling DAX for raw block devices.  However,
> > that support has since been ripped out / abandoned.  You currently
> > need a filesystem on top of a block-device to get DAX operation.
> > Putting xfs or ext4 on top of PCI-E memory mapped range seems awkward
> > if all you want is a way to map the bar for another PCI-E device in
> > the topology.
> >
> > If you're only using the block-device as a entry-point to create
> > dax-mappings then a device-dax (drivers/dax/) character-device might
> > be a better fit.
> >
> 
> We chose a block device because we felt it was intuitive for users to
> carve up a memory region but putting a DAX filesystem on it and creating
> files on that DAX aware FS. It seemed like a convenient way to
> partition up the region and to be easily able to get the DMA address
> for the memory backing the device.

You do realise that local filesystems can silently change the
location of file data at any point in time, so there is no such
thing as a "stable mapping" of file data to block device addresses
in userspace?

If you want remote access to the blocks owned and controlled by a
filesystem, then you need to use a filesystem with a remote locking
mechanism to allow co-ordinated, coherent access to the data in
those blocks. Anything else is just asking for ongoing, unfixable
filesystem corruption or data leakage problems (i.e.  security
issues).

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
