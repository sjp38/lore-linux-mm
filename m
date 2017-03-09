Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 157006B044E
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 05:28:39 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 68so32310688ioh.4
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 02:28:39 -0800 (PST)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20123.outbound.protection.outlook.com. [40.107.2.123])
        by mx.google.com with ESMTPS id b133si2806563iti.73.2017.03.09.02.28.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 09 Mar 2017 02:28:38 -0800 (PST)
Subject: Re: [PATCH] kasan: fix races in quarantine_remove_cache()
References: <20170308151532.5070-1-dvyukov@google.com>
 <1e8cde9e-919d-784c-298c-85efd6efd82c@virtuozzo.com>
 <CACT4Y+a-ZY031qwzJW_SWwDGJEWocoBw85W_q1A0ddB47ciWmw@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <a83b2669-3dd5-7039-d1d8-556ad6f6a3b3@virtuozzo.com>
Date: Thu, 9 Mar 2017 13:29:46 +0300
MIME-Version: 1.0
In-Reply-To: <CACT4Y+a-ZY031qwzJW_SWwDGJEWocoBw85W_q1A0ddB47ciWmw@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, Greg Thelen <gthelen@google.com>

On 03/09/2017 12:37 PM, Dmitry Vyukov wrote:
>>>  void quarantine_reduce(void)
>>>  {
>>>       size_t total_size, new_quarantine_size, percpu_quarantines;
>>>       unsigned long flags;
>>> +     int srcu_idx;
>>>       struct qlist_head to_free = QLIST_INIT;
>>>
>>>       if (likely(READ_ONCE(quarantine_size) <=
>>>                  READ_ONCE(quarantine_max_size)))
>>>               return;
>>>
>>> +     /*
>>> +      * srcu critical section ensures that quarantine_remove_cache()
>>> +      * will not miss objects belonging to the cache while they are in our
>>> +      * local to_free list. srcu is chosen because (1) it gives us private
>>> +      * grace period domain that does not interfere with anything else,
>>> +      * and (2) it allows synchronize_srcu() to return without waiting
>>> +      * if there are no pending read critical sections (which is the
>>> +      * expected case).
>>> +      */
>>> +     srcu_idx = srcu_read_lock(&remove_cache_srcu);
>>
>> I'm puzzled why is SRCU, why not RCU? Given that we take spin_lock in the next line
>> we certainly don't need ability to sleep in read-side critical section.
> 
> I've explained it in the comment above.
 
I've read it. It doesn't explain to me why is SRCU is better than RCU here.
 a) We can't sleep in read-side critical section. Given that RCU is almost always
	faster than SRCU, RCU seem preferable.
 b) synchronize_rcu() indeed might take longer to complete. But does it matter?
    We to synchronize_[s]rcu() only on cache destruction which relatively rare operation and 
    it's not a hotpath. Performance of the quarantine_reduce() is more important

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
