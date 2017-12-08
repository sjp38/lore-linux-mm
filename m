Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8E46B0253
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 03:27:00 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id p17so8122723pfh.18
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 00:27:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m15sor2015067pgr.381.2017.12.08.00.26.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Dec 2017 00:26:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171207234056.GF26792@bombadil.infradead.org>
References: <1512689407-100663-1-git-send-email-yang.s@alibaba-inc.com> <20171207234056.GF26792@bombadil.infradead.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 8 Dec 2017 09:26:37 +0100
Message-ID: <CACT4Y+aB088z8zBuQC8Ff6Sf-2_QHVNRjfVpVjy7Xu8+G5BriQ@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: kasan: suppress soft lockup in slub when !CONFIG_PREEMPT
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Yang Shi <yang.s@alibaba-inc.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Dec 8, 2017 at 12:40 AM, Matthew Wilcox <willy@infradead.org> wrote:
> On Fri, Dec 08, 2017 at 07:30:07AM +0800, Yang Shi wrote:
>> When running stress test with KASAN enabled, the below softlockup may
>> happen occasionally:
>>
>> NMI watchdog: BUG: soft lockup - CPU#7 stuck for 22s!
>> hardirqs last  enabled at (0): [<          (null)>]      (null)
>> hardirqs last disabled at (0): [] copy_process.part.30+0x5c6/0x1f50
>> softirqs last  enabled at (0): [] copy_process.part.30+0x5c6/0x1f50
>> softirqs last disabled at (0): [<          (null)>]      (null)
>
>> Call Trace:
>>  [] __slab_free+0x19c/0x270
>>  [] ___cache_free+0xa6/0xb0
>>  [] qlist_free_all+0x47/0x80
>>  [] quarantine_reduce+0x159/0x190
>>  [] kasan_kmalloc+0xaf/0xc0
>>  [] kasan_slab_alloc+0x12/0x20
>>  [] kmem_cache_alloc+0xfa/0x360
>>  [] ? getname_flags+0x4f/0x1f0
>>  [] getname_flags+0x4f/0x1f0
>>  [] getname+0x12/0x20
>>  [] do_sys_open+0xf9/0x210
>>  [] SyS_open+0x1e/0x20
>>  [] entry_SYSCALL_64_fastpath+0x1f/0xc2
>
> This feels like papering over a problem.  KASAN only calls
> quarantine_reduce() when it's allowed to block.  Presumably it has
> millions of entries on the free list at this point.  I think the right
> thing to do is for qlist_free_all() to call cond_resched() after freeing
> every N items.


Agree. Adding touch_softlockup_watchdog() to a random low-level
function looks like a wrong thing to do.
quarantine_reduce() already has this logic. Look at
QUARANTINE_BATCHES. It's meant to do exactly this -- limit amount of
work in quarantine_reduce() and in quarantine_remove_cache() to
reasonably-sized batches. We could simply increase number of batches
to make them smaller. But it would be good to understand what exactly
happens in this case. Batches should on a par of ~~1MB. Why freeing
1MB worth of objects (smallest of which is 32b) takes 22 seconds?



>> The code is run in irq disabled or preempt disabled context, so
>> cond_resched() can't be used in this case. Touch softlockup watchdog when
>> KASAN is enabled to suppress the warning.
>>
>> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
>> ---
>>  mm/slub.c | 5 +++++
>>  1 file changed, 5 insertions(+)
>>
>> diff --git a/mm/slub.c b/mm/slub.c
>> index cfd56e5..4ae435e 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -35,6 +35,7 @@
>>  #include <linux/prefetch.h>
>>  #include <linux/memcontrol.h>
>>  #include <linux/random.h>
>> +#include <linux/nmi.h>
>>
>>  #include <trace/events/kmem.h>
>>
>> @@ -2266,6 +2267,10 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
>>               page->pobjects = pobjects;
>>               page->next = oldpage;
>>
>> +#ifdef CONFIG_KASAN
>> +             touch_softlockup_watchdog();
>> +#endif
>> +
>>       } while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page)
>>                                                               != oldpage);
>>       if (unlikely(!s->cpu_partial)) {
>> --
>> 1.8.3.1
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
