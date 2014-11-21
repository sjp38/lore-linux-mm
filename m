Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 722DD6B006E
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 00:22:23 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id wn1so3491996obc.31
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 21:22:23 -0800 (PST)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id uk5si2877055oeb.0.2014.11.20.21.22.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 21:22:22 -0800 (PST)
Received: by mail-oi0-f48.google.com with SMTP id u20so3123069oif.21
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 21:22:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALZtONAdpiP+DZfJBYG9EYN+8pTToMnAaUGemZ-r7x8YcQXbCQ@mail.gmail.com>
References: <1416488913-9691-1-git-send-email-opensource.ganesh@gmail.com>
	<CALZtONAdpiP+DZfJBYG9EYN+8pTToMnAaUGemZ-r7x8YcQXbCQ@mail.gmail.com>
Date: Fri, 21 Nov 2014 13:22:21 +0800
Message-ID: <CADAEsF8+BbQO0-cbL0KRxbaH_nisG=_Gukr=_=nkYaCwR+sqQw@mail.gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: avoid duplicate assignment of prev_class
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Hello

2014-11-21 11:22 GMT+08:00 Dan Streetman <ddstreet@ieee.org>:
> On Thu, Nov 20, 2014 at 8:08 AM, Mahendran Ganesh
> <opensource.ganesh@gmail.com> wrote:
>> In zs_create_pool(), prev_class is assigned (ZS_SIZE_CLASSES - 1)
>> times. And the prev_class only references to the previous alloc
>> size_class. So we do not need unnecessary assignement.
>>
>> This patch modifies *prev_class* to *prev_alloc_class*. And the
>> *prev_alloc_class* will only be assigned when a new size_class
>> structure is allocated.
>>
>> Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
>> ---
>>  mm/zsmalloc.c |    9 +++++----
>>  1 file changed, 5 insertions(+), 4 deletions(-)
>>
>> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
>> index b3b57ef..ac2b396 100644
>> --- a/mm/zsmalloc.c
>> +++ b/mm/zsmalloc.c
>> @@ -970,7 +970,7 @@ struct zs_pool *zs_create_pool(gfp_t flags)
>>                 int size;
>>                 int pages_per_zspage;
>>                 struct size_class *class;
>> -               struct size_class *prev_class;
>> +               struct size_class *uninitialized_var(prev_alloc_class);
>
> +               struct size_class *prev_class = NULL;
>
> Use the fact it's unset below, so set it to NULL here

Yes, You are right. I will change it in next resend.
Thanks for your review.

>
>>
>>                 size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA;
>>                 if (size > ZS_MAX_ALLOC_SIZE)
>> @@ -987,9 +987,8 @@ struct zs_pool *zs_create_pool(gfp_t flags)
>>                  * previous size_class if possible.
>>                  */
>>                 if (i < ZS_SIZE_CLASSES - 1) {
>> -                       prev_class = pool->size_class[i + 1];
>> -                       if (can_merge(prev_class, size, pages_per_zspage)) {
>> -                               pool->size_class[i] = prev_class;
>> +                       if (can_merge(prev_alloc_class, size, pages_per_zspage)) {
>> +                               pool->size_class[i] = prev_alloc_class;
>
> simplify more, we can check if this is the first iteration by looking
> at prev_class, e.g.:
>
>                 if (prev_class) {
>                        if (can_merge(prev_class, size, pages_per_zspage)) {
>                                pool->size_class[i] = prev_class;
>
>
>>                                 continue;
>>                         }
>>                 }
>> @@ -1003,6 +1002,8 @@ struct zs_pool *zs_create_pool(gfp_t flags)
>>                 class->pages_per_zspage = pages_per_zspage;
>>                 spin_lock_init(&class->lock);
>>                 pool->size_class[i] = class;
>> +
>> +               prev_alloc_class = class;
>>         }
>>
>>         pool->flags = flags;
>> --
>> 1.7.9.5
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
