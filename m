Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 027C56B0005
	for <linux-mm@kvack.org>; Mon,  2 May 2016 21:52:06 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id i75so20204486ioa.3
        for <linux-mm@kvack.org>; Mon, 02 May 2016 18:52:05 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id n27si1261896ioe.105.2016.05.02.18.52.03
        for <linux-mm@kvack.org>;
        Mon, 02 May 2016 18:52:05 -0700 (PDT)
Date: Tue, 3 May 2016 11:51:59 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
Message-ID: <20160503015159.GS26977@dastard>
References: <20160420205923.GA24797@infradead.org>
 <1461434916.3695.7.camel@intel.com>
 <20160425083114.GA27556@infradead.org>
 <1461604476.3106.12.camel@intel.com>
 <20160425232552.GD18496@dastard>
 <1461628381.1421.24.camel@intel.com>
 <20160426004155.GF18496@dastard>
 <x49pot4ebeb.fsf@segfault.boston.devel.redhat.com>
 <20160502230422.GQ26977@dastard>
 <CAPcyv4jDTvSUDGTBZb0MaK_gKxMxWtMecnR_OjLzim1Sdg5Y9g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jDTvSUDGTBZb0MaK_gKxMxWtMecnR_OjLzim1Sdg5Y9g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "hch@infradead.org" <hch@infradead.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "jack@suse.cz" <jack@suse.cz>

On Mon, May 02, 2016 at 04:25:51PM -0700, Dan Williams wrote:
> On Mon, May 2, 2016 at 4:04 PM, Dave Chinner <david@fromorbit.com> wrote:
> > On Mon, May 02, 2016 at 11:18:36AM -0400, Jeff Moyer wrote:
> >> Dave Chinner <david@fromorbit.com> writes:
> >>
> >> > On Mon, Apr 25, 2016 at 11:53:13PM +0000, Verma, Vishal L wrote:
> >> >> On Tue, 2016-04-26 at 09:25 +1000, Dave Chinner wrote:
> >> > You're assuming that only the DAX aware application accesses it's
> >> > files.  users, backup programs, data replicators, fileystem
> >> > re-organisers (e.g.  defragmenters) etc all may access the files and
> >> > they may throw errors. What then?
> >>
> >> I'm not sure how this is any different from regular storage.  If an
> >> application gets EIO, it's up to the app to decide what to do with that.
> >
> > Sure - they'll fail. But the question I'm asking is that if the
> > application that owns the data is supposed to do error recovery,
> > what happens when a 3rd party application hits an error? If that
> > consumes the error, the the app that owns the data won't ever get a
> > chance to correct the error.
> >
> > This is a minefield - a 3rd party app that swallows and clears DAX
> > based IO errors is a data corruption vector. can yo imagine if
> > *grep* did this? The model that is being promoted here effectively
> > allows this sort of behaviour - I don't really think we
> > should be architecting an error recovery strategy that has the
> > capability to go this wrong....
> 
> Since when does grep write to a file on error?

That's precisely my point - it doesn't right now because there is no
onus on userspace applications to correct data errors when they are
found.

However, if the accepted model becomes "userspace needs to try to correct
errors in data automatically", the above scenario is a distinct
possiblity. I'm not saying grep will do this - I'm taking
the logical argument being presented to the extreme - but I'm sure
that there will be developers that have enough knowledge to know
they are supposed to do something with errors on pmem devices, but
not have enough knowledge to know the correct things to do.

And then the app mishandles a EINVAL error (or something like that)
and so we end up with buggy userspace apps trying to correct
errors in good data and causing data loss that way.

Do we really want to introduce a data integrity and error recovery
model where this sort of "bug" is a distinct possibly?

> >> >> > There's an implicit assumption that applications will keep redundant
> >> >> > copies of their data at the /application layer/ and be able to
> >> >> > automatically repair it?
> >>
> >> That's one way to do things.  It really depends on the application what
> >> it will do for recovery.
> >>
> >> >> > And then there's the implicit assumption that it will unlink and
> >> >> > free the entire file before writing a new copy
> >>
> >> I think Vishal was referring to restoring from backup.  cp itself will
> >> truncate the file before overwriting, iirc.
> >
> > Which version of cp? what happens if they use --sparse and the error
> > is in a zeroed region? There's so many assumptions about undefined userspace
> > environment, application and user behaviour being made here, and
> > it's all being handwaved away.
> >
> > I'm asking for this to be defined, demonstrated and documented as a
> > working model that cannot be abused and doesn't have holes the size
> > of trucks in it, not handwaving...
> 
> You lost me...  how are these patches abusing the existing semantics
> of -EIO and write to clear?

I haven't said that. I said there are assumptions about how
userspace will handle the error, but they aren't documented
anywhere. "copy a file using cp" is not a robust recovery solution -
it provides no guarantees about how the bad file and regions will be
recycled and the errors cleared. This effectively of puts it all on
the filesystems to deal with, even though you're trying to design an
error handling model that bypasses the filesystems and goes straight
to userspace.

If I can't understand how this is all supposed to work
because none of it is documented, then we have no chance that the
average admin is going to be able to understand it.

> 
> >> >> To summarize, the two cases we want to handle are:
> >> >> 1. Application has inbuilt recovery:
> >> >>   - hits badblock
> >> >>   - figures out it is able to recover the data
> >> >>   - handles SIGBUS or EIO
> >> >>   - does a (sector aligned) write() to restore the data
> >> >
> >> > The "figures out" step here is where >95% of the work we'd have to
> >> > do is. And that's in filesystem and block layer code, not
> >> > userspace, and userspace can't do that work in a signal handler.
> >> > And it  can still fall down to the second case when the application
> >> > doesn't have another copy of the data somewhere.
> >>
> >> I read that "figures out" step as the application determining whether or
> >> not it had a redundant copy.
> >
> > Another undocumented assumption, that doesn't simplify what needs to
> > be done. Indeed, userspace can't do that until it is in SIGBUS
> > context, which tends to imply applications need to do a major amount
> > of work from within the signal handler....
> >
> >> > FWIW, we don't have a DAX enabled filesystem that can do
> >> > reverse block mapping, so we're a year or two away from this being a
> >> > workable production solution from the filesystem perspective. And
> >> > AFAICT, it's not even on the roadmap for dm/md layers.
> >>
> >> Do we even need that?  What if we added an FIEMAP flag for determining
> >> bad blocks.
> >
> > So you're assuming that the filesystem has been informed of the bad
> > blocks and has already marked the bad regions of the file in it's
> > extent list?
> >
> > How does that happen? What mechanism is used for the underlying
> > block device to inform the filesytem that theirs a bad LBA, and how
> > does the filesytem the map that to a path/file/offset with reverse
> > mapping? Or is there some other magic that hasn't been explained
> > happening here?
> 
> In 4.5 we added this:
> 
> commit 99e6608c9e7414ae4f2168df8bf8fae3eb49e41f
> Author: Vishal Verma <vishal.l.verma@intel.com>
> Date:   Sat Jan 9 08:36:51 2016 -0800
> 
>     block: Add badblock management for gendisks

Yes, I know, and it doesn't answer any of the questions I just
asked. What you just told me is that there is something that is kept
three levels of abstraction away from a filesystem. So:

	- What mechanism is to be used for the underlying block
	  device to inform the filesytem that a new bad block was
	  added to this list? What context comes along with that
	  notification?
	- how does the filesystem query the bad block list without
	  adding layering violations?
	- when does the filesystem need to query the bad block list?
	- how will the bad block list propagate through DM/MD
	  layers?
	- how does the filesytem the map the bad block to a
	  path/file/offset without reverse mapping - does this error
	  handling interface really imply the filesystem needs to
	  implement brute force scans at notification time?
	- Is the filesystem expectd to find the active application or
	  address_space access that triggered the bad block
	  notification to handle them correctly? (e.g. prevent a
	  page fault from failing because we can recover from the
	  error immediately)
	- what exactly is the filesystem supposed to do with the bad
	  block? e.g:
		- is the block persistently bad until the filesystem
		  rewrites it? Over power cycles? Will we get
		  multiple notifications (e.g. once per boot)?
		- Is the filesystem supposed to intercept
		  reads/writes to bad blocks once it knows about
		  them?
		- how is the filesystem supposed to communicate that
		  there is a bad block in a file back to userspace?
		  Or is userspace supposed to infer that there's a
		  bad block from EIO and so has to run FIEMAP to
		  determine if the error really was due to a bad
		  block?
		- what happens if there is no running application
		  that we can report the error to or will handle the
		  error (e.g. found error by a media scrub or during
		  boot)?
	- if the bad block is in filesystem free space, what should
	  the filesystem do with it?

What I'm failing to communicate is that having and maintaining
things like bad block lists in a block device is the easy part of
the problem.

Similarly reporting a bad block flag in FIEMAP is only a few
lines of code to implement, but that assumes the filesystem has
already propagated the bad block information into it's internal
extents lists.

That's the hard part of all this: connecting the two pieces together
in a sane, reliable, consistent and useful manner. This will form
the user API, so we need to sort it out before applications start to
use it. However, if I'm struggling to understand how I'm supposed to
connecct up the parts inside a filesytem, then expecting application
developers to be able to connect the dots in a sane manner is
bordering on fantasy....

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
