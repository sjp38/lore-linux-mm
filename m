Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9F6C06B00AA
	for <linux-mm@kvack.org>; Mon,  5 May 2014 11:58:06 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so3059431pab.10
        for <linux-mm@kvack.org>; Mon, 05 May 2014 08:58:06 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id wg2si8959062pab.372.2014.05.05.08.58.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 05 May 2014 08:58:05 -0700 (PDT)
Message-ID: <5367B365.1070709@oracle.com>
Date: Mon, 05 May 2014 11:51:01 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: NULL ptr deref in remove_migration_pte
References: <534E9ACA.2090008@oracle.com>
In-Reply-To: <534E9ACA.2090008@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@gentwo.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

Did anyone have a chance to look at it? I still see it in -next.


Thanks,
Sasha

On 04/16/2014 10:59 AM, Sasha Levin wrote:
> Hi all,
> 
> While fuzzing with trinity inside a KVM tools guest running latest -next
> kernel I've stumbled on the following:
> 
> [ 2552.313602] BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
> [ 2552.315878] IP: __lock_acquire (kernel/locking/lockdep.c:3070 (discriminator 1))
> [ 2552.315878] PGD 465836067 PUD 465837067 PMD 0
> [ 2552.315878] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [ 2552.315878] Dumping ftrace buffer:
> [ 2552.315878]    (ftrace buffer empty)
> [ 2552.315878] Modules linked in:
> [ 2552.315878] CPU: 6 PID: 16173 Comm: trinity-c364 Tainted: G        W     3.15.0-rc1-next-20140415-sasha-00020-gaa90d09 #398
> [ 2552.315878] task: ffff88046548b000 ti: ffff88044e532000 task.ti: ffff88044e532000
> [ 2552.320286] RIP: __lock_acquire (kernel/locking/lockdep.c:3070 (discriminator 1))
> [ 2552.320286] RSP: 0018:ffff88044e5339c8  EFLAGS: 00010002
> [ 2552.320286] RAX: 0000000000000082 RBX: ffff88046548b000 RCX: 0000000000000000
> [ 2552.320286] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000018
> [ 2552.320286] RBP: ffff88044e533ab8 R08: 0000000000000001 R09: 0000000000000000
> [ 2552.320286] R10: ffff88046548b000 R11: 0000000000000001 R12: 0000000000000000
> [ 2552.320286] R13: 0000000000000018 R14: 0000000000000000 R15: 0000000000000000
> [ 2552.320286] FS:  00007fd286a9a700(0000) GS:ffff88018b000000(0000) knlGS:0000000000000000
> [ 2552.320286] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 2552.320286] CR2: 0000000000000018 CR3: 0000000442c17000 CR4: 00000000000006a0
> [ 2552.320286] DR0: 0000000000695000 DR1: 0000000000000000 DR2: 0000000000000000
> [ 2552.320286] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
> [ 2552.320286] Stack:
> [ 2552.320286]  ffff88044e5339e8 ffffffff9f56e761 0000000000000000 ffff880315c13000
> [ 2552.320286]  ffff88044e533a38 ffffffff9c193f0d ffffffff9c193e34 ffff8804654e8000
> [ 2552.320286]  ffff8804654e8000 0000000000000001 ffff88046548b000 0000000000000007
> [ 2552.320286] Call Trace:
> [ 2552.320286] ? _raw_spin_unlock_irq (arch/x86/include/asm/preempt.h:98 include/linux/spinlock_api_smp.h:169 kernel/locking/spinlock.c:199)
> [ 2552.320286] ? finish_task_switch (include/linux/tick.h:206 kernel/sched/core.c:2163)
> [ 2552.320286] ? finish_task_switch (arch/x86/include/asm/current.h:14 kernel/sched/sched.h:993 kernel/sched/core.c:2145)
> [ 2552.320286] ? retint_restore_args (arch/x86/kernel/entry_64.S:1040)
> [ 2552.320286] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
> [ 2552.320286] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2557 kernel/locking/lockdep.c:2599)
> [ 2552.320286] lock_acquire (arch/x86/include/asm/current.h:14 kernel/locking/lockdep.c:3602)
> [ 2552.320286] ? remove_migration_pte (mm/migrate.c:137)
> [ 2552.320286] ? retint_restore_args (arch/x86/kernel/entry_64.S:1040)
> [ 2552.320286] _raw_spin_lock (include/linux/spinlock_api_smp.h:143 kernel/locking/spinlock.c:151)
> [ 2552.320286] ? remove_migration_pte (mm/migrate.c:137)
> [ 2552.320286] remove_migration_pte (mm/migrate.c:137)
> [ 2552.320286] rmap_walk (mm/rmap.c:1628 mm/rmap.c:1699)
> [ 2552.320286] remove_migration_ptes (mm/migrate.c:224)
> [ 2552.320286] ? new_page_node (mm/migrate.c:107)
> [ 2552.320286] ? remove_migration_pte (mm/migrate.c:195)
> [ 2552.320286] migrate_pages (mm/migrate.c:922 mm/migrate.c:960 mm/migrate.c:1126)
> [ 2552.320286] ? perf_trace_mm_numa_migrate_ratelimit (mm/migrate.c:1574)
> [ 2552.320286] migrate_misplaced_page (mm/migrate.c:1733)
> [ 2552.320286] __handle_mm_fault (mm/memory.c:3762 mm/memory.c:3812 mm/memory.c:3925)
> [ 2552.320286] ? __const_udelay (arch/x86/lib/delay.c:126)
> [ 2552.320286] ? __rcu_read_unlock (kernel/rcu/update.c:97)
> [ 2552.320286] handle_mm_fault (mm/memory.c:3948)
> [ 2552.320286] __get_user_pages (mm/memory.c:1851)
> [ 2552.320286] ? preempt_count_sub (kernel/sched/core.c:2527)
> [ 2552.320286] __mlock_vma_pages_range (mm/mlock.c:255)
> [ 2552.320286] __mm_populate (mm/mlock.c:711)
> [ 2552.320286] SyS_mlockall (include/linux/mm.h:1799 mm/mlock.c:817 mm/mlock.c:791)
> [ 2552.320286] tracesys (arch/x86/kernel/entry_64.S:749)
> [ 2552.320286] Code: 85 2d 1e 00 00 48 c7 c1 d7 68 6c a0 48 c7 c2 47 11 6c a0 31 c0 be fa 0b 00 00 48 c7 c7 91 68 6c a0 e8 1c 6d f9 ff e9 07 1e 00 00 <49> 81 7d 00 80 31 76 a2 b8 00 00 00 00 44 0f 44 c0 eb 07 0f 1f
> [ 2552.320286] RIP __lock_acquire (kernel/locking/lockdep.c:3070 (discriminator 1))
> [ 2552.320286]  RSP <ffff88044e5339c8>
> [ 2552.320286] CR2: 0000000000000018
> 
> 
> Thanks,
> Sasha
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
