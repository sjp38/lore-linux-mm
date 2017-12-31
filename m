Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 51E8D6B0253
	for <linux-mm@kvack.org>; Sun, 31 Dec 2017 03:11:53 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 73so32370784pfz.11
        for <linux-mm@kvack.org>; Sun, 31 Dec 2017 00:11:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s82sor11259354pfj.127.2017.12.31.00.11.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 31 Dec 2017 00:11:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <001a113bb44676f52b0560ad62d4@google.com>
References: <001a113bb44676f52b0560ad62d4@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 31 Dec 2017 09:11:31 +0100
Message-ID: <CACT4Y+YHBv+=wdS55FBWck0i9z00BKYcXbVxRGyJR4MwwcF92A@mail.gmail.com>
Subject: Re: BUG: bad usercopy in memdup_user_nul
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <bot+6b58391c99a480699fd06e8bdaa57af9e771f7e4@syzkaller.appspotmail.com>
Cc: David Windsor <dave@nullcore.net>, James Morse <james.morse@arm.com>, Kees Cook <keescook@chromium.org>, keun-o.park@darkmatter.ae, Laura Abbott <labbott@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mark Rutland <mark.rutland@arm.com>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com

On Tue, Dec 19, 2017 at 9:38 AM, syzbot
<bot+6b58391c99a480699fd06e8bdaa57af9e771f7e4@syzkaller.appspotmail.com>
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
> usercopy: kernel memory overwrite attempt detected to 00000000056dec9b
> (kmalloc-1024) (983 bytes)
> ------------[ cut here ]------------
> kernel BUG at mm/usercopy.c:84!
> invalid opcode: 0000 [#1] SMP
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 0 PID: 31345 Comm: syz-executor7 Not tainted 4.15.0-rc3-next-20171214+
> #67
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> RIP: 0010:report_usercopy mm/usercopy.c:76 [inline]
> RIP: 0010:__check_object_size+0x1e2/0x250 mm/usercopy.c:276
> RSP: 0018:ffffc90000dbf9c8 EFLAGS: 00010296
> RAX: 0000000000000061 RBX: ffffffff82e57be7 RCX: ffffffff8123dede
> RDX: 00000000000051be RSI: ffffc90002616000 RDI: ffff88021fc136f8
> RBP: ffffc90000dbfa00 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000000 R12: ffff8801fca28050
> R13: 00000000000003d7 R14: 0000000000000000 R15: ffffffff82edf8a5
> FS:  00007f506151b700(0000) GS:ffff88021fc00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 000000000071c000 CR3: 00000001fb4ca004 CR4: 00000000001626f0
> DR0: 0000000020000000 DR1: 0000000020001000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
> Call Trace:
>  check_object_size include/linux/thread_info.h:112 [inline]
>  check_copy_size include/linux/thread_info.h:143 [inline]
>  copy_from_user include/linux/uaccess.h:146 [inline]
>  memdup_user_nul+0x48/0xe0 mm/util.c:227
>  map_write+0x19d/0x920 kernel/user_namespace.c:903
>  proc_projid_map_write+0x91/0xc0 kernel/user_namespace.c:1085
>  __vfs_write+0x43/0x1e0 fs/read_write.c:480
>  __kernel_write+0x72/0x140 fs/read_write.c:501
>  write_pipe_buf+0x77/0x90 fs/splice.c:797
>  splice_from_pipe_feed fs/splice.c:502 [inline]
>  __splice_from_pipe+0x138/0x250 fs/splice.c:626
>  splice_from_pipe+0x66/0x90 fs/splice.c:661
>  default_file_splice_write+0x40/0x70 fs/splice.c:809
>  do_splice_from fs/splice.c:851 [inline]
>  direct_splice_actor+0x60/0x70 fs/splice.c:1018
>  splice_direct_to_actor+0xfb/0x280 fs/splice.c:973
>  do_splice_direct+0xac/0xe0 fs/splice.c:1061
>  do_sendfile+0x216/0x440 fs/read_write.c:1413
>  SYSC_sendfile64 fs/read_write.c:1468 [inline]
>  SyS_sendfile64+0x59/0xc0 fs/read_write.c:1460
>  entry_SYSCALL_64_fastpath+0x1f/0x96
> RIP: 0033:0x452a09
> RSP: 002b:00007f506151ac58 EFLAGS: 00000212 ORIG_RAX: 0000000000000028
> RAX: ffffffffffffffda RBX: 00007f506151a950 RCX: 0000000000452a09
> RDX: 000000002030f000 RSI: 0000000000000013 RDI: 0000000000000014
> RBP: 00007f506151a940 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000007563 R11: 0000000000000212 R12: 00000000004b7366
> R13: 00007f506151aac8 R14: 00000000004b7371 R15: 0000000000000000
> Code: 7b e5 82 48 0f 44 da e8 8d 82 eb ff 48 8b 45 d0 4d 89 e9 4c 89 e1 4c
> 89 fa 48 89 de 48 c7 c7 a8 51 e6 82 49 89 c0 e8 76 b7 e3 ff <0f> 0b 48 c7 c0
> 43 51 e6 82 eb a1 48 c7 c0 53 51 e6 82 eb 98 48
> RIP: report_usercopy mm/usercopy.c:76 [inline] RSP: ffffc90000dbf9c8
> RIP: __check_object_size+0x1e2/0x250 mm/usercopy.c:276 RSP: ffffc90000dbf9c8
> ---[ end trace dbe6ffc74bf4afa4 ]---


Bad things on kmalloc-1024 are most likely caused by an invalid free
in pcrypt, it freed a pointer into a middle of a 1024 byte heap object
which was undetected by KASAN (now there is a patch for this in mm
tree) and later caused all kinds of bad things:
https://groups.google.com/forum/#!topic/syzkaller-bugs/NKn_ivoPOpk
https://patchwork.kernel.org/patch/10126761/

#syz dup: KASAN: use-after-free Read in __list_del_entry_valid (2)


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
>
> --
> You received this message because you are subscribed to the Google Groups
> "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an
> email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit
> https://groups.google.com/d/msgid/syzkaller-bugs/001a113bb44676f52b0560ad62d4%40google.com.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
