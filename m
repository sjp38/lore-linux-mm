Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A58AF6B7860
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 07:07:22 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id f13-v6so5377644pgs.15
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 04:07:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bh4-v6sor1094061plb.113.2018.09.06.04.07.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Sep 2018 04:07:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <58aa0543-86d0-b2ad-7fb9-9bed7c6a1f6c@i-love.sakura.ne.jp>
References: <0252ad5d-46e6-0d7f-ef91-4e316657a83d@i-love.sakura.ne.jp>
 <CACT4Y+Yp6ZbusCWg5C1zaJpcS8=XnGPboKgWfyxVk1axQA2nbw@mail.gmail.com>
 <201809060553.w865rmpj036017@www262.sakura.ne.jp> <CACT4Y+YKJWJr-5rBQidt6nY7+VF=BAsvHyh+XTaf8spwNy3qPA@mail.gmail.com>
 <58aa0543-86d0-b2ad-7fb9-9bed7c6a1f6c@i-love.sakura.ne.jp>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 6 Sep 2018 13:07:00 +0200
Message-ID: <CACT4Y+Zx6Jrpjfo_sDMNuHcrPvcN3GRprtJM_bCAts7f3Cp0_g@mail.gmail.com>
Subject: Re: [PATCH] mm, oom: Introduce time limit for dump_tasks duration.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, syzbot <syzbot+f0fc7f62e88b1de99af3@syzkaller.appspotmail.com>, 'Dmitry Vyukov' via syzkaller-upstream-moderation <syzkaller-upstream-moderation@googlegroups.com>, linux-mm <linux-mm@kvack.org>

On Thu, Sep 6, 2018 at 12:58 PM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> On 2018/09/06 18:54, Dmitry Vyukov wrote:
>> On Thu, Sep 6, 2018 at 7:53 AM, Tetsuo Handa
>> <penguin-kernel@i-love.sakura.ne.jp> wrote:
>>> Dmitry Vyukov wrote:
>>>>> Also, another notable thing is that the backtrace for some reason includes
>>>>>
>>>>> [ 1048.211540]  ? oom_killer_disable+0x3a0/0x3a0
>>>>>
>>>>> line. Was syzbot testing process freezing functionality?
>>>>
>>>> What's the API for this?
>>>>
>>>
>>> I'm not a user of suspend/hibernation. But it seems that usage of the API
>>> is to write one of words listed in /sys/power/state into /sys/power/state .
>>>
>>> # echo suspend > /sys/power/state
>>
>> syzkaller should not write to /sys/power/state. The only mention of
>> "power" is in some selinux contexts.
>>
>
> OK. Then, I have no idea.
> Anyway, I think we can apply this patch.
>
> From 18876f287dd69a7c33f65c91cfcda3564233f55e Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Thu, 6 Sep 2018 19:53:18 +0900
> Subject: [PATCH] mm, oom: Introduce time limit for dump_tasks duration.
>
> Since printk() is slow, printing one line takes nearly 0.01 second.
> As a result, syzbot is stalling for 52 seconds trying to dump 5600

I wonder why there are so many of them?
We have at most 8 test processes (each having no more than 16 threads
if that matters).
No more than 1 instance of syz-executor1 at a time. But we see output
like the one below. It has lots of instances of syz-executor1 with
different pid's. So does it print all tasks that ever existed (kernel
does not store that info, right)? Or it livelocks picking up new and
new tasks as they are created slower than they are created? Or we have
tons of zombies?

...
[   8037]     0  8037    17618     8738   131072        0
0 syz-executor1
[   8039]     0  8039    17585     8737   131072        0
0 syz-executor3
[   8040]     0  8040    17618     8738   131072        0
0 syz-executor1
 schedule+0xfb/0x450 kernel/sched/core.c:3517
[   8056]     0  8056    17585     8738   126976        0
0 syz-executor4
[   8055]     0  8055    17618     8741   126976        0
0 syz-executor5
[   8060]     0  8060    17585     8740   126976        0
0 syz-executor0
[   8062]     0  8062    17585     8739   126976        0
0 syz-executor7
[   8063]     0  8063    17618     8741   126976        0
0 syz-executor5
[   8066]     0  8066    17585     8740   126976        0
0 syz-executor0
[   8067]     0  8067    17585     8737   126976        0
0 syz-executor6
[   8070]     0  8070    17618     8739   131072        0
0 syz-executor3
[   8073]     0  8073    17618     8738   131072        0
0 syz-executor1
[   8074]     0  8074    17585     8737   126976        0
0 syz-executor6
 __rwsem_down_read_failed_common kernel/locking/rwsem-xadd.c:269 [inline]
 rwsem_down_read_failed+0x362/0x610 kernel/locking/rwsem-xadd.c:286
[   8075]     0  8075    17618     8739   131072        0
0 syz-executor3
[   8077]     0  8077    17618     8738   131072        0
0 syz-executor1
[   8079]     0  8079    17585     8739   126976        0
0 syz-executor7
[   8092]     0  8092    17618     8738   131072        0
0 syz-executor1
...


> tasks at for_each_process() under RCU. Since such situation is almost
> inflight fork bomb attack (the OOM killer will print similar tasks for
> so many times), it makes little sense to print all candidate tasks.
> Thus, this patch introduces 3 seconds limit for printing.
>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> ---
>  mm/oom_kill.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
>
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index f10aa53..48e5bf6 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -399,14 +399,22 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
>  {
>         struct task_struct *p;
>         struct task_struct *task;
> +       unsigned long start;
> +       unsigned int skipped = 0;
>
>         pr_info("Tasks state (memory values in pages):\n");
>         pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
>         rcu_read_lock();
> +       start = jiffies;
>         for_each_process(p) {
>                 if (oom_unkillable_task(p, memcg, nodemask))
>                         continue;
>
> +               if (time_after(jiffies, start + 3 * HZ)) {
> +                       skipped++;
> +                       continue;
> +               }
> +
>                 task = find_lock_task_mm(p);
>                 if (!task) {
>                         /*
> @@ -426,6 +434,8 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
>                 task_unlock(task);
>         }
>         rcu_read_unlock();
> +       if (skipped)
> +               pr_info("Printing %u tasks omitted.\n", skipped);
>  }
>
>  static void dump_header(struct oom_control *oc, struct task_struct *p)
> --
> 1.8.3.1
>
