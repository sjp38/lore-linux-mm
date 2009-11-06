Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 19DD16B0044
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 01:03:29 -0500 (EST)
Date: Fri, 6 Nov 2009 07:03:23 +0100
From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC
	failures V2
Message-ID: <20091106060323.GA5528@yumi.tdiedrich.de>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1256221356-26049-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> [No BZ ID] Kernel crash on 2.6.31.x (kcryptd: page allocation failure..)
> 	This apparently is easily reproducible, particular in comparison to
> 	the other reports. The point of greatest interest is that this is
> 	order-0 GFP_ATOMIC failures. Sven, I'm hoping that you in particular
> 	will be able to follow the tests below as you are the most likely
> 	person to have an easily reproducible situation.

I've also seen order-0 failures on 2.6.31.5:
Note that this is with a one process hogging and mlocking memory and
min_free_kbytes reduced to 100 to reproduce the problem more easily.

I tried bisecting the issue, but in the end without memory pressure
I can't reproduce it reliably and with the above mentioned pressure
I get allocation failures even on 2.6.30.o

Initially the issue was that the machine hangs after the allocation
failure, but that seems to be a netconsole related issue, since I
didn't get a hang on 2.6.31 compiled without netconsole.
http://lkml.org/lkml/2009/11/1/66
http://lkml.org/lkml/2009/11/5/100

[  375.398423] swapper: page allocation failure. order:0, mode:0x20
[  375.398483] Pid: 0, comm: swapper Not tainted 2.6.31.5-nokmem-tomodachi #3
[  375.398519] Call Trace:
[  375.398566]  [<c10395a8>] ? __alloc_pages_nodemask+0x40f/0x453
[  375.398613]  [<c104e988>] ? cache_alloc_refill+0x1f3/0x382
[  375.398648]  [<c104eb76>] ? __kmalloc+0x5f/0x97
[  375.398690]  [<c1228003>] ? __alloc_skb+0x44/0x101
[  375.398723]  [<c12289b5>] ? dev_alloc_skb+0x11/0x25
[  375.398760]  [<c11a53a1>] ? tulip_refill_rx+0x3c/0x115
[  375.398793]  [<c11a57f7>] ? tulip_poll+0x37d/0x416
[  375.398832]  [<c122cf56>] ? net_rx_action+0x3a/0xdb
[  375.398874]  [<c101d8b0>] ? __do_softirq+0x5b/0xcb
[  375.398908]  [<c101d855>] ? __do_softirq+0x0/0xcb
[  375.398937]  <IRQ>  [<c1003e0b>] ? do_IRQ+0x66/0x76
[  375.398989]  [<c1002d70>] ? common_interrupt+0x30/0x38
[  375.399026]  [<c100725c>] ? default_idle+0x25/0x38
[  375.399058]  [<c1001a1e>] ? cpu_idle+0x64/0x7a
[  375.399102]  [<c14105ff>] ? start_kernel+0x251/0x258
[  375.399133] Mem-Info:
[  375.399159] DMA per-cpu:
[  375.399184] CPU    0: hi:    0, btch:   1 usd:   0
[  375.399214] Normal per-cpu:
[  375.399241] CPU    0: hi:   90, btch:  15 usd:  28
[  375.399276] Active_anon:6709 active_file:1851 inactive_anon:6729
[  375.399278]  inactive_file:2051 unevictable:40962 dirty:998 writeback:914 unstable:0
[  375.399281]  free:232 slab:1843 mapped:1404 pagetables:613 bounce:0
[  375.399391] DMA free:924kB min:4kB low:4kB high:4kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:15028kB present:15872kB pages_scanned:0 all_unreclaimable? yes
[  375.399465] lowmem_reserve[]: 0 230 230
[  375.399537] Normal free:4kB min:92kB low:112kB high:136kB active_anon:26836kB inactive_anon:26916kB active_file:7404kB inactive_file:8204kB unevictable:148820kB present:235648kB pages_scanned:32 all_unreclaimable? no
[  375.399615] lowmem_reserve[]: 0 0 0
[  375.399681] DMA: 1*4kB 1*8kB 1*16kB 0*32kB 0*64kB 1*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 924kB
[  375.399850] Normal: 1*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 4kB
[  375.400016] 4412 total pagecache pages
[  375.400041] 494 pages in swap cache
[  375.400041] Swap cache stats: add 8110, delete 7616, find 139/205
[  375.400041] Free swap  = 494212kB
[  375.400041] Total swap = 524280kB
[  375.400041] 63472 pages RAM
[  375.400041] 1742 pages reserved
[  375.400041] 14429 pages shared
[  375.400041] 56917 pages non-shared
[  378.306631] swapper: page allocation failure. order:0, mode:0x20
[  378.306686] Pid: 0, comm: swapper Not tainted 2.6.31.5-nokmem-tomodachi #3
[  378.306722] Call Trace:
[  378.306769]  [<c10395a8>] ? __alloc_pages_nodemask+0x40f/0x453
[  378.306817]  [<c104e988>] ? cache_alloc_refill+0x1f3/0x382
[  378.306853]  [<c104eb76>] ? __kmalloc+0x5f/0x97
[  378.306894]  [<c1228003>] ? __alloc_skb+0x44/0x101
[  378.306927]  [<c12289b5>] ? dev_alloc_skb+0x11/0x25
[  378.306964]  [<c11a53a1>] ? tulip_refill_rx+0x3c/0x115
[  378.306996]  [<c11a57f7>] ? tulip_poll+0x37d/0x416
[  378.307035]  [<c122cf56>] ? net_rx_action+0x3a/0xdb
[  378.307079]  [<c101d8b0>] ? __do_softirq+0x5b/0xcb
[  378.307112]  [<c101d855>] ? __do_softirq+0x0/0xcb
[  378.307142]  <IRQ>  [<c1003e0b>] ? do_IRQ+0x66/0x76
[  378.307193]  [<c1002d70>] ? common_interrupt+0x30/0x38
[  378.307232]  [<c100725c>] ? default_idle+0x25/0x38
[  378.307263]  [<c1001a1e>] ? cpu_idle+0x64/0x7a
[  378.307306]  [<c14105ff>] ? start_kernel+0x251/0x258
[  378.307338] Mem-Info:
[  378.307364] DMA per-cpu:
[  378.307389] CPU    0: hi:    0, btch:   1 usd:   0
[  378.307420] Normal per-cpu:
[  378.307446] CPU    0: hi:   90, btch:  15 usd:  70
[  378.307480] Active_anon:6231 active_file:2340 inactive_anon:6283
[  378.307483]  inactive_file:2445 unevictable:40962 dirty:989 writeback:1024 unstable:0
[  378.307485]  free:232 slab:1872 mapped:1408 pagetables:613 bounce:0
[  378.307595] DMA free:924kB min:4kB low:4kB high:4kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:15028kB present:15872kB pages_scanned:0 all_unreclaimable? yes
[  378.307668] lowmem_reserve[]: 0 230 230
[  378.307739] Normal free:4kB min:92kB low:112kB high:136kB active_anon:24924kB inactive_anon:25132kB active_file:9360kB inactive_file:9780kB unevictable:148820kB present:235648kB pages_scanned:32 all_unreclaimable? no
[  378.307816] lowmem_reserve[]: 0 0 0
[  378.307882] DMA: 1*4kB 1*8kB 1*16kB 0*32kB 0*64kB 1*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 924kB
[  378.308052] Normal: 1*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 4kB
[  378.308219] 5866 total pagecache pages
[  378.308247] 1065 pages in swap cache
[  378.308277] Swap cache stats: add 9651, delete 8586, find 152/220
[  378.308308] Free swap  = 488152kB
[  378.308334] Total swap = 524280kB
[  378.310030] 63472 pages RAM
[  378.310030] 1742 pages reserved
[  378.310030] 15289 pages shared
[  378.310030] 56019 pages non-shared

-- 
Tobias						PGP: http://8ef7ddba.uguu.de

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
