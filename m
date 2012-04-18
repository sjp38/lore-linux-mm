Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 984DA6B00ED
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 09:49:26 -0400 (EDT)
Date: Wed, 18 Apr 2012 08:49:24 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: how to avoid allocating or freeze MOVABLE memory in userspace
In-Reply-To: <CAN1soZyJ_zURkhV3aav5oQ6gU1CcQLsUsQKDe38gdOhapkc8jw@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1204180845390.14709@router.home>
References: <CAN1soZzEuhQQYf7fNqOeMYT3Z-8VMix+1ihD77Bjtf+Do3x3DA@mail.gmail.com> <alpine.DEB.2.00.1204131326170.15905@router.home> <CAN1soZyQuiYU_1f0G0eDqF-9WwzjgSgmr3QBh8cpkF+r1r7HrA@mail.gmail.com> <alpine.DEB.2.00.1204160853530.7726@router.home>
 <CAN1soZyJ_zURkhV3aav5oQ6gU1CcQLsUsQKDe38gdOhapkc8jw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haojian Zhuang <haojian.zhuang@gmail.com>
Cc: linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, m.szyprowski@samsung.com

On Wed, 18 Apr 2012, Haojian Zhuang wrote:

> > Run get_user_pages() on the memory you are interest in pinning. See how
> > other drivers do that by looking up other use cases. F.e. ib_umem_get()
> > does a similar thing.
> >
> >
> Got it. And I think there's conflict in CMA.
>
> For example, user process A malloc() memory, page->_count is 1. After
> using get_user_pages()
> in device driver for DMA usage, page->_count becomes 2.
>
> If the page is in CMA region, it results migrate_pages() returns
> -EAGAIN. But error handling in CMA is in below.

The increase of the page count should be temporary. That is why
migrate_pages() uses -EAGAIN to signify a temporary inability to migrate
the page.

Xen uses a page flag for pinned pages. IMHO that could be generalized and
used instead of increasing the page count. Or it could be checked in
addition and change the return value of migrate_pages().

>                 ret = alloc_contig_range(pfn, pfn + count, MIGRATE_CMA);
>                 if (ret == 0) {
>                         bitmap_set(cma->bitmap, pageno, count);
>                         break;
>                 } else if (ret != -EBUSY) {
>                         goto error;
>                 }
>
> Since EAGAIN doesn't equal to EBUSY, dma_alloc_from_contiguous()
> aborts. Should dma_alloc_from_contiguous() handle EAGAIN?

You need to talk to the CMA developers for this one. If there is a pinned
page in that range then definitely alloc_contig_range needs to fail. In
the case of EAGAIN (and correct marking of pinned pages elsewhere in the
kernel) we could handle the EGAIN return value by trying again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
