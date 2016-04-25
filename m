Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E49BE6B0005
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 19:25:56 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b203so113070120pfb.1
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 16:25:56 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id y65si673264pfa.146.2016.04.25.16.25.54
        for <linux-mm@kvack.org>;
        Mon, 25 Apr 2016 16:25:55 -0700 (PDT)
Date: Tue, 26 Apr 2016 09:25:52 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
Message-ID: <20160425232552.GD18496@dastard>
References: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
 <1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
 <x49twj26edj.fsf@segfault.boston.devel.redhat.com>
 <20160420205923.GA24797@infradead.org>
 <1461434916.3695.7.camel@intel.com>
 <20160425083114.GA27556@infradead.org>
 <1461604476.3106.12.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1461604476.3106.12.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Verma, Vishal L" <vishal.l.verma@intel.com>
Cc: "hch@infradead.org" <hch@infradead.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "jmoyer@redhat.com" <jmoyer@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "jack@suse.cz" <jack@suse.cz>

On Mon, Apr 25, 2016 at 05:14:36PM +0000, Verma, Vishal L wrote:
> On Mon, 2016-04-25 at 01:31 -0700, hch@infradead.org wrote:
> > On Sat, Apr 23, 2016 at 06:08:37PM +0000, Verma, Vishal L wrote:
> > > 
> > > direct_IO might fail with -EINVAL due to misalignment, or -ENOMEM
> > > due
> > > to some allocation failing, and I thought we should return the
> > > original
> > > -EIO in such cases so that the application doesn't lose the
> > > information
> > > that the bad block is actually causing the error.
> > EINVAL is a concern here.  Not due to the right error reported, but
> > because it means your current scheme is fundamentally broken - we
> > need to support I/O at any alignment for DAX I/O, and not fail due to
> > alignbment concernes for a highly specific degraded case.
> > 
> > I think this whole series need to go back to the drawing board as I
> > don't think it can actually rely on using direct I/O as the EIO
> > fallback.
> > 
> Agreed that DAX I/O can happen with any size/alignment, but how else do
> we send an IO through the driver without alignment restrictions? Also,
> the granularity at which we store badblocks is 512B sectors, so it
> seems natural that to clear such a sector, you'd expect to send a write
> to the whole sector.
> 
> The expected usage flow is:
> 
> - Application hits EIO doing dax_IO or load/store io
> 
> - It checks badblocks and discovers it's files have lost data

Lots of hand-waving here. How does the application map a bad
"sector" to a file without scanning the entire filesystem to find
the owner of the bad sector?

> - It write()s those sectors (possibly converted to file offsets using
> fiemap)
>     * This triggers the fallback path, but if the application is doing
> this level of recovery, it will know the sector is bad, and write the
> entire sector

Where does the application find the data that was lost to be able to
rewrite it?

> - Or it replaces the entire file from backup also using write() (not
> mmap+stores)
>     * This just frees the fs block, and the next time the block is
> reallocated by the fs, it will likely be zeroed first, and that will be
> done through the driver and will clear errors

There's an implicit assumption that applications will keep redundant
copies of their data at the /application layer/ and be able to
automatically repair it? And then there's the implicit assumption
that it will unlink and free the entire file before writing a new
copy, and that then assumes the the filesystem will zero blocks if
they get reused to clear errors on that LBA sector mapping before
they are accessible again to userspace..

It seems to me that there are a number of assumptions being made
across multiple layers here. Maybe I've missed something - can you
point me to the design/architecture description so I can see how
"app does data recovery itself" dance is supposed to work?

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
