Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id C80AF6B0038
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 06:18:59 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so184532846wic.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 03:18:59 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id fa17si2858546wid.21.2015.09.22.03.18.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 03:18:58 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so16376945wic.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 03:18:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALZtONCF6mSU1dKkv2bX+koM4LHciQ0TJciQx4k-PZzs8_mTNQ@mail.gmail.com>
References: <20150916134857.e4a71f601a1f68cfa16cb361@gmail.com>
	<20150916135048.fbd50fac5e91244ab9731b82@gmail.com>
	<CALZtONCF6mSU1dKkv2bX+koM4LHciQ0TJciQx4k-PZzs8_mTNQ@mail.gmail.com>
Date: Tue, 22 Sep 2015 12:18:58 +0200
Message-ID: <CAMJBoFNGY2f3a7RV_y0buqF+dm23pXhUF=q6mTU3Bcj0AXF=LQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] zbud: allow PAGE_SIZE allocations
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Seth Jennings <sjennings@variantweb.net>

Hi Dan,

On Mon, Sep 21, 2015 at 6:17 PM, Dan Streetman <ddstreet@ieee.org> wrote:
> Please make sure to cc Seth also, he's the owner of zbud.

Sure :)

<snip>
>> @@ -514,8 +552,17 @@ int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries)
>>                 return -EINVAL;
>>         }
>>         for (i = 0; i < retries; i++) {
>> -               zhdr = list_tail_entry(&pool->lru, struct zbud_header, lru);
>> -               list_del(&zhdr->lru);
>> +               page = list_tail_entry(&pool->lru, struct page, lru);
>> +               zhdr = page_address(page);
>> +               list_del(&page->lru);
>> +               /* Uncompressed zbud page? just run eviction and free it */
>> +               if (page->flags & PG_uncompressed) {
>> +                       page->flags &= ~PG_uncompressed;
>> +                       spin_unlock(&pool->lock);
>> +                       pool->ops->evict(pool, encode_handle(zhdr, FULL));
>> +                       __free_page(page);
>> +                       return 0;
>
> again, don't be redundant.  change the function to handle full-sized
> pages, don't repeat the function in an if() block for a special case.

Well, this case is a little tricky. How to process a zbud page in
zbud_reclaim_page() is defined basing on the assumption there is a
zhdr at the beginning of the page. What can be done here IMV is either
of the following:
* add a constant magic number to zhdr and check for it, if the check
fails, it is a type FULL page
* add a CRC field to zhdr, if CRC check over assumed zhdr fails,  it
is a type FULL page
* use a field from struct page to indicate its type

The last option still looks better to me.

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
