Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 336246B026D
	for <linux-mm@kvack.org>; Sun, 15 Jul 2018 02:34:45 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id g9-v6so6916642wrq.7
        for <linux-mm@kvack.org>; Sat, 14 Jul 2018 23:34:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g12-v6sor2082675wrq.26.2018.07.14.23.34.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 14 Jul 2018 23:34:43 -0700 (PDT)
MIME-Version: 1.0
References: <1531557122-12540-1-git-send-email-laoar.shao@gmail.com>
 <CALvZod57QFRVQ7kM4LSNQJACQ+dGC_otJkqK-5+i-0b53Zq5aA@mail.gmail.com>
 <CALOAHbDV73+X-y7V2Z4nX1C7uCY6yzBPTPZhEvTpN3f7_qWwUw@mail.gmail.com>
 <CALvZod5d37v8fv=VCFLa7g+ntPvaT-h8jRQw1+iry2dxb=yXxQ@mail.gmail.com> <CALOAHbBQurMrE6ZCLLsdmbqFrUX3vFVpZtFLvvL_WGnPoF0OSA@mail.gmail.com>
In-Reply-To: <CALOAHbBQurMrE6ZCLLsdmbqFrUX3vFVpZtFLvvL_WGnPoF0OSA@mail.gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Sat, 14 Jul 2018 23:34:30 -0700
Message-ID: <CALvZod6F4vM_U0obH1aU3iJqRs-3JEfR4cHKZoB9JVLTgdSmSQ@mail.gmail.com>
Subject: Re: [PATCH] mm: avoid bothering interrupted task when charge memcg in softirq
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Jul 14, 2018 at 10:26 PM Yafang Shao <laoar.shao@gmail.com> wrote:
>
> On Sun, Jul 15, 2018 at 12:25 PM, Shakeel Butt <shakeelb@google.com> wrote:
> > On Sat, Jul 14, 2018 at 7:10 PM Yafang Shao <laoar.shao@gmail.com> wrote:
> >>
> >> On Sat, Jul 14, 2018 at 11:38 PM, Shakeel Butt <shakeelb@google.com> wrote:
> >> > On Sat, Jul 14, 2018 at 1:32 AM Yafang Shao <laoar.shao@gmail.com> wrote:
> >> >>
> >> >> try_charge maybe executed in packet receive path, which is in interrupt
> >> >> context.
> >> >> In this situation, the 'current' is the interrupted task, which may has
> >> >> no relation to the rx softirq, So it is nonsense to use 'current'.
> >> >>
> >> >
> >> > Have you actually seen this occurring?
> >>
> >> Hi Shakeel,
> >>
> >> I'm trying to produce this issue, but haven't find it occur yet.
> >>
> >> > I am not very familiar with the
> >> > network code but I can think of two ways try_charge() can be called
> >> > from network code. Either through kmem charging or through
> >> > mem_cgroup_charge_skmem() and both locations correctly handle
> >> > interrupt context.
> >> >
> >>
> >> Why do you say that mem_cgroup_charge_skmem() correctly hanle
> >> interrupt context ?
> >>
> >> Let me show you why mem_cgroup_charge_skmem isn't hanling interrupt
> >> context correctly.
> >>
> >> mem_cgroup_charge_skmem() is calling  try_charge() twice.
> >> The first one is with GFP_NOWAIT as the gfp_mask, and the second one
> >> is with  (GFP_NOWAIT |  __GFP_NOFAIL) as the gfp_mask.
> >>
> >> If page_counter_try_charge() failes at the first time, -ENOMEM is returned.
> >> Then mem_cgroup_charge_skmem() will call try_charge() once more with
> >> __GFP_NOFAIL set, and this time if If page_counter_try_charge() failes
> >> again the '
> >> force' label in  try_charge() will be executed and 0 is returned.
> >>
> >> No matter what, the 'current' will be used and touched, that is
> >> meaning mem_cgroup_charge_skmem() isn't hanling the interrupt context
> >> correctly.
> >>
> >
> > Hi Yafang,
> >
> > If you check mem_cgroup_charge_skmem(), the memcg passed is not
> > 'current' but is from the sock object i.e. sk->sk_memcg for which the
> > network buffer is allocated for.
> >
>
> That's correct, the memcg if from the sock object.
> But the point is, in this situation why 'current' is used in try_charge() ?
> As 'current' is not related with the memcg, which is just a interrupted task.
>

Hmm so you mean the behavior of memcg charging in the interrupt
context depends on the state of the interrupted task. As you have
noted, mem_cgroup_charge_skmem() tries charging again with
__GFP_NOFAIL and the charge succeeds. Basically the memcg charging by
mem_cgroup_charge_skmem() will always succeed irrespective of the
state of the interrupted task. However mem_cgroup_charge_skmem() can
return true if the interrupted task was exiting or a fatal signal is
pending or oom victim or reclaiming memory. Can you please explain why
this is bad?

Shakeel
