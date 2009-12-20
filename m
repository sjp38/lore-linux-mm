Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 723816B0044
	for <linux-mm@kvack.org>; Sun, 20 Dec 2009 06:52:28 -0500 (EST)
Date: Sun, 20 Dec 2009 12:52:23 +0100 (CET)
From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: page allocation failure - still unfixed in 2.6.32.1
In-Reply-To: <20091220124721.006da86a.attila@kinali.ch>
Message-ID: <alpine.DEB.1.10.0912201250310.23464@uplift.swm.pp.se>
References: <20091220124721.006da86a.attila@kinali.ch>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Attila Kinali <attila@kinali.ch>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 20 Dec 2009, Attila Kinali wrote:

> Moin,
>
> The page allocation failure that was introduced in 2.6.31 and
> which has been discussed here a few times, is still present in
> 2.6.32.1. I can still (more or less) reproduce it on my home-fileserver:
>
> Dec 20 11:43:14 koyomi kernel: swapper: page allocation failure. order:3, mode:0x20
> Dec 20 11:43:14 koyomi kernel: Pid: 0, comm: swapper Not tainted 2.6.32.1 #1
> Dec 20 11:43:14 koyomi kernel: Call Trace:

Are you sure these are new? I've been seeing them sporadically for years, 
this latest one is on 2.6.28. They seem to happen whenever there are lots 
of TCP sessions going, and I have raised the default TCP parameters for 
long latency performance.

[1136500.281189] swapper: page allocation failure. order:0, mode:0x4020
[1136500.281193] Pid: 0, comm: swapper Not tainted 2.6.28-16-generic 
#57-Ubuntu
[1136500.281195] Call Trace:
[1136500.281197]  <IRQ>  [<ffffffff802b6e2e>] 
__alloc_pages_internal+0x3ee/0x500
[1136500.281207]  [<ffffffff802dfe68>] alloc_slab_page+0x28/0x30
[1136500.281211]  [<ffffffff802e0f2a>] new_slab+0x5a/0x210
[1136500.281215]  [<ffffffff80213668>] ? apic_timer_interrupt+0x88/0x90
[1136500.281219]  [<ffffffff802e2548>] __slab_alloc+0x188/0x290
[1136500.281224]  [<ffffffff805aa21f>] ? __netdev_alloc_skb+0x1f/0x40
[1136500.281228]  [<ffffffff802e3457>] __kmalloc_track_caller+0xd7/0x110
[1136500.281232]  [<ffffffff805aa21f>] ? __netdev_alloc_skb+0x1f/0x40
[1136500.281236]  [<ffffffff805a9ebe>] __alloc_skb+0x6e/0x150
[1136500.281240]  [<ffffffff805aa21f>] __netdev_alloc_skb+0x1f/0x40
[1136500.281252]  [<ffffffffa00ad780>] sky2_rx_alloc+0x80/0x140 [sky2]
[1136500.281259]  [<ffffffffa00b09a9>] receive_new+0x29/0x160 [sky2]
[1136500.281265]  [<ffffffffa00b0c23>] sky2_receive+0x143/0x280 [sky2]
[1136500.281272]  [<ffffffffa00b220d>] sky2_status_intr+0x17d/0x5a0 [sky2]
[1136500.281279]  [<ffffffffa00b2697>] sky2_poll+0x67/0x160 [sky2]
[1136500.281283]  [<ffffffff805b40c4>] net_rx_action+0x104/0x240
[1136500.281287]  [<ffffffff80256c4c>] __do_softirq+0x9c/0x170
[1136500.281291]  [<ffffffff80213d8c>] call_softirq+0x1c/0x30
[1136500.281295]  [<ffffffff80214ffd>] do_softirq+0x5d/0xa0
[1136500.281298]  [<ffffffff802569cd>] irq_exit+0x8d/0xa0
[1136500.281301]  [<ffffffff802152c5>] do_IRQ+0xc5/0x110
[1136500.281305]  [<ffffffff80212bf3>] ret_from_intr+0x0/0x29
[1136500.281307]  <EOI>  [<ffffffff8021a95a>] ? mwait_idle+0x4a/0x50
[1136500.281315]  [<ffffffff80210dd2>] ? enter_idle+0x22/0x30
[1136500.281319]  [<ffffffff80210e85>] ? cpu_idle+0x65/0xc0
[1136500.281324]  [<ffffffff806963d3>] ? start_secondary+0x9e/0xcb
[1136500.281326] Mem-Info:
[1136500.281328] DMA per-cpu:
[1136500.281330] CPU    0: hi:    0, btch:   1 usd:   0
[1136500.281332] CPU    1: hi:    0, btch:   1 usd:   0
[1136500.281334] DMA32 per-cpu:
[1136500.281336] CPU    0: hi:  186, btch:  31 usd:  46
[1136500.281339] CPU    1: hi:  186, btch:  31 usd:  35
[1136500.281340] Normal per-cpu:
[1136500.281342] CPU    0: hi:  186, btch:  31 usd:  35
[1136500.281344] CPU    1: hi:  186, btch:  31 usd:  25
[1136500.281348] Active_anon:146370 active_file:616793 inactive_anon:74536
[1136500.281350]  inactive_file:1107274 unevictable:7 dirty:95693 
writeback:692 unstable:0
[1136500.281351]  free:7738 slab:51933 mapped:76435 pagetables:5975 
bounce:0
[1136500.281355] DMA free:6700kB min:4kB low:4kB high:4kB active_anon:0kB 
inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB 
present:5560kB pages_scanned:0 all_unreclaimable? no
[1136500.281359] lowmem_reserve[]: 0 2999 8049 8049
[1136500.281365] DMA32 free:21728kB min:4276kB low:5344kB high:6412kB 
active_anon:117556kB inactive_anon:73404kB active_file:895956kB 
inactive_file:1639760kB unevictable:0kB present:3071712kB pages_scanned:0 
all_unreclaimable? no
[1136500.281369] lowmem_reserve[]: 0 0 5050 5050
[1136500.281376] Normal free:2524kB min:7200kB low:9000kB high:10800kB 
active_anon:467924kB inactive_anon:224740kB active_file:1571216kB 
inactive_file:2789336kB unevictable:28kB present:5171200kB pages_scanned:0 
all_unreclaimable? no
[1136500.281379] lowmem_reserve[]: 0 0 0 0
[1136500.281384] DMA: 5*4kB 5*8kB 5*16kB 5*32kB 4*64kB 4*128kB 2*256kB 
2*512kB 0*1024kB 0*2048kB 1*4096kB = 6700kB
[1136500.281395] DMA32: 5191*4kB 1*8kB 51*16kB 1*32kB 0*64kB 0*128kB 
0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 21620kB
[1136500.281406] Normal: 450*4kB 2*8kB 36*16kB 0*32kB 0*64kB 1*128kB 
0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2520kB
[1136500.281417] 1727600 total pagecache pages
[1136500.281420] 0 pages in swap cache
[1136500.281422] Swap cache stats: add 0, delete 0, find 0/0
[1136500.281424] Free swap  = 0kB
[1136500.281425] Total swap = 0kB
[1136500.285180] 2359280 pages RAM
[1136500.285180] 339669 pages reserved
[1136500.285180] 602075 pages shared
[1136500.285180] 1500164 pages non-shared


-- 
Mikael Abrahamsson    email: swmike@swm.pp.se

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
