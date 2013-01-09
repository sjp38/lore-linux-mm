Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 6BA606B0062
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 22:55:12 -0500 (EST)
Date: Wed, 9 Jan 2013 03:55:11 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Message-ID: <20130109035511.GA6857@dcvr.yhbt.net>
References: <20130102200848.GA4500@dcvr.yhbt.net>
 <20130104160148.GB3885@suse.de>
 <20130106120700.GA24671@dcvr.yhbt.net>
 <20130107122516.GC3885@suse.de>
 <20130107223850.GA21311@dcvr.yhbt.net>
 <20130108224313.GA13304@suse.de>
 <20130108232325.GA5948@dcvr.yhbt.net>
 <1357697647.18156.1217.camel@edumazet-glaptop>
 <1357698749.27446.6.camel@edumazet-glaptop>
 <1357700082.27446.11.camel@edumazet-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357700082.27446.11.camel@edumazet-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <erdnetdev@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Eric Dumazet <erdnetdev@gmail.com> wrote:
> On Tue, 2013-01-08 at 18:32 -0800, Eric Dumazet wrote:
> > Hmm, it seems sk_filter() can return -ENOMEM because skb has the
> > pfmemalloc() set.
> 
> > 
> > One TCP socket keeps retransmitting an SKB via loopback, and TCP stack 
> > drops the packet again and again.
> 
> sock_init_data() sets sk->sk_allocation to GFP_KERNEL
> 
> Shouldnt it use (GFP_KERNEL | __GFP_NOMEMALLOC) instead ?

Thanks, things are running good after ~35 minutes so far.
Will report back if things break (hopefully I don't run out
of laptop battery power :x).

I'm now getting allocation failure warnings (which I don't believe
happened before, and should be expected, I think...)

kworker/1:1: page allocation failure: order:0, mode:0x20
Pid: 236, comm: kworker/1:1 Not tainted 3.8.0-rc2w5+ #76
Call Trace:
 <IRQ>  [<ffffffff810a2411>] warn_alloc_failed+0xe1/0x130
 [<ffffffff810a5779>] __alloc_pages_nodemask+0x5e9/0x840
 [<ffffffff8133df8d>] ? ip_rcv+0x24d/0x340
 [<ffffffff811f35b3>] ? sg_init_table+0x23/0x50
 [<ffffffffa002162a>] get_a_page.isra.25+0x3a/0x40 [virtio_net]
 [<ffffffffa0022258>] try_fill_recv+0x318/0x4a0 [virtio_net]
 [<ffffffffa00227bd>] virtnet_poll+0x3dd/0x610 [virtio_net]
 [<ffffffff8131767d>] net_rx_action+0x9d/0x1a0
 [<ffffffff8104284a>] __do_softirq+0xba/0x170
 [<ffffffff813b199c>] call_softirq+0x1c/0x30
 <EOI>  [<ffffffff8100c61d>] do_softirq+0x6d/0xa0
 [<ffffffff81042424>] local_bh_enable+0x94/0xa0
 [<ffffffff813aed45>] __cond_resched_softirq+0x35/0x50
 [<ffffffff81305e7c>] release_sock+0x9c/0x150
 [<ffffffff8134b90e>] tcp_sendmsg+0x11e/0xd80
 [<ffffffff81370cee>] inet_sendmsg+0x5e/0xa0
 [<ffffffff81300a77>] sock_sendmsg+0x87/0xa0
 [<ffffffff810a48c9>] ? __free_memcg_kmem_pages+0x9/0x10
 [<ffffffff81067819>] ? select_task_rq_fair+0x699/0x6b0
 [<ffffffff81300acb>] kernel_sendmsg+0x3b/0x50
 [<ffffffffa0052dc9>] xs_send_kvec+0x89/0xa0 [sunrpc]
 [<ffffffffa00534bf>] xs_sendpages+0x5f/0x1e0 [sunrpc]
 [<ffffffff81047d63>] ? lock_timer_base.isra.32+0x33/0x60
 [<ffffffffa00548e7>] xs_tcp_send_request+0x57/0x110 [sunrpc]
 [<ffffffffa0051c0d>] xprt_transmit+0x6d/0x260 [sunrpc]
 [<ffffffffa004f108>] call_transmit+0x1a8/0x240 [sunrpc]
 [<ffffffffa0056316>] __rpc_execute+0x56/0x250 [sunrpc]
 [<ffffffffa0056535>] rpc_async_schedule+0x25/0x40 [sunrpc]
 [<ffffffff810515cc>] process_one_work+0x12c/0x480
 [<ffffffffa0056510>] ? __rpc_execute+0x250/0x250 [sunrpc]
 [<ffffffff810538ad>] worker_thread+0x15d/0x460
 [<ffffffff81053750>] ? flush_delayed_work+0x60/0x60
 [<ffffffff8105865b>] kthread+0xbb/0xc0
 [<ffffffff810585a0>] ? kthread_create_on_node+0x120/0x120
 [<ffffffff813b063c>] ret_from_fork+0x7c/0xb0
 [<ffffffff810585a0>] ? kthread_create_on_node+0x120/0x120
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:   0
CPU    1: hi:  186, btch:  31 usd:   0
active_anon:3620 inactive_anon:3624 isolated_anon:0
 active_file:4290 inactive_file:101218 isolated_file:0
 unevictable:0 dirty:2306 writeback:0 unstable:0
 free:1711 slab_reclaimable:1529 slab_unreclaimable:5796
 mapped:2325 shmem:66 pagetables:759 bounce:0
 free_cma:0
DMA free:2012kB min:84kB low:104kB high:124kB active_anon:0kB inactive_anon:0kB active_file:4kB inactive_file:13624kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15644kB managed:15900kB mlocked:0kB dirty:244kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:16kB slab_unreclaimable:80kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 488 488 488
DMA32 free:4832kB min:2784kB low:3480kB high:4176kB active_anon:14480kB inactive_anon:14496kB active_file:17156kB inactive_file:391248kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:499960kB managed:491256kB mlocked:0kB dirty:8980kB writeback:0kB mapped:9300kB shmem:264kB slab_reclaimable:6100kB slab_unreclaimable:23104kB kernel_stack:1336kB pagetables:3036kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 2*4kB (U) 1*8kB (R) 1*16kB (U) 0*32kB 1*64kB (R) 1*128kB (R) 1*256kB (R) 1*512kB (R) 1*1024kB (R) 0*2048kB 0*4096kB = 2016kB
DMA32: 207*4kB (UEM) 116*8kB (UEM) 32*16kB (UM) 58*32kB (UM) 13*64kB (UM) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 4956kB
108890 total pagecache pages
3302 pages in swap cache
Swap cache stats: add 4086, delete 784, find 494/535
Free swap  = 378980kB
Total swap = 392188kB
131054 pages RAM
3820 pages reserved
541743 pages shared
117221 pages non-shared
cat: page allocation failure: order:0, mode:0x20
Pid: 23684, comm: cat Not tainted 3.8.0-rc2w5+ #76
Call Trace:
 <IRQ>  [<ffffffff810a2411>] warn_alloc_failed+0xe1/0x130
 [<ffffffff810a5779>] __alloc_pages_nodemask+0x5e9/0x840
 [<ffffffff8133df8d>] ? ip_rcv+0x24d/0x340
 [<ffffffff811f35b3>] ? sg_init_table+0x23/0x50
 [<ffffffffa002162a>] get_a_page.isra.25+0x3a/0x40 [virtio_net]
 [<ffffffffa0022258>] try_fill_recv+0x318/0x4a0 [virtio_net]
 [<ffffffffa00227bd>] virtnet_poll+0x3dd/0x610 [virtio_net]
 [<ffffffff8131767d>] net_rx_action+0x9d/0x1a0
 [<ffffffff8104284a>] __do_softirq+0xba/0x170
 [<ffffffff813b199c>] call_softirq+0x1c/0x30
 [<ffffffff8100c61d>] do_softirq+0x6d/0xa0
 [<ffffffff81042a75>] irq_exit+0xa5/0xb0
 [<ffffffff8100c25e>] do_IRQ+0x5e/0xd0
 [<ffffffff813afe2d>] common_interrupt+0x6d/0x6d
 <EOI>  [<ffffffff813af82c>] ? _raw_spin_unlock_irqrestore+0xc/0x20
 [<ffffffff810a91b6>] pagevec_lru_move_fn+0xb6/0xe0
 [<ffffffff810a8780>] ? compound_unlock_irqrestore+0x20/0x20
 [<ffffffffa00acd30>] ? nfs_read_completion+0x190/0x190 [nfs]
 [<ffffffff810a91f7>] __pagevec_lru_add+0x17/0x20
 [<ffffffff810a95c8>] __lru_cache_add+0x68/0x90
 [<ffffffff8109e869>] add_to_page_cache_lru+0x29/0x40
 [<ffffffff810a80cc>] read_cache_pages+0x6c/0x100
 [<ffffffffa00ad4dc>] nfs_readpages+0xcc/0x160 [nfs]
 [<ffffffff810a7f57>] __do_page_cache_readahead+0x1c7/0x280
 [<ffffffff810a827c>] ra_submit+0x1c/0x20
 [<ffffffff810a83ad>] ondemand_readahead+0x12d/0x250
 [<ffffffff8109f37d>] ? __generic_file_aio_write+0x1bd/0x3c0
 [<ffffffff810a8550>] page_cache_async_readahead+0x80/0xa0
 [<ffffffff8109e0b8>] ? find_get_page+0x28/0xd0
 [<ffffffff8109fb73>] generic_file_aio_read+0x503/0x6c0
 [<ffffffffa00a4231>] nfs_file_read+0x91/0xb0 [nfs]
 [<ffffffff810e4477>] do_sync_read+0xa7/0xe0
 [<ffffffff810e4b50>] vfs_read+0xa0/0x160
 [<ffffffff810e4c5d>] sys_read+0x4d/0x90
 [<ffffffff813b06e9>] system_call_fastpath+0x16/0x1b
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:  86
CPU    1: hi:  186, btch:  31 usd: 167
active_anon:2376 inactive_anon:2431 isolated_anon:0
 active_file:3712 inactive_file:103686 isolated_file:17
 unevictable:0 dirty:646 writeback:0 unstable:0
 free:807 slab_reclaimable:1485 slab_unreclaimable:5873
 mapped:2343 shmem:66 pagetables:791 bounce:0
 free_cma:0
DMA free:2032kB min:84kB low:104kB high:124kB active_anon:0kB inactive_anon:0kB active_file:24kB inactive_file:12916kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15644kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:12kB shmem:0kB slab_reclaimable:16kB slab_unreclaimable:124kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 488 488 488
DMA32 free:1196kB min:2784kB low:3480kB high:4176kB active_anon:9504kB inactive_anon:9724kB active_file:14824kB inactive_file:401828kB unevictable:0kB isolated(anon):0kB isolated(file):68kB present:499960kB managed:491256kB mlocked:0kB dirty:2588kB writeback:0kB mapped:9360kB shmem:264kB slab_reclaimable:5924kB slab_unreclaimable:23368kB kernel_stack:1336kB pagetables:3164kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 11*4kB (MR) 1*8kB (R) 0*16kB 2*32kB (R) 4*64kB (R) 3*128kB (R) 1*256kB (R) 0*512kB 1*1024kB (R) 0*2048kB 0*4096kB = 2036kB
DMA32: 40*4kB (UEM) 28*8kB (UM) 22*16kB (UEM) 5*32kB (UM) 5*64kB (UM) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1216kB
108199 total pagecache pages
714 pages in swap cache
Swap cache stats: add 4829, delete 4115, find 583/626
Free swap  = 376280kB
Total swap = 392188kB
131054 pages RAM
3820 pages reserved
542491 pages shared
117305 pages non-shared
cat: page allocation failure: order:0, mode:0x20
Pid: 24171, comm: cat Not tainted 3.8.0-rc2w5+ #76
Call Trace:
 <IRQ>  [<ffffffff810a2411>] warn_alloc_failed+0xe1/0x130
 [<ffffffff8137871e>] ? fib_table_lookup+0x26e/0x2d0
 [<ffffffff810a5779>] __alloc_pages_nodemask+0x5e9/0x840
 [<ffffffff8130a6c0>] __netdev_alloc_frag+0xa0/0x150
 [<ffffffff8130d9d2>] __netdev_alloc_skb+0x82/0xe0
 [<ffffffffa00225b7>] virtnet_poll+0x1d7/0x610 [virtio_net]
 [<ffffffff8131767d>] net_rx_action+0x9d/0x1a0
 [<ffffffff8104284a>] __do_softirq+0xba/0x170
 [<ffffffff813b199c>] call_softirq+0x1c/0x30
 [<ffffffff8100c61d>] do_softirq+0x6d/0xa0
 [<ffffffff81042a75>] irq_exit+0xa5/0xb0
 [<ffffffff8100c25e>] do_IRQ+0x5e/0xd0
 [<ffffffff813afe2d>] common_interrupt+0x6d/0x6d
 <EOI>  [<ffffffff813aeeb5>] ? io_schedule+0xa5/0xd0
 [<ffffffff811ef000>] ? copy_user_generic_string+0x30/0x40
 [<ffffffff8109db32>] ? __lock_page_killable+0x62/0x70
 [<ffffffff8109da85>] ? file_read_actor+0x135/0x180
 [<ffffffff8109f950>] generic_file_aio_read+0x2e0/0x6c0
 [<ffffffffa00a4231>] nfs_file_read+0x91/0xb0 [nfs]
 [<ffffffff810e4477>] do_sync_read+0xa7/0xe0
 [<ffffffff810e4b50>] vfs_read+0xa0/0x160
 [<ffffffff810e4c5d>] sys_read+0x4d/0x90
 [<ffffffff813b06e9>] system_call_fastpath+0x16/0x1b
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:  50
CPU    1: hi:  186, btch:  31 usd:  30
active_anon:2367 inactive_anon:2431 isolated_anon:0
 active_file:3719 inactive_file:103732 isolated_file:0
 unevictable:0 dirty:1302 writeback:0 unstable:0
 free:754 slab_reclaimable:1589 slab_unreclaimable:5896
 mapped:2343 shmem:66 pagetables:781 bounce:0
 free_cma:0
DMA free:1980kB min:84kB low:104kB high:124kB active_anon:0kB inactive_anon:0kB active_file:24kB inactive_file:9704kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15644kB managed:15900kB mlocked:0kB dirty:84kB writeback:0kB mapped:12kB shmem:0kB slab_reclaimable:16kB slab_unreclaimable:180kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 488 488 488
DMA32 free:1036kB min:2784kB low:3480kB high:4176kB active_anon:9468kB inactive_anon:9724kB active_file:14852kB inactive_file:405224kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:499960kB managed:491256kB mlocked:0kB dirty:5124kB writeback:0kB mapped:9360kB shmem:264kB slab_reclaimable:6340kB slab_unreclaimable:23404kB kernel_stack:1368kB pagetables:3124kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 34*4kB (UR) 23*8kB (UMR) 40*16kB (UMR) 2*32kB (UM) 1*64kB (R) 1*128kB (R) 1*256kB (R) 1*512kB (R) 0*1024kB 0*2048kB 0*4096kB = 1984kB
DMA32: 1*4kB (U) 33*8kB (UEM) 8*16kB (UM) 4*32kB (UM) 8*64kB (UM) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1036kB
108257 total pagecache pages
712 pages in swap cache
Swap cache stats: add 4829, delete 4117, find 585/628
Free swap  = 376288kB
Total swap = 392188kB
131054 pages RAM
3820 pages reserved
280574 pages shared
116800 pages non-shared
-- 
Eric Wong

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
