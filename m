Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C7E2D6B028B
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 12:34:03 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id u65so1401756pfd.7
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 09:34:03 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n125sor1499360pga.297.2018.02.06.09.34.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Feb 2018 09:34:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <94eb2c0efc1ede1c4205648e8a49@google.com>
References: <94eb2c0efc1ede1c4205648e8a49@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 6 Feb 2018 18:33:41 +0100
Message-ID: <CACT4Y+ZybLXnPiQ8BDLORD6VA8E7KeMrJZxO8q46MfMKyH7q_Q@mail.gmail.com>
Subject: Re: WARNING: bad usercopy in put_cmsg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+c4dcac91687a29cbae15@syzkaller.appspotmail.com>
Cc: Kees Cook <keescook@chromium.org>, keun-o.park@darkmatter.ae, Laura Abbott <labbott@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mark Rutland <mark.rutland@arm.com>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com

On Tue, Feb 6, 2018 at 6:31 PM, syzbot
<syzbot+c4dcac91687a29cbae15@syzkaller.appspotmail.com> wrote:
> Hello,
>
> syzbot hit the following crash on upstream commit
> e237f98a9c134c3d600353f21e07db915516875b (Mon Feb 5 21:35:56 2018 +0000)
> Merge tag 'xfs-4.16-merge-5' of
> git://git.kernel.org/pub/scm/fs/xfs/xfs-linux
>
> So far this crash happened 8 times on net-next, upstream.
> C reproducer is attached.
> syzkaller reproducer is attached.
> Raw console output is attached.
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached.

#syz dup: WARNING in usercopy_warn

Let's make that one the main copy, since Kees is already looking at it.


> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+c4dcac91687a29cbae15@syzkaller.appspotmail.com
> It will help syzbot understand when the bug is fixed. See footer for
> details.
> If you forward the report, please keep this part and the footer.
>
> ------------[ cut here ]------------
> Bad or missing usercopy whitelist? Kernel memory exposure attempt detected
> from SLAB object 'skbuff_head_cache' (offset 64, size 16)!
> WARNING: CPU: 1 PID: 4176 at mm/usercopy.c:81 usercopy_warn+0xdb/0x100
> mm/usercopy.c:76
> Kernel panic - not syncing: panic_on_warn set ...
>
> CPU: 1 PID: 4176 Comm: syzkaller502931 Not tainted 4.15.0+ #299
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:17 [inline]
>  dump_stack+0x194/0x257 lib/dump_stack.c:53
>  panic+0x1e4/0x41c kernel/panic.c:183
>  __warn+0x1dc/0x200 kernel/panic.c:547
>  report_bug+0x211/0x2d0 lib/bug.c:184
>  fixup_bug.part.11+0x37/0x80 arch/x86/kernel/traps.c:178
>  fixup_bug arch/x86/kernel/traps.c:247 [inline]
>  do_error_trap+0x2d7/0x3e0 arch/x86/kernel/traps.c:296
>  do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:315
>  invalid_op+0x22/0x40 arch/x86/entry/entry_64.S:984
> RIP: 0010:usercopy_warn+0xdb/0x100 mm/usercopy.c:76
> RSP: 0018:ffff8801b2bc7598 EFLAGS: 00010286
> RAX: dffffc0000000008 RBX: ffffffff86801907 RCX: ffffffff815a585e
> RDX: 0000000000000000 RSI: 1ffff10036578e63 RDI: 1ffff10036578e38
> RBP: ffff8801b2bc75f0 R08: 0000000000000000 R09: 0000000000000000
> R10: 00000000000007a6 R11: 0000000000000000 R12: ffffffff86403180
> R13: ffffffff85f2d4c0 R14: 0000000000000040 R15: 0000000000000010
>  __check_heap_object+0x89/0xc0 mm/slab.c:4426
>  check_heap_object mm/usercopy.c:236 [inline]
>  __check_object_size+0x272/0x530 mm/usercopy.c:259
>  check_object_size include/linux/thread_info.h:112 [inline]
>  check_copy_size include/linux/thread_info.h:143 [inline]
>  copy_to_user include/linux/uaccess.h:154 [inline]
>  put_cmsg+0x233/0x3f0 net/core/scm.c:242
>  sock_recv_errqueue+0x200/0x3e0 net/core/sock.c:2910
>  packet_recvmsg+0xb2e/0x17a0 net/packet/af_packet.c:3296
>  sock_recvmsg_nosec net/socket.c:803 [inline]
>  sock_recvmsg+0xc9/0x110 net/socket.c:810
>  ___sys_recvmsg+0x2a4/0x640 net/socket.c:2205
>  __sys_recvmsg+0xe2/0x210 net/socket.c:2250
>  SYSC_recvmsg net/socket.c:2262 [inline]
>  SyS_recvmsg+0x2d/0x50 net/socket.c:2257
>  do_syscall_64+0x282/0x940 arch/x86/entry/common.c:287
>  entry_SYSCALL_64_after_hwframe+0x26/0x9b
> RIP: 0033:0x445399
> RSP: 002b:00007ffdfb47d4d8 EFLAGS: 00000217 ORIG_RAX: 000000000000002f
> RAX: ffffffffffffffda RBX: 0000000000000066 RCX: 0000000000445399
> RDX: 0000000000002000 RSI: 0000000020006fc8 RDI: 0000000000000004
> RBP: 00007ffdfb47d5e8 R08: 000000000000a1fd R09: 000000000000a1fd
> R10: 000000000000a1fd R11: 0000000000000217 R12: 00007ffdfb47d5e8
> R13: 0000000000402860 R14: 0000000000000000 R15: 0000000000000000
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
>
> syzbot will keep track of this bug report.
> If you forgot to add the Reported-by tag, once the fix for this bug is
> merged
> into any tree, please reply to this email with:
> #syz fix: exact-commit-title
> If you want to test a patch for this bug, please reply with:
> #syz test: git://repo/address.git branch
> and provide the patch inline or as an attachment.
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
> https://groups.google.com/d/msgid/syzkaller-bugs/94eb2c0efc1ede1c4205648e8a49%40google.com.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
