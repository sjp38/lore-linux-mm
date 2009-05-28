Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8CE5A6B0055
	for <linux-mm@kvack.org>; Thu, 28 May 2009 05:58:14 -0400 (EDT)
Date: Thu, 28 May 2009 10:59:04 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Inconsistency (bug) of vm_insert_page with high order
	allocations
Message-ID: <20090528095904.GD10334@csn.ul.ie>
References: <202cde0e0905272207y2926d679s7380a0f26f6c6e71@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <202cde0e0905272207y2926d679s7380a0f26f6c6e71@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolex@gmail.com>
Cc: linux-mm@kvack.org, greg@kroah.com, vijaykumar@bravegnu.org
List-ID: <linux-mm.kvack.org>

On Thu, May 28, 2009 at 05:07:01PM +1200, Alexey Korolev wrote:
> Hi,
> I have the following issue. I need to allocate a big chunk of
> contiguous memory and then transfer it to user mode applications to
> let them operate with given buffers.
> 
> To allocate memory I use standard function alloc_apges(gfp_mask,
> order) which asks buddy allocator to give a chunk of memory of given
> "order".
> Allocator returns page and also sets page count to 1 but for page of
> high order. I.e. pages 2,3 etc inside high order allocation will have
> page->_count==0.
> If I try to mmap allocated area to user space vm_insert_page will
> return error as pages 2,3, etc are not refcounted.
> 

page = alloc_pages(high_order);
split_page(page, high_order);

That will fix up the ref-counting of each of the individual pages. You are
then responsible for freeing them individually. As you are inserting these
into userspace, I suspect that's ok.

> The issue could be workaround if to set-up refcount to 1 manually for
> each page. But this workaround is not very good, because page refcount
> is used inside mm subsystem only.
> 

And you would have reimplemented split_page().

> While searching a driver with the similar solutions in kernel tree it
> was found a driver which suffers from exactly the same
> problem("poch"). So it is not single problem.
> 
> What you could suggest to workaround the problem except hacks with page count?
> May be it makes sence to introduce wm_insert_pages function?
> 
> In this case users would have the following picture:
> zero order page: alloc_page <-> vm_instert_page
> non zero order  : alloc_pages(..., order) <-> vm_instert_pages(...., order)
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
