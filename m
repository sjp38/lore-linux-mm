Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 12D406B0044
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 20:21:12 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA51LAiA008012
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 5 Nov 2009 10:21:10 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 240D145DE58
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 10:21:10 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BBE3045DE50
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 10:21:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 908111DB803C
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 10:21:09 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 15EC51DB803E
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 10:21:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: strange OOM receiving a wireless network packet on a SLUB system
In-Reply-To: <87zl71lt7l.fsf_-_@spindle.srvr.nix>
References: <c7a347a10911041421u35b102behe0ed2d94506680c1@mail.gmail.com> <87zl71lt7l.fsf_-_@spindle.srvr.nix>
Message-Id: <20091105094611.2081.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  5 Nov 2009 10:21:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Nix <nix@esperi.org.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, TuxOnIce users' list <tuxonice-users@lists.tuxonice.net>, Linux-Kernel-Mailing-List <linux-kernel@vger.kernel.org>, dominik.stadler@gmx.at, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi

(cc to linux-mm)

> On 4 Nov 2009, Dominik Stadler stated:
> > I just saw a very similar thing happening to me here, ThinkPad T500, Ubuntu
> > 9.10, latest 3.0.1+TOI-Kernel from Karmic-PPA, I  have some other weirdness
> > as well which I am not sure if TOI-related or Karmic, will do some
> > Divide-And-Conquer analysis next to find out the root cause of these and
> > report back.
> >
> > $ uname -a
> > Linux XXXXXX 2.6.31-15-generic #49+tuxonice2-Ubuntu SMP Sat Oct 31 01:46:15
> > UTC 2009 x86_64 GNU/Linux
> >
> > This is what I got just now:
> >
> > Nov  4 22:40:22 dstathink kernel: [39835.951178] swapper: page allocation
> > failure. order:2, mode:0x4020

This is only page allocation failure. not OOM.
We don't gurantee GFP_ATOMIC allocation success.

> 
> That doesn't really look similar to me (not a decompressor -22 error).
> To me it looks more like you ran out of memory, or at least ran very close
> to out: an order-2 allocation is not enormous (16Kb on x86) and should
> definitely work after everything's been chucked out. (mode 0x4020 implies
> a compound-page GFP_ATOMIC allocation, so it couldn't swap, but it
> could certainly discard clean pages.)

No. GFP_ATOMIC can't discard clean pages, anyway. because irq-context don't
tolerate from reclaim latency.

> 
> Did this happen at suspension time, resumption time,or what? It looks
> like the kernel hadn't been up for long, so I guess we can rule out
> really really bad arena fragmentation... but it was long enough that I
> guess this was at suspension time?
>
> > Nov  4 22:40:22 dstathink kernel: [39835.951178] Pid: 0, comm: swapper
> > Tainted: G         C 2.6.31-15-generic #49+tuxonice2-Ubuntu
> > Nov  4 22:40:22 dstathink kernel: [39835.951178] Call
> > Trace:
> > Nov  4 22:40:22 dstathink kernel: [39835.951178]  <IRQ>
> > [<ffffffff810f1abc>]
> > __alloc_pages_slowpath+0x4cc/0x4e0
> > 
> > Nov  4 22:40:22 dstathink kernel: [39835.951178]  [<ffffffff810f1c1e>]
> > __alloc_pages_nodemask+0x14e/0x150
> > 
> > Nov  4 22:40:22 dstathink kernel: [39835.951178]  [<ffffffff811230ca>]
> > kmalloc_large_node+0x5a/0xb0
> > 
> > Nov  4 22:40:22 dstathink kernel: [39835.951178]  [<ffffffff81127275>]
> > __kmalloc_node_track_caller+0x135/0x180
> 
> This is SLUB stuff. Is SLUB production-ready yet? (I haven't been
> following it.)
> 
> (Networking, wireless, SLUB, no idea where to Cc this. I'll just Cc LKML
> and see if anyone notices :) )

SLUB is perfectly stable and usable for production.

> 
> > Nov  4 22:40:22 dstathink kernel: [39835.951178]  [<ffffffffa0245899>] ?
> > iwl_rx_allocate+0x1a9/0x230
> > [iwlcore]
> >
> > Nov  4 22:40:22 dstathink kernel: [39835.951178]  [<ffffffff8144088b>]
> > __alloc_skb+0x7b/0x180
> >
> > Nov  4 22:40:22 dstathink kernel: [39835.951178]  [<ffffffffa0245899>]
> > iwl_rx_allocate+0x1a9/0x230
> > [iwlcore]
> 
> Wireless network packet reception leading to OOM. Not TuxOnIce, I'd say.
> Certainly not the same problem as me: I don't even *have* any wireless
> hardware (with my RSI, laptops might as well have razor blades on their
> keys).
> 
> (Why does it need a 16Kb contiguous region anyway?

Dunno ;)


> > Nov  4 22:40:22 dstathink kernel: [39835.951178]  [<ffffffff81010e12>] ?
> > cpu_idle+0xb2/0x100
> 
> Idle, not suspending...
> 
> > Nov  4 22:40:22 dstathink kernel: [39835.951178] Active_anon:365111
> > active_file:88612 inactive_anon:162361
> 
> Lots of inactive pages. Why were none chucked out?
> 
> > Nov  4 22:40:22 dstathink kernel: [39835.951178]  inactive_file:243222
> > unevictable:4 dirty:214598 writeback:320 unstable:0
> 
> 214000+ dirty pages seems awfully high.
> 
> > Nov  4 22:40:22 dstathink kernel: [39835.951178]  free:6876 slab:51582
> > mapped:40147 pagetables:8440 bounce:0
> 
> 6876 free pages, a reasonable-enough figure, yet it couldn't find four
> in a row to receive a network packet? Seems unlikely.
> 
> > Nov  4 22:40:22 dstathink kernel: [39835.951178] Node 0 DMA free:15644kB
> > min:28kB low:32kB high:40kB active_anon:12kB inactive_anon:32kB
> > active_file:4kB inactive_file:208kB unevictable:0kB present:15336kB
> > pages_scanned:0 all_unreclaimable? no
> > 
> > Nov  4 22:40:22 dstathink kernel: [39835.951178] lowmem_reserve[]: 0 2958
> > 3905 3905
> >
> > Nov  4 22:40:22 dstathink kernel: [39835.951178] Node 0 DMA32 free:10124kB
> > min:6044kB low:7552kB high:9064kB active_anon:1223088kB
> > inactive_anon:367500kB active_file:218036kB inactive_file:833596kB
> > unevictable:16kB present:3029636kB pages_scanned:0 all_unreclaimable?
> > no
> >
> > Nov  4 22:40:22 dstathink kernel: [39835.951178] lowmem_reserve[]: 0 0 946
> > 946
> >
> > Nov  4 22:40:22 dstathink kernel: [39835.951178] Node 0 Normal free:1736kB
> > min:1932kB low:2412kB high:2896kB active_anon:237344kB
> > inactive_anon:281912kB active_file:136408kB inactive_file:139084kB
> > unevictable:0kB present:969600kB pages_scanned:0 all_unreclaimable?
> > no
> 
> Again, heaps of inactive.

On normal zone, free(1736kB) < min(1932kB). It mean we can't use normal zone.
On DMA32 zone, free(10124kB) < min(6044kB) + lowmem_reserve(946*4kB).
It mean we can't use DMA32 zone too.
Of cource, DMA zone is protected by lowmem_reserve too.

It's normal memory shortage.

> 
> > Nov  4 22:40:22 dstathink kernel: [39835.951178] lowmem_reserve[]: 0 0 0
> > 0
> >
> > Nov  4 22:40:22 dstathink kernel: [39835.951178] Node 0 DMA: 7*4kB 4*8kB
> > 2*16kB 2*32kB 2*64kB 2*128kB 3*256kB 2*512kB 3*1024kB 3*2048kB 1*4096kB 15644kB
> > Nov  4 22:40:22 dstathink kernel: [39835.951178] Node 0 DMA32: 2249*4kB
> > 35*8kB 1*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB
> > 0*4096kB = 10124kB
> > Nov  4 22:40:22 dstathink kernel: [39835.951178] Node 0 Normal: 132*4kB
> > 127*8kB 2*16kB 1*32kB 0*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB
> > 0*4096kB = 1736kB

All zones have order-2 contenious memory.


The conclusion is, the system is not so fragmentaion. but It doesn't have
enough memory.
Maybe, the system is under temporal memory pressure. you don't need care it.
It automatically restored soon.


> > Nov  4 22:40:22 dstathink kernel: [39835.951178] 390803 total pagecache
> > pages
> >
> > Nov  4 22:40:22 dstathink kernel: [39835.951178] 12039 pages in swap
> > cache
> >
> > Nov  4 22:40:22 dstathink kernel: [39835.951178] Swap cache stats: add
> > 41296, delete 29257, find
> > 4825/7516
> >
> > Nov  4 22:40:22 dstathink kernel: [39835.951178] Free swap  8330844kB
> >
> > Nov  4 22:40:22 dstathink kernel: [39835.951178] Total swap 8393952kB
> >
> > Nov  4 22:40:22 dstathink kernel: [39835.951178] 1032192 pages
> > RAM
> >
> > Nov  4 22:40:22 dstathink kernel: [39835.951178] 76928 pages
> > reserved
> >
> > Nov  4 22:40:22 dstathink kernel: [39835.951178] 488347 pages
> > shared
> >
> > Nov  4 22:40:22 dstathink kernel: [39835.951178] 596692 pages non-shared
> 
> OK, I don't know why this failed, but I'm an mm neophyte running on pure
> grep. Any ideas from anyone with an actual clue in this area? (I know OOM
> is all the rage right now, so maybe this will garner some attention :) )
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
