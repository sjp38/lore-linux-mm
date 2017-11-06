Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1D8906B026E
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 06:09:34 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id n17so1002474otb.0
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 03:09:34 -0800 (PST)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id s32si5384923otb.439.2017.11.06.03.09.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Nov 2017 03:09:32 -0800 (PST)
Subject: Re: [RFC PATCH] mm, oom_reaper: gather each vma to prevent leaking
 TLB entry
References: <20171106033651.172368-1-wangnan0@huawei.com>
 <CAA_GA1dZebSLTEX2W85svWW6O_9RqXDnD7oFW+tMqg+HX5XbPA@mail.gmail.com>
 <20171106085251.jwrpgne4dnl4gopy@dhcp22.suse.cz>
 <0cf84560-c64a-0737-e654-162928872d5b@huawei.com>
 <20171106104008.yqjqsfolsnaotarr@dhcp22.suse.cz>
From: "Wangnan (F)" <wangnan0@huawei.com>
Message-ID: <32853d25-4b72-443f-381c-5905de872221@huawei.com>
Date: Mon, 6 Nov 2017 19:03:34 +0800
MIME-Version: 1.0
In-Reply-To: <20171106104008.yqjqsfolsnaotarr@dhcp22.suse.cz>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Bob Liu <lliubbo@gmail.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Bob Liu <liubo95@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Ingo
 Molnar <mingo@kernel.org>, Roman Gushchin <guro@fb.com>, Konstantin
 Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>, will.deacon@arm.com



On 2017/11/6 18:40, Michal Hocko wrote:
> On Mon 06-11-17 17:59:54, Wangnan (F) wrote:
>>
>> On 2017/11/6 16:52, Michal Hocko wrote:
>>> On Mon 06-11-17 15:04:40, Bob Liu wrote:
>>>> On Mon, Nov 6, 2017 at 11:36 AM, Wang Nan <wangnan0@huawei.com> wrote:
>>>>> tlb_gather_mmu(&tlb, mm, 0, -1) means gathering all virtual memory space.
>>>>> In this case, tlb->fullmm is true. Some archs like arm64 doesn't flush
>>>>> TLB when tlb->fullmm is true:
>>>>>
>>>>>     commit 5a7862e83000 ("arm64: tlbflush: avoid flushing when fullmm == 1").
>>>>>
>>>> CC'ed Will Deacon.
>>>>
>>>>> Which makes leaking of tlb entries. For example, when oom_reaper
>>>>> selects a task and reaps its virtual memory space, another thread
>>>>> in this task group may still running on another core and access
>>>>> these already freed memory through tlb entries.
>>> No threads should be running in userspace by the time the reaper gets to
>>> unmap their address space. So the only potential case is they are
>>> accessing the user memory from the kernel when we should fault and we
>>> have MMF_UNSTABLE to cause a SIGBUS. So is the race you are describing
>>> real?
>>>
>>>>> This patch gather each vma instead of gathering full vm space,
>>>>> tlb->fullmm is not true. The behavior of oom reaper become similar
>>>>> to munmapping before do_exit, which should be safe for all archs.
>>> I do not have any objections to do per vma tlb flushing because it would
>>> free gathered pages sooner but I am not sure I see any real problem
>>> here. Have you seen any real issues or this is more of a review driven
>>> fix?
>> We saw the problem when we try to reuse oom reaper's code in
>> another situation. In our situation, we allow reaping a task
>> before all other tasks in its task group finish their exiting
>> procedure.
>>
>> I'd like to know what ensures "No threads should be running in
>> userspace by the time the reaper"?
> All tasks are killed by the time. So they should be taken out to the
> kernel.

Sorry. I read oom_kill_process() but still unable to understand
why all tasks are killed.

oom_kill_process() kill victim by sending SIGKILL. It will be
broadcast to all tasks in its task group, but it is asynchronized.
In the following case, race can happen (Thread1 in Task1's task group):

core 1                core 2
Thread1 running       oom_kill_process() selects Task1 as victim
                       oom_kill_process() sends SIGKILL to Task1
                       oom_kill_process() sends SIGKILL to Thread1
                       oom_kill_process() wakes up oom reaper
                       switch to oom_reaper
                       __oom_reap_task_mm
                       tlb_gather_mmu
                       unmap_page_range, reap Task1
                       tlb_finish_mmu
Write page
be kicked off from core
Receives SIGKILL

So what makes Thread1 being kicked off from core 1 before core 2
starting unmapping?

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
