Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 77E366B004D
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 06:05:55 -0400 (EDT)
Date: Wed, 19 Aug 2009 11:05:54 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/3]HTLB mapping for drivers (take 2)
Message-ID: <20090819100553.GE24809@csn.ul.ie>
References: <alpine.LFD.2.00.0908172317470.32114@casper.infradead.org> <56e00de0908180329p2a37da3fp43ddcb8c2d63336a@mail.gmail.com> <202cde0e0908182248we01324em2d24b9e741727a7b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <202cde0e0908182248we01324em2d24b9e741727a7b@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolex@gmail.com>
Cc: Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 19, 2009 at 05:48:11PM +1200, Alexey Korolev wrote:
> Hi,
> >
> > It sounds like this patch set working towards the same goal as my
> > MAP_HUGETLB set.  The only difference I see is you allocate huge page
> > at a time and (if I am understanding the patch) fault the page in
> > immediately, where MAP_HUGETLB only faults pages as needed.  Does the
> > MAP_HUGETLB patch set provide the functionality that you need, and if
> > not, what can be done to provide what you need?
> >
>
> Thanks a lot for willing to help. I'll be much appreciate if you have
> an interesting idea how HTLB mapping for drivers can be done.
> 
> It is better to describe use case in order to make it clear what needs
> to be done.
> Driver provides mapping of device DMA buffers to user level
> applications.

Ok, so the buffer is in normal memory. When mmap() is called, the buffer
is already populated by data DMA'd from the device. That scenario rules out
calling mmap(MAP_ANONYMOUS|MAP_HUGETLB) because userspace has access to the
buffer before it is populated by data from the device.

However, it does not rule out mmap(MAP_ANONYMOUS|MAP_HUGETLB) when userspace
is responsible for populating a buffer for sending to a device. i.e. whether it
is suitable or not depends on when the buffer is populated and who is doing it.

> User level applications process the data.
> Device is using a master DMA to send data to the user buffer, buffer
> size can be >1GB and performance is very important. (So huge pages
> mapping really makes sense.)
> 

Ok, so the DMA may be faster because you have to do less scatter/gather
and can DMA in larger chunks and and reading from userspace may be faster
because there is less translation overhead. Right?

> In addition we have to mention that:
> 1. It is hard for user to tell how much huge pages needs to be
>    reserved by the driver.

I think you have this problem either way. If the buffer is allocated and
populated before mmap(), then the driver is going to have to guess how many
pages it needs. If the DMA occurs as a result of mmap(), it's easier because
you know the number of huge pages to be reserved at that point and you have
the option of falling back to small pages if necessary.

> 2. Devices add constrains on memory regions. For example it needs to
>    be contiguous with in the physical address space. It is necessary to
>   have ability to specify special gfp flags.

The contiguity constraints are the same for huge pages. Do you mean there
are zone restrictions? If so, the hugetlbfs_file_setup() function could be
extended to specify a GFP mask that is used for the allocation of hugepages
and associated with the hugetlbfs inode. Right now, there is a htlb_alloc_mask
mask that is applied to some additional flags so htlb_alloc_mask would be
the default mask unless otherwise specified.

> 3 The HW needs to access physical memory before the user level
> software can access it. (Hugetlbfs picks up pages on page fault from
> pool).
> It means memory allocation needs to be driven by device driver.
> 

How about;

	o Extend Eric's helper slightly to take a GFP mask that is
	  associated with the inode and used for allocations from
	  outside the hugepage pool
	o A helper that returns the page at a given offset within
	  a hugetlbfs file for population before the page has been
	  faulted.

I know this is a bit hand-wavy, but it would allow significant sharing
of the existing code and remove much of the hugetlbfs-awareness from
your current driver.

> Original idea was: create hugetlbfs file which has common mapping with
> device file. Allocate memory. Populate page cache of hugetlbfs file
> with allocated pages.
> When fault occurs, page will be taken from page cache and then
> remapped to user space by hugetlbfs.
> 
> Another possible approach is described here:
> http://marc.info/?l=linux-mm&m=125065257431410&w=2
> But currently not sure  will it work or not.
> 
> 
> Thanks,
> Alexey
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
