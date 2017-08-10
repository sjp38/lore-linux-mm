Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0D6B46B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 05:38:23 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u199so1756329pgb.13
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 02:38:23 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id c3si4051630pld.94.2017.08.10.02.38.21
        for <linux-mm@kvack.org>;
        Thu, 10 Aug 2017 02:38:21 -0700 (PDT)
Date: Thu, 10 Aug 2017 18:37:07 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v8 00/14] lockdep: Implement crossrelease feature
Message-ID: <20170810093707.GA20323@X58A-UD3R>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <20170809155059.yd7le2szn2rcd4h2@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170809155059.yd7le2szn2rcd4h2@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Wed, Aug 09, 2017 at 05:50:59PM +0200, Peter Zijlstra wrote:
> 
> 
> Heh, look what it does...

Wait.. execuse me but.. is it a real problem?

> 
> 
> 4======================================================
> 4WARNING: possible circular locking dependency detected
> 4.13.0-rc2-00317-gadc6764a3adf-dirty #797 Tainted: G        W      
> 4------------------------------------------------------
> 4startpar/582 is trying to acquire lock:
> c (c(complete)&barr->donec){+.+.}c, at: [<ffffffff8110de4d>] flush_work+0x1fd/0x2c0
> 4
> but task is already holding lock:
> c (clockc#3c){+.+.}c, at: [<ffffffff8122e866>] lru_add_drain_all_cpuslocked+0x46/0x1a0
> 4
> which lock already depends on the new lock.
> 
> 4
> the existing dependency chain (in reverse order) is:
> 
> -> #4c (clockc#3c){+.+.}c:
>        __lock_acquire+0x10a5/0x1100
>        lock_acquire+0xea/0x1f0
>        __mutex_lock+0x6c/0x960
>        mutex_lock_nested+0x1b/0x20
>        lru_add_drain_all_cpuslocked+0x46/0x1a0
>        lru_add_drain_all+0x13/0x20
>        SyS_mlockall+0xb8/0x1c0
>        entry_SYSCALL_64_fastpath+0x23/0xc2
> 
> -> #3c (ccpu_hotplug_lock.rw_semc){++++}c:
>        __lock_acquire+0x10a5/0x1100
>        lock_acquire+0xea/0x1f0
>        cpus_read_lock+0x2a/0x90
>        kmem_cache_create+0x2a/0x1d0
>        scsi_init_sense_cache+0xa0/0xc0
>        scsi_add_host_with_dma+0x67/0x360
>        isci_pci_probe+0x873/0xc90
>        local_pci_probe+0x42/0xa0
>        work_for_cpu_fn+0x14/0x20
>        process_one_work+0x273/0x6b0
>        worker_thread+0x21b/0x3f0
>        kthread+0x147/0x180
>        ret_from_fork+0x2a/0x40
> 
> -> #2c (cscsi_sense_cache_mutexc){+.+.}c:
>        __lock_acquire+0x10a5/0x1100
>        lock_acquire+0xea/0x1f0
>        __mutex_lock+0x6c/0x960
>        mutex_lock_nested+0x1b/0x20
>        scsi_init_sense_cache+0x3d/0xc0
>        scsi_add_host_with_dma+0x67/0x360
>        isci_pci_probe+0x873/0xc90
>        local_pci_probe+0x42/0xa0
>        work_for_cpu_fn+0x14/0x20
>        process_one_work+0x273/0x6b0
>        worker_thread+0x21b/0x3f0
>        kthread+0x147/0x180
>        ret_from_fork+0x2a/0x40
> 
> -> #1c (c(&wfc.work)c){+.+.}c:
>        process_one_work+0x244/0x6b0
>        worker_thread+0x21b/0x3f0
>        kthread+0x147/0x180
>        ret_from_fork+0x2a/0x40
>        0xffffffffffffffff
> 
> -> #0c (c(complete)&barr->donec){+.+.}c:
>        check_prev_add+0x3be/0x700
>        __lock_acquire+0x10a5/0x1100
>        lock_acquire+0xea/0x1f0
>        wait_for_completion+0x3b/0x130
>        flush_work+0x1fd/0x2c0
>        lru_add_drain_all_cpuslocked+0x158/0x1a0
>        lru_add_drain_all+0x13/0x20
>        SyS_mlockall+0xb8/0x1c0
>        entry_SYSCALL_64_fastpath+0x23/0xc2
> 
> other info that might help us debug this:
> 
> Chain exists of:
>   c(complete)&barr->donec --> ccpu_hotplug_lock.rw_semc --> clockc#3c
> 
>  Possible unsafe locking scenario:
> 
>        CPU0                    CPU1
>        ----                    ----
>   lock(clockc#3c);
>                                lock(ccpu_hotplug_lock.rw_semc);
>                                lock(clockc#3c);
>   lock(c(complete)&barr->donec);
> 
>  *** DEADLOCK ***
> 
> 2 locks held by startpar/582:
>  #0: c (ccpu_hotplug_lock.rw_semc){++++}c, at: [<ffffffff8122e9ce>] lru_add_drain_all+0xe/0x20
>  #1: c (clockc#3c){+.+.}c, at: [<ffffffff8122e866>] lru_add_drain_all_cpuslocked+0x46/0x1a0
> 
> stack backtrace:
> dCPU: 23 PID: 582 Comm: startpar Tainted: G        W       4.13.0-rc2-00317-gadc6764a3adf-dirty #797
> dHardware name: Intel Corporation S2600GZ/S2600GZ, BIOS SE5C600.86B.02.02.0002.122320131210 12/23/2013
> dCall Trace:
> d dump_stack+0x86/0xcf
> d print_circular_bug+0x203/0x2f0
> d check_prev_add+0x3be/0x700
> d ? add_lock_to_list.isra.30+0xc0/0xc0
> d ? is_bpf_text_address+0x82/0xe0
> d ? unwind_get_return_address+0x1f/0x30
> d __lock_acquire+0x10a5/0x1100
> d ? __lock_acquire+0x10a5/0x1100
> d ? add_lock_to_list.isra.30+0xc0/0xc0
> d lock_acquire+0xea/0x1f0
> d ? flush_work+0x1fd/0x2c0
> d wait_for_completion+0x3b/0x130
> d ? flush_work+0x1fd/0x2c0
> d flush_work+0x1fd/0x2c0
> d ? flush_workqueue_prep_pwqs+0x1c0/0x1c0
> d ? trace_hardirqs_on+0xd/0x10
> d lru_add_drain_all_cpuslocked+0x158/0x1a0
> d lru_add_drain_all+0x13/0x20
> d SyS_mlockall+0xb8/0x1c0
> d entry_SYSCALL_64_fastpath+0x23/0xc2
> dRIP: 0033:0x7f818d2e54c7
> dRSP: 002b:00007fffcce83798 EFLAGS: 00000246c ORIG_RAX: 0000000000000097
> dRAX: ffffffffffffffda RBX: 0000000000000046 RCX: 00007f818d2e54c7
> dRDX: 0000000000000000 RSI: 00007fffcce83650 RDI: 0000000000000003
> dRBP: 000000000002c010 R08: 0000000000000000 R09: 0000000000000000
> dR10: 0000000000000008 R11: 0000000000000246 R12: 000000000002d000
> dR13: 000000000002c010 R14: 0000000000001000 R15: 00007f818d599b00

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
