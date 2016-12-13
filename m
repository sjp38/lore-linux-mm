Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id DCDED6B0253
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 17:55:28 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id j49so1406176qta.1
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 14:55:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c6si26680347qka.141.2016.12.13.14.55.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 14:55:28 -0800 (PST)
Date: Tue, 13 Dec 2016 17:55:24 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [LSF/MM TOPIC] Un-addressable device memory and block/fs
 implications
Message-ID: <20161213225523.GG2305@redhat.com>
References: <20161213181511.GB2305@redhat.com>
 <20161213201515.GB4326@dastard>
 <20161213203112.GE2305@redhat.com>
 <20161213211041.GC4326@dastard>
 <20161213212433.GF2305@redhat.com>
 <20161213221322.GD4326@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20161213221322.GD4326@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Wed, Dec 14, 2016 at 09:13:22AM +1100, Dave Chinner wrote:
> On Tue, Dec 13, 2016 at 04:24:33PM -0500, Jerome Glisse wrote:
> > On Wed, Dec 14, 2016 at 08:10:41AM +1100, Dave Chinner wrote:
> > > On Tue, Dec 13, 2016 at 03:31:13PM -0500, Jerome Glisse wrote:
> > > > On Wed, Dec 14, 2016 at 07:15:15AM +1100, Dave Chinner wrote:
> > > > > On Tue, Dec 13, 2016 at 01:15:11PM -0500, Jerome Glisse wrote:
> > > > > > I would like to discuss un-addressable device memory in the context of
> > > > > > filesystem and block device. Specificaly how to handle write-back, read,
> > > > > > ... when a filesystem page is migrated to device memory that CPU can not
> > > > > > access.
> > > > > 
> > > > > You mean pmem that is DAX-capable that suddenly, without warning,
> > > > > becomes non-DAX capable?
> > > > > 
> > > > > If you are not talking about pmem and DAX, then exactly what does
> > > > > "when a filesystem page is migrated to device memory that CPU can
> > > > > not access" mean? What "filesystem page" are we talking about that
> > > > > can get migrated from main RAM to something the CPU can't access?
> > > > 
> > > > I am talking about GPU, FPGA, ... any PCIE device that have fast on
> > > > board memory that can not be expose transparently to the CPU. I am
> > > > reusing ZONE_DEVICE for this, you can see HMM patchset on linux-mm
> > > > https://lwn.net/Articles/706856/
> > > 
> > > So ZONE_DEVICE memory that is a DMA target but not CPU addressable?
> > 
> > Well not only target, it can be source too. But the device can read
> > and write any system memory and dma to/from that memory to its on
> > board memory.
> 
> So you want the device to be able to dirty mmapped pages that the
> CPU can't access?

Yes, correct.


> > > > So in my case i am only considering non DAX/PMEM filesystem ie any
> > > > "regular" filesystem back by a "regular" block device. I want to be
> > > > able to migrate mmaped area of such filesystem to device memory while
> > > > the device is actively using that memory.
> > > 
> > > "migrate mmapped area of such filesystem" means what, exactly?
> > 
> > fd = open("/path/to/some/file")
> > ptr = mmap(fd, ...);
> > gpu_compute_something(ptr);
> 
> Thought so. Lots of problems with this.
> 
> > > Are you talking about file data contents that have been copied into
> > > the page cache and mmapped into a user process address space?
> > > IOWs, migrating ZONE_NORMAL page cache page content and state
> > > to a new ZONE_DEVICE page, and then migrating back again somehow?
> > 
> > Take any existing application that mmap a file and allow to migrate
> > chunk of that mmaped file to device memory without the application
> > even knowing about it. So nothing special in respect to that mmaped
> > file.
> 
> From the application point of view. Filesystem, page cache, etc
> there's substantial problems here...
> 
> > It is a regular file on your filesystem.
> 
> ... because of this.
> 
> > > > From kernel point of view such memory is almost like any other, it
> > > > has a struct page and most of the mm code is non the wiser, nor need
> > > > to be about it. CPU access trigger a migration back to regular CPU
> > > > accessible page.
> > > 
> > > That sounds ... complex. Page migration on page cache access inside
> > > the filesytem IO path locking during read()/write() sounds like
> > > a great way to cause deadlocks....
> > 
> > There are few restriction on device page, no one can do GUP on them and
> > thus no one can pin them. Hence they can always be migrated back. Yes
> > each fs need modification, most of it (if not all) is isolated in common
> > filemap helpers.
> 
> Sure, but you haven't answered my question: how do you propose we
> address the issue of placing all the mm locks required for migration
> under the filesystem IO path locks?

Two different plans (which are non exclusive of each other). First is to use
workqueue and have read/write wait on the workqueue to be done migrating the
page back.

Second solution is to use a bounce page during I/O so that there is no need
for migration.


> > > > But for thing like writeback i want to be able to do writeback with-
> > > > out having to migrate page back first. So that data can stay on the
> > > > device while writeback is happening.
> > > 
> > > Why can't you do writeback before migration, so only clean pages get
> > > moved?
> > 
> > Because device can write to the page while the page is inside the device
> > memory and we might want to writeback to disk while page stays in device
> > memory and computation continues.
> 
> Ok. So how does the device trigger ->page_mkwrite on a clean page to
> tell the filesystem that the page has been dirtied? So that, for
> example, if the page covers a hole because the file is sparse the
> filesytem can do the required block allocation and data
> initialisation (i.e. zero the cached page) before it gets marked
> dirty and any data gets written to it?
> 
> And if zeroing the page during such a fault requires CPU access to
> the data, how do you propose we handle page migration in the middle
> of the page fault to allow the CPU to zero the page? Seems like more
> lock order/inversion problems there, too...


File back page are never allocated on device, at least we have no incentive
for usecase we care about today to do so. So a regular page is first use
and initialize (to zero for hole) before being migrated to device. So i do
not believe there should be any major concern on ->page_mkwrite. At least
this was my impression when i look at generic filemap one, but for some
filesystem this might need be problematic. I intend to enable this kind of
migration on fs basis and allowing control by userspace to block such
migration for given fs.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
