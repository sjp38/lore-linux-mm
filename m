Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F3A82803BB
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 07:39:05 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id a3so1329104pgd.15
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 04:39:05 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c64si2680817pfl.530.2017.08.24.04.39.03
        for <linux-mm@kvack.org>;
        Thu, 24 Aug 2017 04:39:03 -0700 (PDT)
Date: Thu, 24 Aug 2017 12:37:43 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Intermittent memory corruption with v4.13-rc6+ and earlier
Message-ID: <20170824113743.GA14737@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: syzkaller@googlegroups.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, will.deacon@arm.com

Hi,

I'm chasing intermittent memory corruption bugs seen at least on rc5,
rc6, and yesterday's HEAD (98b9f8a4549909c6), on arm64. 

It looks like we make use of dangling references to a freed struct file,
which is caught by KASAN. Without KASAN, I see a number of other
intermittent issues that I suspect are the result of this memory
corruption. I've included an example splat below, complete with KASAN's
alloc/free traces at the end of this mail.

I've dumped more info in the bugs/20170824-file-uaf directory in my
kernel.org web space [1], including a number of logs, my kernel config,
and Syzkaller reproducers (original and partially minimized). The bug
can be triggered with either, but the original is much faster (minutes
vs hours on average).

I haven't yet tried to bisect this, but I intend to shortly. In prior
testing. I hadn't seen these issues with v4.12, but I've upgraded
Syzkaller in the mean time, and it's possible its now triggering paths
which it didn't in the past.

I'll attack v4.12 with the reproducer to make sure, and attempt a bisect
from there. Any suggestions welcome.

Thanks,
Mark.

[1] https://www.kernel.org/pub/linux/kernel/people/mark/bugs/20170824-file-uaf/

----->8----
[17631.541544] ==================================================================
[17631.542778] BUG: KASAN: use-after-free in get_mm_exe_file+0x244/0x250
[17631.543614] Read of size 8 at addr ffff80000b456ab0 by task syz-executor0/1399
[17631.544543]
[17631.544792] CPU: 3 PID: 1399 Comm: syz-executor0 Not tainted 4.13.0-rc6-00050-g98b9f8a #1
[17631.546081] Hardware name: linux,dummy-virt (DT)
[17631.546826] Call trace:
[17631.547229] [<ffff200008090b08>] dump_backtrace+0x0/0x490
[17631.548046] [<ffff2000080912c0>] show_stack+0x20/0x30
[17631.548779] [<ffff200009a9feb0>] dump_stack+0xd0/0x120
[17631.549525] [<ffff200008432df0>] print_address_description+0x60/0x250
[17631.550452] [<ffff2000084332d8>] kasan_report+0x238/0x2f8
[17631.551289] [<ffff200008433410>] __asan_report_load8_noabort+0x18/0x20
[17631.552302] [<ffff200008117f84>] get_mm_exe_file+0x244/0x250
[17631.553121] [<ffff20000811cfa4>] copy_process.isra.5.part.6+0x3584/0x4b88
[17631.554085] [<ffff20000811e8cc>] _do_fork+0x15c/0x938
[17631.554797] [<ffff20000811f208>] SyS_clone+0x48/0x60
[17631.555507] [<ffff200008083f70>] el0_svc_naked+0x24/0x28
[17631.556292]
[17631.556534] Allocated by task 1398:
[17631.557106]  save_stack_trace_tsk+0x0/0x378
[17631.558024]  save_stack_trace+0x20/0x30
[17631.558630]  kasan_kmalloc+0xd8/0x188
[17631.559143]  kasan_slab_alloc+0x14/0x20
[17631.559715]  kmem_cache_alloc+0x124/0x208
[17631.560407]  get_empty_filp+0x8c/0x328
[17631.560994]  path_openat+0xb8/0x1c20
[17631.561540]  do_filp_open+0x138/0x1f0
[17631.562096]  do_open_execat+0xcc/0x3e8
[17631.562666]  do_execveat_common.isra.15+0x5c0/0x1490
[17631.563700]  SyS_execve+0x48/0x60
[17631.564314]  el0_svc_naked+0x24/0x28
[17631.565058]
[17631.565345] Freed by task 0:
[17631.565970]  save_stack_trace_tsk+0x0/0x378
[17631.566710]  save_stack_trace+0x20/0x30
[17631.567308]  kasan_slab_free+0x88/0x188
[17631.568052]  kmem_cache_free+0x88/0x230
[17631.568647]  file_free_rcu+0x6c/0x80
[17631.569399]  rcu_process_callbacks+0x3e4/0x958
[17631.570323]  __do_softirq+0x304/0x6c4
[17631.571079]
[17631.571337] The buggy address belongs to the object at ffff80000b456a40
[17631.571337]  which belongs to the cache filp of size 456
[17631.573323] The buggy address is located 112 bytes inside of
[17631.573323]  456-byte region [ffff80000b456a40, ffff80000b456c08)
[17631.575775] The buggy address belongs to the page:
[17631.576599] page:ffff7e00002d1500 count:1 mapcount:0 mapping:          (null) index:0xffff80000b457140 compound_mapcount: 0
[17631.578386] flags: 0xfffc00000008100(slab|head)
[17631.579126] raw: 0fffc00000008100 0000000000000000 ffff80000b457140 000000010012000c
[17631.580320] raw: ffff7e0000307620 ffff80000c04eb40 ffff80000c053880 0000000000000000
[17631.581619] page dumped because: kasan: bad access detected
[17631.582498]
[17631.582754] Memory state around the buggy address:
[17631.583746]  ffff80000b456980: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
[17631.584853]  ffff80000b456a00: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
[17631.586351] >ffff80000b456a80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[17631.587869]                                      ^
[17631.588887]  ffff80000b456b00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[17631.590130]  ffff80000b456b80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[17631.591327] ==================================================================
[17631.592494] Disabling lock debugging due to kernel taint
[17631.594702] Kernel panic - not syncing: panic_on_warn set ...
[17631.594702]
[17631.595635] CPU: 3 PID: 1399 Comm: syz-executor0 Tainted: G    B           4.13.0-rc6-00050-g98b9f8a #1
[17631.597704] Hardware name: linux,dummy-virt (DT)
[17631.598457] Call trace:
[17631.598957] [<ffff200008090b08>] dump_backtrace+0x0/0x490
[17631.600128] [<ffff2000080912c0>] show_stack+0x20/0x30
[17631.601225] [<ffff200009a9feb0>] dump_stack+0xd0/0x120
[17631.602324] [<ffff2000081209ec>] panic+0x208/0x3e4
[17631.603190] [<ffff200008432d68>] kasan_save_enable_multi_shot+0x0/0x28
[17631.604581] [<ffff200008433198>] kasan_report+0xf8/0x2f8
[17631.605501] [<ffff200008433410>] __asan_report_load8_noabort+0x18/0x20
[17631.606891] [<ffff200008117f84>] get_mm_exe_file+0x244/0x250
[17631.608114] [<ffff20000811cfa4>] copy_process.isra.5.part.6+0x3584/0x4b88
[17631.609525] [<ffff20000811e8cc>] _do_fork+0x15c/0x938
[17631.610577] [<ffff20000811f208>] SyS_clone+0x48/0x60
[17631.611623] [<ffff200008083f70>] el0_svc_naked+0x24/0x28
[17631.612447] SMP: stopping secondary CPUs
[17631.631714] Kernel Offset: disabled
[17631.632477] CPU features: 0x002082
[17631.633117] Memory Limit: none
[17631.633795] Rebooting in 86400 seconds..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
