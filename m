Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 61EEA6B0006
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 02:03:08 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id o2so2826599pls.10
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 23:03:08 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f23sor68823pgv.252.2018.01.31.23.03.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jan 2018 23:03:05 -0800 (PST)
Date: Wed, 31 Jan 2018 23:03:02 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 page_mapping
Message-ID: <20180201070302.GB657@zzz.localdomain>
References: <94eb2c19e75677d86905608ac491@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <94eb2c19e75677d86905608ac491@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <bot+9b5ecb4a6fd2a3901e163e5dc383fc385c12a5ec@syzkaller.appspotmail.com>
Cc: akpm@linux-foundation.org, dhowells@redhat.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, mingo@kernel.org, rppt@linux.vnet.ibm.com, syzkaller-bugs@googlegroups.com, vbabka@suse.cz, simo.ghannam@gmail.com

On Sun, Dec 17, 2017 at 07:20:01AM -0800, syzbot wrote:
> Hello,
> 
> syzkaller hit the following crash on
> 41d8c16909ebda40f7b4982a7f5e2ad102705ade
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> C reproducer is attached
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers
> 
> 
> audit: type=1400 audit(1513163900.780:7): avc:  denied  { map } for
> pid=3115 comm="syzkaller713832" path="/root/syzkaller713832919" dev="sda1"
> ino=16481 scontext=unconfined_u:system_r:insmod_t:s0-s0:c0.c1023
> tcontext=unconfined_u:object_r:user_home_t:s0 tclass=file permissive=1
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000020
> IP: __read_once_size include/linux/compiler.h:183 [inline]
> IP: compound_head include/linux/page-flags.h:147 [inline]
> IP: page_mapping+0x13/0x130 mm/util.c:475
> PGD 214186067 P4D 214186067 PUD 213479067 PMD 0
> Oops: 0000 [#1] SMP
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 1 PID: 3115 Comm: syzkaller713832 Not tainted 4.15.0-rc3-next-20171213+
> #66
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> RIP: 0010:__read_once_size include/linux/compiler.h:183 [inline]
> RIP: 0010:compound_head include/linux/page-flags.h:147 [inline]
> RIP: 0010:page_mapping+0x13/0x130 mm/util.c:475
> RSP: 0018:ffffc900017abb98 EFLAGS: 00010293
> RAX: ffff880213652240 RBX: 0000000000000000 RCX: ffffffff81377f83
> RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000000
> RBP: ffffc900017abbb8 R08: 0000000000000000 R09: ffff8802164af250
> R10: 0000000000000000 R11: 0000000000000000 R12: ffff8802164af180
> R13: ffff8802164af000 R14: ffff88020db7b7c0 R15: ffff880213404730
> FS:  00000000021c7880(0000) GS:ffff88021fd00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000000020 CR3: 000000021364f000 CR4: 00000000001406e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Call Trace:
>  set_page_dirty+0x1b/0x150 mm/page-writeback.c:2544
>  rds_atomic_free_op+0x25/0x80 net/rds/rdma.c:481
>  rds_message_purge net/rds/message.c:79 [inline]
>  rds_message_put+0x174/0x1b0 net/rds/message.c:91
>  rds_sendmsg+0x7ac/0xcb0 net/rds/send.c:1204
>  sock_sendmsg_nosec net/socket.c:636 [inline]
>  sock_sendmsg+0x51/0x70 net/socket.c:646
>  ___sys_sendmsg+0x35e/0x3b0 net/socket.c:2026
>  __sys_sendmsg+0x50/0x90 net/socket.c:2060
>  SYSC_sendmsg net/socket.c:2071 [inline]
>  SyS_sendmsg+0x2d/0x50 net/socket.c:2067
>  entry_SYSCALL_64_fastpath+0x1f/0x96
> RIP: 0033:0x4400a9
> RSP: 002b:00007fff97b55488 EFLAGS: 00000217 ORIG_RAX: 000000000000002e
> RAX: ffffffffffffffda RBX: 00000000004002c8 RCX: 00000000004400a9
> RDX: 0000000000000040 RSI: 000000002048cfe4 RDI: 0000000000000003
> RBP: 00000000006ca018 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000217 R12: 0000000000401a10
> R13: 0000000000401aa0 R14: 0000000000000000 R15: 0000000000000000
> Code: 14 24 f4 ff 48 c7 c7 c8 57 a4 82 e8 46 01 24 01 0f 1f 84 00 00 00 00
> 00 55 48 89 e5 41 56 41 55 41 54 53 48 89 fb e8 ed 23 f4 ff <4c> 8b 63 20 41
> f6 c4 01 0f 85 c8 00 00 00 e8 da 23 f4 ff 4c 8b
> RIP: __read_once_size include/linux/compiler.h:183 [inline] RSP:
> ffffc900017abb98
> RIP: compound_head include/linux/page-flags.h:147 [inline] RSP:
> ffffc900017abb98
> RIP: page_mapping+0x13/0x130 mm/util.c:475 RSP: ffffc900017abb98
> CR2: 0000000000000020
> ---[ end trace 35e760b7322fed80 ]---
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
