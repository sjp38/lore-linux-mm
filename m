Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 089B36B0044
	for <linux-mm@kvack.org>; Sun, 20 Dec 2009 06:47:33 -0500 (EST)
Received: from localhost (localhost [127.0.0.1])
	by mail.opencsw.org (Postfix) with ESMTP id 0B31A3A6
	for <linux-mm@kvack.org>; Sun, 20 Dec 2009 12:47:30 +0100 (CET)
Received: from mail.opencsw.org ([127.0.0.1])
	by localhost (mail.opencsw.org [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id aFuDEOTWGbui for <linux-mm@kvack.org>;
	Sun, 20 Dec 2009 12:47:22 +0100 (CET)
Received: from jashugan.kinali.ch (jashugan.kinali.ch [82.197.186.51])
	by mail.opencsw.org (Postfix) with SMTP id 2A3663A5
	for <linux-mm@kvack.org>; Sun, 20 Dec 2009 12:47:22 +0100 (CET)
Date: Sun, 20 Dec 2009 12:47:21 +0100
From: Attila Kinali <attila@kinali.ch>
Subject: page allocation failure - still unfixed in 2.6.32.1
Message-Id: <20091220124721.006da86a.attila@kinali.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Moin,

The page allocation failure that was introduced in 2.6.31 and
which has been discussed here a few times, is still present in
2.6.32.1. I can still (more or less) reproduce it on my home-fileserver:

Dec 20 11:43:14 koyomi kernel: swapper: page allocation failure. order:3, mode:0x20
Dec 20 11:43:14 koyomi kernel: Pid: 0, comm: swapper Not tainted 2.6.32.1 #1
Dec 20 11:43:14 koyomi kernel: Call Trace:
Dec 20 11:43:14 koyomi kernel:  [<c106581c>] ? __alloc_pages_nodemask+0x49c/0x580
Dec 20 11:43:14 koyomi kernel:  [<c1288dc8>] ? ipt_do_table+0x238/0x3d0
Dec 20 11:43:14 koyomi kernel:  [<c1082f7c>] ? cache_alloc_refill+0x2bc/0x510
Dec 20 11:43:14 koyomi kernel:  [<c10832a9>] ? __kmalloc+0xd9/0xe0
Dec 20 11:43:14 koyomi kernel:  [<c1213c83>] ? pskb_expand_head+0x53/0x180
Dec 20 11:43:14 koyomi kernel:  [<c12141cf>] ? __pskb_pull_tail+0x4f/0x300
Dec 20 11:43:14 koyomi kernel:  [<c122f2d6>] ? nf_iterate+0x76/0x90
Dec 20 11:43:14 koyomi kernel:  [<c121c061>] ? dev_queue_xmit+0x181/0x500
Dec 20 11:43:14 koyomi kernel:  [<c122f47f>] ? nf_hook_slow+0x9f/0xe0
Dec 20 11:43:14 koyomi kernel:  [<c124f930>] ? ip_finish_output+0x0/0x2b0
Dec 20 11:43:14 koyomi kernel:  [<c124fb27>] ? ip_finish_output+0x1f7/0x2b0
Dec 20 11:43:14 koyomi kernel:  [<c124eb55>] ? ip_local_out+0x15/0x20
Dec 20 11:43:14 koyomi kernel:  [<c124f33b>] ? ip_queue_xmit+0x1ab/0x3d0
Dec 20 11:43:14 koyomi kernel:  [<c128a556>] ? nf_nat_out+0x66/0xf0
Dec 20 11:43:14 koyomi kernel:  [<c10150d3>] ? smp_reschedule_interrupt+0x13/0x20
Dec 20 11:43:14 koyomi kernel:  [<c123324c>] ? __nf_ct_refresh_acct+0x5c/0xf0
Dec 20 11:43:14 koyomi kernel:  [<c12382f9>] ? tcp_packet+0x8c9/0xf00
Dec 20 11:43:14 koyomi kernel:  [<c1261fa6>] ? tcp_transmit_skb+0x476/0x6d0
Dec 20 11:43:14 koyomi kernel:  [<c12148b2>] ? __alloc_skb+0x52/0x130
Dec 20 11:43:14 koyomi kernel:  [<c12640a4>] ? tcp_write_xmit+0x1f4/0x9e0
Dec 20 11:43:14 koyomi kernel:  [<c12615c3>] ? tcp_current_mss+0x33/0x60
Dec 20 11:43:14 koyomi kernel:  [<c126490f>] ? __tcp_push_pending_frames+0x2f/0x90
Dec 20 11:43:14 koyomi kernel:  [<c125fbed>] ? tcp_rcv_established+0x13d/0x8b0
Dec 20 11:43:14 koyomi kernel:  [<c1267293>] ? tcp_v4_do_rcv+0xc3/0x200
Dec 20 11:43:14 koyomi kernel:  [<c124a9b0>] ? ip_local_deliver_finish+0x0/0x1c0
Dec 20 11:43:14 koyomi kernel:  [<c1267a79>] ? tcp_v4_rcv+0x6a9/0x770
Dec 20 11:43:14 koyomi kernel:  [<c124aa33>] ? ip_local_deliver_finish+0x83/0x1c0
Dec 20 11:43:14 koyomi kernel:  [<c124a9b0>] ? ip_local_deliver_finish+0x0/0x1c0
Dec 20 11:43:14 koyomi kernel:  [<c124a4bb>] ? ip_rcv_finish+0x15b/0x360
Dec 20 11:43:14 koyomi kernel:  [<c124a360>] ? ip_rcv_finish+0x0/0x360
Dec 20 11:43:14 koyomi kernel:  [<c121af25>] ? netif_receive_skb+0x235/0x2c0
Dec 20 11:43:14 koyomi kernel:  [<f805cd04>] ? e1000_clean_rx_irq+0x2f4/0x480 [e1000]
Dec 20 11:43:14 koyomi kernel:  [<f8061a7a>] ? e1000_clean+0x1ea/0x540 [e1000]
Dec 20 11:43:14 koyomi kernel:  [<c121b61f>] ? net_rx_action+0x8f/0x120
Dec 20 11:43:14 koyomi kernel:  [<c10304fc>] ? __do_softirq+0x8c/0x110
Dec 20 11:43:14 koyomi kernel:  [<c10305ad>] ? do_softirq+0x2d/0x40
Dec 20 11:43:14 koyomi kernel:  [<c1004e70>] ? do_IRQ+0x50/0xc0
Dec 20 11:43:14 koyomi kernel:  [<c1016166>] ? smp_apic_timer_interrupt+0x56/0x90
Dec 20 11:43:14 koyomi kernel:  [<c10034f0>] ? common_interrupt+0x30/0x38
Dec 20 11:43:14 koyomi kernel:  [<c12e007b>] ? cache_open+0x5b/0xd0
Dec 20 11:43:14 koyomi kernel:  [<c100936a>] ? default_idle+0x4a/0x60
Dec 20 11:43:14 koyomi kernel:  [<c1001e24>] ? cpu_idle+0x94/0xb0
Dec 20 11:43:14 koyomi kernel: Mem-Info:
Dec 20 11:43:14 koyomi kernel: DMA per-cpu:
Dec 20 11:43:14 koyomi kernel: CPU    0: hi:    0, btch:   1 usd:   0
Dec 20 11:43:14 koyomi kernel: CPU    1: hi:    0, btch:   1 usd:   0
Dec 20 11:43:14 koyomi kernel: Normal per-cpu:
Dec 20 11:43:14 koyomi kernel: CPU    0: hi:  186, btch:  31 usd: 115
Dec 20 11:43:14 koyomi kernel: CPU    1: hi:  186, btch:  31 usd: 143
Dec 20 11:43:14 koyomi kernel: HighMem per-cpu:
Dec 20 11:43:14 koyomi kernel: CPU    0: hi:  186, btch:  31 usd:   9
Dec 20 11:43:14 koyomi kernel: CPU    1: hi:  186, btch:  31 usd:  27
Dec 20 11:43:14 koyomi kernel: active_anon:806 inactive_anon:9497 isolated_anon:0
Dec 20 11:43:14 koyomi kernel:  active_file:74007 inactive_file:83541 isolated_file:0
Dec 20 11:43:14 koyomi kernel:  unevictable:0 dirty:10 writeback:0 unstable:0
Dec 20 11:43:14 koyomi kernel:  free:215643 slab_reclaimable:65501 slab_unreclaimable:1680
Dec 20 11:43:14 koyomi kernel:  mapped:1791 shmem:186 pagetables:308 bounce:0
Dec 20 11:43:14 koyomi kernel: DMA free:3504kB min:64kB low:80kB high:96kB active_anon:0kB inactive_anon:0kB active_file:596kB inactive_file:11416kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15864kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:380kB slab_unreclaimable:80kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Dec 20 11:43:14 koyomi kernel: lowmem_reserve[]: 0 865 1762 1762
Dec 20 11:43:14 koyomi kernel: Normal free:62312kB min:3728kB low:4660kB high:5592kB active_anon:0kB inactive_anon:0kB active_file:266576kB inactive_file:266684kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:885944kB mlocked:0kB dirty:36kB writeback:0kB mapped:84kB shmem:0kB slab_reclaimable:261624kB slab_unreclaimable:6640kB kernel_stack:1056kB pagetables:1232kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Dec 20 11:43:14 koyomi kernel: lowmem_reserve[]: 0 0 7175 7175
Dec 20 11:43:14 koyomi kernel: HighMem free:796756kB min:512kB low:1476kB high:2444kB active_anon:3224kB inactive_anon:37988kB active_file:28856kB inactive_file:56064kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:918456kB mlocked:0kB dirty:4kB writeback:0kB mapped:7080kB shmem:744kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
Dec 20 11:43:14 koyomi kernel: lowmem_reserve[]: 0 0 0 0
Dec 20 11:43:14 koyomi kernel: DMA: 6*4kB 5*8kB 1*16kB 1*32kB 1*64kB 0*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 0*4096kB = 3504kB
Dec 20 11:43:14 koyomi kernel: Normal: 13380*4kB 920*8kB 89*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 62304kB
Dec 20 11:43:14 koyomi kernel: HighMem: 1647*4kB 279*8kB 358*16kB 790*32kB 311*64kB 126*128kB 136*256kB 138*512kB 85*1024kB 58*2048kB 100*4096kB = 796756kB
Dec 20 11:43:14 koyomi kernel: 157743 total pagecache pages
Dec 20 11:43:14 koyomi kernel: 0 pages in swap cache
Dec 20 11:43:14 koyomi kernel: Swap cache stats: add 0, delete 0, find 0/0
Dec 20 11:43:14 koyomi kernel: Free swap  = 4883752kB
Dec 20 11:43:14 koyomi kernel: Total swap = 4883752kB
Dec 20 11:43:14 koyomi kernel: 458748 pages RAM
Dec 20 11:43:14 koyomi kernel: 231422 pages HighMem
Dec 20 11:43:14 koyomi kernel: 5001 pages reserved
Dec 20 11:43:14 koyomi kernel: 157266 pages shared
Dec 20 11:43:14 koyomi kernel: 88907 pages non-shared


The machine itself is a dual-P3 with an MV88SX6081 based SATA card,
an E1000 NIC and running a self compiled, vanilla 2.6.32.1.

Is there anything i could help to narrow down the cause of this problem?


				Attila Kinali

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
