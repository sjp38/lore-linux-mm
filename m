Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0CE3D6B028D
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 18:49:10 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 127-v6so10096033pgb.7
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 15:49:10 -0700 (PDT)
Received: from ipmail01.adl2.internode.on.net (ipmail01.adl2.internode.on.net. [150.101.137.133])
        by mx.google.com with ESMTP id h184-v6si24329653pfe.72.2018.10.30.15.49.07
        for <linux-mm@kvack.org>;
        Tue, 30 Oct 2018 15:49:08 -0700 (PDT)
Date: Wed, 31 Oct 2018 09:49:04 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Message-ID: <20181030224904.GT19305@dastard>
References: <20181002100531.GC4135@quack2.suse.cz>
 <20181002121039.GA3274@linux-x5ow.site>
 <20181002142959.GD9127@quack2.suse.cz>
 <x49h8hkfhk9.fsf@segfault.boston.devel.redhat.com>
 <20181018002510.GC6311@dastard>
 <20181018145555.GS23493@quack2.suse.cz>
 <20181019004303.GI6311@dastard>
 <CAPcyv4ixoAh7HEMfm+B4sRDx1Qwm6SHGjtQ+5r3EKsxreRydrA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4ixoAh7HEMfm+B4sRDx1Qwm6SHGjtQ+5r3EKsxreRydrA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, jmoyer <jmoyer@redhat.com>, Johannes Thumshirn <jthumshirn@suse.de>, Dave Jiang <dave.jiang@intel.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Mon, Oct 29, 2018 at 11:30:41PM -0700, Dan Williams wrote:
> On Thu, Oct 18, 2018 at 5:58 PM Dave Chinner <david@fromorbit.com> wrote:
> > On Thu, Oct 18, 2018 at 04:55:55PM +0200, Jan Kara wrote:
> > > On Thu 18-10-18 11:25:10, Dave Chinner wrote:
> > > > On Wed, Oct 17, 2018 at 04:23:50PM -0400, Jeff Moyer wrote:
> > > > > MAP_SYNC
> > > > > - file system guarantees that metadata required to reach faulted-in file
> > > > >   data is consistent on media before a write fault is completed.  A
> > > > >   side-effect is that the page cache will not be used for
> > > > >   writably-mapped pages.
> > > >
> > > > I think you are conflating current implementation with API
> > > > requirements - MAP_SYNC doesn't guarantee anything about page cache
> > > > use. The man page definition simply says "supported only for files
> > > > supporting DAX" and that it provides certain data integrity
> > > > guarantees. It does not define the implementation.
....
> > > With O_DIRECT the fallback to buffered IO is quite rare (at least for major
> > > filesystems) so usually people just won't notice. If fallback for
> > > MAP_DIRECT will be easy to hit, I'm not sure it would be very useful.
> >
> > Which is just like the situation where O_DIRECT on ext3 was not very
> > useful, but on other filesystems like XFS it was fully functional.
> >
> > IMO, the fact that a specific filesytem has a suboptimal fallback
> > path for an uncommon behaviour isn't an argument against MAP_DIRECT
> > as a hint - it's actually a feature. If MAP_DIRECT can't be used
> > until it's always direct access, then most filesystems wouldn't be
> > able to provide any faster paths at all. It's much better to have
> > partial functionality now than it is to never have the functionality
> > at all, and so we need to design in the flexibility we need to
> > iteratively improve implementations without needing API changes that
> > will break applications.
> 
> The hard guarantee requirement still remains though because an
> application that expects combined MAP_SYNC|MAP_DIRECT semantics will
> be surprised if the MAP_DIRECT property silently disappears.

Why would they be surprised? They won't even notice it if the
filesystem can provide MAP_SYNC without MAP_DIRECT.

And that's the whole point.

MAP_DIRECT is a private mapping state. So is MAP_SYNC. They are not
visible to the filesystem and the filesystem does nothing to enforce
them. If someone does something that requires the page cache (e.g.
calls do_splice_direct()) then that MAP_DIRECT mapping has a whole
heap of new work to do. And, in some cases, the filesystem may not
be able to provide MAP_DIRECT as a result..

IOWs, the filesystem cannot guarantee MAP_DIRECT and the
circumstances under which MAP_DIRECT will and will not work are
dynamic. If MAP_DIRECT is supposed to be a guarantee then we'll have
applications randomly segfaulting in production as things like
backups, indexers, etc run over the filesystem and do their work.

This is why MAP_DIRECT needs to be an optimisation, not a
requirement - things will still work if MAP_DIRECT is not used. What
matters to these applications is MAP_SYNC - if we break MAP_SYNC,
then the application data integrity model is violated. That's not an
acceptible outcome.

The problem, it seems to me, is that people are unable to separate
MAP_DIRECT and MAP_SYNC. I suspect that is because, at present,
MAP_SYNC on XFS and ext4 requires MAP_DIRECT. i.e. we can only
provide MAP_SYNC functionality on DAX mappings. However, that's a
/filesystem implementation issue/, not an API guarantee we need to
provide to userspace.

If we implement a persistent page cache (e.g. allocate page cache
pages out of ZONE_DEVICE pmem), then filesystems like XFS and ext4
could provide applications with the MAP_SYNC data integrity model
without MAP_DIRECT. Indeed, those filesystems would not even be able
to provide MAP_DIRECT semantics because they aren't backed by pmem.

Hence if applications that want MAP_SYNC are hard coded
MAP_SYNC|MAP_DIRECT and we make MAP_DIRECT a hard guarantee, then
those applications are going to fail on a filesystem that provides
only MAP_SYNC. This is despite the fact the applications would
function correctly and the data integrity model would be maintained.
i.e. the failure is because applications have assumed MAP_SYNC can
only be provided by a DAX implementation, not because MAP_SYNC is
not supported.

MAP_SYNC really isn't about DAX at all. It's about enabling a data
integrity model that requires the filesystem to provide userspace
access to CPU addressable persistent memory.  DAX+MAP_DIRECT is just
one method of providing this functionality, but it's not the only
method. Our API needs to be future proof rather than an encoding of
the existing implementation limitations, otherwise apps will have to
be re-written as every new MAP_SYNC capable technology comes along.

In summary:

	MAP_DIRECT is an access hint.

	MAP_SYNC provides a data integrity model guarantee.

	MAP_SYNC may imply MAP_DIRECT for specific implementations,
	but it does not require or guarantee MAP_DIRECT.

Let's compare that with O_DIRECT:

	O_DIRECT in an access hint.

	O_DSYNC provides a data integrity model guarantee.

	O_DSYNC may imply O_DIRECT for specific implementations, but
	it does not require or guarantee O_DIRECT.

Consistency in access and data integrity models is a good thing. DAX
and pmem is not an exception. We need to use a model we know works
and has proven itself over a long period of time.

> I think
> it still makes some sense as a hint for apps that want to minimize
> page cache, but for the applications with a flush from userspace model
> I think that wants to be an F_SETLEASE / F_DIRECTLCK operation. This
> still gives the filesystem the option to inject page-cache at will,
> but with an application coordination point.

Why make it more complex for applications than it needs to be? 

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
