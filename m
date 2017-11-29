Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 75C726B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 05:30:58 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 73so2164965pfz.11
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 02:30:58 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z6sor383611pgp.47.2017.11.29.02.30.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Nov 2017 02:30:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <001a1144a1eebb0bbe055f1c88b3@google.com>
References: <001a1144a1eebb0bbe055f1c88b3@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 29 Nov 2017 11:30:36 +0100
Message-ID: <CACT4Y+ZVYKQ1Cd_4SNGhqJhEUeeoVavFBNo2BDSw_HQcbxGLJw@mail.gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in kfree
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <bot+9f319d9f8748fecc56f23463861c56aae433413e@syzkaller.appspotmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, syzkaller-bugs@googlegroups.com, Herbert Xu <herbert@gondor.apana.org.au>, David Miller <davem@davemloft.net>, linux-crypto@vger.kernel.org, Eric Biggers <ebiggers@google.com>, Stephan Mueller <smueller@chronox.de>

On Wed, Nov 29, 2017 at 11:24 AM, syzbot
<bot+9f319d9f8748fecc56f23463861c56aae433413e@syzkaller.appspotmail.com>
wrote:
> Hello,
>
> syzkaller hit the following crash on
> 43570f0383d6d5879ae585e6c3cf027ba321546f
> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
>
> Unfortunately, I don't have any reproducer for this bug yet.
>
>
> netlink: 3 bytes leftover after parsing attributes in process
> `syz-executor3'.
> device gre0 entered promiscuous mode
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000074
> IP: virt_to_cache mm/slab.c:400 [inline]
> IP: kfree+0xb2/0x250 mm/slab.c:3802
> PGD 1d369e067 P4D 1d369e067 PUD 1c8da0067 PMD 0
> Oops: 0000 [#1] SMP KASAN
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 0 PID: 8031 Comm: syz-executor5 Not tainted 4.15.0-rc1+ #199
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> task: ffff8801d33f8540 task.stack: ffff8801d3b58000
> RIP: 0010:virt_to_cache mm/slab.c:400 [inline]
> RIP: 0010:kfree+0xb2/0x250 mm/slab.c:3802
> RSP: 0018:ffff8801d3b5f780 EFLAGS: 00010046
> RAX: 0000000000000000 RBX: ffff8801d3b5f948 RCX: ffffffffffffffff
> RDX: ffffea00074ed7c0 RSI: 0000000000000000 RDI: ffff8801d3b5f948
> RBP: ffff8801d3b5f7a0 R08: ffffed003a2c3b7c R09: 0000000000000000
> R10: 0000000000000001 R11: ffffed003a2c3b7b R12: 0000000000000286
> R13: 0000000000000000 R14: ffff8801d3b5f948 R15: ffff8801d3b5f8b0
> FS:  00007f7f80409700(0000) GS:ffff8801db400000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000000074 CR3: 00000001c97a2000 CR4: 00000000001426f0
> DR0: 0000000020001000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
> Call Trace:
>  blkcipher_walk_done+0x72b/0xde0 crypto/blkcipher.c:139
>  encrypt+0x50a/0xaf0 crypto/salsa20_generic.c:208
>  skcipher_crypt_blkcipher crypto/skcipher.c:622 [inline]
>  skcipher_decrypt_blkcipher+0x213/0x310 crypto/skcipher.c:640
>  crypto_skcipher_decrypt include/crypto/skcipher.h:463 [inline]
>  _skcipher_recvmsg crypto/algif_skcipher.c:144 [inline]
>  skcipher_recvmsg+0xa54/0xf20 crypto/algif_skcipher.c:165
>  sock_recvmsg_nosec net/socket.c:805 [inline]
>  sock_recvmsg+0xc9/0x110 net/socket.c:812
>  ___sys_recvmsg+0x29b/0x630 net/socket.c:2207
>  __sys_recvmsg+0xe2/0x210 net/socket.c:2252
>  SYSC_recvmsg net/socket.c:2264 [inline]
>  SyS_recvmsg+0x2d/0x50 net/socket.c:2259
>  entry_SYSCALL_64_fastpath+0x1f/0x96
> RIP: 0033:0x4529d9
> RSP: 002b:00007f7f80408c58 EFLAGS: 00000212 ORIG_RAX: 000000000000002f
> RAX: ffffffffffffffda RBX: 0000000000758190 RCX: 00000000004529d9
> RDX: 0000000000000002 RSI: 000000002022efc8 RDI: 0000000000000018
> RBP: 000000000000001a R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000212 R12: 00000000006ed310
> R13: 00000000ffffffff R14: 00007f7f804096d4 R15: 0000000000000002
> Code: c2 48 b8 00 00 00 00 00 ea ff ff 48 89 df 48 c1 ea 0c 48 c1 e2 06 48
> 01 c2 48 8b 42 20 48 8d 48 ff a8 01 48 0f 45 d1 4c 8b 6a 30 <49> 63 75 74 e8
> 65 75 af ff 48 89 de 4c 89 ef 4c 8b 75 08 e8 06
> RIP: virt_to_cache mm/slab.c:400 [inline] RSP: ffff8801d3b5f780
> RIP: kfree+0xb2/0x250 mm/slab.c:3802 RSP: ffff8801d3b5f780
> CR2: 0000000000000074
> ---[ end trace e41183aa3c5416f4 ]---


I think this was misattributed to mm. So +crypto maintainers, mm
maintainers to bcc.
Original attachments are here:
https://groups.google.com/forum/#!msg/syzkaller-bugs/bQmKHgXOQyc/ODs0diBkAgAJ
I've also filed an issue to fix such misattribution in future:
https://github.com/google/syzkaller/issues/446



> ---
> This bug is generated by a dumb bot. It may contain errors.
> See https://goo.gl/tpsmEJ for details.
> Direct all questions to syzkaller@googlegroups.com.
> Please credit me with: Reported-by: syzbot <syzkaller@googlegroups.com>
>
> syzbot will keep track of this bug report.
> Once a fix for this bug is committed, please reply to this email with:
> #syz fix: exact-commit-title
> To mark this as a duplicate of another syzbot report, please reply with:
> #syz dup: exact-subject-of-another-report
> If it's a one-off invalid bug report, please reply with:
> #syz invalid
> Note: if the crash happens again, it will cause creation of a new bug
> report.
> Note: all commands must start from beginning of the line in the email body.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
