Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4DDE790013A
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 10:44:41 -0400 (EDT)
Received: from d06nrmr1507.portsmouth.uk.ibm.com (d06nrmr1507.portsmouth.uk.ibm.com [9.149.38.233])
	by mtagate7.uk.ibm.com (8.13.1/8.13.1) with ESMTP id p7JEiZH2009399
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 14:44:35 GMT
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by d06nrmr1507.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p7JEiZVk999644
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 15:44:35 +0100
Received: from d06av06.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p7JEiYdL014335
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 08:44:35 -0600
Date: Fri, 19 Aug 2011 16:44:32 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [patch v3 2/8] kdump: Make kimage_load_crash_segment() weak
Message-ID: <20110819164432.2bda197c@mschwide>
In-Reply-To: <20110819143748.GI18656@redhat.com>
References: <20110812134849.748973593@linux.vnet.ibm.com>
	<20110812134907.166585439@linux.vnet.ibm.com>
	<20110818171541.GC15413@redhat.com>
	<1313760472.3858.26.camel@br98xy6r>
	<20110819134836.GB18656@redhat.com>
	<20110819162854.64bd7201@mschwide>
	<20110819143748.GI18656@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>, ebiederm@xmission.com, mahesh@linux.vnet.ibm.com, hbabu@us.ibm.com, oomichi@mxs.nes.nec.co.jp, horms@verge.net.au, heiko.carstens@de.ibm.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org

On Fri, 19 Aug 2011 10:37:48 -0400
Vivek Goyal <vgoyal@redhat.com> wrote:

> On Fri, Aug 19, 2011 at 04:28:54PM +0200, Martin Schwidefsky wrote:
> > On Fri, 19 Aug 2011 09:48:36 -0400
> > Vivek Goyal <vgoyal@redhat.com> wrote:
> > 
> > > On Fri, Aug 19, 2011 at 03:27:52PM +0200, Michael Holzheu wrote:
> > > > Hello Vivek,
> > > > 
> > > > On Thu, 2011-08-18 at 13:15 -0400, Vivek Goyal wrote:
> > > > > On Fri, Aug 12, 2011 at 03:48:51PM +0200, Michael Holzheu wrote:
> > > > > > From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
> > > > > > 
> > > > > > On s390 we do not create page tables at all for the crashkernel memory.
> > > > > > This requires a s390 specific version for kimage_load_crash_segment().
> > > > > > Therefore this patch declares this function as "__weak". The s390 version is
> > > > > > very simple. It just copies the kexec segment to real memory without using
> > > > > > page tables:
> > > > > > 
> > > > > > int kimage_load_crash_segment(struct kimage *image,
> > > > > >                               struct kexec_segment *segment)
> > > > > > {
> > > > > >         return copy_from_user_real((void *) segment->mem, segment->buf,
> > > > > >                                    segment->bufsz);
> > > > > > }
> > > > > > 
> > > > > > There are two main advantages of not creating page tables for the
> > > > > > crashkernel memory:
> > > > > > 
> > > > > > a) It saves memory. We have scenarios in mind, where crashkernel
> > > > > >    memory can be very large and saving page table space is important.
> > > > > > b) We protect the crashkernel memory from being overwritten.
> > > > > 
> > > > > Michael,
> > > > > 
> > > > > Thinking more about it. Can't we provide a arch specific version of
> > > > > kmap() and kunmap() so that we create temporary mappings to copy
> > > > > the pages and then these are torn off.
> > > > 
> > > > Isn't kmap/kunmap() used for higmem? These functions are called from
> > > > many different functions in the Linux kernel, not only for kdump. I
> > > > would assume that creating and removing mappings with these functions is
> > > > not what a caller would expect and probably would break the Linux kernel
> > > > at many other places, no?
> > > 
> > > [CCing linux-mm]
> > > 
> > > Yes it is being used for highmem pages. If arch has not defined kmap()
> > > then generic definition is just returning page_address(page), expecting
> > > that page will be mapped.
> > > 
> > > I was wondering that what will be broken if arch decides to extend this
> > > to create temporary mappings for pages which are not HIGHMEM but do
> > > not have any mapping. (Like this special case of s390).
> > > 
> > > I guess memory management guys can give a better answer here. As a layman,
> > > kmap() seems to be the way to get a kernel mapping for any page frame
> > > and if one is not already there, then arch might create one on the fly,
> > > like we do for HIGHMEM pages. So the question is can be extend this
> > > to also cover pages which are not highmem but do not have any mappings
> > > on s390.
> > 
> > Imho it would be wrong to misuse kmap/kunmap to get around a minor problem
> > with the memory for the crash kernel. These functions are used to provide
> > accessibility to highmem pages in the kernel address space. The highmem
> > area is "normal" memory with corresponding struct page elements (the
> > functions do take a struct page * as argument after all). They are not
> > usable to map arbitrary page frames.
> 
> Same is the case with crashkernel memory in s390 where these are
> normal pages, just that these are not mapped in linearly mapped region.
> 
> The only exception to highmem pages is that linearly mapped region is
> not big enough in certain arches, so we left them unmapped.

Well, the crashkernel memory in s390 is addressable without a page table
but is not included in the mem_map array (no struct page). For the highmem
page it is the other way round, the are not addressable without a page table
entry but they are included in mem_map. That makes all the difference, no?
 
> > 
> > And we definitely don't want to make the memory management any slower by
> > defining non-trivial kmap/kunmap functions.
> 
> if we continue to return page_address() and only go into else loop if page
> is not mapped, then there should not be any slow down for exisitng cases
> where memory is mapped?
> 
> Anyway, this was just a thought. I am not too particular about it and
> michael has agreed to get rid of code which was removing mappings for
> crashkernel area. So for the time we don't need above.

Then we can use the standard kimage_load_crash_segment function. But we
should think about adding code that protects the crash kernel memory,
e.g. by making the memory area read-only in the kernel page table. One
reason why we wanted to exclude the crash kernel memory from the memory
that is seen by the Linux kernel is protection from wild stores.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
