Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 802736B03B6
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 09:05:15 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id w10so10837861uaw.4
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 06:05:15 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g79sor237251vkf.5.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Feb 2017 06:05:14 -0800 (PST)
MIME-Version: 1.0
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 28 Feb 2017 15:04:53 +0100
Message-ID: <CACT4Y+YgntApw9WMLZwF_ncF4JQdA2FNHDpzM+8hb_FpCuuC_g@mail.gmail.com>
Subject: mm: fault in __do_fault
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, ross.zwisler@linux.intel.com, Michal Hocko <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: syzkaller <syzkaller@googlegroups.com>

Hello,

The following program triggers GPF in __do_fault:
https://gist.githubusercontent.com/dvyukov/27345737fca18d92ef761e7fa08aec9b/raw/d99d02511d0bf9a8d6f6bd9c79d373a26924e974/gistfile1.txt

general protection fault: 0000 [#1] SMP KASAN
Modules linked in:
CPU: 3 PID: 2955 Comm: a.out Not tainted 4.10.0+ #230
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff88006b4e2480 task.stack: ffff88006b0b0000
RIP: 0010:__read_once_size include/linux/compiler.h:247 [inline]
RIP: 0010:compound_head include/linux/page-flags.h:146 [inline]
RIP: 0010:trylock_page include/linux/pagemap.h:442 [inline]
RIP: 0010:lock_page include/linux/pagemap.h:452 [inline]
RIP: 0010:__do_fault+0x247/0x3e0 mm/memory.c:2898
RSP: 0000:ffff88006b0b7470 EFLAGS: 00010202
RAX: dffffc0000000000 RBX: 1ffff1000d616e91 RCX: 0000000000000000
RDX: 0000000000000004 RSI: dffffc0000000000 RDI: 0000000000000020
RBP: ffff88006b0b7550 R08: 0000000000000001 R09: 0000000000000001
R10: 0000000000000000 R11: 0000000000000004 R12: ffff88006b0b74e8
R13: 0000000000000000 R14: ffff88006b0b7528 R15: 0000000000000000
FS:  00007fef8bb55700(0000) GS:ffff88006d180000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020012fe0 CR3: 000000006a8dc000 CR4: 00000000001406e0
Call Trace:
 do_read_fault mm/memory.c:3266 [inline]
 do_fault+0x5ee/0x2080 mm/memory.c:3366
 handle_pte_fault mm/memory.c:3596 [inline]
 __handle_mm_fault+0x1062/0x2cb0 mm/memory.c:3710
 handle_mm_fault+0x1e2/0x480 mm/memory.c:3747
 __do_page_fault+0x4f6/0xb60 arch/x86/mm/fault.c:1396
 trace_do_page_fault+0x141/0x6c0 arch/x86/mm/fault.c:1489
 do_async_page_fault+0x72/0xc0 arch/x86/kernel/kvm.c:264
 async_page_fault+0x28/0x30 arch/x86/entry/entry_64.S:1014
RIP: 0033:0x43dda0
RSP: 002b:00007fef8bb54878 EFLAGS: 00010202
RAX: 00007fef8bb548b0 RBX: 0000000000000000 RCX: 000000000000000e
RDX: 0000000000000400 RSI: 0000000020012fe0 RDI: 00007fef8bb548b0
RBP: 00007fef8bb54cd0 R08: 0000000000000400 R09: 00007fef8bb54d10
R10: 00007fef8bb559d0 R11: 0000000000000202 R12: 0000000000000000
R13: 0000000000000000 R14: 00007fef8bb559c0 R15: 00007fef8bb55700
Code: 00 e8 0e 35 b8 ff e8 79 09 a2 02 4c 89 e2 49 8d 7f 20 48 b8 00
00 00 00 00 fc ff df 48 c1 ea 03 c6 04 02 00 48 89 fa 48 c1 ea 03 <80>
3c 02 00 0f 85 ec 00 00 00 4c 89 e2 48 b8 00 00 00 00 00 fc
RIP: __read_once_size include/linux/compiler.h:247 [inline] RSP:
ffff88006b0b7470
RIP: compound_head include/linux/page-flags.h:146 [inline] RSP: ffff88006b0b7470
RIP: trylock_page include/linux/pagemap.h:442 [inline] RSP: ffff88006b0b7470
RIP: lock_page include/linux/pagemap.h:452 [inline] RSP: ffff88006b0b7470
RIP: __do_fault+0x247/0x3e0 mm/memory.c:2898 RSP: ffff88006b0b7470
---[ end trace d24250eecdbb8a34 ]---

On commit e5d56efc97f8240d0b5d66c03949382b6d7e5570

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
