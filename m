Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id C690E6B0269
	for <linux-mm@kvack.org>; Sun, 15 Jul 2018 00:25:45 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id 40-v6so6815932wrb.23
        for <linux-mm@kvack.org>; Sat, 14 Jul 2018 21:25:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z18-v6sor2790946wma.3.2018.07.14.21.25.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 14 Jul 2018 21:25:44 -0700 (PDT)
MIME-Version: 1.0
References: <1531557122-12540-1-git-send-email-laoar.shao@gmail.com>
 <CALvZod57QFRVQ7kM4LSNQJACQ+dGC_otJkqK-5+i-0b53Zq5aA@mail.gmail.com> <CALOAHbDV73+X-y7V2Z4nX1C7uCY6yzBPTPZhEvTpN3f7_qWwUw@mail.gmail.com>
In-Reply-To: <CALOAHbDV73+X-y7V2Z4nX1C7uCY6yzBPTPZhEvTpN3f7_qWwUw@mail.gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Sat, 14 Jul 2018 21:25:31 -0700
Message-ID: <CALvZod5d37v8fv=VCFLa7g+ntPvaT-h8jRQw1+iry2dxb=yXxQ@mail.gmail.com>
Subject: Re: [PATCH] mm: avoid bothering interrupted task when charge memcg in softirq
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Jul 14, 2018 at 7:10 PM Yafang Shao <laoar.shao@gmail.com> wrote:
>
> On Sat, Jul 14, 2018 at 11:38 PM, Shakeel Butt <shakeelb@google.com> wrote:
> > On Sat, Jul 14, 2018 at 1:32 AM Yafang Shao <laoar.shao@gmail.com> wrote:
> >>
> >> try_charge maybe executed in packet receive path, which is in interrupt
> >> context.
> >> In this situation, the 'current' is the interrupted task, which may has
> >> no relation to the rx softirq, So it is nonsense to use 'current'.
> >>
> >
> > Have you actually seen this occurring?
>
> Hi Shakeel,
>
> I'm trying to produce this issue, but haven't find it occur yet.
>
> > I am not very familiar with the
> > network code but I can think of two ways try_charge() can be called
> > from network code. Either through kmem charging or through
> > mem_cgroup_charge_skmem() and both locations correctly handle
> > interrupt context.
> >
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

Hi Yafang,

If you check mem_cgroup_charge_skmem(), the memcg passed is not
'current' but is from the sock object i.e. sk->sk_memcg for which the
network buffer is allocated for.

If the network buffers is allocated through kmem interface, the
charging is bypassed altogether (through memcg_kmem_bypass()) for
interrupt context.

regards,
Shakeel
