Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 382316B0255
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 13:09:50 -0400 (EDT)
Received: by igcpb10 with SMTP id pb10so103657465igc.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 10:09:50 -0700 (PDT)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com. [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id y3si13665018igl.47.2015.09.22.10.09.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 10:09:49 -0700 (PDT)
Received: by igxx6 with SMTP id x6so13483330igx.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 10:09:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAMJBoFNGY2f3a7RV_y0buqF+dm23pXhUF=q6mTU3Bcj0AXF=LQ@mail.gmail.com>
References: <20150916134857.e4a71f601a1f68cfa16cb361@gmail.com>
 <20150916135048.fbd50fac5e91244ab9731b82@gmail.com> <CALZtONCF6mSU1dKkv2bX+koM4LHciQ0TJciQx4k-PZzs8_mTNQ@mail.gmail.com>
 <CAMJBoFNGY2f3a7RV_y0buqF+dm23pXhUF=q6mTU3Bcj0AXF=LQ@mail.gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 22 Sep 2015 13:09:09 -0400
Message-ID: <CALZtONCgqF7MiGUkLaGm8sTfPu-yd2gMTgq2Y1DJNOpFdBEt8A@mail.gmail.com>
Subject: Re: [PATCH 1/2] zbud: allow PAGE_SIZE allocations
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Seth Jennings <sjennings@variantweb.net>

On Tue, Sep 22, 2015 at 6:18 AM, Vitaly Wool <vitalywool@gmail.com> wrote:
> Hi Dan,
>
> On Mon, Sep 21, 2015 at 6:17 PM, Dan Streetman <ddstreet@ieee.org> wrote:
>> Please make sure to cc Seth also, he's the owner of zbud.
>
> Sure :)
>
> <snip>
>>> @@ -514,8 +552,17 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
>>>                 return -EINVAL;
>>>         }
>>>         for (i = 0; i < retries; i++) {
>>> -               zhdr = list_tail_entry(&pool->lru, struct zbud_header, lru);
>>> -               list_del(&zhdr->lru);
>>> +               page = list_tail_entry(&pool->lru, struct page, lru);
>>> +               zhdr = page_address(page);
>>> +               list_del(&page->lru);
>>> +               /* Uncompressed zbud page? just run eviction and free it */
>>> +               if (page->flags & PG_uncompressed) {
>>> +                       page->flags &= ~PG_uncompressed;
>>> +                       spin_unlock(&pool->lock);
>>> +                       pool->ops->evict(pool, encode_handle(zhdr, FULL));
>>> +                       __free_page(page);
>>> +                       return 0;
>>
>> again, don't be redundant.  change the function to handle full-sized
>> pages, don't repeat the function in an if() block for a special case.
>
> Well, this case is a little tricky. How to process a zbud page in
> zbud_reclaim_page() is defined basing on the assumption there is a
> zhdr at the beginning of the page. What can be done here IMV is either
> of the following:

aha, this is why you used the page flag.

> * add a constant magic number to zhdr and check for it, if the check
> fails, it is a type FULL page
> * add a CRC field to zhdr, if CRC check over assumed zhdr fails,  it
> is a type FULL page

neither of those; you can't guarantee the magic number won't naturally
occur in a page.

> * use a field from struct page to indicate its type

sure, you could use a pre-existing field from struct page, like the
page->private field.

>
> The last option still looks better to me.
>
> ~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
