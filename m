Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6714E6B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 08:06:20 -0500 (EST)
Received: by wmww144 with SMTP id w144so68501300wmw.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 05:06:20 -0800 (PST)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id w132si5688640wma.114.2015.11.25.05.06.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 05:06:19 -0800 (PST)
Received: by wmvv187 with SMTP id v187so256144921wmv.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 05:06:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151124223116.GA2874@cmpxchg.org>
References: <CACT4Y+ZCkv0BPOdo3aiheA5LXzXhcnuiw7kCoWL=b9FcC8-wqg@mail.gmail.com>
 <20151124223116.GA2874@cmpxchg.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 25 Nov 2015 14:05:58 +0100
Message-ID: <CACT4Y+ZbBNji+176aZmxf5McxS+EV3Sj6Gw+D292JPYx1nyuwQ@mail.gmail.com>
Subject: Re: WARNING in handle_mm_fault
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, Eric Dumazet <edumazet@google.com>, Greg Thelen <gthelen@google.com>

On Tue, Nov 24, 2015 at 11:31 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> Hi Dmitry,
>
> On Tue, Nov 24, 2015 at 02:50:26PM +0100, Dmitry Vyukov wrote:
>> As a blind guess, I've added the following BUG into copy_process:
>>
>> diff --git a/kernel/fork.c b/kernel/fork.c
>> index b4dc490..c5667e8 100644
>> --- a/kernel/fork.c
>> +++ b/kernel/fork.c
>> @@ -1620,6 +1620,8 @@ static struct task_struct *copy_process(unsigned
>> long clone_flags,
>>         trace_task_newtask(p, clone_flags);
>>         uprobe_copy_process(p, clone_flags);
>>
>> +       BUG_ON(p->memcg_may_oom);
>> +
>>         return p;
>
> Thanks for your report.
>
> I don't see how this could happen through the legitimate setters of
> p->memcg_may_oom. Something must clobber it. What happens with the
> following patch applied?
>
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index edad7a4..42e1285 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1463,9 +1463,11 @@ struct task_struct {
>         unsigned sched_reset_on_fork:1;
>         unsigned sched_contributes_to_load:1;
>         unsigned sched_migrated:1;
> +       unsigned dummy_a:1;
>  #ifdef CONFIG_MEMCG
>         unsigned memcg_may_oom:1;
>  #endif
> +       unsigned dummy_b:1;
>  #ifdef CONFIG_MEMCG_KMEM
>         unsigned memcg_kmem_skip_account:1;
>  #endif
> diff --git a/kernel/fork.c b/kernel/fork.c
> index f97f2c4..ab6f7ba 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1617,6 +1617,12 @@ static struct task_struct *copy_process(unsigned long clone_flags,
>         trace_task_newtask(p, clone_flags);
>         uprobe_copy_process(p, clone_flags);
>
> +       if (p->dummy_a || p->dummy_b || p->memcg_may_oom) {
> +               printk(KERN_ALERT "dummy_a:%d dummy_b:%d memcg_may_oom:%d\n",
> +                      p->dummy_a, p->dummy_b, p->memcg_may_oom);
> +               BUG();
> +       }
> +
>         return p;
>
>  bad_fork_cancel_cgroup:


I cannot reproduce the condition again, either with your patch or with
mine patch... Will try harder.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
