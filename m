Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2D5696B005C
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 04:11:33 -0400 (EDT)
Date: Mon, 20 Jul 2009 09:11:31 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: HugeTLB mapping for drivers (sample driver)
Message-ID: <20090720081130.GA7989@csn.ul.ie>
References: <alpine.LFD.2.00.0907140258100.25576@casper.infradead.org> <20090714102735.GD28569@csn.ul.ie> <202cde0e0907141708g51294247i7a201c34e97f5b66@mail.gmail.com> <202cde0e0907190639k7bbebc63k143734ad696f90f5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <202cde0e0907190639k7bbebc63k143734ad696f90f5@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolex@gmail.com>
Cc: Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 20, 2009 at 01:39:30AM +1200, Alexey Korolev wrote:
> Mel,
> 
> >>
> >> I ran out of time to review this properly, but glancing through I would be
> >> concerned with what happens on fork() and COW. At a short read, it would
> >> appear that pages get allocated from alloc_buddy_huge_page() instead of your
> >> normal function altering the counters for hstate_nores.
> >>
> 
> I've done some more investigations. You are right it is necessary to
> track cases with private mappings some how if we are going to provide
> hugetlb remap for drivers. OOM killer starts to work on COW caused by
> private hugetlb mapping. (In case of non huge tlb mapping memory just
> copied)
> 

Did the OOM killer really trigger and select a process for killing or
did the process itself just get killed with an out-of-memory message? I
would have expected the latter.

> In fact there should be quite few cases when private mapping makes
> sense for drivers and mapping DMA buffers. I thought about possible
> solutions. The question is what to choose.
> 
> 1. Forbid private mappings for drivers in case of hugetlb. (But this
> limits functionality - it is not so good)

For a long time, this was the "solution" for hugetlbfs.

> 2. Allow private mapping. Use hugetlbfs hstates. (But it forces user
> to know how much hugetlb memory it is necessary to reserve for
> drivers)

You can defer working out the reservations until mmap() time,
particularly if you are using dynamic hugepage pool resizing instead of
static allocation.

> 3. Allow private mapping. Use special hstate for driver and driver
> should tell how much memory needs to be reserved for it. (Not clear
> yet how to behave if we are out of reserved space)
> 
> Could you please suggest what is the best solution? May be some other options?
> 

The only solution that springs to mind is the same one used by hugetlbfs
and that is that reservations are taken at mmap() time for the size of the
mapping. In your case, you prefault but either way, the hugepages exist.

What then happens for hugetlbfs is that only the process that called mmap()
is guaranteed their faults will succeed. If a child process incurs a COW
and the hugepages are not available, the child process gets killed. If
the parent process performs COW and the huge pages are not available, it
unmaps the pages from the child process so that COW becomes unnecessary. If
the child process then faults, it gets killed.  This is implemented in
mm/hugetlb.c#unmap_ref_private().

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
