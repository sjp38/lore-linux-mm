Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 43B876B0038
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 17:13:36 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id a8so1547261pfg.0
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 14:13:36 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id m188si49493415pfc.211.2016.12.13.14.13.34
        for <linux-mm@kvack.org>;
        Tue, 13 Dec 2016 14:13:35 -0800 (PST)
Date: Wed, 14 Dec 2016 09:13:22 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [LSF/MM TOPIC] Un-addressable device memory and block/fs
 implications
Message-ID: <20161213221322.GD4326@dastard>
References: <20161213181511.GB2305@redhat.com>
 <20161213201515.GB4326@dastard>
 <20161213203112.GE2305@redhat.com>
 <20161213211041.GC4326@dastard>
 <20161213212433.GF2305@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161213212433.GF2305@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Tue, Dec 13, 2016 at 04:24:33PM -0500, Jerome Glisse wrote:
> On Wed, Dec 14, 2016 at 08:10:41AM +1100, Dave Chinner wrote:
> > On Tue, Dec 13, 2016 at 03:31:13PM -0500, Jerome Glisse wrote:
> > > On Wed, Dec 14, 2016 at 07:15:15AM +1100, Dave Chinner wrote:
> > > > On Tue, Dec 13, 2016 at 01:15:11PM -0500, Jerome Glisse wrote:
> > > > > I would like to discuss un-addressable device memory in the context of
> > > > > filesystem and block device. Specificaly how to handle write-back, read,
> > > > > ... when a filesystem page is migrated to device memory that CPU can not
> > > > > access.
> > > > 
> > > > You mean pmem that is DAX-capable that suddenly, without warning,
> > > > becomes non-DAX capable?
> > > > 
> > > > If you are not talking about pmem and DAX, then exactly what does
> > > > "when a filesystem page is migrated to device memory that CPU can
> > > > not access" mean? What "filesystem page" are we talking about that
> > > > can get migrated from main RAM to something the CPU can't access?
> > > 
> > > I am talking about GPU, FPGA, ... any PCIE device that have fast on
> > > board memory that can not be expose transparently to the CPU. I am
> > > reusing ZONE_DEVICE for this, you can see HMM patchset on linux-mm
> > > https://lwn.net/Articles/706856/
> > 
> > So ZONE_DEVICE memory that is a DMA target but not CPU addressable?
> 
> Well not only target, it can be source too. But the device can read
> and write any system memory and dma to/from that memory to its on
> board memory.

So you want the device to be able to dirty mmapped pages that the
CPU can't access?

> > > So in my case i am only considering non DAX/PMEM filesystem ie any
> > > "regular" filesystem back by a "regular" block device. I want to be
> > > able to migrate mmaped area of such filesystem to device memory while
> > > the device is actively using that memory.
> > 
> > "migrate mmapped area of such filesystem" means what, exactly?
> 
> fd = open("/path/to/some/file")
> ptr = mmap(fd, ...);
> gpu_compute_something(ptr);

Thought so. Lots of problems with this.

> > Are you talking about file data contents that have been copied into
> > the page cache and mmapped into a user process address space?
> > IOWs, migrating ZONE_NORMAL page cache page content and state
> > to a new ZONE_DEVICE page, and then migrating back again somehow?
> 
> Take any existing application that mmap a file and allow to migrate
> chunk of that mmaped file to device memory without the application
> even knowing about it. So nothing special in respect to that mmaped
> file.

>From the application point of view. Filesystem, page cache, etc
there's substantial problems here...

> It is a regular file on your filesystem.

... because of this.

> > > From kernel point of view such memory is almost like any other, it
> > > has a struct page and most of the mm code is non the wiser, nor need
> > > to be about it. CPU access trigger a migration back to regular CPU
> > > accessible page.
> > 
> > That sounds ... complex. Page migration on page cache access inside
> > the filesytem IO path locking during read()/write() sounds like
> > a great way to cause deadlocks....
> 
> There are few restriction on device page, no one can do GUP on them and
> thus no one can pin them. Hence they can always be migrated back. Yes
> each fs need modification, most of it (if not all) is isolated in common
> filemap helpers.

Sure, but you haven't answered my question: how do you propose we
address the issue of placing all the mm locks required for migration
under the filesystem IO path locks?

> > > But for thing like writeback i want to be able to do writeback with-
> > > out having to migrate page back first. So that data can stay on the
> > > device while writeback is happening.
> > 
> > Why can't you do writeback before migration, so only clean pages get
> > moved?
> 
> Because device can write to the page while the page is inside the device
> memory and we might want to writeback to disk while page stays in device
> memory and computation continues.

Ok. So how does the device trigger ->page_mkwrite on a clean page to
tell the filesystem that the page has been dirtied? So that, for
example, if the page covers a hole because the file is sparse the
filesytem can do the required block allocation and data
initialisation (i.e. zero the cached page) before it gets marked
dirty and any data gets written to it?

And if zeroing the page during such a fault requires CPU access to
the data, how do you propose we handle page migration in the middle
of the page fault to allow the CPU to zero the page? Seems like more
lock order/inversion problems there, too...

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
