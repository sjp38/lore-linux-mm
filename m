Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A1992808B4
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 04:37:28 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id w33so81189117uaw.4
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 01:37:28 -0800 (PST)
Received: from mail-ua0-x229.google.com (mail-ua0-x229.google.com. [2607:f8b0:400c:c08::229])
        by mx.google.com with ESMTPS id e189si2701067vkh.102.2017.03.09.01.37.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 01:37:27 -0800 (PST)
Received: by mail-ua0-x229.google.com with SMTP id f54so68355750uaa.1
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 01:37:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1e8cde9e-919d-784c-298c-85efd6efd82c@virtuozzo.com>
References: <20170308151532.5070-1-dvyukov@google.com> <1e8cde9e-919d-784c-298c-85efd6efd82c@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 9 Mar 2017 10:37:06 +0100
Message-ID: <CACT4Y+a-ZY031qwzJW_SWwDGJEWocoBw85W_q1A0ddB47ciWmw@mail.gmail.com>
Subject: Re: [PATCH] kasan: fix races in quarantine_remove_cache()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, Greg Thelen <gthelen@google.com>

On Thu, Mar 9, 2017 at 10:25 AM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
> On 03/08/2017 06:15 PM, Dmitry Vyukov wrote:
>
>> diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
>> index 6f1ed1630873..075422c3cee3 100644
>> --- a/mm/kasan/quarantine.c
>> +++ b/mm/kasan/quarantine.c
>> @@ -27,6 +27,7 @@
>>  #include <linux/slab.h>
>>  #include <linux/string.h>
>>  #include <linux/types.h>
>> +#include <linux/srcu.h>
>>
>
> Nit: keep alphabetical order please.

Doh, we really need clang-format. This is not productive.
Will send v2.


>>  void quarantine_reduce(void)
>>  {
>>       size_t total_size, new_quarantine_size, percpu_quarantines;
>>       unsigned long flags;
>> +     int srcu_idx;
>>       struct qlist_head to_free = QLIST_INIT;
>>
>>       if (likely(READ_ONCE(quarantine_size) <=
>>                  READ_ONCE(quarantine_max_size)))
>>               return;
>>
>> +     /*
>> +      * srcu critical section ensures that quarantine_remove_cache()
>> +      * will not miss objects belonging to the cache while they are in our
>> +      * local to_free list. srcu is chosen because (1) it gives us private
>> +      * grace period domain that does not interfere with anything else,
>> +      * and (2) it allows synchronize_srcu() to return without waiting
>> +      * if there are no pending read critical sections (which is the
>> +      * expected case).
>> +      */
>> +     srcu_idx = srcu_read_lock(&remove_cache_srcu);
>
> I'm puzzled why is SRCU, why not RCU? Given that we take spin_lock in the next line
> we certainly don't need ability to sleep in read-side critical section.

I've explained it in the comment above.




>>       spin_lock_irqsave(&quarantine_lock, flags);
>>
>>       /*
>> @@ -237,6 +257,7 @@ void quarantine_reduce(void)
>>       spin_unlock_irqrestore(&quarantine_lock, flags);
>>
>>       qlist_free_all(&to_free, NULL);
>> +     srcu_read_unlock(&remove_cache_srcu, srcu_idx);
>>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
