Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 93F836B0038
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 20:08:02 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id h67so6116175vkf.4
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 17:08:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j129si14386283vkg.175.2016.12.13.17.08.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 17:08:01 -0800 (PST)
Date: Tue, 13 Dec 2016 20:07:58 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [LSF/MM TOPIC] Un-addressable device memory and block/fs
 implications
Message-ID: <20161214010755.GA2182@redhat.com>
References: <20161213181511.GB2305@redhat.com>
 <20161213201515.GB4326@dastard>
 <20161213203112.GE2305@redhat.com>
 <20161213211041.GC4326@dastard>
 <20161213212433.GF2305@redhat.com>
 <20161213221322.GD4326@dastard>
 <20161213225523.GG2305@redhat.com>
 <20161214001422.GE4326@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20161214001422.GE4326@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Wed, Dec 14, 2016 at 11:14:22AM +1100, Dave Chinner wrote:
> On Tue, Dec 13, 2016 at 05:55:24PM -0500, Jerome Glisse wrote:
> > On Wed, Dec 14, 2016 at 09:13:22AM +1100, Dave Chinner wrote:
> > > On Tue, Dec 13, 2016 at 04:24:33PM -0500, Jerome Glisse wrote:
> > > > On Wed, Dec 14, 2016 at 08:10:41AM +1100, Dave Chinner wrote:
> > > > > > From kernel point of view such memory is almost like any other, it
> > > > > > has a struct page and most of the mm code is non the wiser, nor need
> > > > > > to be about it. CPU access trigger a migration back to regular CPU
> > > > > > accessible page.
> > > > > 
> > > > > That sounds ... complex. Page migration on page cache access inside
> > > > > the filesytem IO path locking during read()/write() sounds like
> > > > > a great way to cause deadlocks....
> > > > 
> > > > There are few restriction on device page, no one can do GUP on them and
> > > > thus no one can pin them. Hence they can always be migrated back. Yes
> > > > each fs need modification, most of it (if not all) is isolated in common
> > > > filemap helpers.
> > > 
> > > Sure, but you haven't answered my question: how do you propose we
> > > address the issue of placing all the mm locks required for migration
> > > under the filesystem IO path locks?
> > 
> > Two different plans (which are non exclusive of each other). First is to use
> > workqueue and have read/write wait on the workqueue to be done migrating the
> > page back.
> 
> Pushing something to a workqueue and then waiting on the workqueue
> to complete the work doesn't change lock ordering problems - it
> just hides them away and makes them harder to debug.

Migration doesn't need many lock below is a list and i don't see any lock issue
in respect to ->read or ->write.

 lock_page(page);
 spin_lock_irq(&mapping->tree_lock);
 lock_buffer(bh); // if page has buffer_head
 i_mmap_lock_read(mapping);
 vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
    // page table lock for each entry
 }

I don't think i miss any and thus i don't see any real issues here. Care to point
to the lock you think is gona be problematic ?


> > Second solution is to use a bounce page during I/O so that there is no need
> > for migration.
> 
> Which means the page in the device is left with out-of-date
> contents, right?
>
> If so, how do you prevent data corruption/loss when the device
> has modified the page out of sight of the CPU and the bounce page
> doesn't contain those modifications? Or if the dirty device page is
> written back directly without containing the changes made in the
> bounce page?

There is no issue here, if bounce page is use then the page is mark as read
only on the device until write is done and device copy is updated with what
we have been ask to write. So no coherency issue between the 2 copy.

> 
> Hmmm - what happens when we invalidate and release a range of
> file pages that have been migrated to a device? e.g. on truncate?

Same as if it where regular memory, access by device trigger SIGBUS which is
reported through the device API. On that respect it follows the exact same
code path as regular page.

> > > > > > But for thing like writeback i want to be able to do writeback with-
> > > > > > out having to migrate page back first. So that data can stay on the
> > > > > > device while writeback is happening.
> > > > > 
> > > > > Why can't you do writeback before migration, so only clean pages get
> > > > > moved?
> > > > 
> > > > Because device can write to the page while the page is inside the device
> > > > memory and we might want to writeback to disk while page stays in device
> > > > memory and computation continues.
> > > 
> > > Ok. So how does the device trigger ->page_mkwrite on a clean page to
> > > tell the filesystem that the page has been dirtied? So that, for
> > > example, if the page covers a hole because the file is sparse the
> > > filesytem can do the required block allocation and data
> > > initialisation (i.e. zero the cached page) before it gets marked
> > > dirty and any data gets written to it?
> > > 
> > > And if zeroing the page during such a fault requires CPU access to
> > > the data, how do you propose we handle page migration in the middle
> > > of the page fault to allow the CPU to zero the page? Seems like more
> > > lock order/inversion problems there, too...
> > 
> > File back page are never allocated on device, at least we have no incentive
> > for usecase we care about today to do so. So a regular page is first use
> > and initialize (to zero for hole) before being migrated to device.
> > So i do not believe there should be any major concern on ->page_mkwrite.
> 
> Such deja vu - inodes are not static objects as modern filesystems
> are highly dynamic. If you want to have safe, reliable non-coherent
> mmap-based file data offload to devices, then I suspect that we're
> going to need pretty much all of the same restrictions the pmem
> programming model requires for userspace data flushing. i.e.:
> 
> https://lkml.org/lkml/2016/9/15/33

I don't see any of the issues in that email applying to my case. Like i said
from fs/mm point of view my page are _exactly_ like regular page. Only thing
is no CPU access. So what would have happen to regular page would happen to
device page. There is no differences here whatsoever.


> 
> At which point I have to ask: why is mmap considered to be the right
> model for transfering data in and out of devices that are not
> directly CPU addressable? 

That is where the industry is going, OpenCL 2.0/3.0, C++ concurrency and
parallelism, OpenACC, OpenMP, HSA, Cuda ... all those API require unified
address space and transparent use of device memory.

There are hardware solution in the making like CCIX or OpenCAPI but not
all players are willing to move forward and let PCIE go. So we will need
a software solution to catter to those platform that decide to stick with
PCIE or otherwise there is a large range of hardware we will not be able
to use to their full potential (rendering them mostly useless on linux).

 
> > At least
> > this was my impression when i look at generic filemap one, but for some
> > filesystem this might need be problematic.
> 
> Definitely problematic for XFS, btrfs, f2fs, ocfs2, and probably
> ext4 and others as well.
> 
> > and allowing control by userspace to block such
> > migration for given fs.
> 
> How do you propose doing that?

As a mount flag option is my first idea but i have no strong opinion here.
It might make sense for finer granularity but i don't believe so.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
