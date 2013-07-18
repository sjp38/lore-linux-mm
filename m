Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id C19946B0031
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 20:09:03 -0400 (EDT)
Date: Thu, 18 Jul 2013 09:09:01 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: hugepage related lockdep trace.
Message-ID: <20130718000901.GA31972@blaptop>
References: <20130717153223.GD27731@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130717153223.GD27731@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Cc: Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

Ccing people get_maintainer says.

On Wed, Jul 17, 2013 at 11:32:23AM -0400, Dave Jones wrote:
> [128095.470960] =================================
> [128095.471315] [ INFO: inconsistent lock state ]
> [128095.471660] 3.11.0-rc1+ #9 Not tainted
> [128095.472156] ---------------------------------
> [128095.472905] inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage.
> [128095.473650] kswapd0/49 [HC0[0]:SC0[0]:HE1:SE1] takes:
> [128095.474373]  (&mapping->i_mmap_mutex){+.+.?.}, at: [<c114971b>] page_referenced+0x87/0x5e3
> [128095.475128] {RECLAIM_FS-ON-W} state was registered at:
> [128095.475866]   [<c10a6232>] mark_held_locks+0x81/0xe7
> [128095.476597]   [<c10a8db3>] lockdep_trace_alloc+0x5e/0xbc
> [128095.477322]   [<c112316b>] __alloc_pages_nodemask+0x8b/0x9b6
> [128095.478049]   [<c1123ab6>] __get_free_pages+0x20/0x31
> [128095.478769]   [<c1123ad9>] get_zeroed_page+0x12/0x14
> [128095.479477]   [<c113fe1e>] __pmd_alloc+0x1c/0x6b
> [128095.480138]   [<c1155ea7>] huge_pmd_share+0x265/0x283
> [128095.480138]   [<c1155f22>] huge_pte_alloc+0x5d/0x71
> [128095.480138]   [<c115612e>] hugetlb_fault+0x7c/0x64a
> [128095.480138]   [<c114087c>] handle_mm_fault+0x255/0x299
> [128095.480138]   [<c15bbab0>] __do_page_fault+0x142/0x55c
> [128095.480138]   [<c15bbed7>] do_page_fault+0xd/0x16
> [128095.480138]   [<c15b927c>] error_code+0x6c/0x74
> [128095.480138] irq event stamp: 3136917
> [128095.480138] hardirqs last  enabled at (3136917): [<c15b8139>] _raw_spin_unlock_irq+0x27/0x50
> [128095.480138] hardirqs last disabled at (3136916): [<c15b7f4e>] _raw_spin_lock_irq+0x15/0x78
> [128095.480138] softirqs last  enabled at (3136180): [<c1048e4a>] __do_softirq+0x137/0x30f
> [128095.480138] softirqs last disabled at (3136175): [<c1049195>] irq_exit+0xa8/0xaa
> [128095.480138] 
> other info that might help us debug this:
> [128095.480138]  Possible unsafe locking scenario:
> 
> [128095.480138]        CPU0
> [128095.480138]        ----
> [128095.480138]   lock(&mapping->i_mmap_mutex);
> [128095.480138]   <Interrupt>
> [128095.480138]     lock(&mapping->i_mmap_mutex);
> [128095.480138] 
>  *** DEADLOCK ***
> 
> [128095.480138] no locks held by kswapd0/49.
> [128095.480138] 
> stack backtrace:
> [128095.480138] CPU: 1 PID: 49 Comm: kswapd0 Not tainted 3.11.0-rc1+ #9
> [128095.480138] Hardware name: Dell Inc.                 Precision WorkStation 490    /0DT031, BIOS A08 04/25/2008
> [128095.480138]  c1d32630 00000000 ee39fb18 c15b001e ee395780 ee39fb54 c15acdcb c1751845
> [128095.480138]  c1751bbf 00000031 00000000 00000000 00000000 00000000 00000001 00000001
> [128095.480138]  c1751bbf 00000008 ee395c44 00000100 ee39fb88 c10a6130 00000008 0000d8fb
> [128095.480138] Call Trace:
> [128095.480138]  [<c15b001e>] dump_stack+0x4b/0x79
> [128095.480138]  [<c15acdcb>] print_usage_bug+0x1d9/0x1e3
> [128095.480138]  [<c10a6130>] mark_lock+0x1e0/0x261
> [128095.480138]  [<c10a5878>] ? check_usage_backwards+0x109/0x109
> [128095.480138]  [<c10a6cde>] __lock_acquire+0x623/0x17f2
> [128095.480138]  [<c107aa43>] ? sched_clock_cpu+0xcd/0x130
> [128095.480138]  [<c107a7e8>] ? sched_clock_local+0x42/0x12e
> [128095.480138]  [<c10a84cf>] lock_acquire+0x7d/0x195
> [128095.480138]  [<c114971b>] ? page_referenced+0x87/0x5e3
> [128095.480138]  [<c15b3671>] mutex_lock_nested+0x6c/0x3a7
> [128095.480138]  [<c114971b>] ? page_referenced+0x87/0x5e3
> [128095.480138]  [<c114971b>] ? page_referenced+0x87/0x5e3
> [128095.480138]  [<c11661d5>] ? mem_cgroup_charge_statistics.isra.24+0x61/0x9e
> [128095.480138]  [<c114971b>] page_referenced+0x87/0x5e3
> [128095.480138]  [<f8433030>] ? raid0_congested+0x26/0x8a [raid0]
> [128095.480138]  [<c112b9c7>] shrink_page_list+0x3d9/0x947
> [128095.480138]  [<c10a6457>] ? trace_hardirqs_on+0xb/0xd
> [128095.480138]  [<c112c3cf>] shrink_inactive_list+0x155/0x4cb
> [128095.480138]  [<c112cd07>] shrink_lruvec+0x300/0x5ce
> [128095.480138]  [<c112d028>] shrink_zone+0x53/0x14e
> [128095.480138]  [<c112e531>] kswapd+0x517/0xa75
> [128095.480138]  [<c112e01a>] ? mem_cgroup_shrink_node_zone+0x280/0x280
> [128095.480138]  [<c10661ff>] kthread+0xa8/0xaa
> [128095.480138]  [<c10a6457>] ? trace_hardirqs_on+0xb/0xd
> [128095.480138]  [<c15bf737>] ret_from_kernel_thread+0x1b/0x28
> [128095.480138]  [<c1066157>] ? insert_kthread_work+0x63/0x63

IMHO, it's a false positive because i_mmap_mutex was held by kswapd
while one in the middle of fault path could be never on kswapd context.

It seems lockdep for reclaim-over-fs isn't enough smart to identify
between background and direct reclaim.

Wait for other's opinion.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
