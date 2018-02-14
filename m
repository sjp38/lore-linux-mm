Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 33FC76B0003
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 10:37:11 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 189so2005544pge.0
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 07:37:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i7-v6sor3776149plt.78.2018.02.14.07.37.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Feb 2018 07:37:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <001a1140c57aa34e8205649a7ca6@google.com>
References: <001a1140c57aa34e8205649a7ca6@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 14 Feb 2018 16:36:48 +0100
Message-ID: <CACT4Y+YkguGRJZ+JiKXyGBOuvd4zK0q+XBOa7-FXnW0UzQROUw@mail.gmail.com>
Subject: Re: INFO: task hung in blkdev_fsync
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+2c56c0ca42f9e7bf1aef@syzkaller.appspotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Jan Kara <jack@suse.cz>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Ingo Molnar <mingo@kernel.org>, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, Al Viro <viro@zeniv.linux.org.uk>

On Wed, Feb 7, 2018 at 8:46 AM, syzbot
<syzbot+2c56c0ca42f9e7bf1aef@syzkaller.appspotmail.com> wrote:
> Hello,
>
> syzbot hit the following crash on upstream commit
> e237f98a9c134c3d600353f21e07db915516875b (Mon Feb 5 21:35:56 2018 +0000)
> Merge tag 'xfs-4.16-merge-5' of
> git://git.kernel.org/pub/scm/fs/xfs/xfs-linux
>
> Unfortunately, I don't have any reproducer for this crash yet.
> Raw console output is attached.
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached.


Looks similar to this one:

#syz dup: INFO: task hung in sync_blockdev


> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+2c56c0ca42f9e7bf1aef@syzkaller.appspotmail.com
> It will help syzbot understand when the bug is fixed. See footer for
> details.
> If you forward the report, please keep this part and the footer.
>
> Buffer I/O error on dev loop0, logical block 3, lost async page write
> INFO: task syz-executor1:13412 blocked for more than 120 seconds.
>       Not tainted 4.15.0+ #299
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> syz-executor1   D22160 13412  13284 0x00000004
> Call Trace:
>  context_switch kernel/sched/core.c:2845 [inline]
>  __schedule+0x8eb/0x2060 kernel/sched/core.c:3421
>  schedule+0xf5/0x430 kernel/sched/core.c:3480
>  io_schedule+0x1c/0x70 kernel/sched/core.c:5096
>  wait_on_page_bit_common+0x4b3/0x770 mm/filemap.c:1099
>  wait_on_page_bit mm/filemap.c:1132 [inline]
>  wait_on_page_writeback include/linux/pagemap.h:546 [inline]
>  __filemap_fdatawait_range+0x282/0x430 mm/filemap.c:533
>  file_write_and_wait_range+0xd7/0x100 mm/filemap.c:756
>  blkdev_fsync+0x67/0xb0 fs/block_dev.c:623
>  vfs_fsync_range+0x110/0x260 fs/sync.c:196
>  generic_write_sync include/linux/fs.h:2679 [inline]
>  blkdev_write_iter+0x2e6/0x3e0 fs/block_dev.c:1895
>  call_write_iter include/linux/fs.h:1781 [inline]
>  do_iter_readv_writev+0x55c/0x830 fs/read_write.c:653
>  do_iter_write+0x154/0x540 fs/read_write.c:932
>  vfs_iter_write+0x77/0xb0 fs/read_write.c:945
>  iter_file_splice_write+0x7db/0xf30 fs/splice.c:749
>  do_splice_from fs/splice.c:851 [inline]
>  direct_splice_actor+0x125/0x180 fs/splice.c:1018
>  splice_direct_to_actor+0x2c1/0x820 fs/splice.c:973
>  do_splice_direct+0x29b/0x3c0 fs/splice.c:1061
>  do_sendfile+0x5c9/0xe80 fs/read_write.c:1413
>  SYSC_sendfile64 fs/read_write.c:1468 [inline]
>  SyS_sendfile64+0xbd/0x160 fs/read_write.c:1460
>  do_syscall_64+0x282/0x940 arch/x86/entry/common.c:287
>  entry_SYSCALL_64_after_hwframe+0x26/0x9b
> RIP: 0033:0x453299
> RSP: 002b:00007faff6e0dc58 EFLAGS: 00000212 ORIG_RAX: 0000000000000028
> RAX: ffffffffffffffda RBX: 000000000071bea0 RCX: 0000000000453299
> RDX: 00000000200ddff8 RSI: 0000000000000016 RDI: 0000000000000013
> RBP: 00000000000004a0 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000100000001 R11: 0000000000000212 R12: 00000000006f5fa0
> R13: 00000000ffffffff R14: 00007faff6e0e6d4 R15: 0000000000000000
>
> Showing all locks held in the system:
> 3 locks held by kworker/u4:2/69:
>  #0:  ((wq_completion)"writeback"){+.+.}, at: [<0000000030bfda85>]
> process_one_work+0xaaf/0x1af0 kernel/workqueue.c:2084
>  #1:  ((work_completion)(&(&wb->dwork)->work)){+.+.}, at:
> [<0000000049257d79>] process_one_work+0xb01/0x1af0 kernel/workqueue.c:2088
>  #2:  (&type->s_umount_key#27){.+.+}, at: [<00000000626952c2>]
> trylock_super+0x20/0x100 fs/super.c:395
> 2 locks held by khungtaskd/758:
>  #0:  (rcu_read_lock){....}, at: [<000000009948c30a>]
> check_hung_uninterruptible_tasks kernel/hung_task.c:175 [inline]
>  #0:  (rcu_read_lock){....}, at: [<000000009948c30a>] watchdog+0x1c5/0xd60
> kernel/hung_task.c:249
>  #1:  (tasklist_lock){.+.+}, at: [<00000000e3ff5a9d>]
> debug_show_all_locks+0xd3/0x3d0 kernel/locking/lockdep.c:4470
> 2 locks held by getty/4127:
>  #0:  (&tty->ldisc_sem){++++}, at: [<00000000e999d147>]
> ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
>  #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000426efef1>]
> n_tty_read+0x2ef/0x1a00 drivers/tty/n_tty.c:2131
> 2 locks held by getty/4128:
>  #0:  (&tty->ldisc_sem){++++}, at: [<00000000e999d147>]
> ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
>  #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000426efef1>]
> n_tty_read+0x2ef/0x1a00 drivers/tty/n_tty.c:2131
> 2 locks held by getty/4129:
>  #0:  (&tty->ldisc_sem){++++}, at: [<00000000e999d147>]
> ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
>  #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000426efef1>]
> n_tty_read+0x2ef/0x1a00 drivers/tty/n_tty.c:2131
> 2 locks held by getty/4130:
>  #0:  (&tty->ldisc_sem){++++}, at: [<00000000e999d147>]
> ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
>  #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000426efef1>]
> n_tty_read+0x2ef/0x1a00 drivers/tty/n_tty.c:2131
> 2 locks held by getty/4131:
>  #0:  (&tty->ldisc_sem){++++}, at: [<00000000e999d147>]
> ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
>  #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000426efef1>]
> n_tty_read+0x2ef/0x1a00 drivers/tty/n_tty.c:2131
> 2 locks held by getty/4132:
>  #0:  (&tty->ldisc_sem){++++}, at: [<00000000e999d147>]
> ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
>  #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000426efef1>]
> n_tty_read+0x2ef/0x1a00 drivers/tty/n_tty.c:2131
> 2 locks held by getty/4133:
>  #0:  (&tty->ldisc_sem){++++}, at: [<00000000e999d147>]
> ldsem_down_read+0x37/0x40 drivers/tty/tty_ldsem.c:365
>  #1:  (&ldata->atomic_read_lock){+.+.}, at: [<00000000426efef1>]
> n_tty_read+0x2ef/0x1a00 drivers/tty/n_tty.c:2131
>
> =============================================
>
> NMI backtrace for cpu 0
> CPU: 0 PID: 758 Comm: khungtaskd Not tainted 4.15.0+ #299
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:17 [inline]
>  dump_stack+0x194/0x257 lib/dump_stack.c:53
>  nmi_cpu_backtrace+0x1d2/0x210 lib/nmi_backtrace.c:103
>  nmi_trigger_cpumask_backtrace+0x122/0x180 lib/nmi_backtrace.c:62
>  arch_trigger_cpumask_backtrace+0x14/0x20 arch/x86/kernel/apic/hw_nmi.c:38
>  trigger_all_cpu_backtrace include/linux/nmi.h:138 [inline]
>  check_hung_task kernel/hung_task.c:132 [inline]
>  check_hung_uninterruptible_tasks kernel/hung_task.c:190 [inline]
>  watchdog+0x90c/0xd60 kernel/hung_task.c:249
>  kthread+0x33c/0x400 kernel/kthread.c:238
>  ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:429
> Sending NMI from CPU 0 to CPUs 1:
> NMI backtrace for cpu 1 skipped: idling at native_safe_halt+0x6/0x10
> arch/x86/include/asm/irqflags.h:54
>
>
> ---
> This bug is generated by a dumb bot. It may contain errors.
> See https://goo.gl/tpsmEJ for details.
> Direct all questions to syzkaller@googlegroups.com.
>
> syzbot will keep track of this bug report.
> If you forgot to add the Reported-by tag, once the fix for this bug is
> merged
> into any tree, please reply to this email with:
> #syz fix: exact-commit-title
> To mark this as a duplicate of another syzbot report, please reply with:
> #syz dup: exact-subject-of-another-report
> If it's a one-off invalid bug report, please reply with:
> #syz invalid
> Note: if the crash happens again, it will cause creation of a new bug
> report.
> Note: all commands must start from beginning of the line in the email body.
>
> --
> You received this message because you are subscribed to the Google Groups
> "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an
> email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit
> https://groups.google.com/d/msgid/syzkaller-bugs/001a1140c57aa34e8205649a7ca6%40google.com.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
