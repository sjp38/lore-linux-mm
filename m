Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 70A406B0033
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 15:58:20 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id n79so10176209ion.17
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 12:58:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y200sor718717iof.12.2017.11.01.12.58.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Nov 2017 12:58:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <94eb2c19df188b1926055cf13c21@google.com>
References: <94eb2c19df188b1926055cf13c21@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 1 Nov 2017 22:57:57 +0300
Message-ID: <CACT4Y+ZDVP7mJHaOpq9N5oewE0WwCCWgrtWX08DFdBJN4sBRhQ@mail.gmail.com>
Subject: Re: BUG: soft lockup
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <bot+63583aefef5457348dcfa06b87d4fd1378b26b09@syzkaller.appspotmail.com>
Cc: aaron.lu@intel.com, Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Stephen Rothwell <sfr@canb.auug.org.au>, shli@fb.com, syzkaller-bugs@googlegroups.com, Matthew Wilcox <willy@linux.intel.com>, ying.huang@intel.com, zi.yan@cs.rutgers.edu, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>, alsa-devel@alsa-project.org

On Wed, Nov 1, 2017 at 10:54 PM, syzbot
<bot+63583aefef5457348dcfa06b87d4fd1378b26b09@syzkaller.appspotmail.com>
wrote:
> Hello,
>
> syzkaller hit the following crash on
> 1d53d908b79d7870d89063062584eead4cf83448
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> C reproducer is attached
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers
>
>
> watchdog: BUG: soft lockup - CPU#3 stuck for 210s! [syzkaller355698:2995]
> Modules linked in:
> irq event stamp: 23090
> hardirqs last  enabled at (23089): [<ffffffff8155d77c>]
> __raw_spin_lock_init+0x1c/0x100 kernel/locking/spinlock_debug.c:23
> hardirqs last disabled at (23090): [<ffffffff84d3eb58>]
> apic_timer_interrupt+0x98/0xb0 arch/x86/entry/entry_64.S:577
> softirqs last  enabled at (1838): [<ffffffff84d4496d>]
> __do_softirq+0x74d/0xbd0 kernel/softirq.c:310
> softirqs last disabled at (1825): [<ffffffff81415033>] invoke_softirq
> kernel/softirq.c:364 [inline]
> softirqs last disabled at (1825): [<ffffffff81415033>] irq_exit+0x1d3/0x210
> kernel/softirq.c:405
> CPU: 3 PID: 2995 Comm: syzkaller355698 Not tainted 4.13.0-rc7-next-20170901+
> #13
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff88006b8fc580 task.stack: ffff880069df8000
> RIP: 0010:clear_page_rep+0x7/0x10 arch/x86/lib/clear_page_64.S:19
> RSP: 0000:ffff880069dff6f8 EFLAGS: 00010246 ORIG_RAX: ffffffffffffff10
> RAX: 0000000000000000 RBX: 0000000000000057 RCX: 0000000000000178
> RDX: 0000000000000000 RSI: ffff88006b8fc580 RDI: ffff880064657440
> RBP: ffff880069dff760 R08: 0000000000029190 R09: 0000000000000000
> R10: ffffffffffffffe8 R11: 0000000000000000 R12: dffffc0000000000
> R13: ffff88006b8fc580 R14: ffff88006b8fc580 R15: ffff88006b8fc580
> FS:  0000000000f65880(0000) GS:ffff88006df00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000020c67ff1 CR3: 000000006741d000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Call Trace:
>  __do_huge_pmd_anonymous_page mm/huge_memory.c:570 [inline]
>  do_huge_pmd_anonymous_page+0x59c/0x1ba0 mm/huge_memory.c:728
>  create_huge_pmd mm/memory.c:3802 [inline]
>  __handle_mm_fault+0x1827/0x39c0 mm/memory.c:4005
>  handle_mm_fault+0x3bb/0x860 mm/memory.c:4071
>  __do_page_fault+0x4f6/0xb60 arch/x86/mm/fault.c:1445
>  do_page_fault+0xee/0x720 arch/x86/mm/fault.c:1520
>  do_async_page_fault+0x72/0xc0 arch/x86/kernel/kvm.c:266
>  async_page_fault+0x22/0x30 arch/x86/entry/entry_64.S:1069
> RIP: 0033:0x4012c8
> RSP: 002b:00007ffc12d93e10 EFLAGS: 00010286
> RAX: ffffffffffffffff RBX: ffffffffffffffff RCX: 0000000000439779
> RDX: 0000000000000000 RSI: 000000002076e000 RDI: ffffffffffffffff
> RBP: 00327265636e6575 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000286 R12: 7165732f7665642f
> R13: 646e732f7665642f R14: 0030656c69662f2e R15: 0000000000000000
> Code: 60 39 d1 fc e9 8d fd ff ff be 08 00 00 00 4c 89 ff e8 2e 39 d1 fc e9
> 1c fd ff ff 90 90 90 90 90 90 90 90 90 b9 00 02 00 00 31 c0 <f3> 48 ab c3 0f
> 1f 44 00 00 31 c0 b9 40 00 00 00 66 0f 1f 84 00
> Kernel panic - not syncing: softlockup: hung tasks
> CPU: 3 PID: 2995 Comm: syzkaller355698 Tainted: G             L
> 4.13.0-rc7-next-20170901+ #13
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  <IRQ>
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x194/0x257 lib/dump_stack.c:52
>  panic+0x1e4/0x417 kernel/panic.c:181
>  watchdog_timer_fn+0x401/0x410 kernel/watchdog.c:433
>  __run_hrtimer kernel/time/hrtimer.c:1213 [inline]
>  __hrtimer_run_queues+0x349/0xe10 kernel/time/hrtimer.c:1277
>  hrtimer_interrupt+0x1d4/0x5f0 kernel/time/hrtimer.c:1311
>  local_apic_timer_interrupt arch/x86/kernel/apic/apic.c:1021 [inline]
>  smp_apic_timer_interrupt+0x156/0x710 arch/x86/kernel/apic/apic.c:1046
>  apic_timer_interrupt+0x9d/0xb0 arch/x86/entry/entry_64.S:577
>  </IRQ>
> RIP: 0010:clear_page_rep+0x7/0x10 arch/x86/lib/clear_page_64.S:19
> RSP: 0000:ffff880069dff6f8 EFLAGS: 00010246 ORIG_RAX: ffffffffffffff10
> RAX: 0000000000000000 RBX: 0000000000000057 RCX: 0000000000000178
> RDX: 0000000000000000 RSI: ffff88006b8fc580 RDI: ffff880064657440
> RBP: ffff880069dff760 R08: 0000000000029190 R09: 0000000000000000
> R10: ffffffffffffffe8 R11: 0000000000000000 R12: dffffc0000000000
> R13: ffff88006b8fc580 R14: ffff88006b8fc580 R15: ffff88006b8fc580
>  __do_huge_pmd_anonymous_page mm/huge_memory.c:570 [inline]
>  do_huge_pmd_anonymous_page+0x59c/0x1ba0 mm/huge_memory.c:728
>  create_huge_pmd mm/memory.c:3802 [inline]
>  __handle_mm_fault+0x1827/0x39c0 mm/memory.c:4005
>  handle_mm_fault+0x3bb/0x860 mm/memory.c:4071
>  __do_page_fault+0x4f6/0xb60 arch/x86/mm/fault.c:1445
>  do_page_fault+0xee/0x720 arch/x86/mm/fault.c:1520
>  do_async_page_fault+0x72/0xc0 arch/x86/kernel/kvm.c:266
>  async_page_fault+0x22/0x30 arch/x86/entry/entry_64.S:1069
> RIP: 0033:0x4012c8
> RSP: 002b:00007ffc12d93e10 EFLAGS: 00010286
> RAX: ffffffffffffffff RBX: ffffffffffffffff RCX: 0000000000439779
> RDX: 0000000000000000 RSI: 000000002076e000 RDI: ffffffffffffffff
> RBP: 00327265636e6575 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000286 R12: 7165732f7665642f
> R13: 646e732f7665642f R14: 0030656c69662f2e R15: 0000000000000000
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Kernel Offset: disabled
> Rebooting in 86400 seconds..


Looking at the reproducer it looks more sound-related, so +alsa maintainers.
This reproducer on linux-next 36ef71cae353f88fd6e095e2aaa3e5953af1685d
(Oct 20) as well.

INFO: rcu_sched detected stalls on CPUs/tasks:
3-...0: (1 GPs behind) idle=d3e/1/4611686018427387906
softirq=4046/4046 fqs=31231
(detected by 2, t=125002 jiffies, g=2422, c=2421, q=5593)
Sending NMI from CPU 2 to CPUs 3:
NMI backtrace for cpu 3
CPU: 3 PID: 3082 Comm: a.out Not tainted 4.14.0-rc5-next-20171018 #15
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff880063ed4140 task.stack: ffff880063a98000
RIP: 0010:snd_timer_user_interrupt+0x68/0x3f0 sound/core/timer.c:1220
RSP: 0000:ffff88006cb87730 EFLAGS: 00000802
RAX: 0000000000000000 RBX: ffff8800646727c0 RCX: 0000000000000000
RDX: 1ffff1000c8ce4fd RSI: 0000000000000001 RDI: ffff8800646727e8
RBP: ffff88006cb87768 R08: 0000000000000008 R09: 00000000000022df
R10: ffff880063ed49d8 R11: ffff880063ed4140 R12: dffffc0000000000
R13: ffff88006b842410 R14: ffff880064672808 R15: 0000000000000001
FS:  0000000001def880(0000) GS:ffff88006cb80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000203a2000 CR3: 000000006b29f006 CR4: 00000000001606e0
Call Trace:
 <IRQ>
 snd_timer_interrupt+0xae5/0x1510 sound/core/timer.c:808
 snd_hrtimer_callback+0x211/0x3b0 sound/core/hrtimer.c:64
 __run_hrtimer kernel/time/hrtimer.c:1213 [inline]
 __hrtimer_run_queues+0x38f/0x1000 kernel/time/hrtimer.c:1277
 hrtimer_interrupt+0x1e2/0x650 kernel/time/hrtimer.c:1311
 local_apic_timer_interrupt arch/x86/kernel/apic/apic.c:1025 [inline]
 smp_apic_timer_interrupt+0x153/0x6d0 arch/x86/kernel/apic/apic.c:1050
 apic_timer_interrupt+0x9d/0xb0 arch/x86/entry/entry_64.S:577
 </IRQ>
RIP: 0010:clear_page_erms+0x7/0x10 arch/x86/lib/clear_page_64.S:49
RSP: 0000:ffff880063a9f680 EFLAGS: 00010246 ORIG_RAX: ffffffffffffff11
RAX: 0000000000000000 RBX: 0000000000000034 RCX: 0000000000000040
RDX: ffff880063ed4140 RSI: 0000160000000000 RDI: ffff88005bd78fc0
RBP: ffff880063a9f6d0 R08: ffff880063ed4140 R09: 0000000000000000
R10: ffffffffffffffe2 R11: 0000000000000000 R12: dffffc0000000000
R13: ffffea00016f0000 R14: 0000000000000144 R15: 000000000000005e
 __do_huge_pmd_anonymous_page mm/huge_memory.c:570 [inline]
 do_huge_pmd_anonymous_page+0x8ad/0x1e70 mm/huge_memory.c:728
 create_huge_pmd mm/memory.c:3828 [inline]
 __handle_mm_fault+0x261d/0x3eb0 mm/memory.c:4031
 handle_mm_fault+0x395/0xa10 mm/memory.c:4097
 __do_page_fault+0x63f/0xff0 arch/x86/mm/fault.c:1438
 do_page_fault+0xee/0x880 arch/x86/mm/fault.c:1514
 do_async_page_fault+0x37/0x80 arch/x86/kernel/kvm.c:273
 async_page_fault+0x22/0x30 arch/x86/entry/entry_64.S:1069
RIP: 0033:0x427449
RSP: 002b:00007ffd9a2f3568 EFLAGS: 00010202
RAX: 00000000203a2000 RBX: 00000000004002c8 RCX: 0030656c69662f2e
RDX: 0000000000000008 RSI: 000000000049813d RDI: 00000000203a2000
RBP: 00007ffd9a2f3580 R08: ffffffffffffffff R09: 0000000000000000
R10: 0000000000000032 R11: 0000000000000246 R12: 0000000000000000
R13: 00000000004068d0 R14: 0000000000406960 R15: 0000000000000000
Code: 00 00 48 8b 5b 40 4c 8d 73 48 4c 89 f7 e8 41 32 1b 01 48 8d 7b
28 48 b8 00 00 00 00 00 fc ff df 48 89 fa 48 c1 ea 03 0f b6 04 02 <84>
c0 74 08 3c 03 0f 8e ed 02 00 00 44 8b 63 28 31 ff 44 89 e6


I've sampled cpu stacks before stall message and it seems sound
interrupts happen too frequently:

Sending NMI from CPU 2 to CPUs 0-1,3:
NMI backtrace for cpu 3
CPU: 3 PID: 3082 Comm: a.out Not tainted 4.14.0-rc5-next-20171018 #15
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff880063ed4140 task.stack: ffff880063a98000
RIP: 0010:__lock_acquire+0xaa8/0x4480 kernel/locking/lockdep.c:3373
RSP: 0000:ffff88006cb87110 EFLAGS: 00000046
RAX: 0000000000000003 RBX: 0000000000000001 RCX: 0000000000000000
RDX: 0000000000000004 RSI: 0000000000000000 RDI: ffff88006b125120
RBP: ffff88006cb875e0 R08: 0000000000000001 R09: 0000000000000001
R10: 0000000000000000 R11: ffff880063ed4140 R12: 0000000000000000
R13: ffff88006b125120 R14: 0000000000000000 R15: 0000000000000001
FS:  0000000001def880(0000) GS:ffff88006cb80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000203a2000 CR3: 000000006b29f006 CR4: 00000000001606e0
Call Trace:
 <IRQ>
 lock_acquire+0x1d3/0x520 kernel/locking/lockdep.c:3991
 __raw_spin_lock include/linux/spinlock_api_smp.h:142 [inline]
 _raw_spin_lock+0x2a/0x40 kernel/locking/spinlock.c:149
 spin_lock include/linux/spinlock.h:314 [inline]
 snd_timer_user_interrupt+0x4f/0x3f0 sound/core/timer.c:1219
 snd_timer_interrupt+0xae5/0x1510 sound/core/timer.c:808
 snd_hrtimer_callback+0x211/0x3b0 sound/core/hrtimer.c:64
 __run_hrtimer kernel/time/hrtimer.c:1213 [inline]
 __hrtimer_run_queues+0x38f/0x1000 kernel/time/hrtimer.c:1277
 hrtimer_interrupt+0x1e2/0x650 kernel/time/hrtimer.c:1311
 local_apic_timer_interrupt arch/x86/kernel/apic/apic.c:1025 [inline]
 smp_apic_timer_interrupt+0x153/0x6d0 arch/x86/kernel/apic/apic.c:1050
 apic_timer_interrupt+0x9d/0xb0 arch/x86/entry/entry_64.S:577
 </IRQ>
RIP: 0010:clear_page_erms+0x7/0x10 arch/x86/lib/clear_page_64.S:49
RSP: 0000:ffff880063a9f680 EFLAGS: 00010246 ORIG_RAX: ffffffffffffff11
RAX: 0000000000000000 RBX: 0000000000000034 RCX: 0000000000000040
RDX: ffff880063ed4140 RSI: 0000160000000000 RDI: ffff88005bd78fc0
RBP: ffff880063a9f6d0 R08: ffff880063ed4140 R09: 0000000000000000
R10: ffffffffffffffe2 R11: 0000000000000000 R12: dffffc0000000000
R13: ffffea00016f0000 R14: 0000000000000144 R15: 000000000000005e
 __do_huge_pmd_anonymous_page mm/huge_memory.c:570 [inline]
 do_huge_pmd_anonymous_page+0x8ad/0x1e70 mm/huge_memory.c:728
 create_huge_pmd mm/memory.c:3828 [inline]
 __handle_mm_fault+0x261d/0x3eb0 mm/memory.c:4031
 handle_mm_fault+0x395/0xa10 mm/memory.c:4097
 __do_page_fault+0x63f/0xff0 arch/x86/mm/fault.c:1438
 do_page_fault+0xee/0x880 arch/x86/mm/fault.c:1514
 do_async_page_fault+0x37/0x80 arch/x86/kernel/kvm.c:273
 async_page_fault+0x22/0x30 arch/x86/entry/entry_64.S:1069
RIP: 0033:0x427449
RSP: 002b:00007ffd9a2f3568 EFLAGS: 00010202
RAX: 00000000203a2000 RBX: 00000000004002c8 RCX: 0030656c69662f2e
RDX: 0000000000000008 RSI: 000000000049813d RDI: 00000000203a2000
RBP: 00007ffd9a2f3580 R08: ffffffffffffffff R09: 0000000000000000
R10: 0000000000000032 R11: 0000000000000246 R12: 0000000000000000
R13: 00000000004068d0 R14: 0000000000406960 R15: 0000000000000000
Code: ff df 49 8d 7c dd 08 48 89 fa 48 c1 ea 03 80 3c 02 00 0f 85 61
35 00 00 49 8b 44 dd 08 48 85 c0 0f 85 77 f7 ff ff e9 27 f7 ff ff <48>
c7 c7 40 c4 0c 86 48 b8 00 00 00 00 00 fc ff df 48 89 fa 48
NMI backtrace for cpu 0
CPU: 0 PID: 3086 Comm: a.out Not tainted 4.14.0-rc5-next-20171018 #15
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff88006391a7c0 task.stack: ffff880062800000
RIP: 0010:__lock_is_held+0x37/0x140 kernel/locking/lockdep.c:3808
RSP: 0000:ffff880062807578 EFLAGS: 00000806
RAX: dffffc0000000000 RBX: 0000000000000286 RCX: ffffffff81a04fa8
RDX: 1ffff1000c723605 RSI: 00000000ffffffff RDI: ffffffff8613d500
RBP: ffff8800628075b8 R08: ffff88006391a7c0 R09: 0000000000000000
R10: ffffffffffffffe2 R11: 0000000000000000 R12: ffff88006391a7c0
R13: ffffffff8613d500 R14: 00000000000011e5 R15: 000000000000005d
FS:  0000000001def880(0000) GS:ffff88006ca00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000205a3fcc CR3: 000000006ae36002 CR4: 00000000001606f0
Call Trace:
 lock_is_held_type+0x118/0x210 kernel/locking/lockdep.c:4029
 lock_is_held include/linux/lockdep.h:436 [inline]
 rcu_preempt_sleep_check include/linux/rcupdate.h:301 [inline]
 ___might_sleep+0x295/0x370 kernel/sched/core.c:6012
 clear_huge_page+0x3b5/0x750 mm/memory.c:4581
 __do_huge_pmd_anonymous_page mm/huge_memory.c:570 [inline]
 do_huge_pmd_anonymous_page+0x8ad/0x1e70 mm/huge_memory.c:728
 create_huge_pmd mm/memory.c:3828 [inline]
 __handle_mm_fault+0x261d/0x3eb0 mm/memory.c:4031
 handle_mm_fault+0x395/0xa10 mm/memory.c:4097
 __do_page_fault+0x63f/0xff0 arch/x86/mm/fault.c:1438
 do_page_fault+0xee/0x880 arch/x86/mm/fault.c:1514
 do_async_page_fault+0x37/0x80 arch/x86/kernel/kvm.c:273
 async_page_fault+0x22/0x30 arch/x86/entry/entry_64.S:1069
RIP: 0033:0x401355
RSP: 002b:00007ffd9a2f3570 EFLAGS: 00010202
RAX: 00000000205a3fcc RBX: 00000000004002c8 RCX: 0000000000401620
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 00007ffd9a2f3140
RBP: 00007ffd9a2f3580 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000010 R11: 0000000000000246 R12: 0000000000000000
R13: 00000000004068d0 R14: 0000000000406960 R15: 0000000000000000
Code: 65 4c 8b 24 25 c0 64 01 00 49 8d 84 24 68 08 00 00 53 48 89 c2
48 83 ec 18 48 89 45 c8 48 c1 ea 03 48 b8 00 00 00 00 00 fc ff df <48>
89 7d d0 0f b6 04 02 89 75 c4 84 c0 74 08 3c 03 0f 8e c7 00
NMI backtrace for cpu 1
CPU: 1 PID: 3084 Comm: a.out Not tainted 4.14.0-rc5-next-20171018 #15
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff880063f44780 task.stack: ffff880063380000
RIP: 0010:clear_page_erms+0x9/0x10 arch/x86/lib/clear_page_64.S:50
RSP: 0000:ffff880063387680 EFLAGS: 00000246
RAX: 0000000000000000 RBX: 0000000000000047 RCX: 0000000000000000
RDX: ffff880063f44780 RSI: 0000160000000000 RDI: ffff88005e448000
RBP: ffff8800633876d0 R08: ffff880063f44780 R09: 0000000000000000
R10: ffffffffffffffe2 R11: 0000000000000000 R12: 0000000000000000
R13: ffffea0001790000 R14: dffffc0000000000 R15: 0000000000000000
FS:  0000000001def880(0000) GS:ffff88006ca80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020000fe0 CR3: 000000006b4ef005 CR4: 00000000001606e0
Call Trace:
 __do_huge_pmd_anonymous_page mm/huge_memory.c:570 [inline]
 do_huge_pmd_anonymous_page+0x8ad/0x1e70 mm/huge_memory.c:728
 create_huge_pmd mm/memory.c:3828 [inline]
 __handle_mm_fault+0x261d/0x3eb0 mm/memory.c:4031
 handle_mm_fault+0x395/0xa10 mm/memory.c:4097
 __do_page_fault+0x63f/0xff0 arch/x86/mm/fault.c:1438
 do_page_fault+0xee/0x880 arch/x86/mm/fault.c:1514
 do_async_page_fault+0x37/0x80 arch/x86/kernel/kvm.c:273
 async_page_fault+0x22/0x30 arch/x86/entry/entry_64.S:1069
RIP: 0033:0x4012af
RSP: 002b:00007ffd9a2f3570 EFLAGS: 00010246
RAX: 0000000020000fe0 RBX: 00000000004002c8 RCX: 0030656c69662f2e
RDX: 0000000000000000 RSI: 0000000000498145 RDI: 00000000203a2008
RBP: 00007ffd9a2f3580 R08: ffffffffffffffff R09: 0000000000000000
R10: 0000000000000032 R11: 0000000000000246 R12: 0000000000000000
R13: 00000000004068d0 R14: 0000000000406960 R15: 0000000000000000
Code: 89 47 18 48 89 47 20 48 89 47 28 48 89 47 30 48 89 47 38 48 8d
7f 40 75 d9 90 c3 0f 1f 80 00 00 00 00 b9 00 10 00 00 31 c0 f3 aa <c3>
90 90 90 90 90 90 55 48 89 e5 41 57 41 56 41 55 41 54 53 48



> ---
> This bug is generated by a dumb bot. It may contain errors.
> See https://goo.gl/tpsmEJ for details.
> Direct all questions to syzkaller@googlegroups.com.
> Please credit me with: Reported-by: syzbot <syzkaller@googlegroups.com>
>
> syzbot will keep track of this bug report.
> Once a fix for this bug is committed, please reply to this email with:
> #syz fix: exact-commit-title
> To mark this as a duplicate of another syzbot report, please reply with:
> #syz dup: exact-subject-of-another-report
> If it's a one-off invalid bug report, please reply with:
> #syz invalid
> Note: if the crash happens again, it will cause creation of a new bug
> report.
> Note: all commands must start from beginning of the line.
>
> --
> You received this message because you are subscribed to the Google Groups
> "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an
> email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit
> https://groups.google.com/d/msgid/syzkaller-bugs/94eb2c19df188b1926055cf13c21%40google.com.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
