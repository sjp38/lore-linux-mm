Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CEA9D5F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:45:37 -0400 (EDT)
Date: Tue, 2 Jun 2009 09:38:52 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Inconsistency (bug) of vm_insert_page with high order
	allocations
Message-ID: <20090602083852.GC5960@csn.ul.ie>
References: <202cde0e0905272207y2926d679s7380a0f26f6c6e71@mail.gmail.com> <20090528095904.GD10334@csn.ul.ie> <202cde0e0905292227tc619a17h41df83d22bc922fa@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <202cde0e0905292227tc619a17h41df83d22bc922fa@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolex@gmail.com>
Cc: linux-mm@kvack.org, greg@kroah.com, vijaykumar@bravegnu.org
List-ID: <linux-mm.kvack.org>

On Sat, May 30, 2009 at 05:27:15PM +1200, Alexey Korolev wrote:
> Hi,
> >> To allocate memory I use standard function alloc_apges(gfp_mask,
> >> order) which asks buddy allocator to give a chunk of memory of given
> >> "order".
> >> Allocator returns page and also sets page count to 1 but for page of
> >> high order. I.e. pages 2,3 etc inside high order allocation will have
> >> page->_count==0.
> >> If I try to mmap allocated area to user space vm_insert_page will
> >> return error as pages 2,3, etc are not refcounted.
> >>
> >
> > page = alloc_pages(high_order);
> > split_page(page, high_order);
> >
> > That will fix up the ref-counting of each of the individual pages. You are
> > then responsible for freeing them individually. As you are inserting these
> > into userspace, I suspect that's ok.
> 
> It seems it is the only way I have now. It is not so elegant - but should work.
> Thanks for good advise.
> 
> BTW: Just out of curiosity what limits mapping high ordered pages into
> user space. I tried to find any except the check in vm_insert but
> failed. Is this checks caused by possible swapping?
> 

Nothing limits it as such other than it's usually not required. There is
nothing really that special about high-order pages other than they are
physically contiguous. The expectation is normally that userspace does
not care about physical contiguity.

There is expected to be a 1 to 1 mapping of PTE to ref-counted pages so that
they get freed at the right times so it's not just about swapping.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
