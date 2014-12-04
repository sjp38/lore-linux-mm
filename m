Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id DC00B6B0032
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 18:30:37 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id r20so29621602wiv.8
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 15:30:37 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bt4si63226wib.2.2014.12.04.15.30.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Dec 2014 15:30:36 -0800 (PST)
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
	by mx2.suse.de (Postfix) with ESMTP id 21F67AB07
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 23:30:36 +0000 (UTC)
Message-ID: <5480EE9D.1050503@suse.cz>
Date: Fri, 05 Dec 2014 00:30:37 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
References: <546D2366.1050506@suse.cz> <20141121023554.GA24175@cucumber.bridge.anchor.net.au> <20141123093348.GA16954@cucumber.anchor.net.au> <CABYiri8LYukujETMCb4gHUQd=J-MQ8m=rGRiEkTD1B42Jh=Ksg@mail.gmail.com> <20141128080331.GD11802@js1304-P5Q-DELUXE> <54783FB7.4030502@suse.cz> <20141201083118.GB2499@js1304-P5Q-DELUXE> <20141202014724.GA22239@cucumber.bridge.anchor.net.au> <20141202045324.GC6268@js1304-P5Q-DELUXE> <20141202050608.GA11051@cucumber.bridge.anchor.net.au> <20141203040404.GA16499@cucumber.bridge.anchor.net.au>
In-Reply-To: <20141203040404.GA16499@cucumber.bridge.anchor.net.au>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

On 3.12.2014 5:04, Christian Marie wrote:
> On Tue, Dec 02, 2014 at 04:06:08PM +1100, Christian Marie wrote:
>> I will attempt to do this tomorrow and should have results in around 24 hours.
> I ran said test today and wasn't able to pinpoint a solid difference between a kernel
> with both patches and one with only the first. The one with both patches "felt"
> a little more responsive, probably a fluke.
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
>
> There's enough starvation to break single page allocations.

Oh, I would think that if you can't allocate single pages, then there's
little wonder that compaction also spends all its time looking for single
free pages. Did that happen just now for the single page allocations,
or was it always the case?

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


---
This email has been checked for viruses by Avast antivirus software.
http://www.avast.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
