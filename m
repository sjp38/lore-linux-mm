Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 768576B0003
	for <linux-mm@kvack.org>; Sun,  1 Apr 2018 13:10:03 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id o132so11978903iod.11
        for <linux-mm@kvack.org>; Sun, 01 Apr 2018 10:10:03 -0700 (PDT)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id m127sor5764457iom.2.2018.04.01.10.10.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 01 Apr 2018 10:10:02 -0700 (PDT)
MIME-Version: 1.0
Date: Sun, 01 Apr 2018 10:10:01 -0700
Message-ID: <94eb2c05b2d83650030568cc8bd9@google.com>
Subject: INFO: task hung in wb_shutdown (2)
From: syzbot <syzbot+c0cf869505e03bdf1a24@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, christophe.jaillet@wanadoo.fr, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, zhangweiping@didichuxing.com

Hello,

syzbot hit the following crash on upstream commit
3eb2ce825ea1ad89d20f7a3b5780df850e4be274 (Sun Mar 25 22:44:30 2018 +0000)
Linux 4.16-rc7
syzbot dashboard link:  
https://syzkaller.appspot.com/bug?extid=c0cf869505e03bdf1a24

So far this crash happened 179 times on upstream.
Unfortunately, I don't have any reproducer for this crash yet.
Raw console output:  
https://syzkaller.appspot.com/x/log.txt?id=4738516814659584
Kernel config:  
https://syzkaller.appspot.com/x/.config?id=-8440362230543204781
compiler: gcc (GCC) 7.1.1 20170620

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+c0cf869505e03bdf1a24@syzkaller.appspotmail.com
It will help syzbot understand when the bug is fixed. See footer for  
details.
If you forward the report, please keep this part and the footer.

unregister_netdevice: waiting for lo to become free. Usage count = 1
unregister_netdevice: waiting for lo to become free. Usage count = 1
unregister_netdevice: waiting for lo to become free. Usage count = 1
unregister_netdevice: waiting for lo to become free. Usage count = 1
unregister_netdevice: waiting for lo to become free. Usage count = 1
INFO: task kworker/0:5:16458 blocked for more than 120 seconds.
       Not tainted 4.16.0-rc7+ #368
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
kworker/0:5     D20928 16458      2 0x80000000
Workqueue: events cgwb_release_workfn
Call Trace:
  context_switch kernel/sched/core.c:2862 [inline]
  __schedule+0x8fb/0x1ec0 kernel/sched/core.c:3440
  schedule+0xf5/0x430 kernel/sched/core.c:3499
  bit_wait+0x18/0x90 kernel/sched/wait_bit.c:250
  __wait_on_bit+0x88/0x130 kernel/sched/wait_bit.c:51
  out_of_line_wait_on_bit+0x204/0x3a0 kernel/sched/wait_bit.c:64
  wait_on_bit include/linux/wait_bit.h:84 [inline]
  wb_shutdown+0x335/0x430 mm/backing-dev.c:377
  cgwb_release_workfn+0x8b/0x61d mm/backing-dev.c:520
  process_one_work+0xc47/0x1bb0 kernel/workqueue.c:2113
  worker_thread+0x223/0x1990 kernel/workqueue.c:2247
  kthread+0x33c/0x400 kernel/kthread.c:238
  ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:406

Showing all locks held in the system:
3 locks held by kworker/u4:1/21:
  #0:  ((wq_completion)"%s""netns"){+.+.}, at: [<00000000c0d07d52>]  
work_static include/linux/workqueue.h:198 [inline]
  #0:  ((wq_completion)"%s""netns"){+.+.}, at: [<00000000c0d07d52>]  
set_work_data kernel/workqueue.c:619 [inline]
  #0:  ((wq_completion)"%s""netns"){+.+.}, at: [<00000000c0d07d52>]  
set_work_pool_and_clear_pending kernel/workqueue.c:646 [inline]
  #0:  ((wq_completion)"%s""netns"){+.+.}, at: [<00000000c0d07d52>]  
process_one_work+0xb12/0x1bb0 kernel/workqueue.c:2084
  #1:  (net_cleanup_work){+.+.}, at: [<000000006c4c2cfd>]  
process_one_work+0xb89/0x1bb0 kernel/workqueue.c:2088
  #2:  (net_mutex){+.+.}, at: [<0000000058427774>] cleanup_net+0x242/0xcb0  
net/core/net_namespace.c:484
2 locks held by khungtaskd/869:
  #0:  (rcu_read_lock){....}, at: [<000000009066e5de>]  
check_hung_uninterruptible_tasks kernel/hung_task.c:175 [inline]
  #0:  (rcu_read_lock){....}, at: [<000000009066e5de>] watchdog+0x1c5/0xd60  
kernel/hung_task.c:249
  #1:  (tasklist_lock){.+.+}, at: [<000000002117cbd8>]  
debug_show_all_locks+0xd3/0x3d0 kernel/locking/lockdep.c:4470
2 locks held by getty/4407:
  #0:  (&tty->ldisc_sem){++++}, at: [<0000000015dafb41>]  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000841085d3>]  
n_tty_read+0x2ef/0x1a40 drivers/tty/n_tty.c:2131
2 locks held by getty/4408:
  #0:  (&tty->ldisc_sem){++++}, at: [<0000000015dafb41>]  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000841085d3>]  
n_tty_read+0x2ef/0x1a40 drivers/tty/n_tty.c:2131
2 locks held by getty/4409:
  #0:  (&tty->ldisc_sem){++++}, at: [<0000000015dafb41>]  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000841085d3>]  
n_tty_read+0x2ef/0x1a40 drivers/tty/n_tty.c:2131
2 locks held by getty/4410:
  #0:  (&tty->ldisc_sem){++++}, at: [<0000000015dafb41>]  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000841085d3>]  
n_tty_read+0x2ef/0x1a40 drivers/tty/n_tty.c:2131
2 locks held by getty/4411:
  #0:  (&tty->ldisc_sem){++++}, at: [<0000000015dafb41>]  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000841085d3>]  
n_tty_read+0x2ef/0x1a40 drivers/tty/n_tty.c:2131
2 locks held by getty/4412:
  #0:  (&tty->ldisc_sem){++++}, at: [<0000000015dafb41>]  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000841085d3>]  
n_tty_read+0x2ef/0x1a40 drivers/tty/n_tty.c:2131
2 locks held by getty/4413:
  #0:  (&tty->ldisc_sem){++++}, at: [<0000000015dafb41>]  
ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
  #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000841085d3>]  
n_tty_read+0x2ef/0x1a40 drivers/tty/n_tty.c:2131
2 locks held by kworker/0:5/16458:
  #0:  ((wq_completion)"events"){+.+.}, at: [<00000000c0d07d52>] work_static  
include/linux/workqueue.h:198 [inline]
  #0:  ((wq_completion)"events"){+.+.}, at: [<00000000c0d07d52>]  
set_work_data kernel/workqueue.c:619 [inline]
  #0:  ((wq_completion)"events"){+.+.}, at: [<00000000c0d07d52>]  
set_work_pool_and_clear_pending kernel/workqueue.c:646 [inline]
  #0:  ((wq_completion)"events"){+.+.}, at: [<00000000c0d07d52>]  
process_one_work+0xb12/0x1bb0 kernel/workqueue.c:2084
  #1:  ((work_completion)(&wb->release_work)){+.+.}, at:  
[<000000006c4c2cfd>] process_one_work+0xb89/0x1bb0 kernel/workqueue.c:2088
1 lock held by syz-executor6/23709:
  #0:  (net_mutex){+.+.}, at: [<00000000843d65a3>] copy_net_ns+0x1f5/0x580  
net/core/net_namespace.c:417

=============================================

NMI backtrace for cpu 0
CPU: 0 PID: 869 Comm: khungtaskd Not tainted 4.16.0-rc7+ #368
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:17 [inline]
  dump_stack+0x194/0x24d lib/dump_stack.c:53
  nmi_cpu_backtrace+0x1d2/0x210 lib/nmi_backtrace.c:103
  nmi_trigger_cpumask_backtrace+0x123/0x180 lib/nmi_backtrace.c:62
  arch_trigger_cpumask_backtrace+0x14/0x20 arch/x86/kernel/apic/hw_nmi.c:38
  trigger_all_cpu_backtrace include/linux/nmi.h:138 [inline]
  check_hung_task kernel/hung_task.c:132 [inline]
  check_hung_uninterruptible_tasks kernel/hung_task.c:190 [inline]
  watchdog+0x90c/0xd60 kernel/hung_task.c:249
  kthread+0x33c/0x400 kernel/kthread.c:238
  ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:406
Sending NMI from CPU 0 to CPUs 1:
NMI backtrace for cpu 1 skipped: idling at native_safe_halt+0x6/0x10  
arch/x86/include/asm/irqflags.h:54


---
This bug is generated by a dumb bot. It may contain errors.
See https://goo.gl/tpsmEJ for details.
Direct all questions to syzkaller@googlegroups.com.

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
