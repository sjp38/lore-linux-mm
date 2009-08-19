Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BA2796B004D
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 06:35:50 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id 22so1023629fge.4
        for <linux-mm@kvack.org>; Wed, 19 Aug 2009 03:35:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090819100553.GE24809@csn.ul.ie>
References: <alpine.LFD.2.00.0908172317470.32114@casper.infradead.org>
	 <56e00de0908180329p2a37da3fp43ddcb8c2d63336a@mail.gmail.com>
	 <202cde0e0908182248we01324em2d24b9e741727a7b@mail.gmail.com>
	 <20090819100553.GE24809@csn.ul.ie>
Date: Wed, 19 Aug 2009 11:35:50 +0100
Message-ID: <56e00de0908190335n6b120114kb6ece4623f024319@mail.gmail.com>
Subject: Re: [PATCH 0/3]HTLB mapping for drivers (take 2)
From: Eric B Munson <linux-mm@mgebm.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Alexey Korolev <akorolex@gmail.com>, Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 19, 2009 at 11:05 AM, Mel Gorman<mel@csn.ul.ie> wrote:
> On Wed, Aug 19, 2009 at 05:48:11PM +1200, Alexey Korolev wrote:
>> Hi,
>> >
>> > It sounds like this patch set working towards the same goal as my
>> > MAP_HUGETLB set. =A0The only difference I see is you allocate huge pag=
e
>> > at a time and (if I am understanding the patch) fault the page in
>> > immediately, where MAP_HUGETLB only faults pages as needed. =A0Does th=
e
>> > MAP_HUGETLB patch set provide the functionality that you need, and if
>> > not, what can be done to provide what you need?
>> >
>>
>> Thanks a lot for willing to help. I'll be much appreciate if you have
>> an interesting idea how HTLB mapping for drivers can be done.
>>
>> It is better to describe use case in order to make it clear what needs
>> to be done.
>> Driver provides mapping of device DMA buffers to user level
>> applications.
>
> Ok, so the buffer is in normal memory. When mmap() is called, the buffer
> is already populated by data DMA'd from the device. That scenario rules o=
ut
> calling mmap(MAP_ANONYMOUS|MAP_HUGETLB) because userspace has access to t=
he
> buffer before it is populated by data from the device.
>
> However, it does not rule out mmap(MAP_ANONYMOUS|MAP_HUGETLB) when usersp=
ace
> is responsible for populating a buffer for sending to a device. i.e. whet=
her it
> is suitable or not depends on when the buffer is populated and who is doi=
ng it.
>
>> User level applications process the data.
>> Device is using a master DMA to send data to the user buffer, buffer
>> size can be >1GB and performance is very important. (So huge pages
>> mapping really makes sense.)
>>
>
> Ok, so the DMA may be faster because you have to do less scatter/gather
> and can DMA in larger chunks and and reading from userspace may be faster
> because there is less translation overhead. Right?
>
>> In addition we have to mention that:
>> 1. It is hard for user to tell how much huge pages needs to be
>> =A0 =A0reserved by the driver.
>
> I think you have this problem either way. If the buffer is allocated and
> populated before mmap(), then the driver is going to have to guess how ma=
ny
> pages it needs. If the DMA occurs as a result of mmap(), it's easier beca=
use
> you know the number of huge pages to be reserved at that point and you ha=
ve
> the option of falling back to small pages if necessary.
>
>> 2. Devices add constrains on memory regions. For example it needs to
>> =A0 =A0be contiguous with in the physical address space. It is necessary=
 to
>> =A0 have ability to specify special gfp flags.
>
> The contiguity constraints are the same for huge pages. Do you mean there
> are zone restrictions? If so, the hugetlbfs_file_setup() function could b=
e
> extended to specify a GFP mask that is used for the allocation of hugepag=
es
> and associated with the hugetlbfs inode. Right now, there is a htlb_alloc=
_mask
> mask that is applied to some additional flags so htlb_alloc_mask would be
> the default mask unless otherwise specified.
>
>> 3 The HW needs to access physical memory before the user level
>> software can access it. (Hugetlbfs picks up pages on page fault from
>> pool).
>> It means memory allocation needs to be driven by device driver.
>>
>
> How about;
>
> =A0 =A0 =A0 =A0o Extend Eric's helper slightly to take a GFP mask that is
> =A0 =A0 =A0 =A0 =A0associated with the inode and used for allocations fro=
m
> =A0 =A0 =A0 =A0 =A0outside the hugepage pool
> =A0 =A0 =A0 =A0o A helper that returns the page at a given offset within
> =A0 =A0 =A0 =A0 =A0a hugetlbfs file for population before the page has be=
en
> =A0 =A0 =A0 =A0 =A0faulted.
>
> I know this is a bit hand-wavy, but it would allow significant sharing
> of the existing code and remove much of the hugetlbfs-awareness from
> your current driver.
>
>> Original idea was: create hugetlbfs file which has common mapping with
>> device file. Allocate memory. Populate page cache of hugetlbfs file
>> with allocated pages.
>> When fault occurs, page will be taken from page cache and then
>> remapped to user space by hugetlbfs.
>>
>> Another possible approach is described here:
>> http://marc.info/?l=3Dlinux-mm&m=3D125065257431410&w=3D2
>> But currently not sure =A0will it work or not.
>>
>>
>> Thanks,
>> Alexey
>>
>
> --
> Mel Gorman
> Part-time Phd Student =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
Linux Technology Center
> University of Limerick =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IB=
M Dublin Software Lab
>

Alexey,

I'd be willing to take a stab at a prototype of Mel's suggestion based
on my patch set if you this it would be useful to you.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
