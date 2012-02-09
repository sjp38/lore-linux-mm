Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 4082A6B002C
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 08:54:21 -0500 (EST)
Date: Thu, 9 Feb 2012 14:54:08 +0100
From: Johannes Stezenbach <js@sig21.net>
Subject: Re: swap storm since kernel 3.2.x
Message-ID: <20120209135407.GA15492@sig21.net>
References: <201202041109.53003.toralf.foerster@gmx.de>
 <201202051107.26634.toralf.foerster@gmx.de>
 <CAJd=RBCvvVgWqfSkoEaWVG=2mwKhyXarDOthHt9uwOb2fuDE9g@mail.gmail.com>
 <201202080956.18727.toralf.foerster@gmx.de>
 <20120208115244.GA24959@sig21.net>
 <CAJd=RBDbYA4xZRikGtHJvKESdiSE-B4OucZ6vQ+tHCi+hG2+aw@mail.gmail.com>
 <20120209113606.GA8054@sig21.net>
 <CAJd=RBDzUpUgZLVU+WSfb8grzMAbi3fcyyZkpX8qpaxu6zYe1g@mail.gmail.com>
 <20120209132155.GA15147@sig21.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120209132155.GA15147@sig21.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Toralf =?iso-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

On Thu, Feb 09, 2012 at 02:21:55PM +0100, Johannes Stezenbach wrote:
> it looks good.  Neither do I get the huge debug_objects_cache
> nor does it swap, after running a crosstool-ng toolchain build.
> Well, last time I also had one kvm -m 1G instance running.  I'll
> try if that triggers the issue.  So far:

The kvm produced a bunch of page allocation failures
on the host:

[ 6496.165268] kvm: page allocation failure: order:1, mode:0x4020
[ 6496.165273] Pid: 15322, comm: kvm Not tainted 3.2.4 #2
[ 6496.165274] Call Trace:
[ 6496.165276]  <IRQ>  [<ffffffff810cec13>] warn_alloc_failed+0x115/0x12a
[ 6496.165286]  [<ffffffff810d0c11>] __alloc_pages_nodemask+0x5f5/0x697
[ 6496.165291]  [<ffffffff810fcc4b>] new_slab+0x96/0x1ef
[ 6496.165295]  [<ffffffff8155b517>] __slab_alloc.isra.52.constprop.59+0x245/0x349
[ 6496.165299]  [<ffffffff8146f7e9>] ? skb_segment+0x213/0x50e
[ 6496.165302]  [<ffffffff810fc14b>] ? deactivate_slab+0x45b/0x47e
[ 6496.165306]  [<ffffffff81008c1f>] ? sched_clock+0x9/0xd
[ 6496.165309]  [<ffffffff810fe708>] __kmalloc_track_caller+0xb0/0x174
[ 6496.165312]  [<ffffffff8146f7e9>] ? skb_segment+0x213/0x50e
[ 6496.165315]  [<ffffffff8146dea5>] __alloc_skb+0x66/0x127
[ 6496.165318]  [<ffffffff8146f7e9>] skb_segment+0x213/0x50e
[ 6496.165323]  [<ffffffff814d6c69>] tcp_tso_segment+0x2cd/0x2e2
[ 6496.165327]  [<ffffffff814f4200>] inet_gso_segment+0x162/0x283
[ 6496.165330]  [<ffffffff814f417c>] ? inet_gso_segment+0xde/0x283
[ 6496.165333]  [<ffffffff814769aa>] skb_gso_segment+0x24e/0x2fb
[ 6496.165335]  [<ffffffff814768f7>] ? skb_gso_segment+0x19b/0x2fb
[ 6496.165338]  [<ffffffff81479511>] ? dev_hard_start_xmit+0x20b/0x658
[ 6496.165341]  [<ffffffff81008bd8>] ? native_sched_clock+0x35/0x73
[ 6496.165344]  [<ffffffff81008c1f>] ? sched_clock+0x9/0xd
[ 6496.165348]  [<ffffffff8107ae56>] ? put_lock_stats.isra.15+0xe/0x29
[ 6496.165351]  [<ffffffff8107af09>] ? lock_release_holdtime.part.16+0x98/0xa1
[ 6496.165354]  [<ffffffff81479511>] ? dev_hard_start_xmit+0x20b/0x658
[ 6496.165357]  [<ffffffff814796be>] dev_hard_start_xmit+0x3b8/0x658
[ 6496.165360]  [<ffffffff81479375>] ? dev_hard_start_xmit+0x6f/0x658
[ 6496.165364]  [<ffffffff8148e0f4>] sch_direct_xmit+0x71/0x204
[ 6496.165367]  [<ffffffff81479d96>] dev_queue_xmit+0x438/0x721
[ 6496.165370]  [<ffffffff8147995e>] ? dev_hard_start_xmit+0x658/0x658
[ 6496.165374]  [<ffffffff81517623>] br_dev_queue_push_xmit+0x7d/0x84
[ 6496.165377]  [<ffffffff8151767b>] br_forward_finish+0x51/0x58
[ 6496.165380]  [<ffffffff8151777c>] __br_deliver+0x54/0x5b
[ 6496.165383]  [<ffffffff815177aa>] br_deliver+0x27/0x33
[ 6496.165386]  [<ffffffff81515ec0>] br_dev_xmit+0x170/0x1ab
[ 6496.165389]  [<ffffffff81515dd9>] ? br_dev_xmit+0x89/0x1ab
[ 6496.165392]  [<ffffffff8147975f>] dev_hard_start_xmit+0x459/0x658
[ 6496.165395]  [<ffffffff81479375>] ? dev_hard_start_xmit+0x6f/0x658
[ 6496.165398]  [<ffffffff81479f31>] dev_queue_xmit+0x5d3/0x721
[ 6496.165400]  [<ffffffff8147995e>] ? dev_hard_start_xmit+0x658/0x658
[ 6496.165403]  [<ffffffff814ceee9>] ip_finish_output+0x2b5/0x378
[ 6496.165406]  [<ffffffff814cee42>] ? ip_finish_output+0x20e/0x378
[ 6496.165408]  [<ffffffff814d034d>] ip_output+0xaf/0xcc
[ 6496.165411]  [<ffffffff814cfae8>] ip_local_out+0x4f/0x66
[ 6496.165413]  [<ffffffff814cfe46>] ip_queue_xmit+0x347/0x3c7
[ 6496.165415]  [<ffffffff814cfaff>] ? ip_local_out+0x66/0x66
[ 6496.165417]  [<ffffffff8107340d>] ? getnstimeofday+0x61/0xb2
[ 6496.165421]  [<ffffffff814e259c>] tcp_transmit_skb+0x6c4/0x6ff
[ 6496.165424]  [<ffffffff814e3223>] tcp_write_xmit+0x7bb/0x8cf
[ 6496.165427]  [<ffffffff814e3391>] __tcp_push_pending_frames+0x26/0xab
[ 6496.165430]  [<ffffffff814e06b6>] tcp_rcv_established+0x10e/0x5d0
[ 6496.165433]  [<ffffffff814e5e4d>] tcp_v4_do_rcv+0xc5/0x39f
[ 6496.165438]  [<ffffffff81562bbe>] ? _raw_spin_lock_nested+0x70/0x79
[ 6496.165441]  [<ffffffff814e8050>] ? tcp_v4_rcv+0x370/0x87a
[ 6496.165444]  [<ffffffff81487abd>] ? sk_filter+0xb8/0xc3
[ 6496.165447]  [<ffffffff814e8217>] tcp_v4_rcv+0x537/0x87a
[ 6496.165450]  [<ffffffff814cb714>] ip_local_deliver_finish+0x124/0x19a
[ 6496.165453]  [<ffffffff814cb628>] ? ip_local_deliver_finish+0x38/0x19a
[ 6496.165456]  [<ffffffff814cb8e8>] ip_local_deliver+0x7a/0x81
[ 6496.165459]  [<ffffffff814cb58e>] ip_rcv_finish+0x2ba/0x31c
[ 6496.165462]  [<ffffffff814cbb28>] ip_rcv+0x239/0x261
[ 6496.165465]  [<ffffffff81512d27>] ? packet_rcv_spkt+0x136/0x141
[ 6496.165468]  [<ffffffff81474bfb>] __netif_receive_skb+0x2c8/0x34b
[ 6496.165470]  [<ffffffff814749d0>] ? __netif_receive_skb+0x9d/0x34b
[ 6496.165473]  [<ffffffff8147607e>] netif_receive_skb+0xd7/0xde
[ 6496.165476]  [<ffffffff81475fdb>] ? netif_receive_skb+0x34/0xde
[ 6496.165479]  [<ffffffff81518124>] ? br_handle_local_finish+0x44/0x44
[ 6496.165482]  [<ffffffff81518353>] br_handle_frame_finish+0x22f/0x246
[ 6496.165486]  [<ffffffff8151d87a>] br_nf_pre_routing_finish+0x2f2/0x317
[ 6496.165489]  [<ffffffff8151de48>] br_nf_pre_routing+0x5a9/0x5be
[ 6496.165492]  [<ffffffff814932c4>] nf_iterate+0x48/0x7d
[ 6496.165495]  [<ffffffff81518124>] ? br_handle_local_finish+0x44/0x44
[ 6496.165498]  [<ffffffff81493392>] nf_hook_slow+0x99/0x14b
[ 6496.165501]  [<ffffffff81518124>] ? br_handle_local_finish+0x44/0x44
[ 6496.165504]  [<ffffffff81518571>] br_handle_frame+0x207/0x232
[ 6496.165507]  [<ffffffff8151836a>] ? br_handle_frame_finish+0x246/0x246
[ 6496.165510]  [<ffffffff81474b3e>] __netif_receive_skb+0x20b/0x34b
[ 6496.165512]  [<ffffffff814749d0>] ? __netif_receive_skb+0x9d/0x34b
[ 6496.165516]  [<ffffffff8147846c>] process_backlog+0xbe/0x17f
[ 6496.165518]  [<ffffffff814781fe>] net_rx_action+0x91/0x241
[ 6496.165522]  [<ffffffff81053954>] __do_softirq+0xf7/0x228
[ 6496.165525]  [<ffffffff815659bc>] call_softirq+0x1c/0x30
[ 6496.165527]  <EOI>  [<ffffffff81003756>] do_softirq+0x4b/0xa5
[ 6496.165531]  [<ffffffff81476732>] netif_rx_ni+0x34/0x5e
[ 6496.165535]  [<ffffffff813ad8de>] tun_get_user+0x3b6/0x3e4
[ 6496.165538]  [<ffffffff813adda8>] tun_chr_aio_write+0x6c/0x87
[ 6496.165541]  [<ffffffff813add3c>] ? tun_chr_poll+0xdb/0xdb
[ 6496.165545]  [<ffffffff81106a1c>] do_sync_readv_writev+0xbc/0x101
[ 6496.165549]  [<ffffffff81107bfc>] ? fget_light+0xe8/0x11d
[ 6496.165553]  [<ffffffff81146685>] compat_do_readv_writev+0xf5/0x1bd
[ 6496.165556]  [<ffffffff8107af09>] ? lock_release_holdtime.part.16+0x98/0xa1
[ 6496.165559]  [<ffffffff81107bfc>] ? fget_light+0xe8/0x11d
[ 6496.165562]  [<ffffffff81146795>] compat_writev+0x48/0x6f
[ 6496.165565]  [<ffffffff81146e91>] compat_sys_writev+0x45/0x64
[ 6496.165568]  [<ffffffff81565a80>] sysenter_dispatch+0x7/0x37
[ 6496.165571]  [<ffffffff812857de>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 6496.165573] Mem-Info:
[ 6496.165574] DMA per-cpu:
[ 6496.165576] CPU    0: hi:    0, btch:   1 usd:   0
[ 6496.165578] CPU    1: hi:    0, btch:   1 usd:   0
[ 6496.165579] CPU    2: hi:    0, btch:   1 usd:   0
[ 6496.165581] CPU    3: hi:    0, btch:   1 usd:   0
[ 6496.165582] DMA32 per-cpu:
[ 6496.165584] CPU    0: hi:  186, btch:  31 usd:   0
[ 6496.165586] CPU    1: hi:  186, btch:  31 usd:   0
[ 6496.165587] CPU    2: hi:  186, btch:  31 usd:   1
[ 6496.165589] CPU    3: hi:  186, btch:  31 usd:   0
[ 6496.165590] Normal per-cpu:
[ 6496.165591] CPU    0: hi:  186, btch:  31 usd:   0
[ 6496.165593] CPU    1: hi:  186, btch:  31 usd:  23
[ 6496.165595] CPU    2: hi:  186, btch:  31 usd:  47
[ 6496.165596] CPU    3: hi:  186, btch:  31 usd:   0
[ 6496.165600] active_anon:72439 inactive_anon:49028 isolated_anon:0
[ 6496.165601]  active_file:302270 inactive_file:313604 isolated_file:0
[ 6496.165602]  unevictable:0 dirty:234 writeback:0 unstable:0
[ 6496.165602]  free:10617 slab_reclaimable:137832 slab_unreclaimable:83412
[ 6496.165603]  mapped:10536 shmem:8789 pagetables:1023 bounce:0
[ 6496.165609] DMA free:15680kB min:28kB low:32kB high:40kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB un
[ 6496.165613] lowmem_reserve[]: 0 3161 3915 3915
[ 6496.165621] DMA32 free:24592kB min:6452kB low:8064kB high:9676kB active_anon:117596kB inactive_anon:23728kB active_file:1129544
[ 6496.165626] lowmem_reserve[]: 0 0 754 754
[ 6496.165634] Normal free:2196kB min:1536kB low:1920kB high:2304kB active_anon:172160kB inactive_anon:172384kB active_file:79536k
[ 6496.165638] lowmem_reserve[]: 0 0 0 0
[ 6496.165642] DMA: 0*4kB 2*8kB 1*16kB 1*32kB 0*64kB 2*128kB 2*256kB 1*512kB 2*1024kB 2*2048kB 2*4096kB = 15680kB
[ 6496.165652] DMA32: 5856*4kB 58*8kB 25*16kB 3*32kB 0*64kB 1*128kB 1*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 24768kB
[ 6496.165661] Normal: 559*4kB 8*8kB 1*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2316kB
[ 6496.165671] 624680 total pagecache pages
[ 6496.165672] 0 pages in swap cache
[ 6496.165674] Swap cache stats: add 1427, delete 1427, find 732/869
[ 6496.165675] Free swap  = 3903308kB
[ 6496.165677] Total swap = 3903484kB
[ 6496.175804] 1048048 pages RAM
[ 6496.175806] 63348 pages reserved
[ 6496.175808] 561973 pages shared
[ 6496.175809] 441897 pages non-shared
[ 6496.175813] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
[ 6496.175815]   cache: kmalloc-4096, object size: 4096, buffer size: 4424, default order: 3, min order: 1
[ 6496.175817]   kmalloc-4096 debugging increased min order, use slub_debug=O to disable.
[ 6496.175819]   node 0: slabs: 44, objs: 302, free: 0

(repeats a few times)

I guess that is expected with your patch?


MemTotal:        3938800 kB
MemFree:          115236 kB
Buffers:           74016 kB
Cached:          1643088 kB
SwapCached:         7532 kB
Active:          1501576 kB
Inactive:        1388668 kB
Active(anon):     841280 kB
Inactive(anon):   366456 kB
Active(file):     660296 kB
Inactive(file):  1022212 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:       3903484 kB
SwapFree:        3864724 kB
Dirty:                12 kB
Writeback:             0 kB
AnonPages:       1165632 kB
Mapped:            27176 kB
Shmem:             34596 kB
Slab:             864524 kB
SReclaimable:     512968 kB
SUnreclaim:       351556 kB
KernelStack:        1568 kB
PageTables:         5868 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     5872884 kB
Committed_AS:    1588204 kB
VmallocTotal:   34359738367 kB
VmallocUsed:      348068 kB
VmallocChunk:   34359372819 kB
DirectMap4k:       12288 kB
DirectMap2M:     4098048 kB

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
  774103 774090  99%    0.36K  35198       22    281584K debug_objects_cache
  358596 204935  57%    0.42K  19923       18    159384K buffer_head
  148306 144221  97%    1.74K  12081       18    386592K ext3_inode_cache
   75360  69344  92%    0.58K   2795       27     44720K dentry


Thanks
Johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
