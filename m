Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4A5F56B0266
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 20:25:16 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id ce7-v6so22190202plb.22
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 17:25:16 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id d2-v6si18103168plo.210.2018.10.17.17.25.13
        for <linux-mm@kvack.org>;
        Wed, 17 Oct 2018 17:25:14 -0700 (PDT)
Date: Thu, 18 Oct 2018 11:25:10 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Message-ID: <20181018002510.GC6311@dastard>
References: <20181002100531.GC4135@quack2.suse.cz>
 <20181002121039.GA3274@linux-x5ow.site>
 <20181002142959.GD9127@quack2.suse.cz>
 <x49h8hkfhk9.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49h8hkfhk9.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Jan Kara <jack@suse.cz>, Johannes Thumshirn <jthumshirn@suse.de>, Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org

On Wed, Oct 17, 2018 at 04:23:50PM -0400, Jeff Moyer wrote:
> Jan Kara <jack@suse.cz> writes:
> 
> > [Added ext4, xfs, and linux-api folks to CC for the interface discussion]
> >
> > On Tue 02-10-18 14:10:39, Johannes Thumshirn wrote:
> >> On Tue, Oct 02, 2018 at 12:05:31PM +0200, Jan Kara wrote:
> >> > Hello,
> >> > 
> >> > commit e1fb4a086495 "dax: remove VM_MIXEDMAP for fsdax and device dax" has
> >> > removed VM_MIXEDMAP flag from DAX VMAs. Now our testing shows that in the
> >> > mean time certain customer of ours started poking into /proc/<pid>/smaps
> >> > and looks at VMA flags there and if VM_MIXEDMAP is missing among the VMA
> >> > flags, the application just fails to start complaining that DAX support is
> >> > missing in the kernel. The question now is how do we go about this?
> >> 
> >> OK naive question from me, how do we want an application to be able to
> >> check if it is running on a DAX mapping?
> >
> > The question from me is: Should application really care? After all DAX is
> > just a caching decision. Sure it affects performance characteristics and
> > memory usage of the kernel but it is not a correctness issue (in particular
> > we took care for MAP_SYNC to return EOPNOTSUPP if the feature cannot be
> > supported for current mapping). And in the future the details of what we do
> > with DAX mapping can change - e.g. I could imagine we might decide to cache
> > writes in DRAM but do direct PMEM access on reads. And all this could be
> > auto-tuned based on media properties. And we don't want to tie our hands by
> > specifying too narrowly how the kernel is going to behave.
> 
> For read and write, I would expect the O_DIRECT open flag to still work,
> even for dax-capable persistent memory.  Is that a contentious opinion?

Not contentious at all, because that's the way it currently works.
FYI, XFS decides what to do with read (and similarly writes) like
this:

        if (IS_DAX(inode))
                ret = xfs_file_dax_read(iocb, to);
        else if (iocb->ki_flags & IOCB_DIRECT)
                ret = xfs_file_dio_aio_read(iocb, to);
        else
                ret = xfs_file_buffered_aio_read(iocb, to);

Neither DAX or O_DIRECT on pmem use the page cache - the only difference
between the DAX read/write path and the O_DIRECT read/write path
is where the memcpy() into the user buffer is done. For DAX
it's done in the fsdax layer, for O_DIRECT it's done in the pmem
block driver.

> So, what we're really discussing is the behavior for mmap.

Yes.

> MAP_SYNC
> will certainly ensure that the page cache is not used for writes.  It
> would also be odd for us to decide to cache reads.  The only issue I can
> see is that perhaps the application doesn't want to take a performance
> hit on write faults.  I haven't heard that concern expressed in this
> thread, though.
> 
> Just to be clear, this is my understanding of the world:
> 
> MAP_SYNC
> - file system guarantees that metadata required to reach faulted-in file
>   data is consistent on media before a write fault is completed.  A
>   side-effect is that the page cache will not be used for
>   writably-mapped pages.

I think you are conflating current implementation with API
requirements - MAP_SYNC doesn't guarantee anything about page cache
use. The man page definition simply says "supported only for files
supporting DAX" and that it provides certain data integrity
guarantees. It does not define the implementation.

We've /implemented MAP_SYNC/ as O_DSYNC page fault behaviour,
because that's the only way we can currently provide the required
behaviour to userspace. However, if a filesystem can use the page
cache to provide the required functionality, then it's free to do
so.

i.e. if someone implements a pmem-based page cache, MAP_SYNC data
integrity could be provided /without DAX/ by any filesystem using
that persistent page cache. i.e. MAP_SYNC really only requires
mmap() of CPU addressable persistent memory - it does not require
DAX. Right now, however, the only way to get this functionality is
through a DAX capable filesystem on dax capable storage.

And, FWIW, this is pretty much how NOVA maintains DAX w/ COW - it
COWs new pages in pmem and attaches them a special per-inode cache
on clean->dirty transition. Then on data sync, background writeback
or crash recovery, it migrates them from the cache into the file map
proper via atomic metadata pointer swaps.

IOWs, NOVA provides the correct MAP_SYNC semantics by using a
separate persistent per-inode write cache to provide the correct
crash recovery semantics for MAP_SYNC.

> and what I think Dan had proposed:
> 
> mmap flag, MAP_DIRECT
> - file system guarantees that page cache will not be used to front storage.
>   storage MUST be directly addressable.  This *almost* implies MAP_SYNC.
>   The subtle difference is that a write fault /may/ not result in metadata
>   being written back to media.

SIimilar to O_DIRECT, these semantics do not allow userspace apps to
replace msync/fsync with CPU cache flush operations. So any
application that uses this mode still needs to use either MAP_SYNC
or issue msync/fsync for data integrity.

If the app is using MAP_DIRECT, the what do we do if the filesystem
can't provide the required semantics for that specific operation? In
the case of O_DIRECT, we fall back to buffered IO because it has the
same data integrity semantics as O_DIRECT and will always work. It's
just slower and consumes more memory, but the app continues to work
just fine.

Sending SIGBUS to apps when we can't perform MAP_DIRECT operations
without using the pagecache seems extremely problematic to me.  e.g.
an app already has an open MAP_DIRECT file, and a third party
reflinks it or dedupes it and the fs has to fall back to buffered IO
to do COW operations. This isn't the app's fault - the kernel should
just fall back transparently to using the page cache for the
MAP_DIRECT app and just keep working, just like it would if it was
using O_DIRECT read/write.

The point I'm trying to make here is that O_DIRECT is a /hint/, not
a guarantee, and it's done that way to prevent applications from
being presented with transient, potentially fatal error cases
because a filesystem implementation can't do a specific operation
through the direct IO path.

IMO, MAP_DIRECT needs to be a hint like O_DIRECT and not a
guarantee. Over time we'll end up with filesystems that can
guarantee that MAP_DIRECT is always going to use DAX, in the same
way we have filesystems that guarantee O_DIRECT will always be
O_DIRECT (e.g. XFS). But if we decide that MAP_DIRECT must guarantee
no page cache will ever be used, then we are basically saying
"filesystems won't provide MAP_DIRECT even in common, useful cases
because they can't provide MAP_DIRECT in all cases." And that
doesn't seem like a very good solution to me.

> and this is what I think you were proposing, Jan:
> 
> madvise flag, MADV_DIRECT_ACCESS
> - same semantics as MAP_DIRECT, but specified via the madvise system call

Seems to be the equivalent of fcntl(F_SETFL, O_DIRECT). Makes sense
to have both MAP_DIRECT and MADV_DIRECT_ACCESS to me - one is an
init time flag, the other is a run time flag.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
