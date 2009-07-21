Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 95B786B005A
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 05:40:00 -0400 (EDT)
Date: Tue, 21 Jul 2009 10:40:00 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: HugeTLB mapping for drivers (sample driver)
Message-ID: <20090721094000.GB25383@csn.ul.ie>
References: <alpine.LFD.2.00.0907140258100.25576@casper.infradead.org> <20090714102735.GD28569@csn.ul.ie> <202cde0e0907141708g51294247i7a201c34e97f5b66@mail.gmail.com> <202cde0e0907190639k7bbebc63k143734ad696f90f5@mail.gmail.com> <20090720081130.GA7989@csn.ul.ie> <202cde0e0907210232gc8a6119jc7f2ba522d22a80d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <202cde0e0907210232gc8a6119jc7f2ba522d22a80d@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolex@gmail.com>
Cc: Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 21, 2009 at 09:32:34PM +1200, Alexey Korolev wrote:
> Hi,
> >
> > Did the OOM killer really trigger and select a process for killing or
> > did the process itself just get killed with an out-of-memory message? I
> > would have expected the latter.
> >
>
> OMM killer triggered in case of private mapping on attempt to access a
> page under private mapping. It was because code did not check the pages
> availability at mmap time. Will be fixed.
> 

That's a surprise. I should check out why the OOM killer fired instead
of just killing the application that failed to fault the page.

> >> In fact there should be quite few cases when private mapping makes
> >> sense for drivers and mapping DMA buffers. I thought about possible
> >> solutions. The question is what to choose.
> >>
> >> 1. Forbid private mappings for drivers in case of hugetlb. (But this
> >> limits functionality - it is not so good)
> >
> > For a long time, this was the "solution" for hugetlbfs.
> >
> >> 2. Allow private mapping. Use hugetlbfs hstates. (But it forces user
> >> to know how much hugetlb memory it is necessary to reserve for
> >> drivers)
> >
> > You can defer working out the reservations until mmap() time,
> > particularly if you are using dynamic hugepage pool resizing instead of
> > static allocation.
> >
> >> 3. Allow private mapping. Use special hstate for driver and driver
> >> should tell how much memory needs to be reserved for it. (Not clear
> >> yet how to behave if we are out of reserved space)
> >>
> >> Could you please suggest what is the best solution? May be some other options?
> >>
> >
> > The only solution that springs to mind is the same one used by hugetlbfs
> > and that is that reservations are taken at mmap() time for the size of the
> > mapping. In your case, you prefault but either way, the hugepages exist.
> >
> Yes, that looks sane. I'll follow this way. In a particular case if
> driver do not
> need a private mapping mmap will return error. Thanks for the advice.
> I'm about
> to modify the patches. I'll try to involve  hugetlb reservation
> functions as much  as
> possible and track reservations by special hstate for drivers.
> 

Ok but bear in mind you are now going far down the road of
re-implementing hugetlbfs and you should re-examine why you cannot use
the hidden internal hugetlbfs mount similar to what shared memory does.

> > What then happens for hugetlbfs is that only the process that called mmap()
> > is guaranteed their faults will succeed. If a child process incurs a COW
> > and the hugepages are not available, the child process gets killed. If
> > the parent process performs COW and the huge pages are not available, it
> > unmaps the pages from the child process so that COW becomes unnecessary. If
> > the child process then faults, it gets killed.  This is implemented in
> > mm/hugetlb.c#unmap_ref_private().
> 
> So on out of memory COW hugetlb code prefer applications to be killed by
> SIGSEGV (SIGBUS?) instead of OOM. Okk.
> 

It prefers to kill the children with SIGKILL than have the parent
application randomly fail. This happens when the pool is insufficient for
any part of the application to continue. What it was intended to address
was hugepage-aware-applications-using-MAP_PRIVATE that fork() and exec()
helper applications/monitors which appears to be fairly common. There was
a sizable window between fork() and exec() where the parent process could
get killed accessing its MAP_PRIVATE area and taking a COW even though the
child would never need it. Guaranteeing that the process that called mmap()
would always succeed fault was better than it being a random choice between
parents and children.

The impact is that applications that use MAP_PRIVATE that expect
children to get a full private copy of hugetlb-backed areas are going to
have a bad time but the expectation is that these applications are very
rare and they'll be told "don't do that".

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
