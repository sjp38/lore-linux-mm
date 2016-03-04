Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 903C96B007E
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 23:20:16 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fl4so27388780pad.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 20:20:16 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id p8si2838878pfi.111.2016.03.03.20.20.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 20:20:15 -0800 (PST)
Subject: Re: [PATCHv3 00/29] huge tmpfs implementation using compound pages
References: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
From: Sasha Levin <sasha.levin@oracle.com>
Message-ID: <56D90CF0.9070500@oracle.com>
Date: Thu, 3 Mar 2016 23:20:00 -0500
MIME-Version: 1.0
In-Reply-To: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/03/2016 11:51 AM, Kirill A. Shutemov wrote:
> I consider it feature complete for initial step into upstream. I'll focus
> on validation now. I work with Sasha on that.

Hey Kirill,

I see the following two (separate) issues. I haven't hit them ever before, so
I suspect that while they seem unrelated, they are somehow caused by this series.

First:

[ 1386.011801] ==================================================================

[ 1386.011901] BUG: KASAN: use-after-free in __fget+0x4fa/0x540 at addr ffff8801afe43b34

[ 1386.011922] Read of size 4 by task syz-executor/22976

[ 1386.011939] =============================================================================

[ 1386.011959] BUG filp (Not tainted): kasan: bad access detected

[ 1386.011969] -----------------------------------------------------------------------------

[ 1386.011969]

[ 1386.011976] Disabling lock debugging due to kernel taint

[ 1386.012005] INFO: Slab 0xffffea0006bf9000 objects=19 used=16 fp=0xffff8801afe40040 flags=0x2fffff80004080

[ 1386.012027] INFO: Object 0xffff8801afe43a80 @offset=14976 fp=0xbbbbbbbbbbbbbbbb

[ 1386.012027]

[ 1386.012061] Redzone ffff8801afe43a40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1386.012087] Redzone ffff8801afe43a50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1386.012112] Redzone ffff8801afe43a60: 02 00 00 00 68 30 00 00 3b 55 0e 00 01 00 00 00  ....h0..;U......

[ 1386.012133] Redzone ffff8801afe43a70: 00 00 00 00 00 00 00 00 40 aa 90 ac ff ff ff ff  ........@.......

[ 1386.012156] Object ffff8801afe43a80: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................

[ 1386.012181] Object ffff8801afe43a90: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................

[ 1386.012206] Object ffff8801afe43aa0: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................

[ 1386.012230] Object ffff8801afe43ab0: bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb bb  ................

[ 1386.012251] Object ffff8801afe43ac0: 00 00 00 00 00 00 00 00 70 03 8c a1 ff ff ff ff  ........p.......

[ 1386.012278] Object ffff8801afe43ad0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1386.012298] Object ffff8801afe43ae0: 00 00 00 00 00 00 00 00 c0 65 94 ac ff ff ff ff  .........e......

[ 1386.012317] Object ffff8801afe43af0: 00 00 00 00 ad 4e ad de ff ff ff ff 00 00 00 00  .....N..........

[ 1386.012333] Object ffff8801afe43b00: ff ff ff ff ff ff ff ff 00 e0 57 bc ff ff ff ff  ..........W.....

[ 1386.012351] Object ffff8801afe43b10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1386.012367] Object ffff8801afe43b20: e0 b6 93 ac ff ff ff ff 00 00 00 00 00 00 00 00  ................

[ 1386.012382] Object ffff8801afe43b30: 01 80 00 00 1e 00 04 00 01 00 00 00 00 00 00 00  ................

[ 1386.012394] Object ffff8801afe43b40: 00 00 00 00 ad 4e ad de ff ff ff ff 00 00 00 00  .....N..........

[ 1386.012405] Object ffff8801afe43b50: ff ff ff ff ff ff ff ff 40 35 6a bb ff ff ff ff  ........@5j.....

[ 1386.012416] Object ffff8801afe43b60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1386.012427] Object ffff8801afe43b70: c0 c4 8c ac ff ff ff ff 78 3b e4 af 01 88 ff ff  ........x;......

[ 1386.012438] Object ffff8801afe43b80: 78 3b e4 af 01 88 ff ff 00 00 00 00 00 00 00 00  x;..............

[ 1386.012450] Object ffff8801afe43b90: 38 3b e4 af 01 88 ff ff c0 df 57 bc ff ff ff ff  8;........W.....

[ 1386.012461] Object ffff8801afe43ba0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1386.012472] Object ffff8801afe43bb0: 20 b7 93 ac ff ff ff ff 00 00 00 00 00 00 00 00   ...............

[ 1386.012483] Object ffff8801afe43bc0: 00 00 00 00 00 00 00 00 ed 1e af de ff ff ff ff  ................

[ 1386.012494] Object ffff8801afe43bd0: ff ff ff ff ff ff ff ff 40 e0 57 bc ff ff ff ff  ........@.W.....

[ 1386.012506] Object ffff8801afe43be0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1386.012517] Object ffff8801afe43bf0: a0 b6 93 ac ff ff ff ff 00 00 00 00 00 00 00 00  ................

[ 1386.012528] Object ffff8801afe43c00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1386.012539] Object ffff8801afe43c10: 40 b6 d5 b2 00 88 ff ff 00 00 00 00 00 00 00 00  @...............

[ 1386.012550] Object ffff8801afe43c20: 00 00 00 00 00 00 00 00 20 00 00 00 00 00 00 00  ........ .......

[ 1386.012561] Object ffff8801afe43c30: ff ff ff ff ff ff ff ff                          ........

[ 1386.012572] Redzone ffff8801afe43c38: 00 00 00 00 00 00 00 00                          ........

[ 1386.012583] Padding ffff8801afe43d70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................

[ 1386.012607] CPU: 1 PID: 22976 Comm: syz-executor Tainted: G    B           4.5.0-rc6-next-20160301-sasha-00054-g4c13c38-dirty #2987

[ 1386.012636]  0000000000000000 ffff8800b2097d08 ffffffffa33db57d ffffffff00000001

[ 1386.012651]  fffffbfff5e6cc08 0000000041b58ab3 ffffffffaecc1ee9 ffffffffa33db3e5

[ 1386.012666]  000000002e90934f ffff8801b1744000 ffffffffaecdeceb ffff8801afe43a80

[ 1386.012669] Call Trace:

[ 1386.012713] dump_stack (lib/dump_stack.c:53)
[ 1386.012731] ? arch_local_irq_restore (init/do_mounts.h:17)
[ 1386.012749] ? print_section (./arch/x86/include/asm/current.h:14 include/linux/kasan.h:35 mm/slub.c:481 mm/slub.c:512)
[ 1386.012763] print_trailer (mm/slub.c:670)
[ 1386.012778] object_err (mm/slub.c:677)
[ 1386.012794] kasan_report_error (include/linux/kasan.h:28 mm/kasan/report.c:170 mm/kasan/report.c:237)
[ 1386.012920] __asan_report_load4_noabort (mm/kasan/report.c:279)
[ 1386.012946] __fget (fs/file.c:707)
[ 1386.012996] __fget_light (fs/file.c:757)
[ 1386.013009] __fdget (fs/file.c:765)
[ 1386.013030] SyS_ioctl (include/linux/file.h:55 fs/ioctl.c:683 fs/ioctl.c:680)
[ 1386.013051] entry_SYSCALL_64_fastpath (arch/x86/entry/entry_64.S:200)
[ 1386.013056] Memory state around the buggy address:

[ 1386.013069]  ffff8801afe43a00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc

[ 1386.013080]  ffff8801afe43a80: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb

[ 1386.013090] >ffff8801afe43b00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb

[ 1386.013094]                                      ^

[ 1386.013105]  ffff8801afe43b80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb

[ 1386.013115]  ffff8801afe43c00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fc

[ 1386.013119] ==================================================================

And second:

[ 2328.415149] ------------[ cut here ]------------

[ 2328.417960] WARNING: CPU: 2 PID: 13358 at arch/x86/mm/pat.c:986 untrack_pfn+0x24e/0x2d0

[ 2328.418852] Modules linked in:

[ 2328.419257] CPU: 2 PID: 13358 Comm: syz-executor Not tainted 4.5.0-rc6-next-20160301-sasha-00054-g4c13c38-dirty #2987

[ 2328.420445]  0000000000000000 ffff88000cad77c0 ffffffffa43db57d ffffffff00000002

[ 2328.421392]  fffffbfff606cc08 0000000041b58ab3 ffffffffafcc1ee9 ffffffffa43db3e5

[ 2328.422295]  ffffffffa2598b50 0000000020000000 0000000041b58ab3 ffffffffafcddf50

[ 2328.423234] Call Trace:

[ 2328.423583] dump_stack (lib/dump_stack.c:53)
[ 2328.424184] ? arch_local_irq_restore (init/do_mounts.h:17)
[ 2328.424917] ? is_module_text_address (kernel/module.c:4033)
[ 2328.425668] ? vm_insert_mixed (mm/memory.c:3737)
[ 2328.426385] ? untrack_pfn (arch/x86/mm/pat.c:986 (discriminator 3))
[ 2328.427036] __warn (kernel/panic.c:492)
[ 2328.439719] warn_slowpath_null (kernel/panic.c:528)
[ 2328.440792] untrack_pfn (arch/x86/mm/pat.c:986 (discriminator 3))
[ 2328.441606] ? track_pfn_insert (arch/x86/mm/pat.c:975)
[ 2328.442418] ? do_wp_page (mm/memory.c:1235)
[ 2328.443099] unmap_single_vma (mm/memory.c:1270)
[ 2328.443975] unmap_vmas (mm/memory.c:1320 (discriminator 3))
[ 2328.452015] exit_mmap (mm/mmap.c:2769)
[ 2328.452868] ? SyS_munmap (mm/mmap.c:2739)
[ 2328.453798] ? do_raw_spin_unlock (kernel/locking/spinlock_debug.c:160)
[ 2328.454498] ? __might_sleep (kernel/sched/core.c:7736 (discriminator 14))
[ 2328.455113] mmput (kernel/fork.c:715)
[ 2328.455666] do_exit (./arch/x86/include/asm/bitops.h:311 include/linux/thread_info.h:92 kernel/exit.c:437 kernel/exit.c:735)
[ 2328.456251] ? mm_update_next_owner (kernel/exit.c:653)
[ 2328.456952] ? __dequeue_signal (kernel/signal.c:546)
[ 2328.457643] ? do_sigaltstack (kernel/signal.c:546)
[ 2328.458351] ? _raw_spin_unlock_irq (./arch/x86/include/asm/paravirt.h:801 include/linux/spinlock_api_smp.h:170 kernel/locking/spinlock.c:199)
[ 2328.459063] do_group_exit (include/linux/sched.h:815 kernel/exit.c:861)
[ 2328.459698] get_signal (kernel/signal.c:2327)
[ 2328.460363] do_signal (arch/x86/kernel/signal.c:784)
[ 2328.460956] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2540 kernel/locking/lockdep.c:2587)
[ 2328.461750] ? trace_hardirqs_on (kernel/locking/lockdep.c:2595)
[ 2328.462469] ? setup_sigcontext (arch/x86/kernel/signal.c:781)
[ 2328.463134] ? finish_task_switch (./arch/x86/include/asm/current.h:14 kernel/sched/core.c:2746)
[ 2328.469533] ? finish_task_switch (kernel/sched/sched.h:1101 kernel/sched/core.c:2743)
[ 2328.470303] ? rcu_read_unlock (kernel/sched/core.c:2706)
[ 2328.470966] ? SyS_futex (kernel/futex.c:3182)
[ 2328.471615] ? exit_to_usermode_loop (./arch/x86/include/asm/paravirt.h:801 arch/x86/entry/common.c:238)
[ 2328.473334] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2540 kernel/locking/lockdep.c:2587)
[ 2328.474135] exit_to_usermode_loop (arch/x86/entry/common.c:248)
[ 2328.476051] ? trace_hardirqs_on_caller (kernel/locking/lockdep.c:2540 kernel/locking/lockdep.c:2587)
[ 2328.476827] syscall_return_slowpath (arch/x86/entry/common.c:283 arch/x86/entry/common.c:348)
[ 2328.478821] entry_SYSCALL_64_fastpath (arch/x86/entry/entry_64.S:232)
[ 2328.486429] ---[ end trace be1dc5a23ab2ebe4 ]---


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
