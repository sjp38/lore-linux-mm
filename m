Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 6A0D56B007E
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 03:36:36 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so6722963vbb.14
        for <linux-mm@kvack.org>; Wed, 18 Apr 2012 00:36:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1204160853530.7726@router.home>
References: <CAN1soZzEuhQQYf7fNqOeMYT3Z-8VMix+1ihD77Bjtf+Do3x3DA@mail.gmail.com>
	<alpine.DEB.2.00.1204131326170.15905@router.home>
	<CAN1soZyQuiYU_1f0G0eDqF-9WwzjgSgmr3QBh8cpkF+r1r7HrA@mail.gmail.com>
	<alpine.DEB.2.00.1204160853530.7726@router.home>
Date: Wed, 18 Apr 2012 15:36:35 +0800
Message-ID: <CAN1soZyJ_zURkhV3aav5oQ6gU1CcQLsUsQKDe38gdOhapkc8jw@mail.gmail.com>
Subject: Re: how to avoid allocating or freeze MOVABLE memory in userspace
From: Haojian Zhuang <haojian.zhuang@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, m.szyprowski@samsung.com

On Mon, Apr 16, 2012 at 9:55 PM, Christoph Lameter <cl@linux.com> wrote:
> On Sat, 14 Apr 2012, Haojian Zhuang wrote:
>
>> On Sat, Apr 14, 2012 at 2:27 AM, Christoph Lameter <cl@linux.com> wrote:
>> > On Fri, 13 Apr 2012, Haojian Zhuang wrote:
>> >
>> >> I have one question on memory migration. As we know, malloc() from
>> >> user app will allocate MIGRATE_MOVABLE pages. But if we want to use
>> >> this memory as DMA usage, we can't accept MIGRATE_MOVABLE type. Could
>> >> we change its behavior before DMA working?
>> >
>> > MIGRATE_MOVABLE works fine for DMA. If you keep a reference from a device
>> > driver to user pages then you will have to increase the page refcount
>> > which will in turn pin the page and make it non movable for as long as you
>> > keep the refcount.
>>
>> Hi Christoph,
>>
>> Thanks for your illustration. But it's a little abstract. Could you
>> give me a simple example
>> or show me the code?
>
> Run get_user_pages() on the memory you are interest in pinning. See how
> other drivers do that by looking up other use cases. F.e. ib_umem_get()
> does a similar thing.
>
>
Got it. And I think there's conflict in CMA.

For example, user process A malloc() memory, page->_count is 1. After
using get_user_pages()
in device driver for DMA usage, page->_count becomes 2.

If the page is in CMA region, it results migrate_pages() returns
-EAGAIN. But error handling in CMA is in below.

                ret = alloc_contig_range(pfn, pfn + count, MIGRATE_CMA);
                if (ret == 0) {
                        bitmap_set(cma->bitmap, pageno, count);
                        break;
                } else if (ret != -EBUSY) {
                        goto error;
                }

Since EAGAIN doesn't equal to EBUSY, dma_alloc_from_contiguous()
aborts. Should dma_alloc_from_contiguous() handle EAGAIN?

Best Regards
Haojian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
