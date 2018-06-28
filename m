Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0E6076B0007
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 01:04:46 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id d6-v6so2452123plo.15
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 22:04:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z184-v6sor1418060pgd.370.2018.06.27.22.04.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Jun 2018 22:04:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180627172313.69bf3803871630aa2d8e8dd0@linux-foundation.org>
References: <bug-200271-27@https.bugzilla.kernel.org/> <20180627172313.69bf3803871630aa2d8e8dd0@linux-foundation.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 28 Jun 2018 07:04:21 +0200
Message-ID: <CACT4Y+bOriF-ELXMLr30ndNU8Jb=gpcoo2LO1S4s1u3hCstcxA@mail.gmail.com>
Subject: Re: [Bug 200271] New: BUG: unable to handle kernel paging request at fffff1e034000208
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: air icy <icytxw@gmail.com>, bugzilla-daemon@bugzilla.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Linux-MM <linux-mm@kvack.org>

On Thu, Jun 28, 2018 at 2:23 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> Thanks.  It might be a KASAN issue.  If nobody can spot the bug in the
> next few days, we may ask you to perform a bisection search to identify
> the faulty commit.

I've replied to this here:
https://groups.google.com/forum/#!topic/kasan-dev/pGbuCnsTPjQ

/dev/sg has history of badly corrupting memory.


> On Mon, 25 Jun 2018 13:51:37 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> https://bugzilla.kernel.org/show_bug.cgi?id=200271
>>
>>             Bug ID: 200271
>>            Summary: BUG: unable to handle kernel paging request at
>>                     fffff1e034000208
>>            Product: Memory Management
>>            Version: 2.5
>>     Kernel Version: v4.18-rc2
>>           Hardware: All
>>                 OS: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Page Allocator
>>           Assignee: akpm@linux-foundation.org
>>           Reporter: icytxw@gmail.com
>>         Regression: No
>>
>> Hi,
>> In linux kernel v4.18-rc2 exists a paging request error.
>>
>> BUG: unable to handle kernel paging request at fffff1e034000208
>> PGD 0 P4D 0
>> Oops: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
>> CPU: 0 PID: 2708 Comm: sshd Not tainted 4.18.0-rc1 #2
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
>> rel-1.10.2-0-g5f4c7b1-prebuilt.qemu-project.org 04/01/2014
>> RIP: 0010:__read_once_size include/linux/compiler.h:188 [inline]
>> RIP: 0010:compound_head include/linux/page-flags.h:142 [inline]
>> RIP: 0010:virt_to_head_page include/linux/mm.h:640 [inline]
>> RIP: 0010:qlink_to_cache mm/kasan/quarantine.c:127 [inline]
>> RIP: 0010:qlist_free_all+0xb1/0x190 mm/kasan/quarantine.c:163
>> Code: 75 bf b9 00 00 00 80 4c 89 fa 48 01 c1 48 0f 42 15 f4 68 2a 03 48 01 ca
>> 48 c1 ea 0c 48 c1 e2 06 4e 8d 2c 32 49 83 fd f8 74 71 <49> 8b 4d 08 48 8d 71 ff
>> 83 e1 01 4c 0f 45 ee 4d 85 ed 74 45 49 8b
>> RSP: 0018:ffff8800692f7570 EFLAGS: 00010293
>> RAX: 0001800d0000800d RBX: 0000000000000000 RCX: 0001800d8000800d
>> RDX: 000007e034000200 RSI: ffffea00019b11c0 RDI: ffff8800695ffb40
>> RBP: ffff8800692f75a8 R08: 0000000080170010 R09: ffffffff8176d6dd
>> R10: ffff8800692f7520 R11: fffffbfff0941800 R12: ffff8800692f75c0
>> R13: fffff1e034000200 R14: ffffea0000000000 R15: 000077ff80000000
>> FS:  00007fa739b147c0(0000) GS:ffff88006c800000(0000) knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> CR2: fffff1e034000208 CR3: 0000000068a74000 CR4: 00000000000006f0
>> Call Trace:
>>  quarantine_reduce+0x1e4/0x290 mm/kasan/quarantine.c:259
>>  kasan_kmalloc+0xca/0xe0 mm/kasan/kasan.c:538
>>  kasan_slab_alloc+0x11/0x20 mm/kasan/kasan.c:490
>>  slab_post_alloc_hook mm/slab.h:444 [inline]
>>  slab_alloc_node mm/slub.c:2708 [inline]
>>  kmem_cache_alloc_node+0x163/0x360 mm/slub.c:2744
>>  __alloc_skb+0xe5/0x6d0 net/core/skbuff.c:193
>>  alloc_skb_fclone include/linux/skbuff.h:1029 [inline]
>>  sk_stream_alloc_skb+0x13d/0x890 net/ipv4/tcp.c:864
>>  tcp_sendmsg_locked+0x12c0/0x3ce0 net/ipv4/tcp.c:1279
>>  tcp_sendmsg+0x34/0x50 net/ipv4/tcp.c:1436
>>  inet_sendmsg+0x103/0x490 net/ipv4/af_inet.c:798
>>  sock_sendmsg_nosec net/socket.c:645 [inline]
>>  sock_sendmsg+0xf9/0x180 net/socket.c:655
>>  sock_write_iter+0x254/0x4a0 net/socket.c:924
>>  call_write_iter include/linux/fs.h:1795 [inline]
>>  new_sync_write fs/read_write.c:474 [inline]
>>  __vfs_write+0x405/0x820 fs/read_write.c:487
>>  vfs_write+0x1aa/0x630 fs/read_write.c:549
>>  ksys_write+0xde/0x1c0 fs/read_write.c:598
>>  __do_sys_write fs/read_write.c:610 [inline]
>>  __se_sys_write fs/read_write.c:607 [inline]
>>  __x64_sys_write+0x81/0xd0 fs/read_write.c:607
>>  do_syscall_64+0xb8/0x3a0 arch/x86/entry/common.c:290
>>  entry_SYSCALL_64_after_hwframe+0x49/0xbe
>> RIP: 0033:0x7fa737eae370
>> Code: 73 01 c3 48 8b 0d c8 4a 2b 00 31 d2 48 29 c2 64 89 11 48 83 c8 ff eb ea
>> 90 90 83 3d 85 a2 2b 00 00 75 10 b8 01 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 31
>> c3 48 83 ec 08 e8 0e 8a 01 00 48 89 04 24
>> RSP: 002b:00007fffd34e67e8 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
>> RAX: ffffffffffffffda RBX: 0000000000004028 RCX: 00007fa737eae370
>> RDX: 0000000000004028 RSI: 000055ac329d4ea0 RDI: 0000000000000003
>> RBP: 000055ac329d4ea0 R08: 0000000000000001 R09: 0101010101010101
>> R10: 0000000000000008 R11: 0000000000000246 R12: 00007fffd34e684c
>> R13: 000055ac321a8fb4 R14: 0000000000000028 R15: 000055ac321aaca0
>> Modules linked in:
>> Dumping ftrace buffer:
>>    (ftrace buffer empty)
>> CR2: fffff1e034000208
>> ---[ end trace 3fb4ab829d4ae198 ]---
>> RIP: 0010:__read_once_size include/linux/compiler.h:188 [inline]
>> RIP: 0010:compound_head include/linux/page-flags.h:142 [inline]
>> RIP: 0010:virt_to_head_page include/linux/mm.h:640 [inline]
>> RIP: 0010:qlink_to_cache mm/kasan/quarantine.c:127 [inline]
>> RIP: 0010:qlist_free_all+0xb1/0x190 mm/kasan/quarantine.c:163
>> Code: 75 bf b9 00 00 00 80 4c 89 fa 48 01 c1 48 0f 42 15 f4 68 2a 03 48 01 ca
>> 48 c1 ea 0c 48 c1 e2 06 4e 8d 2c 32 49 83 fd f8 74 71 <49> 8b 4d 08 48 8d 71 ff
>> 83 e1 01 4c 0f 45 ee 4d 85 ed 74 45 49 8b
>> RSP: 0018:ffff8800692f7570 EFLAGS: 00010293
>> RAX: 0001800d0000800d RBX: 0000000000000000 RCX: 0001800d8000800d
>> RDX: 000007e034000200 RSI: ffffea00019b11c0 RDI: ffff8800695ffb40
>> RBP: ffff8800692f75a8 R08: 0000000080170010 R09: ffffffff8176d6dd
>> R10: ffff8800692f7520 R11: fffffbfff0941800 R12: ffff8800692f75c0
>> R13: fffff1e034000200 R14: ffffea0000000000 R15: 000077ff80000000
>> FS:  00007fa739b147c0(0000) GS:ffff88006c800000(0000) knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> CR2: fffff1e034000208 CR3: 0000000068a74000 CR4: 00000000000006f0
>>
>> --
>> You are receiving this mail because:
>> You are the assignee for the bug.
