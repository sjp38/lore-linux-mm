Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3E2FD6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 05:12:32 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id x35so39707736uax.11
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 02:12:32 -0700 (PDT)
Received: from mail-ua0-x242.google.com (mail-ua0-x242.google.com. [2607:f8b0:400c:c08::242])
        by mx.google.com with ESMTPS id j190si3011577vkh.249.2017.08.14.02.12.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 02:12:31 -0700 (PDT)
Received: by mail-ua0-x242.google.com with SMTP id 80so4690282uas.4
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 02:12:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170814083105.GC26913@bbox>
References: <1502692486-27519-1-git-send-email-zhuhui@xiaomi.com> <20170814083105.GC26913@bbox>
From: Hui Zhu <teawater@gmail.com>
Date: Mon, 14 Aug 2017 17:11:50 +0800
Message-ID: <CANFwon0cB3xveRD+eqLaVXhPs9uWO+Ds+a4W8R8dPU0KH28Jfg@mail.gmail.com>
Subject: Re: [PATCH] zsmalloc: zs_page_migrate: schedule free_work if zspage
 is ZS_EMPTY
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hui Zhu <zhuhui@xiaomi.com>, "ngupta@vflare.org" <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

2017-08-14 16:31 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> Hi Hui,
>
> On Mon, Aug 14, 2017 at 02:34:46PM +0800, Hui Zhu wrote:
>> After commit e2846124f9a2 ("zsmalloc: zs_page_migrate: skip unnecessary
>> loops but not return -EBUSY if zspage is not inuse") zs_page_migrate
>> can handle the ZS_EMPTY zspage.
>>
>> But it will affect the free_work free the zspage.  That will make this
>> ZS_EMPTY zspage stay in system until another zspage wake up free_work.
>>
>> Make this patch let zs_page_migrate wake up free_work if need.
>>
>> Fixes: e2846124f9a2 ("zsmalloc: zs_page_migrate: skip unnecessary loops but not return -EBUSY if zspage is not inuse")
>> Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
>
> This patch makes me remind why I didn't try to migrate empty zspage
> as you did e2846124f9a2. I have forgotten it toally.
>
> We cannot guarantee when the freeing of the page happens if we use
> deferred freeing in zs_page_migrate. However, we returns
> MIGRATEPAGE_SUCCESS which is totally lie.
> Without instant freeing the page, it doesn't help the migration
> situation. No?
>

Sorry I think the reason is I didn't introduce this clear.
After I patch e2846124f9a2.  I got some false in zs_page_isolate:
if (get_zspage_inuse(zspage) == 0) {
spin_unlock(&class->lock);
return false;
}
The page of this zspage was migrated in before.

So I think e2846124f9a2 is OK that MIGRATEPAGE_SUCCESS with the "page".
But it keep the "newpage" with a empty zspage inside system.
Root cause is zs_page_isolate remove it from  ZS_EMPTY list but not
call zs_page_putback "schedule_work(&pool->free_work);".  Because
zs_page_migrate done the job without
"schedule_work(&pool->free_work);"

That is why I made the new patch.

Thanks,
Hui

> I start to wonder why your patch e2846124f9a2 helped your test.
> I will think over the issue with fresh mind after the holiday.
>
>> ---
>>  mm/zsmalloc.c | 10 ++++++++--
>>  1 file changed, 8 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
>> index 62457eb..48ce043 100644
>> --- a/mm/zsmalloc.c
>> +++ b/mm/zsmalloc.c
>> @@ -2035,8 +2035,14 @@ int zs_page_migrate(struct address_space *mapping, struct page *newpage,
>>        * Page migration is done so let's putback isolated zspage to
>>        * the list if @page is final isolated subpage in the zspage.
>>        */
>> -     if (!is_zspage_isolated(zspage))
>> -             putback_zspage(class, zspage);
>> +     if (!is_zspage_isolated(zspage)) {
>> +             /*
>> +              * The page and class is locked, we cannot free zspage
>> +              * immediately so let's defer.
>> +              */
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
