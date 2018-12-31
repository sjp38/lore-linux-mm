Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 754718E005B
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 02:15:13 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id o22so31701363iob.13
        for <linux-mm@kvack.org>; Sun, 30 Dec 2018 23:15:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y78sor28227153itb.5.2018.12.30.23.15.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Dec 2018 23:15:12 -0800 (PST)
MIME-Version: 1.0
References: <0000000000006069e7057e4c2833@google.com>
In-Reply-To: <0000000000006069e7057e4c2833@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 31 Dec 2018 08:15:01 +0100
Message-ID: <CACT4Y+bxyQXWB51QT32+B7XAmsUEOtqebw34SH_65NqA9GA42g@mail.gmail.com>
Subject: Re: general protection fault in rb_next (2)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+563bb80fa8765090bf16@syzkaller.appspotmail.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Tejun Heo <tj@kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Dec 31, 2018 at 8:14 AM syzbot
<syzbot+563bb80fa8765090bf16@syzkaller.appspotmail.com> wrote:
>
> Hello,
>
> syzbot found the following crash on:
>
> HEAD commit:    edeca3a769ad Merge tag 'sound-4.20-rc4' of git://git.kerne..
> git tree:       upstream
> console output: https://syzkaller.appspot.com/x/log.txt?x=13316f7b400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=73e2bc0cb6463446
> dashboard link: https://syzkaller.appspot.com/bug?extid=563bb80fa8765090bf16
> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
>
> Unfortunately, I don't have any reproducer for this crash yet.
>
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+563bb80fa8765090bf16@syzkaller.appspotmail.com

Since this involves OOMs and looks like a one-off induced memory corruption:

#syz dup: kernel panic: corrupted stack end in wb_workfn

> bond0 (unregistering): Releasing backup interface bond_slave_0
> bond0 (unregistering): Released all slaves
> kasan: CONFIG_KASAN_INLINE enabled
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> general protection fault: 0000 [#1] PREEMPT SMP KASAN
> CPU: 1 PID: 160 Comm: kworker/u4:3 Not tainted 4.20.0-rc3+ #125
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Workqueue: netns cleanup_net
> RIP: 0010:rb_next+0xd7/0x140 lib/rbtree.c:541
> Code: 49 89 dc 4c 89 eb 48 83 e3 fc 48 89 d8 75 c8 48 83 c4 08 5b 41 5c 41
> 5d 41 5e 5d c3 48 89 d0 48 8d 78 10 48 89 fa 48 c1 ea 03 <80> 3c 1a 00 75
> 1a 48 8b 50 10 48 85 d2 75 e3 48 83 c4 08 5b 41 5c
> RSP: 0018:ffff8881d930ebc8 EFLAGS: 00010203
> RAX: 5741e5894855dfff RBX: dffffc0000000000 RCX: ffffffff81f8d010
> RDX: 0ae83cb1290abc01 RSI: ffffffff81f8cee0 RDI: 5741e5894855e00f
> RBP: ffff8881d930ebf0 R08: ffff8881d92fc480 R09: fffffbfff0fab697
> R10: fffffbfff0fab697 R11: ffffffff87d5b4bf R12: ffffffff87d5b4f0
> R13: fc0000000000ba48 R14: dffffc0000000000 R15: 0000000000000004
> FS:  0000000000000000(0000) GS:ffff8881daf00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000402e9d CR3: 000000017cbad000 CR4: 00000000001406e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
> Call Trace:
>   kernfs_next_descendant_post+0x89/0x2e0 fs/kernfs/dir.c:1235
>   __kernfs_remove+0x178/0xaf0 fs/kernfs/dir.c:1295
>   kernfs_remove+0x23/0x40 fs/kernfs/dir.c:1353
>   sysfs_remove_dir+0xd6/0x110 fs/sysfs/dir.c:101
>   kobject_del.part.4+0x3a/0xf0 lib/kobject.c:592
>   kobject_del lib/kobject.c:588 [inline]
>   kobject_cleanup lib/kobject.c:656 [inline]
>   kobject_release lib/kobject.c:691 [inline]
>   kref_put include/linux/kref.h:70 [inline]
>   kobject_put.cold.9+0x1f0/0x2e4 lib/kobject.c:708
>   netdev_queue_update_kobjects+0x312/0x4f0 net/core/net-sysfs.c:1513
>   remove_queue_kobjects net/core/net-sysfs.c:1563 [inline]
>   netdev_unregister_kobject+0x1ff/0x2e0 net/core/net-sysfs.c:1713
>   rollback_registered_many+0x8d4/0x1250 net/core/dev.c:8030
>   unregister_netdevice_many+0xfa/0x4c0 net/core/dev.c:9111
>   default_device_exit_batch+0x43a/0x540 net/core/dev.c:9580
>   ops_exit_list.isra.5+0x105/0x160 net/core/net_namespace.c:156
>   cleanup_net+0x555/0xb10 net/core/net_namespace.c:551
>   process_one_work+0xc90/0x1c40 kernel/workqueue.c:2153
>   worker_thread+0x17f/0x1390 kernel/workqueue.c:2296
>   kthread+0x35a/0x440 kernel/kthread.c:246
>   ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352
> Modules linked in:
> ---[ end trace 0076ea0e5672f55d ]---
> RIP: 0010:rb_next+0xd7/0x140 lib/rbtree.c:541
> Code: 49 89 dc 4c 89 eb 48 83 e3 fc 48 89 d8 75 c8 48 83 c4 08 5b 41 5c 41
> 5d 41 5e 5d c3 48 89 d0 48 8d 78 10 48 89 fa 48 c1 ea 03 <80> 3c 1a 00 75
> 1a 48 8b 50 10 48 85 d2 75 e3 48 83 c4 08 5b 41 5c
> RSP: 0018:ffff8881d930ebc8 EFLAGS: 00010203
> RAX: 5741e5894855dfff RBX: dffffc0000000000 RCX: ffffffff81f8d010
> RDX: 0ae83cb1290abc01 RSI: ffffffff81f8cee0 RDI: 5741e5894855e00f
> RBP: ffff8881d930ebf0 R08: ffff8881d92fc480 R09: fffffbfff0fab697
> R10: fffffbfff0fab697 R11: ffffffff87d5b4bf R12: ffffffff87d5b4f0
> R13: fc0000000000ba48 R14: dffffc0000000000 R15: 0000000000000004
> FS:  0000000000000000(0000) GS:ffff8881dae00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: ffffffffff600400 CR3: 00000001d2e72000 CR4: 00000000001406f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
>
>
> ---
> This bug is generated by a bot. It may contain errors.
> See https://goo.gl/tpsmEJ for more information about syzbot.
> syzbot engineers can be reached at syzkaller@googlegroups.com.
>
> syzbot will keep track of this bug report. See:
> https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with
> syzbot.
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/0000000000006069e7057e4c2833%40google.com.
> For more options, visit https://groups.google.com/d/optout.
