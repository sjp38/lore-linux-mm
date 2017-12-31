Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 62A4E6B0038
	for <linux-mm@kvack.org>; Sun, 31 Dec 2017 03:10:02 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id d4so27317927plr.8
        for <linux-mm@kvack.org>; Sun, 31 Dec 2017 00:10:02 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v1sor14284631plp.28.2017.12.31.00.10.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 31 Dec 2017 00:10:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jKNvUmgpqZdR+FEFRZZ34vfv5BPViCxZTGtkTiQ2Uy78w@mail.gmail.com>
References: <001a1140b830b8cf6d05607af7a6@google.com> <CAGXu5jKNvUmgpqZdR+FEFRZZ34vfv5BPViCxZTGtkTiQ2Uy78w@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 31 Dec 2017 09:09:39 +0100
Message-ID: <CACT4Y+aqojSpR_T+qW4DmyzTV9as6-aakzNa2vhc5-C7AryfiQ@mail.gmail.com>
Subject: Re: BUG: bad usercopy in ___sys_sendmsg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: syzbot <bot+60f2c3a2a759796bd44ac3f94599ab78756b6a62@syzkaller.appspotmail.com>, keun-o.park@darkmatter.ae, Laura Abbott <labbott@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mark Rutland <mark.rutland@arm.com>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com

On Sun, Dec 17, 2017 at 12:31 AM, Kees Cook <keescook@chromium.org> wrote:
> On Sat, Dec 16, 2017 at 12:29 PM, syzbot
> <bot+60f2c3a2a759796bd44ac3f94599ab78756b6a62@syzkaller.appspotmail.com>
> wrote:
>> Hello,
>>
>> syzkaller hit the following crash on
>> 5c13e07580c8bd2af6aa902d6b62faa968c360bc
>> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/master
>> compiler: gcc (GCC) 7.1.1 20170620
>> .config is attached
>> Raw console output is attached.
>>
>> Unfortunately, I don't have any reproducer for this bug yet.
>>
>
> The report before the BUG output is:
>
> [  518.368426] usercopy: kernel memory overwrite attempt detected to
> 000000009919ac15 (kmalloc-1024) (960 bytes)
>
> This looks like a heap overflow (the offset into the 1024 buffer isn't
> being reported, so it's not clear how far it goes):
>
>                 if (copy_from_user(ctl_buf,
>                                    (void __user __force *)msg_sys->msg_control,
>                                    ctl_len))
>
> I would expect the 960 to be ctl_len, though this somehow means the
> earlier sock_kmalloc() and kmalloc() broke in some insane fashion.
>
> A reproducer would be nice here; maybe there is some other corruption
> happening that manifests as an overflow?
>
> -Kees
>
>
>>
>> ------------[ cut here ]------------
>> netlink: 'syz-executor2': attribute type 5 has an invalid length.
>> kernel BUG at mm/usercopy.c:72!
>> invalid opcode: 0000 [#1] SMP KASAN
>> Dumping ftrace buffer:
>>    (ftrace buffer empty)
>> Modules linked in:
>> CPU: 0 PID: 24150 Comm: syz-executor3 Not tainted 4.15.0-rc2+ #153
>> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
>> Google 01/01/2011
>> RIP: 0010:report_usercopy mm/usercopy.c:64 [inline]
>> RIP: 0010:__check_object_size+0x3a2/0x4f0 mm/usercopy.c:264
>> RSP: 0018:ffff8801cece7940 EFLAGS: 00010282
>> RAX: 0000000000000061 RBX: ffffffff85328d40 RCX: 0000000000000000
>> RDX: 0000000000000061 RSI: ffffc90003cae000 RDI: ffffed0039d9cf1c
>> RBP: ffff8801cece7a30 R08: ffff8801cece71a8 R09: 0000000000000000
>> R10: 00000000712bcb5c R11: 0000000000000000 R12: ffffffff85328d00
>> R13: ffff8801cb8936d0 R14: 00000000000003c0 R15: ffffea00072e2480
>> FS:  00007f8422fd6700(0000) GS:ffff8801db400000(0000) knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> CR2: 0000558e50e10460 CR3: 000000019cd91000 CR4: 00000000001406f0
>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
>> Call Trace:
>>  check_object_size include/linux/thread_info.h:112 [inline]
>>  check_copy_size include/linux/thread_info.h:143 [inline]
>>  copy_from_user include/linux/uaccess.h:146 [inline]
>>  ___sys_sendmsg+0x58f/0x8a0 net/socket.c:2003
>>  __sys_sendmmsg+0x1e6/0x5f0 net/socket.c:2116
>>  SYSC_sendmmsg net/socket.c:2147 [inline]
>>  SyS_sendmmsg+0x35/0x60 net/socket.c:2142
>>  entry_SYSCALL_64_fastpath+0x1f/0x96
>> RIP: 0033:0x452a39
>> RSP: 002b:00007f8422fd5c58 EFLAGS: 00000212 ORIG_RAX: 0000000000000133
>> RAX: ffffffffffffffda RBX: 00007f8422fd6700 RCX: 0000000000452a39
>> RDX: 0000000000000006 RSI: 000000002077ce98 RDI: 0000000000000015
>> RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000000
>> R10: 0000000000000000 R11: 0000000000000212 R12: 0000000000000000
>> R13: 0000000000a6f7ff R14: 00007f8422fd69c0 R15: 0000000000000000
>> Code: 48 0f 44 da e8 e0 6e c2 ff 48 8b 85 28 ff ff ff 4d 89 f1 4c 89 e9 4c
>> 89 e2 48 89 de 48 c7 c7 00 8e 32 85 49 89 c0 e8 e6 2c ac ff <0f> 0b 48 c7 c0
>> c0 8b 32 85 eb 96 48 c7 c0 00 8c 32 85 eb 8d 48
>> RIP: report_usercopy mm/usercopy.c:64 [inline] RSP: ffff8801cece7940
>> RIP: __check_object_size+0x3a2/0x4f0 mm/usercopy.c:264 RSP: ffff8801cece7940
>> ---[ end trace 22ce313ea80c715c ]---
>> Kernel panic - not syncing: Fatal exception
>> Dumping ftrace buffer:
>>    (ftrace buffer empty)
>> Kernel Offset: disabled
>> Rebooting in 86400 seconds..
>>
>>
>> ---
>> This bug is generated by a dumb bot. It may contain errors.
>> See https://goo.gl/tpsmEJ for details.
>> Direct all questions to syzkaller@googlegroups.com.
>> Please credit me with: Reported-by: syzbot <syzkaller@googlegroups.com>
>>
>> syzbot will keep track of this bug report.
>> Once a fix for this bug is merged into any tree, reply to this email with:
>> #syz fix: exact-commit-title
>> To mark this as a duplicate of another syzbot report, please reply with:
>> #syz dup: exact-subject-of-another-report
>> If it's a one-off invalid bug report, please reply with:
>> #syz invalid
>> Note: if the crash happens again, it will cause creation of a new bug
>> report.
>> Note: all commands must start from beginning of the line in the email body.

Bad things on kmalloc-1024 are most likely caused by an invalid free
in pcrypt, it freed a pointer into a middle of a 1024 byte heap object
which was undetected by KASAN (now there is a patch for this in mm
tree) and later caused all kinds of bad things:
https://groups.google.com/forum/#!topic/syzkaller-bugs/NKn_ivoPOpk
https://patchwork.kernel.org/patch/10126761/

#syz dup: KASAN: use-after-free Read in __list_del_entry_valid (2)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
