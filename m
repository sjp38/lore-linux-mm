Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 986906B0274
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 05:01:58 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id n14so10664974pfh.15
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 02:01:58 -0800 (PST)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id 205si12031246pfy.38.2017.11.06.02.01.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Nov 2017 02:01:57 -0800 (PST)
Subject: Re: [RFC PATCH] mm, oom_reaper: gather each vma to prevent leaking
 TLB entry
References: <20171106033651.172368-1-wangnan0@huawei.com>
 <CAA_GA1dZebSLTEX2W85svWW6O_9RqXDnD7oFW+tMqg+HX5XbPA@mail.gmail.com>
 <20171106085251.jwrpgne4dnl4gopy@dhcp22.suse.cz>
From: "Wangnan (F)" <wangnan0@huawei.com>
Message-ID: <0cf84560-c64a-0737-e654-162928872d5b@huawei.com>
Date: Mon, 6 Nov 2017 17:59:54 +0800
MIME-Version: 1.0
In-Reply-To: <20171106085251.jwrpgne4dnl4gopy@dhcp22.suse.cz>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Bob Liu <lliubbo@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Bob Liu <liubo95@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Ingo
 Molnar <mingo@kernel.org>, Roman Gushchin <guro@fb.com>, Konstantin
 Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>, will.deacon@arm.com



On 2017/11/6 16:52, Michal Hocko wrote:
> On Mon 06-11-17 15:04:40, Bob Liu wrote:
>> On Mon, Nov 6, 2017 at 11:36 AM, Wang Nan <wangnan0@huawei.com> wrote:
>>> tlb_gather_mmu(&tlb, mm, 0, -1) means gathering all virtual memory space.
>>> In this case, tlb->fullmm is true. Some archs like arm64 doesn't flush
>>> TLB when tlb->fullmm is true:
>>>
>>>    commit 5a7862e83000 ("arm64: tlbflush: avoid flushing when fullmm == 1").
>>>
>> CC'ed Will Deacon.
>>
>>> Which makes leaking of tlb entries. For example, when oom_reaper
>>> selects a task and reaps its virtual memory space, another thread
>>> in this task group may still running on another core and access
>>> these already freed memory through tlb entries.
> No threads should be running in userspace by the time the reaper gets to
> unmap their address space. So the only potential case is they are
> accessing the user memory from the kernel when we should fault and we
> have MMF_UNSTABLE to cause a SIGBUS. So is the race you are describing
> real?
>
>>> This patch gather each vma instead of gathering full vm space,
>>> tlb->fullmm is not true. The behavior of oom reaper become similar
>>> to munmapping before do_exit, which should be safe for all archs.
> I do not have any objections to do per vma tlb flushing because it would
> free gathered pages sooner but I am not sure I see any real problem
> here. Have you seen any real issues or this is more of a review driven
> fix?

We saw the problem when we try to reuse oom reaper's code in
another situation. In our situation, we allow reaping a task
before all other tasks in its task group finish their exiting
procedure.

I'd like to know what ensures "No threads should be running in
userspace by the time the reaper"?

Thank you.

>>> Signed-off-by: Wang Nan <wangnan0@huawei.com>
>>> Cc: Bob Liu <liubo95@huawei.com>
>>> Cc: Michal Hocko <mhocko@suse.com>
>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Cc: Michal Hocko <mhocko@suse.com>
>>> Cc: David Rientjes <rientjes@google.com>
>>> Cc: Ingo Molnar <mingo@kernel.org>
>>> Cc: Roman Gushchin <guro@fb.com>
>>> Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>>> ---
>>>   mm/oom_kill.c | 7 ++++---
>>>   1 file changed, 4 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>>> index dee0f75..18c5b35 100644
>>> --- a/mm/oom_kill.c
>>> +++ b/mm/oom_kill.c
>>> @@ -532,7 +532,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>>>           */
>>>          set_bit(MMF_UNSTABLE, &mm->flags);
>>>
>>> -       tlb_gather_mmu(&tlb, mm, 0, -1);
>>>          for (vma = mm->mmap ; vma; vma = vma->vm_next) {
>>>                  if (!can_madv_dontneed_vma(vma))
>>>                          continue;
>>> @@ -547,11 +546,13 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>>>                   * we do not want to block exit_mmap by keeping mm ref
>>>                   * count elevated without a good reason.
>>>                   */
>>> -               if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))
>>> +               if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED)) {
>>> +                       tlb_gather_mmu(&tlb, mm, vma->vm_start, vma->vm_end);
>>>                          unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
>>>                                           NULL);
>>> +                       tlb_finish_mmu(&tlb, vma->vm_start, vma->vm_end);
>>> +               }
>>>          }
>>> -       tlb_finish_mmu(&tlb, 0, -1);
>>>          pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
>>>                          task_pid_nr(tsk), tsk->comm,
>>>                          K(get_mm_counter(mm, MM_ANONPAGES)),
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
