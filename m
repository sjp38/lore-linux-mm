Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5E2C66B0005
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 19:35:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b203so113413127pfb.1
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 16:35:09 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id f77si699548pfd.64.2016.04.25.16.35.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 16:35:08 -0700 (PDT)
Date: Mon, 25 Apr 2016 16:34:29 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
Message-ID: <20160425233429.GH18517@birch.djwong.org>
References: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
 <1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
 <x49twj26edj.fsf@segfault.boston.devel.redhat.com>
 <20160420205923.GA24797@infradead.org>
 <1461434916.3695.7.camel@intel.com>
 <20160425083114.GA27556@infradead.org>
 <1461604476.3106.12.camel@intel.com>
 <20160425232552.GD18496@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20160425232552.GD18496@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "Verma, Vishal L" <vishal.l.verma@intel.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "jack@suse.cz" <jack@suse.cz>, "axboe@fb.com" <axboe@fb.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "hch@infradead.org" <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jmoyer@redhat.com" <jmoyer@redhat.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>

On Tue, Apr 26, 2016 at 09:25:52AM +1000, Dave Chinner wrote:
> On Mon, Apr 25, 2016 at 05:14:36PM +0000, Verma, Vishal L wrote:
> > On Mon, 2016-04-25 at 01:31 -0700, hch@infradead.org wrote:
> > > On Sat, Apr 23, 2016 at 06:08:37PM +0000, Verma, Vishal L wrote:
> > > > 
> > > > direct_IO might fail with -EINVAL due to misalignment, or -ENOMEM
> > > > due
> > > > to some allocation failing, and I thought we should return the
> > > > original
> > > > -EIO in such cases so that the application doesn't lose the
> > > > information
> > > > that the bad block is actually causing the error.
> > > EINVAL is a concern here.  Not due to the right error reported, but
> > > because it means your current scheme is fundamentally broken - we
> > > need to support I/O at any alignment for DAX I/O, and not fail due to
> > > alignbment concernes for a highly specific degraded case.
> > > 
> > > I think this whole series need to go back to the drawing board as I
> > > don't think it can actually rely on using direct I/O as the EIO
> > > fallback.
> > > 
> > Agreed that DAX I/O can happen with any size/alignment, but how else do
> > we send an IO through the driver without alignment restrictions? Also,
> > the granularity at which we store badblocks is 512B sectors, so it
> > seems natural that to clear such a sector, you'd expect to send a write
> > to the whole sector.
> > 
> > The expected usage flow is:
> > 
> > - Application hits EIO doing dax_IO or load/store io
> > 
> > - It checks badblocks and discovers it's files have lost data
> 
> Lots of hand-waving here. How does the application map a bad
> "sector" to a file without scanning the entire filesystem to find
> the owner of the bad sector?

FWIW there was some discussion @ LSF about using (XFS) rmap to figure out
which parts of a file (on XFS) have gone bad.  Chris Mason said that he'd
like to collaborate on having a common getfsmap ioctl between btrfs and
XFS since they have a backref index that could be hooked up to it for them.

Obviously the app still has to coordinate stopping file IO and calling
GETFSMAP since the fs won't do that on its own.  There's also the question
of how to handle LBA translation if there's other stuff like dm in the way.
I don't think device-mapper or md do reverse mapping, so things get murky
from here.

Guess I should get on pushing out a getfsmap patch for review. :)

--D

(/me doesn't have answers to any of your other questions.)

> > - It write()s those sectors (possibly converted to file offsets using
> > fiemap)
> >     * This triggers the fallback path, but if the application is doing
> > this level of recovery, it will know the sector is bad, and write the
> > entire sector
> 
> Where does the application find the data that was lost to be able to
> rewrite it?
> 
> > - Or it replaces the entire file from backup also using write() (not
> > mmap+stores)
> >     * This just frees the fs block, and the next time the block is
> > reallocated by the fs, it will likely be zeroed first, and that will be
> > done through the driver and will clear errors
> 
> There's an implicit assumption that applications will keep redundant
> copies of their data at the /application layer/ and be able to
> automatically repair it? And then there's the implicit assumption
> that it will unlink and free the entire file before writing a new
> copy, and that then assumes the the filesystem will zero blocks if
> they get reused to clear errors on that LBA sector mapping before
> they are accessible again to userspace..
> 
> It seems to me that there are a number of assumptions being made
> across multiple layers here. Maybe I've missed something - can you
> point me to the design/architecture description so I can see how
> "app does data recovery itself" dance is supposed to work?
> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com
> 
> _______________________________________________
> xfs mailing list
> xfs@oss.sgi.com
> http://oss.sgi.com/mailman/listinfo/xfs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
