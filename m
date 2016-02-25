Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id C47476B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 16:08:43 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id jq7so60121646obb.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 13:08:43 -0800 (PST)
Received: from na01-by2-obe.outbound.protection.outlook.com (mail-by2on0115.outbound.protection.outlook.com. [207.46.100.115])
        by mx.google.com with ESMTPS id h82si8233527oif.44.2016.02.25.13.08.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 25 Feb 2016 13:08:42 -0800 (PST)
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
References: <56CCD54C.3010600@plexistor.com>
 <CAPcyv4iqO=Pzu_r8tV6K2G953c5HqJRdqCE1pymfDmURy8_ODw@mail.gmail.com>
 <x49egc3c8gf.fsf@segfault.boston.devel.redhat.com>
 <CAPcyv4jUkMikW_x1EOTHXH4GC5DkPieL=sGd0-ajZqmG6C7DEg@mail.gmail.com>
 <x49a8mrc7rn.fsf@segfault.boston.devel.redhat.com>
 <CAPcyv4hMJ_+o2hYU7xnKEWUcKpcPVd66e2KChwL96Qxxk2R8iQ@mail.gmail.com>
 <x49a8mqgni5.fsf@segfault.boston.devel.redhat.com>
 <20160224225623.GL14668@dastard>
 <x49y4a8iwpy.fsf@segfault.boston.devel.redhat.com>
 <x49twkwiozu.fsf@segfault.boston.devel.redhat.com>
 <20160225201517.GA30721@dastard>
From: Phil Terry <pterry@inphi.com>
Message-ID: <56CF6D4C.1020101@inphi.com>
Date: Thu, 25 Feb 2016 13:08:28 -0800
MIME-Version: 1.0
In-Reply-To: <20160225201517.GA30721@dastard>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Jeff Moyer <jmoyer@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 02/25/2016 12:15 PM, Dave Chinner wrote:
> On Thu, Feb 25, 2016 at 02:11:49PM -0500, Jeff Moyer wrote:
>> Jeff Moyer <jmoyer@redhat.com> writes:
>>
>>>> The big issue we have right now is that we haven't made the DAX/pmem
>>>> infrastructure work correctly and reliably for general use.  Hence
>>>> adding new APIs to workaround cases where we haven't yet provided
>>>> correct behaviour, let alone optimised for performance is, quite
>>>> frankly, a clear case premature optimisation.
>>> Again, I see the two things as separate issues.  You need both.
>>> Implementing MAP_SYNC doesn't mean we don't have to solve the bigger
>>> issue of making existing applications work safely.
>> I want to add one more thing to this discussion, just for the sake of
>> clarity.  When I talk about existing applications and pmem, I mean
>> applications that already know how to detect and recover from torn
>> sectors.  Any application that assumes hardware does not tear sectors
>> should be run on a file system layered on top of the btt.
> Which turns off DAX, and hence makes this a moot discussion because
> mmap is then buffered through the page cache and hence applications
> *must use msync/fsync* to provide data integrity. Which also makes
> them safe to use with DAX if we have a working fsync.
>
> Keep in mind that existing storage technologies tear fileystem data
> writes, too, because user data writes are filesystem block sized and
> not atomic at the device level (i.e.  typical is 512 byte sector, 4k
> filesystem block size, so there are 7 points in a single write where
> a tear can occur on a crash).
Is that really true? Storage to date is on the PCIE/SATA etc IO chain. 
The locks and application crash scenarios when traversing down this 
chain are such that the device will not have its DMA programmed until 
the whole 4K etc page is flushed to memory, pinned for DMA, etc. Then 
the DMA to the device is kicked off. If power crashes during the DMA, 
either we have devices which are supercapped or battery backed to flush 
their write caches and or have firmware which will abort the damaged 
results of the torn DMA on the devices internal meta-data recovery when 
power is restored. (The hardware/firmware on an HDD has been way more 
complex than the simple mind model might lead one to expect for years). 
All of this wrapped inside filesystem transaction semantics.

This is a crucial difference for "storage class memory" on the DRAM bus. 
The NVDIMMs cannot be DMA masters and instead passively receive 
cache-line writes. A "buffered DIMM" as alluded to in the pmem.io Device 
Writers Guide might have intelligence on the DIIMM to detect, map and 
recover tearing via the Block Window Aperture driver interface but on a 
PMEM interface cannot do so. Hence btt on the host with full 
transparency to manage the memory on the NVDIMM is required for the PMEM 
driver. Given this it doesn't make sense to try and put it on the device 
for the BW driver either.

In both cases, btt is not indirecting the buffer (as for a DMA master IO 
type device) but is simply using the same pmem api primitives to manage 
its own meta data about the filesystem writes to detect and recover from 
tears after the event. In what sense is DAX disabled for this?

So I think (please correct me if I'm wrong) but actually the 
hardware/firmware guys have been fixing the torn sector problem for the 
last 30 years and the "storage on the memory channel" has reintroduced 
the problem. So to use as SSD analogy, you fix this problem with the 
FTL, and as we've seen with recent software defined flash and 
openchannel approaches, you can either have the FTL on the device or on 
the host. Absence of the bus master DMA on a DIMM (even with the BW 
aperture software) makes a device based solution problematic so the host 
solution a la btt is required for both PMEM and BW.

>
> IOWs existing storage already has the capability of tearing user
> data on crash and has been doing so for a least they last 30 years.
> Hence I really don't see any fundamental difference here with
> pmem+DAX - the only difference is that the tear granuarlity is
> smaller (CPU cacheline rather than sector).
>
> Cheers,
>
> Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
