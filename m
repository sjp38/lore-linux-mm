Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3107F6B0253
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 07:50:49 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id t73so8942582oie.5
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 04:50:49 -0700 (PDT)
Received: from gateway32.websitewelcome.com (gateway32.websitewelcome.com. [192.185.145.114])
        by mx.google.com with ESMTPS id d24si7761481ote.92.2016.10.25.04.50.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 04:50:48 -0700 (PDT)
Received: from cm7.websitewelcome.com (cm7.websitewelcome.com [108.167.139.20])
	by gateway32.websitewelcome.com (Postfix) with ESMTP id 344B7E1CC36C0
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 06:50:48 -0500 (CDT)
Date: Tue, 25 Oct 2016 05:50:43 -0600
From: Stephen Bates <sbates@raithlin.com>
Subject: Re: [PATCH 0/3] iopmem : A block device for PCIe memory
Message-ID: <20161025115043.GA14986@cgy1-donard.priv.deltatee.com>
References: <1476826937-20665-1-git-send-email-sbates@raithlin.com>
 <CAPcyv4gJ_c-6s2BUjsu6okR1EF53R+KNuXnOc5jv0fuwJaa3cQ@mail.gmail.com>
 <20161019184814.GC16550@cgy1-donard.priv.deltatee.com>
 <20161020232239.GQ23194@dastard>
 <20161021095714.GA12209@infradead.org>
 <20161021111253.GQ14023@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161021111253.GQ14023@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, Dan Williams <dan.j.williams@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, linux-rdma@vger.kernel.org, linux-block@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, jgunthorpe@obsidianresearch.com, haggaie@mellanox.com, Jens Axboe <axboe@fb.com>, Jonathan Corbet <corbet@lwn.net>, jim.macdonald@everspin.com, sbates@raithin.com, Logan Gunthorpe <logang@deltatee.com>, David Woodhouse <dwmw2@infradead.org>, "Raj, Ashok" <ashok.raj@intel.com>

Hi Dave and Christoph

On Fri, Oct 21, 2016 at 10:12:53PM +1100, Dave Chinner wrote:
> On Fri, Oct 21, 2016 at 02:57:14AM -0700, Christoph Hellwig wrote:
> > On Fri, Oct 21, 2016 at 10:22:39AM +1100, Dave Chinner wrote:
> > > You do realise that local filesystems can silently change the
> > > location of file data at any point in time, so there is no such
> > > thing as a "stable mapping" of file data to block device addresses
> > > in userspace?
> > >
> > > If you want remote access to the blocks owned and controlled by a
> > > filesystem, then you need to use a filesystem with a remote locking
> > > mechanism to allow co-ordinated, coherent access to the data in
> > > those blocks. Anything else is just asking for ongoing, unfixable
> > > filesystem corruption or data leakage problems (i.e.  security
> > > issues).
> >

Dave are you saying that even for local mappings of files on a DAX
capable system it is possible for the mappings to move on you unless
the FS supports locking? Does that not mean DAX on such FS is
inherently broken?

> > And at least for XFS we have such a mechanism :)  E.g. I have a
> > prototype of a pNFS layout that uses XFS+DAX to allow clients to do
> > RDMA directly to XFS files, with the same locking mechanism we use
> > for the current block and scsi layout in xfs_pnfs.c.
>

Thanks for fixing this issue on XFS Christoph! I assume this problem
continues to exist on the other DAX capable FS?

One more reason to consider a move to /dev/dax I guess ;-)...

Stephen


> Oh, that's good to know - pNFS over XFS was exactly what I was
> thinking of when I wrote my earlier reply. A few months ago someone
> else was trying to use file mappings in userspace for direct remote
> client access on fabric connected devices. I told them "pNFS on XFS
> and write an efficient transport for you hardware"....
>
> Now that I know we've got RDMA support for pNFS on XFS in the
> pipeline, I can just tell them "just write an rdma driver for your
> hardware" instead. :P
>
> Cheers,
>
> Dave.
> --
> Dave Chinner
> david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
