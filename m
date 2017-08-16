Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 40F286B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 20:18:01 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m133so8915100pga.2
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 17:18:01 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id b184si6002291pgc.801.2017.08.15.17.17.59
        for <linux-mm@kvack.org>;
        Tue, 15 Aug 2017 17:17:59 -0700 (PDT)
Date: Wed, 16 Aug 2017 09:16:37 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v8 00/14] lockdep: Implement crossrelease feature
Message-ID: <20170816001637.GN20323@X58A-UD3R>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <20170815082020.fvfahxwx2zt4ps4i@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170815082020.fvfahxwx2zt4ps4i@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, peterz@infradead.org, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Tue, Aug 15, 2017 at 10:20:20AM +0200, Ingo Molnar wrote:
> 
> So with the latest fixes there's a new lockdep warning on one of my testboxes:
> 
> [   11.322487] EXT4-fs (sda2): mounted filesystem with ordered data mode. Opts: (null)
> 
> [   11.495661] ======================================================
> [   11.502093] WARNING: possible circular locking dependency detected
> [   11.508507] 4.13.0-rc5-00497-g73135c58-dirty #1 Not tainted
> [   11.514313] ------------------------------------------------------
> [   11.520725] umount/533 is trying to acquire lock:
> [   11.525657]  ((complete)&barr->done){+.+.}, at: [<ffffffff810fdbb3>] flush_work+0x213/0x2f0
> [   11.534411] 
>                but task is already holding lock:
> [   11.540661]  (lock#3){+.+.}, at: [<ffffffff8122678d>] lru_add_drain_all_cpuslocked+0x3d/0x190
> [   11.549613] 
>                which lock already depends on the new lock.
> 
> The full splat is below. The kernel config is nothing fancy - distro derived, 
> pretty close to defconfig, with lockdep enabled.

I see...

Worker A : acquired of wfc.work -> wait for cpu_hotplug_lock to be released
Task   B : acquired of cpu_hotplug_lock -> wait for lock#3 to be released
Task   C : acquired of lock#3 -> wait for completion of barr->done
Worker D : wait for wfc.work to be released -> will complete barr->done

The report below is telling that a deadlock would happen if the four tasks
run simultaniously. Here, I wonder if wfc.work sould be acquired with a
write version. I am not familiar with workqueue. Could anyone explain it
for me?

Thank you,
Byungchul

> Thanks,
> 
> 	Ingo
> 
> [   11.322487] EXT4-fs (sda2): mounted filesystem with ordered data mode. Opts: (null)
> 
> [   11.495661] ======================================================
> [   11.502093] WARNING: possible circular locking dependency detected
> [   11.508507] 4.13.0-rc5-00497-g73135c58-dirty #1 Not tainted
> [   11.514313] ------------------------------------------------------
> [   11.520725] umount/533 is trying to acquire lock:
> [   11.525657]  ((complete)&barr->done){+.+.}, at: [<ffffffff810fdbb3>] flush_work+0x213/0x2f0
> [   11.534411] 
>                but task is already holding lock:
> [   11.540661]  (lock#3){+.+.}, at: [<ffffffff8122678d>] lru_add_drain_all_cpuslocked+0x3d/0x190
> [   11.549613] 
>                which lock already depends on the new lock.
> 
> [   11.558349] 
>                the existing dependency chain (in reverse order) is:
> [   11.566229] 
>                -> #3 (lock#3){+.+.}:
> [   11.571439]        lock_acquire+0xe7/0x1d0
> [   11.575765]        __mutex_lock+0x75/0x8e0
> [   11.580086]        lru_add_drain_all_cpuslocked+0x3d/0x190
> [   11.585797]        lru_add_drain_all+0xf/0x20
> [   11.590402]        invalidate_bdev+0x3e/0x60
> [   11.594901]        ext4_put_super+0x1f9/0x3d0
> [   11.599485]        generic_shutdown_super+0x64/0x110
> [   11.604685]        kill_block_super+0x21/0x50
> [   11.609270]        deactivate_locked_super+0x39/0x70
> [   11.614462]        cleanup_mnt+0x3b/0x70
> [   11.618612]        task_work_run+0x72/0x90
> [   11.622955]        exit_to_usermode_loop+0x93/0xa0
> [   11.627971]        do_syscall_64+0x1a2/0x1c0
> [   11.632470]        return_from_SYSCALL_64+0x0/0x7a
> [   11.637487] 
>                -> #2 (cpu_hotplug_lock.rw_sem){++++}:
> [   11.644144]        lock_acquire+0xe7/0x1d0
> [   11.648487]        cpus_read_lock+0x2b/0x60
> [   11.652897]        apply_workqueue_attrs+0x12/0x50
> [   11.657917]        __alloc_workqueue_key+0x2f2/0x510
> [   11.663110]        scsi_host_alloc+0x353/0x470
> [   11.667780]        _scsih_probe+0x5bb/0x7b0
> [   11.672192]        local_pci_probe+0x3f/0x90
> [   11.676714]        work_for_cpu_fn+0x10/0x20
> [   11.681213]        process_one_work+0x1fc/0x670
> [   11.685971]        worker_thread+0x219/0x3e0
> [   11.690469]        kthread+0x13a/0x170
> [   11.694465]        ret_from_fork+0x27/0x40
> [   11.698790] 
>                -> #1 ((&wfc.work)){+.+.}:
> [   11.704433]        worker_thread+0x219/0x3e0
> [   11.708930]        kthread+0x13a/0x170
> [   11.712908]        ret_from_fork+0x27/0x40
> [   11.717234]        0xffffffffffffffff
> [   11.721142] 
>                -> #0 ((complete)&barr->done){+.+.}:
> [   11.727633]        __lock_acquire+0x1433/0x14a0
> [   11.732392]        lock_acquire+0xe7/0x1d0
> [   11.736715]        wait_for_completion+0x4e/0x170
> [   11.741664]        flush_work+0x213/0x2f0
> [   11.745919]        lru_add_drain_all_cpuslocked+0x149/0x190
> [   11.751718]        lru_add_drain_all+0xf/0x20
> [   11.756303]        invalidate_bdev+0x3e/0x60
> [   11.760819]        ext4_put_super+0x1f9/0x3d0
> [   11.765403]        generic_shutdown_super+0x64/0x110
> [   11.770596]        kill_block_super+0x21/0x50
> [   11.775181]        deactivate_locked_super+0x39/0x70
> [   11.780372]        cleanup_mnt+0x3b/0x70
> [   11.784522]        task_work_run+0x72/0x90
> [   11.788848]        exit_to_usermode_loop+0x93/0xa0
> [   11.793875]        do_syscall_64+0x1a2/0x1c0
> [   11.798399]        return_from_SYSCALL_64+0x0/0x7a
> [   11.803416] 
>                other info that might help us debug this:
> 
> [   11.811997] Chain exists of:
>                  (complete)&barr->done --> cpu_hotplug_lock.rw_sem --> lock#3
> 
> [   11.823810]  Possible unsafe locking scenario:
> 
> [   11.830120]        CPU0                    CPU1
> [   11.834878]        ----                    ----
> [   11.839636]   lock(lock#3);
> [   11.842653]                                lock(cpu_hotplug_lock.rw_sem);
> [   11.849697]                                lock(lock#3);
> [   11.855236]   lock((complete)&barr->done);
> [   11.859560] 
>                 *** DEADLOCK ***
> 
> [   11.866054] 3 locks held by umount/533:
> [   11.870117]  #0:  (&type->s_umount_key#24){+.+.}, at: [<ffffffff8129b7ad>] deactivate_super+0x4d/0x60
> [   11.879737]  #1:  (cpu_hotplug_lock.rw_sem){++++}, at: [<ffffffff812268ea>] lru_add_drain_all+0xa/0x20
> [   11.889445]  #2:  (lock#3){+.+.}, at: [<ffffffff8122678d>] lru_add_drain_all_cpuslocked+0x3d/0x190
> [   11.898805] 
>                stack backtrace:
> [   11.903573] CPU: 12 PID: 533 Comm: umount Not tainted 4.13.0-rc5-00497-g73135c58-dirty #1
> [   11.912169] Hardware name: Supermicro H8DG6/H8DGi/H8DG6/H8DGi, BIOS 2.0b       03/01/2012
> [   11.920759] Call Trace:
> [   11.923433]  dump_stack+0x5e/0x8e
> [   11.926975]  print_circular_bug+0x204/0x310
> [   11.931385]  ? add_lock_to_list.isra.29+0xb0/0xb0
> [   11.936316]  check_prev_add+0x444/0x860
> [   11.940382]  ? generic_shutdown_super+0x64/0x110
> [   11.945237]  ? add_lock_to_list.isra.29+0xb0/0xb0
> [   11.950168]  ? __lock_acquire+0x1433/0x14a0
> [   11.954578]  __lock_acquire+0x1433/0x14a0
> [   11.958818]  lock_acquire+0xe7/0x1d0
> [   11.962621]  ? flush_work+0x213/0x2f0
> [   11.966506]  wait_for_completion+0x4e/0x170
> [   11.970915]  ? flush_work+0x213/0x2f0
> [   11.974807]  ? flush_work+0x1e6/0x2f0
> [   11.978699]  flush_work+0x213/0x2f0
> [   11.982416]  ? flush_workqueue_prep_pwqs+0x1b0/0x1b0
> [   11.987610]  ? mark_held_locks+0x66/0x90
> [   11.991778]  ? queue_work_on+0x41/0x70
> [   11.995755]  lru_add_drain_all_cpuslocked+0x149/0x190
> [   12.001034]  lru_add_drain_all+0xf/0x20
> [   12.005124]  invalidate_bdev+0x3e/0x60
> [   12.009094]  ext4_put_super+0x1f9/0x3d0
> [   12.013159]  generic_shutdown_super+0x64/0x110
> [   12.017856]  kill_block_super+0x21/0x50
> [   12.021922]  deactivate_locked_super+0x39/0x70
> [   12.026591]  cleanup_mnt+0x3b/0x70
> [   12.030242]  task_work_run+0x72/0x90
> [   12.034063]  exit_to_usermode_loop+0x93/0xa0
> [   12.038561]  do_syscall_64+0x1a2/0x1c0
> [   12.042541]  entry_SYSCALL64_slow_path+0x25/0x25
> [   12.047384] RIP: 0033:0x7fc3f2854a37
> [   12.051189] RSP: 002b:00007fff660582b8 EFLAGS: 00000246 ORIG_RAX: 00000000000000a6
> [   12.059162] RAX: 0000000000000000 RBX: 00000074471c14e0 RCX: 00007fc3f2854a37
> [   12.066530] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 00000074471c22e0
> [   12.073895] RBP: 00000074471c22e0 R08: 0000000000000000 R09: 0000000000000002
> [   12.081264] R10: 00007fff66058050 R11: 0000000000000246 R12: 00007fc3f35e6890
> [   12.088656] R13: 0000000000000000 R14: 00000074471c1660 R15: 0000000000000000
> [   12.110307] dracut: Checking ext4: /dev/sda2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
