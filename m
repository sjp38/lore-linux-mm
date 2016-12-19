Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7556C6B02A9
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 12:00:44 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 144so233139320pfv.5
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 09:00:44 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n28si19023345pfb.144.2016.12.19.09.00.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 09:00:43 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uBJGwrFa036851
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 12:00:43 -0500
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 27ehbkseg0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 12:00:42 -0500
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 19 Dec 2016 10:00:41 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Un-addressable device memory and block/fs implications
In-Reply-To: <20161214111351.GC18624@quack2.suse.cz>
References: <20161213181511.GB2305@redhat.com> <20161213201515.GB4326@dastard> <20161213203112.GE2305@redhat.com> <20161213211041.GC4326@dastard> <20161213212433.GF2305@redhat.com> <20161214111351.GC18624@quack2.suse.cz>
Date: Mon, 19 Dec 2016 22:30:06 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87shpjua5l.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>, linux-block@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org

Jan Kara <jack@suse.cz> writes:

> On Tue 13-12-16 16:24:33, Jerome Glisse wrote:
>> On Wed, Dec 14, 2016 at 08:10:41AM +1100, Dave Chinner wrote:
>> > On Tue, Dec 13, 2016 at 03:31:13PM -0500, Jerome Glisse wrote:
>> > > On Wed, Dec 14, 2016 at 07:15:15AM +1100, Dave Chinner wrote:
>> > > > On Tue, Dec 13, 2016 at 01:15:11PM -0500, Jerome Glisse wrote:
>> > > > > I would like to discuss un-addressable device memory in the context of
>> > > > > filesystem and block device. Specificaly how to handle write-back, read,
>> > > > > ... when a filesystem page is migrated to device memory that CPU can not
>> > > > > access.
>> > > > 
>> > > > You mean pmem that is DAX-capable that suddenly, without warning,
>> > > > becomes non-DAX capable?
>> > > > 
>> > > > If you are not talking about pmem and DAX, then exactly what does
>> > > > "when a filesystem page is migrated to device memory that CPU can
>> > > > not access" mean? What "filesystem page" are we talking about that
>> > > > can get migrated from main RAM to something the CPU can't access?
>> > > 
>> > > I am talking about GPU, FPGA, ... any PCIE device that have fast on
>> > > board memory that can not be expose transparently to the CPU. I am
>> > > reusing ZONE_DEVICE for this, you can see HMM patchset on linux-mm
>> > > https://lwn.net/Articles/706856/
>> > 
>> > So ZONE_DEVICE memory that is a DMA target but not CPU addressable?
>> 
>> Well not only target, it can be source too. But the device can read
>> and write any system memory and dma to/from that memory to its on
>> board memory.
>> 
>> > 
>> > > So in my case i am only considering non DAX/PMEM filesystem ie any
>> > > "regular" filesystem back by a "regular" block device. I want to be
>> > > able to migrate mmaped area of such filesystem to device memory while
>> > > the device is actively using that memory.
>> > 
>> > "migrate mmapped area of such filesystem" means what, exactly?
>> 
>> fd = open("/path/to/some/file")
>> ptr = mmap(fd, ...);
>> gpu_compute_something(ptr);
>> 
>> > 
>> > Are you talking about file data contents that have been copied into
>> > the page cache and mmapped into a user process address space?
>> > IOWs, migrating ZONE_NORMAL page cache page content and state
>> > to a new ZONE_DEVICE page, and then migrating back again somehow?
>> 
>> Take any existing application that mmap a file and allow to migrate
>> chunk of that mmaped file to device memory without the application
>> even knowing about it. So nothing special in respect to that mmaped
>> file. It is a regular file on your filesystem.
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

For Coherent Device Memory case, the CPU can continue to access these
device pages.


>
> And by migration you really mean page migration? Be aware that migration of
> pagecache pages may be a problem for some pages of some filesystems on its
> own - e. g. page migration may fail because there is a filesystem transaction
> outstanding modifying that page. For userspace these will be really hard
> to understand sporadic errors because it's really filesystem internal
> thing. So far page migration was widely used only for free space
> defragmentation and for that purpose if page is not migratable for a minute
> who cares.

On the device driver side, i guess we should be able to handle page
migration failures and retry. For the reverse, i guess we need the
guarantee that a CPU access can always migrate back these pages without
failures ? Are there failure condition we need to handle when migrating
pages back to system memory ?


>
> So won't it be easier to leave the pagecache page where it is and *copy* it
> to the device? Can the device notify us *before* it is going to modify a
> page, not just after it has modified it? Possibly if we just give it the
> page read-only and it will have to ask CPU to get write permission? If yes,
> then I belive this could work and even fs support should be doable.
>

For coherent device memory scenario, we can live with one copy and both
cpu/device can access these pages. In CDM case the decision to migrate
is driven by the frequency of access from the device.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
