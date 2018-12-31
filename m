Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id C7FAC8E005B
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 02:50:49 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id q23so31175708ior.6
        for <linux-mm@kvack.org>; Sun, 30 Dec 2018 23:50:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z25sor10316839iob.90.2018.12.30.23.50.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Dec 2018 23:50:48 -0800 (PST)
MIME-Version: 1.0
References: <000000000000837814057e4ca571@google.com>
In-Reply-To: <000000000000837814057e4ca571@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 31 Dec 2018 08:50:37 +0100
Message-ID: <CACT4Y+Y1zWq-jckxS+B0hAUKZKrSeNUn1q0_gHyyaAoO6DfFiQ@mail.gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 qlist_free_all (6)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+84caccb6fb5a9d11b560@syzkaller.appspotmail.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Al Viro <viro@zeniv.linux.org.uk>, Linux-MM <linux-mm@kvack.org>

On Mon, Dec 31, 2018 at 8:49 AM syzbot
<syzbot+84caccb6fb5a9d11b560@syzkaller.appspotmail.com> wrote:
>
> Hello,
>
> syzbot found the following crash on:
>
> HEAD commit:    5f179793f0a7 Merge tag 'for_linus' of git://git.kernel.org..
> git tree:       upstream
> console output: https://syzkaller.appspot.com/x/log.txt?x=17a713d5400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=8110fb1cd164e8f
> dashboard link: https://syzkaller.appspot.com/bug?extid=84caccb6fb5a9d11b560
> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=11b8592b400000
>
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+84caccb6fb5a9d11b560@syzkaller.appspotmail.com

The repro matches the ones that cause stack overflow during OOMs:

#syz dup: kernel panic: corrupted stack end in wb_workfn


> device bridge_slave_0 left promiscuous mode
> bridge0: port 1(bridge_slave_0) entered disabled state
> team0 (unregistering): Port device team_slave_1 removed
> team0 (unregistering): Port device team_slave_0 removed
> bond0 (unregistering): Releasing backup interface bond_slave_1
> BUG: unable to handle kernel NULL pointer dereference at 00000000000000fc
> PGD 1c38c3067 P4D 1c38c3067 PUD 1c38c8067 PMD 0
> Oops: 0000 [#1] PREEMPT SMP KASAN
> CPU: 1 PID: 5937 Comm: rs:main Q:Reg Not tainted 4.20.0-rc5+ #146
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> RIP: 0010:qlist_free_all+0x30/0x140 mm/kasan/quarantine.c:163
> Code: 41 56 41 55 41 54 53 48 83 ec 08 48 8b 1f 48 85 db 0f 84 b0 00 00 00
> 49 89 f4 48 89 7d d0 4d 85 e4 4d 89 e7 0f 84 c7 00 00 00 <49> 63 87 fc 00
> 00 00 4c 8b 33 48 29 c3 48 83 3d 53 10 8f 07 00 49
> RSP: 0018:ffff8881b1f0ec28 EFLAGS: 00010246
> RAX: ffffea00001f5400 RBX: ffffffff87d50a40 RCX: ffffea00001f5407
> RDX: 0000000000000000 RSI: ffffffff8139dd66 RDI: 0000000000000007
> RBP: ffff8881b1f0ec58 R08: ffff8881c3bee080 R09: 0000000000000006
> R10: 0000000000000000 R11: ffff8881c3bee080 R12: 0000000000000000
> R13: ffff8881d92d7f18 R14: ffffffff87d50a40 R15: 0000000000000000
> FS:  00007f8d04ccb700(0000) GS:ffff8881daf00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000000000fc CR3: 00000001c4212000 CR4: 00000000001406e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Call Trace:
>   quarantine_reduce+0x163/0x1a0 mm/kasan/quarantine.c:259
>   kasan_kmalloc+0x9b/0xe0 mm/kasan/kasan.c:538
>   kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:490
>   slab_post_alloc_hook mm/slab.h:444 [inline]
>   slab_alloc mm/slab.c:3392 [inline]
>   kmem_cache_alloc+0x11b/0x730 mm/slab.c:3552
>   kmem_cache_zalloc include/linux/slab.h:731 [inline]
>   alloc_buffer_head+0x7c/0x1b0 fs/buffer.c:3360
>   alloc_page_buffers+0x1cd/0x6b0 fs/buffer.c:829
>   create_empty_buffers+0xf4/0xdb0 fs/buffer.c:1516
>   ext4_block_write_begin+0x11ed/0x1870 fs/ext4/inode.c:1174
>   ext4_da_write_begin+0x43b/0x12c0 fs/ext4/inode.c:3108
>   generic_perform_write+0x3aa/0x6a0 mm/filemap.c:3140
>   __generic_file_write_iter+0x26e/0x630 mm/filemap.c:3265
>   ext4_file_write_iter+0x390/0x1420 fs/ext4/file.c:266
>   call_write_iter include/linux/fs.h:1857 [inline]
>   new_sync_write fs/read_write.c:474 [inline]
>   __vfs_write+0x6b8/0x9f0 fs/read_write.c:487
>   vfs_write+0x1fc/0x560 fs/read_write.c:549
>   ksys_write+0x101/0x260 fs/read_write.c:598
>   __do_sys_write fs/read_write.c:610 [inline]
>   __se_sys_write fs/read_write.c:607 [inline]
>   __x64_sys_write+0x73/0xb0 fs/read_write.c:607
>   do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
>   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x7f8d0672919d
> Code: d1 20 00 00 75 10 b8 01 00 00 00 0f 05 48 3d 01 f0 ff ff 73 31 c3 48
> 83 ec 08 e8 be fa ff ff 48 89 04 24 b8 01 00 00 00 0f 05 <48> 8b 3c 24 48
> 89 c2 e8 07 fb ff ff 48 89 d0 48 83 c4 08 48 3d 01
> RSP: 002b:00007f8d04cc9f90 EFLAGS: 00000293 ORIG_RAX: 0000000000000001
> RAX: ffffffffffffffda RBX: 0000000000000400 RCX: 00007f8d0672919d
> RDX: 0000000000000400 RSI: 0000000000e8ca90 RDI: 0000000000000005
> RBP: 0000000000e8ca90 R08: 0000000000eae080 R09: 00007f8d060a7440
> R10: 0000000000000000 R11: 0000000000000293 R12: 0000000000000000
> R13: 00007f8d04cca410 R14: 0000000000eae080 R15: 0000000000e8c890
> Modules linked in:
> CR2: 00000000000000fc
> ---[ end trace ede8d46aa0374d9c ]---
> RIP: 0010:qlist_free_all+0x30/0x140 mm/kasan/quarantine.c:163
> Code: 41 56 41 55 41 54 53 48 83 ec 08 48 8b 1f 48 85 db 0f 84 b0 00 00 00
> 49 89 f4 48 89 7d d0 4d 85 e4 4d 89 e7 0f 84 c7 00 00 00 <49> 63 87 fc 00
> 00 00 4c 8b 33 48 29 c3 48 83 3d 53 10 8f 07 00 49
> kobject: 'rx-0' (0000000047bedca6): kobject_cleanup, parent 0000000004119b11
> RSP: 0018:ffff8881b1f0ec28 EFLAGS: 00010246
> kobject: 'rx-0' (0000000047bedca6): auto cleanup 'remove' event
> RAX: ffffea00001f5400 RBX: ffffffff87d50a40 RCX: ffffea00001f5407
> kobject: 'rx-0' (0000000047bedca6): kobject_uevent_env
> kobject: 'rx-0' (0000000047bedca6): kobject_uevent_env: uevent_suppress
> caused the event to drop!
> RDX: 0000000000000000 RSI: ffffffff8139dd66 RDI: 0000000000000007
> kobject: 'rx-0' (0000000047bedca6): auto cleanup kobject_del
> RBP: ffff8881b1f0ec58 R08: ffff8881c3bee080 R09: 0000000000000006
> kobject: 'rx-0' (0000000047bedca6): calling ktype release
> R10: 0000000000000000 R11: ffff8881c3bee080 R12: 0000000000000000
> R13: ffff8881d92d7f18 R14: ffffffff87d50a40 R15: 0000000000000000
> FS:  00007f8d04ccb700(0000) GS:ffff8881daf00000(0000) knlGS:0000000000000000
> kobject: 'rx-0': free name
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> kobject: 'tx-0' (00000000115069f4): kobject_cleanup, parent 0000000004119b11
> CR2: 00000000000000fc CR3: 00000001c4212000 CR4: 00000000001406e0
> kobject: 'tx-0' (00000000115069f4): auto cleanup 'remove' event
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> kobject: 'tx-0' (00000000115069f4): kobject_uevent_env
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> kobject: 'tx-0' (00000000115069f4): kobject_uevent_env: uevent_suppress
> caused the event to drop!
> kobject: 'tx-0' (00000000115069f4): auto cleanup kobject_del
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
> syzbot can test patches for this bug, for details see:
> https://goo.gl/tpsmEJ#testing-patches
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/000000000000837814057e4ca571%40google.com.
> For more options, visit https://groups.google.com/d/optout.
