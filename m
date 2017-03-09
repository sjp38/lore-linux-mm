Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 61B772808B4
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 06:08:17 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id k133so85330837oia.6
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 03:08:17 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0131.outbound.protection.outlook.com. [104.47.0.131])
        by mx.google.com with ESMTPS id o41si2842959oto.107.2017.03.09.03.08.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 09 Mar 2017 03:08:16 -0800 (PST)
Subject: Re: [PATCH] kasan: fix races in quarantine_remove_cache()
References: <20170308151532.5070-1-dvyukov@google.com>
 <1e8cde9e-919d-784c-298c-85efd6efd82c@virtuozzo.com>
 <CACT4Y+a-ZY031qwzJW_SWwDGJEWocoBw85W_q1A0ddB47ciWmw@mail.gmail.com>
 <a83b2669-3dd5-7039-d1d8-556ad6f6a3b3@virtuozzo.com>
 <CACT4Y+aZLKnmUw-R-SEzCaYbBnrYx--g8q_yW8Z+Qk=CQcQqFQ@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <6b83d94d-3b73-4ba5-d8f0-16e19786a88c@virtuozzo.com>
Date: Thu, 9 Mar 2017 14:09:24 +0300
MIME-Version: 1.0
In-Reply-To: <CACT4Y+aZLKnmUw-R-SEzCaYbBnrYx--g8q_yW8Z+Qk=CQcQqFQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, Greg Thelen <gthelen@google.com>



On 03/09/2017 01:43 PM, Dmitry Vyukov wrote:
> On Thu, Mar 9, 2017 at 11:29 AM, Andrey Ryabinin
> <aryabinin@virtuozzo.com> wrote:
>> On 03/09/2017 12:37 PM, Dmitry Vyukov wrote:
>>>>>  void quarantine_reduce(void)
>>>>>  {
>>>>>       size_t total_size, new_quarantine_size, percpu_quarantines;
>>>>>       unsigned long flags;
>>>>> +     int srcu_idx;
>>>>>       struct qlist_head to_free = QLIST_INIT;
>>>>>
>>>>>       if (likely(READ_ONCE(quarantine_size) <=
>>>>>                  READ_ONCE(quarantine_max_size)))
>>>>>               return;
>>>>>
>>>>> +     /*
>>>>> +      * srcu critical section ensures that quarantine_remove_cache()
>>>>> +      * will not miss objects belonging to the cache while they are in our
>>>>> +      * local to_free list. srcu is chosen because (1) it gives us private
>>>>> +      * grace period domain that does not interfere with anything else,
>>>>> +      * and (2) it allows synchronize_srcu() to return without waiting
>>>>> +      * if there are no pending read critical sections (which is the
>>>>> +      * expected case).
>>>>> +      */
>>>>> +     srcu_idx = srcu_read_lock(&remove_cache_srcu);
>>>>
>>>> I'm puzzled why is SRCU, why not RCU? Given that we take spin_lock in the next line
>>>> we certainly don't need ability to sleep in read-side critical section.
>>>
>>> I've explained it in the comment above.
>>
>> I've read it. It doesn't explain to me why is SRCU is better than RCU here.
>>  a) We can't sleep in read-side critical section. Given that RCU is almost always
>>         faster than SRCU, RCU seem preferable.
>>  b) synchronize_rcu() indeed might take longer to complete. But does it matter?
>>     We to synchronize_[s]rcu() only on cache destruction which relatively rare operation and
>>     it's not a hotpath. Performance of the quarantine_reduce() is more important
> 
> 
> As far as I understand container destruction will cause destruction of
> a bunch of caches. synchronize_sched() caused serious problems on
> these paths in the past, see 86d9f48534e800e4d62cdc1b5aaf539f4c1d47d6.
> srcu_read_lock/unlock are not too expensive, that's some atomic
> operations on per-cpu variables, so cheaper than the existing
> spinlock. And this is already not the fast-fast-path (which is
> kmalloc/free). But hundreds of synchronize_rcu in a row can cause
> hangup and panic. The fact that it's a rare operation won't help. Also
> if we free a substantial batch of objects under rcu lock, it will
> affect latency of all rcu callbacks in kernel which can have undesired
> effects.
> I am trying to make this more predictable and tolerant to unexpected
> workloads, rather than sacrifice everything in the name of fast path
> performance.
> 

Ok, fair enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
