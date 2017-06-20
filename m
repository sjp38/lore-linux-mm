Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B046A6B0292
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 21:14:28 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q78so116192284pfj.9
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 18:14:28 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id s61si10428700plb.32.2017.06.19.18.14.21
        for <linux-mm@kvack.org>;
        Mon, 19 Jun 2017 18:14:24 -0700 (PDT)
Date: Tue, 20 Jun 2017 10:46:53 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC PATCH 2/2] mm, fs: daxfile, an interface for
 byte-addressable updates to pmem
Message-ID: <20170620004653.GI17542@dastard>
References: <149766212410.22552.15957843500156182524.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149766213493.22552.4057048843646200083.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CALCETrU1Hg=q4cdQDex--3nVBfwRC1o=9pC6Ss77Z8Lxg7ZJLg@mail.gmail.com>
 <CAPcyv4j4UEegViDJcLZjVv5AFGC18-DcvHFnhZatB0hH3BY85g@mail.gmail.com>
 <CALCETrUfv26pvmyQ1gOkKbzfSXK2DnmeBG6VmSWjFy1WBhknTw@mail.gmail.com>
 <CAPcyv4iPb69e+rE3fJUzm9U_P_dLfhantU9mvYmV-R0oQee4rA@mail.gmail.com>
 <CALCETrVY38h2ajpod2U_2pdHSp8zO4mG2p19h=OnnHmhGTairw@mail.gmail.com>
 <20170619132107.GG11993@dastard>
 <CALCETrUe0igzK0RZTSSondkCY3ApYQti89tOh00f0j_APrf_dQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUe0igzK0RZTSSondkCY3ApYQti89tOh00f0j_APrf_dQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, andy.rudoff@intel.com, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>

On Mon, Jun 19, 2017 at 08:22:10AM -0700, Andy Lutomirski wrote:
> On Mon, Jun 19, 2017 at 6:21 AM, Dave Chinner <david@fromorbit.com> wrote:
> > On Sat, Jun 17, 2017 at 10:05:45PM -0700, Andy Lutomirski wrote:
> >> On Sat, Jun 17, 2017 at 8:15 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> >> > On Sat, Jun 17, 2017 at 4:50 PM, Andy Lutomirski <luto@kernel.org> wrote:
> >> >> My other objection is that the syscall intentionally leaks a reference
> >> >> to the file.  This means it needs overflow protection and it probably
> >> >> shouldn't ever be allowed to use it without privilege.
> >> >
> >> > We only hold the one reference while S_DAXFILE is set, so I think the
> >> > protection is there, and per Dave's original proposal this requires
> >> > CAP_LINUX_IMMUTABLE.
> >> >
> >> >> Why can't the underlying issue be easily fixed, though?  Could
> >> >> .page_mkwrite just make sure that metadata is synced when the FS uses
> >> >> DAX?
> >> >
> >> > Yes, it most definitely could and that idea has been floated.
> >> >
> >> >> On a DAX fs, syncing metadata should be extremely fast.
> >
> > <sigh>
> >
> > This again....
> >
> > Persistent memory means the *I/O* is fast. It does not mean that
> > *complex filesystem operations* are fast.
> >
> > Don't forget that there's an shitload of CPU that gets burnt to make
> > sure that the metadata is synced correctly. Do that /synchronously/
> > on *every* write page fault (which, BTW, modify mtime, so will
> > always have dirty metadata to sync) and now you have a serious
> > performance problem with your "fast" DAX access method.
> 
> I think the mtime issue can and should be solved separately.  But it'
> s a fair point that there would be workloads for which this could be
> excessively expensive.  In particular, simply creating a file,
> mmapping a large range, and touching the pages one by one -- delalloc
> would be completely defeated.
> 
> But here's a strawman for solving both issues.  First, mtime.  I
> consider it to be either a bug or a misfeature that .page_mkwrite
> *ever* dirties an inode just to update mtime.  I have old patches to
> fix this, and those patches could be updated and merged.  With them
> applied, there's just a set_bit() in .page_mkwrite() to handle mtime.
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/luto/linux.git/log/?h=mmap_mtime/patch_v4

Yup, I remember that - it delays the update to data writeback time,
IOWs the proposed MAP_SYNC page fault semantics result in the same
(poor) behaviour because the sync operation will trigger mtime
updates instead of the page fault.

Unless, of course, you are implying that MAP_SYNC should not
actually sync all known dirty metadata on an inode.

<smacks head on desk>

> Second: syncing extents.  Here's a straw man.  Forget the mmap() flag.
> Instead add a new msync() operation:
> 
> msync(start, length, MSYNC_PMEM_PREPARE_WRITE);

How's this any different from the fallocate command I proposed to do
this (apart from the fact that msync() is not intended to be abused
as a file preallocation/zeroing interface)?

> If this operation succeeds, it guarantees that all future writes
> through this mapping on this range will hit actual storage and that
> all the metadata operations needed to make this write persistent will
> hit storage such that they are ordered before the user's writes.
> As an implementation detail, this will flush out the extents if
> needed.  In addition, if the FS has any mechanism that would cause
> problems asyncronously later on (dedupe?  deallocated extents full
> of zeros?  defrag?),

Hole punch, truncate, reflink, dedupe, snapshots, scrubbing and
other background filesystem maintenance operations, etc can all
change the extent layout asynchronously if there's no mechanism to
tell the fs not to modify the inode extent layout.

> it may also need to set a flag on the VMA
> that changes the behavior of future .page_mkwrite operations.
> 
> (On x86, for example, this would permit the FS to do WC/streaming
> writes without SFENCE if the FS were structured in a way that this
> worked.)
> 
> Now we have an API that should work going forward without
> introducing baggage.  And XFS is free to implement this API by
> making the entire file act like a swap file if XFS wants to do so,
> but this doesn't force other filesystems (ext4? NOVA?) to do the
> same thing.

Sure, you are providing a simple programmatic API, but this does not
provide a viable feature management strategy.

i.e. the API you are now proposing requires the filesystem to ensure
an inode's extent map cannot be modified ever again in the future
(that "guarantees all future writes" bit).  This requires, at
minimum, a persistent flag to be set on the inode so the VFS and
filesystem implementations can use it to prevent anything that, for
example, relies on copy-on-write semantics being done on those
files. That means the proposed msync operation will need to check
the filesystem can support this feature and *fail* if it can't.

Further, administrators need to be aware of this application
requirement so they can plan their backup and disaster recovery
operations appropriately (e.g. reflink and/or snapshots cannot be
used as part of thei backup strategy). Hence the point of such
restricted file manipulation functionality requiring permissions to
be granted - it ensures sysadmins know they've got something less
than obvious going on they may need special processes to handle
safely.

Unsurprisingly, this is exactly what the "DAX immutable" inode flag
I proposed provides.  It provides an explicit, standardised and
*documented* management strategy that is common across all
filesystems. It uses mechanisms that *already exist*, the VFS and
filesystems already implement, and adminstrators are familiar with
using to manage their systems (e.g. setting the "NODUMP" inode flag
to exclude files from backups). This also avoids the management
level fragmentation which would occur if filesystems each solve the
"DAX userspace data sync" problem differently via different
management tools, behaviours and semantics.

Keep in mind that there are more uses for immutable extent maps than
just DAX. e.g. every so often someone pops up and says "I have this
high speed data aquisition hardware and we'd like to DMA data direct
to the storage because it's far too slow pushing it through memory
and then the OS to get it to storage. How do I map the storage
blocks and guarantee the mapping won't change while we are
transferring data direct from the hardware?". A file with an
allocated, immutable extent map solves this problem for these sorts
of esoteric applications.

As such, can we please drop all the mmap/msync special API snowflake
proposals and instead address the problem how to set up and manage
files with immutable extent maps efficiently through fallocate?
Once we have them, pmem aware applications don't need to do anything
special with mmap to be able to use userspace data sync instructions
safely.  i.e. the pmem library should select the correct data sync
method according to how the file was set up and what functionality
the underlying filesystem DAX implementation supports.

> >> Dave, even with the lock ordering issue, couldn't XFS implement
> >> MAP_PMEM_AWARE by having .page_mkwrite work roughly like this:
> >>
> >> if (metadata is dirty) { up_write(&mmap_sem); sync the
> >> metadata; down_write(&mmap_sem); return 0;  /* retry the fault
> >> */ } else { return whatever success code; }
> >
> > How do you know that there is dependent filesystem metadata that
> > needs syncing at a level that you can safely manipulate the
> > mmap_sem? And how, exactly, do you do this without races?
> 
> I have no idea, but I expect that all the locking issues are
> solvable.

Yay, Dunning-Kruger to the rescue!

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
