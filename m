Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3F7A16B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 14:13:59 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id k127so41599559vke.7
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 11:13:59 -0800 (PST)
Received: from mail-ua0-x229.google.com (mail-ua0-x229.google.com. [2607:f8b0:400c:c08::229])
        by mx.google.com with ESMTPS id b186si430601vka.65.2017.02.06.11.13.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 11:13:57 -0800 (PST)
Received: by mail-ua0-x229.google.com with SMTP id y9so68301644uae.2
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 11:13:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+ZT+_L3deDUcmBkr_Pr3KdCdLv6ON=2QHbK5YnBxJfLDg@mail.gmail.com>
References: <CACT4Y+asbKDni4RBavNf0-HwApTXjbbNko9eQbU6zCOgB2Yvnw@mail.gmail.com>
 <c7658ace-23ae-227a-2ea9-7e6bd1c8c761@suse.cz> <CACT4Y+ZT+_L3deDUcmBkr_Pr3KdCdLv6ON=2QHbK5YnBxJfLDg@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 6 Feb 2017 20:13:35 +0100
Message-ID: <CACT4Y+Z-juavN8s+5sc-PB0rbqy4zmsRpc6qZBg3C7z3topLTw@mail.gmail.com>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jan 30, 2017 at 4:48 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Sun, Jan 29, 2017 at 6:22 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>> On 29.1.2017 13:44, Dmitry Vyukov wrote:
>>> Hello,
>>>
>>> I've got the following deadlock report while running syzkaller fuzzer
>>> on f37208bc3c9c2f811460ef264909dfbc7f605a60:
>>>
>>> [ INFO: possible circular locking dependency detected ]
>>> 4.10.0-rc5-next-20170125 #1 Not tainted
>>> -------------------------------------------------------
>>> syz-executor3/14255 is trying to acquire lock:
>>>  (cpu_hotplug.dep_map){++++++}, at: [<ffffffff814271c7>]
>>> get_online_cpus+0x37/0x90 kernel/cpu.c:239
>>>
>>> but task is already holding lock:
>>>  (pcpu_alloc_mutex){+.+.+.}, at: [<ffffffff81937fee>]
>>> pcpu_alloc+0xbfe/0x1290 mm/percpu.c:897
>>>
>>> which lock already depends on the new lock.
>>
>> I suspect the dependency comes from recent changes in drain_all_pages(). They
>> were later redone (for other reasons, but nice to have another validation) in
>> the mmots patch [1], which AFAICS is not yet in mmotm and thus linux-next. Could
>> you try if it helps?
>
> It happened only once on linux-next, so I can't verify the fix. But I
> will watch out for other occurrences.


Unfortunately it does not seem to help.
Fuzzer now runs on 510948533b059f4f5033464f9f4a0c32d4ab0c08 of
mmotm/auto-latest
(git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git):

commit 510948533b059f4f5033464f9f4a0c32d4ab0c08
Date:   Thu Feb 2 10:08:47 2017 +0100
    mmotm: userfaultfd-non-cooperative-add-event-for-memory-unmaps-fix

The commit you referenced is already there:

commit 806b158031ca0b4714e775898396529a758ebc2c
Date:   Thu Feb 2 08:53:16 2017 +0100
    mm, page_alloc: use static global work_struct for draining per-cpu pages

But I still got:

[ INFO: possible circular locking dependency detected ]
4.9.0 #6 Not tainted
-------------------------------------------------------
syz-executor1/8199 is trying to acquire lock:
 (cpu_hotplug.dep_map){++++++}, at: [<ffffffff81422fe7>]
get_online_cpus+0x37/0x90 kernel/cpu.c:246
but task is already holding lock:
 (pcpu_alloc_mutex){+.+.+.}, at: [<ffffffff818f07ea>]
pcpu_alloc+0xbda/0x1280 mm/percpu.c:896
which lock already depends on the new lock.

the existing dependency chain (in reverse order) is:

       [  403.953319] [<ffffffff8156fc29>] validate_chain
kernel/locking/lockdep.c:2265 [inline]
       [  403.953319] [<ffffffff8156fc29>]
__lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
       [  403.961232] [<ffffffff81571db1>] lock_acquire+0x2a1/0x630
kernel/locking/lockdep.c:3753
       [  403.968788] [<ffffffff8436697e>] __mutex_lock_common
kernel/locking/mutex.c:521 [inline]
       [  403.968788] [<ffffffff8436697e>]
mutex_lock_nested+0x24e/0xff0 kernel/locking/mutex.c:621
       [  403.976782] [<ffffffff818f07ea>] pcpu_alloc+0xbda/0x1280
mm/percpu.c:896
       [  403.984266] [<ffffffff818f0ee4>] __alloc_percpu+0x24/0x30
mm/percpu.c:1075
       [  403.991873] [<ffffffff816543e3>]
smpcfd_prepare_cpu+0x73/0xd0 kernel/smp.c:44
       [  403.999799] [<ffffffff814240b4>]
cpuhp_invoke_callback+0x254/0x1480 kernel/cpu.c:136
       [  404.008253] [<ffffffff81425821>]
cpuhp_up_callbacks+0x81/0x2a0 kernel/cpu.c:493
       [  404.016365] [<ffffffff81427bf3>] _cpu_up+0x1e3/0x2a0 kernel/cpu.c:1057
       [  404.023507] [<ffffffff81427d23>] do_cpu_up+0x73/0xa0 kernel/cpu.c:1087
       [  404.030647] [<ffffffff81427d68>] cpu_up+0x18/0x20 kernel/cpu.c:1095
       [  404.037523] [<ffffffff854ede84>] smp_init+0xe9/0xee kernel/smp.c:564
       [  404.044559] [<ffffffff85482f81>]
kernel_init_freeable+0x439/0x690 init/main.c:1010
       [  404.052811] [<ffffffff84357083>] kernel_init+0x13/0x180
init/main.c:941
       [  404.060198] [<ffffffff84377baa>] ret_from_fork+0x2a/0x40
arch/x86/entry/entry_64.S:433

       [  404.072827] [<ffffffff8156fc29>] validate_chain
kernel/locking/lockdep.c:2265 [inline]
       [  404.072827] [<ffffffff8156fc29>]
__lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
       [  404.080733] [<ffffffff81571db1>] lock_acquire+0x2a1/0x630
kernel/locking/lockdep.c:3753
       [  404.088311] [<ffffffff8436697e>] __mutex_lock_common
kernel/locking/mutex.c:521 [inline]
       [  404.088311] [<ffffffff8436697e>]
mutex_lock_nested+0x24e/0xff0 kernel/locking/mutex.c:621
       [  404.096318] [<ffffffff81427876>]
cpu_hotplug_begin+0x206/0x2e0 kernel/cpu.c:304
       [  404.104321] [<ffffffff81427ada>] _cpu_up+0xca/0x2a0 kernel/cpu.c:1011
       [  404.111357] [<ffffffff81427d23>] do_cpu_up+0x73/0xa0 kernel/cpu.c:1087
       [  404.118480] [<ffffffff81427d68>] cpu_up+0x18/0x20 kernel/cpu.c:1095
       [  404.125360] [<ffffffff854ede84>] smp_init+0xe9/0xee kernel/smp.c:564
       [  404.132393] [<ffffffff85482f81>]
kernel_init_freeable+0x439/0x690 init/main.c:1010
       [  404.140668] [<ffffffff84357083>] kernel_init+0x13/0x180
init/main.c:941
       [  404.148079] [<ffffffff84377baa>] ret_from_fork+0x2a/0x40
arch/x86/entry/entry_64.S:433

       [  404.160977] [<ffffffff8156976d>] check_prev_add
kernel/locking/lockdep.c:1828 [inline]
       [  404.160977] [<ffffffff8156976d>]
check_prevs_add+0xa8d/0x1c00 kernel/locking/lockdep.c:1938
       [  404.168898] [<ffffffff8156fc29>] validate_chain
kernel/locking/lockdep.c:2265 [inline]
       [  404.168898] [<ffffffff8156fc29>]
__lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
       [  404.176844] [<ffffffff81571db1>] lock_acquire+0x2a1/0x630
kernel/locking/lockdep.c:3753
       [  404.184416] [<ffffffff81423012>] get_online_cpus+0x62/0x90
kernel/cpu.c:248
       [  404.192103] [<ffffffff8185fcf8>] drain_all_pages+0xf8/0x710
mm/page_alloc.c:2385
       [  404.199880] [<ffffffff81865e5d>]
__alloc_pages_direct_reclaim mm/page_alloc.c:3440 [inline]
       [  404.199880] [<ffffffff81865e5d>]
__alloc_pages_slowpath+0x8fd/0x2370 mm/page_alloc.c:3778
       [  404.208406] [<ffffffff818681c5>]
__alloc_pages_nodemask+0x8f5/0xc60 mm/page_alloc.c:3980
       [  404.216851] [<ffffffff818ed0c1>] __alloc_pages
include/linux/gfp.h:426 [inline]
       [  404.216851] [<ffffffff818ed0c1>] __alloc_pages_node
include/linux/gfp.h:439 [inline]
       [  404.216851] [<ffffffff818ed0c1>] alloc_pages_node
include/linux/gfp.h:453 [inline]
       [  404.216851] [<ffffffff818ed0c1>] pcpu_alloc_pages
mm/percpu-vm.c:93 [inline]
       [  404.216851] [<ffffffff818ed0c1>]
pcpu_populate_chunk+0x1e1/0x900 mm/percpu-vm.c:282
       [  404.225015] [<ffffffff818f0a11>] pcpu_alloc+0xe01/0x1280
mm/percpu.c:998
       [  404.232482] [<ffffffff818f0eb7>]
__alloc_percpu_gfp+0x27/0x30 mm/percpu.c:1062
       [  404.240389] [<ffffffff817d25b2>] bpf_array_alloc_percpu
kernel/bpf/arraymap.c:34 [inline]
       [  404.240389] [<ffffffff817d25b2>] array_map_alloc+0x532/0x710
kernel/bpf/arraymap.c:99
       [  404.248224] [<ffffffff817ba034>] find_and_alloc_map
kernel/bpf/syscall.c:34 [inline]
       [  404.248224] [<ffffffff817ba034>] map_create
kernel/bpf/syscall.c:188 [inline]
       [  404.248224] [<ffffffff817ba034>] SYSC_bpf
kernel/bpf/syscall.c:870 [inline]
       [  404.248224] [<ffffffff817ba034>] SyS_bpf+0xd64/0x2500
kernel/bpf/syscall.c:827
       [  404.255434] [<ffffffff84377941>] entry_SYSCALL_64_fastpath+0x1f/0xc2

other info that might help us debug this:

Chain exists of:
 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(pcpu_alloc_mutex);
                               lock(cpu_hotplug.lock);
                               lock(pcpu_alloc_mutex);
  lock(cpu_hotplug.dep_map);

 *** DEADLOCK ***

2 locks held by syz-executor1/8199:
 #0:  (pcpu_alloc_mutex){+.+.+.}, at: [<ffffffff818f07ea>]
pcpu_alloc+0xbda/0x1280 mm/percpu.c:896
 #1:  (pcpu_drain_mutex){+.+...}, at: [<ffffffff8185fcd7>]
drain_all_pages+0xd7/0x710 mm/page_alloc.c:2375

stack backtrace:
CPU: 0 PID: 8199 Comm: syz-executor1 Not tainted 4.9.0 #6
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
 ffff88017ea4e118 ffffffff8234d0df ffffffff00000000 1ffff1002fd49bb6
 ffffed002fd49bae 0000000041b58ab3 ffffffff84b38180 ffffffff8234cdf1
 ffffffff84b00510 ffffffff81560170 ffff88018ab02200 0000000041b58ab3
Call Trace:
 [<ffffffff8234d0df>] __dump_stack lib/dump_stack.c:15 [inline]
 [<ffffffff8234d0df>] dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 [<ffffffff815673e7>] print_circular_bug+0x307/0x3b0
kernel/locking/lockdep.c:1202
 [<ffffffff8156976d>] check_prev_add kernel/locking/lockdep.c:1828 [inline]
 [<ffffffff8156976d>] check_prevs_add+0xa8d/0x1c00 kernel/locking/lockdep.c:1938
 [<ffffffff8156fc29>] validate_chain kernel/locking/lockdep.c:2265 [inline]
 [<ffffffff8156fc29>] __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
 [<ffffffff81571db1>] lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
 [<ffffffff81423012>] get_online_cpus+0x62/0x90 kernel/cpu.c:248
 [<ffffffff8185fcf8>] drain_all_pages+0xf8/0x710 mm/page_alloc.c:2385
 [<ffffffff81865e5d>] __alloc_pages_direct_reclaim mm/page_alloc.c:3440 [inline]
 [<ffffffff81865e5d>] __alloc_pages_slowpath+0x8fd/0x2370 mm/page_alloc.c:3778
 [<ffffffff818681c5>] __alloc_pages_nodemask+0x8f5/0xc60 mm/page_alloc.c:3980
 [<ffffffff818ed0c1>] __alloc_pages include/linux/gfp.h:426 [inline]
 [<ffffffff818ed0c1>] __alloc_pages_node include/linux/gfp.h:439 [inline]
 [<ffffffff818ed0c1>] alloc_pages_node include/linux/gfp.h:453 [inline]
 [<ffffffff818ed0c1>] pcpu_alloc_pages mm/percpu-vm.c:93 [inline]
 [<ffffffff818ed0c1>] pcpu_populate_chunk+0x1e1/0x900 mm/percpu-vm.c:282
 [<ffffffff818f0a11>] pcpu_alloc+0xe01/0x1280 mm/percpu.c:998
 [<ffffffff818f0eb7>] __alloc_percpu_gfp+0x27/0x30 mm/percpu.c:1062
 [<ffffffff817d25b2>] bpf_array_alloc_percpu kernel/bpf/arraymap.c:34 [inline]
 [<ffffffff817d25b2>] array_map_alloc+0x532/0x710 kernel/bpf/arraymap.c:99
 [<ffffffff817ba034>] find_and_alloc_map kernel/bpf/syscall.c:34 [inline]
 [<ffffffff817ba034>] map_create kernel/bpf/syscall.c:188 [inline]
 [<ffffffff817ba034>] SYSC_bpf kernel/bpf/syscall.c:870 [inline]
 [<ffffffff817ba034>] SyS_bpf+0xd64/0x2500 kernel/bpf/syscall.c:827
 [<ffffffff84377941>] entry_SYSCALL_64_fastpath+0x1f/0xc2
syz-executor1: page allocation failure: order:0,
mode:0x14001c2(GFP_KERNEL|__GFP_HIGHMEM|__GFP_COLD), nodemask=(null)
syz-executor1 cpuset=/ mems_allowed=0
CPU: 0 PID: 8199 Comm: syz-executor1 Not tainted 4.9.0 #6
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
 ffff88017ea4eb80 ffffffff8234d0df ffffffff00000000 1ffff1002fd49d03
 ffffed002fd49cfb 0000000041b58ab3 ffffffff84b38180 ffffffff8234cdf1
 0000000000000282 ffffffff84fd53c0 ffff8801dae65b38 ffff88017ea4e7b8
Call Trace:
 [<ffffffff8234d0df>] __dump_stack lib/dump_stack.c:15 [inline]
 [<ffffffff8234d0df>] dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 [<ffffffff8186530f>] warn_alloc+0x21f/0x360 mm/page_alloc.c:3126
 [<ffffffff818671f8>] __alloc_pages_slowpath+0x1c98/0x2370 mm/page_alloc.c:3890
 [<ffffffff818681c5>] __alloc_pages_nodemask+0x8f5/0xc60 mm/page_alloc.c:3980
 [<ffffffff818ed0c1>] __alloc_pages include/linux/gfp.h:426 [inline]
 [<ffffffff818ed0c1>] __alloc_pages_node include/linux/gfp.h:439 [inline]
 [<ffffffff818ed0c1>] alloc_pages_node include/linux/gfp.h:453 [inline]
 [<ffffffff818ed0c1>] pcpu_alloc_pages mm/percpu-vm.c:93 [inline]
 [<ffffffff818ed0c1>] pcpu_populate_chunk+0x1e1/0x900 mm/percpu-vm.c:282
 [<ffffffff818f0a11>] pcpu_alloc+0xe01/0x1280 mm/percpu.c:998
 [<ffffffff818f0eb7>] __alloc_percpu_gfp+0x27/0x30 mm/percpu.c:1062
 [<ffffffff817d25b2>] bpf_array_alloc_percpu kernel/bpf/arraymap.c:34 [inline]
 [<ffffffff817d25b2>] array_map_alloc+0x532/0x710 kernel/bpf/arraymap.c:99
 [<ffffffff817ba034>] find_and_alloc_map kernel/bpf/syscall.c:34 [inline]
 [<ffffffff817ba034>] map_create kernel/bpf/syscall.c:188 [inline]
 [<ffffffff817ba034>] SYSC_bpf kernel/bpf/syscall.c:870 [inline]
 [<ffffffff817ba034>] SyS_bpf+0xd64/0x2500 kernel/bpf/syscall.c:827
 [<ffffffff84377941>] entry_SYSCALL_64_fastpath+0x1f/0xc2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
