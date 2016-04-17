Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8889D6B007E
	for <linux-mm@kvack.org>; Sun, 17 Apr 2016 07:12:19 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id h6so311474191ywc.3
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 04:12:19 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id f6si43308405qhd.112.2016.04.17.04.12.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Apr 2016 04:12:18 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: mm: memory corruption on mmput
Message-ID: <57136F8C.9060307@oracle.com>
Date: Sun, 17 Apr 2016 07:12:12 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>

Hi all,

I've hit the following while fuzzing with syzkaller inside a KVM tools guest
running the latest -next kernel:

[ 1065.516003] BUG: Bad page map in process syz-executor  pte:00007025 pmd:1b5743067

[ 1065.516016] page:ffffea00000001c0 count:1 mapcount:-1 mapping:          (null) index:0x0

[ 1065.516025] flags: 0xfffff80000404(referenced|reserved)

[ 1065.516027] page dumped because: bad pte

[ 1065.516033] addr:0000000000405000 vm_flags:08000875 anon_vma:          (null) mapping:ffff8801d2914de8 index:5

[ 1065.516126] file:syz-executor fault:filemap_fault mmap:v9fs_file_mmap readpage:v9fs_vfs_readpage

[ 1065.516173] CPU: 0 PID: 29757 Comm: syz-executor Tainted: G    B           4.6.0-rc3-next-20160412-sasha-00023-g0b02d6d-dirty #2998

[ 1065.516194]  0000000000000000 00000000626373ad ffff8801b232f6c0 ffffffff82fc9d01

[ 1065.516202]  ffffffff00000000 fffffbfff1bad2a0 0000000041b58ab3 ffffffff8d65eee0

[ 1065.516210]  ffffffff82fc9b88 ffff8801b232f6a0 ffffffff816d0a8f 00000000fffffeff

[ 1065.516212] Call Trace:

[ 1065.516238] dump_stack (lib/dump_stack.c:53)
[ 1065.516311] print_bad_pte (mm/memory.c:693 (discriminator 12))
[ 1065.516319] unmap_page_range (mm/memory.c:1163 mm/memory.c:1242 mm/memory.c:1263 mm/memory.c:1284)
[ 1065.516336] unmap_single_vma (mm/memory.c:1329)
[ 1065.516344] unmap_vmas (mm/memory.c:1358 (discriminator 3))
[ 1065.516352] exit_mmap (mm/mmap.c:2757)
[ 1065.516406] mmput (include/linux/compiler.h:222 kernel/fork.c:748 kernel/fork.c:715)
[ 1065.516443] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:92 kernel/exit.c:437 kernel/exit.c:735)
[ 1065.516468] do_group_exit (kernel/exit.c:862)
[ 1065.516476] get_signal (kernel/signal.c:2307)
[ 1065.516490] do_signal (arch/x86/kernel/signal.c:784)
[ 1065.516572] exit_to_usermode_loop (arch/x86/entry/common.c:231)
[ 1065.516582] prepare_exit_to_usermode (arch/x86/entry/common.c:274)
[ 1065.516592] retint_user (arch/x86/entry/entry_64.S:495)
[ 1065.516728] swap_free: Bad swap file entry 000d2880

[ 1065.516736] BUG: Bad page map in process syz-executor  pte:1a510000 pmd:1b5743067

[ 1065.516743] addr:00000000004aa000 vm_flags:08000875 anon_vma:          (null) mapping:ffff8801d2914de8 index:aa

[ 1065.516761] file:syz-executor fault:filemap_fault mmap:v9fs_file_mmap readpage:v9fs_vfs_readpage

[ 1065.516770] CPU: 0 PID: 29757 Comm: syz-executor Tainted: G    B           4.6.0-rc3-next-20160412-sasha-00023-g0b02d6d-dirty #2998

[ 1065.516779]  0000000000000000 00000000626373ad ffff8801b232f6c0 ffffffff82fc9d01

[ 1065.516787]  ffffffff00000000 fffffbfff1bad2a0 0000000041b58ab3 ffffffff8d65eee0

[ 1065.516794]  ffffffff82fc9b88 0000000002000200 00000000626373ad ffffea0002d4f5c0

[ 1065.516798] Call Trace:

[ 1065.516807] dump_stack (lib/dump_stack.c:53)
[ 1065.516868] print_bad_pte (mm/memory.c:693 (discriminator 12))
[ 1065.516877] unmap_page_range (mm/memory.c:1185 mm/memory.c:1242 mm/memory.c:1263 mm/memory.c:1284)
[ 1065.516894] unmap_single_vma (mm/memory.c:1329)
[ 1065.516901] unmap_vmas (mm/memory.c:1358 (discriminator 3))
[ 1065.516909] exit_mmap (mm/mmap.c:2757)
[ 1065.516936] mmput (include/linux/compiler.h:222 kernel/fork.c:748 kernel/fork.c:715)
[ 1065.516969] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:92 kernel/exit.c:437 kernel/exit.c:735)
[ 1065.516994] do_group_exit (kernel/exit.c:862)
[ 1065.517002] get_signal (kernel/signal.c:2307)
[ 1065.517009] do_signal (arch/x86/kernel/signal.c:784)
[ 1065.517059] exit_to_usermode_loop (arch/x86/entry/common.c:231)
[ 1065.517069] prepare_exit_to_usermode (arch/x86/entry/common.c:274)
[ 1065.517077] retint_user (arch/x86/entry/entry_64.S:495)
[ 1065.575917] BUG: Bad page state in process syz-executor  pfn:00007

[ 1065.575928] page:ffffea00000001c0 count:0 mapcount:-1 mapping:          (null) index:0x0

[ 1065.575933] flags: 0xfffff80000404(referenced|reserved)

[ 1065.575936] page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set

[ 1065.575939] bad because of flags: 0x400(reserved)

[ 1065.575950] Modules linked in:

[ 1065.575961] CPU: 0 PID: 29757 Comm: syz-executor Tainted: G    B           4.6.0-rc3-next-20160412-sasha-00023-g0b02d6d-dirty #2998

[ 1065.575972]  0000000000000000 00000000626373ad ffff8801b232f380 ffffffff82fc9d01

[ 1065.575980]  ffffffff00000000 fffffbfff1bad2a0 0000000041b58ab3 ffffffff8d65eee0

[ 1065.575988]  ffffffff82fc9b88 ffffffff8152e630 ffffea00000001e0 ffffffff8b307460

[ 1065.575990] Call Trace:

[ 1065.576005] dump_stack (lib/dump_stack.c:53)
[ 1065.576039] bad_page (./arch/x86/include/asm/atomic.h:38 include/linux/mm.h:488 mm/page_alloc.c:464)
[ 1065.576089] free_pages_prepare (mm/page_alloc.c:808 mm/page_alloc.c:1039)
[ 1065.576108] free_hot_cold_page (mm/page_alloc.c:2193)
[ 1065.576145] free_hot_cold_page_list (mm/page_alloc.c:2239 (discriminator 3))
[ 1065.576153] release_pages (mm/swap.c:715)
[ 1065.576190] free_pages_and_swap_cache (mm/swap_state.c:271)
[ 1065.576199] tlb_flush_mmu_free (mm/memory.c:259 (discriminator 4))
[ 1065.576207] unmap_page_range (mm/memory.c:1206 mm/memory.c:1242 mm/memory.c:1263 mm/memory.c:1284)
[ 1065.576224] unmap_single_vma (mm/memory.c:1329)
[ 1065.576232] unmap_vmas (mm/memory.c:1358 (discriminator 3))
[ 1065.576240] exit_mmap (mm/mmap.c:2757)
[ 1065.576268] mmput (include/linux/compiler.h:222 kernel/fork.c:748 kernel/fork.c:715)
[ 1065.576302] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:92 kernel/exit.c:437 kernel/exit.c:735)
[ 1065.576328] do_group_exit (kernel/exit.c:862)
[ 1065.576335] get_signal (kernel/signal.c:2307)
[ 1065.576344] do_signal (arch/x86/kernel/signal.c:784)
[ 1065.576395] exit_to_usermode_loop (arch/x86/entry/common.c:231)
[ 1065.576404] prepare_exit_to_usermode (arch/x86/entry/common.c:274)
[ 1065.576412] retint_user (arch/x86/entry/entry_64.S:495)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
