Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 60E2B6B0171
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 07:26:11 -0400 (EDT)
Date: Tue, 25 Aug 2009 11:47:31 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/3]HTLB mapping for drivers (take 2)
Message-ID: <20090825104731.GA21335@csn.ul.ie>
References: <alpine.LFD.2.00.0908172317470.32114@casper.infradead.org> <56e00de0908180329p2a37da3fp43ddcb8c2d63336a@mail.gmail.com> <202cde0e0908182248we01324em2d24b9e741727a7b@mail.gmail.com> <20090819100553.GE24809@csn.ul.ie> <202cde0e0908200003w43b91ac3v8a149ec1ace45d6d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <202cde0e0908200003w43b91ac3v8a149ec1ace45d6d@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolex@gmail.com>
Cc: Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 20, 2009 at 07:03:28PM +1200, Alexey Korolev wrote:
> Mel,
> 
> >> User level applications process the data.
> >> Device is using a master DMA to send data to the user buffer, buffer
> >> size can be >1GB and performance is very important. (So huge pages
> >> mapping really makes sense.)
> >>
> >
> > Ok, so the DMA may be faster because you have to do less scatter/gather
> > and can DMA in larger chunks and and reading from userspace may be faster
> > because there is less translation overhead. Right?
> >
> Less translation overhead is important. Unfortunately not all devices
> have scatter/gather
> (our case) as having it increase h/w complexity a lot.
> 

Ok.

> >> In addition we have to mention that:
> >> 1. It is hard for user to tell how much huge pages needs to be
> >>    reserved by the driver.
> >
> > I think you have this problem either way. If the buffer is allocated and
> > populated before mmap(), then the driver is going to have to guess how many
> > pages it needs. If the DMA occurs as a result of mmap(), it's easier because
> > you know the number of huge pages to be reserved at that point and you have
> > the option of falling back to small pages if necessary.
> >
> >> 2. Devices add constrains on memory regions. For example it needs to
> >>    be contiguous with in the physical address space. It is necessary to
> >>   have ability to specify special gfp flags.
> >
> > The contiguity constraints are the same for huge pages. Do you mean there
> > are zone restrictions? If so, the hugetlbfs_file_setup() function could be
> > extended to specify a GFP mask that is used for the allocation of hugepages
> > and associated with the hugetlbfs inode. Right now, there is a htlb_alloc_mask
> > mask that is applied to some additional flags so htlb_alloc_mask would be
> > the default mask unless otherwise specified.
> >
> Under contiguous I mean that we need several huge pages being
> physically contiguous.

Why? One hugepage of default size will be one TLB entry. Each hugepage
after that will be additional TLB entries so there is no savings on
translation overhead.

Getting contiguous pages beyond the hugepage boundary is not a matter
for GFP flags.

> To obtain it we allocate pages till not find a contig. region
> (success) or reach a boundary (fail).
> So in our particular case approach based on getting pages from
> hugetlbfs won't work
> because memory region will not be contiguous.

With a direct allocation of hugepages, there is no guarantee they will
be contiguous either. If you need contiguity above hugepages (which in
many cases will also be the largest page the buddy allocator can grant),
you need something else.

> However this approach will give an easy way to support hugetlb
> mapping, it won't cause any complexity
> in accounting. But it will be suitable for hardware with large amount
> of sg regions only.
> 
> >
> > How about;
> >
> >        o Extend Eric's helper slightly to take a GFP mask that is
> >          associated with the inode and used for allocations from
> >          outside the hugepage pool
> >        o A helper that returns the page at a given offset within
> >          a hugetlbfs file for population before the page has been
> >          faulted.
>
> Do you mean get_user_pages call?
> 

If you're willing to call it directly, sure.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
