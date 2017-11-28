Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 29BCF6B02FB
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 06:30:09 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id b11so277619itj.0
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 03:30:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d18sor10187180iob.22.2017.11.28.03.30.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Nov 2017 03:30:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+aAhHSW=qBFLy7S1wWLsJsjW83y8uC4nQy0N9Hf8HoMKQ@mail.gmail.com>
References: <1511841842-3786-1-git-send-email-zhouzhouyi@gmail.com>
 <CAABZP2zEup53ZcNKOEUEMx_aRMLONZdYCLd7s5J4DLTccPxC-A@mail.gmail.com>
 <CACT4Y+YE5POWUoDj2sUv2NDKeimTRyxCpg1yd7VpZnqeYJ+Qcg@mail.gmail.com>
 <CAABZP2zB8vKswQXicYq5r8iNOKz21CRyw1cUiB2s9O+ZMb+JvQ@mail.gmail.com>
 <CACT4Y+YkVbkwAm0h7UJH08woiohJT9EYObhxpE33dP0A4agtkw@mail.gmail.com>
 <CAABZP2zjoSDTNkn_qMqi+NCHOzzQZSj-LvfCjPy_tg-FZeUWZg@mail.gmail.com>
 <CACT4Y+ah6q-xoakyPL7v-+Knp8ZaFbnRRk_Ki6Wsmz3C8Pe8XQ@mail.gmail.com>
 <CAABZP2yS524XEiyu=kkVx7ff1ySTtE=WWETNDrZ_toEm0mwqyQ@mail.gmail.com> <CACT4Y+aAhHSW=qBFLy7S1wWLsJsjW83y8uC4nQy0N9Hf8HoMKQ@mail.gmail.com>
From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Date: Tue, 28 Nov 2017 19:30:06 +0800
Message-ID: <CAABZP2wxDxAHJ_f022Ha7gyffukgo0PPOv2uJQphwFXGO_fL1w@mail.gmail.com>
Subject: Re: [PATCH 1/1] kasan: fix livelock in qlist_move_cache
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi,
   By using perf top, qlist_move_cache occupies 100% cpu did really
happen in my environment yesterday, or I
won't notice the kasan code.
   Currently I have difficulty to let it reappear because the frontend
guy modified some user mode code.
   I can repeat again and again now is
kgdb_breakpoint () at kernel/debug/debug_core.c:1073
1073 wmb(); /* Sync point after breakpoint */
(gdb) p quarantine_batch_size
$1 = 3601946
   And by instrument code, maximum
global_quarantine[quarantine_tail].bytes reached is 6618208.

   I do think drain quarantine right in quarantine_put is a better
place to drain because cache_free is fine in
that context. I am willing do it if you think it is convenient :-)


On Tue, Nov 28, 2017 at 5:27 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Tue, Nov 28, 2017 at 10:17 AM, Zhouyi Zhou <zhouzhouyi@gmail.com> wrote:
>> Hi,
>>     Imagine all of the QUARANTINE_BATCHES elements of
>> global_quarantine array is of size 4MB + 1MB, now a new call
>> to quarantine_put is invoked, one of the element will be of size 4MB +
>> 1MB + 1MB, so on and on.
>
>
> I see what you mean. Does it really happen in your case? What's the
> maximum batch size that you get during your workload?
>
> I always wondered why don't we drain quarantine right in
> quarantine_put when we overflow it? We already take quarantine_lock
> and calling cache_free should be fine in that context, since user code
> already does that.
>
>
>
>> On Tue, Nov 28, 2017 at 4:58 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>> On Tue, Nov 28, 2017 at 9:33 AM, Zhouyi Zhou <zhouzhouyi@gmail.com> wrote:
>>>> Hi,
>>>>    Please take a look at function quarantine_put, I don't think following
>>>> code will limit the batch size below quarantine_batch_size. It only advance
>>>> quarantine_tail after qlist_move_all.
>>>>
>>>>                 qlist_move_all(q, &temp);
>>>>
>>>>                 spin_lock(&quarantine_lock);
>>>>                 WRITE_ONCE(quarantine_size, quarantine_size + temp.bytes);
>>>>                 qlist_move_all(&temp, &global_quarantine[quarantine_tail]);
>>>>                 if (global_quarantine[quarantine_tail].bytes >=
>>>>                                 READ_ONCE(quarantine_batch_size)) {
>>>>                         int new_tail;
>>>>
>>>>                         new_tail = quarantine_tail + 1;
>>>>                         if (new_tail == QUARANTINE_BATCHES)
>>>>                                 new_tail = 0;
>>>>                         if (new_tail != quarantine_head)
>>>>                                 quarantine_tail = new_tail;
>>>
>>>
>>> As far as I see this code can exceed global quarantine batch size by
>>> at most 1 per-cpu batch. Per-cpu batch is caped at 1MB. So max global
>>> batch size will be 4MB+1MB. Which does not radically change situation.
>>>
>>>
>>>> On Tue, Nov 28, 2017 at 4:12 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>>>> On Tue, Nov 28, 2017 at 9:00 AM, Zhouyi Zhou <zhouzhouyi@gmail.com> wrote:
>>>>>> Thanks for reviewing
>>>>>>    My machine has 128G of RAM, and runs many KVM virtual machines.
>>>>>> libvirtd always
>>>>>> report "internal error: received hangup / error event on socket" under
>>>>>> heavy memory load.
>>>>>>    Then I use perf top -g, qlist_move_cache consumes 100% cpu for
>>>>>> several minutes.
>>>>>
>>>>> For 128GB of RAM, batch size is 4MB. Processing such batch should not
>>>>> take more than few ms. So I am still struggling  to understand how/why
>>>>> your change helps and why there are issues in the first place...
>>>>>
>>>>>
>>>>>
>>>>>> On Tue, Nov 28, 2017 at 3:45 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>>>>>> On Tue, Nov 28, 2017 at 5:05 AM, Zhouyi Zhou <zhouzhouyi@gmail.com> wrote:
>>>>>>>> When there are huge amount of quarantined cache allocates in system,
>>>>>>>> number of entries in global_quarantine[i] will be great. Meanwhile,
>>>>>>>> there is no relax in while loop in function qlist_move_cache which
>>>>>>>> hold quarantine_lock. As a result, some userspace programs for example
>>>>>>>> libvirt will complain.
>>>>>>>
>>>>>>> Hi,
>>>>>>>
>>>>>>> The QUARANTINE_BATCHES thing was supposed to fix this problem, see
>>>>>>> quarantine_remove_cache() function.
>>>>>>> What is the amount of RAM and number of CPUs in your system?
>>>>>>> If system has 4GB of RAM, quarantine size is 128MB and that's split
>>>>>>> into 1024 batches. Batch size is 128KB. Even if that's filled with the
>>>>>>> smallest objects of size 32, that's only 4K objects. And there is a
>>>>>>> cond_resched() between processing of every batch.
>>>>>>> I don't understand why it causes problems in your setup. We use KASAN
>>>>>>> extremely heavily on hundreds of machines 24x7 and we have not seen
>>>>>>> any single report from this code...
>>>>>>>
>>>>>>>
>>>>>>>> On Tue, Nov 28, 2017 at 12:04 PM,  <zhouzhouyi@gmail.com> wrote:
>>>>>>>>> From: Zhouyi Zhou <zhouzhouyi@gmail.com>
>>>>>>>>>
>>>>>>>>> This patch fix livelock by conditionally release cpu to let others
>>>>>>>>> has a chance to run.
>>>>>>>>>
>>>>>>>>> Tested on x86_64.
>>>>>>>>> Signed-off-by: Zhouyi Zhou <zhouzhouyi@gmail.com>
>>>>>>>>> ---
>>>>>>>>>  mm/kasan/quarantine.c | 12 +++++++++++-
>>>>>>>>>  1 file changed, 11 insertions(+), 1 deletion(-)
>>>>>>>>>
>>>>>>>>> diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
>>>>>>>>> index 3a8ddf8..33eeff4 100644
>>>>>>>>> --- a/mm/kasan/quarantine.c
>>>>>>>>> +++ b/mm/kasan/quarantine.c
>>>>>>>>> @@ -265,10 +265,13 @@ static void qlist_move_cache(struct qlist_head *from,
>>>>>>>>>                                    struct kmem_cache *cache)
>>>>>>>>>  {
>>>>>>>>>         struct qlist_node *curr;
>>>>>>>>> +       struct qlist_head tmp_head;
>>>>>>>>> +       unsigned long flags;
>>>>>>>>>
>>>>>>>>>         if (unlikely(qlist_empty(from)))
>>>>>>>>>                 return;
>>>>>>>>>
>>>>>>>>> +       qlist_init(&tmp_head);
>>>>>>>>>         curr = from->head;
>>>>>>>>>         qlist_init(from);
>>>>>>>>>         while (curr) {
>>>>>>>>> @@ -278,10 +281,17 @@ static void qlist_move_cache(struct qlist_head *from,
>>>>>>>>>                 if (obj_cache == cache)
>>>>>>>>>                         qlist_put(to, curr, obj_cache->size);
>>>>>>>>>                 else
>>>>>>>>> -                       qlist_put(from, curr, obj_cache->size);
>>>>>>>>> +                       qlist_put(&tmp_head, curr, obj_cache->size);
>>>>>>>>>
>>>>>>>>>                 curr = next;
>>>>>>>>> +
>>>>>>>>> +               if (need_resched()) {
>>>>>>>>> +                       spin_unlock_irqrestore(&quarantine_lock, flags);
>>>>>>>>> +                       cond_resched();
>>>>>>>>> +                       spin_lock_irqsave(&quarantine_lock, flags);
>>>>>>>>> +               }
>>>>>>>>>         }
>>>>>>>>> +       qlist_move_all(&tmp_head, from);
>>>>>>>>>  }
>>>>>>>>>
>>>>>>>>>  static void per_cpu_remove_cache(void *arg)
>>>>>>>>> --
>>>>>>>>> 2.1.4
>>>>>>>>>
>>>>>>>>
>>>>>>>> --
>>>>>>>> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
>>>>>>>> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
>>>>>>>> To post to this group, send email to kasan-dev@googlegroups.com.
>>>>>>>> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/CAABZP2zEup53ZcNKOEUEMx_aRMLONZdYCLd7s5J4DLTccPxC-A%40mail.gmail.com.
>>>>>>>> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
