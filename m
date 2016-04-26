Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id B88836B0005
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 22:56:52 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id d62so9051586iof.1
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 19:56:52 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id ax2si20531755igc.22.2016.04.25.19.56.50
        for <linux-mm@kvack.org>;
        Mon, 25 Apr 2016 19:56:51 -0700 (PDT)
Date: Tue, 26 Apr 2016 12:56:45 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
Message-ID: <20160426025645.GG18496@dastard>
References: <1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
 <x49twj26edj.fsf@segfault.boston.devel.redhat.com>
 <20160420205923.GA24797@infradead.org>
 <1461434916.3695.7.camel@intel.com>
 <20160425083114.GA27556@infradead.org>
 <1461604476.3106.12.camel@intel.com>
 <20160425232552.GD18496@dastard>
 <CAPcyv4i6iwm1iY2mQ5yRbYfRexQroUX_R0B-db4ROU837fratw@mail.gmail.com>
 <20160426001157.GE18496@dastard>
 <CAPcyv4i0qnCrzsTQT-v84OhnhjmVBFJ8gKoyu6XkuUwH0babfQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4i0qnCrzsTQT-v84OhnhjmVBFJ8gKoyu6XkuUwH0babfQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "Verma, Vishal L" <vishal.l.verma@intel.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "jack@suse.cz" <jack@suse.cz>, "axboe@fb.com" <axboe@fb.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "hch@infradead.org" <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>

On Mon, Apr 25, 2016 at 06:45:08PM -0700, Dan Williams wrote:
> On Mon, Apr 25, 2016 at 5:11 PM, Dave Chinner <david@fromorbit.com> wrote:
> > On Mon, Apr 25, 2016 at 04:43:14PM -0700, Dan Williams wrote:
> [..]
> >> Maybe I missed something, but all these assumptions are already
> >> present for typical block devices, i.e. sectors may go bad and a write
> >> may make the sector usable again.
> >
> > The assumption we make about sectors going bad on SSDs or SRDs is
> > that the device is about to die and needs replacing ASAP.
> 
> Similar assumptions here.  Storage media is experiencing errors and
> past a certain threshold it may be time to decommission the device.
> 
> You can see definitions for SMART / media health commands from various
> vendors at these links, and yes, hopefully these are standardized /
> unified at some point down the road:
> 
> http://pmem.io/documents/NVDIMM_DSM_Interface_Example.pdf
> https://github.com/HewlettPackard/hpe-nvm/blob/master/Documentation/NFIT_DSM_DDR4_NVDIMM-N_v84s.pdf
> https://msdn.microsoft.com/en-us/library/windows/hardware/mt604717(v=vs.85).aspx
> 
> 
> > Then
> > RAID takes care of the rebuild completely transparently. i.e.
> > handling and correcting bad sectors is typically done completely
> > transparently /below/ the filesytem like so:
> 
> Again, same for an NVDIMM.  Use the pmem block-device as a RAID-member device.

Which means we're not using DAX and so the existing storage model
applies. I understand how this works.

What I'm asking about the redundancy/error correction model /when
using DAX/ and a userspace DAX load/store throws the MCE.

> > And somehow all the error information from the hardware layer needs
> > to be propagated up to the application layer, along with all the
> > mapping information from the filesystem and block layers for the
> > application to make sense of the hardware reported errors.
> >
> > I see assumptions this this "just works" but we don't have any of
> > the relevant APIs or infrastructure to enable the application to do
> > the hardware error->file+offset namespace mapping (i.e. filesystem
> > reverse mapping for for file offsets and directory paths, and
> > reverse mapping for the the block layer remapping drivers).
> 
> If an application expects errors to be handled beneath the filesystem
> then it should forgo DAX and arrange for the NVDIMM devices to be
> RAIDed.

See above: I'm asking about the DAX-enabled error handling model,
not the traditional error handling model.

> Otherwise, if an application wants to use DAX then it might
> need to be prepared to handle media errors itself same as the
> un-RAIDed disk case.  Yes, at an administrative level without
> reverse-mapping support from a filesystem there's presently no way to
> ask "which files on this fs are impacted by media errors", and we're
> aware that reverse-mapping capabilities are nascent for current
> DAX-aware filesystems.

Precisely my point - suggestions are being proposed which assume
use of infrastructure that *does not exist yet* and has not been
discussed or documented. If we're expecting such infrastructure to
be implemented in the filesystems and block device drivers, then we
need to determine that the error model actually works first...

> The forward lookup path, as impractical as it
> is for large numbers of files, is available if an application wanted
> to know if a specific file was impacted.  We've discussed possibly
> extending fiemap() to return bad blocks in a file rather than
> consulting sysfs, or extending lseek() with something like SEEK_ERROR
> to return offsets of bad areas in a file.

Via what infrastructure will the filesystem use for finding out
whether a file has bad blocks in it? And if the file does have bad
blocks, what are you expecting the filesystem to do with that
information?

> > I haven't seen any design/documentation for infrastructure at the
> > application layer to handle redundant data and correctly
> > transparently so I don't have any idea what the technical
> > requirements this different IO stack places on filesystems may be.
> > Hence I'm asking for some kind of architecture/design documentation
> > that I can read to understand exactly what is being proposed here...
> 
> I think this is a discussion for a solution that would build on top of
> this basic "here are the errors, re-write them with good data if you
> can; otherwise, best of luck" foundation.  Something like a DAX-aware
> device mapper layer that duplicates data tagged with REQ_META so at
> least we have a recovery path when a sector error lands in critical
> filesystem-metadata. 

Filesytsem metadata is not the topic of discussion here - it's
user data that throws an error on a DAX load/store that is the
issue.

> However, anything we come up with to make NVDIMM
> errors more survivable should be directly applicable to traditional
> disk storage as well.

I'm not sure it does. DAX implies that traditional block layer RAID
infrastructure is not possible, nor are data CRCs, nor are any other
sort of data transformations that are needed for redundancy at the
device layers. Anything that relies on copying/modifying/stable data to
provide redundancies needs to do such work at a place where it can
stall userspace page faults.

This is where pmem native filesystem designs like NOVA take over
from traditional block based filesystems - they are designed around
the ability to do atomic page-based operations for data protection
and recovery operations. It is this mechanism that allows stable
pages to be committed to permanent storage and as such, allow
redundancy operations such as mirroring to be performed before
operations are marked as "stable".

I'm missing the bigger picture that is being aimed at here - what's the
point of DAX if we have to turn it off if we want any sort of
failure protection? What's the big plan for fully enabling DAX with
robust error correction? Where is this all supposed to be leading
to?

> Along these lines we had a BoF session at Vault
> where drive vendors we're wondering if the sysfs bad sectors list
> could help software recover from the loss of a disk-head, or other
> errors that only take down part of the drive.

Right, but as I've said elsewhere, loss of a disk head implies
terabyte scale data loss. That is not something we can automatically
recovery from at the filesystem level. Low level raid recovery could
handle that sort of loss, but at the higher layers it's a disaster
similar to multiple disk RAID failure.  It's a completely different
scale to a single sector/page loss we are talking about here, and so
I don't see there as being much (if any) overlap here.

> An I/O hint that flags
> data that should be stored redundantly might be useful there as well.

DAX doesn't have an IO path to hint with... :/

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
