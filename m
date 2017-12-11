Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7C69B6B0033
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 13:00:21 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g8so13487764pgs.14
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 10:00:21 -0800 (PST)
Received: from out0-230.mail.aliyun.com (out0-230.mail.aliyun.com. [140.205.0.230])
        by mx.google.com with ESMTPS id 1si10224457plw.770.2017.12.11.10.00.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Dec 2017 10:00:18 -0800 (PST)
Subject: Re: [RFC PATCH] mm: kasan: suppress soft lockup in slub when
 !CONFIG_PREEMPT
References: <1512689407-100663-1-git-send-email-yang.s@alibaba-inc.com>
 <20171207234056.GF26792@bombadil.infradead.org>
 <CACT4Y+aB088z8zBuQC8Ff6Sf-2_QHVNRjfVpVjy7Xu8+G5BriQ@mail.gmail.com>
 <57afe220-036a-591c-2acc-56c5f3c6acef@virtuozzo.com>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <3fabaa44-4767-bfcf-bf86-f1fce573d5e1@alibaba-inc.com>
Date: Tue, 12 Dec 2017 02:00:10 +0800
MIME-Version: 1.0
In-Reply-To: <57afe220-036a-591c-2acc-56c5f3c6acef@virtuozzo.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitry Vyukov <dvyukov@google.com>, Matthew Wilcox <willy@infradead.org>
Cc: Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>



On 12/8/17 1:16 AM, Andrey Ryabinin wrote:
> On 12/08/2017 11:26 AM, Dmitry Vyukov wrote:
>> On Fri, Dec 8, 2017 at 12:40 AM, Matthew Wilcox <willy@infradead.org> wrote:
>>> On Fri, Dec 08, 2017 at 07:30:07AM +0800, Yang Shi wrote:
>>>> When running stress test with KASAN enabled, the below softlockup may
>>>> happen occasionally:
>>>>
>>>> NMI watchdog: BUG: soft lockup - CPU#7 stuck for 22s!
>>>> hardirqs last  enabled at (0): [<          (null)>]      (null)
>>>> hardirqs last disabled at (0): [] copy_process.part.30+0x5c6/0x1f50
>>>> softirqs last  enabled at (0): [] copy_process.part.30+0x5c6/0x1f50
>>>> softirqs last disabled at (0): [<          (null)>]      (null)
>>>
>>>> Call Trace:
>>>>   [] __slab_free+0x19c/0x270
>>>>   [] ___cache_free+0xa6/0xb0
>>>>   [] qlist_free_all+0x47/0x80
>>>>   [] quarantine_reduce+0x159/0x190
>>>>   [] kasan_kmalloc+0xaf/0xc0
>>>>   [] kasan_slab_alloc+0x12/0x20
>>>>   [] kmem_cache_alloc+0xfa/0x360
>>>>   [] ? getname_flags+0x4f/0x1f0
>>>>   [] getname_flags+0x4f/0x1f0
>>>>   [] getname+0x12/0x20
>>>>   [] do_sys_open+0xf9/0x210
>>>>   [] SyS_open+0x1e/0x20
>>>>   [] entry_SYSCALL_64_fastpath+0x1f/0xc2
>>>
>>> This feels like papering over a problem.  KASAN only calls
>>> quarantine_reduce() when it's allowed to block.  Presumably it has
>>> millions of entries on the free list at this point.  I think the right
>>> thing to do is for qlist_free_all() to call cond_resched() after freeing
>>> every N items.
>>
>>
>> Agree. Adding touch_softlockup_watchdog() to a random low-level
>> function looks like a wrong thing to do.
>> quarantine_reduce() already has this logic. Look at
>> QUARANTINE_BATCHES. It's meant to do exactly this -- limit amount of
>> work in quarantine_reduce() and in quarantine_remove_cache() to
>> reasonably-sized batches. We could simply increase number of batches
>> to make them smaller. But it would be good to understand what exactly
>> happens in this case. Batches should on a par of ~~1MB. Why freeing
>> 1MB worth of objects (smallest of which is 32b) takes 22 seconds?
>>
> 
> I think the problem here is that kernel 4.9.44-003.ali3000.alios7.x86_64.debug
> doesn't have 64abdcb24351 ("kasan: eliminate long stalls during quarantine reduction").
> 
> We probably should ask that commit to be included in stable, but it would be good to hear
> a confirmation from Yang that it really helps.

Thanks, folks. Yes, my kernel doesn't have this commit. It sounds the 
commit batches the quarantine to smaller group. I will run some tests 
against this commit to see if it could help. Reading the code tells me 
it is likely to help.

Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
