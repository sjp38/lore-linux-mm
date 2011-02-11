Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DA1578D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 19:48:48 -0500 (EST)
Date: Thu, 10 Feb 2011 16:48:45 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Fw: I have a blaze of 353 page allocation failures, all alike
Message-Id: <20110210164845.16ae64af.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Thu__10_Feb_2011_16_48_45_-0800_C=+fMws77XyIT3C2"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Peter Kruse <pk@q-leap.com>

This is a multi-part message in MIME format.

--Multipart=_Thu__10_Feb_2011_16_48_45_-0800_C=+fMws77XyIT3C2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit


That sounds a bit excessive?


Begin forwarded message:

Date: Thu, 10 Feb 2011 16:03:31 +0100
From: Peter Kruse <pk@q-leap.com>
To: linux-kernel@vger.kernel.org
Subject: I have a blaze of 353 page allocation failures, all alike


Hello,

today one of our servers went berserk and produced literally 353
page allocation failures in 7 minutes until it was reset
(sysrq was still working).  I attach one of them as an example.
The failures happened for different processes ranging from
sshd, top, java, tclsh, ypserv, smbd, portmap, kswapd to Xvnc4.
I already reported about an incidence with this server here:
https://lkml.org/lkml/2011/1/19/145
we have set vm.min_free_kbytes = 2097152 but the problem
obviously did not go away.
All traces start with one of these three beginnings:

Call Trace:
  <IRQ>  [<ffffffff81071f46>] __alloc_pages_nodemask+0x5ca/0x600
  [<ffffffff81344127>] ? skb_dma_map+0xd2/0x23f

Call Trace:
  <IRQ>  [<ffffffff81071f46>] __alloc_pages_nodemask+0x5ca/0x600
  [<ffffffff8109428b>] kmem_getpages+0x5c/0x127

Call Trace:
  <IRQ>  [<ffffffff81071f46>] __alloc_pages_nodemask+0x5ca/0x600
  [<ffffffffa01418fd>] ? tcp_packet+0xc87/0xcb2 [nf_conntrack]

Please anybody, what is the cause of these failures?

Thanks,

   Peter

--Multipart=_Thu__10_Feb_2011_16_48_45_-0800_C=+fMws77XyIT3C2
Content-Type: text/plain;
 name="calltrace.1"
Content-Disposition: attachment;
 filename="calltrace.1"
Content-Transfer-Encoding: 7bit

Call Trace:
 <IRQ>  [<ffffffff81071f46>] __alloc_pages_nodemask+0x5ca/0x600
 [<ffffffff8109428b>] kmem_getpages+0x5c/0x127
 [<ffffffff81094475>] fallback_alloc+0x11f/0x195
 [<ffffffff81094614>] ____cache_alloc_node+0x129/0x138
 [<ffffffff81094fdd>] kmem_cache_alloc+0xd1/0xfe
 [<ffffffff8133c2f9>] sk_prot_alloc+0x2c/0xcd
 [<ffffffff8133c427>] sk_clone+0x1b/0x24b
 [<ffffffff81369ce2>] inet_csk_clone+0x13/0x81
 [<ffffffff8137d698>] tcp_create_openreq_child+0x1d/0x39c
 [<ffffffff8137c309>] tcp_v4_syn_recv_sock+0x57/0x1bc
 [<ffffffff8137d50f>] tcp_check_req+0x210/0x37c
 [<ffffffffa0154423>] ? ipv4_confirm+0x161/0x179 [nf_conntrack_ipv4]
 [<ffffffff8137ba63>] tcp_v4_do_rcv+0xc1/0x1d7
 [<ffffffff8137c021>] tcp_v4_rcv+0x4a8/0x739
 [<ffffffff8135ba27>] ? nf_hook_slow+0x63/0xc3
 [<ffffffff81361bb0>] ? ip_local_deliver_finish+0x0/0x1d0
 [<ffffffff81361ca8>] ip_local_deliver_finish+0xf8/0x1d0
 [<ffffffff81361df2>] ip_local_deliver+0x72/0x7a
 [<ffffffff813618ac>] ip_rcv_finish+0x33c/0x356
 [<ffffffff81361b79>] ip_rcv+0x2b3/0x2ea
 [<ffffffff813a2861>] ? packet_rcv_spkt+0x10f/0x11a
 [<ffffffff8134660a>] netif_receive_skb+0x2cb/0x2ed
 [<ffffffff81346767>] napi_skb_finish+0x28/0x40
 [<ffffffff81346ba5>] napi_gro_receive+0x2a/0x2f
 [<ffffffffa001669d>] igb_poll+0x507/0x86a [igb]
 [<ffffffffa0015ef8>] ? igb_clean_tx_irq+0x1dd/0x47b [igb]
 [<ffffffff81346cb6>] net_rx_action+0xa7/0x178
 [<ffffffff8103bd21>] __do_softirq+0x96/0x119
 [<ffffffff8100bf5c>] call_softirq+0x1c/0x28
 [<ffffffff8100d9e7>] do_softirq+0x33/0x6b
 [<ffffffff8103b844>] irq_exit+0x36/0x38
 [<ffffffff8100d0e9>] do_IRQ+0xa3/0xba
 [<ffffffff8100b7d3>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffffa00f046f>] ? xfs_reclaim_inode_shrink+0xc3/0x112 [xfs]
 [<ffffffffa00f0451>] ? xfs_reclaim_inode_shrink+0xa5/0x112 [xfs]
 [<ffffffffa00f04bd>] ? xfs_reclaim_inode_shrink+0x111/0x112 [xfs]
 [<ffffffff810770fc>] ? shrink_slab+0xd2/0x154
 [<ffffffff81077e00>] ? try_to_free_pages+0x221/0x31c
 [<ffffffff81074f4a>] ? isolate_pages_global+0x0/0x1f0
 [<ffffffff81071d79>] ? __alloc_pages_nodemask+0x3fd/0x600
 [<ffffffff8109428b>] ? kmem_getpages+0x5c/0x127
 [<ffffffff81094475>] ? fallback_alloc+0x11f/0x195
 [<ffffffff81094614>] ? ____cache_alloc_node+0x129/0x138
 [<ffffffff810a9055>] ? pollwake+0x0/0x5b
 [<ffffffff810946bf>] ? kmem_cache_alloc_node+0x9c/0xc7
 [<ffffffff8109472d>] ? __kmalloc_node+0x43/0x45
 [<ffffffff81340625>] ? __alloc_skb+0x6b/0x164
 [<ffffffff8133bcc1>] ? sock_alloc_send_pskb+0xdd/0x31c
 [<ffffffff8133bf10>] ? sock_alloc_send_skb+0x10/0x12
 [<ffffffff8139e4c2>] ? unix_stream_sendmsg+0x180/0x312
 [<ffffffff81338270>] ? sock_aio_write+0x109/0x122
 [<ffffffff8100b7ce>] ? common_interrupt+0xe/0x13
 [<ffffffff8109a41a>] ? do_sync_write+0xe7/0x12d
 [<ffffffff81049208>] ? autoremove_wake_function+0x0/0x38
 [<ffffffff8100b7ce>] ? common_intreclaimable:78357
 mapped:11679 shmem:26799 pagetables:13497 bounce:0

--Multipart=_Thu__10_Feb_2011_16_48_45_-0800_C=+fMws77XyIT3C2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
