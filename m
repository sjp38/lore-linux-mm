Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id D50B96B0010
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 10:27:04 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id n194-v6so8355516itn.0
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 07:27:04 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id 19-v6sor3564019iou.304.2018.07.30.07.27.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Jul 2018 07:27:03 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 30 Jul 2018 07:27:02 -0700
Message-ID: <0000000000004d12070572384150@google.com>
Subject: INFO: rcu detected stall in snd_seq_oss_write
From: syzbot <syzbot+9f421126464547bed3ee@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, jglisse@redhat.com, kirill.shutemov@linux.intel.com, ldufour@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, minchan@kernel.org, ross.zwisler@linux.intel.com, syzkaller-bugs@googlegroups.com, willy@infradead.org, ying.huang@intel.com

Hello,

syzbot found the following crash on:

HEAD commit:    a26fb01c2879 Merge tag 'random_for_linus_stable' of git://..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=171a2f0c400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=ffb4428fdc82f93b
dashboard link: https://syzkaller.appspot.com/bug?extid=9f421126464547bed3ee
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
userspace arch: i386

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+9f421126464547bed3ee@syzkaller.appspotmail.com

INFO: rcu_sched detected stalls on CPUs/tasks:
	(detected by 1, t=105002 jiffies, g=114619, c=114618, q=1460)
All QSes seen, last rcu_sched kthread activity 55292  
(4295532443-4295477151), jiffies_till_next_fqs=3, root ->qsmask 0x0
syz-executor3   R  running task    21928  9814   4421 0x2002000c
Call Trace:
  <IRQ>
  sched_show_task.cold.84+0x27a/0x301 kernel/sched/core.c:5324
  print_other_cpu_stall.cold.77+0x92f/0x9d2 kernel/rcu/tree.c:1441
  check_cpu_stall.isra.60+0x721/0xf70 kernel/rcu/tree.c:1559
  __rcu_pending kernel/rcu/tree.c:3244 [inline]
  rcu_pending kernel/rcu/tree.c:3291 [inline]
  rcu_check_callbacks+0x23f/0xcd0 kernel/rcu/tree.c:2646
  update_process_times+0x2d/0x70 kernel/time/timer.c:1636
  tick_sched_handle+0x9f/0x180 kernel/time/tick-sched.c:164
  tick_sched_timer+0x45/0x130 kernel/time/tick-sched.c:1274
  __run_hrtimer kernel/time/hrtimer.c:1398 [inline]
  __hrtimer_run_queues+0x3eb/0x10c0 kernel/time/hrtimer.c:1460
  hrtimer_interrupt+0x2f3/0x750 kernel/time/hrtimer.c:1518
  local_apic_timer_interrupt arch/x86/kernel/apic/apic.c:1025 [inline]
  smp_apic_timer_interrupt+0x165/0x730 arch/x86/kernel/apic/apic.c:1050
  apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:863
  </IRQ>
RIP: 0010:arch_local_irq_disable arch/x86/include/asm/paravirt.h:788  
[inline]
RIP: 0010:arch_local_irq_save arch/x86/include/asm/paravirt.h:801 [inline]
RIP: 0010:lock_release+0x13c/0xa30 kernel/locking/lockdep.c:3939
Code: 48 89 85 e8 fe ff ff 48 b8 00 00 00 00 00 fc ff df 48 89 fa 48 c1 ea  
03 80 3c 02 00 0f 85 40 07 00 00 48 83 3d 44 95 92 06 00 <0f> 84 53 06 00  
00 fa 66 0f 1f 44 00 00 65 4c 8b 3c 25 40 ee 01 00
RSP: 0018:ffff88019c8ff7f0 EFLAGS: 00000286 ORIG_RAX: ffffffffffffff13
RAX: dffffc0000000000 RBX: 1ffff1003391ff03 RCX: ffffc90005236000
RDX: 1ffffffff0fe3616 RSI: 0000000000000000 RDI: ffffffff87f1b0b0
RBP: ffff88019c8ff920 R08: 0000000000000000 R09: 0000000000000000
R10: ffff88019907c978 R11: b21129c27367def3 R12: ffff88019c8ff8f8
R13: ffff8801abf50bc8 R14: ffff88019c8ffa20 R15: ffff88019907c140
  __might_fault+0x19e/0x1e0 mm/memory.c:4564
  _copy_from_user+0x30/0x150 lib/usercopy.c:10
  copy_from_user include/linux/uaccess.h:147 [inline]
  snd_seq_oss_write+0x188/0xb70 sound/core/seq/oss/seq_oss_rw.c:106
  odev_write+0x59/0x90 sound/core/seq/oss/seq_oss.c:177
  __vfs_write+0x117/0x9f0 fs/read_write.c:485
  vfs_write+0x1f8/0x560 fs/read_write.c:549
  ksys_write+0x101/0x260 fs/read_write.c:598
  __do_sys_write fs/read_write.c:610 [inline]
  __se_sys_write fs/read_write.c:607 [inline]
  __ia32_sys_write+0x71/0xb0 fs/read_write.c:607
  do_syscall_32_irqs_on arch/x86/entry/common.c:326 [inline]
  do_fast_syscall_32+0x34d/0xfb2 arch/x86/entry/common.c:397
  entry_SYSENTER_compat+0x70/0x7f arch/x86/entry/entry_64_compat.S:139
RIP: 0023:0xf7f87cb9
Code: 55 08 8b 88 64 cd ff ff 8b 98 68 cd ff ff 89 c8 85 d2 74 02 89 0a 5b  
5d c3 8b 04 24 c3 8b 1c 24 c3 51 52 55 89 e5 0f 34 cd 80 <5d> 5a 59 c3 90  
90 90 90 eb 0d 90 90 90 90 90 90 90 90 90 90 90 90
RSP: 002b:00000000f5f410cc EFLAGS: 00000296 ORIG_RAX: 0000000000000004
RAX: ffffffffffffffda RBX: 000000000000001b RCX: 0000000020000240
RDX: 00000000fffffe71 RSI: 0000000000000000 RDI: 0000000000000000
RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: 0000000000000000 R14: 0000000000000000 R15: 0000000000000000
rcu_sched kthread starved for 55292 jiffies! g114619 c114618 f0x2  
RCU_GP_WAIT_FQS(3) ->state=0x0 ->cpu=1
RCU grace-period kthread stack dump:
rcu_sched       R  running task    23688    10      2 0x80000000
Call Trace:
  context_switch kernel/sched/core.c:2853 [inline]
  __schedule+0x87c/0x1ec0 kernel/sched/core.c:3501
  schedule+0xfb/0x450 kernel/sched/core.c:3545
  schedule_timeout+0x140/0x260 kernel/time/timer.c:1801
  rcu_gp_kthread+0x717/0x1c90 kernel/rcu/tree.c:2179
  kthread+0x345/0x410 kernel/kthread.c:246
  ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:412


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
