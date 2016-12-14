Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id E3F0B6B0260
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 12:15:18 -0500 (EST)
Received: by mail-yb0-f199.google.com with SMTP id 186so48476160yby.5
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 09:15:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y36si3484845ybi.204.2016.12.14.09.15.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 09:15:18 -0800 (PST)
Date: Wed, 14 Dec 2016 12:15:14 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Un-addressable device memory and
 block/fs implications
Message-ID: <20161214171514.GB14755@redhat.com>
References: <20161213181511.GB2305@redhat.com>
 <20161213201515.GB4326@dastard>
 <20161213203112.GE2305@redhat.com>
 <20161213211041.GC4326@dastard>
 <20161213212433.GF2305@redhat.com>
 <20161214111351.GC18624@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20161214111351.GC18624@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, linux-block@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org

On Wed, Dec 14, 2016 at 12:13:51PM +0100, Jan Kara wrote:
> On Tue 13-12-16 16:24:33, Jerome Glisse wrote:
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
> > 
> > > 
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
> > 
> > > 
> > > Are you talking about file data contents that have been copied into
> > > the page cache and mmapped into a user process address space?
> > > IOWs, migrating ZONE_NORMAL page cache page content and state
> > > to a new ZONE_DEVICE page, and then migrating back again somehow?
> > 
> > Take any existing application that mmap a file and allow to migrate
> > chunk of that mmaped file to device memory without the application
> > even knowing about it. So nothing special in respect to that mmaped
> > file. It is a regular file on your filesystem.
> 
> OK, so I share most of Dave's concerns about this. But let's talk about
> what we can do and what you need and we may find something usable. First
> let me understand what is doable / what are the costs on your side.
> 
> So we have a page cache page that you'd like to migrate to the device.
> Fine. You are willing to sacrifice direct IO - even better. We can fall
> back to buffered IO in that case (well, except for XFS which does not do it
> but that's a minor detail). One thing I'm not sure about: When a page is
> migrated to the device, is its contents available and is just possibly stale
> or will something bad happen if we try to access (or even modify) page data?

Well i am not ready to sacrifice anything :) the point is that high level
langage are evolving in direction in which they want to transparently use
device like GPU without the programmer knowledge so it is important that
all feature keeps working as if nothing is amiss.

Device behave exactly like CPU in respect to memory. They have a page table
and they have same kind of capabilities. So device will follow same rules.
When you start writeback you do page_mkclean() and this will be reflected
on the device too, it will write protect the page.

Moreover you can access the data at any time, device are cache coherent and
so when you use their dma engine to retrive page content you will get the
full page content and nothing can be stale (assuming that page is first
write protected).

> 
> And by migration you really mean page migration? Be aware that migration of
> pagecache pages may be a problem for some pages of some filesystems on its
> own - e. g. page migration may fail because there is a filesystem transaction
> outstanding modifying that page. For userspace these will be really hard
> to understand sporadic errors because it's really filesystem internal
> thing. So far page migration was widely used only for free space
> defragmentation and for that purpose if page is not migratable for a minute
> who cares.

I am aware that page migration can fail because a writeback is underway and
i am fine with it. When that happens either device wait or use the system
page directly (read only obviously as device obey read/write protection).

> 
> So won't it be easier to leave the pagecache page where it is and *copy* it
> to the device? Can the device notify us *before* it is going to modify a
> page, not just after it has modified it? Possibly if we just give it the
> page read-only and it will have to ask CPU to get write permission? If yes,
> then I belive this could work and even fs support should be doable.

Well yes and no. Device obey the same rule as CPU so if a file back page is
map read only in the process it must first do a write fault which will call
in the fs (page_mkwrite() of vm_ops). But once a page has write permission
there is no way to be notify by hardware on every write. First the hardware
do not have the capability. Second we are talking thousand (10 000 is upper
range in today device) of concurrent thread, each can possibly write to page
under consideration.

We really want the device page to behave just like regular page. Most fs code
path never map file content, it only happens during read/write and i believe
this can be handled either by migrating back or by using bounce page. I want
to provide the choice between the two solutions as one will be better for some
workload and the other for different workload.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
