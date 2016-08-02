Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3FCB46B025E
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 06:05:33 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 33so91049399lfw.1
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 03:05:33 -0700 (PDT)
Received: from mail-lf0-x235.google.com (mail-lf0-x235.google.com. [2a00:1450:4010:c07::235])
        by mx.google.com with ESMTPS id p204si741784lfp.301.2016.08.02.03.05.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 03:05:31 -0700 (PDT)
Received: by mail-lf0-x235.google.com with SMTP id b199so134661394lfe.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 03:05:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <57A06F23.9080804@virtuozzo.com>
References: <1470063563-96266-1-git-send-email-glider@google.com> <57A06F23.9080804@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 2 Aug 2016 12:05:10 +0200
Message-ID: <CACT4Y+ad6ZY=1=kM0FGZD8LtOaupV4c0AW0mXjMoxMNRsH2omA@mail.gmail.com>
Subject: Re: [PATCH] kasan: avoid overflowing quarantine size on low memory systems
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>, Kostya Serebryany <kcc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Aug 2, 2016 at 12:00 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
>
> On 08/01/2016 05:59 PM, Alexander Potapenko wrote:
>> If the total amount of memory assigned to quarantine is less than the
>> amount of memory assigned to per-cpu quarantines, |new_quarantine_size|
>> may overflow. Instead, set it to zero.
>>
>
> Just curious, how did find this?
> Overflow is possible if system has more than 32 cpus per GB of memory. AFIAK this quite unusual.

I was reading code for unrelated reason.

>> Reported-by: Dmitry Vyukov <dvyukov@google.com>
>> Fixes: 55834c59098d ("mm: kasan: initial memory quarantine
>> implementation")
>> Signed-off-by: Alexander Potapenko <glider@google.com>
>> ---
>>  mm/kasan/quarantine.c | 12 ++++++++++--
>>  1 file changed, 10 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
>> index 65793f1..416d3b0 100644
>> --- a/mm/kasan/quarantine.c
>> +++ b/mm/kasan/quarantine.c
>> @@ -196,7 +196,7 @@ void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache)
>>
>>  void quarantine_reduce(void)
>>  {
>> -     size_t new_quarantine_size;
>> +     size_t new_quarantine_size, percpu_quarantines;
>>       unsigned long flags;
>>       struct qlist_head to_free = QLIST_INIT;
>>       size_t size_to_free = 0;
>> @@ -214,7 +214,15 @@ void quarantine_reduce(void)
>>        */
>>       new_quarantine_size = (READ_ONCE(totalram_pages) << PAGE_SHIFT) /
>>               QUARANTINE_FRACTION;
>> -     new_quarantine_size -= QUARANTINE_PERCPU_SIZE * num_online_cpus();
>> +     percpu_quarantines = QUARANTINE_PERCPU_SIZE * num_online_cpus();
>> +     if (new_quarantine_size < percpu_quarantines) {
>> +             WARN_ONCE(1,
>> +                     "Too little memory, disabling global KASAN quarantine.\n",
>> +             );
>
> Why WARN? I'd suggest pr_warn_once();


I would suggest to just do something useful. Setting quarantine
new_quarantine_size to 0 looks fine.
What would user do with this warning? Number of CPUs and amount of
memory are generally fixed. Why is it an issue for end user at all? We
still have some quarantine per-cpu. A WARNING means a [non-critical]
kernel bug. E.g. syzkaller will catch each and every boot of such
system as a bug.


>> +             new_quarantine_size = 0;
>> +     } else {
>> +             new_quarantine_size -= percpu_quarantines;
>> +     }
>>       WRITE_ONCE(quarantine_size, new_quarantine_size);
>>
>>       last = global_quarantine.head;
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
