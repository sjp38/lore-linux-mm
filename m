Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4B56E6B51C0
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 09:32:01 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id w6-v6so5797868wrc.22
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 06:32:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u3-v6sor4934356wrw.12.2018.08.30.06.31.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 Aug 2018 06:31:58 -0700 (PDT)
MIME-Version: 1.0
From: Vegard Nossum <vegard.nossum@gmail.com>
Date: Thu, 30 Aug 2018 15:31:46 +0200
Message-ID: <CAOMGZ=G52R-30rZvhGxEbkTw7rLLwBGadVYeo--iizcD3upL3A@mail.gmail.com>
Subject: v4.18.0+ WARNING: at mm/vmscan.c:1756 isolate_lru_page + bad page state
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>

Hi,

Got this on a recent kernel (pretty sure it was
2ad0d52699700a91660a406a4046017a2d7f246a but annoyingly the oops
itself doesn't tell me the exact version):

------------[ cut here ]------------
trying to isolate tail page
WARNING: CPU: 2 PID: 19156 at mm/vmscan.c:1756 isolate_lru_page+0x235/0x250
CPU: 2 PID: 19156 Comm: mmap Not tainted 4.18.0+ #493
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
Ubuntu-1.8.2-1ubuntu1 04/01/2014
RIP: 0010:isolate_lru_page+0x235/0x250
Code: fe ff ff 48 c7 c6 80 73 43 82 48 c7 c7 60 27 a9 82 e8 3f 40 c9
00 85 c0 0f 84 f4 fd ff ff 48 c7 c7 a5 ba 75 82 e8 6b 59 ed ff <0f> 0b
e9 e1 fd ff ff 49 c7 c7 00 fe ff ff 44 89 7c 24 04 e9 ed fe
RSP: 0018:ffffc90008edbc20 EFLAGS: 00010282
RAX: 0000000000000000 RBX: ffffea00082fd000 RCX: 0000000000000002
RDX: 0000000080000002 RSI: 0000000000000002 RDI: 00000000ffffffff
RBP: ffff8803a157ea00 R08: 0000000000000001 R09: 0000000000000000
R10: ffffffff82e456dc R11: 0000000000000001 R12: ffffea00082fd000
R13: 800000020bf40805 R14: 00007fe50f341000 R15: ffffc90008edbdd8
FS:  0000000000000000(0000) GS:ffff88042fb00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000580fb8 CR3: 0000000002a1e004 CR4: 00000000000606e0
Call Trace:
 clear_page_mlock+0x73/0xb0
 page_remove_rmap+0x31e/0x370
 unmap_page_range+0x70b/0xa40
 unmap_vmas+0x47/0x90
 exit_mmap+0xb0/0x1c0
 mmput+0x5d/0x130
 do_exit+0x2c2/0xc20
 do_group_exit+0x42/0xb0
 __x64_sys_exit_group+0xf/0x10
 do_syscall_64+0x57/0x170
 entry_SYSCALL_64_after_hwframe+0x44/0xa9
RIP: 0033:0x501ad8
Code: Bad RIP value.
RSP: 002b:00007fff9bb8dee8 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 0000000000501ad8
RDX: 0000000000000000 RSI: 000000000000003c RDI: 0000000000000000
RBP: 000000000059b4a0 R08: 00000000000000e7 R09: ffffffffffffffc8
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000001
R13: 00000000007d7860 R14: 0000000000027150 R15: 00007fff9bb8e0c0
---[ end trace d3ada49968979043 ]---
------------[ cut here ]------------
list_del corruption, ffffea00082fd008->prev is LIST_POISON2 (dead000000000200)
WARNING: CPU: 2 PID: 19156 at lib/list_debug.c:50
__list_del_entry_valid+0x62/0x90
CPU: 2 PID: 19156 Comm: mmap Tainted: G        W         4.18.0+ #493
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
Ubuntu-1.8.2-1ubuntu1 04/01/2014
RIP: 0010:__list_del_entry_valid+0x62/0x90
Code: 00 00 00 c3 48 89 fe 48 89 c2 48 c7 c7 f0 b3 79 82 e8 d2 84 b1
ff 0f 0b 31 c0 c3 48 89 fe 48 c7 c7 28 b4 79 82 e8 be 84 b1 ff <0f> 0b
31 c0 c3 48 89 fe 48 c7 c7 60 b4 79 82 e8 aa 84 b1 ff 0f 0b
RSP: 0018:ffffc90008edbc18 EFLAGS: 00010086
RAX: 0000000000000000 RBX: ffffea00082fd000 RCX: 0000000000000003
RDX: 0000000000000003 RSI: 0000000000000003 RDI: 00000000ffffffff
RBP: ffff88043fff0d00 R08: 0000000000000001 R09: 0000000000000000
R10: ffff8802794a60c8 R11: 0000000000000001 R12: 0000000000000004
R13: ffff88042f4ae800 R14: 0000000000000005 R15: ffffc90008edbdd8
FS:  0000000000000000(0000) GS:ffff88042fb00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000501aae CR3: 0000000002a1e004 CR4: 00000000000606e0
Call Trace:
 isolate_lru_page+0xf3/0x250
 clear_page_mlock+0x73/0xb0
 page_remove_rmap+0x31e/0x370
 unmap_page_range+0x70b/0xa40
 unmap_vmas+0x47/0x90
 exit_mmap+0xb0/0x1c0
 mmput+0x5d/0x130
 do_exit+0x2c2/0xc20
 do_group_exit+0x42/0xb0
 __x64_sys_exit_group+0xf/0x10
 do_syscall_64+0x57/0x170
 entry_SYSCALL_64_after_hwframe+0x44/0xa9
RIP: 0033:0x501ad8
Code: Bad RIP value.
RSP: 002b:00007fff9bb8dee8 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 0000000000501ad8
RDX: 0000000000000000 RSI: 000000000000003c RDI: 0000000000000000
RBP: 000000000059b4a0 R08: 00000000000000e7 R09: ffffffffffffffc8
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000001
R13: 00000000007d7860 R14: 0000000000027150 R15: 00007fff9bb8e0c0
---[ end trace d3ada49968979044 ]---
BUG: Bad page state in process mmap  pfn:20bf40
page:ffffea00082fd000 count:0 mapcount:0 mapping:dead000000000400 index:0x1
flags: 0x400000000000000()
raw: 0400000000000000 dead000000000100 dead000000000200 dead000000000400
raw: 0000000000000001 0000000000000000 00000000ffffffff 0000000000000000
page dumped because: non-NULL mapping
CPU: 2 PID: 19156 Comm: mmap Tainted: G        W         4.18.0+ #493
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
Ubuntu-1.8.2-1ubuntu1 04/01/2014
Call Trace:
 dump_stack+0x5c/0x7b
 bad_page+0xb3/0x110
 free_pcppages_bulk+0x17b/0x7e0
 free_unref_page+0x4a/0x60
 zap_huge_pmd+0x204/0x360
 unmap_page_range+0x970/0xa40
 unmap_vmas+0x47/0x90
 exit_mmap+0xb0/0x1c0
 mmput+0x5d/0x130
 do_exit+0x2c2/0xc20
 do_group_exit+0x42/0xb0
 __x64_sys_exit_group+0xf/0x10
 do_syscall_64+0x57/0x170
 entry_SYSCALL_64_after_hwframe+0x44/0xa9
RIP: 0033:0x501ad8
Code: Bad RIP value.
RSP: 002b:00007fff9bb8dee8 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 0000000000501ad8
RDX: 0000000000000000 RSI: 000000000000003c RDI: 0000000000000000
RBP: 000000000059b4a0 R08: 00000000000000e7 R09: ffffffffffffffc8
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000001
R13: 00000000007d7860 R14: 0000000000027150 R15: 00007fff9bb8e0c0
Disabling lock debugging due to kernel taint
general protection fault: 0000 [#1] PREEMPT SMP PTI
CPU: 2 PID: 19156 Comm: mmap Tainted: G    B   W         4.18.0+ #493
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
Ubuntu-1.8.2-1ubuntu1 04/01/2014
RIP: 0010:page_evictable+0x38/0x90
Code: 81 31 d2 45 31 c9 45 31 c0 31 f6 b9 02 00 00 00 48 c7 c7 a0 79
a7 82 e8 b6 6e f2 ff 48 89 ef e8 ce be 00 00 48 85 c0 5a 74 2f <48> 8b
80 08 01 00 00 31 db a8 08 74 22 e8 b6 27 f4 ff 48 c7 c2 a5
RSP: 0018:ffffc90008edbc98 EFLAGS: 00010086
RAX: dead000000000400 RBX: ffffea00082fd000 RCX: 0000000000000000
RDX: ffffffff811fff60 RSI: 0000000000000000 RDI: ffffea00082fd000
RBP: ffffea00082fd000 R08: 0000000000000001 R09: 0000000000000000
R10: ffff8802794a5900 R11: 0000000000000000 R12: ffffea00082fd000
R13: ffff88042f4ae800 R14: 0000000000000000 R15: ffffffff811f8b30
FS:  0000000000991900(0000) GS:ffff88042fb00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000501aae CR3: 0000000002a1e004 CR4: 00000000000606e0
Call Trace:
 __pagevec_lru_add_fn+0x53/0x320
 ? __put_compound_page+0x30/0x30
 pagevec_lru_move_fn+0x83/0xd0
 lru_add_drain_cpu+0xdb/0xf0
 lru_add_drain+0x16/0x40
 free_pages_and_swap_cache+0x13/0xb0
 tlb_flush_mmu_free+0x2c/0x50
 arch_tlb_finish_mmu+0x3d/0x70
 tlb_finish_mmu+0x1a/0x30
 exit_mmap+0xd8/0x1c0
 mmput+0x5d/0x130
 do_exit+0x2c2/0xc20
 do_group_exit+0x42/0xb0
 __x64_sys_exit_group+0xf/0x10
 do_syscall_64+0x57/0x170
 entry_SYSCALL_64_after_hwframe+0x44/0xa9
RIP: 0033:0x501ad8
Code: Bad RIP value.
RSP: 002b:00007fff9bb8dee8 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 0000000000501ad8
RDX: 0000000000000000 RSI: 000000000000003c RDI: 0000000000000000
RBP: 000000000059b4a0 R08: 00000000000000e7 R09: ffffffffffffffc8
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000001
R13: 00000000007d7860 R14: 0000000000027150 R15: 00007fff9bb8e0c0
Dumping ftrace buffer:
   (ftrace buffer empty)
---[ end trace d3ada49968979045 ]---
RIP: 0010:page_evictable+0x38/0x90
Code: 81 31 d2 45 31 c9 45 31 c0 31 f6 b9 02 00 00 00 48 c7 c7 a0 79
a7 82 e8 b6 6e f2 ff 48 89 ef e8 ce be 00 00 48 85 c0 5a 74 2f <48> 8b
80 08 01 00 00 31 db a8 08 74 22 e8 b6 27 f4 ff 48 c7 c2 a5
RSP: 0018:ffffc90008edbc98 EFLAGS: 00010086
RAX: dead000000000400 RBX: ffffea00082fd000 RCX: 0000000000000000
RDX: ffffffff811fff60 RSI: 0000000000000000 RDI: ffffea00082fd000
RBP: ffffea00082fd000 R08: 0000000000000001 R09: 0000000000000000
R10: ffff8802794a5900 R11: 0000000000000000 R12: ffffea00082fd000
R13: ffff88042f4ae800 R14: 0000000000000000 R15: ffffffff811f8b30
FS:  0000000000991900(0000) GS:ffff88042fb00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000501aae CR3: 0000000002a1e004 CR4: 00000000000606e0
Kernel panic - not syncing: Fatal exception
Dumping ftrace buffer:
   (ftrace buffer empty)
Kernel Offset: disabled

I don't have the capacity to debug it atm and it may even have been
fixed in mainline (though searching didn't yield any other reports
AFAICT).

I have .config and vmlinux (with DEBUG_INFO=y) if needed.

It's not reproducible for the time being.


Vegard
