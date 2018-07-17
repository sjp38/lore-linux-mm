Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8CE376B000C
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 15:28:10 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id m25-v6so825445pgv.22
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 12:28:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e3-v6sor531282pln.37.2018.07.17.12.28.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Jul 2018 12:28:09 -0700 (PDT)
Date: Tue, 17 Jul 2018 12:28:06 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: kernel BUG at fs/userfaultfd.c:LINE! (2)
Message-ID: <20180717192806.GI75957@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000000000000dcb1a1057112c66a@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: syzbot <syzbot+121be635a7a35ddb7dcb@syzkaller.appspotmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk

[+Cc userfaultfd developers and linux-mm]

The reproducer hits the BUG_ON() in userfaultfd_release():

	BUG_ON(!!vma->vm_userfaultfd_ctx.ctx ^
	       !!(vma->vm_flags & (VM_UFFD_MISSING | VM_UFFD_WP)));

On Sun, Jul 15, 2018 at 05:19:03PM -0700, syzbot wrote:
> Hello,
> 
> syzbot found the following crash on:
> 
> HEAD commit:    37b5dca2898d Merge tag 'rtc-4.18-2' of git://git.kernel.or..
> git tree:       upstream
> console output: https://syzkaller.appspot.com/x/log.txt?x=12aaf3b2400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=25856fac4e580aa7
> dashboard link: https://syzkaller.appspot.com/bug?extid=121be635a7a35ddb7dcb
> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=11176d62400000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=1362b368400000
> 
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+121be635a7a35ddb7dcb@syzkaller.appspotmail.com
> 
> random: sshd: uninitialized urandom read (32 bytes read)
> random: sshd: uninitialized urandom read (32 bytes read)
> random: sshd: uninitialized urandom read (32 bytes read)
> ------------[ cut here ]------------
> kernel BUG at fs/userfaultfd.c:883!
> invalid opcode: 0000 [#1] SMP KASAN
> CPU: 0 PID: 4708 Comm: syz-executor086 Not tainted 4.18.0-rc4+ #148
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> RIP: 0010:userfaultfd_release+0x5fb/0x770 fs/userfaultfd.c:882
> Code: 00 31 c0 48 8b 4d d0 65 48 33 0c 25 28 00 00 00 0f 85 a1 00 00 00 48
> 8d 65 d8 5b 41 5c 41 5d 41 5e 41 5f 5d c3 e8 75 be a0 ff <0f> 0b 4c 89 f7 e8
> 0b 9e de ff e9 11 fc ff ff 4c 89 e7 e8 5e 9d de
> RSP: 0018:ffff8801d8407a80 EFLAGS: 00010293
> RAX: ffff8801d8742080 RBX: dffffc0000000000 RCX: ffffffff81db4a59
> RDX: 0000000000000000 RSI: ffffffff81db4ccb RDI: 0000000000000000
> RBP: ffff8801d8407bd0 R08: ffff8801d8742080 R09: 0000000000000000
> R10: ffff8801d87428b8 R11: 16fb0df9f74494d6 R12: ffff8801d89a3b58
> R13: 0000000000000000 R14: ffff8801d89a3a50 R15: 0000000000000000
> FS:  0000000000ed6880(0000) GS:ffff8801dae00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00007f45c6b81e78 CR3: 00000001acb61000 CR4: 00000000001406f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Call Trace:
>  __fput+0x355/0x8b0 fs/file_table.c:209
>  ____fput+0x15/0x20 fs/file_table.c:243
>  task_work_run+0x1ec/0x2a0 kernel/task_work.c:113
>  tracehook_notify_resume include/linux/tracehook.h:192 [inline]
>  exit_to_usermode_loop+0x313/0x370 arch/x86/entry/common.c:166
>  prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
>  syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
>  do_syscall_64+0x6be/0x820 arch/x86/entry/common.c:293
>  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x405471
> Code: 75 14 b8 03 00 00 00 0f 05 48 3d 01 f0 ff ff 0f 83 54 17 00 00 c3 48
> 83 ec 08 e8 6a fc ff ff 48 89 04 24 b8 03 00 00 00 0f 05 <48> 8b 3c 24 48 89
> c2 e8 b3 fc ff ff 48 89 d0 48 83 c4 08 48 3d 01
> RSP: 002b:00007ffcad3db600 EFLAGS: 00000293 ORIG_RAX: 0000000000000003
> RAX: 0000000000000000 RBX: 0000000000000005 RCX: 0000000000405471
> RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000005
> RBP: 0000000000000001 R08: 0000000000000000 R09: 0000000000000000
> R10: 00007ffcad3db610 R11: 0000000000000293 R12: 00000000006dbc3c
> R13: 00000000006dbda0 R14: 0000000000000008 R15: 0000000000000001
> Modules linked in:
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> ---[ end trace 638e68cedadb8eda ]---
> RIP: 0010:userfaultfd_release+0x5fb/0x770 fs/userfaultfd.c:882
> Code: 00 31 c0 48 8b 4d d0 65 48 33 0c 25 28 00 00 00 0f 85 a1 00 00 00 48
> 8d 65 d8 5b 41 5c 41 5d 41 5e 41 5f 5d c3 e8 75 be a0 ff <0f> 0b 4c 89 f7 e8
> 0b 9e de ff e9 11 fc ff ff 4c 89 e7 e8 5e 9d de
> RSP: 0018:ffff8801d8407a80 EFLAGS: 00010293
> RAX: ffff8801d8742080 RBX: dffffc0000000000 RCX: ffffffff81db4a59
> RDX: 0000000000000000 RSI: ffffffff81db4ccb RDI: 0000000000000000
> RBP: ffff8801d8407bd0 R08: ffff8801d8742080 R09: 0000000000000000
> R10: ffff8801d87428b8 R11: 16fb0df9f74494d6 R12: ffff8801d89a3b58
> R13: 0000000000000000 R14: ffff8801d89a3a50 R15: 0000000000000000
> FS:  0000000000ed6880(0000) GS:ffff8801dae00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00007f45c6b81e78 CR3: 00000001acb61000 CR4: 00000000001406f0
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
> syzbot can test patches for this bug, for details see:
> https://goo.gl/tpsmEJ#testing-patches
> 
> -- 
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/000000000000dcb1a1057112c66a%40google.com.
> For more options, visit https://groups.google.com/d/optout.
