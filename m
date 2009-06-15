Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BF19E6B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 05:23:13 -0400 (EDT)
Date: Mon, 15 Jun 2009 10:23:51 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Huge pages for device drivers
Message-ID: <20090615092351.GA23198@csn.ul.ie>
References: <202cde0e0906112141n634c1bd6n15ec1ac42faa36d3@mail.gmail.com> <20090612143005.GA4429@csn.ul.ie> <202cde0e0906142358x6474ad7fxeac0a3e60634021@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <202cde0e0906142358x6474ad7fxeac0a3e60634021@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolex@gmail.com>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 15, 2009 at 06:58:08PM +1200, Alexey Korolev wrote:
> >
> > Ok. So the order is
> >
> > 1. driver alloc_pages()
> > 2. driver DMA
> > 3. userspace mmap
> > 4. userspace fault
> >
> > ?
> Correct.
> The only minor difference in my case memory is remapped in mmap call
> not in fault. (But this is not important)
> 

Well, it is important really. You're willing to have the whole regions
page tables populated at once. This is something that is ordinarily
avoided in hugetlbfs.

> > There is a subtle distinction depending on what you are really looking for.
> > If all you are interested in is large contiguous pages, then that is relatively
> > handy. I did a hatchet-job below to show how one could allocate pages from
> > hugepage pools that should not break reservations. It's not tested, it's just
> > to illustrate how something like this might be implemented because it's been
> > asked for a number of times. However, I doubt it's what driver people really
> > want, it's just what has been asked for on occasion :)
> 
> Good question. I remember just two cases, when it was desired:
> 1. Driver/libraries for video card which has no own video memory.
> Implementation was based
> on data handling through DirectFB interface. Video card allocated
> 128MB - 192MB of system RAM which was maped to user space. User space
> library performed
> big bunch of operations with RAM assigned for video card.  (Card and
> drivers were for STB solution)
> 
> 2. 10Gb networking, where data analysing can consume all available
> resources  on most
> powerful servers. Performance is critical here as 5-7% perf gain -
> means xxk$ cheaper servers.
> Both cases are pretty specific IMHO.
> 

Specific indeed although I'm seeing more cases recently where a device
driver needs to access a large amount of memory quickly so it might be a
more common use case than previous years.

> > If you must get those mapped into userspace, then it would be tricky to get the
> > pages above mapped into userspace properly, particularly with respect to PTEs
> > and then making sure the fault occurs properly. I'd hate to be maintaining such
> > a driver. It could be worked around to some extent by doing something similar
> > to what happens for shmget() and shmat() and this would be relatively reusable.
> >
> Yes it is a thing I need.
> 
> > 1. Create a wrapper around hugetlb_file_setup() similar to what happens in
> > ipc/shm.c#newseg(). That would create a hugetlbfs file on an invisible mount
> > and reserve the hugepages you will need.
> >
> > 2. Create a function that is similar to a nopage fault handler that allocates
> > a hugepage within an offset in your hidden hugetlbfs file and inserts it
> > into the hugetlbfs pagecache giving you back the page frame for use with DMA.
> >
> The main problem is here, because it is necessary to do operations with PTE
> to insert huge pages into given VMA. So it is necessary to provide
> some prototype for drivers
> here. I'm fine to modify code here but completely not sure what
> interfaces must be given for drivers.
> (Not sure that it is good just to export calls like huge_pte_alloc? ).
> 

Well, essentially you are duplicating hugetlb_no_page() with a version
that doesn't manipulate the VMA, mm or page tables. All you want is the
page to be allocated, be placed correctly in the page cache and given
back to you for population with data. The intent is to get it into
userspace with the normal fault path later.

> > Most of the code you need is already there, just not quite in the shape
> > you want it in. I have no plans to implement such a thing but I estimate it
> > wouldn't take someone who really cared more than a few days to implement it.
> >
> > Anyway, here is the alloc_huge_page() prototype for what that's worth to
> > you
> >
> Thank you so much for this prototype it is very helpful. I applied and
> tried it today and stopped
> at the problem of page fault handling.
>

Instead of handling the faults yourself, duplicate hugetlb_no_page() to
allocate the page for you and nothing else. Once the file is then mapped
to userspace, it will take one minor fault per hugepage to fix up the
pagetables.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
