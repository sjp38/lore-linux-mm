Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 608386B0007
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 10:55:58 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b34-v6so18760257ede.5
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 07:55:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b4-v6si11160616edi.60.2018.10.18.07.55.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 07:55:56 -0700 (PDT)
Date: Thu, 18 Oct 2018 16:55:55 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Message-ID: <20181018145555.GS23493@quack2.suse.cz>
References: <20181002100531.GC4135@quack2.suse.cz>
 <20181002121039.GA3274@linux-x5ow.site>
 <20181002142959.GD9127@quack2.suse.cz>
 <x49h8hkfhk9.fsf@segfault.boston.devel.redhat.com>
 <20181018002510.GC6311@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018002510.GC6311@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, Jan Kara <jack@suse.cz>, Johannes Thumshirn <jthumshirn@suse.de>, Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org

On Thu 18-10-18 11:25:10, Dave Chinner wrote:
> On Wed, Oct 17, 2018 at 04:23:50PM -0400, Jeff Moyer wrote:
> > MAP_SYNC
> > - file system guarantees that metadata required to reach faulted-in file
> >   data is consistent on media before a write fault is completed.  A
> >   side-effect is that the page cache will not be used for
> >   writably-mapped pages.
> 
> I think you are conflating current implementation with API
> requirements - MAP_SYNC doesn't guarantee anything about page cache
> use. The man page definition simply says "supported only for files
> supporting DAX" and that it provides certain data integrity
> guarantees. It does not define the implementation.
> 
> We've /implemented MAP_SYNC/ as O_DSYNC page fault behaviour,
> because that's the only way we can currently provide the required
> behaviour to userspace. However, if a filesystem can use the page
> cache to provide the required functionality, then it's free to do
> so.
> 
> i.e. if someone implements a pmem-based page cache, MAP_SYNC data
> integrity could be provided /without DAX/ by any filesystem using
> that persistent page cache. i.e. MAP_SYNC really only requires
> mmap() of CPU addressable persistent memory - it does not require
> DAX. Right now, however, the only way to get this functionality is
> through a DAX capable filesystem on dax capable storage.
> 
> And, FWIW, this is pretty much how NOVA maintains DAX w/ COW - it
> COWs new pages in pmem and attaches them a special per-inode cache
> on clean->dirty transition. Then on data sync, background writeback
> or crash recovery, it migrates them from the cache into the file map
> proper via atomic metadata pointer swaps.
> 
> IOWs, NOVA provides the correct MAP_SYNC semantics by using a
> separate persistent per-inode write cache to provide the correct
> crash recovery semantics for MAP_SYNC.

Corect. NOVA would be able to provide MAP_SYNC semantics without DAX. But
effectively it will be also able to provide MAP_DIRECT semantics, right?
Because there won't be DRAM between app and persistent storage and I don't
think COW tricks or other data integrity methods are that interesting for
the application. Most users of O_DIRECT are concerned about getting close
to media speed performance and low DRAM usage...

> > and what I think Dan had proposed:
> > 
> > mmap flag, MAP_DIRECT
> > - file system guarantees that page cache will not be used to front storage.
> >   storage MUST be directly addressable.  This *almost* implies MAP_SYNC.
> >   The subtle difference is that a write fault /may/ not result in metadata
> >   being written back to media.
> 
> SIimilar to O_DIRECT, these semantics do not allow userspace apps to
> replace msync/fsync with CPU cache flush operations. So any
> application that uses this mode still needs to use either MAP_SYNC
> or issue msync/fsync for data integrity.
> 
> If the app is using MAP_DIRECT, the what do we do if the filesystem
> can't provide the required semantics for that specific operation? In
> the case of O_DIRECT, we fall back to buffered IO because it has the
> same data integrity semantics as O_DIRECT and will always work. It's
> just slower and consumes more memory, but the app continues to work
> just fine.
> 
> Sending SIGBUS to apps when we can't perform MAP_DIRECT operations
> without using the pagecache seems extremely problematic to me.  e.g.
> an app already has an open MAP_DIRECT file, and a third party
> reflinks it or dedupes it and the fs has to fall back to buffered IO
> to do COW operations. This isn't the app's fault - the kernel should
> just fall back transparently to using the page cache for the
> MAP_DIRECT app and just keep working, just like it would if it was
> using O_DIRECT read/write.

There's another option of failing reflink / dedupe with EBUSY if the file
is mapped with MAP_DIRECT and the filesystem cannot support relink &
MAP_DIRECT together. But there are downsides to that as well.

> The point I'm trying to make here is that O_DIRECT is a /hint/, not
> a guarantee, and it's done that way to prevent applications from
> being presented with transient, potentially fatal error cases
> because a filesystem implementation can't do a specific operation
> through the direct IO path.
> 
> IMO, MAP_DIRECT needs to be a hint like O_DIRECT and not a
> guarantee. Over time we'll end up with filesystems that can
> guarantee that MAP_DIRECT is always going to use DAX, in the same
> way we have filesystems that guarantee O_DIRECT will always be
> O_DIRECT (e.g. XFS). But if we decide that MAP_DIRECT must guarantee
> no page cache will ever be used, then we are basically saying
> "filesystems won't provide MAP_DIRECT even in common, useful cases
> because they can't provide MAP_DIRECT in all cases." And that
> doesn't seem like a very good solution to me.

These are good points. I'm just somewhat wary of the situation where users
will map files with MAP_DIRECT and then the machine starts thrashing
because the file got reflinked and thus pagecache gets used suddently.
With O_DIRECT the fallback to buffered IO is quite rare (at least for major
filesystems) so usually people just won't notice. If fallback for
MAP_DIRECT will be easy to hit, I'm not sure it would be very useful.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
