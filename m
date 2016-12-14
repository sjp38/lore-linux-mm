Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 85B276B0038
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 19:29:30 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id g186so9136020pgc.2
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 16:29:30 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id l14si25825748pfg.13.2016.12.13.16.29.28
        for <linux-mm@kvack.org>;
        Tue, 13 Dec 2016 16:29:29 -0800 (PST)
Date: Wed, 14 Dec 2016 11:14:22 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [LSF/MM TOPIC] Un-addressable device memory and block/fs
 implications
Message-ID: <20161214001422.GE4326@dastard>
References: <20161213181511.GB2305@redhat.com>
 <20161213201515.GB4326@dastard>
 <20161213203112.GE2305@redhat.com>
 <20161213211041.GC4326@dastard>
 <20161213212433.GF2305@redhat.com>
 <20161213221322.GD4326@dastard>
 <20161213225523.GG2305@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161213225523.GG2305@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Tue, Dec 13, 2016 at 05:55:24PM -0500, Jerome Glisse wrote:
> On Wed, Dec 14, 2016 at 09:13:22AM +1100, Dave Chinner wrote:
> > On Tue, Dec 13, 2016 at 04:24:33PM -0500, Jerome Glisse wrote:
> > > On Wed, Dec 14, 2016 at 08:10:41AM +1100, Dave Chinner wrote:
> > > > > From kernel point of view such memory is almost like any other, it
> > > > > has a struct page and most of the mm code is non the wiser, nor need
> > > > > to be about it. CPU access trigger a migration back to regular CPU
> > > > > accessible page.
> > > > 
> > > > That sounds ... complex. Page migration on page cache access inside
> > > > the filesytem IO path locking during read()/write() sounds like
> > > > a great way to cause deadlocks....
> > > 
> > > There are few restriction on device page, no one can do GUP on them and
> > > thus no one can pin them. Hence they can always be migrated back. Yes
> > > each fs need modification, most of it (if not all) is isolated in common
> > > filemap helpers.
> > 
> > Sure, but you haven't answered my question: how do you propose we
> > address the issue of placing all the mm locks required for migration
> > under the filesystem IO path locks?
> 
> Two different plans (which are non exclusive of each other). First is to use
> workqueue and have read/write wait on the workqueue to be done migrating the
> page back.

Pushing something to a workqueue and then waiting on the workqueue
to complete the work doesn't change lock ordering problems - it
just hides them away and makes them harder to debug.

> Second solution is to use a bounce page during I/O so that there is no need
> for migration.

Which means the page in the device is left with out-of-date
contents, right?

If so, how do you prevent data corruption/loss when the device
has modified the page out of sight of the CPU and the bounce page
doesn't contain those modifications? Or if the dirty device page is
written back directly without containing the changes made in the
bounce page?

Hmmm - what happens when we invalidate and release a range of
file pages that have been migrated to a device? e.g. on truncate?

> > > > > But for thing like writeback i want to be able to do writeback with-
> > > > > out having to migrate page back first. So that data can stay on the
> > > > > device while writeback is happening.
> > > > 
> > > > Why can't you do writeback before migration, so only clean pages get
> > > > moved?
> > > 
> > > Because device can write to the page while the page is inside the device
> > > memory and we might want to writeback to disk while page stays in device
> > > memory and computation continues.
> > 
> > Ok. So how does the device trigger ->page_mkwrite on a clean page to
> > tell the filesystem that the page has been dirtied? So that, for
> > example, if the page covers a hole because the file is sparse the
> > filesytem can do the required block allocation and data
> > initialisation (i.e. zero the cached page) before it gets marked
> > dirty and any data gets written to it?
> > 
> > And if zeroing the page during such a fault requires CPU access to
> > the data, how do you propose we handle page migration in the middle
> > of the page fault to allow the CPU to zero the page? Seems like more
> > lock order/inversion problems there, too...
> 
> File back page are never allocated on device, at least we have no incentive
> for usecase we care about today to do so. So a regular page is first use
> and initialize (to zero for hole) before being migrated to device.
> So i do not believe there should be any major concern on ->page_mkwrite.

Such deja vu - inodes are not static objects as modern filesystems
are highly dynamic. If you want to have safe, reliable non-coherent
mmap-based file data offload to devices, then I suspect that we're
going to need pretty much all of the same restrictions the pmem
programming model requires for userspace data flushing. i.e.:

https://lkml.org/lkml/2016/9/15/33

At which point I have to ask: why is mmap considered to be the right
model for transfering data in and out of devices that are not
directly CPU addressable? 

> At least
> this was my impression when i look at generic filemap one, but for some
> filesystem this might need be problematic.

Definitely problematic for XFS, btrfs, f2fs, ocfs2, and probably
ext4 and others as well.

> and allowing control by userspace to block such
> migration for given fs.

How do you propose doing that?

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
