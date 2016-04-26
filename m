Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id A91966B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 04:27:29 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id e63so12568936iod.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 01:27:29 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id n70si1950022iod.22.2016.04.26.01.27.27
        for <linux-mm@kvack.org>;
        Tue, 26 Apr 2016 01:27:28 -0700 (PDT)
Date: Tue, 26 Apr 2016 18:27:11 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
Message-ID: <20160426082711.GC26977@dastard>
References: <20160420205923.GA24797@infradead.org>
 <1461434916.3695.7.camel@intel.com>
 <20160425083114.GA27556@infradead.org>
 <1461604476.3106.12.camel@intel.com>
 <20160425232552.GD18496@dastard>
 <CAPcyv4i6iwm1iY2mQ5yRbYfRexQroUX_R0B-db4ROU837fratw@mail.gmail.com>
 <20160426001157.GE18496@dastard>
 <CAPcyv4i0qnCrzsTQT-v84OhnhjmVBFJ8gKoyu6XkuUwH0babfQ@mail.gmail.com>
 <20160426025645.GG18496@dastard>
 <CAPcyv4hg6O3nvD7aXuFm_GAB-1GJxqfNn=RZswj47COa9bVygA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hg6O3nvD7aXuFm_GAB-1GJxqfNn=RZswj47COa9bVygA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "Verma, Vishal L" <vishal.l.verma@intel.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "jack@suse.cz" <jack@suse.cz>, "axboe@fb.com" <axboe@fb.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "hch@infradead.org" <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>

On Mon, Apr 25, 2016 at 09:18:42PM -0700, Dan Williams wrote:
> On Mon, Apr 25, 2016 at 7:56 PM, Dave Chinner <david@fromorbit.com> wrote:
> > On Mon, Apr 25, 2016 at 06:45:08PM -0700, Dan Williams wrote:
> >> > I haven't seen any design/documentation for infrastructure at the
> >> > application layer to handle redundant data and correctly
> >> > transparently so I don't have any idea what the technical
> >> > requirements this different IO stack places on filesystems may be.
> >> > Hence I'm asking for some kind of architecture/design documentation
> >> > that I can read to understand exactly what is being proposed here...
> >>
> >> I think this is a discussion for a solution that would build on top of
> >> this basic "here are the errors, re-write them with good data if you
> >> can; otherwise, best of luck" foundation.  Something like a DAX-aware
> >> device mapper layer that duplicates data tagged with REQ_META so at
> >> least we have a recovery path when a sector error lands in critical
> >> filesystem-metadata.
> >
> > Filesytsem metadata is not the topic of discussion here - it's
> > user data that throws an error on a DAX load/store that is the
> > issue.
> 
> Which is not a new problem since volatile DRAM in the non-DAX case can
> throw the exact same error.

They are not the same class of error, not by a long shot.

The "bad page in page cache" error on traditional storage means data
is not lost - the original copy still in whatever storage medium
that the cached page was filled from. i.e. Re-read the file and the
data is still there, which is no different to crashing and
restarting that machine and losing whatever writes had not been
committed to stable storage..

In the pmem case, a "bad page" is a permanent loss of data - it's
unrecoverable without some form data recovery operation being
performed on the storage.

> The current recovery model there is crash
> the kernel (without MCE recovery),

Ouch. Permanent data loss and a system wide DoS.

> or crash the application and hope
> the kernel maps out the page or the application knows how to restart
> after SIGBUS. 

Not much better - neither provide a mechanism for recovery.

> Memory mirroring is meant to make this a bit less
> harsh, but there's no mechanism to make this available outside the
> kernel.

Which implies that we need a DM module that interfaces with the
hardware memory mirroring to perform recovery and remapping
operations. i.e. in the traditional storage stack location.

> >> However, anything we come up with to make NVDIMM
> >> errors more survivable should be directly applicable to traditional
> >> disk storage as well.
> >
> > I'm not sure it does. DAX implies that traditional block layer RAID
> > infrastructure is not possible, nor are data CRCs, nor are any other
> > sort of data transformations that are needed for redundancy at the
> > device layers. Anything that relies on copying/modifying/stable data to
> > provide redundancies needs to do such work at a place where it can
> > stall userspace page faults.
> >
> > This is where pmem native filesystem designs like NOVA take over
> > from traditional block based filesystems - they are designed around
> > the ability to do atomic page-based operations for data protection
> > and recovery operations. It is this mechanism that allows stable
> > pages to be committed to permanent storage and as such, allow
> > redundancy operations such as mirroring to be performed before
> > operations are marked as "stable".
> >
> > I'm missing the bigger picture that is being aimed at here - what's the
> > point of DAX if we have to turn it off if we want any sort of
> > failure protection? What's the big plan for fully enabling DAX with
> > robust error correction? Where is this all supposed to be leading
> > to?
> >
> 
> NOVA and other solutions are free and encouraged to do a coherent
> bottoms-up rethink of error handling on top of persistent memory
> devices, in the meantime applications can only expect the legacy
> SIGBUS and -EIO mechanisms are available.  So I'm still trying to
> connect how the "What would NOVA do?" discussion is anything but
> orthogonal to hooking up SIGBUS and -EIO for traditional-filesystem
> DAX.  It's the only error model an application can expect because it's
> the only one that currently exists.

<sigh>

Yes, I get that. I'm not interested in the resultant fatal error
delivery - I'm asking about what happens between the memory error
and the delivery of the fatal "we've lost your data forever" error
that gets delivered to userspace. i.e. I'm after  a description of
how error correction/recovery is supposed to be applied to DAX
*before we report SIGBUS or EIO* to the application.

What is the plan/model/vision for intercepting MCEs and recovering
from them? e.g. how do we going to pull the good copy from
hardware/software memory mirrors? What layer is supposed to be
responsible for that? Is it different for hardware mirroring
compared to a more traditional software dm-RAID1 solution? What
requirements does software recovery imply - do we need stable page
state for DAX (i.e. to prevent userspace modification while we
make copies)? Do we need to remap LBAs in the storage stack iduring
recovery when bad blocks are reported? If so, where does it get
done? What atomicity and resiliency requirements are there for
recovery? e.g. bad block is reported, system crashes - what needs to
happen on reboot to have recovery work correctly? 

There's heaps of stuff that is completely undefined here - error
handling is fucking hard at the best of times, but I'm struggling to
understand even the basics of what is being proposed here apart from
"pmem error == crash the application, maybe even the system".

Future filesystems are only part of the solution here -
infrastructure like access to hardware mirrored copies for recovery
purposes will impact greatly on the design of upper layers and their
performance (e.g. no need for RAID1 in a software layer), so we
really need the model/architecture to be pretty clearly defined at
the outset before people waste too much time going down paths that
simply won't work on the hardware/infrastructure that is being
provided....

> >> An I/O hint that flags
> >> data that should be stored redundantly might be useful there as well.
> >
> > DAX doesn't have an IO path to hint with... :/
> 
> ...I was thinking traditional filesystem metadata operations through
> the block layer.  NOVA could of course do something better since it
> always indirects userspace access through a filesystem managed page.

It seems to me you are focussing on code/technologies that exist
today instead of trying to define an architecture that is more
optimal for pmem storage systems. Yes, working code is great, but if
you can't tell people how things like robust error handling and
redundancy are going to work in future then it's going to take
forever for everyone else to handle such errors robustly through the
storage stack...

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
