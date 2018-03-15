Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 89C316B0007
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 08:09:46 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id o61-v6so3123446pld.5
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 05:09:46 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00123.outbound.protection.outlook.com. [40.107.0.123])
        by mx.google.com with ESMTPS id 3-v6si3844268plr.440.2018.03.15.05.09.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 15 Mar 2018 05:09:45 -0700 (PDT)
Subject: Re: [PATCH] percpu: Allow to kill tasks doing pcpu_alloc() and
 waiting for pcpu_balance_workfn()
References: <152102825828.13166.9574628787314078889.stgit@localhost.localdomain>
 <20180314135631.3e21b31b154e9f3036fa6c52@linux-foundation.org>
 <20180314220909.GE2943022@devbig577.frc2.facebook.com>
 <20180314152203.c06fce436d221d34d3e4cf4a@linux-foundation.org>
 <c5c1c98b-9e0c-ec09-36c6-4266ad239ef1@virtuozzo.com>
 <5a4a1aae-8c61-de28-d3cd-2f8f4355f050@i-love.sakura.ne.jp>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <77e9be93-3c94-269e-3100-463b39ed9776@virtuozzo.com>
Date: Thu, 15 Mar 2018 15:09:37 +0300
MIME-Version: 1.0
In-Reply-To: <5a4a1aae-8c61-de28-d3cd-2f8f4355f050@i-love.sakura.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>
Cc: cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 15.03.2018 13:48, Tetsuo Handa wrote:
> On 2018/03/15 17:58, Kirill Tkhai wrote:
>> On 15.03.2018 01:22, Andrew Morton wrote:
>>> On Wed, 14 Mar 2018 15:09:09 -0700 Tejun Heo <tj@kernel.org> wrote:
>>>
>>>> Hello, Andrew.
>>>>
>>>> On Wed, Mar 14, 2018 at 01:56:31PM -0700, Andrew Morton wrote:
>>>>> It would benefit from a comment explaining why we're doing this (it's
>>>>> for the oom-killer).
>>>>
>>>> Will add.
>>>>
>>>>> My memory is weak and our documentation is awful.A  What does
>>>>> mutex_lock_killable() actually do and how does it differ from
>>>>> mutex_lock_interruptible()?A  Userspace tasks can run pcpu_alloc() and I
>>>>
>>>> IIRC, killable listens only to SIGKILL.
> 
> I think that killable listens to any signal which results in termination of
> that process. For example, if a process is configured to terminate upon SIGINT,
> fatal_signal_pending() becomes true upon SIGINT.

It shouldn't act on SIGINT:

static inline int __fatal_signal_pending(struct task_struct *p)
{
        return unlikely(sigismember(&p->pending.signal, SIGKILL));
}

static inline int fatal_signal_pending(struct task_struct *p)
{
        return signal_pending(p) && __fatal_signal_pending(p);
}

>>>>
>>>>> wonder if there's any way in which a userspace-delivered signal can
>>>>> disrupt another userspace task's memory allocation attempt?
>>>>
>>>> Hmm... maybe.A  Just honoring SIGKILL *should* be fine but the alloc
>>>> failure paths might be broken, so there are some risks.A  Given that
>>>> the cases where userspace tasks end up allocation percpu memory is
>>>> pretty limited and/or priviledged (like mount, bpf), I don't think the
>>>> risks are high tho.
>>>
>>> hm.A  spose so.A  Maybe.A  Are there other ways?A  I assume the time is
>>> being spent in pcpu_create_chunk()?A  We could drop the mutex while
>>> running that stuff and take the appropriate did-we-race-with-someone
>>> testing after retaking it.A  Or similar.
>>
>> The balance work spends its time in pcpu_populate_chunk(). There are
>> two stacks of this problem:
> 
> Will you show me more contexts? Unless CONFIG_MMU=n kernels, the OOM reaper
> reclaims memory from the OOM victim. Therefore, "If tasks doing pcpu_alloc()
> are choosen by OOM killer, they can't exit, because they are waiting for the
> mutex." should not cause problems. Of course, giving up upon SIGKILL is nice
> regardless.

There is a test case, which leads my 4 cpus VM to the OOM:

#define _GNU_SOURCE
#include <sched.h>

main()
{
	int i;
	for (i = 0; i < 8; i++)
		fork();
	daemon(1,1);

	while (1)
		unshare(CLONE_NEWNET);
}

The problem is that net namespace init/exit methods are not made to be executed in parallel,
and exclusive mutex is used there. I'm working on solution at the moment, and you may find
that I've done in net-next.git, if you are interested.

pcpu_alloc()-related OOM happens on stable kernel, and it's easy to trigger it by the test.
pcpu is not the only problem there, but it's one of them, and since there is logically seen
OOM deadlock in pcpu code like it's written in patch description, and the patch fixes it.

Going away from this problem to general, I think all allocating/registering actions in kernel
should be made with killable primitives, if they can fail. And the generic policy should be
using mutex_lock_killable() instead of mutex_lock(). Otherwise, OOM victims can't died,
if they waiting for a mutex, which is held by a process making a reclaim. This makes circular
dependencies and just makes OOM badness counting useless, while it must not be so.

>>
>> [A  106.313267] kworker/2:2A A A A  D13832A A  936A A A A A  2 0x80000000
>> [A  106.313740] Workqueue: events pcpu_balance_workfn
>> [A  106.314109] Call Trace:
>> [A  106.314293]A  ? __schedule+0x267/0x750
>> [A  106.314570]A  schedule+0x2d/0x90
>> [A  106.314803]A  schedule_timeout+0x17f/0x390
>> [A  106.315106]A  ? __next_timer_interrupt+0xc0/0xc0
>> [A  106.315429]A  __alloc_pages_slowpath+0xb73/0xd90
>> [A  106.315792]A  __alloc_pages_nodemask+0x16a/0x210
>> [A  106.316148]A  pcpu_populate_chunk+0xce/0x300
>> [A  106.316479]A  pcpu_balance_workfn+0x3f3/0x580
>> [A  106.316853]A  ? _raw_spin_unlock_irq+0xe/0x30
>> [A  106.317227]A  ? finish_task_switch+0x8d/0x250
>> [A  106.317632]A  process_one_work+0x1b7/0x410
>> [A  106.317970]A  worker_thread+0x26/0x3d0
>> [A  106.318304]A  ? process_one_work+0x410/0x410
>> [A  106.318649]A  kthread+0x10e/0x130
>> [A  106.318916]A  ? __kthread_create_worker+0x120/0x120
>> [A  106.319360]A  ret_from_fork+0x35/0x40
>>
>> [A  106.453375] a.outA A A A A A A A A A  D13400A  3670A A A A A  1 0x00100004
>> [A  106.453880] Call Trace:
>> [A  106.454114]A  ? __schedule+0x267/0x750
>> [A  106.454427]A  schedule+0x2d/0x90
>> [A  106.454829]A  schedule_preempt_disabled+0xf/0x20
>> [A  106.455422]A  __mutex_lock.isra.2+0x181/0x4d0
>> [A  106.455988]A  ? pcpu_alloc+0x3c4/0x670
>> [A  106.456465]A  pcpu_alloc+0x3c4/0x670
>> [A  106.456973]A  ? preempt_count_add+0x63/0x90
>> [A  106.457401]A  ? __local_bh_enable_ip+0x2e/0x60
>> [A  106.457882]A  ipv6_add_dev+0x121/0x490
>> [A  106.458330]A  addrconf_notify+0x27b/0x9a0
>> [A  106.458823]A  ? inetdev_init+0xd7/0x150
>> [A  106.459270]A  ? inetdev_event+0x339/0x4b0
>> [A  106.459738]A  ? preempt_count_add+0x63/0x90
>> [A  106.460243]A  ? _raw_spin_lock_irq+0xf/0x30
>> [A  106.460747]A  ? notifier_call_chain+0x42/0x60
>> [A  106.461271]A  notifier_call_chain+0x42/0x60
>> [A  106.461819]A  register_netdevice+0x415/0x530
>> [A  106.462364]A  register_netdev+0x11/0x20
>> [A  106.462849]A  loopback_net_init+0x43/0x90
>> [A  106.463216]A  ops_init+0x3b/0x100
>> [A  106.463516]A  setup_net+0x7d/0x150
>> [A  106.463831]A  copy_net_ns+0x14b/0x180
>> [A  106.464134]A  create_new_namespaces+0x117/0x1b0
>> [A  106.464481]A  unshare_nsproxy_namespaces+0x5b/0x90
>> [A  106.464864]A  SyS_unshare+0x1b0/0x300
>>
>> [A  106.536845] Kernel panic - not syncing: Out of memory and no killable processes...
> 
> These two stacks of this problem are not blocked at mutex_lock().
> 
> Why all OOM-killable threads were killed? There were only few?
> Does pcpu_alloc() allocate so much enough to deplete memory reserves?

The test eats all kmem, so OOM kills everything. It's because of slow net namespace
destruction. But this patch is about "half"-deadlock between pcpu_alloc() and worker,
which slows down OOM reaping. There is potential possibility, and it's good to fix it.
I've seen a crash with waiting on the mutex, but I have not saved it. It seems the test
may reproduce it after some time. With the patch applied I don't see pcpu-related crashes
in pcpu_alloc() at all.

Kirill
