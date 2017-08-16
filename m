Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4183B6B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 22:49:56 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id c80so3031339oig.7
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 19:49:56 -0700 (PDT)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id s131si7769829ois.45.2017.08.15.19.49.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 19:49:55 -0700 (PDT)
Received: by mail-oi0-x243.google.com with SMTP id q70so2456397oic.2
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 19:49:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170816021339.GA23451@blaptop>
References: <1502704590-3129-1-git-send-email-zhuhui@xiaomi.com> <20170816021339.GA23451@blaptop>
From: Hui Zhu <teawater@gmail.com>
Date: Wed, 16 Aug 2017 10:49:14 +0800
Message-ID: <CANFwon3kDOUKcUBmihVzSwkQ34MOGkEnAkOdHET+uv8XBoAWfQ@mail.gmail.com>
Subject: Re: [PATCH v2] zsmalloc: zs_page_migrate: schedule free_work if
 zspage is ZS_EMPTY
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hui Zhu <zhuhui@xiaomi.com>, "ngupta@vflare.org" <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi Minchan,

2017-08-16 10:13 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> Hi Hui,
>
> On Mon, Aug 14, 2017 at 05:56:30PM +0800, Hui Zhu wrote:
>> After commit e2846124f9a2 ("zsmalloc: zs_page_migrate: skip unnecessary
>
> This patch is not merged yet so the hash is invalid.
> That means we may fold this patch to [1] in current mmotm.
>
> [1] zsmalloc-zs_page_migrate-skip-unnecessary-loops-but-not-return-ebusy-if-zspage-is-not-inuse-fix.patch
>
>> loops but not return -EBUSY if zspage is not inuse") zs_page_migrate
>> can handle the ZS_EMPTY zspage.
>>
>> But I got some false in zs_page_isolate:
>>       if (get_zspage_inuse(zspage) == 0) {
>>               spin_unlock(&class->lock);
>>               return false;
>>       }
>
> I also realized we should make zs_page_isolate succeed on empty zspage
> because we allow the empty zspage migration from now on.
> Could you send a patch for that as well?

OK.  I will make a patch for that later.

Thanks,
Hui

>
>> The page of this zspage was migrated in before.
>>
>> The reason is commit e2846124f9a2 ("zsmalloc: zs_page_migrate: skip
>> unnecessary loops but not return -EBUSY if zspage is not inuse") just
>> handle the "page" but not "newpage" then it keep the "newpage" with
>> a empty zspage inside system.
>> Root cause is zs_page_isolate remove it from ZS_EMPTY list but not
>> call zs_page_putback "schedule_work(&pool->free_work);".  Because
>> zs_page_migrate done the job without "schedule_work(&pool->free_work);"
>>
>> Make this patch let zs_page_migrate wake up free_work if need.
>>
>> Fixes: e2846124f9a2 ("zsmalloc: zs_page_migrate: skip unnecessary loops but not return -EBUSY if zspage is not inuse")
>> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
>> ---
>>  mm/zsmalloc.c | 13 +++++++++++--
>>  1 file changed, 11 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
>> index 62457eb..c6cc77c 100644
>> --- a/mm/zsmalloc.c
>> +++ b/mm/zsmalloc.c
>> @@ -2035,8 +2035,17 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
>>        * Page migration is done so let's putback isolated zspage to
>>        * the list if @page is final isolated subpage in the zspage.
>>        */
>> -     if (!is_zspage_isolated(zspage))
>> -             putback_zspage(class, zspage);
>> +     if (!is_zspage_isolated(zspage)) {
>> +             /*
>> +              * Page will be freed in following part. But newpage and
>> +              * zspage will stay in system if zspage is in ZS_EMPTY
>> +              * list.  So call free_work to free it.
>> +              * The page and class is locked, we cannot free zspage
>> +              * immediately so let's defer.
>> +              */
>
> How about this?
>
>                 /*
>                  * Since we allow empty zspage migration, putback of zspage
>                  * should free empty zspage. Otherwise, it could make a leak
>                  * until upcoming free_work is done, which isn't guaranteed.
>                  */
>> +             if (putback_zspage(class, zspage) == ZS_EMPTY)
>> +                     schedule_work(&pool->free_work);
>> +     }
>>
>>       reset_page(page);
>>       put_page(page);
>> --
>> 1.9.1
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
