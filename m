Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 097FF6B0278
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:10:57 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id m9so12676433pff.0
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:10:57 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h1si9359078pln.582.2017.12.18.04.10.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Dec 2017 04:10:55 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] lockdep: Print number of locks held by running tasks.
Date: Mon, 18 Dec 2017 21:09:55 +0900
Message-Id: <1513598995-4385-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: syzkaller@googlegroups.com, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>

Since it is not safe to dump locks held by running tasks, lockdep is not
reporting locks held by running tasks. But reporting number of locks held
by running (or waiting to run) tasks might be able to give some clue for
debugging, for no suspicious lock was reported in an example shown below
when syzbot got a khungtaskd warning.

----------
INFO: task syz-executor7:10280 blocked for more than 120 seconds.
      Not tainted 4.15.0-rc3-next-20171214+ #67
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
syz-executor7   D    0 10280   3310 0x00000004
Call Trace:
 context_switch kernel/sched/core.c:2800 [inline]
 __schedule+0x30b/0xaf0 kernel/sched/core.c:3376
 schedule+0x2e/0x90 kernel/sched/core.c:3435
 io_schedule+0x11/0x40 kernel/sched/core.c:5043
 wait_on_page_bit_common mm/filemap.c:1099 [inline]
 wait_on_page_bit mm/filemap.c:1132 [inline]
 wait_on_page_locked include/linux/pagemap.h:530 [inline]
 __lock_page_or_retry+0x391/0x3e0 mm/filemap.c:1310
 lock_page_or_retry include/linux/pagemap.h:510 [inline]
 filemap_fault+0x61c/0xa70 mm/filemap.c:2532
 __do_fault+0x23/0xa4 mm/memory.c:3206
 do_read_fault mm/memory.c:3616 [inline]
 do_fault mm/memory.c:3716 [inline]
 handle_pte_fault mm/memory.c:3947 [inline]
 __handle_mm_fault+0x10b5/0x1930 mm/memory.c:4071
 handle_mm_fault+0x215/0x450 mm/memory.c:4108
 faultin_page mm/gup.c:502 [inline]
 __get_user_pages+0x1ff/0x980 mm/gup.c:699
 populate_vma_page_range+0xa1/0xb0 mm/gup.c:1200
 __mm_populate+0xcc/0x190 mm/gup.c:1250
 mm_populate include/linux/mm.h:2233 [inline]
 vm_mmap_pgoff+0x103/0x110 mm/util.c:338
 SYSC_mmap_pgoff mm/mmap.c:1533 [inline]
 SyS_mmap_pgoff+0x215/0x2c0 mm/mmap.c:1491
 SYSC_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
 SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:91
 entry_SYSCALL_64_fastpath+0x1f/0x96
RIP: 0033:0x452a09
RSP: 002b:00007efce66dac58 EFLAGS: 00000212 ORIG_RAX: 0000000000000009
RAX: ffffffffffffffda RBX: 000000000071bea0 RCX: 0000000000452a09
RDX: 0000000000000003 RSI: 0000000000001000 RDI: 0000000020e5b000
RBP: 0000000000000033 R08: 0000000000000016 R09: 0000000000000000
R10: 0000000000002011 R11: 0000000000000212 R12: 00000000006ed568
R13: 00000000ffffffff R14: 00007efce66db6d4 R15: 0000000000000000

Showing all locks held in the system:
2 locks held by khungtaskd/673:
 #0:  (rcu_read_lock){....}, at: [<00000000f4a26b03>] check_hung_uninterruptible_tasks kernel/hung_task.c:175 [inline]
 #0:  (rcu_read_lock){....}, at: [<00000000f4a26b03>] watchdog+0xbf/0x750 kernel/hung_task.c:249
 #1:  (tasklist_lock){.+.+}, at: [<00000000cd00a56d>] debug_show_all_locks+0x3d/0x1a0 kernel/locking/lockdep.c:4464
1 lock held by rsyslogd/2967:
 #0:  (&f->f_pos_lock){+.+.}, at: [<0000000085b629a7>] __fdget_pos+0x5b/0x70 fs/file.c:765
2 locks held by getty/3089:
 #0:  (&tty->ldisc_sem){++++}, at: [<000000000b906052>] ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
 #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000d59241b2>] n_tty_read+0xce/0xa40 drivers/tty/n_tty.c:2131
2 locks held by getty/3090:
 #0:  (&tty->ldisc_sem){++++}, at: [<000000000b906052>] ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
 #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000d59241b2>] n_tty_read+0xce/0xa40 drivers/tty/n_tty.c:2131
2 locks held by getty/3091:
 #0:  (&tty->ldisc_sem){++++}, at: [<000000000b906052>] ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
 #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000d59241b2>] n_tty_read+0xce/0xa40 drivers/tty/n_tty.c:2131
2 locks held by getty/3092:
 #0:  (&tty->ldisc_sem){++++}, at: [<000000000b906052>] ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
 #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000d59241b2>] n_tty_read+0xce/0xa40 drivers/tty/n_tty.c:2131
2 locks held by getty/3093:
 #0:  (&tty->ldisc_sem){++++}, at: [<000000000b906052>] ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
 #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000d59241b2>] n_tty_read+0xce/0xa40 drivers/tty/n_tty.c:2131
2 locks held by getty/3094:
 #0:  (&tty->ldisc_sem){++++}, at: [<000000000b906052>] ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
 #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000d59241b2>] n_tty_read+0xce/0xa40 drivers/tty/n_tty.c:2131
2 locks held by getty/3095:
 #0:  (&tty->ldisc_sem){++++}, at: [<000000000b906052>] ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
 #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000d59241b2>] n_tty_read+0xce/0xa40 drivers/tty/n_tty.c:2131
----------

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Peter Zijlstra <peterz@infradead.org> (maintainer:LOCKING PRIMITIVES)
Cc: Ingo Molnar <mingo@redhat.com> (maintainer:LOCKING PRIMITIVES)
---
 kernel/locking/lockdep.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 5fa1324..1459063 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -4483,8 +4483,15 @@ void debug_show_all_locks(void)
 		 * if it's not sleeping (or if it's not the current
 		 * task):
 		 */
-		if (p->state == TASK_RUNNING && p != current)
+		if (p->state == TASK_RUNNING && p != current) {
+			const int depth = p->lockdep_depth;
+
+			if (depth)
+				printk("%d lock%s held by %s/%d:\n",
+				       depth, depth > 1 ? "s" : "", p->comm,
+				       task_pid_nr(p));
 			continue;
+		}
 		if (p->lockdep_depth)
 			lockdep_print_held_locks(p);
 		if (!unlock)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
