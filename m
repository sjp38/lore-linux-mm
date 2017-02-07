Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id F37266B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 03:43:06 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id o16so2358189wra.2
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 00:43:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p94si4171003wrc.161.2017.02.07.00.43.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 00:43:05 -0800 (PST)
Date: Tue, 7 Feb 2017 09:43:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Message-ID: <20170207084302.GA5810@dhcp22.suse.cz>
References: <CACT4Y+asbKDni4RBavNf0-HwApTXjbbNko9eQbU6zCOgB2Yvnw@mail.gmail.com>
 <c7658ace-23ae-227a-2ea9-7e6bd1c8c761@suse.cz>
 <CACT4Y+ZT+_L3deDUcmBkr_Pr3KdCdLv6ON=2QHbK5YnBxJfLDg@mail.gmail.com>
 <CACT4Y+Z-juavN8s+5sc-PB0rbqy4zmsRpc6qZBg3C7z3topLTw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Z-juavN8s+5sc-PB0rbqy4zmsRpc6qZBg3C7z3topLTw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>

On Mon 06-02-17 20:13:35, Dmitry Vyukov wrote:
[...]
> Fuzzer now runs on 510948533b059f4f5033464f9f4a0c32d4ab0c08 of
> mmotm/auto-latest
> (git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git):
> 
> commit 510948533b059f4f5033464f9f4a0c32d4ab0c08
> Date:   Thu Feb 2 10:08:47 2017 +0100
>     mmotm: userfaultfd-non-cooperative-add-event-for-memory-unmaps-fix
> 
> The commit you referenced is already there:
> 
> commit 806b158031ca0b4714e775898396529a758ebc2c
> Date:   Thu Feb 2 08:53:16 2017 +0100
>     mm, page_alloc: use static global work_struct for draining per-cpu pages
> 
> But I still got:
> 
> [ INFO: possible circular locking dependency detected ]
> 4.9.0 #6 Not tainted
> -------------------------------------------------------
> syz-executor1/8199 is trying to acquire lock:
>  (cpu_hotplug.dep_map){++++++}, at: [<ffffffff81422fe7>] get_online_cpus+0x37/0x90 kernel/cpu.c:246
> but task is already holding lock:
>  (pcpu_alloc_mutex){+.+.+.}, at: [<ffffffff818f07ea>] pcpu_alloc+0xbda/0x1280 mm/percpu.c:896
> which lock already depends on the new lock.
> 

the original was too hard to read so here is the reformated output.

> the existing dependency chain (in reverse order) is:
> 
> [  403.953319] [<ffffffff8156fc29>] validate_chain kernel/locking/lockdep.c:2265 [inline]
> [  403.953319] [<ffffffff8156fc29>] __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
> [  403.961232] [<ffffffff81571db1>] lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
> [  403.968788] [<ffffffff8436697e>] __mutex_lock_common kernel/locking/mutex.c:521 [inline]
> [  403.968788] [<ffffffff8436697e>] mutex_lock_nested+0x24e/0xff0 kernel/locking/mutex.c:621
> [  403.976782] [<ffffffff818f07ea>] pcpu_alloc+0xbda/0x1280 mm/percpu.c:896
> [  403.984266] [<ffffffff818f0ee4>] __alloc_percpu+0x24/0x30 mm/percpu.c:1075
> [  403.991873] [<ffffffff816543e3>] smpcfd_prepare_cpu+0x73/0xd0 kernel/smp.c:44
> [  403.999799] [<ffffffff814240b4>] cpuhp_invoke_callback+0x254/0x1480 kernel/cpu.c:136
> [  404.008253] [<ffffffff81425821>] cpuhp_up_callbacks+0x81/0x2a0 kernel/cpu.c:493
> [  404.016365] [<ffffffff81427bf3>] _cpu_up+0x1e3/0x2a0 kernel/cpu.c:1057
> [  404.023507] [<ffffffff81427d23>] do_cpu_up+0x73/0xa0 kernel/cpu.c:1087
> [  404.030647] [<ffffffff81427d68>] cpu_up+0x18/0x20 kernel/cpu.c:1095
> [  404.037523] [<ffffffff854ede84>] smp_init+0xe9/0xee kernel/smp.c:564
> [  404.044559] [<ffffffff85482f81>] kernel_init_freeable+0x439/0x690 init/main.c:1010
> [  404.052811] [<ffffffff84357083>] kernel_init+0x13/0x180 init/main.c:941
> [  404.060198] [<ffffffff84377baa>] ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:433

cpu_hotplug_begin
  cpu_hotplug.lock
pcpu_alloc
  pcpu_alloc_mutex

> [  404.072827] [<ffffffff8156fc29>] validate_chain kernel/locking/lockdep.c:2265 [inline]
> [  404.072827] [<ffffffff8156fc29>] __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
> [  404.080733] [<ffffffff81571db1>] lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
> [  404.088311] [<ffffffff8436697e>] __mutex_lock_common kernel/locking/mutex.c:521 [inline]
> [  404.088311] [<ffffffff8436697e>] mutex_lock_nested+0x24e/0xff0 kernel/locking/mutex.c:621
> [  404.096318] [<ffffffff81427876>] cpu_hotplug_begin+0x206/0x2e0 kernel/cpu.c:304
> [  404.104321] [<ffffffff81427ada>] _cpu_up+0xca/0x2a0 kernel/cpu.c:1011
> [  404.111357] [<ffffffff81427d23>] do_cpu_up+0x73/0xa0 kernel/cpu.c:1087
> [  404.118480] [<ffffffff81427d68>] cpu_up+0x18/0x20 kernel/cpu.c:1095
> [  404.125360] [<ffffffff854ede84>] smp_init+0xe9/0xee kernel/smp.c:564
> [  404.132393] [<ffffffff85482f81>] kernel_init_freeable+0x439/0x690 init/main.c:1010
> [  404.140668] [<ffffffff84357083>] kernel_init+0x13/0x180 init/main.c:941
> [  404.148079] [<ffffffff84377baa>] ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:433

cpu_hotplug_begin
  cpu_hotplug.lock
 
> [  404.160977] [<ffffffff8156976d>] check_prev_add kernel/locking/lockdep.c:1828 [inline]
> [  404.160977] [<ffffffff8156976d>] check_prevs_add+0xa8d/0x1c00 kernel/locking/lockdep.c:1938
> [  404.168898] [<ffffffff8156fc29>] validate_chain kernel/locking/lockdep.c:2265 [inline]
> [  404.168898] [<ffffffff8156fc29>] __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
> [  404.176844] [<ffffffff81571db1>] lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
> [  404.184416] [<ffffffff81423012>] get_online_cpus+0x62/0x90 kernel/cpu.c:248
> [  404.192103] [<ffffffff8185fcf8>] drain_all_pages+0xf8/0x710 mm/page_alloc.c:2385
> [  404.199880] [<ffffffff81865e5d>] __alloc_pages_direct_reclaim mm/page_alloc.c:3440 [inline]
> [  404.199880] [<ffffffff81865e5d>] __alloc_pages_slowpath+0x8fd/0x2370 mm/page_alloc.c:3778
> [  404.208406] [<ffffffff818681c5>] __alloc_pages_nodemask+0x8f5/0xc60 mm/page_alloc.c:3980
> [  404.216851] [<ffffffff818ed0c1>] __alloc_pages include/linux/gfp.h:426 [inline]
> [  404.216851] [<ffffffff818ed0c1>] __alloc_pages_node include/linux/gfp.h:439 [inline]
> [  404.216851] [<ffffffff818ed0c1>] alloc_pages_node include/linux/gfp.h:453 [inline]
> [  404.216851] [<ffffffff818ed0c1>] pcpu_alloc_pages mm/percpu-vm.c:93 [inline]
> [  404.216851] [<ffffffff818ed0c1>] pcpu_populate_chunk+0x1e1/0x900 mm/percpu-vm.c:282
> [  404.225015] [<ffffffff818f0a11>] pcpu_alloc+0xe01/0x1280 mm/percpu.c:998
> [  404.232482] [<ffffffff818f0eb7>] __alloc_percpu_gfp+0x27/0x30 mm/percpu.c:1062
> [  404.240389] [<ffffffff817d25b2>] bpf_array_alloc_percpu kernel/bpf/arraymap.c:34 [inline]
> [  404.240389] [<ffffffff817d25b2>] array_map_alloc+0x532/0x710 kernel/bpf/arraymap.c:99
> [  404.248224] [<ffffffff817ba034>] find_and_alloc_map kernel/bpf/syscall.c:34 [inline]
> [  404.248224] [<ffffffff817ba034>] map_create kernel/bpf/syscall.c:188 [inline]
> [  404.248224] [<ffffffff817ba034>] SYSC_bpf kernel/bpf/syscall.c:870 [inline]
> [  404.248224] [<ffffffff817ba034>] SyS_bpf+0xd64/0x2500 kernel/bpf/syscall.c:827
> [  404.255434] [<ffffffff84377941>] entry_SYSCALL_64_fastpath+0x1f/0xc2

pcpu_alloc
  pcpu_alloc_mutex
drain_all_pages
  pcpu_drain_mutex
  get_online_cpus
    cpu_hotplug.lock

so the deadlock is real!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
