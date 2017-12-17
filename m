Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 12E736B0033
	for <linux-mm@kvack.org>; Sun, 17 Dec 2017 11:45:53 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id 49so8379352uat.8
        for <linux-mm@kvack.org>; Sun, 17 Dec 2017 08:45:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 32sor4113600uat.303.2017.12.17.08.45.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Dec 2017 08:45:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <001a1141c43a5f5178056084703f@google.com>
References: <001a1141c43a5f5178056084703f@google.com>
From: Kees Cook <keescook@chromium.org>
Date: Sun, 17 Dec 2017 08:45:50 -0800
Message-ID: <CAGXu5jLAvE9GaF=VdzR=wrUpquDSJkUXCidZMU-qb02+FDZW6g@mail.gmail.com>
Subject: Re: BUG: bad usercopy in old_dev_ioctl
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <bot+5e56fb40e0f2bc3f20402f782f0b3913cb959acc@syzkaller.appspotmail.com>
Cc: David Windsor <dave@nullcore.net>, James Morse <james.morse@arm.com>, keun-o.park@darkmatter.ae, Laura Abbott <labbott@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mark Rutland <mark.rutland@arm.com>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com

On Sat, Dec 16, 2017 at 11:47 PM, syzbot
<bot+5e56fb40e0f2bc3f20402f782f0b3913cb959acc@syzkaller.appspotmail.com>
wrote:
> Hello,
>
> syzkaller hit the following crash on
> 6084b576dca2e898f5c101baef151f7bfdbb606d
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
>
> Unfortunately, I don't have any reproducer for this bug yet.
>
>
> device gre0 entered promiscuous mode
> usercopy: kernel memory exposure attempt detected from 00000000a6830059
> (kmalloc-1024) (1024 bytes)
> ------------[ cut here ]------------
> kernel BUG at mm/usercopy.c:84!
> invalid opcode: 0000 [#1] SMP
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 1 PID: 28799 Comm: syz-executor4 Not tainted 4.15.0-rc3-next-20171214+
> #67
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> RIP: 0010:report_usercopy mm/usercopy.c:76 [inline]
> RIP: 0010:__check_object_size+0x1e2/0x250 mm/usercopy.c:276
> RSP: 0018:ffffc9000116fc50 EFLAGS: 00010286
> RAX: 0000000000000063 RBX: ffffffff82e6518f RCX: ffffffff8123dede
> RDX: 0000000000004c58 RSI: ffffc900050ed000 RDI: ffff88021fd136f8
> RBP: ffffc9000116fc88 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000000 R12: ffff880216bb6050
> R13: 0000000000000400 R14: 0000000000000001 R15: ffffffff82eda864
> FS:  00007f61a06bc700(0000) GS:ffff88021fd00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000020a5afd8 CR3: 000000020f8a9000 CR4: 00000000001406e0
> Call Trace:
>  check_object_size include/linux/thread_info.h:112 [inline]
>  check_copy_size include/linux/thread_info.h:143 [inline]
>  copy_to_user include/linux/uaccess.h:154 [inline]
>  old_dev_ioctl.isra.1+0x21d/0x9a0 net/bridge/br_ioctl.c:178

Uhh, this doesn't make sense, much like the other report...

                indices = kcalloc(num, sizeof(int), GFP_KERNEL);
                if (indices == NULL)
                        return -ENOMEM;

                get_port_ifindices(br, indices, num);
                if (copy_to_user((void __user *)args[1], indices,
num*sizeof(int)))

offset is 0. size overlaps. usercopy checks in -next must be broken. I
will double-check.

-Kees

>  br_dev_ioctl+0x3f/0xa0 net/bridge/br_ioctl.c:392
>  dev_ifsioc+0x175/0x520 net/core/dev_ioctl.c:354
>  dev_ioctl+0x548/0x7a0 net/core/dev_ioctl.c:589
>  sock_ioctl+0x150/0x320 net/socket.c:998
>  vfs_ioctl fs/ioctl.c:46 [inline]
>  do_vfs_ioctl+0xaf/0x840 fs/ioctl.c:686
>  SYSC_ioctl fs/ioctl.c:701 [inline]
>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:692
>  entry_SYSCALL_64_fastpath+0x1f/0x96
> RIP: 0033:0x452a39
> RSP: 002b:00007f61a06bbc58 EFLAGS: 00000212 ORIG_RAX: 0000000000000010
> RAX: ffffffffffffffda RBX: 00007f61a06bc700 RCX: 0000000000452a39
> RDX: 0000000020a59fd8 RSI: 00000000000089f0 RDI: 0000000000000014
> RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000212 R12: 0000000000000000
> R13: 0000000000a6f7ff R14: 00007f61a06bc9c0 R15: 0000000000000000
> Code: 7b e5 82 48 0f 44 da e8 8d 82 eb ff 48 8b 45 d0 4d 89 e9 4c 89 e1 4c
> 89 fa 48 89 de 48 c7 c7 a8 51 e6 82 49 89 c0 e8 76 b7 e3 ff <0f> 0b 48 c7 c0
> 43 51 e6 82 eb a1 48 c7 c0 53 51 e6 82 eb 98 48
> RIP: report_usercopy mm/usercopy.c:76 [inline] RSP: ffffc9000116fc50
> RIP: __check_object_size+0x1e2/0x250 mm/usercopy.c:276 RSP: ffffc9000116fc50
> ---[ end trace 5fadb883cda020dc ]---
> Kernel panic - not syncing: Fatal exception
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Kernel Offset: disabled
> Rebooting in 86400 seconds..
>
>
> ---
> This bug is generated by a dumb bot. It may contain errors.
> See https://goo.gl/tpsmEJ for details.
> Direct all questions to syzkaller@googlegroups.com.
> Please credit me with: Reported-by: syzbot <syzkaller@googlegroups.com>
>
> syzbot will keep track of this bug report.
> Once a fix for this bug is merged into any tree, reply to this email with:
> #syz fix: exact-commit-title
> To mark this as a duplicate of another syzbot report, please reply with:
> #syz dup: exact-subject-of-another-report
> If it's a one-off invalid bug report, please reply with:
> #syz invalid
> Note: if the crash happens again, it will cause creation of a new bug
> report.
> Note: all commands must start from beginning of the line in the email body.



-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
