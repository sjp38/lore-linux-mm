Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 954A46B0278
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 12:22:53 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id an2so56447519wjc.3
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 09:22:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 6si13332543wrr.155.2017.01.29.09.22.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 29 Jan 2017 09:22:52 -0800 (PST)
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
References: <CACT4Y+asbKDni4RBavNf0-HwApTXjbbNko9eQbU6zCOgB2Yvnw@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c7658ace-23ae-227a-2ea9-7e6bd1c8c761@suse.cz>
Date: Sun, 29 Jan 2017 18:22:48 +0100
MIME-Version: 1.0
In-Reply-To: <CACT4Y+asbKDni4RBavNf0-HwApTXjbbNko9eQbU6zCOgB2Yvnw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Cc: syzkaller <syzkaller@googlegroups.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>

On 29.1.2017 13:44, Dmitry Vyukov wrote:
> Hello,
> 
> I've got the following deadlock report while running syzkaller fuzzer
> on f37208bc3c9c2f811460ef264909dfbc7f605a60:
> 
> [ INFO: possible circular locking dependency detected ]
> 4.10.0-rc5-next-20170125 #1 Not tainted
> -------------------------------------------------------
> syz-executor3/14255 is trying to acquire lock:
>  (cpu_hotplug.dep_map){++++++}, at: [<ffffffff814271c7>]
> get_online_cpus+0x37/0x90 kernel/cpu.c:239
> 
> but task is already holding lock:
>  (pcpu_alloc_mutex){+.+.+.}, at: [<ffffffff81937fee>]
> pcpu_alloc+0xbfe/0x1290 mm/percpu.c:897
> 
> which lock already depends on the new lock.

I suspect the dependency comes from recent changes in drain_all_pages(). They
were later redone (for other reasons, but nice to have another validation) in
the mmots patch [1], which AFAICS is not yet in mmotm and thus linux-next. Could
you try if it helps?

Vlastimil


[1]
http://ozlabs.org/~akpm/mmots/broken-out/mm-page_alloc-use-static-global-work_struct-for-draining-per-cpu-pages.patch

> 
> the existing dependency chain (in reverse order) is:
> 
> -> #2 (pcpu_alloc_mutex){+.+.+.}:
> 
> [<ffffffff8157a169>] validate_chain kernel/locking/lockdep.c:2265 [inline]
> [<ffffffff8157a169>] __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
> [<ffffffff8157c2f1>] lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
> [<ffffffff8447fb62>] __mutex_lock_common kernel/locking/mutex.c:757 [inline]
> [<ffffffff8447fb62>] __mutex_lock+0x382/0x25c0 kernel/locking/mutex.c:894
> [<ffffffff84481db6>] mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:909
> [<ffffffff81937fee>] pcpu_alloc+0xbfe/0x1290 mm/percpu.c:897
> [<ffffffff819386d4>] __alloc_percpu+0x24/0x30 mm/percpu.c:1076
> [<ffffffff81684963>] smpcfd_prepare_cpu+0x73/0xd0 kernel/smp.c:47
> [<ffffffff81428296>] cpuhp_invoke_callback+0x256/0x1480 kernel/cpu.c:136
> [<ffffffff81429a11>] cpuhp_up_callbacks+0x81/0x2a0 kernel/cpu.c:425
> [<ffffffff8142bd53>] _cpu_up+0x1e3/0x2a0 kernel/cpu.c:940
> [<ffffffff8142be83>] do_cpu_up+0x73/0xa0 kernel/cpu.c:970
> [<ffffffff8142bec8>] cpu_up+0x18/0x20 kernel/cpu.c:978
> [<ffffffff8570eec9>] smp_init+0x148/0x160 kernel/smp.c:565
> [<ffffffff856a2fef>] kernel_init_freeable+0x43e/0x695 init/main.c:1026
> [<ffffffff8446ccf3>] kernel_init+0x13/0x180 init/main.c:955
> [<ffffffff8448f0b1>] ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430
> 
> -> #1 (cpu_hotplug.lock){+.+.+.}:
> 
> [<ffffffff8157a169>] validate_chain kernel/locking/lockdep.c:2265 [inline]
> [<ffffffff8157a169>] __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
> [<ffffffff8157c2f1>] lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
> [<ffffffff8447fb62>] __mutex_lock_common kernel/locking/mutex.c:757 [inline]
> [<ffffffff8447fb62>] __mutex_lock+0x382/0x25c0 kernel/locking/mutex.c:894
> [<ffffffff84481db6>] mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:909
> [<ffffffff8142b9d6>] cpu_hotplug_begin+0x206/0x2e0 kernel/cpu.c:297
> [<ffffffff8142bc3a>] _cpu_up+0xca/0x2a0 kernel/cpu.c:894
> [<ffffffff8142be83>] do_cpu_up+0x73/0xa0 kernel/cpu.c:970
> [<ffffffff8142bec8>] cpu_up+0x18/0x20 kernel/cpu.c:978
> [<ffffffff8570eec9>] smp_init+0x148/0x160 kernel/smp.c:565
> [<ffffffff856a2fef>] kernel_init_freeable+0x43e/0x695 init/main.c:1026
> [<ffffffff8446ccf3>] kernel_init+0x13/0x180 init/main.c:955
> [<ffffffff8448f0b1>] ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430
> 
> -> #0 (cpu_hotplug.dep_map){++++++}:
> 
> [<ffffffff81573ebf>] check_prev_add kernel/locking/lockdep.c:1828 [inline]
> [<ffffffff81573ebf>] check_prevs_add+0xa8f/0x19f0 kernel/locking/lockdep.c:1938
> [<ffffffff8157a169>] validate_chain kernel/locking/lockdep.c:2265 [inline]
> [<ffffffff8157a169>] __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
> [<ffffffff8157c2f1>] lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
> [<ffffffff814271f2>] get_online_cpus+0x62/0x90 kernel/cpu.c:241
> [<ffffffff818991ec>] drain_all_pages.part.98+0x8c/0x8f0 mm/page_alloc.c:2371
> [<ffffffff818adac6>] drain_all_pages mm/page_alloc.c:2364 [inline]
> [<ffffffff818adac6>] __alloc_pages_direct_reclaim mm/page_alloc.c:3435 [inline]
> [<ffffffff818adac6>] __alloc_pages_slowpath+0x966/0x23d0 mm/page_alloc.c:3773
> [<ffffffff818afe25>] __alloc_pages_nodemask+0x8f5/0xc60 mm/page_alloc.c:3975
> [<ffffffff819348a1>] __alloc_pages include/linux/gfp.h:426 [inline]
> [<ffffffff819348a1>] __alloc_pages_node include/linux/gfp.h:439 [inline]
> [<ffffffff819348a1>] alloc_pages_node include/linux/gfp.h:453 [inline]
> [<ffffffff819348a1>] pcpu_alloc_pages mm/percpu-vm.c:93 [inline]
> [<ffffffff819348a1>] pcpu_populate_chunk+0x1e1/0x900 mm/percpu-vm.c:282
> [<ffffffff81938205>] pcpu_alloc+0xe15/0x1290 mm/percpu.c:999
> [<ffffffff819386a7>] __alloc_percpu_gfp+0x27/0x30 mm/percpu.c:1063
> [<ffffffff81811913>] bpf_array_alloc_percpu kernel/bpf/arraymap.c:33 [inline]
> [<ffffffff81811913>] array_map_alloc+0x543/0x700 kernel/bpf/arraymap.c:94
> [<ffffffff817f53cd>] find_and_alloc_map kernel/bpf/syscall.c:37 [inline]
> [<ffffffff817f53cd>] map_create kernel/bpf/syscall.c:228 [inline]
> [<ffffffff817f53cd>] SYSC_bpf kernel/bpf/syscall.c:1040 [inline]
> [<ffffffff817f53cd>] SyS_bpf+0x108d/0x27c0 kernel/bpf/syscall.c:997
> [<ffffffff8448ee41>] entry_SYSCALL_64_fastpath+0x1f/0xc2
> 
> other info that might help us debug this:
> 
> Chain exists of:
>   cpu_hotplug.dep_map --> cpu_hotplug.lock --> pcpu_alloc_mutex
> 
>  Possible unsafe locking scenario:
> 
>        CPU0                    CPU1
>        ----                    ----
>   lock(pcpu_alloc_mutex);
>                                lock(cpu_hotplug.lock);
>                                lock(pcpu_alloc_mutex);
>   lock(cpu_hotplug.dep_map);
> 
>  *** DEADLOCK ***
> 
> 1 lock held by syz-executor3/14255:
>  #0:  (pcpu_alloc_mutex){+.+.+.}, at: [<ffffffff81937fee>]
> pcpu_alloc+0xbfe/0x1290 mm/percpu.c:897
> 
> stack backtrace:
> CPU: 1 PID: 14255 Comm: syz-executor3 Not tainted 4.10.0-rc5-next-20170125 #1
> Hardware name: Google Google Compute Engine/Google Compute Engine,
> BIOS Google 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:15 [inline]
>  dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
>  print_circular_bug+0x307/0x3b0 kernel/locking/lockdep.c:1202
>  check_prev_add kernel/locking/lockdep.c:1828 [inline]
>  check_prevs_add+0xa8f/0x19f0 kernel/locking/lockdep.c:1938
>  validate_chain kernel/locking/lockdep.c:2265 [inline]
>  __lock_acquire+0x2149/0x3430 kernel/locking/lockdep.c:3338
>  lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
>  get_online_cpus+0x62/0x90 kernel/cpu.c:241
>  drain_all_pages.part.98+0x8c/0x8f0 mm/page_alloc.c:2371
>  drain_all_pages mm/page_alloc.c:2364 [inline]
>  __alloc_pages_direct_reclaim mm/page_alloc.c:3435 [inline]
>  __alloc_pages_slowpath+0x966/0x23d0 mm/page_alloc.c:3773
>  __alloc_pages_nodemask+0x8f5/0xc60 mm/page_alloc.c:3975
>  __alloc_pages include/linux/gfp.h:426 [inline]
>  __alloc_pages_node include/linux/gfp.h:439 [inline]
>  alloc_pages_node include/linux/gfp.h:453 [inline]
>  pcpu_alloc_pages mm/percpu-vm.c:93 [inline]
>  pcpu_populate_chunk+0x1e1/0x900 mm/percpu-vm.c:282
>  pcpu_alloc+0xe15/0x1290 mm/percpu.c:999
>  __alloc_percpu_gfp+0x27/0x30 mm/percpu.c:1063
>  bpf_array_alloc_percpu kernel/bpf/arraymap.c:33 [inline]
>  array_map_alloc+0x543/0x700 kernel/bpf/arraymap.c:94
>  find_and_alloc_map kernel/bpf/syscall.c:37 [inline]
>  map_create kernel/bpf/syscall.c:228 [inline]
>  SYSC_bpf kernel/bpf/syscall.c:1040 [inline]
>  SyS_bpf+0x108d/0x27c0 kernel/bpf/syscall.c:997
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
