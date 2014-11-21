Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id A76536B006E
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 00:33:27 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id m8so3474723obr.13
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 21:33:27 -0800 (PST)
Received: from mail-ob0-x22a.google.com (mail-ob0-x22a.google.com. [2607:f8b0:4003:c01::22a])
        by mx.google.com with ESMTPS id j8si2892275obk.3.2014.11.20.21.33.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 21:33:26 -0800 (PST)
Received: by mail-ob0-f170.google.com with SMTP id wp18so3504889obc.1
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 21:33:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141121035442.GB10123@bbox>
References: <1416489716-9967-1-git-send-email-opensource.ganesh@gmail.com>
	<20141121035442.GB10123@bbox>
Date: Fri, 21 Nov 2014 13:33:26 +0800
Message-ID: <CADAEsF975+a6Y5dcEu1B2OscQ5JaxD+ZQ1jnFOJ115BXgMqULA@mail.gmail.com>
Subject: Re: [RFC PATCH] mm/zsmalloc: remove unnecessary check
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Hello

2014-11-21 11:54 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> On Thu, Nov 20, 2014 at 09:21:56PM +0800, Mahendran Ganesh wrote:
>> ZS_SIZE_CLASSES is calc by:
>>   ((ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) / ZS_SIZE_CLASS_DELTA + 1)
>>
>> So when i is in [0, ZS_SIZE_CLASSES - 1), the size:
>>   size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA
>> will not be greater than ZS_MAX_ALLOC_SIZE
>>
>> This patch removes the unnecessary check.
>
> It depends on ZS_MIN_ALLOC_SIZE.
> For example, we would change min to 8 but MAX is still 4096.
> ZS_SIZE_CLASSES is (4096 - 8) / 16 + 1 = 256 so 8 + 255 * 16 = 4088,
> which exceeds the max.
Here, 4088 is less than MAX(4096).

ZS_SIZE_CLASSES = (MAX - MIN) / Delta + 1
So, I think the value of
    MIN + (ZS_SIZE_CLASSES - 1) * Delta =
    MIN + ((MAX - MIN) / Delta) * Delta =
    MAX
will not exceed the MAX

Thanks.

>
>>
>> Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
>> ---
>>  mm/zsmalloc.c |    2 --
>>  1 file changed, 2 deletions(-)
>>
>> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
>> index b3b57ef..f2279e2 100644
>> --- a/mm/zsmalloc.c
>> +++ b/mm/zsmalloc.c
>> @@ -973,8 +973,6 @@ struct zs_pool *zs_create_pool(gfp_t flags)
>>               struct size_class *prev_class;
>>
>>               size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA;
>> -             if (size > ZS_MAX_ALLOC_SIZE)
>> -                     size = ZS_MAX_ALLOC_SIZE;
>>               pages_per_zspage = get_pages_per_zspage(size);
>>
>>               /*
>> --
>> 1.7.9.5
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
