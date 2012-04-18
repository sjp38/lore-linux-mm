Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id DD47C6B0092
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 11:10:07 -0400 (EDT)
Received: from euspt2 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M2O008MNKQRR4@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 18 Apr 2012 16:08:51 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M2O00019KSRKV@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 18 Apr 2012 16:10:03 +0100 (BST)
Date: Wed, 18 Apr 2012 17:10:02 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: how to avoid allocating or freeze MOVABLE memory in userspace
In-reply-to: 
 <CAN1soZyJ_zURkhV3aav5oQ6gU1CcQLsUsQKDe38gdOhapkc8jw@mail.gmail.com>
Message-id: <016501cd1d75$54173a80$fc45af80$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: 
 <CAN1soZzEuhQQYf7fNqOeMYT3Z-8VMix+1ihD77Bjtf+Do3x3DA@mail.gmail.com>
 <alpine.DEB.2.00.1204131326170.15905@router.home>
 <CAN1soZyQuiYU_1f0G0eDqF-9WwzjgSgmr3QBh8cpkF+r1r7HrA@mail.gmail.com>
 <alpine.DEB.2.00.1204160853530.7726@router.home>
 <CAN1soZyJ_zURkhV3aav5oQ6gU1CcQLsUsQKDe38gdOhapkc8jw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Haojian Zhuang' <haojian.zhuang@gmail.com>, 'Christoph Lameter' <cl@linux.com>
Cc: linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, 'Michal Nazarewicz' <mnazarewicz@gmail.com>

Hello,

On Wednesday, April 18, 2012 9:37 AM Haojian Zhuang wrote:

> On Mon, Apr 16, 2012 at 9:55 PM, Christoph Lameter <cl@linux.com> wrote:
> > On Sat, 14 Apr 2012, Haojian Zhuang wrote:
> >
> >> On Sat, Apr 14, 2012 at 2:27 AM, Christoph Lameter <cl@linux.com> wrote:
> >> > On Fri, 13 Apr 2012, Haojian Zhuang wrote:
> >> >
> >> >> I have one question on memory migration. As we know, malloc() from
> >> >> user app will allocate MIGRATE_MOVABLE pages. But if we want to use
> >> >> this memory as DMA usage, we can't accept MIGRATE_MOVABLE type. Could
> >> >> we change its behavior before DMA working?
> >> >
> >> > MIGRATE_MOVABLE works fine for DMA. If you keep a reference from a device
> >> > driver to user pages then you will have to increase the page refcount
> >> > which will in turn pin the page and make it non movable for as long as you
> >> > keep the refcount.
> >>
> >> Hi Christoph,
> >>
> >> Thanks for your illustration. But it's a little abstract. Could you
> >> give me a simple example
> >> or show me the code?
> >
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
> 
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

Yes, it definitely should threat EAGAIN the same way as EBUSY. I think
I've double checked that alloc_contig_range return only EBUSY in case of
migration failure, but it looks that I need to check it once again. Thanks
for spotting the possible bug.

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
