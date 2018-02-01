Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id B48BF6B0003
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 02:02:07 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id a61so2841490pla.22
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 23:02:07 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r2sor66846pgd.354.2018.01.31.23.02.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jan 2018 23:02:03 -0800 (PST)
Date: Wed, 31 Jan 2018 23:02:00 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: general protection fault in page_mapping
Message-ID: <20180201070200.GA657@zzz.localdomain>
References: <001a11440bd89fbb530560279f62@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <001a11440bd89fbb530560279f62@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <bot+2ae755141b3df39bc92fbca1cb7272b7de1334b5@syzkaller.appspotmail.com>
Cc: akpm@linux-foundation.org, dhowells@redhat.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, mingo@kernel.org, syzkaller-bugs@googlegroups.com, vbabka@suse.cz, simo.ghannam@gmail.com

On Tue, Dec 12, 2017 at 09:03:01AM -0800, syzbot wrote:
> Hello,
> 
> syzkaller hit the following crash on
> 82bcf1def3b5f1251177ad47c44f7e17af039b4b
> git://git.cmpxchg.org/linux-mmots.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> C reproducer is attached
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers
> 
> 
> audit: type=1400 audit(1512751226.892:7): avc:  denied  { map } for
> pid=3149 comm="syzkaller233597" path="/root/syzkaller233597068" dev="sda1"
> ino=16481 scontext=unconfined_u:system_r:insmod_t:s0-s0:c0.c1023
> tcontext=unconfined_u:object_r:user_home_t:s0 tclass=file permissive=1
> kasan: CONFIG_KASAN_INLINE enabled
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> general protection fault: 0000 [#1] SMP KASAN
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 0 PID: 3149 Comm: syzkaller233597 Not tainted 4.15.0-rc2-mm1+ #39
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> RIP: 0010:__read_once_size include/linux/compiler.h:183 [inline]
> RIP: 0010:compound_head include/linux/page-flags.h:147 [inline]
> RIP: 0010:page_mapping+0xa4/0x530 mm/util.c:475
> RSP: 0018:ffff8801c5177320 EFLAGS: 00010202
> RAX: 0000000000000004 RBX: 1ffff10038a2ee65 RCX: ffffffff81950c5d
> RDX: 0000000000000000 RSI: 1ffff10038a2ef03 RDI: 0000000000000000
> RBP: ffff8801c5177470 R08: ffffed0038a6fbac R09: ffff8801c537dd40
> R10: ffff8801d6e8c518 R11: ffffed0038a6fbab R12: 0000000000000000
> R13: ffff8801c5177448 R14: dffffc0000000000 R15: 0000000000000020
> FS:  00000000021da880(0000) GS:ffff8801db200000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000020a23000 CR3: 00000001c6bf5000 CR4: 00000000001406f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Call Trace:
>  set_page_dirty+0xb9/0x5d0 mm/page-writeback.c:2544
>  rds_atomic_free_op+0xc2/0x330 net/rds/rdma.c:481
>  rds_message_purge net/rds/message.c:79 [inline]
>  rds_message_put+0x53c/0x6b0 net/rds/message.c:91
>  rds_sendmsg+0x14ee/0x1f90 net/rds/send.c:1204
>  sock_sendmsg_nosec net/socket.c:636 [inline]
>  sock_sendmsg+0xca/0x110 net/socket.c:646
>  ___sys_sendmsg+0x75b/0x8a0 net/socket.c:2026
>  __sys_sendmsg+0xe5/0x210 net/socket.c:2060
>  SYSC_sendmsg net/socket.c:2071 [inline]
>  SyS_sendmsg+0x2d/0x50 net/socket.c:2067
>  entry_SYSCALL_64_fastpath+0x1f/0x96
> RIP: 0033:0x43fe49
> RSP: 002b:00007fffab075338 EFLAGS: 00000217 ORIG_RAX: 000000000000002e
> RAX: ffffffffffffffda RBX: 00000000004002c8 RCX: 000000000043fe49
> RDX: 0000000000000000 RSI: 0000000020159fc8 RDI: 0000000000000003
> RBP: 00000000006ca018 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000217 R12: 00000000004017b0
> R13: 0000000000401840 R14: 0000000000000000 R15: 0000000000000000
> Code: f2 f2 f2 c7 40 14 00 f2 f2 f2 c7 40 18 f2 f2 f2 f2 c7 40 1c 00 f2 f2
> f2 c7 40 20 f3 f3 f3 f3 e8 43 29 db ff 4c 89 f8 48 c1 e8 03 <42> 80 3c 30 00
> 0f 85 41 04 00 00 4d 8d b5 00 ff ff ff 48 ba 00
> RIP: __read_once_size include/linux/compiler.h:183 [inline] RSP:
> ffff8801c5177320
> RIP: compound_head include/linux/page-flags.h:147 [inline] RSP:
> ffff8801c5177320
> RIP: page_mapping+0xa4/0x530 mm/util.c:475 RSP: ffff8801c5177320
> ---[ end trace f878597b0d0664a0 ]---
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

Crash is no longer occurring, was fixed by commit 7d11f77f84b27:

#syz fix: RDS: null pointer dereference in rds_atomic_free_op

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
