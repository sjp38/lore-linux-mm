Return-Path: <linux-kernel-owner@vger.kernel.org>
MIME-Version: 1.0
Date: Mon, 30 Apr 2018 11:09:02 -0700
Message-ID: <000000000000a6d200056b14bfd4@google.com>
Subject: INFO: task hung in collapse_huge_page
From: syzbot <syzbot+e65df5e4d866512cd91d@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org, gregkh@linuxfoundation.org, hannes@cmpxchg.org, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, rientjes@google.com, shli@fb.com, sj38.park@gmail.com, syzkaller-bugs@googlegroups.com, willy@infradead.org, yang.s@alibaba-inc.com
List-ID: <linux-mm.kvack.org>

Hello,

syzbot found the following crash on:

HEAD commit:    fd40ffc72e2f selinux: fix missing dput() before selinuxfs  
u...
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?id=5175701267283968
kernel config:   
https://syzkaller.appspot.com/x/.config?id=-771321277174894814
dashboard link: https://syzkaller.appspot.com/bug?extid=e65df5e4d866512cd91d
compiler:       gcc (GCC) 8.0.1 20180301 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+e65df5e4d866512cd91d@syzkaller.appspotmail.com

RAX: ffffffffffffffda RBX: 00007f3f474226d4 RCX: 0000000000455259
RDX: 0000000000000000 RSI: 00000000200001c0 RDI: 0000000000000013
RBP: 000000000072bf58 R08: 00000000200002c0 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000014
R13: 0000000000000402 R14: 00000000006f90d0 R15: 0000000000000000
INFO: task khugepaged:893 blocked for more than 120 seconds.
       Not tainted 4.16.0+ #14
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
khugepaged      D22696   893      2 0x80000000
Call Trace:
  context_switch kernel/sched/core.c:2848 [inline]
  __schedule+0x807/0x1e40 kernel/sched/core.c:3490
  schedule+0xef/0x430 kernel/sched/core.c:3549
  __rwsem_down_write_failed_common+0x919/0x15d0  
kernel/locking/rwsem-xadd.c:566
  rwsem_down_write_failed+0xe/0x10 kernel/locking/rwsem-xadd.c:595
  call_rwsem_down_write_failed+0x17/0x30 arch/x86/lib/rwsem.S:117
  __down_write arch/x86/include/asm/rwsem.h:142 [inline]
  down_write+0xa2/0x120 kernel/locking/rwsem.c:72
  collapse_huge_page+0x2cf/0x20a0 mm/khugepaged.c:1008
  khugepaged_scan_pmd mm/khugepaged.c:1217 [inline]
  khugepaged_scan_mm_slot+0x2082/0x3320 mm/khugepaged.c:1741
  khugepaged_do_scan mm/khugepaged.c:1822 [inline]
  khugepaged+0x99c/0xcc0 mm/khugepaged.c:1867
  kthread+0x345/0x410 kernel/kthread.c:238
  ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:411

Showing all locks held in the system:
2 locks held by khungtaskd/887:
  #0: 00000000da18574b (rcu_read_lock){....}, at:  
check_hung_uninterruptible_tasks kernel/hung_task.c:175 [inline]
  #0: 00000000da18574b (rcu_read_lock){....}, at: watchdog+0x1ff/0xf60  
kernel/hung_task.c:249
  #1: 00000000b2d19eff (tasklist_lock){.+.+}, at:  
debug_show_all_locks+0xde/0x34a kernel/locking/lockdep.c:4470
1 lock held by khugepaged/893:
  #0: 000000005e9ebf28 (&mm->mmap_sem){++++}, at:  
collapse_huge_page+0x2cf/0x20a0 mm/khugepaged.c:1008
2 locks held by rs:main Q:Reg/4355:
  #0: 00000000fbbe3e1f (&f->f_pos_lock){+.+.}, at: __fdget_pos+0x1a9/0x1e0  
fs/file.c:766
  #1: 0000000017101d2e (sb_writers#4){++++}, at: file_start_write  
include/linux/fs.h:2712 [inline]
  #1: 0000000017101d2e (sb_writers#4){++++}, at: vfs_write+0x452/0x560  
fs/read_write.c:548
2 locks held by getty/4447:
  #0: 00000000eef31803 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 000000008462dcad (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x321/0x1cc0 drivers/tty/n_tty.c:2131
2 locks held by getty/4448:
  #0: 0000000088b6b0e6 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 000000001ac62533 (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x321/0x1cc0 drivers/tty/n_tty.c:2131
2 locks held by getty/4449:
  #0: 00000000bb91f0f8 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 0000000057fc7078 (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x321/0x1cc0 drivers/tty/n_tty.c:2131
2 locks held by getty/4450:
  #0: 000000009dae2019 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 000000000e9ac784 (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x321/0x1cc0 drivers/tty/n_tty.c:2131
2 locks held by getty/4451:
  #0: 00000000347d58b3 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 000000004529ab2b (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x321/0x1cc0 drivers/tty/n_tty.c:2131
2 locks held by getty/4452:
  #0: 000000001f202914 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 00000000a9aa7ea8 (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x321/0x1cc0 drivers/tty/n_tty.c:2131
2 locks held by getty/4453:
  #0: 000000004b0529c9 (&tty->ldisc_sem){++++}, at:  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1: 0000000069ad55c2 (&ldata->atomic_read_lock){+.+.}, at:  
n_tty_read+0x321/0x1cc0 drivers/tty/n_tty.c:2131
2 locks held by syz-fuzzer/4473:
  #0: 000000005e9ebf28 (&mm->mmap_sem){++++}, at:  
__do_page_fault+0x381/0xe40 arch/x86/mm/fault.c:1328
  #1: 00000000259e49a0 (sb_pagefaults){++++}, at: sb_start_pagefault  
include/linux/fs.h:1579 [inline]
  #1: 00000000259e49a0 (sb_pagefaults){++++}, at:  
ext4_page_mkwrite+0x1c8/0x1420 fs/ext4/inode.c:6074
2 locks held by syz-fuzzer/4477:
  #0: 000000005e9ebf28 (&mm->mmap_sem){++++}, at:  
__do_page_fault+0x381/0xe40 arch/x86/mm/fault.c:1328
  #1: 00000000259e49a0 (sb_pagefaults){++++}, at: sb_start_pagefault  
include/linux/fs.h:1579 [inline]
  #1: 00000000259e49a0 (sb_pagefaults){++++}, at:  
ext4_page_mkwrite+0x1c8/0x1420 fs/ext4/inode.c:6074
1 lock held by syz-executor7/4525:
  #0: 0000000017101d2e (sb_writers#4){++++}, at: sb_start_write  
include/linux/fs.h:1550 [inline]
  #0: 0000000017101d2e (sb_writers#4){++++}, at: mnt_want_write+0x3f/0xc0  
fs/namespace.c:386
1 lock held by syz-executor3/4526:
  #0: 0000000017101d2e (sb_writers#4){++++}, at: sb_start_write  
include/linux/fs.h:1550 [inline]
  #0: 0000000017101d2e (sb_writers#4){++++}, at: mnt_want_write+0x3f/0xc0  
fs/namespace.c:386
1 lock held by syz-executor1/4528:
  #0: 0000000017101d2e (sb_writers#4){++++}, at: sb_start_write  
include/linux/fs.h:1550 [inline]
  #0: 0000000017101d2e (sb_writers#4){++++}, at: mnt_want_write+0x3f/0xc0  
fs/namespace.c:386
1 lock held by syz-executor6/4529:
  #0: 0000000017101d2e (sb_writers#4){++++}, at: sb_start_write  
include/linux/fs.h:1550 [inline]
  #0: 0000000017101d2e (sb_writers#4){++++}, at: mnt_want_write+0x3f/0xc0  
fs/namespace.c:386
1 lock held by syz-executor4/6088:
  #0: 0000000017101d2e (sb_writers#4){++++}, at: sb_start_write  
include/linux/fs.h:1550 [inline]
  #0: 0000000017101d2e (sb_writers#4){++++}, at: mnt_want_write+0x3f/0xc0  
fs/namespace.c:386
1 lock held by syz-executor5/9599:
  #0: 0000000017101d2e (sb_writers#4){++++}, at: file_start_write  
include/linux/fs.h:2712 [inline]
  #0: 0000000017101d2e (sb_writers#4){++++}, at: vfs_fallocate+0x5be/0x8d0  
fs/open.c:318
1 lock held by syz-executor5/9601:
  #0: 0000000017101d2e (sb_writers#4){++++}, at: sb_start_write  
include/linux/fs.h:1550 [inline]
  #0: 0000000017101d2e (sb_writers#4){++++}, at: mnt_want_write+0x3f/0xc0  
fs/namespace.c:386
1 lock held by syz-executor0/9580:
  #0: 0000000017101d2e (sb_writers#4){++++}, at: sb_start_write  
include/linux/fs.h:1550 [inline]
  #0: 0000000017101d2e (sb_writers#4){++++}, at: mnt_want_write+0x3f/0xc0  
fs/namespace.c:386
1 lock held by syz-executor2/9605:
  #0: 0000000017101d2e (sb_writers#4){++++}, at: sb_start_write  
include/linux/fs.h:1550 [inline]
  #0: 0000000017101d2e (sb_writers#4){++++}, at: mnt_want_write+0x3f/0xc0  
fs/namespace.c:386

=============================================

NMI backtrace for cpu 1
CPU: 1 PID: 887 Comm: khungtaskd Not tainted 4.16.0+ #14
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1b9/0x294 lib/dump_stack.c:113
  nmi_cpu_backtrace.cold.4+0x19/0xce lib/nmi_backtrace.c:103
  nmi_trigger_cpumask_backtrace+0x151/0x192 lib/nmi_backtrace.c:62
  arch_trigger_cpumask_backtrace+0x14/0x20 arch/x86/kernel/apic/hw_nmi.c:38
  trigger_all_cpu_backtrace include/linux/nmi.h:138 [inline]
  check_hung_task kernel/hung_task.c:132 [inline]
  check_hung_uninterruptible_tasks kernel/hung_task.c:190 [inline]
  watchdog+0xc10/0xf60 kernel/hung_task.c:249
  kthread+0x345/0x410 kernel/kthread.c:238
  ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:411
Sending NMI from CPU 1 to CPUs 0:
NMI backtrace for cpu 0
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.16.0+ #14
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:get_current arch/x86/include/asm/current.h:15 [inline]
RIP: 0010:lockdep_softirq_start kernel/softirq.c:225 [inline]
RIP: 0010:__do_softirq+0x1fc/0xaf5 kernel/softirq.c:263
RSP: 0018:ffff8801db007af0 EFLAGS: 00000046
RAX: 0000000000000007 RBX: ffffffff88a752c0 RCX: 0000000000000001
RDX: 0000000000000000 RSI: 0000000080000001 RDI: ffffffff88a75b04
RBP: ffff8801db007cc8 R08: 0000000000000000 R09: 0000000000000001
R10: ffffed003b6046c2 R11: ffff8801db023613 R12: ffff8801db02c500
R13: ffffffff88a752c0 R14: ffff8801db007e68 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff8801db000000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffffffffff600400 CR3: 00000001d9bea000 CR4: 00000000001406f0
DR0: 0000000020000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
  <IRQ>
  invoke_softirq kernel/softirq.c:365 [inline]
  irq_exit+0x1d1/0x200 kernel/softirq.c:405
  scheduler_ipi+0x52b/0xa30 kernel/sched/core.c:1778
  smp_reschedule_interrupt+0xed/0x660 arch/x86/kernel/smp.c:277
  reschedule_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:886
  </IRQ>
RIP: 0010:native_safe_halt+0x6/0x10 arch/x86/include/asm/irqflags.h:54
RSP: 0018:ffffffff88a07c38 EFLAGS: 00000282 ORIG_RAX: ffffffffffffff02
RAX: dffffc0000000000 RBX: 1ffffffff1140f8a RCX: 0000000000000000
RDX: 1ffffffff1162f80 RSI: 0000000000000001 RDI: ffffffff88b17c00
RBP: ffffffff88a07c38 R08: ffffffff88a752c0 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: ffffffff88a07cf0 R14: ffffffff88b17bf0 R15: 0000000000000000
  arch_safe_halt arch/x86/include/asm/paravirt.h:94 [inline]
  default_idle+0xc2/0x440 arch/x86/kernel/process.c:354
  arch_cpu_idle+0x10/0x20 arch/x86/kernel/process.c:345
  default_idle_call+0x6d/0x90 kernel/sched/idle.c:93
  cpuidle_idle_call kernel/sched/idle.c:151 [inline]
  do_idle+0x2f4/0x3c0 kernel/sched/idle.c:241
  cpu_startup_entry+0x104/0x120 kernel/sched/idle.c:346
  rest_init+0xe1/0xe4 init/main.c:437
  start_kernel+0x887/0x8ae init/main.c:717
  x86_64_start_reservations+0x29/0x2b arch/x86/kernel/head64.c:443
  x86_64_start_kernel+0x76/0x79 arch/x86/kernel/head64.c:424
  secondary_startup_64+0xa5/0xb0 arch/x86/kernel/head_64.S:242
Code: 89 f8 83 e0 07 83 c0 03 38 d0 7c 08 84 d2 0f 85 81 08 00 00 83 ab 44  
08 00 00 01 c6 85 37 fe ff ff 01 65 48 8b 1c 25 c0 ed 01 00 <48> 8d bb 64  
08 00 00 48 b8 00 00 00 00 00 fc ff df 48 89 fa 48


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report.
If you forgot to add the Reported-by tag, once the fix for this bug is  
merged
into any tree, please reply to this email with:
#syz fix: exact-commit-title
To mark this as a duplicate of another syzbot report, please reply with:
#syz dup: exact-subject-of-another-report
If it's a one-off invalid bug report, please reply with:
#syz invalid
Note: if the crash happens again, it will cause creation of a new bug  
report.
Note: all commands must start from beginning of the line in the email body.
