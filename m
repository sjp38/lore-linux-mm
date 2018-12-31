Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 81B3D8E005B
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 02:06:20 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id p4so30864917iod.17
        for <linux-mm@kvack.org>; Sun, 30 Dec 2018 23:06:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g7sor49243569jae.14.2018.12.30.23.06.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Dec 2018 23:06:19 -0800 (PST)
MIME-Version: 1.0
References: <0000000000004fa95e057ca3b6c3@google.com>
In-Reply-To: <0000000000004fa95e057ca3b6c3@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 31 Dec 2018 08:06:07 +0100
Message-ID: <CACT4Y+ZjZqHUdTHGiphxUjZrmEOQgqJAw0dFxYivFQJkH06hyA@mail.gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in depot_save_stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+ed56d5a9b979d862fb67@syzkaller.appspotmail.com>
Cc: 'Dmitry Vyukov' via syzkaller-upstream-moderation <syzkaller-upstream-moderation@googlegroups.com>, Linux-MM <linux-mm@kvack.org>

On Mon, Dec 10, 2018 at 5:51 AM syzbot
<syzbot+ed56d5a9b979d862fb67@syzkaller.appspotmail.com> wrote:
>
> Hello,
>
> syzbot found the following crash on:
>
> HEAD commit:    b72f711a4efa Merge branch 'spectre' of git://git.armlinux...
> git tree:       upstream
> console output: https://syzkaller.appspot.com/x/log.txt?x=11eef243400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=b9cc5a440391cbfd
> dashboard link: https://syzkaller.appspot.com/bug?extid=ed56d5a9b979d862fb67
> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> CC:             [gregkh@linuxfoundation.org linux-kernel@vger.kernel.org
> tj@kernel.org]
>
> Unfortunately, I don't have any reproducer for this crash yet.
>
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+ed56d5a9b979d862fb67@syzkaller.appspotmail.com

Since this involves OOMs and looks like memory corruption:

#syz dup: kernel panic: corrupted stack end in wb_workfn

> IPVS: ftp: loaded support on port[0] = 21
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000009
> PGD 1b3eee067 P4D 1b3eee067 PUD 1b3eef067 PMD 0
> Oops: 0000 [#1] PREEMPT SMP KASAN
> CPU: 0 PID: 20236 Comm: syz-executor1 Not tainted 4.20.0-rc5+ #366
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> RIP: 0010:find_stack lib/stackdepot.c:188 [inline]
> RIP: 0010:depot_save_stack+0x121/0x470 lib/stackdepot.c:238
> Code: 0f 00 4e 8b 24 f5 20 0a 2e 8b 4d 85 e4 0f 84 d4 00 00 00 44 8d 47 ff
> 49 c1 e0 03 eb 0d 4d 8b 24 24 4d 85 e4 0f 84 bd 00 00 00 <41> 39 5c 24 08
> 75 ec 41 3b 7c 24 0c 75 e5 48 8b 01 49 39 44 24 18
> RSP: 0018:ffff888180156d08 EFLAGS: 00010202
> RAX: 0000000047977639 RBX: 00000000fef8ec23 RCX: ffff888180156d68
> RDX: 000000001e65b1bd RSI: 00000000006080c0 RDI: 0000000000000018
> RBP: ffff888180156d40 R08: 00000000000000b8 R09: 00000000dc2cc839
> R10: 00000000fafaa4f6 R11: ffff8881dae2dafb R12: 0000000000000001
> R13: ffff888180156d50 R14: 000000000008ec23 R15: ffff8881bba6641f
> FS:  0000000000d33940(0000) GS:ffff8881dae00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000000009 CR3: 00000001b3ecd000 CR4: 00000000001406f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Call Trace:
>   save_stack+0xa9/0xd0 mm/kasan/kasan.c:454
>   set_track mm/kasan/kasan.c:460 [inline]
>   kasan_kmalloc+0xc7/0xe0 mm/kasan/kasan.c:553
>   kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:490
>   slab_post_alloc_hook mm/slab.h:444 [inline]
>   slab_alloc mm/slab.c:3392 [inline]
>   kmem_cache_alloc+0x11b/0x730 mm/slab.c:3552
>   kmem_cache_zalloc include/linux/slab.h:731 [inline]
>   __kernfs_new_node+0x127/0x8d0 fs/kernfs/dir.c:634
>   kernfs_new_node+0x95/0x120 fs/kernfs/dir.c:695
>   __kernfs_create_file+0x5a/0x340 fs/kernfs/file.c:992
>   sysfs_add_file_mode_ns+0x222/0x530 fs/sysfs/file.c:306
>   sysfs_create_file_ns+0x1a3/0x270 fs/sysfs/file.c:331
>   sysfs_create_file include/linux/sysfs.h:513 [inline]
>   device_create_file+0xf4/0x1e0 drivers/base/core.c:1381
>   device_add+0x48c/0x18e0 drivers/base/core.c:1889
>   netdev_register_kobject+0x187/0x3f0 net/core/net-sysfs.c:1751
>   register_netdevice+0x99a/0x11d0 net/core/dev.c:8536
>   register_netdev+0x30/0x50 net/core/dev.c:8651
>   loopback_net_init+0x78/0x160 drivers/net/loopback.c:212
>   ops_init+0x101/0x560 net/core/net_namespace.c:129
>   setup_net+0x362/0x8d0 net/core/net_namespace.c:314
>   copy_net_ns+0x2b1/0x4a0 net/core/net_namespace.c:437
>   create_new_namespaces+0x6ad/0x900 kernel/nsproxy.c:107
>   unshare_nsproxy_namespaces+0xc3/0x1f0 kernel/nsproxy.c:206
>   ksys_unshare+0x79c/0x10b0 kernel/fork.c:2539
>   __do_sys_unshare kernel/fork.c:2607 [inline]
>   __se_sys_unshare kernel/fork.c:2605 [inline]
>   __x64_sys_unshare+0x31/0x40 kernel/fork.c:2605
>   do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
>   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x45a057
> Code: 00 00 00 b8 63 00 00 00 0f 05 48 3d 01 f0 ff ff 0f 83 fd 88 fb ff c3
> 66 2e 0f 1f 84 00 00 00 00 00 66 90 b8 10 01 00 00 0f 05 <48> 3d 01 f0 ff
> ff 0f 83 dd 88 fb ff c3 66 2e 0f 1f 84 00 00 00 00
> RSP: 002b:0000000000a3ff78 EFLAGS: 00000202 ORIG_RAX: 0000000000000110
> RAX: ffffffffffffffda RBX: 00007f2516b77000 RCX: 000000000045a057
> RDX: 0000000000000006 RSI: 0000000000a3fa90 RDI: 0000000040000000
> RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000006
> R10: 0000000000000064 R11: 0000000000000202 R12: 0000000000000010
> R13: 0000000000412e50 R14: 0000000000000000 R15: 0000000000000000
> Modules linked in:
> CR2: 0000000000000009
> ---[ end trace 8ed3c6a41fc89e09 ]---
> RIP: 0010:find_stack lib/stackdepot.c:188 [inline]
> RIP: 0010:depot_save_stack+0x121/0x470 lib/stackdepot.c:238
> Code: 0f 00 4e 8b 24 f5 20 0a 2e 8b 4d 85 e4 0f 84 d4 00 00 00 44 8d 47 ff
> 49 c1 e0 03 eb 0d 4d 8b 24 24 4d 85 e4 0f 84 bd 00 00 00 <41> 39 5c 24 08
> 75 ec 41 3b 7c 24 0c 75 e5 48 8b 01 49 39 44 24 18
> RSP: 0018:ffff888180156d08 EFLAGS: 00010202
> RAX: 0000000047977639 RBX: 00000000fef8ec23 RCX: ffff888180156d68
> RDX: 000000001e65b1bd RSI: 00000000006080c0 RDI: 0000000000000018
> RBP: ffff888180156d40 R08: 00000000000000b8 R09: 00000000dc2cc839
> R10: 00000000fafaa4f6 R11: ffff8881dae2dafb R12: 0000000000000001
> R13: ffff888180156d50 R14: 000000000008ec23 R15: ffff8881bba6641f
> FS:  0000000000d33940(0000) GS:ffff8881dae00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000000009 CR3: 00000001b3ecd000 CR4: 00000000001406f0
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
> You received this message because you are subscribed to the Google Groups "syzkaller-upstream-moderation" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-upstream-moderation+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-upstream-moderation/0000000000004fa95e057ca3b6c3%40google.com.
> For more options, visit https://groups.google.com/d/optout.
