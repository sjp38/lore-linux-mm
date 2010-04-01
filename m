Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D26D56B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 21:30:43 -0400 (EDT)
Received: by pvg2 with SMTP id 2so152080pvg.14
        for <linux-mm@kvack.org>; Wed, 31 Mar 2010 18:30:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2f11576a1003310717y1fe1aa66p8f92135d5eec29e6@mail.gmail.com>
References: <1270044631-8576-1-git-send-email-user@bob-laptop>
	 <2f11576a1003310717y1fe1aa66p8f92135d5eec29e6@mail.gmail.com>
Date: Thu, 1 Apr 2010 09:30:42 +0800
Message-ID: <w2gcf18f8341003311830pb0d697efi721641050c88a254@mail.gmail.com>
Subject: Re: [PATCH] __isolate_lru_page: skip unneeded mode check
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/31/10, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 2010/3/31 Bob Liu <lliubbo@gmail.com>:
>> From: Bob Liu <lliubbo@gmail.com>
>>
>> Whether mode is ISOLATE_BOTH or not, we should compare
>> page_is_file_cache with argument file.
>>
>> And there is no more need not when checking the active state.
>>
>> Signed-off-by: Bob Liu <lliubbo@gmail.com>
>> ---
>>  mm/vmscan.c |    9 ++-------
>>  1 files changed, 2 insertions(+), 7 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index e0e5f15..34d7e3d 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -862,15 +862,10 @@ int __isolate_lru_page(struct page *page, int mode,
>> int file)
>>        if (!PageLRU(page))
>>                return ret;
>>
>> -       /*
>> -        * When checking the active state, we need to be sure we are
>> -        * dealing with comparible boolean values.  Take the logical not
>> -        * of each.
>> -        */
>> -       if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode))
>> +       if (mode != ISOLATE_BOTH && (PageActive(page) != mode))
>>                return ret;
>
> no. please read the comment.
>

Hm,. I have read it, but still miss it :-).
PageActive(page) will return an int 0 or 1, mode is also int 0 or 1(
already != ISOLATE_BOTH).
There are comparible and why must to be sure to boolean values?

>> -       if (mode != ISOLATE_BOTH && page_is_file_cache(page) != file)
>> +       if (page_is_file_cache(page) != file)
>>                return ret;
>
> no. please consider lumpy reclaim.
>

During lumpy reclaim mode is ISOLATE_BOTH, that case we don't check
page_is_file_cache() ?  Would you please explain it a little more ,i
am still unclear about it.
Thanks a lot.
-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
