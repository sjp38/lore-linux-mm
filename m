Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 25FE26B7E6A
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 08:57:40 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 186-v6so7165929pgc.12
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 05:57:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e12-v6sor1542540pfb.40.2018.09.07.05.57.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Sep 2018 05:57:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1536319423-9344-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1536319423-9344-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 7 Sep 2018 14:57:17 +0200
Message-ID: <CACT4Y+ZN9ZccjgzUy=8gBntWdau5H1wtLxsh6ZautaTNdMvieQ@mail.gmail.com>
Subject: Re: [PATCH] syzbot: Dump all threads upon OOM.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>

On Fri, Sep 7, 2018 at 1:23 PM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> syzbot is getting stalls with linux-next kernels because dump_tasks() from
> out_of_memory() is printing 6600 tasks. Most of these tasks are syzbot
> processes but syzbot is supposed not to create so many processes.
> Therefore, let's start from checking what these tasks are doing.
> This change will be removed after the bug is fixed.
>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> ---
>  mm/oom_kill.c | 5 +++++
>  1 file changed, 5 insertions(+)
>
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index f10aa53..867fd6a 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -41,6 +41,7 @@
>  #include <linux/kthread.h>
>  #include <linux/init.h>
>  #include <linux/mmu_notifier.h>
> +#include <linux/sched/debug.h>
>
>  #include <asm/tlb.h>
>  #include "internal.h"
> @@ -446,6 +447,10 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
>                 if (is_dump_unreclaim_slabs())
>                         dump_unreclaimable_slab();
>         }
> +#ifdef CONFIG_DEBUG_AID_FOR_SYZBOT
> +       show_state();
> +       panic("Out of memory");

won't this panic on every oom?
we have lots of oom's, especially inside of cgroups, but probably global too
it would be bad if we crash all machines this way


> +#endif
>         if (sysctl_oom_dump_tasks)
>                 dump_tasks(oc->memcg, oc->nodemask);
>  }
> --
> 1.8.3.1
>
