Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id EEBE66B025C
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 14:23:55 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l126so8287295wml.1
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 11:23:55 -0800 (PST)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id fd18si3965850wjc.165.2015.12.15.11.23.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 11:23:54 -0800 (PST)
Received: by mail-wm0-x233.google.com with SMTP id n186so110167807wmn.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 11:23:54 -0800 (PST)
MIME-Version: 1.0
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 15 Dec 2015 20:23:34 +0100
Message-ID: <CACT4Y+YpcpqhyCiSZYoCzWTVKCmKMBTX-kSdeEBOjoQFQMs77g@mail.gmail.com>
Subject: BUG_ON(!PageLocked(page)) in munlock_vma_page/migrate_pages/__block_write_begin
Content-Type: multipart/mixed; boundary=001a113d812ef61a130526f4ba48
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Eric B Munson <emunson@akamai.com>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Jeff Vander Stoep <jeffv@google.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>
Cc: syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Eric Dumazet <edumazet@google.com>

--001a113d812ef61a130526f4ba48
Content-Type: text/plain; charset=UTF-8

Hello,

I am seeing lots of similar BUGs in different functions all pointing
to BUG_ON(!PageLocked(page)). I reproduced them on several recent
commits, including stock 6764e5ebd5c62236d082f9ae030674467d0b2779 (Dec
9) with no changes on top and no KASAN/etc.

------------[ cut here ]------------
kernel BUG at fs/buffer.c:1917!
invalid opcode: 0000 [#1] SMP
Modules linked in:
CPU: 3 PID: 17243 Comm: executor Not tainted 4.4.0-rc4+ #53
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff8800347ac380 ti: ffff880033510000 task.ti: ffff880033510000
RIP: 0010:[<ffffffff8125cae0>]  [
<ffffffff8125cae0>][<      none      >]
__block_write_begin+0x450/0x480 fs/buffer.c:1919
RSP: 0018:ffff880033513be8  EFLAGS: 00010246
RAX: 01fffc000000086c RBX: ffffea0000c57340 RCX: ffffffff812eb890
RDX: 0000000000001000 RSI: 0000000000000000 RDI: ffffea0000c57340
RBP: ffff880033513c90 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000001000
R13: 00000000fffffff2 R14: ffffffff812eb890 R15: ffff8800721ca4a0
FS:  000000000254f880(0063) GS:ffff88007fd00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00000000007100b8 CR3: 0000000034b22000 CR4: 00000000000006e0
Stack:
 ffff88003ff6aeb8 ffff880033513c68 0000000000000002 ffff880033513c40
 ffffffff823f976e ffffea0000c57340 ffffea0000c57340 ffff8800721ca2b0
 ffffffff812eb890 ffff8800721ca2b0 ffff8800721ca4a0 ffff880033513c90
Call Trace:
 [<ffffffff8125cf3a>] block_page_mkwrite+0x9a/0xd0 fs/buffer.c:2449
 [<ffffffff812f3960>] ext4_page_mkwrite+0x270/0x400 fs/ext4/inode.c:5286
 [<ffffffff811da8e0>] do_page_mkwrite+0x40/0x80 mm/memory.c:1970
 [<     inline     >] wp_page_shared mm/memory.c:2240
 [<ffffffff811dcc36>] do_wp_page+0x356/0x4e0 mm/memory.c:2344
 [<     inline     >] handle_pte_fault mm/memory.c:3311
 [<     inline     >] __handle_mm_fault mm/memory.c:3413
 [<ffffffff811de9e0>] handle_mm_fault+0xd70/0x1a70 mm/memory.c:3442
 [<ffffffff810a647a>] __do_page_fault+0x18a/0x410 arch/x86/mm/fault.c:1238
 [<ffffffff810a6773>] trace_do_page_fault+0x43/0xd0 arch/x86/mm/fault.c:1331
 [<ffffffff810a1494>] do_async_page_fault+0x14/0x80 arch/x86/kernel/kvm.c:264
 [<ffffffff82400778>] async_page_fault+0x28/0x30 arch/x86/entry/entry_64.S:988
Code: b4 44 8b 4d b0 4c 8b 55 a8 e9 3b fd ff ff 8b 55 bc 8b 75 b8 48
8b 7d 80 e8 5e ef ff ff e9 dc fe ff ff 0f 0b e8 de 08 41 00 0f 0b <0f>
0b be 0f 00 00 00 48 c7 c7 41 c4 95 82 4c 89 55 a8 44 89 4d
RIP  [<ffffffff8125cae0>] __block_write_begin+0x450/0x480 fs/buffer.c:1919
 RSP <ffff880033513be8>
---[ end trace c0d117b74b7a2ba6 ]---


------------[ cut here ]------------
kernel BUG at include/linux/swapops.h:106!
invalid opcode: 0000 [#1] SMP KASAN
Modules linked in:
CPU: 2 PID: 10089 Comm: syzkaller_execu Tainted: G        W
4.4.0-rc4+ #161
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff880037715e00 ti: ffff8800006a0000 task.ti: ffff8800006a0000
RIP: 0010:[<ffffffff816874db>]  [<ffffffff816874db>]
try_to_unmap_one+0x74b/0x960
RSP: 0018:ffff8800006a6fb0  EFLAGS: 00010212
RAX: ffff880037715e00 RBX: ffff88005a650000 RCX: ffffc900048f6000
RDX: 0000000000003fff RSI: 0000000000004000 RDI: ffff88005a650130
RBP: ffff8800006a7078 R08: 0000000000000001 R09: 0000000000000000
R10: ffffed000fffec13 R11: 0000000000000000 R12: 0000000000000002
R13: 0000000000000002 R14: 80000000424ad007 R15: 0000000000000018
FS:  00007f84b59d1700(0000) GS:ffff88006da00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000020797ff8 CR3: 000000000fb77000 CR4: 00000000000006e0
Stack:
 0000000000000000 ffff880000000000 0000000000000212 ffff880046dc4780
 0000000000000001 1ffff100000d4dfe 00000000006f0000 ffffea0001092b40
 0000000041b58ab3 ffffffff86a6af3b ffffffff81686d90 ffffffff81653e38
Call Trace:
 [<     inline     >] rmap_walk_anon mm/rmap.c:1600
 [<ffffffff81689a9e>] rmap_walk+0x54e/0xa10 mm/rmap.c:1668
 [<ffffffff8168a599>] try_to_unmap+0xd9/0x180 mm/rmap.c:1495
 [<     inline     >] __unmap_and_move mm/migrate.c:890
 [<     inline     >] unmap_and_move mm/migrate.c:950
 [<ffffffff816d8220>] migrate_pages+0xcc0/0x25b0 mm/migrate.c:1149
 [<ffffffff8165090e>] compact_zone+0xe2e/0x2180 mm/compaction.c:1411
 [<ffffffff81651d4a>] compact_zone_order+0xea/0x160 mm/compaction.c:1504
 [<ffffffff81652793>] try_to_compact_pages+0x323/0xa60 mm/compaction.c:1555
 [<ffffffff815f85ff>] __alloc_pages_direct_compact+0x7f/0x280
mm/page_alloc.c:2765
 [<     inline     >] __alloc_pages_slowpath mm/page_alloc.c:3076
 [<ffffffff815f9320>] __alloc_pages_nodemask+0xb20/0x15f0 mm/page_alloc.c:3235
 [<     inline     >] __alloc_pages include/linux/gfp.h:415
 [<     inline     >] __alloc_pages_node include/linux/gfp.h:428
 [<ffffffff816beb3f>] alloc_pages_vma+0x49f/0x600 mm/mempolicy.c:2001
 [<ffffffff816e6a1a>] do_huge_pmd_wp_page+0x9ba/0x1ab0 mm/huge_memory.c:1189
 [<     inline     >] wp_huge_pmd mm/memory.c:3250
 [<     inline     >] __handle_mm_fault mm/memory.c:3382
 [<ffffffff816684f4>] handle_mm_fault+0x2b44/0x3a30 mm/memory.c:3442
 [<ffffffff8121d786>] __do_page_fault+0x376/0x8d0 arch/x86/mm/fault.c:1238
 [<ffffffff8121ddc3>] trace_do_page_fault+0xb3/0x3d0 arch/x86/mm/fault.c:1331
 [<ffffffff81210c94>] do_async_page_fault+0x14/0x70 arch/x86/kernel/kvm.c:264
 [<ffffffff85b694f8>] async_page_fault+0x28/0x30 arch/x86/entry/entry_64.S:988
 [<ffffffff85b673f6>] entry_SYSCALL_64_fastpath+0x16/0x7a
arch/x86/entry/entry_64.S:185
Code: fc e7 ff f0 48 ff 8b 48 03 00 00 f0 48 ff 83 50 03 00 00 4c 89
e1 48 c1 e9 39 48 8d 14 09 4c 89 e1 e9 2d fd ff ff e8 a5 fc e7 ff <0f>
0b e8 9e fc e7 ff 48 89 df 48 8b b5 68 ff ff ff 48 8b 95 50
RIP  [<     inline     >] make_migration_entry include/linux/swapops.h:106
RIP  [<ffffffff816874db>] try_to_unmap_one+0x74b/0x960 mm/rmap.c:1390
 RSP <ffff8800006a6fb0>
---[ end trace 4641abb232e75cf4 ]---


------------[ cut here ]------------
kernel BUG at mm/mlock.c:179!
invalid opcode: 0000 [#1] SMP KASAN
Modules linked in:
CPU: 3 PID: 13580 Comm: syzkaller_execu Tainted: G        W
4.4.0-rc4+ #161
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff88003d825e00 ti: ffff88003ab88000 task.ti: ffff88003ab88000
RIP: 0010:[<ffffffff8166fb84>]  [<ffffffff8166fb84>]
munlock_vma_page+0x1c4/0x200
RSP: 0018:ffff88003ab8f4a8  EFLAGS: 00010297
RAX: ffffffff8166fb84 RBX: ffffea00017d0840 RCX: ffffc900070a6000
RDX: 0000000000000720 RSI: 0000000000000721 RDI: 000000000000001f
RBP: ffff88003ab8f4d8 R08: 0000000000000001 R09: 0000000000000001
R10: ffffed000fffec1b R11: 0000000000000000 R12: 00000000000007c0
R13: ffff88007fff7000 R14: ffff88006ad38d48 R15: ffff880031018010
FS:  00007fa3ef2d9700(0000) GS:ffff88006db00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000020002006 CR3: 00000000380b9000 CR4: 00000000000006e0
Stack:
 00000000000007c0 ffff88006ad38cf8 ffffea00017d0840 0000000000000001
 ffff88006ad38d48 ffff880031018010 ffff88003ab8f5c0 ffffffff8166010e
 0000000020003000 ffff880036e098c0 ffff88002f22cbe8 80000000635c0067
Call Trace:
 [<ffffffff8166010e>] wp_page_copy.isra.56+0x93e/0xe60 mm/memory.c:2171
 [<ffffffff81663eaf>] do_wp_page+0x17f/0xf20 mm/memory.c:2354
 [<     inline     >] handle_pte_fault mm/memory.c:3311
 [<     inline     >] __handle_mm_fault mm/memory.c:3413
 [<ffffffff81667716>] handle_mm_fault+0x1d66/0x3a30 mm/memory.c:3442
 [<ffffffff8121d786>] __do_page_fault+0x376/0x8d0 arch/x86/mm/fault.c:1238
 [<ffffffff8121ddc3>] trace_do_page_fault+0xb3/0x3d0 arch/x86/mm/fault.c:1331
 [<ffffffff81210c94>] do_async_page_fault+0x14/0x70 arch/x86/kernel/kvm.c:264
 [<ffffffff85b694f8>] async_page_fault+0x28/0x30 arch/x86/entry/entry_64.S:988
 [<     inline     >] SYSC_poll fs/select.c:969
 [<ffffffff817532bc>] SyS_poll+0xbc/0x3f0 fs/select.c:957
 [<ffffffff85b673f6>] entry_SYSCALL_64_fastpath+0x16/0x7a
arch/x86/entry/entry_64.S:185
Code: 48 89 df e8 ff f3 ff ff 84 c0 74 ba e8 16 76 e9 ff 4c 89 ff e8
ee 6d 4f 04 48 89 df e8 b6 f2 ff ff e9 50 ff ff ff e8 fc 75 e9 ff <0f>
0b 48 89 df e8 12 ef 05 00 eb 88 e8 0b ef 05 00 e9 87 fe ff
RIP  [<ffffffff8166fb84>] munlock_vma_page+0x1c4/0x200 mm/mlock.c:179
 RSP <ffff88003ab8f4a8>
---[ end trace 76823d12a049bf21 ]---


Unfortunately I cannot reproduce it without syzkaller fuzzer. Here are
repro instructions using syzkaller infrastructure (you need Go1.5
toolchain installed and GOPATH env var setup):

$ go get github.com/google/syzkaller/tools/execprog
$ cd $GOPATH/src/github.com/google/syzkaller
$ make executor
Then copy $GOPATH/bin/execprog,
$GOPATH/src/github.com/google/syzkaller/bin/executor and the attached
file into the test machine. Run the following command inside of the
test machine:
$ ./execprog -executor ./executor -loop -procs 16 -cover=0 pagelocked

It may require a hour or so to reproduce.

Syzkaller's execprog will do something along the following lines (to
give you idea of what's stressed): create a bunch of threads; mmap 2
shared files per test process (32 in this case); spawn 16
subprocesses; these subprocess will spawn another subproccess; these
subprocesses will execute syscalls listed in the attached file in
different threads in somewhat chaotic order. I've tried to reproduce
it all in the attached mlocked.c file, but it did not trigger the BUGs
for me.

--001a113d812ef61a130526f4ba48
Content-Type: application/octet-stream; name=pagelocked
Content-Disposition: attachment; filename=pagelocked
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ii7roqic0

bW1hcCgmKDB4N2YwMDAwMDAwMDAwKT1uaWwsICgweDEwMDApLCAweDMsIDB4MzIsIDB4ZmZmZmZm
ZmZmZmZmZmZmZiwgMHgwKQptbWFwKCYoMHg3ZjAwMDAwMDAwMDApPW5pbCwgKDB4MTAwMCksIDB4
MywgMHgzMiwgMHhmZmZmZmZmZmZmZmZmZmZmLCAweDApCm1tYXAoJigweDdmMDAwMDAwMDAwMCk9
bmlsLCAoMHgxMDAwKSwgMHgzLCAweDMyLCAweGZmZmZmZmZmZmZmZmZmZmYsIDB4MCkKbXN5bmMo
JigweDdmMDAwMGMwZjAwMCk9bmlsLCAoMHg0MDAwKSwgMHgxKQpyMSA9IGdldHRpZCgpCm1tYXAo
JigweDdmMDAwMDAwMTAwMCk9bmlsLCAoMHgxMDAwKSwgMHgzLCAweDMyLCAweGZmZmZmZmZmZmZm
ZmZmZmYsIDB4MCkKc2NoZWRfc2V0YXR0cihyMSwgJigweDdmMDAwMDAwMjAwMC0weDMwKT17MHgz
MCwgMHgwLCAweDEsIDB4MiwgMHgyLCAweDcsIDB4MSwgMHg5fSwgMHgwKQptbWFwKCYoMHg3ZjAw
MDAwMDIwMDApPW5pbCwgKDB4MTAwMCksIDB4MywgMHgzMiwgMHhmZmZmZmZmZmZmZmZmZmZmLCAw
eDApCm1tYXAoJigweDdmMDAwMDAwMjAwMCk9bmlsLCAoMHgxMDAwKSwgMHgzLCAweDMyLCAweGZm
ZmZmZmZmZmZmZmZmZmYsIDB4MCkKbW1hcCgmKDB4N2YwMDAwMDAyMDAwKT1uaWwsICgweDEwMDAp
LCAweDMsIDB4MzIsIDB4ZmZmZmZmZmZmZmZmZmZmZiwgMHgwKQptbWFwKCYoMHg3ZjAwMDAwMDIw
MDApPW5pbCwgKDB4MTAwMCksIDB4MywgMHgzMiwgMHhmZmZmZmZmZmZmZmZmZmZmLCAweDApCnN5
bmMoKQptbWFwKCYoMHg3ZjAwMDAwMDMwMDApPW5pbCwgKDB4MTAwMCksIDB4MywgMHgzMiwgMHhm
ZmZmZmZmZmZmZmZmZmZmLCAweDApCnNobWdldCgweGZmZmZmZmZmZmZmZmY3MjcsICgweDEwMDAp
LCAweDgwLCAmKDB4N2YwMDAwMDAxMDAwKT1uaWwpCnRraWxsKHIxLCAweDQpCm1tYXAoJigweDdm
MDAwMDAwNDAwMCk9bmlsLCAoMHgxMDAwKSwgMHgzLCAweDMyLCAweGZmZmZmZmZmZmZmZmZmZmYs
IDB4MCkKcjMgPSBvcGVuYXQoMHgxODY5ZiwgJigweDdmMDAwMDAwNDAwMCk9IjJlMmY2NjY5NmM2
NTMwMDAiLCAweDAsIDB4MTQwKQptbWFwKCYoMHg3ZjAwMDAwMDQwMDApPW5pbCwgKDB4MTAwMCks
IDB4MywgMHgzMiwgMHhmZmZmZmZmZmZmZmZmZmZmLCAweDApCm1tYXAoJigweDdmMDAwMDAwNDAw
MCk9bmlsLCAoMHgxMDAwKSwgMHgzLCAweDMyLCAweGZmZmZmZmZmZmZmZmZmZmYsIDB4MCkKbW1h
cCgmKDB4N2YwMDAwMDA0MDAwKT1uaWwsICgweDEwMDApLCAweDMsIDB4MzIsIDB4ZmZmZmZmZmZm
ZmZmZmZmZiwgMHgwKQptbWFwKCYoMHg3ZjAwMDAwMDUwMDApPW5pbCwgKDB4MTAwMCksIDB4Mywg
MHgzMiwgMHhmZmZmZmZmZmZmZmZmZmZmLCAweDApCm1tYXAoJigweDdmMDAwMDAwNTAwMCk9bmls
LCAoMHgxMDAwKSwgMHgzLCAweDMyLCAweGZmZmZmZmZmZmZmZmZmZmYsIDB4MCkKLS0tCm1tYXAo
JigweDdmMDAwMDAwMDAwMCk9bmlsLCAoMHgxMDAwKSwgMHgzLCAweDMyLCAweGZmZmZmZmZmZmZm
ZmZmZmYsIDB4MCkKbW1hcCgmKDB4N2YwMDAwMDAwMDAwKT1uaWwsICgweDEwMDApLCAweDMsIDB4
MzIsIDB4ZmZmZmZmZmZmZmZmZmZmZiwgMHgwKQptbWFwKCYoMHg3ZjAwMDAwMDAwMDApPW5pbCwg
KDB4MTAwMCksIDB4MywgMHgzMiwgMHhmZmZmZmZmZmZmZmZmZmZmLCAweDApCnIwID0gYWRkX2tl
eSgmKDB4N2YwMDAwMDAwMDAwKzB4NTlmKT0iNzM3OTczNzQ2NTZkNzQ3Mjc1NzM3NDY1NjQwMCIs
ICYoMHg3ZjAwMDAwMDEwMDAtMHgyOCk9IjZkNjk2ZDY1NWY3NDc5NzA2NTcwNzI2ZjYzNzM2NTZj
Njk2ZTc1NzgyZDVjMmFjNzZkNjk2ZDY1NWY3NDc5NzA2NTJlMmY2NTc0NjgzMTAwIiwgJigweDdm
MDAwMDAwMDAwMCsweDYyNCk9IjEwMjI4YzVjNmNjODA0MjY0N2ExNDFkMTVhM2U0ZTg0ZGQzOTVk
NTcwOTFkNjEwZTUxZWEzMWNkY2Y2ODkxNDc2NmJhMmQ5YzIzNTIyNjUyODY3ODI5MzlhOGFhOTUw
MmJkMjkxOWQ2Yzg3NjZhMzA0Yzc3NzUyZDkxOTg3NzE5MjkwM2U0ZjQ0OTY4ZGVmODIyOGNlY2Mz
M2Y5MjNjNDY0MWJhNmM2NDUyMWU3NjRkNzE3ZGQyNmM5YTE3ODUyYTE0Y2EzNTY1YWQzMjgxMTZi
MWZhMzg5NGNlNDE0YjA5ZmUwM2JmOWY2MGNjNzY5NzVkN2FkNjY2M2VjYjAzNGM1OGEzYzJjNWI2
NmZhMmIzNzA0ZTBiNjcyMmZkYTliYTQyZjdiNTBjZGIyMmQxMjAiLCAweDk4LCAweGRlMzM3YTFj
YjRjZjg0OWQpCm1zeW5jKCYoMHg3ZjAwMDBjMGYwMDApPW5pbCwgKDB4NDAwMCksIDB4MSkKcjEg
PSBnZXR0aWQoKQptbWFwKCYoMHg3ZjAwMDAwMDEwMDApPW5pbCwgKDB4MTAwMCksIDB4MywgMHgz
MiwgMHhmZmZmZmZmZmZmZmZmZmZmLCAweDApCnNjaGVkX3NldGF0dHIocjEsICYoMHg3ZjAwMDAw
MDIwMDAtMHgzMCk9ezB4MzAsIDB4MCwgMHgxLCAweDIsIDB4MiwgMHg3LCAweDEsIDB4OX0sIDB4
MCkKa2V5Y3RsJHNldF90aW1lb3V0KDB4ZiwgcjAsIDB4NCkKbW1hcCgmKDB4N2YwMDAwMDAyMDAw
KT1uaWwsICgweDEwMDApLCAweDMsIDB4MzIsIDB4ZmZmZmZmZmZmZmZmZmZmZiwgMHgwKQptbWFw
KCYoMHg3ZjAwMDAwMDIwMDApPW5pbCwgKDB4MTAwMCksIDB4MywgMHgzMiwgMHhmZmZmZmZmZmZm
ZmZmZmZmLCAweDApCnIyID0gYWNjZXB0KDB4ZmZmZmZmZmZmZmZmZmZmZiwgJigweDdmMDAwMDAw
MjAwMCk9bmlsLCAmKDB4N2YwMDAwMDAyMDAwKzB4MTU5KT1uaWwpCm1tYXAoJigweDdmMDAwMDAw
MjAwMCk9bmlsLCAoMHgxMDAwKSwgMHgzLCAweDMyLCAweGZmZmZmZmZmZmZmZmZmZmYsIDB4MCkK
bW1hcCgmKDB4N2YwMDAwMDAyMDAwKT1uaWwsICgweDEwMDApLCAweDMsIDB4MzIsIDB4ZmZmZmZm
ZmZmZmZmZmZmZiwgMHgwKQpnZXRzb2Nrb3B0JGlwX21yZXFzcmMocjIsIDB4MCwgMHgyNywgJigw
eDdmMDAwMDAwMzAwMC0weGMpPXsweDAsIDB4MCwgMHgwfSwgJigweDdmMDAwMDAwMzAwMC0weDQp
PW5pbCkKc3luYygpCnNodXRkb3duKHIyLCAweDEpCm1tYXAoJigweDdmMDAwMDAwMzAwMCk9bmls
LCAoMHgxMDAwKSwgMHgzLCAweDMyLCAweGZmZmZmZmZmZmZmZmZmZmYsIDB4MCkKc2V0c29ja29w
dCRpcF9pcHNlYyhyMiwgMHgwLCAweDEwLCAmKDB4N2YwMDAwMDAzMDAwKT17e3t7MHgwLCAweDAs
IDB4MCwgMHgxMDAwMDAwfSwgezB4MCwgMHgwLCAweDAsIDB4MTAwMDAwMH0sIDB4MCwgMHgwLCAw
eDMsIDB4NSwgMHg3LCAweDQsIDB4MCwgMHg5LCAweDIyZSwgMHg0fSwgezB4NCwgMHgzM2RiNjRi
NywgMHgxLCAweDIsIDB4OSwgMHg1MzQsIDB4MjM5NzY0MDAsIDB4NX0sIHsweGZmZmZmZmZmZmZm
ZmM5ODEsIDB4MiwgMHhjODA3LCAweDN9LCAweGM4MSwgMHg4LCAweDcsIDB4MCwgMHhmZmZmZmZm
ZmZmZmZmZmZlLCAweDB9LCB7e3sweDAsIDB4MCwgMHgwLCAweDEwMDAwMDB9LCAweDQxMiwgMHgy
fSwgMHg4LCB7MHgxMDAwMDdmLCAweDAsIDB4MCwgMHgwfSwgMHhmZmZmZmZmZmZmZmZmZmY5LCAw
eGI1LCAweDYsIDB4NTUsIDB4ZGEsIDB4OSwgMHg4fX0sIDB4ZGIpCnNobWdldCgweGZmZmZmZmZm
ZmZmZmY3MjcsICgweDEwMDApLCAweDgwLCAmKDB4N2YwMDAwMDAxMDAwKT1uaWwpCnRraWxsKHIx
LCAweDQpCmtleWN0bCRyZXZva2UoMHgzLCByMCkKbW1hcCgmKDB4N2YwMDAwMDA0MDAwKT1uaWws
ICgweDEwMDApLCAweDMsIDB4MzIsIDB4ZmZmZmZmZmZmZmZmZmZmZiwgMHgwKQpyMyA9IG9wZW5h
dCgweDE4NjlmLCAmKDB4N2YwMDAwMDA0MDAwKT0iMmUyZjY2Njk2YzY1MzAwMCIsIDB4MCwgMHgx
NDApCm1tYXAoJigweDdmMDAwMDAwNDAwMCk9bmlsLCAoMHgxMDAwKSwgMHgzLCAweDMyLCAweGZm
ZmZmZmZmZmZmZmZmZmYsIDB4MCkKbW1hcCgmKDB4N2YwMDAwMDA0MDAwKT1uaWwsICgweDEwMDAp
LCAweDMsIDB4MzIsIDB4ZmZmZmZmZmZmZmZmZmZmZiwgMHgwKQpyNCA9IG9wZW4oJigweDdmMDAw
MDAwNDAwMCsweDc1ZSk9IjJlMmY2Mjc1NzMwMCIsIDB4MTAxMDAwLCAweDUwKQptbWFwKCYoMHg3
ZjAwMDAwMDQwMDApPW5pbCwgKDB4MTAwMCksIDB4MywgMHgzMiwgMHhmZmZmZmZmZmZmZmZmZmZm
LCAweDApCmxpbmthdChyMywgJigweDdmMDAwMDAwNDAwMCk9IjJlMmY2NjY5NmM2NTMwMDAiLCBy
NCwgJigweDdmMDAwMDAwNTAwMC0weDUpPSIyZTJmNjY2OTZjNjUzMDAwIiwgMHgxMDAwKQptbWFw
KCYoMHg3ZjAwMDAwMDUwMDApPW5pbCwgKDB4MTAwMCksIDB4MywgMHgzMiwgMHhmZmZmZmZmZmZm
ZmZmZmZmLCAweDApCm1tYXAoJigweDdmMDAwMDAwNTAwMCk9bmlsLCAoMHgxMDAwKSwgMHgzLCAw
eDMyLCAweGZmZmZmZmZmZmZmZmZmZmYsIDB4MCkKY2xvY2tfbmFub3NsZWVwKDB4ODhkMjZiMzcx
ZmU2ZGFiMywgMHgxLCAmKDB4N2YwMDAwMDA1MDAwKT17MHg3NzM1OTQwMCwgMHgwfSwgJigweDdm
MDAwMDAwNjAwMC0weDEwKT17MHgwLCAweDB9KQoK
--001a113d812ef61a130526f4ba48
Content-Type: text/x-csrc; charset=US-ASCII; name="mlocked.c"
Content-Disposition: attachment; filename="mlocked.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ii7rvnd71

Ly8gYXV0b2dlbmVyYXRlZCBieSBzeXprYWxsZXIgKGh0dHA6Ly9naXRodWIuY29tL2dvb2dsZS9z
eXprYWxsZXIpCiNpbmNsdWRlIDxzeXNjYWxsLmg+CiNpbmNsdWRlIDxzdHJpbmcuaD4KI2luY2x1
ZGUgPHN0ZGludC5oPgojaW5jbHVkZSA8c3RkbGliLmg+CiNpbmNsdWRlIDxzdGRpby5oPgojaW5j
bHVkZSA8cHRocmVhZC5oPgojaW5jbHVkZSA8dW5pc3RkLmg+CiNpbmNsdWRlIDxzdGRsaWIuaD4K
I2luY2x1ZGUgPHN5cy9tbWFuLmg+CiNpbmNsdWRlIDxzeXMvdHlwZXMuaD4KI2luY2x1ZGUgPHN5
cy9zdGF0Lmg+CiNpbmNsdWRlIDxmY250bC5oPgoKbG9uZyByNiA9IC0xOwpsb25nIHI4ID0gLTE7
Cmxvbmcgcjg5ID0gLTE7CmxvbmcgcjkzID0gLTE7CgojZGVmaW5lIE5NQVAgMwojZGVmaW5lIFNJ
WkUgKDE8PDIwKQoKdm9pZCAqbWFwc1tOTUFQXTsKCnZvaWQgKnRocih2b2lkICphcmcpCnsKCXN3
aXRjaCAoKGxvbmcpYXJnKSB7CgljYXNlIDA6CgkJc3lzY2FsbChTWVNfbW1hcCwgMHgyMDAwMDAw
MHVsLCAweDEwMDB1bCwgMHgzdWwsIDB4MzJ1bCwgMHhmZmZmZmZmZmZmZmZmZmZmdWwsIDB4MHVs
KTsKCQlicmVhazsKCWNhc2UgMToKCQlzeXNjYWxsKFNZU19tbWFwLCAweDIwMDAwMDAwdWwsIDB4
MTAwMHVsLCAweDN1bCwgMHgzMnVsLCAweGZmZmZmZmZmZmZmZmZmZmZ1bCwgMHgwdWwpOwoJCWJy
ZWFrOwoJY2FzZSAyOgoJCXN5c2NhbGwoU1lTX21tYXAsIDB4MjAwMDAwMDB1bCwgMHgxMDAwdWws
IDB4M3VsLCAweDMydWwsIDB4ZmZmZmZmZmZmZmZmZmZmZnVsLCAweDB1bCk7CgkJYnJlYWs7Cglj
YXNlIDM6CgkJbWVtY3B5KCh2b2lkKikweDIwMDAwNTlmLCAiXHg3M1x4NzlceDczXHg3NFx4NjVc
eDZkXHg3NFx4NzJceDc1XHg3M1x4NzRceDY1XHg2NFx4MDAiLCAxNCk7CgkJbWVtY3B5KCh2b2lk
KikweDIwMDAwZmQ4LCAiXHg2ZFx4NjlceDZkXHg2NVx4NWZceDc0XHg3OVx4NzBceDY1XHg3MFx4
NzJceDZmXHg2M1x4NzNceDY1XHg2Y1x4NjlceDZlXHg3NVx4NzhceDJkXHg1Y1x4MmFceGM3XHg2
ZFx4NjlceDZkXHg2NVx4NWZceDc0XHg3OVx4NzBceDY1XHgyZVx4MmZceDY1XHg3NFx4NjhceDMx
XHgwMCIsIDQwKTsKCQltZW1jcHkoKHZvaWQqKTB4MjAwMDA2MjQsICJceDEwXHgyMlx4OGNceDVj
XHg2Y1x4YzhceDA0XHgyNlx4NDdceGExXHg0MVx4ZDFceDVhXHgzZVx4NGVceDg0XHhkZFx4Mzlc
eDVkXHg1N1x4MDlceDFkXHg2MVx4MGVceDUxXHhlYVx4MzFceGNkXHhjZlx4NjhceDkxXHg0N1x4
NjZceGJhXHgyZFx4OWNceDIzXHg1Mlx4MjZceDUyXHg4Nlx4NzhceDI5XHgzOVx4YThceGFhXHg5
NVx4MDJceGJkXHgyOVx4MTlceGQ2XHhjOFx4NzZceDZhXHgzMFx4NGNceDc3XHg3NVx4MmRceDkx
XHg5OFx4NzdceDE5XHgyOVx4MDNceGU0XHhmNFx4NDlceDY4XHhkZVx4ZjhceDIyXHg4Y1x4ZWNc
eGMzXHgzZlx4OTJceDNjXHg0Nlx4NDFceGJhXHg2Y1x4NjRceDUyXHgxZVx4NzZceDRkXHg3MVx4
N2RceGQyXHg2Y1x4OWFceDE3XHg4NVx4MmFceDE0XHhjYVx4MzVceDY1XHhhZFx4MzJceDgxXHgx
Nlx4YjFceGZhXHgzOFx4OTRceGNlXHg0MVx4NGJceDA5XHhmZVx4MDNceGJmXHg5Zlx4NjBceGNj
XHg3Nlx4OTdceDVkXHg3YVx4ZDZceDY2XHgzZVx4Y2JceDAzXHg0Y1x4NThceGEzXHhjMlx4YzVc
eGI2XHg2Zlx4YTJceGIzXHg3MFx4NGVceDBiXHg2N1x4MjJceGZkXHhhOVx4YmFceDQyXHhmN1x4
YjVceDBjXHhkYlx4MjJceGQxXHgyMCIsIDE1Mik7CgkJcjYgPSBzeXNjYWxsKFNZU19hZGRfa2V5
LCAweDIwMDAwNTlmdWwsIDB4MjAwMDBmZDh1bCwgMHgyMDAwMDYyNHVsLCAweDk4dWwsIDB4ZGUz
MzdhMWNiNGNmODQ5ZHVsLCAwKTsKCQlicmVhazsKCWNhc2UgNDoKCQlzeXNjYWxsKFNZU19tc3lu
YywgMHgyMGMwZjAwMHVsLCAweDQwMDB1bCwgMHgxdWwsIDAsIDAsIDApOwoJCWJyZWFrOwoJY2Fz
ZSA1OgoJCXI4ID0gc3lzY2FsbChTWVNfZ2V0dGlkLCAwLCAwLCAwLCAwLCAwLCAwKTsKCQlicmVh
azsKCWNhc2UgNjoKCQlzeXNjYWxsKFNZU19tbWFwLCAweDIwMDAxMDAwdWwsIDB4MTAwMHVsLCAw
eDN1bCwgMHgzMnVsLCAweGZmZmZmZmZmZmZmZmZmZmZ1bCwgMHgwdWwpOwoJCSoodWludDMyX3Qq
KTB4MjAwMDFmZDAgPSAweDMwOwoJCSoodWludDMyX3QqKTB4MjAwMDFmZDQgPSAweDA7CgkJKih1
aW50NjRfdCopMHgyMDAwMWZkOCA9IDB4MTsKCQkqKHVpbnQzMl90KikweDIwMDAxZmUwID0gMHgy
OwoJCSoodWludDMyX3QqKTB4MjAwMDFmZTQgPSAweDI7CgkJKih1aW50NjRfdCopMHgyMDAwMWZl
OCA9IDB4NzsKCQkqKHVpbnQ2NF90KikweDIwMDAxZmYwID0gMHgxOwoJCSoodWludDY0X3QqKTB4
MjAwMDFmZjggPSAweDk7CgkJc3lzY2FsbChTWVNfc2NoZWRfc2V0YXR0ciwgcjgsIDB4MjAwMDFm
ZDB1bCwgMHgwdWwsIDAsIDAsIDApOwoJCWJyZWFrOwoJY2FzZSA3OgoJCXN5c2NhbGwoU1lTX2tl
eWN0bCwgMHhmdWwsIHI2LCAweDR1bCwgMCwgMCwgMCk7CgkJYnJlYWs7CgljYXNlIDg6CgkJc3lz
Y2FsbChTWVNfc3luYywgMCwgMCwgMCwgMCwgMCwgMCk7CgkJYnJlYWs7CgljYXNlIDk6CgkJc3lz
Y2FsbChTWVNfbW1hcCwgMHgyMDAwMzAwMHVsLCAweDEwMDB1bCwgMHgzdWwsIDB4MzJ1bCwgMHhm
ZmZmZmZmZmZmZmZmZmZmdWwsIDB4MHVsKTsKCQlicmVhazsKCWNhc2UgMTA6CgkJc3lzY2FsbChT
WVNfc2htZ2V0LCAweGZmZmZmZmZmZmZmZmY3Mjd1bCwgMHgxMDAwdWwsIDB4ODB1bCwgMHgyMDAw
MTAwMHVsLCAwLCAwKTsKCQlicmVhazsKCWNhc2UgMTE6CgkJc3lzY2FsbChTWVNfdGtpbGwsIHI4
LCAweDR1bCwgMCwgMCwgMCwgMCk7CgkJYnJlYWs7CgljYXNlIDEyOgoJCXN5c2NhbGwoU1lTX2tl
eWN0bCwgMHgzdWwsIHI2LCAwLCAwLCAwLCAwKTsKCQlicmVhazsKCWNhc2UgMTM6CgkJc3lzY2Fs
bChTWVNfbW1hcCwgMHgyMDAwNDAwMHVsLCAweDEwMDB1bCwgMHgzdWwsIDB4MzJ1bCwgMHhmZmZm
ZmZmZmZmZmZmZmZmdWwsIDB4MHVsKTsKCQlicmVhazsKCWNhc2UgMTQ6CgkJbWVtY3B5KCh2b2lk
KikweDIwMDA0MDAwLCAiXHgyZVx4MmZceDY2XHg2OVx4NmNceDY1XHgzMFx4MDAiLCA4KTsKCQly
ODkgPSBzeXNjYWxsKFNZU19vcGVuYXQsIDB4MTg2OWZ1bCwgMHgyMDAwNDAwMHVsLCAweDB1bCwg
MHgxNDB1bCwgMCwgMCk7CgkJYnJlYWs7CgljYXNlIDE1OgoJCXN5c2NhbGwoU1lTX21tYXAsIDB4
MjAwMDQwMDB1bCwgMHgxMDAwdWwsIDB4M3VsLCAweDMydWwsIDB4ZmZmZmZmZmZmZmZmZmZmZnVs
LCAweDB1bCk7CgkJYnJlYWs7CgljYXNlIDE2OgoJCXN5c2NhbGwoU1lTX21tYXAsIDB4MjAwMDQw
MDB1bCwgMHgxMDAwdWwsIDB4M3VsLCAweDMydWwsIDB4ZmZmZmZmZmZmZmZmZmZmZnVsLCAweDB1
bCk7CgkJYnJlYWs7CgljYXNlIDE3OgoJCW1lbWNweSgodm9pZCopMHgyMDAwNDc1ZSwgIlx4MmVc
eDJmXHg2Mlx4NzVceDczXHgwMCIsIDYpOwoJCXI5MyA9IHN5c2NhbGwoU1lTX29wZW4sIDB4MjAw
MDQ3NWV1bCwgMHgxMDEwMDB1bCwgMHg1MHVsLCAwLCAwLCAwKTsKCQlicmVhazsKCWNhc2UgMTg6
CgkJc3lzY2FsbChTWVNfbW1hcCwgMHgyMDAwNDAwMHVsLCAweDEwMDB1bCwgMHgzdWwsIDB4MzJ1
bCwgMHhmZmZmZmZmZmZmZmZmZmZmdWwsIDB4MHVsKTsKCQlicmVhazsKCWNhc2UgMTk6CgkJbWVt
Y3B5KCh2b2lkKikweDIwMDA0MDAwLCAiXHgyZVx4MmZceDY2XHg2OVx4NmNceDY1XHgzMFx4MDAi
LCA4KTsKCQltZW1jcHkoKHZvaWQqKTB4MjAwMDRmZmIsICJceDJlXHgyZlx4NjZceDY5XHg2Y1x4
NjVceDMwXHgwMCIsIDgpOwoJCXN5c2NhbGwoU1lTX2xpbmthdCwgcjg5LCAweDIwMDA0MDAwdWws
IHI5MywgMHgyMDAwNGZmYnVsLCAweDEwMDB1bCwgMCk7CgkJYnJlYWs7CgljYXNlIDIwOgoJCXN5
c2NhbGwoU1lTX21tYXAsIDB4MjAwMDUwMDB1bCwgMHgxMDAwdWwsIDB4M3VsLCAweDMydWwsIDB4
ZmZmZmZmZmZmZmZmZmZmZnVsLCAweDB1bCk7CgkJYnJlYWs7CgljYXNlIDIxOgoJCXN5c2NhbGwo
U1lTX21tYXAsIDB4MjAwMDUwMDB1bCwgMHgxMDAwdWwsIDB4M3VsLCAweDMydWwsIDB4ZmZmZmZm
ZmZmZmZmZmZmZnVsLCAweDB1bCk7CgkJYnJlYWs7CgljYXNlIDIyOiB7CgkJdW5zaWduZWQgbG9u
ZyBvbGQsIG5ldzsKCQlvbGQgPSAxOwoJCW5ldyA9IDI7CgkJbWlncmF0ZV9wYWdlcyhnZXRwaWQo
KSwgMiwgJm9sZCwgJm5ldyk7CgkJYnJlYWs7Cgl9CgljYXNlIDIzOiB7CgkJdW5zaWduZWQgbG9u
ZyBvbGQsIG5ldzsKCQlvbGQgPSAyOwoJCW5ldyA9IDE7CgkJbWlncmF0ZV9wYWdlcyhnZXRwaWQo
KSwgMiwgJm9sZCwgJm5ldyk7CgkJYnJlYWs7Cgl9Cgl9CglyZXR1cm4gMDsKfQoKdm9pZCB3b3Jr
ZXIodm9pZCkKewoJY29uc3QgaW50IE4gPSAyNDsKCWNvbnN0IGludCBLID0gMjsKCWludCBpLCBq
OwoJcHRocmVhZF90IHRoW0sqTl07Cgl2b2lkICpwOwoKCWNoYXIgYnVmWzEyOF07CglzcHJpbnRm
KGJ1ZiwgIi90bXAvbXlwcml2YXRlJWQiLCBnZXRwaWQoKSk7CglpbnQgZmQgPSBvcGVuKGJ1Ziwg
T19SRFdSfE9fQ1JFQVQsIDA2MDApOwoJZnRydW5jYXRlKGZkLCAxMDA8PDIwKTsKCXAgPSBtbWFw
KDAsIDEwMDw8MjAsIFBST1RfUkVBRHxQUk9UX1dSSVRFLCBNQVBfU0hBUkVELCBmZCwgMCk7Cglp
ZiAocCAhPSBNQVBfRkFJTEVEKSB7CgkJZm9yIChpID0gMDsgaSA8ICgxMDA8PDIwKTsgaSArPSAo
NDw8MTApKQoJCQkoKHZvbGF0aWxlIGNoYXIqKXApW2ldKys7CgkJbXVubWFwKHAsIDEwMDw8MjAp
OwoJfQoJY2xvc2UoZmQpOwoJdW5saW5rKGJ1Zik7CgoJZm9yIChpID0gMDsgaSA8IE5NQVA7IGkr
KykgewoJCWZvciAoaiA9IDA7IGogPCBTSVpFOyBqICs9IDQ8PDEwKQoJCQkoKHZvbGF0aWxlIGNo
YXIqKW1hcHNbaV0pW2pdID0gMTsKCX0KCglmb3IgKGkgPSAwOyBpIDwgSypOOyBpKyspIHsKCQlw
dGhyZWFkX2NyZWF0ZSgmdGhbaV0sIDAsIHRociwgKHZvaWQqKShsb25nKWkpOwoJCXVzbGVlcCgy
MCk7Cgl9CgoJZm9yIChpID0gMDsgaSA8IEsqTjsgaSsrKQoJCXB0aHJlYWRfam9pbih0aFtpXSwg
MCk7Cgp9Cgp2b2lkIGZvcmt3b3JrZXIodm9pZCkKewoJaW50IGksIGo7CgoJZm9yIChpID0gMDsg
aSA8IE5NQVA7IGkrKykgewoJCWZvciAoaiA9IDA7IGogPCBTSVpFOyBqICs9IDQ8PDEwKQoJCQko
KHZvbGF0aWxlIGNoYXIqKW1hcHNbaV0pW2pdID0gMTsKCX0KCglpZiAoZm9yaygpID09IDApIHsK
CQl3b3JrZXIoKTsKCQlleGl0KDApOwoJfQp9CgppbnQgbWFpbihpbnQgYXJnYywgY2hhciAqKmFy
Z3YpCnsKCWludCBpOwoKCWZvciAoaSA9IDA7IGkgPCBOTUFQOyBpKyspIHsKCQljaGFyIGJ1Zlsx
MjhdOwoJCXNwcmludGYoYnVmLCAiL3RtcC9teXNoYXJlZCVkIiwgaSk7CgkJaW50IGZkID0gb3Bl
bihidWYsIE9fUkRXUnxPX0NSRUFULCAwNjAwKTsKCQlmdHJ1bmNhdGUoZmQsIFNJWkUpOwoJCW1h
cHNbaV0gPSBtbWFwKDAsIFNJWkUsIFBST1RfUkVBRHxQUk9UX1dSSVRFLCBNQVBfU0hBUkVELCBm
ZCwgMCk7Cgl9CgoJZm9yIChpID0gMDsgaSA8IDg7IGkrKykKCQlmb3Jrd29ya2VyKCk7Cglmb3Ig
KDs7KQoJCWlmICh3YWl0KDApICE9IC0xKQoJCQlmb3Jrd29ya2VyKCk7Cn0K
--001a113d812ef61a130526f4ba48--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
