Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE93928043F
	for <linux-mm@kvack.org>; Sun, 27 Aug 2017 00:17:51 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id v96so31307490ioi.9
        for <linux-mm@kvack.org>; Sat, 26 Aug 2017 21:17:51 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z123si5324824itc.60.2017.08.26.21.17.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 26 Aug 2017 21:17:50 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm,page_alloc: Don't call __node_reclaim() with oom_lock held.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1503577106-9196-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170825134714.844d9fb169e5b1883c3dd6eb@linux-foundation.org>
	<201708261028.HBH81733.HOtQJLMVFOFFOS@I-love.SAKURA.ne.jp>
In-Reply-To: <201708261028.HBH81733.HOtQJLMVFOFFOS@I-love.SAKURA.ne.jp>
Message-Id: <201708271317.FDB87559.QOJFOtLFMVFHOS@I-love.SAKURA.ne.jp>
Date: Sun, 27 Aug 2017 13:17:46 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, mgorman@suse.de, mhocko@suse.com, vbabka@suse.cz

Tetsuo Handa wrote:
> Andrew Morton wrote:
> > On Thu, 24 Aug 2017 21:18:25 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> > 
> > > We are doing last second memory allocation attempt before calling
> > > out_of_memory(). But since slab shrinker functions might indirectly
> > > wait for other thread's __GFP_DIRECT_RECLAIM && !__GFP_NORETRY memory
> > > allocations via sleeping locks, calling slab shrinker functions from
> > > node_reclaim() from get_page_from_freelist() with oom_lock held has
> > > possibility of deadlock. Therefore, make sure that last second memory
> > > allocation attempt does not call slab shrinker functions.
> > 
> > I wonder if there's any way we could gert lockdep to detect this sort
> > of thing.
> 
> That is hopeless regarding MM subsystem.
> 
> The root problem is that MM subsystem assumes that somebody else shall make
> progress for me. And direct reclaim does not check for other thread's progress
> (e.g. too_many_isolated() looping forever waiting for kswapd) and continue
> consuming CPU resource (e.g. deprive a thread doing schedule_timeout_killable()
> with oom_lock held of all CPU time for doing pointless get_page_from_freelist()
> etc.).
> 
> Since the page allocator chooses retry the attempt rather than wait for locks,
> lockdep won't help. The dependency is spreaded to all threads with timing and
> threshold checks, preventing threads from calling operations which lockdep
> will detect.

Here is an example. If we use trylock, lockdep cannot detect the dependency.

----------
#include <linux/module.h>

static int __init test_init(void)
{
        static DEFINE_MUTEX(my_oom_lock);
        static DEFINE_MUTEX(some_shrinker_lock);

        if (!mutex_trylock(&my_oom_lock))
                return -EINVAL;
        mutex_lock(&some_shrinker_lock);
        mutex_unlock(&some_shrinker_lock);
        mutex_unlock(&my_oom_lock);

        mutex_lock(&some_shrinker_lock);
        if (!mutex_trylock(&my_oom_lock))
                goto unlock;
        mutex_unlock(&my_oom_lock);
 unlock:
        mutex_unlock(&some_shrinker_lock);
        return -EINVAL;
}

module_init(test_init);
MODULE_LICENSE("GPL");
----------

If we don't use trylock, lockdep can detect the dependency.

----------
#include <linux/module.h>

static int __init test_init(void)
{
        static DEFINE_MUTEX(my_oom_lock);
        static DEFINE_MUTEX(some_shrinker_lock);

        if (!mutex_trylock(&my_oom_lock))
                return -EINVAL;
        mutex_lock(&some_shrinker_lock);
        mutex_unlock(&some_shrinker_lock);
        mutex_unlock(&my_oom_lock);

        mutex_lock(&some_shrinker_lock);
        mutex_lock(&my_oom_lock);
        mutex_unlock(&my_oom_lock);
        mutex_unlock(&some_shrinker_lock);
        return -EINVAL;
}

module_init(test_init);
MODULE_LICENSE("GPL");
----------

----------
[  276.343968] ======================================================
[  276.345523] WARNING: possible circular locking dependency detected
[  276.347101] 4.13.0-rc5-next-20170817 #666 Tainted: G           O
[  276.349421] ------------------------------------------------------
[  276.351506] insmod/9628 is trying to acquire lock:
[  276.354961]  (my_oom_lock){+.+.}, at: [<ffffffffa015f056>] test_init+0x56/0x1000 [test]
[  276.357598]
but task is already holding lock:
[  276.359453]  (some_shrinker_lock){+.+.}, at: [<ffffffffa015f048>] test_init+0x48/0x1000 [test]
[  276.361693]
which lock already depends on the new lock.

[  276.364402]
the existing dependency chain (in reverse order) is:
[  276.367241]
-> #1 (some_shrinker_lock){+.+.}:
[  276.369246]        __lock_acquire+0x1292/0x15f0
[  276.370752]        lock_acquire+0x82/0xd0
[  276.372156]        __mutex_lock+0x83/0x950
[  276.373533]        mutex_lock_nested+0x16/0x20
[  276.374894]        test_init+0x22/0x1000 [test]
[  276.376396]        do_one_initcall+0x4c/0x1a0
[  276.377752]        do_init_module+0x56/0x1ea
[  276.379110]        load_module+0x20d1/0x2600
[  276.380409]        SyS_finit_module+0xc5/0xd0
[  276.381892]        do_syscall_64+0x61/0x1d0
[  276.383391]        return_from_SYSCALL_64+0x0/0x7a
[  276.385004]
-> #0 (my_oom_lock){+.+.}:
[  276.386921]        check_prev_add+0x832/0x840
[  276.388210]        __lock_acquire+0x1292/0x15f0
[  276.389526]        lock_acquire+0x82/0xd0
[  276.390670]        __mutex_lock+0x83/0x950
[  276.391994]        mutex_lock_nested+0x16/0x20
[  276.393793]        test_init+0x56/0x1000 [test]
[  276.395169]        do_one_initcall+0x4c/0x1a0
[  276.396883]        do_init_module+0x56/0x1ea
[  276.399988]        load_module+0x20d1/0x2600
[  276.401669]        SyS_finit_module+0xc5/0xd0
[  276.403050]        do_syscall_64+0x61/0x1d0
[  276.404407]        return_from_SYSCALL_64+0x0/0x7a
[  276.405771]
other info that might help us debug this:

[  276.408627]  Possible unsafe locking scenario:

[  276.410712]        CPU0                    CPU1
[  276.412094]        ----                    ----
[  276.413373]   lock(some_shrinker_lock);
[  276.414489]                                lock(my_oom_lock);
[  276.416584]                                lock(some_shrinker_lock);
[  276.418423]   lock(my_oom_lock);
[  276.419639]
 *** DEADLOCK ***

[  276.421869] 1 lock held by insmod/9628:
[  276.422945]  #0:  (some_shrinker_lock){+.+.}, at: [<ffffffffa015f048>] test_init+0x48/0x1000 [test]
[  276.425026]
stack backtrace:
[  276.426627] CPU: 3 PID: 9628 Comm: insmod Tainted: G           O    4.13.0-rc5-next-20170817 #666
[  276.428668] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  276.431176] Call Trace:
[  276.432108]  dump_stack+0x67/0x9e
[  276.433320]  print_circular_bug+0x390/0x39e
[  276.434728]  check_prev_add+0x832/0x840
[  276.436114]  ? add_lock_to_list.isra.25+0xe0/0xe0
[  276.437465]  ? native_sched_clock+0x36/0xa0
[  276.438755]  ? add_lock_to_list.isra.25+0xe0/0xe0
[  276.440107]  __lock_acquire+0x1292/0x15f0
[  276.441366]  ? test_init+0x56/0x1000 [test]
[  276.442683]  lock_acquire+0x82/0xd0
[  276.443799]  ? test_init+0x56/0x1000 [test]
[  276.445127]  __mutex_lock+0x83/0x950
[  276.446297]  ? test_init+0x56/0x1000 [test]
[  276.447542]  ? test_init+0x56/0x1000 [test]
[  276.448896]  ? 0xffffffffa015f000
[  276.450321]  ? __mutex_unlock_slowpath+0x4d/0x2a0
[  276.451822]  ? 0xffffffffa015f000
[  276.452979]  mutex_lock_nested+0x16/0x20
[  276.454125]  test_init+0x56/0x1000 [test]
[  276.455296]  do_one_initcall+0x4c/0x1a0
[  276.456752]  ? do_init_module+0x1d/0x1ea
[  276.457932]  ? kmem_cache_alloc+0x19e/0x1e0
[  276.459135]  do_init_module+0x56/0x1ea
[  276.460336]  load_module+0x20d1/0x2600
[  276.461534]  ? __symbol_get+0x90/0x90
[  276.462681]  SyS_finit_module+0xc5/0xd0
[  276.463873]  do_syscall_64+0x61/0x1d0
[  276.464968]  entry_SYSCALL64_slow_path+0x25/0x25
[  276.466432] RIP: 0033:0x7fca5de2f7f9
[  276.467839] RSP: 002b:00007ffe0cc50238 EFLAGS: 00000202 ORIG_RAX: 0000000000000139
[  276.469852] RAX: ffffffffffffffda RBX: 00000000010b6220 RCX: 00007fca5de2f7f9
[  276.471918] RDX: 0000000000000000 RSI: 000000000041a2d8 RDI: 0000000000000003
[  276.471919] RBP: 000000000041a2d8 R08: 0000000000000000 R09: 00007ffe0cc503d8
[  276.471919] R10: 0000000000000003 R11: 0000000000000202 R12: 0000000000000000
[  276.471920] R13: 00000000010b61f0 R14: 0000000000000000 R15: 0000000000000000
----------

This is because the page allocator pretends that progress is made
without waiting for lock, but actually the page allocator cannot
make progress without waiting for lock. As long as we use trylock,
lockdep won't detect "this sort of thing". (Or we want to jump into
lockdep annotation hell?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
