Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 787294402ED
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 12:32:36 -0500 (EST)
Received: by wmuu63 with SMTP id u63so147396779wmu.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 09:32:35 -0800 (PST)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id j62si7180561wmd.65.2015.11.25.09.32.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 09:32:35 -0800 (PST)
Received: by wmuu63 with SMTP id u63so147396247wmu.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 09:32:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+ZdF09hOnb_bL4GNjytSMMGvNde8=9pdZt6gZQB1sp0hQ@mail.gmail.com>
References: <CACT4Y+ZCkv0BPOdo3aiheA5LXzXhcnuiw7kCoWL=b9FcC8-wqg@mail.gmail.com>
 <20151125084403.GA24703@dhcp22.suse.cz> <565592A1.50407@I-love.SAKURA.ne.jp>
 <CACT4Y+Zn+mK37-mvqDQTyt1Psp6HT2heT0e937SO24F7V1q7PA@mail.gmail.com>
 <201511260027.CCC26590.SOHFMQLVJOtFOF@I-love.SAKURA.ne.jp> <CACT4Y+ZdF09hOnb_bL4GNjytSMMGvNde8=9pdZt6gZQB1sp0hQ@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 25 Nov 2015 18:32:15 +0100
Message-ID: <CACT4Y+YhCXznHzu8ieQgA0spMq5=-Yfodt1jLDYz96rDoF5tyg@mail.gmail.com>
Subject: Re: WARNING in handle_mm_fault
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>, Eric Dumazet <edumazet@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Peter Zijlstra <peterz@infradead.org>

On Wed, Nov 25, 2015 at 6:21 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Wed, Nov 25, 2015 at 4:27 PM, Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
>> Dmitry Vyukov wrote:
>>> If the race described in
>>> http://www.spinics.net/lists/cgroups/msg14078.html does actually
>>> happen, then there is nothing to check.
>>> https://gcc.gnu.org/ml/gcc/2012-02/msg00005.html talks about different
>>> memory locations, if there is store-widening involving different
>>> memory locations, then this is a compiler bug. But the race happens on
>>> a single memory location, in such case the code is buggy.
>>>
>>
>> All ->in_execve ->in_iowait ->sched_reset_on_fork ->sched_contributes_to_load
>> ->sched_migrated ->memcg_may_oom ->memcg_kmem_skip_account ->brk_randomized
>> shares the same byte.
>>
>> sched_fork(p) modifies p->sched_reset_on_fork but p is not yet visible.
>> __sched_setscheduler(p) modifies p->sched_reset_on_fork.
>> try_to_wake_up(p) modifies p->sched_contributes_to_load.
>> perf_event_task_migrate(p) modifies p->sched_migrated.
>>
>> Trying to reproduce this problem with
>>
>>  static __always_inline bool
>>  perf_sw_migrate_enabled(void)
>>  {
>> -       if (static_key_false(&perf_swevent_enabled[PERF_COUNT_SW_CPU_MIGRATIONS]))
>> -               return true;
>>         return false;
>>  }
>>
>> would help testing ->sched_migrated case.
>
>
>
>
>
>
>
>
> I have some progress.
>
> With the following patch:
>
> dvyukov@dvyukov-z840:~/src/linux-dvyukov$ git diff
> include/linux/sched.h mm/memory.c
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 2fae7d8..4c126a1 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1455,6 +1455,8 @@ struct task_struct {
>         /* Used for emulating ABI behavior of previous Linux versions */
>         unsigned int personality;
>
> +       union {
> +       struct {
>         unsigned in_execve:1;   /* Tell the LSMs that the process is doing an
>                                  * execve */
>         unsigned in_iowait:1;
> @@ -1463,18 +1465,24 @@ struct task_struct {
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
>  #ifdef CONFIG_COMPAT_BRK
>         unsigned brk_randomized:1;
>  #endif
> +       };
> +       unsigned nonatomic_flags;
> +       };
>
>         unsigned long atomic_flags; /* Flags needing atomic access. */
>
> +
>         struct restart_block restart_block;
>
>         pid_t pid;
> diff --git a/mm/memory.c b/mm/memory.c
> index deb679c..6351dac 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -62,6 +62,7 @@
>  #include <linux/dma-debug.h>
>  #include <linux/debugfs.h>
>  #include <linux/userfaultfd_k.h>
> +#include <linux/kasan.h>
>
>  #include <asm/io.h>
>  #include <asm/pgalloc.h>
> @@ -3436,12 +3437,45 @@ int handle_mm_fault(struct mm_struct *mm,
> struct vm_area_struct *vma,
>          * Enable the memcg OOM handling for faults triggered in user
>          * space.  Kernel faults are handled more gracefully.
>          */
> -       if (flags & FAULT_FLAG_USER)
> +       if (flags & FAULT_FLAG_USER) {
> +               volatile int x;
> +               unsigned f0, f1;
> +               f0 = READ_ONCE(current->nonatomic_flags);
> +               for (x = 0; x < 1000; x++) {
> +                       WRITE_ONCE(current->nonatomic_flags, 0xaeaeaeae);
> +                       cpu_relax();
> +                       WRITE_ONCE(current->nonatomic_flags, 0xaeaeaeab);
> +                       cpu_relax();
> +                       f1 = READ_ONCE(current->nonatomic_flags);
> +                       if (f1 != 0xaeaeaeab) {
> +                               pr_err("enable: flags 0x%x -> 0x%x\n", f0, f1);
> +                               break;
> +                       }
> +               }
> +               WRITE_ONCE(current->nonatomic_flags, f0);
> +
>                 mem_cgroup_oom_enable();
> +       }
>
>         ret = __handle_mm_fault(mm, vma, address, flags);
>
>         if (flags & FAULT_FLAG_USER) {
> +               volatile int x;
> +               unsigned f0, f1;
> +               f0 = READ_ONCE(current->nonatomic_flags);
> +               for (x = 0; x < 1000; x++) {
> +                       WRITE_ONCE(current->nonatomic_flags, 0xaeaeaeae);
> +                       cpu_relax();
> +                       WRITE_ONCE(current->nonatomic_flags, 0xaeaeaeab);
> +                       cpu_relax();
> +                       f1 = READ_ONCE(current->nonatomic_flags);
> +                       if (f1 != 0xaeaeaeab) {
> +                               pr_err("enable: flags 0x%x -> 0x%x\n", f0, f1);
> +                               break;
> +                       }
> +               }
> +               WRITE_ONCE(current->nonatomic_flags, f0);
> +
>                 mem_cgroup_oom_disable();
>                  /*
>                   * The task may have entered a memcg OOM situation but
>
>
> I see:
>
> [  153.484152] enable: flags 0x8 -> 0xaeaeaeaf
> [  168.707786] enable: flags 0x8 -> 0xaeaeaeae
> [  169.654966] enable: flags 0x40 -> 0xaeaeaeae
> [  176.809080] enable: flags 0x48 -> 0xaeaeaeaa
> [  177.496219] enable: flags 0x8 -> 0xaeaeaeaf
> [  193.266703] enable: flags 0x0 -> 0xaeaeaeae
> [  199.536435] enable: flags 0x8 -> 0xaeaeaeae
> [  210.650809] enable: flags 0x48 -> 0xaeaeaeaf
> [  210.869397] enable: flags 0x8 -> 0xaeaeaeaf
> [  216.150804] enable: flags 0x8 -> 0xaeaeaeaa
> [  231.607211] enable: flags 0x8 -> 0xaeaeaeaf
> [  260.677408] enable: flags 0x48 -> 0xaeaeaeae
> [  272.065364] enable: flags 0x40 -> 0xaeaeaeaf
> [  281.594973] enable: flags 0x48 -> 0xaeaeaeaf
> [  282.899860] enable: flags 0x8 -> 0xaeaeaeaf
> [  286.472173] enable: flags 0x8 -> 0xaeaeaeae
> [  286.763203] enable: flags 0x8 -> 0xaeaeaeaf
> [  288.229107] enable: flags 0x0 -> 0xaeaeaeaf
> [  291.336522] enable: flags 0x8 -> 0xaeaeaeae
> [  310.082981] enable: flags 0x48 -> 0xaeaeaeaf
> [  313.798935] enable: flags 0x8 -> 0xaeaeaeaf
> [  343.340508] enable: flags 0x8 -> 0xaeaeaeaf
> [  344.170635] enable: flags 0x48 -> 0xaeaeaeaf
> [  357.568555] enable: flags 0x8 -> 0xaeaeaeaf
> [  359.158179] enable: flags 0x48 -> 0xaeaeaeaf
> [  361.188300] enable: flags 0x40 -> 0xaeaeaeaa
> [  365.636639] enable: flags 0x8 -> 0xaeaeaeaf




With a better check:

                volatile int x;
                unsigned f0, f1;
                f0 = READ_ONCE(current->nonatomic_flags);
                for (x = 0; x < 1000; x++) {
                        WRITE_ONCE(current->nonatomic_flags, 0xaeaeaeff);
                        cpu_relax();
                        WRITE_ONCE(current->nonatomic_flags, 0xaeaeae00);
                        cpu_relax();
                        f1 = READ_ONCE(current->nonatomic_flags);
                        if (f1 != 0xaeaeae00) {
                                pr_err("enable1: flags 0x%x -> 0x%x\n", f0, f1);
                                break;
                        }

                        WRITE_ONCE(current->nonatomic_flags, 0xaeaeae00);
                        cpu_relax();
                        WRITE_ONCE(current->nonatomic_flags, 0xaeaeaeff);
                        cpu_relax();
                        f1 = READ_ONCE(current->nonatomic_flags);
                        if (f1 != 0xaeaeaeff) {
                                pr_err("enable2: flags 0x%x -> 0x%x\n", f0, f1);
                                break;
                        }
                }
                WRITE_ONCE(current->nonatomic_flags, f0);


I see:

[   82.339662] enable1: flags 0x8 -> 0xaeaeae04
[  102.743386] enable1: flags 0x0 -> 0xaeaeaeff
[  122.209687] enable2: flags 0x0 -> 0xaeaeae04
[  142.366938] enable1: flags 0x8 -> 0xaeaeae04
[  157.273155] diable2: flags 0x40 -> 0xaeaeaefb
[  162.320346] enable2: flags 0x8 -> 0xaeaeae00
[  163.241090] enable2: flags 0x0 -> 0xaeaeaefb
[  194.266300] diable2: flags 0x40 -> 0xaeaeaefb
[  196.247483] enable1: flags 0x8 -> 0xaeaeae04
[  219.996095] enable2: flags 0x0 -> 0xaeaeaefb
[  228.088207] diable1: flags 0x48 -> 0xaeaeae04
[  228.802678] diable2: flags 0x40 -> 0xaeaeaefb
[  241.829173] enable1: flags 0x8 -> 0xaeaeae04
[  257.601127] diable2: flags 0x48 -> 0xaeaeae04
[  265.207038] enable2: flags 0x8 -> 0xaeaeaefb
[  269.887365] enable1: flags 0x0 -> 0xaeaeae04
[  272.254086] diable1: flags 0x40 -> 0xaeaeae04
[  272.480384] enable1: flags 0x8 -> 0xaeaeae04
[  276.430762] enable2: flags 0x8 -> 0xaeaeaefb
[  289.526677] enable1: flags 0x8 -> 0xaeaeae04


Which suggests that somebody messes with 3-rd bit (both sets and
resets). Assuming that compiler does not reorder fields, this bit is
sched_reset_on_fork.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
