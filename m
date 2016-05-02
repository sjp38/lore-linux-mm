Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A30EA6B0005
	for <linux-mm@kvack.org>; Mon,  2 May 2016 19:05:01 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 77so5812875pfz.3
        for <linux-mm@kvack.org>; Mon, 02 May 2016 16:05:01 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id g4si544498pax.154.2016.05.02.16.04.58
        for <linux-mm@kvack.org>;
        Mon, 02 May 2016 16:05:00 -0700 (PDT)
Date: Tue, 3 May 2016 09:04:22 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
Message-ID: <20160502230422.GQ26977@dastard>
References: <1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
 <x49twj26edj.fsf@segfault.boston.devel.redhat.com>
 <20160420205923.GA24797@infradead.org>
 <1461434916.3695.7.camel@intel.com>
 <20160425083114.GA27556@infradead.org>
 <1461604476.3106.12.camel@intel.com>
 <20160425232552.GD18496@dastard>
 <1461628381.1421.24.camel@intel.com>
 <20160426004155.GF18496@dastard>
 <x49pot4ebeb.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <x49pot4ebeb.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: "Dan J. Williams" <dan.j.williams@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "hch@infradead.org" <hch@infradead.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "jack@suse.cz" <jack@suse.cz>

On Mon, May 02, 2016 at 11:18:36AM -0400, Jeff Moyer wrote:
> Dave Chinner <david@fromorbit.com> writes:
> 
> > On Mon, Apr 25, 2016 at 11:53:13PM +0000, Verma, Vishal L wrote:
> >> On Tue, 2016-04-26 at 09:25 +1000, Dave Chinner wrote:
> > You're assuming that only the DAX aware application accesses it's
> > files.  users, backup programs, data replicators, fileystem
> > re-organisers (e.g.  defragmenters) etc all may access the files and
> > they may throw errors. What then?
> 
> I'm not sure how this is any different from regular storage.  If an
> application gets EIO, it's up to the app to decide what to do with that.

Sure - they'll fail. But the question I'm asking is that if the
application that owns the data is supposed to do error recovery,
what happens when a 3rd party application hits an error? If that
consumes the error, the the app that owns the data won't ever get a
chance to correct the error.

This is a minefield - a 3rd party app that swallows and clears DAX
based IO errors is a data corruption vector. can yo imagine if
*grep* did this? The model that is being promoted here effectively
allows this sort of behaviour - I don't really think we
should be architecting an error recovery strategy that has the
capability to go this wrong....

> >> > Where does the application find the data that was lost to be able to
> >> > rewrite it?
> >> 
> >> The data that was lost is gone -- this assumes the application has some
> >> ability to recover using a journal/log or other redundancy - yes, at the
> >> application layer. If it doesn't have this sort of capability, the only
> >> option is to restore files from a backup/mirror.
> >
> > So the architecture has a built in assumption that only userspace
> > can handle data loss?
> 
> Remember that the proposed programming model completely bypasses the
> kernel, so yes, it is expected that user-space will have to deal with
> the problem.

No, it doesn't completely bypass the kernel - the kernel is the
infrastructure that catches the errors in the first place, and it
owns and controls all the metadata that corresponds to the physical
location of that error. The only thing the kernel doesn't own is the
*contents* of that location.

> > What about filesytsems like NOVA, that use log structured design to
> > provide DAX w/ update atomicity and can potentially also provide
> > redundancy/repair through the same mechanisms? Won't pmem native
> > filesystems with built in data protection features like this remove
> > the need for adding all this to userspace applications?
> 
> I don't think we'll /only/ support NOVA for pmem.  So we'll have to deal
> with this for existing file systems, right?

Yes, but that misses my point that it seems that the design is only
focussed on userspace and existing filesystems and there is no
consideration of kernel side functionality that could do transparent
recovery....

> > If so, shouldn't that be the focus of development rahter than
> > placing the burden on userspace apps to handle storage repair
> > situations?
> 
> It really depends on the programming model.  In the model Vishal is
> talking about, either the applications themselves or the libraries they
> link to are expected to implement the redundancies where necessary.

IOWs, filesystems no longer have any control over data integrity.
Yet it's the filesystem developers who will still be responsible for
data integrity and when the filesystem has a data coruption event
we'll get blamed and the filesystem gets a bad name, even though
it's entirely the applications fault. We've seen this time and time
again - application developers cannot be trusted to guarantee data
integrity. yes, some apps will be fine, but do you really expect
application devs that refuse to use fsync because it's too slow are
going to have a different approach to integrity when it comes to
DAX?

> >> > There's an implicit assumption that applications will keep redundant
> >> > copies of their data at the /application layer/ and be able to
> >> > automatically repair it?
> 
> That's one way to do things.  It really depends on the application what
> it will do for recovery.
> 
> >> > And then there's the implicit assumption that it will unlink and
> >> > free the entire file before writing a new copy
> 
> I think Vishal was referring to restoring from backup.  cp itself will
> truncate the file before overwriting, iirc.

Which version of cp? what happens if they use --sparse and the error
is in a zeroed region? There's so many assumptions about undefined userspace
environment, application and user behaviour being made here, and
it's all being handwaved away.

I'm asking for this to be defined, demonstrated and documented as a
working model that cannot be abused and doesn't have holes the size
of trucks in it, not handwaving...

> >> To summarize, the two cases we want to handle are:
> >> 1. Application has inbuilt recovery:
> >>   - hits badblock
> >>   - figures out it is able to recover the data
> >>   - handles SIGBUS or EIO
> >>   - does a (sector aligned) write() to restore the data
> >
> > The "figures out" step here is where >95% of the work we'd have to
> > do is. And that's in filesystem and block layer code, not
> > userspace, and userspace can't do that work in a signal handler.
> > And it  can still fall down to the second case when the application
> > doesn't have another copy of the data somewhere.
> 
> I read that "figures out" step as the application determining whether or
> not it had a redundant copy.

Another undocumented assumption, that doesn't simplify what needs to
be done. Indeed, userspace can't do that until it is in SIGBUS
context, which tends to imply applications need to do a major amount
of work from within the signal handler....

> > FWIW, we don't have a DAX enabled filesystem that can do
> > reverse block mapping, so we're a year or two away from this being a
> > workable production solution from the filesystem perspective. And
> > AFAICT, it's not even on the roadmap for dm/md layers.
> 
> Do we even need that?  What if we added an FIEMAP flag for determining
> bad blocks.

So you're assuming that the filesystem has been informed of the bad
blocks and has already marked the bad regions of the file in it's
extent list?

How does that happen? What mechanism is used for the underlying
block device to inform the filesytem that theirs a bad LBA, and how
does the filesytem the map that to a path/file/offset with reverse
mapping? Or is there some other magic that hasn't been explained
happening here?

> The file system could simply walk the list of extents for
> the file and check the corresponding disk blocks.  No reverse mapping
> required.

You're expecting the filesystem to poll the block device to find bad
sectors? Ignoring the fact this is the sort of brute force scan we
need reverse mapping to avoid, how does the filesystem know what
file/extent list it should be searching when the block device
informs it there is a bad sector somewhere? i.e. what information
does the MCE convey to the block device, and what does the block
device pass to the filesytem so the filesystem can do one of these
scans? If the block device is only passing LBAs or a generic "new
bad block has been found" message, the filesystem still has to do an
full scan of it's metadata to find the owner of the LBA(s) that have
gone bad....

Nobody is explaining these important little details - there seems to
be an assumption that everyone "knows" how this is all going to work
and that we have infrastructure that can make it work.

Just because we might be able to present bad block information to
userspace via FIEMAP doesn't mean that it's trivial to implement.
THE FIEMAP flag is trivial - connecting the dots is the hard part
and nobody is explaining to me how that is all supposed to be done.

> Also note that DM/MD don't support direct_access(), either,
> so I don't think they're relevant for this discussion.

But they could for linear concatenation, which would be extremely
useful. e.g. stitching per-node non-linear pmem into a single linear
LBA range....


> >> 2. Application doesn't have any inbuilt recovery mechanism
> >>   - hits badblock
> >>   - gets SIGBUS (or EIO) and crashes
> >>   - Sysadmin restores file from backup
> >
> > Which is no different to an existing non-DAX application getting an
> > EIO/sigbus from current storage technologies.
> >
> > Except: in the existing storage stack, redundancy and correction has
> > already had to have failed for the application to see such an error.
> > Hence this is normally considered a DR case as there's had to be
> > cascading failures (e.g.  multiple disk failures in a RAID) to get
> > to this stage, not a single error in a single sector in
> > non-redundant storage.
> >
> > We need some form of redundancy and correction in the PMEM stack to
> > prevent single sector errors from taking down services until an
> > administrator can correct the problem. I'm trying to understand
> > where this is supposed to fit into the picture - at this point I
> > really don't think userspace applications are going to be able to do
> > this reliably....
> 
> Not all storage is configured into a RAID volume, and in some instances,
> the application is better positioned to recover the data (gluster/ceph,
> for example).

Right, but they still rely on the filesystem to provide data
integrity guarantees to work correctly. While they have "node level"
redundancy, operations within the node still need to work correctly
and so they'd still need all the kernel/fs side functionality to
provide them with error information (like fiemap bad blocks) on top
of all the new error detectiona nd correction code they'd need to
support this...

FWIW, the whole point of DAX on existing filesystems was to not need
major changes to existing filesystems to support fast pmem
operations.  i.e. to get something working quickly while pmem native
filesytems are developed to support pmem and all it's quirks in a
clean and efficient manner.

Instead, what I'm seeing now is a trend towards forcing existing
filesystems to support the requirements and quirks of DAX and pmem,
without any focus on pmem native solutions. i.e. I'm hearing "we
need major surgery to existing filesystems and block devices to make
DAX work" rather than "how do we make this efficient for a pmem
native solution rather than being bound to block device semantics"?

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
