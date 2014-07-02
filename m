Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id 718AB6B0031
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 02:50:13 -0400 (EDT)
Received: by mail-yh0-f51.google.com with SMTP id f10so6555538yha.24
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 23:50:13 -0700 (PDT)
Received: from mail-yk0-x235.google.com (mail-yk0-x235.google.com [2607:f8b0:4002:c07::235])
        by mx.google.com with ESMTPS id r30si23951578yhm.123.2014.07.01.23.50.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 23:50:12 -0700 (PDT)
Received: by mail-yk0-f181.google.com with SMTP id 9so6224388ykp.40
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 23:50:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1407012101160.1009@eggly.anvils>
References: <1404272573-24448-1-git-send-email-pingfank@linux.vnet.ibm.com>
	<alpine.LSU.2.11.1407012101160.1009@eggly.anvils>
Date: Wed, 2 Jul 2014 14:50:12 +0800
Message-ID: <CAFgQCTuUPm0EbOYsJOMdM5MV2qqGuCbcSSB30UvwK6=6kbCUgg@mail.gmail.com>
Subject: Re: [PATCH] mm: swap: avoid to writepage when a page is !PageSwapCache
From: Liu ping fan <kernelfans@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, Jul 2, 2014 at 12:29 PM, Hugh Dickins <hughd@google.com> wrote:
> On Wed, 2 Jul 2014, Liu Ping Fan wrote:
>
>> There is race between do_swap_page() and swap_writepage(), if
>> do_swap_page() had deleted a page from swap cache, there is no need
>> to write it. So changing the ret of try_to_free_swap() to make
>> swap_writepage() aware of this scene.
>
> Is this an inefficiency that you have noticed in practice,
> or something that you think you spotted by code inspection?
>

just  spotted by code inspection.
> I don't see how it can happen: all the places I know of that call
> swap_writepage() (including vmscan.c's mapping->a_ops->writepage)
> have not dropped page lock since setting or checking PageSwapCache,
> and page lock is supposed to protect against deletion from swap cache.
>
> Has that changed?  Please point out where.
>

No, my fault.  Thanks for making me aware of this.
>>
>> Signed-off-by: Liu Ping Fan <pingfank@linux.vnet.ibm.com>
>> ---
>>  mm/swapfile.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/swapfile.c b/mm/swapfile.c
>> index 4c524f7..9d80671 100644
>> --- a/mm/swapfile.c
>> +++ b/mm/swapfile.c
>> @@ -910,7 +910,7 @@ int try_to_free_swap(struct page *page)
>>       VM_BUG_ON_PAGE(!PageLocked(page), page);
>>
>>       if (!PageSwapCache(page))
>> -             return 0;
>> +             return -1;
>
> Previously it returned either 0 or 1, which is what __try_to_reclaim_swap()
> says it returns; so better to stick to 0 or 1, unless you have good reason
> to add a distinct value.
>
> It's true that by the time __try_to_reclaim_swap() has got the page lock,
> the page might have been removed from swap cache, and we could then treat
> that as swap_was_freed (even though it was not freed by the caller).
>
> But it's a very narrow window, and no great advantage to do so:
> I don't think it's worth changing try_to_free_swap() semantics for,
> but you could persuade us.
>

Got it, and it is meaningless to do that.

Thanks,
Fan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
