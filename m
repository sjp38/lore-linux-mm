Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1B7066B0005
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 11:04:53 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ag5so8832860pad.2
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 08:04:53 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0102.outbound.protection.outlook.com. [104.47.1.102])
        by mx.google.com with ESMTPS id y186si3613975pfb.59.2016.08.11.08.04.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 11 Aug 2016 08:04:52 -0700 (PDT)
Subject: Re: [PATCH v2] kasan: avoid overflowing quarantine size on low memory
 systems
References: <1470133620-28683-1-git-send-email-glider@google.com>
 <20160810155015.bffc044a171466b2fdf5195e@linux-foundation.org>
 <CAG_fn=UW0bszthjs9_8vKZOX9nCaD9gvz-7A=x8=CBf=GTDxMA@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <4dd1e32f-24b8-9aad-7418-67b90aca5eba@virtuozzo.com>
Date: Thu, 11 Aug 2016 18:06:02 +0300
MIME-Version: 1.0
In-Reply-To: <CAG_fn=UW0bszthjs9_8vKZOX9nCaD9gvz-7A=x8=CBf=GTDxMA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitriy Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>



On 08/11/2016 04:42 PM, Alexander Potapenko wrote:
> On Thu, Aug 11, 2016 at 12:50 AM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>> On Tue,  2 Aug 2016 12:27:00 +0200 Alexander Potapenko <glider@google.com> wrote:
>>
>>> If the total amount of memory assigned to quarantine is less than the
>>> amount of memory assigned to per-cpu quarantines, |new_quarantine_size|
>>> may overflow. Instead, set it to zero.
>>>
>>> ...
>>>
>>> --- a/mm/kasan/quarantine.c
>>> +++ b/mm/kasan/quarantine.c
>>> @@ -196,7 +196,7 @@ void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache)
>>>
>>>  void quarantine_reduce(void)
>>>  {
>>> -     size_t new_quarantine_size;
>>> +     size_t new_quarantine_size, percpu_quarantines;
>>>       unsigned long flags;
>>>       struct qlist_head to_free = QLIST_INIT;
>>>       size_t size_to_free = 0;
>>> @@ -214,7 +214,9 @@ void quarantine_reduce(void)
>>>        */
>>>       new_quarantine_size = (READ_ONCE(totalram_pages) << PAGE_SHIFT) /
>>>               QUARANTINE_FRACTION;
>>> -     new_quarantine_size -= QUARANTINE_PERCPU_SIZE * num_online_cpus();
>>> +     percpu_quarantines = QUARANTINE_PERCPU_SIZE * num_online_cpus();
>>> +     new_quarantine_size = (new_quarantine_size < percpu_quarantines) ?
>>> +             0 : new_quarantine_size - percpu_quarantines;
>>>       WRITE_ONCE(quarantine_size, new_quarantine_size);
>>>
>>>       last = global_quarantine.head;
>>
>> Confused.  Which kernel version is this supposed to apply to?
> This is the second version of the patch which should've been applied
> to the mainline instead of v1.
> But since v1 has already hit upstream, this patch makes sense no more.
> If WARN_ONCE (which is currently present in this code) is a big deal,
> I can send a new patch that removes it.
> 

Probably not a big deal, but please, send the patch anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
