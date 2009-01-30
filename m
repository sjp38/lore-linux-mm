Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A6B5B6B005C
	for <linux-mm@kvack.org>; Fri, 30 Jan 2009 03:22:11 -0500 (EST)
Received: by ewy6 with SMTP id 6so211521ewy.14
        for <linux-mm@kvack.org>; Fri, 30 Jan 2009 00:22:09 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 30 Jan 2009 11:22:09 +0300
Message-ID: <a4423d670901300022w1d2fe742kddc94869cce2097d@mail.gmail.com>
Subject: 2.6.29-rc3: page allocation failure
From: Alexander Beregalov <a.beregalov@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I see few messages like the following after running for one day.
I do not know yet if it can be bisected.

rtorrent: page allocation failure. order:1, mode:0x4020
Pid: 2161, comm: rtorrent Not tainted 2.6.29-rc3 #1
Call Trace:
 [<c04104c1>] ? printk+0x18/0x1f
 [<c01651df>] __alloc_pages_internal+0x33f/0x450
 [<c01834b4>] ? deactivate_slab+0x124/0x170
 [<c0183eb4>] __slab_alloc+0x244/0x5f0
 [<c0184f16>] __kmalloc_track_caller+0x106/0x130
 [<c03c3622>] ? tcp_collapse+0x1f2/0x370
 [<c03c3622>] ? tcp_collapse+0x1f2/0x370
 [<c038fab9>] __alloc_skb+0x49/0x100
 [<c03c3622>] tcp_collapse+0x1f2/0x370
 [<c03c398c>] tcp_try_rmem_schedule+0x1ec/0x340
 [<c03c3c32>] tcp_data_queue+0x152/0xb40
 [<c0413727>] ? _read_unlock+0x27/0x50
 [<c03c67c5>] tcp_rcv_established+0x225/0x5c0
 [<c03cd200>] tcp_v4_do_rcv+0x90/0x1b0
 [<c0412e3f>] ? _spin_lock_nested+0x6f/0x80
 [<c03ce6ca>] ? tcp_v4_rcv+0x46a/0x600
 [<c03ce792>] tcp_v4_rcv+0x532/0x600
 [<c03b1bac>] ip_local_deliver+0x6c/0xe0
 [<c03b19d2>] ip_rcv+0x2b2/0x420
 [<c039a20c>] netif_receive_skb+0x24c/0x310
 [<c0349ae8>] nv_napi_poll+0x298/0x670
 [<c015d0bd>] ? __rcu_read_lock+0x6d/0x90
 [<c014c7cb>] ? trace_hardirqs_on+0xb/0x10
 [<c0396436>] net_rx_action+0x106/0x1b0
 [<c014c662>] ? trace_hardirqs_on_caller+0x62/0x1c0
 [<c012cfef>] __do_softirq+0x7f/0x120
 [<c012d0f5>] do_softirq+0x65/0x70
 [<c012d2d3>] irq_exit+0x83/0xa0
 [<c0105475>] do_IRQ+0x55/0xb0
 [<c0103a2c>] common_interrupt+0x2c/0x34
 [<c0184311>] ? kmem_cache_alloc+0xb1/0x100
 [<c028eb60>] ? kmem_zone_alloc+0x80/0xc0
 [<c028eb60>] ? kmem_zone_alloc+0x80/0xc0
 [<c028eb60>] kmem_zone_alloc+0x80/0xc0
 [<c0293280>] xfs_buf_get_flags+0x30/0x140
 [<c0183b75>] ? kmem_cache_free+0x85/0xe0
 [<c029363d>] xfs_buf_read_flags+0x1d/0x90
 [<c0286ab6>] xfs_trans_read_buf+0x2b6/0x530
 [<c024a4ea>] xfs_btree_read_bufl+0x8a/0xe0
 [<c023c3d3>] xfs_bmap_check_leaf_extents+0x513/0x540
 [<c014cc94>] ? __lock_acquire+0x2a4/0x1170
 [<c024334f>] xfs_bmap_add_extent+0x1cf/0x670
 [<c0413507>] ? _spin_unlock+0x27/0x50
 [<c02471ca>] xfs_bmapi+0xfca/0x1c80
 [<c026162b>] ? xfs_error_test+0x1b/0xc0
 [<c02466cf>] ? xfs_bmapi+0x4cf/0x1c80
 [<c0271357>] xfs_iomap_write_delay+0x1e7/0x3a0
 [<c01493ed>] ? put_lock_stats+0xd/0x30
 [<c0271dc9>] xfs_iomap+0x3d9/0x3f0
 [<c0290693>] __xfs_get_blocks+0xa3/0x350
 [<c0290992>] xfs_get_blocks+0x22/0x30
 [<c01aa4c4>] __block_prepare_write+0x1a4/0x380
 [<c014c7cb>] ? trace_hardirqs_on+0xb/0x10
 [<c015f9f8>] ? find_lock_page+0x28/0x70
 [<c01aa6c6>] block_prepare_write+0x26/0x40
 [<c0290970>] ? xfs_get_blocks+0x0/0x30
 [<c01aa7b4>] block_page_mkwrite+0xd4/0x100
 [<c0290970>] ? xfs_get_blocks+0x0/0x30
 [<c0290970>] ? xfs_get_blocks+0x0/0x30
 [<c0293ca0>] ? xfs_vm_page_mkwrite+0x0/0x10
 [<c0293cad>] xfs_vm_page_mkwrite+0xd/0x10
 [<c01739de>] __do_fault+0x8e/0x350
 [<c0174480>] handle_mm_fault+0x100/0x590
 [<c013f77d>] ? down_read_trylock+0x5d/0x70
 [<c0119458>] do_page_fault+0x288/0x740
 [<c0108e01>] ? native_sched_clock+0x21/0x70
 [<c0108e01>] ? native_sched_clock+0x21/0x70
 [<c01493ed>] ? put_lock_stats+0xd/0x30
 [<c014b512>] ? lock_release_holdtime+0x92/0x190
 [<c014dc86>] ? lock_release_non_nested+0x96/0x2a0
 [<c01191d0>] ? do_page_fault+0x0/0x740
 [<c0413b0f>] error_code+0x6f/0x74
 [<c02c3782>] ? copy_to_user+0x112/0x130
 [<c0392b1b>] memcpy_toiovec+0x4b/0x70
 [<c0393347>] skb_copy_datagram_iovec+0x47/0x1e0
 [<c014c7cb>] ? trace_hardirqs_on+0xb/0x10
 [<c03bd6ba>] tcp_recvmsg+0x54a/0x8e0
 [<c038b8c3>] sock_common_recvmsg+0x43/0x60
 [<c038a063>] sock_recvmsg+0xd3/0x100
 [<c013be90>] ? autoremove_wake_function+0x0/0x40
 [<c014b512>] ? lock_release_holdtime+0x92/0x190
 [<c0174480>] ? handle_mm_fault+0x100/0x590
 [<c013f8f6>] ? up_read+0x16/0x30
 [<c01194ae>] ? do_page_fault+0x2de/0x740
 [<c038ae38>] sys_recvfrom+0x78/0xd0
 [<c0108e01>] ? native_sched_clock+0x21/0x70
 [<c01493ed>] ? put_lock_stats+0xd/0x30
 [<c014b512>] ? lock_release_holdtime+0x92/0x190
 [<c014dc86>] ? lock_release_non_nested+0x96/0x2a0
 [<c01719d2>] ? might_fault+0x52/0xa0
 [<c01719d2>] ? might_fault+0x52/0xa0
 [<c038aec6>] sys_recv+0x36/0x40
 [<c038b361>] sys_socketcall+0x181/0x270
 [<c02c2ff4>] ? trace_hardirqs_on_thunk+0xc/0x10
 [<c0103405>] sysenter_do_call+0x12/0x35
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd: 141
HighMem per-cpu:
CPU    0: hi:  186, btch:  31 usd:  30
Active_anon:14536 active_file:84384 inactive_anon:20635
 inactive_file:243524 unevictable:0 dirty:382 writeback:0 unstable:0
 free:9441 slab:12147 mapped:5471 pagetables:207 bounce:0
DMA free:3488kB min:64kB low:80kB high:96kB active_anon:0kB
inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB
present:15860kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 865 1508 1508
Normal free:33096kB min:3728kB low:4660kB high:5592kB active_anon:8kB
inactive_anon:1184kB active_file:214720kB inactive_file:575176kB
unevictable:0kB present:885944kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 5143 5143
HighMem free:1180kB min:512kB low:1204kB high:1896kB
active_anon:58136kB inactive_anon:81356kB active_file:122816kB
inactive_file:398920kB unevictable:0kB present:658312kB
pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 2*4kB 3*8kB 0*16kB 0*32kB 0*64kB 1*128kB 1*256kB 0*512kB 1*1024kB
1*2048kB 0*4096kB = 3488kB
Normal: 8122*4kB 0*8kB 2*16kB 2*32kB 0*64kB 0*128kB 0*256kB 1*512kB
0*1024kB 0*2048kB 0*4096kB = 33096kB
HighMem: 5*4kB 3*8kB 9*16kB 5*32kB 3*64kB 1*128kB 0*256kB 1*512kB
0*1024kB 0*2048kB 0*4096kB = 1180kB
327949 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 498004kB
Total swap = 498004kB
393200 pages RAM
165874 pages HighMem
6205 pages reserved
117186 pages shared
269142 pages non-shared

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
