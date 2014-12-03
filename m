Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 27B956B006C
	for <linux-mm@kvack.org>; Wed,  3 Dec 2014 03:02:35 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so15243445pab.14
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 00:02:34 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id jd4si37063254pbb.112.2014.12.03.00.02.31
        for <linux-mm@kvack.org>;
        Wed, 03 Dec 2014 00:02:33 -0800 (PST)
Date: Wed, 3 Dec 2014 17:05:59 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Message-ID: <20141203080559.GC6276@js1304-P5Q-DELUXE>
References: <20141121023554.GA24175@cucumber.bridge.anchor.net.au>
 <20141123093348.GA16954@cucumber.anchor.net.au>
 <CABYiri8LYukujETMCb4gHUQd=J-MQ8m=rGRiEkTD1B42Jh=Ksg@mail.gmail.com>
 <20141128080331.GD11802@js1304-P5Q-DELUXE>
 <54783FB7.4030502@suse.cz>
 <20141201083118.GB2499@js1304-P5Q-DELUXE>
 <20141202014724.GA22239@cucumber.bridge.anchor.net.au>
 <20141202045324.GC6268@js1304-P5Q-DELUXE>
 <20141202050608.GA11051@cucumber.bridge.anchor.net.au>
 <20141203040404.GA16499@cucumber.bridge.anchor.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141203040404.GA16499@cucumber.bridge.anchor.net.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

On Wed, Dec 03, 2014 at 03:04:04PM +1100, Christian Marie wrote:
> On Tue, Dec 02, 2014 at 04:06:08PM +1100, Christian Marie wrote:
> > I will attempt to do this tomorrow and should have results in around 24 hours.
> 
> I ran said test today and wasn't able to pinpoint a solid difference between a kernel
> with both patches and one with only the first. The one with both patches "felt"
> a little more responsive, probably a fluke.

Thanks! It would help me.

> 
> I'd really like to write a stress test that simulates what ceph/ipoib is doing
> here so that I can test this in a more scientific manner.
> 
> Here is some perf output, the kernel with only the first patch is on the right:
> 
> http://ponies.io/raw/before-after.png
> 
> 
> A note in passing: we left the cluster running with min_free_kbytes set to the
> default last night and within a few hours it started spewing the usual
> pre-patch allocation failures, so whilst this patch appears to make the system
> more responsive under adverse conditions the underlying
> not-keeping-up-with-pressure issue is still there.

I guess that it is caused by too fast allocation. If your allocation rate
is more than kswapd's reclaim rate and no GFP_WAIT, failure would be possible.
Following failure log looks that case. In this case, enlaring
min_free_kbytes may be right solution, but, I'm not expert so please consult
other MM guys.

> There's enough starvation to break single page allocations.
> 
> Keep in mind that this is on a 3.10 kernel with the patches applied so I'm not
> expecting anyone to particularly care. I'm running out of time to test the
> whole cluster at 3.18 is all, I really do think that replicating the allocation
> pattern is the best way forward but my attempts at simply sending a lot of
> packets that look similar with lots of page cache don't do it.
> 
> Those allocation failures on 3.10 with both patches look like this:
> 
> 	[73138.803800] ceph-osd: page allocation failure: order:0, mode:0x20
> 	[73138.803802] CPU: 0 PID: 9214 Comm: ceph-osd Tainted: GF
> 	O--------------   3.10.0-123.9.3.anchor.x86_64 #1
> 	[73138.803803] Hardware name: Dell Inc. PowerEdge R720xd/0X3D66, BIOS 2.2.2
> 	01/16/2014
> 	[73138.803803]  0000000000000020 00000000d6532f99 ffff88081fa03aa0
> 	ffffffff815e23bb
> 	[73138.803806]  ffff88081fa03b30 ffffffff81147340 00000000ffffffff
> 	ffff8807da887900
> 	[73138.803808]  ffff88083ffd9e80 ffff8800b2242900 ffff8807d843c050
> 	00000000d6532f99
> 	[73138.803812] Call Trace:
> 	[73138.803813]  <IRQ>  [<ffffffff815e23bb>] dump_stack+0x19/0x1b
> 	[73138.803817]  [<ffffffff81147340>] warn_alloc_failed+0x110/0x180
> 	[73138.803819]  [<ffffffff8114b4ee>] __alloc_pages_nodemask+0x91e/0xb20
> 	[73138.803821]  [<ffffffff8152f82a>] ? tcp_v4_rcv+0x67a/0x7c0
> 	[73138.803823]  [<ffffffff81509710>] ? ip_rcv_finish+0x350/0x350
> 	[73138.803826]  [<ffffffff81188369>] alloc_pages_current+0xa9/0x170
> 	[73138.803828]  [<ffffffff814bedb1>] __netdev_alloc_frag+0x91/0x140
> 	[73138.803831]  [<ffffffff814c0df7>] __netdev_alloc_skb+0x77/0xc0
> 	[73138.803834]  [<ffffffffa06b54c5>] ipoib_cm_handle_rx_wc+0xf5/0x940
> 	[ib_ipoib]
> 	[73138.803838]  [<ffffffffa0625e78>] ? mlx4_ib_poll_cq+0xc8/0x210 [mlx4_ib]
> 	[73138.803841]  [<ffffffffa06a90ed>] ipoib_poll+0x8d/0x150 [ib_ipoib]
> 	[73138.803843]  [<ffffffff814d05aa>] net_rx_action+0x15a/0x250
> 	[73138.803846]  [<ffffffff81067047>] __do_softirq+0xf7/0x290
> 	[73138.803848]  [<ffffffff815f43dc>] call_softirq+0x1c/0x30
> 	[73138.803851]  [<ffffffff81014d25>] do_softirq+0x55/0x90
> 	[73138.803853]  [<ffffffff810673e5>] irq_exit+0x115/0x120
> 	[73138.803855]  [<ffffffff815f4cd8>] do_IRQ+0x58/0xf0
> 	[73138.803857]  [<ffffffff815e9e2d>] common_interrupt+0x6d/0x6d
> 	[73138.803858]  <EOI>  [<ffffffff815f2bc0>] ? sysret_audit+0x17/0x21
> 
> We get some like this, also:
> 
> [ 1293.152415] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
> [ 1293.152416]   cache: kmalloc-256, object size: 256, buffer size: 256,
> default order: 1, min order: 0
> [ 1293.152417]   node 0: slabs: 1789, objs: 57248, free: 0
> [ 1293.152418]   node 1: slabs: 449, objs: 14368, free: 2
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
