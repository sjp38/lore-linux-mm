Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id E45176B0031
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 09:27:15 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so7311289pab.4
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 06:27:15 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ze10si43545475pac.23.2014.07.08.06.27.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 08 Jul 2014 06:27:14 -0700 (PDT)
Message-ID: <53BBEFA9.9020608@oracle.com>
Date: Tue, 08 Jul 2014 09:18:33 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: shmem: WARNING: CPU: 1 PID: 8994 at mm/shmem.c:594 shmem_evict_inode+0x123/0x150()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>

Hi Hugh,

This is the first time I saw the warning at mm/shmem.c:594 getting hit. Your comments on
that warning is that you saw it getting hit yourself (and changed it from a BUG_ON to WARN),
but it's still useful to know about it.

So this is my FYI report about that warning still being triggered :)

[  297.375500] WARNING: CPU: 1 PID: 8994 at mm/shmem.c:594 shmem_evict_inode+0x123/0x150()
[  297.380368] Modules linked in:
[  297.381370] CPU: 1 PID: 8994 Comm: trinity-c84 Not tainted 3.16.0-rc4-next-20140708-sasha-00022-g94c7290-dirty #770
[  297.384668]  0000000000000009 ffff880248403ae8 ffffffff8d495ea4 0000000000000000
[  297.387501]  0000000000000000 ffff880248403b28 ffffffff8a16ad4c ffff880248403b28
[  297.389813]  ffff88006d8340d0 ffff88006d8340d0 ffff88006d8340d0 ffff88006d834128
[  297.393372] Call Trace:
[  297.394791] dump_stack (lib/dump_stack.c:52)
[  297.397459] warn_slowpath_common (kernel/panic.c:431)
[  297.400225] warn_slowpath_null (kernel/panic.c:466)
[  297.402078] shmem_evict_inode (mm/shmem.c:594 (discriminator 1))
[  297.404050] evict (fs/inode.c:550)
[  297.405639] iput (fs/inode.c:1438)
[  297.407289] __dentry_kill (fs/dcache.c:292 fs/dcache.c:477)
[  297.408206] ? dput (fs/dcache.c:509 fs/dcache.c:617)
[  297.408971] dput (fs/dcache.c:521 fs/dcache.c:617)
[  297.409731] __fput (fs/file_table.c:235)
[  297.410692] ____fput (fs/file_table.c:253)
[  297.411442] task_work_run (kernel/task_work.c:125 (discriminator 1))
[  297.412242] do_exit (kernel/exit.c:756)
[  297.412997] ? put_lock_stats.isra.12 (./arch/x86/include/asm/preempt.h:98 kernel/locking/lockdep.c:254)
[  297.413933] ? _raw_spin_unlock_irq (./arch/x86/include/asm/paravirt.h:819 include/linux/spinlock_api_smp.h:168 kernel/locking/spinlock.c:199)
[  297.414878] do_group_exit (kernel/exit.c:884)
[  297.415674] get_signal_to_deliver (kernel/signal.c:2351)
[  297.416626] ? vtime_account_user (kernel/sched/cputime.c:687)
[  297.417558] do_signal (arch/x86/kernel/signal.c:698)
[  297.418372] ? vtime_account_user (kernel/sched/cputime.c:687)
[  297.419305] ? kmemleak_no_scan (mm/kmemleak.c:1102)
[  297.420258] ? is_prefetch.isra.11 (arch/x86/mm/fault.c:158)
[  297.421144] ? context_tracking_user_exit (./arch/x86/include/asm/paravirt.h:809 (discriminator 2) kernel/context_tracking.c:184 (discriminator 2))
[  297.422120] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[  297.423137] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2557 kernel/locking/lockdep.c:2599)
[  297.424139] do_notify_resume (arch/x86/kernel/signal.c:751)
[  297.424974] retint_signal (arch/x86/kernel/entry_64.S:921)


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
