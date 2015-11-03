Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3AB9A82F64
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 17:16:05 -0500 (EST)
Received: by padhx2 with SMTP id hx2so22525210pad.1
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 14:16:05 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c8si45245488pat.181.2015.11.03.14.16.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 14:16:04 -0800 (PST)
Date: Tue, 3 Nov 2015 14:16:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 107111] New: page allocation failure but there seem to be
 free pages
Message-Id: <20151103141603.261893b44e0cd6e704921fb6@linux-foundation.org>
In-Reply-To: <bug-107111-27@https.bugzilla.kernel.org/>
References: <bug-107111-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, john@calva.com, Mel Gorman <mgorman@techsingularity.net>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 03 Nov 2015 16:21:06 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=107111
> 
>             Bug ID: 107111
>            Summary: page allocation failure but there seem to be free
>                     pages
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.2.3
>           Hardware: IA-64

Note: IA64.  It isn't tested much and perhaps this triggered an oddity.


>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Page Allocator
>           Assignee: akpm@linux-foundation.org
>           Reporter: john@calva.com
>         Regression: No
> 
> I'm getting various page allocation errors, mostly:
> 
> apache2: page allocation failure: order:1, mode:0x204020
> 
> but also
> 
> kswapd0: page allocation failure: order:1, mode:0x204020
> swapper/0: page allocation failure: order:1, mode:0x204020
> 
> My (virtual) machine doesn't have much memory (2G) but it seems to have some
> free:
> 
> MemFree:          226832 kB
> 
> Here is the full output of the last error:
> 
> [1188431.177410] apache2: page allocation failure: order:1, mode:0x204020

An order-1 page, __GFP_COMP|__GFP_HIGH.  ie: GFP_ATOMIC.

> [1188431.177413] CPU: 0 PID: 6673 Comm: apache2 Not tainted 4.2.3-jh1 #2
> [1188431.177414] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
> [1188431.177416]  0000000000000000 0000000000000000 ffffffff8155b3d8
> 0000000000204020
> [1188431.177418]  ffffffff8115a911 0000000100000000 00ff880000000000
> ffff88007fffdb00
> [1188431.177421]  0000000000000000 ffff88007fffdb08 0000000000000000
> ffff880036d6a540
> [1188431.177424] Call Trace:
> [1188431.177425]  <IRQ>  [<ffffffff8155b3d8>] ? dump_stack+0x40/0x50
> [1188431.177430]  [<ffffffff8115a911>] ? warn_alloc_failed+0xf1/0x150
> [1188431.177433]  [<ffffffff8115da78>] ? __alloc_pages_nodemask+0x2b8/0x990
> [1188431.177436]  [<ffffffff811a6acf>] ? kmem_getpages+0x5f/0x110
> [1188431.177439]  [<ffffffff811a8778>] ? fallback_alloc+0x1b8/0x210
> [1188431.177441]  [<ffffffff811a9a97>] ? kmem_cache_alloc+0x187/0x1c0
> [1188431.177444]  [<ffffffff8144c9b8>] ? sk_prot_alloc+0x48/0x190
> [1188431.177446]  [<ffffffff8144f1df>] ? sk_clone_lock+0x1f/0x330
> [1188431.177449]  [<ffffffff814a8ea5>] ? inet_csk_clone_lock+0x15/0x130
> [1188431.177451]  [<ffffffff814c3172>] ? tcp_create_openreq_child+0x22/0x470
> [1188431.177453]  [<ffffffff814c12fc>] ? tcp_v4_syn_recv_sock+0x4c/0x370
> [1188431.177456]  [<ffffffff814a9bb9>] ?
> inet_csk_reqsk_queue_hash_add+0x89/0xa0
> [1188431.177459]  [<ffffffff815303ca>] ? tcp_v6_syn_recv_sock+0x45a/0x6c0
> [1188431.177462]  [<ffffffff810c5165>] ? handle_edge_irq+0x95/0x150
> [1188431.177464]  [<ffffffff814c396e>] ? tcp_check_req+0x37e/0x4a0
> [1188431.177466]  [<ffffffff814c1c1c>] ? tcp_v4_do_rcv+0x1ec/0x3b0
> [1188431.177469]  [<ffffffff814c2f74>] ? tcp_v4_rcv+0x954/0xa20
> [1188431.177471]  [<ffffffff8105a89e>] ? kvm_clock_read+0x1e/0x30
> [1188431.177474]  [<ffffffff8149e5a7>] ? ip_local_deliver_finish+0x97/0x1e0
> [1188431.177477]  [<ffffffff8149e856>] ? ip_local_deliver+0x46/0xb0
> [1188431.177479]  [<ffffffff8149e45b>] ? ip_rcv_finish+0x29b/0x350
> [1188431.177482]  [<ffffffff8149eb48>] ? ip_rcv+0x288/0x3f0
> [1188431.177485]  [<ffffffff814640fc>] ? __netif_receive_skb_core+0x65c/0x910
> [1188431.177487]  [<ffffffff8105a89e>] ? kvm_clock_read+0x1e/0x30
> [1188431.177490]  [<ffffffff8146456f>] ? netif_receive_skb_internal+0x1f/0x80
> [1188431.177493]  [<ffffffffa0010610>] ? virtnet_receive+0x280/0x870
> [virtio_net]
> [1188431.177496]  [<ffffffffa0010c26>] ? virtnet_poll+0x26/0x90 [virtio_net]
> [1188431.177499]  [<ffffffff81464c7c>] ? net_rx_action+0x15c/0x310
> [1188431.177502]  [<ffffffff81074f9f>] ? __do_softirq+0xcf/0x250
> [1188431.177505]  [<ffffffff81075333>] ? irq_exit+0x93/0xa0
> [1188431.177507]  [<ffffffff81563cd4>] ? do_IRQ+0x64/0x100
> [1188431.177510]  [<ffffffff81561c6b>] ? common_interrupt+0x6b/0x6b
> [1188431.177511]  <EOI> Mem-Info:
> [1188431.177516] active_anon:32089 inactive_anon:34044 isolated_anon:0
> [1188431.177516]  active_file:187241 inactive_file:189090 isolated_file:0
> [1188431.177516]  unevictable:16 dirty:949 writeback:0 unstable:0
> [1188431.177516]  slab_reclaimable:52124 slab_unreclaimable:5167
> [1188431.177516]  mapped:13709 shmem:4094 pagetables:3847 bounce:0
> [1188431.177516]  free:3964 free_pcp:170 free_cma:0
> [1188431.177521] Node 0 DMA free:7968kB min:40kB low:48kB high:60kB

The 16MB DMA zone has 8MB free and it's miles above watermarks.

> active_anon:112kB inactive_anon:388kB active_file:948kB inactive_file:1744kB
> unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15944kB
> managed:15860kB mlocked:0kB dirty:8kB writeback:0kB mapped:52kB shmem:0kB
> slab_reclaimable:1388kB slab_unreclaimable:856kB kernel_stack:960kB
> pagetables:44kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> [1188431.177527] lowmem_reserve[]: 0 1988 1988 1988
> [1188431.177530] Node 0 DMA32 free:7888kB min:5588kB low:6984kB high:8380kB

The DMA32 zone is somewhat depleted.

> active_anon:128244kB inactive_anon:135788kB active_file:748016kB
> inactive_file:754616kB unevictable:64kB isolated(anon):0kB isolated(file):0kB
> present:2080768kB managed:2038300kB mlocked:64kB dirty:3788kB writeback:0kB
> mapped:54784kB shmem:16376kB slab_reclaimable:207108kB
> slab_unreclaimable:19812kB kernel_stack:3712kB pagetables:15344kB unstable:0kB
> bounce:0kB free_pcp:680kB local_pcp:680kB free_cma:0kB writeback_tmp:0kB
> pages_scanned:0 all_unreclaimable? no
> [1188431.177552] lowmem_reserve[]: 0 0 0 0
> [1188431.177555] Node 0 DMA: 44*4kB (UE) 94*8kB (UEM) 76*16kB (UE) 42*32kB
> (UEM) 22*64kB (UEM) 6*128kB (UE) 3*256kB (UE) 1*512kB (E) 1*1024kB (U) 0*2048kB
> 0*4096kB = 7968kB

The DMA zone has lots and lots of higher-order pages available which
could satisfy this allocation.

> [1188431.177567] Node 0 DMA32: 1972*4kB (U) 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB
> 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 7888kB

The DMA32 zone has no higher-order pages available.

> [1188431.177576] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0
> hugepages_size=2048kB
> [1188431.177578] 338595 total pagecache pages
> [1188431.177579] 2504 pages in swap cache
> [1188431.177581] Swap cache stats: add 66871, delete 64367, find
> 21973081/21986496
> [1188431.177582] Free swap  = 4127584kB
> [1188431.177584] Total swap = 4194300kB
> [1188431.177585] 524178 pages RAM
> [1188431.177586] 0 pages HighMem/MovableOnly
> [1188431.177587] 10638 pages reserved
> [1188431.177589] 0 pages hwpoisoned

The kernel could and should have satisfied this order-1 GFP_ATOMIC
IRQ-context allocation from the DMA zone.  But it did not do so.  Bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
