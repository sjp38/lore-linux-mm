Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 85A9D6B000D
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 22:25:51 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id p12-v6so17183488iog.8
        for <linux-mm@kvack.org>; Sat, 14 Jul 2018 19:25:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i10-v6sor11096584iog.51.2018.07.14.19.25.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 14 Jul 2018 19:25:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALOAHbDV73+X-y7V2Z4nX1C7uCY6yzBPTPZhEvTpN3f7_qWwUw@mail.gmail.com>
References: <1531557122-12540-1-git-send-email-laoar.shao@gmail.com>
 <CALvZod57QFRVQ7kM4LSNQJACQ+dGC_otJkqK-5+i-0b53Zq5aA@mail.gmail.com> <CALOAHbDV73+X-y7V2Z4nX1C7uCY6yzBPTPZhEvTpN3f7_qWwUw@mail.gmail.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Sun, 15 Jul 2018 10:25:09 +0800
Message-ID: <CALOAHbA__E8oCYpGvKg-ZMpeQ1tOT5V2ShxLhuozZSSnDNh2XQ@mail.gmail.com>
Subject: Re: [PATCH] mm: avoid bothering interrupted task when charge memcg in softirq
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, Jul 15, 2018 at 10:10 AM, Yafang Shao <laoar.shao@gmail.com> wrote:
> On Sat, Jul 14, 2018 at 11:38 PM, Shakeel Butt <shakeelb@google.com> wrote:
>> On Sat, Jul 14, 2018 at 1:32 AM Yafang Shao <laoar.shao@gmail.com> wrote:
>>>
>>> try_charge maybe executed in packet receive path, which is in interrupt
>>> context.
>>> In this situation, the 'current' is the interrupted task, which may has
>>> no relation to the rx softirq, So it is nonsense to use 'current'.
>>>
>>
>> Have you actually seen this occurring?
>
> Hi Shakeel,
>
> I'm trying to produce this issue, but haven't find it occur yet.
>
>> I am not very familiar with the
>> network code but I can think of two ways try_charge() can be called
>> from network code. Either through kmem charging or through
>> mem_cgroup_charge_skmem() and both locations correctly handle
>> interrupt context.
>>
>
> Why do you say that mem_cgroup_charge_skmem() correctly hanle
> interrupt context ?
>
> Let me show you why mem_cgroup_charge_skmem isn't hanling interrupt
> context correctly.
>
> mem_cgroup_charge_skmem() is calling  try_charge() twice.
> The first one is with GFP_NOWAIT as the gfp_mask, and the second one
> is with  (GFP_NOWAIT |  __GFP_NOFAIL) as the gfp_mask.
>
> If page_counter_try_charge() failes at the first time, -ENOMEM is returned.
> Then mem_cgroup_charge_skmem() will call try_charge() once more with
> __GFP_NOFAIL set, and this time if If page_counter_try_charge() failes
> again the '
> force' label in  try_charge() will be executed and 0 is returned.
>
> No matter what, the 'current' will be used and touched, that is
> meaning mem_cgroup_charge_skmem() isn't hanling the interrupt context
> correctly.
>
> Pls. let me know if I miss something.
>
>

Maybe bellow change is better,
@@ -2123,6 +2123,9 @@ static int try_charge(struct mem_cgroup *memcg,
gfp_t gfp_mask,
                goto retry;
        }

+       if (!gfpflags_allow_blocking(gfp_mask))
+               goto nomem;
+
        /*
         * Unlike in global OOM situations, memcg is not in a physical
         * memory shortage.  Allow dying and OOM-killed tasks to
@@ -2146,9 +2149,6 @@ static int try_charge(struct mem_cgroup *memcg,
gfp_t gfp_mask,
        if (unlikely(task_in_memcg_oom(current)))
                goto nomem;

-       if (!gfpflags_allow_blocking(gfp_mask))
-               goto nomem;

Thanks
Yafang
