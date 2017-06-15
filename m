Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6D2336B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 20:57:35 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id e63so2724497iod.11
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 17:57:35 -0700 (PDT)
Received: from fldsmtpe03.verizon.com (fldsmtpe03.verizon.com. [140.108.26.142])
        by mx.google.com with ESMTPS id e80si1771580itd.1.2017.06.14.17.57.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 17:57:33 -0700 (PDT)
From: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Subject: Bad page state freeing hugepages
Date: Thu, 15 Jun 2017 00:56:14 +0000
Message-ID: <20170615005612.5eeqdajx5qnhxxuf@sasha-lappy>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <2447CC0DBD03EA44A871B51B00A03A7B@vzwcorp.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "hughd@google.com" <hughd@google.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi all,

I've started seeing the following traces while fuzzing on the latest
-next kernel:

BUG: Bad page state in process syz-executor1  pfn:1ac01
page:ffffea00006b0040 count:0 mapcount:1 mapping:dead000000000000 index:0x2=
0001 compound_mapcount: 1
flags: 0xfffe0000000000()
raw: 00fffe0000000000 dead000000000000 0000000000000000 00000000ffffffff
raw: ffffea00006b0001 0000000900000003 0000000000000000 0000000000000000
page dumped because: nonzero compound_mapcount
Modules linked in:
CPU: 1 PID: 25025 Comm: syz-executor1 Not tainted 4.12.0-rc5-next-20170614+=
 #119
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.1-1ubuntu1=
 04/01/2014
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x11d/0x1e5 lib/dump_stack.c:52
 bad_page+0x232/0x2c0 mm/page_alloc.c:565
 free_tail_pages_check mm/page_alloc.c:974 [inline]
 free_pages_prepare mm/page_alloc.c:1030 [inline]
 __free_pages_ok+0x10be/0x1900 mm/page_alloc.c:1247
 free_compound_page+0x5e/0x70 mm/page_alloc.c:589
 free_transhuge_page+0x2d2/0x440 mm/huge_memory.c:2553
 __put_compound_page+0x87/0xb0 mm/swap.c:95
 __put_page+0xc3/0x410 mm/swap.c:111
 put_page include/linux/mm.h:814 [inline]
 get_futex_key+0xf86/0x1ce0 kernel/futex.c:702
 futex_wait_setup+0xd2/0x3f0 kernel/futex.c:2453
 futex_wait+0x32d/0xa20 kernel/futex.c:2516
 do_futex+0x106a/0x20c0 kernel/futex.c:3393
 SYSC_futex kernel/futex.c:3453 [inline]
 SyS_futex+0x299/0x3e0 kernel/futex.c:3421
 do_syscall_64+0x267/0x740 arch/x86/entry/common.c:284
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x451429
RSP: 002b:00007f03ba95bc08 EFLAGS: 00000216 ORIG_RAX: 00000000000000ca
RAX: ffffffffffffffda RBX: 00000000201ff000 RCX: 0000000000451429
RDX: 0000000100000000 RSI: 0000000000000000 RDI: 00000000201ff000
RBP: 0000000000718000 R08: 0000000020f67ffc R09: 0000000000000001
R10: 00000000207d3000 R11: 0000000000000216 R12: 00000000ffffffff
R13: 0000000000000000 R14: 000000000000007a R15: 00007f03ba95c700
Disabling lock debugging due to kernel taint
page:ffffea00006b0000 count:0 mapcount:0 mapping:          (null) index:0x2=
0000 compound_mapcount: 1
flags: 0xfffe0000048008(uptodate|head|swapbacked)
raw: 00fffe0000048008 0000000000000000 0000000000020000 00000000ffffffff
raw: ffffea00006b0020 ffffea00006b0020 0000000000000000 0000000000000000
page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) =3D=3D 0)
------------[ cut here ]------------
kernel BUG at ./include/linux/mm.h:466!
invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 2 PID: 25054 Comm: syz-executor1 Tainted: G    B           4.12.0-rc5-=
next-20170614+ #119
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.1-1ubuntu1=
 04/01/2014
task: ffff880038dec040 task.stack: ffff88003d668000
RIP: 0010:put_page_testzero include/linux/mm.h:466 [inline]
RIP: 0010:release_pages+0xb9c/0x1270 mm/swap.c:764
RSP: 0018:ffff88003d66f030 EFLAGS: 00010246
RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000000
RDX: ffffffff816bf7ad RSI: ffffc90002a03000 RDI: ffffed0007acddf7
RBP: ffff88003d66f528 R08: 0000000000000000 R09: ffff880038dec040
R10: dffffc0000000000 R11: ffffffffb34e73fe R12: 1ffff10007acde20
R13: ffffea00006b0000 R14: ffff88003d66f500 R15: dffffc0000000000
FS:  00007f03ba8f9700(0000) GS:ffff88006d600000(0000) knlGS:000000000000000=
0
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000002000a000 CR3: 0000000034cd2000 CR4: 00000000000406e0
Call Trace:
 free_pages_and_swap_cache+0x2c0/0x420 mm/swap_state.c:291
 tlb_flush_mmu_free+0xb4/0x160 mm/memory.c:262
 tlb_flush_mmu mm/memory.c:271 [inline]
 tlb_finish_mmu+0x23/0xa0 mm/memory.c:282
 unmap_region+0x364/0x500 mm/mmap.c:2467
 do_munmap+0x59a/0x1090 mm/mmap.c:2669
 mmap_region+0x5b1/0x15b0 mm/mmap.c:1616
 do_mmap+0x70b/0xe60 mm/mmap.c:1453
 do_mmap_pgoff include/linux/mm.h:2135 [inline]
 vm_mmap_pgoff+0x1f1/0x290 mm/util.c:309
 SYSC_mmap_pgoff mm/mmap.c:1503 [inline]
 SyS_mmap_pgoff+0x243/0x600 mm/mmap.c:1461
 SYSC_mmap arch/x86/kernel/sys_x86_64.c:98 [inline]
 SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:89
 do_syscall_64+0x267/0x740 arch/x86/entry/common.c:284
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x451429
RSP: 002b:00007f03ba8f8c08 EFLAGS: 00000216 ORIG_RAX: 0000000000000009
RAX: ffffffffffffffda RBX: 0000000020000000 RCX: 0000000000451429
RDX: 0000000000000003 RSI: 0000000000f63000 RDI: 0000000020000000
RBP: 00000000007181f8 R08: ffffffffffffffff R09: 0000000000000000
R10: 0000000000000032 R11: 0000000000000216 R12: 00000000ffffffff
R13: 0000000000f63000 R14: 0000000000000377 R15: 00007f03ba8f9700
Code: 40 fb ff ff 48 8d bb 80 4e 00 00 31 db e8 ed 19 2b 04 e9 64 ff ff ff =
e8 33 16 e3 ff 48 c7 c6 80 7a cc b7 4c 89 ef e8 04 00 09 00 <0f> 0b e8 1d 1=
6 e3 ff 4d 8d 6c 24 ff e9 08 f7 ff ff e8 0e 16 e3=20
RIP: put_page_testzero include/linux/mm.h:466 [inline] RSP: ffff88003d66f03=
0
RIP: release_pages+0xb9c/0x1270 mm/swap.c:764 RSP: ffff88003d66f030
---[ end trace 005231fe0842ac18 ]---
Kernel panic - not syncing: Fatal exception

BUG: Bad page state in process syz-fuzzer  pfn:1f601
page:ffffea00007d8040 count:0 mapcount:1 mapping:dead000000000000 index:0x7=
fa463e01 compound_mapcount: 1
flags: 0xfffe0000000000()
raw: 00fffe0000000000 dead000000000000 0000000000000000 00000000ffffffff
raw: ffffea00007d8001 0000000900000003 0000000000000000 0000000000000000
page dumped because: nonzero compound_mapcount
Modules linked in:
CPU: 2 PID: 6331 Comm: syz-fuzzer Not tainted 4.12.0-rc5-next-20170614+ #11=
9
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.1-1ubuntu1=
 04/01/2014
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x11d/0x1e5 lib/dump_stack.c:52
 bad_page+0x232/0x2c0 mm/page_alloc.c:565
 free_tail_pages_check mm/page_alloc.c:974 [inline]
 free_pages_prepare mm/page_alloc.c:1030 [inline]
 __free_pages_ok+0x10be/0x1900 mm/page_alloc.c:1247
 free_compound_page+0x5e/0x70 mm/page_alloc.c:589
 free_transhuge_page+0x2d2/0x440 mm/huge_memory.c:2553
 __put_compound_page+0x87/0xb0 mm/swap.c:95
 __put_page+0xc3/0x410 mm/swap.c:111
 put_page include/linux/mm.h:814 [inline]
 get_futex_key+0xf86/0x1ce0 kernel/futex.c:702
 futex_wake+0x1a5/0x6a0 kernel/futex.c:1512
 do_futex+0x102e/0x20c0 kernel/futex.c:3397
 SYSC_futex kernel/futex.c:3453 [inline]
 SyS_futex+0x299/0x3e0 kernel/futex.c:3421
 mm_release+0x3fb/0x560 kernel/fork.c:1143
 exit_mm kernel/exit.c:511 [inline]
 do_exit+0x480/0x1bb0 kernel/exit.c:863
 do_group_exit+0x151/0x410 kernel/exit.c:978
 get_signal+0x84e/0x18b0 kernel/signal.c:2323
 do_signal+0x98/0x1eb0 arch/x86/kernel/signal.c:808
 exit_to_usermode_loop+0x187/0x220 arch/x86/entry/common.c:157
 prepare_exit_to_usermode arch/x86/entry/common.c:194 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:263 [inline]
 do_syscall_64+0x50b/0x740 arch/x86/entry/common.c:289
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x488964
RSP: 002b:000000c4268115e0 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
RAX: fffffffffffffe00 RBX: 0000000000000000 RCX: 0000000000488964
RDX: 000000000001ffdf RSI: 000000c4268b4021 RDI: 000000000000000e
RBP: 000000c426811630 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 00000000ffffffee R14: 000000c42a7a17a0 R15: 0000000000000000
Disabling lock debugging due to kernel taint
page:ffffea00007d8000 count:0 mapcount:-1 mapping:          (null) index:0x=
7fa463e00 compound_mapcount: 0
flags: 0x85760000048008(uptodate|head|swapbacked)
raw: 0085760000048008 0000000000000000 00000007fa463e00 00000000fffffffe
raw: ffffea00007d8020 ffffea00007d8020 0000000000000000 0000000000000000
page dumped because: VM_BUG_ON_PAGE(page_mapcount(page) < 0)
------------[ cut here ]------------
kernel BUG at mm/huge_memory.c:1640!
invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 1 PID: 6378 Comm: syz-fuzzer Tainted: G    B           4.12.0-rc5-next=
-20170614+ #119
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.1-1ubuntu1=
 04/01/2014
task: ffff8800629a0040 task.stack: ffff88006a5b8000
RIP: 0010:zap_huge_pmd+0x96c/0xbd0 mm/huge_memory.c:1640
RSP: 0018:ffff88006a5bea60 EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffffea00007d8000 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffffed000d4b7d3d
RBP: ffff88006a5bebc0 R08: 0000000000000000 R09: ffff8800629a0040
R10: dffffc0000000000 R11: ffffffffa229bba3 R12: ffff88006a5bf100
R13: 1ffff1000d4b7d4f R14: ffff880068b158f8 R15: ffffea00007d8020
FS:  00007fa4569f6700(0000) GS:ffff88003ec00000(0000) knlGS:000000000000000=
0
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020003fd8 CR3: 000000004a028000 CR4: 00000000000406e0
Call Trace:
 zap_pmd_range mm/memory.c:1304 [inline]
 zap_pud_range mm/memory.c:1346 [inline]
 zap_p4d_range mm/memory.c:1367 [inline]
 unmap_page_range+0x152f/0x1db0 mm/memory.c:1388
 unmap_single_vma+0x15f/0x2d0 mm/memory.c:1433
 unmap_vmas+0xf1/0x1b0 mm/memory.c:1463
 exit_mmap+0x211/0x450 mm/mmap.c:2963
 __mmput kernel/fork.c:903 [inline]
 mmput+0x22f/0x6e0 kernel/fork.c:925
 exit_mm kernel/exit.c:556 [inline]
 do_exit+0x9a0/0x1bb0 kernel/exit.c:863
 do_group_exit+0x151/0x410 kernel/exit.c:978
 get_signal+0x84e/0x18b0 kernel/signal.c:2323
 do_signal+0x98/0x1eb0 arch/x86/kernel/signal.c:808
 exit_to_usermode_loop+0x187/0x220 arch/x86/entry/common.c:157
 prepare_exit_to_usermode arch/x86/entry/common.c:194 [inline]
 syscall_return_slowpath arch/x86/entry/common.c:263 [inline]
 do_syscall_64+0x50b/0x740 arch/x86/entry/common.c:289
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x45c723
RSP: 002b:000000c420025ea0 EFLAGS: 00000202 ORIG_RAX: 00000000000000ca
RAX: fffffffffffffdfc RBX: 000000003b7615ec RCX: 000000000045c723
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000e5d9d8
RBP: 000000c420025ee8 R08: 0000000000000000 R09: 0000000000000000
R10: 000000c420025ed8 R11: 0000000000000202 R12: 0000004df9784cc4
R13: 0000004df9784cc4 R14: 000000c42bd91d40 R15: 0000000000000000
Code: ff e8 89 e1 c9 ff 48 c7 c6 80 5d ae a6 48 89 df e8 5a cb ef ff 0f 0b =
e8 73 e1 c9 ff 48 c7 c6 c0 5d ae a6 48 89 df e8 44 cb ef ff <0f> 0b e8 5d e=
1 c9 ff 48 c7 c6 20 5e ae a6 48 89 df e8 2e cb ef=20
RIP: zap_huge_pmd+0x96c/0xbd0 mm/huge_memory.c:1640 RSP: ffff88006a5bea60
---[ end trace c0196962ea14530a ]---
Kernel panic - not syncing: Fatal exception


BUG: Bad page state in process syz-executor0  pfn:4e801
page:ffffea00013a0040 count:0 mapcount:1 mapping:dead000000000000 index:0x2=
0401 compound_mapcount: 1
flags: 0x4fffe0000000000()
raw: 04fffe0000000000 dead000000000000 0000000000000000 00000000ffffffff
raw: ffffea00013a0001 0000000900000003 0000000000000000 0000000000000000
page dumped because: nonzero compound_mapcount
Modules linked in:
CPU: 3 PID: 14685 Comm: syz-executor0 Not tainted 4.12.0-rc5-next-20170614+=
 #119
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.1-1ubuntu1=
 04/01/2014
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x11d/0x1e5 lib/dump_stack.c:52
 bad_page+0x232/0x2c0 mm/page_alloc.c:565
 free_tail_pages_check mm/page_alloc.c:974 [inline]
 free_pages_prepare mm/page_alloc.c:1030 [inline]
 __free_pages_ok+0x10be/0x1900 mm/page_alloc.c:1247
 free_compound_page+0x5e/0x70 mm/page_alloc.c:589
 free_transhuge_page+0x2d2/0x440 mm/huge_memory.c:2553
 __put_compound_page+0x87/0xb0 mm/swap.c:95
 __put_page+0xc3/0x410 mm/swap.c:111
 put_page include/linux/mm.h:814 [inline]
 do_direct_IO fs/direct-io.c:981 [inline]
 do_blockdev_direct_IO+0x836b/0xd5a0 fs/direct-io.c:1257
 __blockdev_direct_IO+0x9d/0xd0 fs/direct-io.c:1343
 ext4_direct_IO_write fs/ext4/inode.c:3646 [inline]
 ext4_direct_IO+0xbd6/0x1c50 fs/ext4/inode.c:3768
 generic_file_direct_write+0x199/0x340 mm/filemap.c:2737
 __generic_file_write_iter+0x224/0x600 mm/filemap.c:2910
 ext4_file_write_iter+0x2b0/0x1140 fs/ext4/file.c:242
 call_write_iter include/linux/fs.h:1735 [inline]
 new_sync_write fs/read_write.c:497 [inline]
 __vfs_write+0x679/0x9a0 fs/read_write.c:510
 vfs_write+0x18f/0x510 fs/read_write.c:558
 SYSC_write fs/read_write.c:605 [inline]
 SyS_write+0xfa/0x240 fs/read_write.c:597
 do_syscall_64+0x267/0x740 arch/x86/entry/common.c:284
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x451429
RSP: 002b:00007fc5506c9c08 EFLAGS: 00000216 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 0000000000451429
RDX: 0000000000001000 RSI: 00000000205ff000 RDI: 0000000000000005
RBP: 0000000000718000 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000216 R12: 00000000ffffffff
R13: 00000000205ff000 R14: 00000000000005ce R15: 00007fc5506ca700
page:ffffea00013a0000 count:0 mapcount:0 mapping:ffff8800661a6289 index:0x2=
0400 compound_mapcount: 0
flags: 0x4fffe0000048008(uptodate|head|swapbacked)
raw: 04fffe0000048008 ffff8800661a6289 0000000000020400 00000000ffffffff
Disabling lock debugging due to kernel taint
list_add corruption. prev->next should be next (ffff88007ffdcf20), but was =
          (null). (prev=3Dffffea00013a0088).
------------[ cut here ]------------
kernel BUG at lib/list_debug.c:28!
invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 3 PID: 14707 Comm: syz-executor6 Tainted: G    B           4.12.0-rc5-=
next-20170614+ #119
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.1-1ubuntu1=
 04/01/2014
task: ffff88005fde0040 task.stack: ffff88005fe80000
RIP: 0010:__list_add_valid.cold.0+0x23/0x25 lib/list_debug.c:26
RSP: 0018:ffff88005fe86cb0 EFLAGS: 00010082
RAX: 0000000000000075 RBX: ffff88007ffdcf20 RCX: 00000000000008d8
RDX: 0000000000000000 RSI: ffffc90003909000 RDI: 0000000000000000
RBP: ffff88005fe86cc8 R08: 0000000000000000 R09: ffff88005fde0040
R10: ffffea00013a0088 R11: ffffffffa6c9bba3 R12: ffffea00013c0088
R13: ffff88007ffd8000 R14: ffff88007ffdced8 R15: ffffea00013c0000
FS:  00007faab4f70700(0000) GS:ffff88006d600000(0000) knlGS:000000000000000=
0
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000209e2000 CR3: 0000000061087000 CR4: 00000000000406e0
Call Trace:
 __list_add include/linux/list.h:59 [inline]
 list_add_tail include/linux/list.h:92 [inline]
 deferred_split_huge_page+0x2d1/0x590 mm/huge_memory.c:2566
 page_remove_anon_compound_rmap mm/rmap.c:1229 [inline]
 page_remove_rmap+0x377/0xcd0 mm/rmap.c:1246
 zap_huge_pmd+0x305/0xbd0 mm/huge_memory.c:1639
 zap_pmd_range mm/memory.c:1304 [inline]
 zap_pud_range mm/memory.c:1346 [inline]
 zap_p4d_range mm/memory.c:1367 [inline]
 unmap_page_range+0x152f/0x1db0 mm/memory.c:1388
 unmap_single_vma+0x15f/0x2d0 mm/memory.c:1433
 unmap_vmas+0xf1/0x1b0 mm/memory.c:1463
 unmap_region+0x2c1/0x500 mm/mmap.c:2464
 do_munmap+0x59a/0x1090 mm/mmap.c:2669
 mmap_region+0x5b1/0x15b0 mm/mmap.c:1616
 do_mmap+0x70b/0xe60 mm/mmap.c:1453
 do_mmap_pgoff include/linux/mm.h:2135 [inline]
 vm_mmap_pgoff+0x1f1/0x290 mm/util.c:309
 SYSC_mmap_pgoff mm/mmap.c:1503 [inline]
 SyS_mmap_pgoff+0x243/0x600 mm/mmap.c:1461
 SYSC_mmap arch/x86/kernel/sys_x86_64.c:98 [inline]
 SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:89
 do_syscall_64+0x267/0x740 arch/x86/entry/common.c:284
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x451429
RSP: 002b:00007faab4f6fc08 EFLAGS: 00000216 ORIG_RAX: 0000000000000009
RAX: ffffffffffffffda RBX: 0000000020000000 RCX: 0000000000451429
RDX: 0000000000000003 RSI: 00000000009e1000 RDI: 0000000020000000
RBP: 0000000000718000 R08: ffffffffffffffff R09: 0000000000000000
R10: 0000000000000032 R11: 0000000000000216 R12: 00000000ffffffff
R13: 00000000009e1000 R14: 0000000000000377 R15: 00007faab4f70700
Code: fe 5b 41 5c 41 5d 5d c3 48 89 d9 48 c7 c7 60 84 67 ab e8 b8 68 97 fe =
0f 0b 48 89 f1 48 c7 c7 20 85 67 ab 48 89 de e8 a4 68 97 fe <0f> 0b 48 c7 c=
7 c0 86 67 ab e8 96 68 97 fe 0f 0b 4c 89 e2 48 c7=20
RIP: __list_add_valid.cold.0+0x23/0x25 lib/list_debug.c:26 RSP: ffff88005fe=
86cb0
---[ end trace f869bcffb9c578bb ]---
Kernel panic - not syncing: Fatal exception

--=20

Thanks,
Sasha=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
