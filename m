Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id 433C96B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 11:55:52 -0400 (EDT)
Received: by mail-yh0-f54.google.com with SMTP id i57so1835858yha.41
        for <linux-mm@kvack.org>; Wed, 14 May 2014 08:55:51 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id o67si2789026yhb.88.2014.05.14.08.55.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 14 May 2014 08:55:51 -0700 (PDT)
Message-ID: <53739201.6080604@oracle.com>
Date: Wed, 14 May 2014 11:55:45 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: mm: NULL ptr deref handling mmaping of special mappings
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>

Hi all,

While fuzzing with trinity inside a KVM tools guest running the latest -next
kernel I've stumbled on the following spew:

[ 1634.969408] BUG: unable to handle kernel NULL pointer dereference at           (null)
[ 1634.970538] IP: special_mapping_fault (mm/mmap.c:2961)
[ 1634.971420] PGD 3334fc067 PUD 3334cf067 PMD 0
[ 1634.972081] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[ 1634.972913] Dumping ftrace buffer:
[ 1634.975493]    (ftrace buffer empty)
[ 1634.977470] Modules linked in:
[ 1634.977513] CPU: 6 PID: 29578 Comm: trinity-c269 Not tainted 3.15.0-rc5-next-20140513-sasha-00020-gebce144-dirty #461
[ 1634.977513] task: ffff880333158000 ti: ffff88033351e000 task.ti: ffff88033351e000
[ 1634.977513] RIP: special_mapping_fault (mm/mmap.c:2961)
[ 1634.977513] RSP: 0018:ffff88033351faf8  EFLAGS: 00010202
[ 1634.977513] RAX: 0000000000000000 RBX: ffff88033351fbb0 RCX: 0000000000000028
[ 1634.977513] RDX: 0000000000000001 RSI: ffff88033351fb38 RDI: ffff88006d28b600
[ 1634.977513] RBP: ffff88033351fb18 R08: ffff88033351fbb0 R09: 0000000000000000
[ 1634.977513] R10: ffff88001bcca690 R11: 0000000000000000 R12: ffff88001bcca690
[ 1634.977513] R13: ffff880000000748 R14: 0000000000000028 R15: ffff88006d28b600
[ 1634.977513] FS:  00007f79da4b8700(0000) GS:ffff8801b4c00000(0000) knlGS:0000000000000000
[ 1634.977513] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1634.977513] CR2: 0000000000000000 CR3: 00000003334fb000 CR4: 00000000000006a0
[ 1634.977513] Stack:
[ 1634.977513]  ffff88033351fb08 00000000000005d1 00000000000005d1 ffff88033351fbb0
[ 1634.977513]  ffff88033351fb78 ffffffffac2b83a9 ffff88033351fc28 ffffffffac1cb679
[ 1634.977513]  0000000000000028 00000007f79da4e9 00007f79da4e9000 0000000000000000
[ 1634.977513] Call Trace:
[ 1634.977513] __do_fault (mm/memory.c:2703)
[ 1634.977513] ? __lock_acquire (kernel/locking/lockdep.c:3189)
[ 1634.977513] do_read_fault.isra.40 (mm/memory.c:2883)
[ 1634.977513] ? get_parent_ip (kernel/sched/core.c:2519)
[ 1634.977513] ? get_parent_ip (kernel/sched/core.c:2519)
[ 1634.977513] ? __mem_cgroup_count_vm_event (include/linux/rcupdate.h:391 include/linux/rcupdate.h:893 mm/memcontrol.c:1302)
[ 1634.977513] ? get_parent_ip (kernel/sched/core.c:2519)
[ 1634.977513] __handle_mm_fault (mm/memory.c:3021 mm/memory.c:3182 mm/memory.c:3306)
[ 1634.977513] ? __const_udelay (arch/x86/lib/delay.c:126)
[ 1634.977513] ? __rcu_read_unlock (kernel/rcu/update.c:97)
[ 1634.977513] handle_mm_fault (mm/memory.c:3329)
[ 1634.977513] __do_page_fault (arch/x86/mm/fault.c:1224)
[ 1634.977513] ? kvm_clock_read (arch/x86/include/asm/preempt.h:90 arch/x86/kernel/kvmclock.c:86)
[ 1634.977513] ? sched_clock (arch/x86/include/asm/paravirt.h:192 arch/x86/kernel/tsc.c:305)
[ 1634.977513] ? sched_clock_local (kernel/sched/clock.c:214)
[ 1634.977513] ? get_parent_ip (kernel/sched/core.c:2519)
[ 1634.977513] ? context_tracking_user_exit (kernel/context_tracking.c:182)
[ 1634.977513] ? __this_cpu_preempt_check (lib/smp_processor_id.c:63)
[ 1634.977513] ? trace_hardirqs_off_caller (kernel/locking/lockdep.c:2638 (discriminator 2))
[ 1634.977513] do_page_fault (arch/x86/mm/fault.c:1277 include/linux/jump_label.h:105 include/linux/context_tracking_state.h:27 include/linux/context_tracking.h:45 arch/x86/mm/fault.c:1278)
[ 1634.977513] do_async_page_fault (arch/x86/kernel/kvm.c:264)
[ 1634.977513] async_page_fault (arch/x86/kernel/entry_64.S:1552)
[ 1634.977513] ? copy_user_generic_unrolled (arch/x86/lib/copy_user_64.S:153)
[ 1634.977513] ? SyS_add_key (security/keys/keyctl.c:109 security/keys/keyctl.c:62)
[ 1634.977513] tracesys (arch/x86/kernel/entry_64.S:746)
[ 1634.977513] Code: 1f 40 00 66 66 66 66 90 55 48 89 e5 53 48 83 ec 18 48 8b 56 08 48 8b 87 a8 00 00 00 48 2b 97 98 00 00 00 74 1e 66 0f 1f 44 00 00 <48> 83 38 00 74 62 48 83 c0 08 48 83 ea 01 75 f0 0f 1f 84 00 00
[ 1634.977513] RIP special_mapping_fault (mm/mmap.c:2961)
[ 1634.977513]  RSP <ffff88033351faf8>
[ 1634.977513] CR2: 0000000000000000


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
