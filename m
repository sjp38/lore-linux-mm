Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 681116B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 18:01:39 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id a64so6357980oii.1
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 15:01:39 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id b202si7561276itb.21.2016.06.14.15.01.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 15:01:38 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: mm: BUG: KASAN: use-after-free in unmapped_area_topdown
Message-ID: <57607EBF.60005@oracle.com>
Date: Tue, 14 Jun 2016 18:01:35 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi all,

I've hit the following while fuzzing with syzkaller inside a KVM tools guest
running the latest -next kernel:

[ 1292.662270] BUG: KASAN: use-after-free in unmapped_area_topdown+0x402/0x5a0 at addr ffff8801c58b7038

[ 1292.662285] Read of size 8 by task syz-executor/23061

[ 1292.662312] CPU: 4 PID: 23061 Comm: syz-executor Not tainted 4.7.0-rc3-next-20160614-sasha-00032-g8e3c1a2-dirty #3105

[ 1292.662336]  1ffff10016b04f32 0000000081187c24 ffff8800b5827a18 ffffffffa402fb57

[ 1292.662347]  ffffffff00000004 fffffbfff5e30bac 0000000041b58ab3 ffffffffaeafca90

[ 1292.662357]  ffffffffa402f9e8 ffff8800b58279e0 ffffffffa2697745 0000000081187c24

[ 1292.662360] Call Trace:

[ 1292.662406] dump_stack (lib/dump_stack.c:53)
[ 1292.662463] kasan_report_error (mm/kasan/report.c:139 mm/kasan/report.c:178 mm/kasan/report.c:274)
[ 1292.662489] __asan_report_load8_noabort (mm/kasan/report.c:317)
[ 1292.662515] unmapped_area_topdown (mm/mmap.c:1750)
[ 1292.662542] arch_get_unmapped_area_topdown (include/linux/mm.h:2077 arch/x86/kernel/sys_x86_64.c:203)
[ 1292.662603] get_unmapped_area (mm/mmap.c:1915)
[ 1292.662615] do_mmap (mm/mmap.c:1184)
[ 1292.662626] vm_mmap_pgoff (mm/util.c:304)
[ 1292.662674] SyS_mmap_pgoff (mm/mmap.c:1337 mm/mmap.c:1295)
[ 1292.662752] SyS_mmap (arch/x86/kernel/sys_x86_64.c:86)
[ 1292.662772] do_syscall_64 (arch/x86/entry/common.c:350)
[ 1292.662833] entry_SYSCALL64_slow_path (arch/x86/entry/entry_64.S:251)
[ 1292.662841] Object at ffff8801c58b7000, in cache vm_area_struct

[ 1292.662844] Object allocated with size 192 bytes.

[ 1292.662846] Allocation:

[ 1292.662849] PID = 10741

[ 1292.662869] save_stack_trace (arch/x86/kernel/stacktrace.c:68)
[ 1292.662882] save_stack (mm/kasan/kasan.c:478 mm/kasan/kasan.c:499)
[ 1292.662893] kasan_kmalloc (mm/kasan/kasan.c:510 mm/kasan/kasan.c:616)
[ 1292.662905] kasan_slab_alloc (mm/kasan/kasan.c:534)
[ 1292.662917] kmem_cache_alloc (mm/slab.h:419 include/linux/memcontrol.h:781 mm/slab.h:422 mm/slub.c:2696 mm/slub.c:2704 mm/slub.c:2709)
[ 1292.662933] copy_process (kernel/fork.c:463 kernel/fork.c:970 kernel/fork.c:1024 kernel/fork.c:1490)
[ 1292.662945] _do_fork (kernel/fork.c:1775)
[ 1292.662956] SyS_clone (kernel/fork.c:1872)
[ 1292.662967] do_syscall_64 (arch/x86/entry/common.c:350)
[ 1292.662981] return_from_SYSCALL_64 (arch/x86/entry/entry_64.S:251)
[ 1292.662983] Memory state around the buggy address:

[ 1292.663000]  ffff8801c58b6f00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

[ 1292.663008]  ffff8801c58b6f80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

[ 1292.663016] >ffff8801c58b7000: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb

[ 1292.663020]                                         ^

[ 1292.663028]  ffff8801c58b7080: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc

[ 1292.663035]  ffff8801c58b7100: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
