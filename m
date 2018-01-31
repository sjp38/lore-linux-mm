Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B9466B0005
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 05:16:03 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id o42so9871933uao.12
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 02:16:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e6sor512126vkf.289.2018.01.31.02.16.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jan 2018 02:16:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180130213607.i4oybskvoxpzxqxd@gmail.com>
References: <94eb2c05551289ffff0563224e41@google.com> <20180130213607.i4oybskvoxpzxqxd@gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 31 Jan 2018 21:16:00 +1100
Message-ID: <CAGXu5j+2Yv8DaBfcxpL57pB_m=GrZt8V5w1wqmhjpR=ZiAm6QQ@mail.gmail.com>
Subject: Re: WARNING in usercopy_warn
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: James Morse <james.morse@arm.com>, keun-o.park@darkmatter.ae, syzbot <syzbot+e2d6cfb305e9f3911dea@syzkaller.appspotmail.com>, Laura Abbott <labbott@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com

On Wed, Jan 31, 2018 at 8:36 AM, Eric Biggers <ebiggers3@gmail.com> wrote:
> On Fri, Jan 19, 2018 at 06:58:01AM -0800, syzbot wrote:
>> Hello,
>>
>> syzbot hit the following crash on linux-next commit
>> b625c1ff82272e26c76570d3c7123419ec345b20
>>
>> So far this crash happened 5 times on linux-next, mmots.
>> C reproducer is attached.
>> syzkaller reproducer is attached.
>> Raw console output is attached.
>> compiler: gcc (GCC) 7.1.1 20170620
>> .config is attached.
>>
>> IMPORTANT: if you fix the bug, please add the following tag to the commit:
>> Reported-by: syzbot+e2d6cfb305e9f3911dea@syzkaller.appspotmail.com
>> It will help syzbot understand when the bug is fixed. See footer for
>> details.
>> If you forward the report, please keep this part and the footer.
>>
>> device syz0 entered promiscuous mode
>> ------------[ cut here ]------------
>> Bad or missing usercopy whitelist? Kernel memory exposure attempt detected
>> from SLAB object 'skbuff_head_cache' (offset 64, size 16)!
>> WARNING: CPU: 0 PID: 3663 at mm/usercopy.c:81 usercopy_warn+0xdb/0x100
>> mm/usercopy.c:76
>> Kernel panic - not syncing: panic_on_warn set ...
>>
>> CPU: 0 PID: 3663 Comm: syzkaller694156 Not tainted 4.15.0-rc7-next-20180115+
>> #97
>> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
>> Google 01/01/2011
>> Call Trace:
>>  __dump_stack lib/dump_stack.c:17 [inline]
>>  dump_stack+0x194/0x257 lib/dump_stack.c:53
>>  panic+0x1e4/0x41c kernel/panic.c:183
>>  __warn+0x1dc/0x200 kernel/panic.c:547
>>  report_bug+0x211/0x2d0 lib/bug.c:184
>>  fixup_bug.part.11+0x37/0x80 arch/x86/kernel/traps.c:178
>>  fixup_bug arch/x86/kernel/traps.c:247 [inline]
>>  do_error_trap+0x2d7/0x3e0 arch/x86/kernel/traps.c:296
>>  do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:315
>>  invalid_op+0x22/0x40 arch/x86/entry/entry_64.S:1085
>> RIP: 0010:usercopy_warn+0xdb/0x100 mm/usercopy.c:76
>> RSP: 0018:ffff8801d99df548 EFLAGS: 00010282
>> RAX: dffffc0000000008 RBX: ffffffff865cf19f RCX: ffffffff815aba6e
>> RDX: 0000000000000000 RSI: 1ffff1003b33be2e RDI: 1ffff1003b33be64
>> RBP: ffff8801d99df5a0 R08: 0000000000000000 R09: 0000000000000000
>> R10: 00000000000003e6 R11: 0000000000000000 R12: ffffffff86200d00
>> R13: ffffffff85d2cfc0 R14: 0000000000000040 R15: 0000000000000010
>>  __check_heap_object+0x89/0xc0 mm/slab.c:4426
>>  check_heap_object mm/usercopy.c:236 [inline]
>>  __check_object_size+0x272/0x530 mm/usercopy.c:259
>>  check_object_size include/linux/thread_info.h:112 [inline]
>>  check_copy_size include/linux/thread_info.h:143 [inline]
>>  copy_to_user include/linux/uaccess.h:154 [inline]
>>  put_cmsg+0x233/0x3f0 net/core/scm.c:242
>>  sock_recv_errqueue+0x200/0x3e0 net/core/sock.c:2913
>>  packet_recvmsg+0xb2e/0x17a0 net/packet/af_packet.c:3296
>>  sock_recvmsg_nosec net/socket.c:803 [inline]
>>  sock_recvmsg+0xc9/0x110 net/socket.c:810
>>  ___sys_recvmsg+0x2a4/0x640 net/socket.c:2179
>>  __sys_recvmmsg+0x2a9/0xaf0 net/socket.c:2287
>>  SYSC_recvmmsg net/socket.c:2368 [inline]
>>  SyS_recvmmsg+0xc4/0x160 net/socket.c:2352
>>  entry_SYSCALL_64_fastpath+0x29/0xa0
>> RIP: 0033:0x444339
>> RSP: 002b:00007ffdb359d7d8 EFLAGS: 00000203 ORIG_RAX: 000000000000012b
>> RAX: ffffffffffffffda RBX: 00000000004002e0 RCX: 0000000000444339
>> RDX: 0000000000000001 RSI: 0000000020ef7fc4 RDI: 0000000000000005
>> RBP: 00000000006ce018 R08: 0000000020000000 R09: 0000000000000001
>> R10: 0000000000002000 R11: 0000000000000203 R12: 0000000000402020
>> R13: 00000000004020b0 R14: 0000000000000000 R15: 0000000000000000
>> Dumping ftrace buffer:
>>    (ftrace buffer empty)
>> Kernel Offset: disabled
>> Rebooting in 86400 seconds..
>
> Kees, has this been fixed yet?

Hi! Thanks for the ping. I missed this in my backlog of email across
LCA. I'm looking at it now...

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
