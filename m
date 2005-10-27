Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9RJeQEc021801
	for <linux-mm@kvack.org>; Thu, 27 Oct 2005 15:40:26 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9RJeQOO111392
	for <linux-mm@kvack.org>; Thu, 27 Oct 2005 15:40:26 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j9RJePXo011730
	for <linux-mm@kvack.org>; Thu, 27 Oct 2005 15:40:26 -0400
Reply-To: Gerrit Huizenga <gh@us.ibm.com>
From: Gerrit Huizenga <gh@us.ibm.com>
Subject: Re: [RFC] madvise(MADV_TRUNCATE) 
In-reply-to: Your message of Thu, 27 Oct 2005 11:50:50 PDT.
             <20051027115050.7f5a6fb7.akpm@osdl.org>
Date: Thu, 27 Oct 2005 12:40:05 -0700
Message-Id: <E1EVDbZ-0004fp-00@w-gerrit.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, andrea@suse.de, ak@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Oct 2005 11:50:50 PDT, Andrew Morton wrote:
> Badari Pulavarty <pbadari@us.ibm.com> wrote:
> >
> > I have 2 reasons (I don't know if Andrea has more uses/reasons):
> >
> > (1) Our database folks want to drop parts of shared memory segments
> > when they see memory pressure
> 
> How do they "see memory pressure"?
> 
> The kernel's supposed to write the memory out to swap under memory
> pressure, so why is a manual interface needed?
> 
> > or memory hotplug/virtualization stuff.
> 
> Really?  Are you sure?  Is this the only means by which the memory hotplug
> developers can free up shmem pages?  I think not...
 
On pSeries, an LPAR shrink the amount of memory/number of processors
available to an OS instance.  The most convenient way for this to happen
for some applications is to tell them that their world has shrunk, so
they can conssciously resize their various data pools, mmap segments,
buffers, pre-fault rates, heaps, etc. in some uniform way.  Once they
have been told the world is going to shrink the LPAR can more easily
find free pages to scavenge without sending them machine into paroxysms
of page paging and thrashing.

> > madvise(DONTNEED) is not really releasing the pagecache pages. So 
> > they want madvise(DISCARD).
> >
> > (2) Jeff Dike wants to use this for UML.
> 
> Why?  For what purpose?   Will he only ever want it for shmem segments?

 I don't know Jeff's purpose, but this allows some large applications
 to mmap a rediculously large mmap segment which doesn't have to be
 remapped every time the underlying hardware changes.  At the same time,
 some applications (DB2 is the prime example here, but Java wants this
 as well) know when pages are no longer needed and would like to free
 them.

 In Java, for instance, the heap can a two hand sweep and compress,
 moving active pages from one side of the heap to the other periodically.
 (Actually the heap management is a bit more complex than that, but...)
 The overall heap is a large virtual address space but in reality
 when pages are freed from it, the application really believes those
 pages can go away and should not be cached or preserved for that section.
 The physical pages can be re-used immediately and re-faulted (possibly
 ZFOD) if necessary afterwards.

> > Please advise on what you would prefer. A small extension to madvise()
> >  to solve few problems right now OR lets do real sys_holepunch() and
> >  bite the bullet (even though we may not get any more users for it).
> 
> I don't think that the benefits for a full holepunch would be worth the
> complexity - nasty, complex, rarely-tested changes to every filesystem.  So
> let's not go there.
> 
> If we take the position that this is a shmem-specific thing and we don't
> intend to extend it to real/regular filesytems then perhaps a new syscall
> would be more appropriate.  On x86 that'd probably be another entry in the
> sys_shm() switch statement.  Maybe?

 I believe Java uses mmap() today for this; DB2 probably uses both mmap()
 and shm*().

gerrit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
