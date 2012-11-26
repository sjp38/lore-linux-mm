Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 4B3106B0071
	for <linux-mm@kvack.org>; Sun, 25 Nov 2012 22:58:42 -0500 (EST)
Date: 25 Nov 2012 22:58:41 -0500
Message-ID: <20121126035841.5973.qmail@science.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: 3.7-rc6 soft lockup in kswapd0
In-Reply-To: <20121123085137.GA646@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@horizon.com, mgorman@suse.de
Cc: dave@linux.vnet.ibm.com, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Sorry for the delay; was AF(that)K for the weekend.

> Ok, is there any chance you can capture more of sysrq+m, particularly the
> bits that say how much free memory there is and many pages of each order
> that is free? If you can't, it's ok. I ask because my kernel bug dowsing
> rod is twitching in the direction of the recent free page accounting bug
> Dave Hansen identified and fixed -- https://lkml.org/lkml/2012/11/21/504

Okay; as mentioned, I installed that patch and it didn't make any obvious
difference to the symptoms.

The hang IP is still either in __zone_watermark_ok or kswapd (address varies).

> The free page counter and these free lists should be close together. If
> there is a big gap then it's almost certainly the bug Dave identified.

The full sysrq-M output (at least the 49 lines I could read without
working scrollback) is here.  I went over it twice (at least, all the
varying numbers; I may have a typo in some of the fixed text), so I'm
pretty sure it's right.

DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd: 181
HighMem per-cpu:
CPU    0: hi:  186, btch:  31 usd: 172
active_anon:14759 inactive_anon:6504 isolated_anon:0
 active_file:126610 inactive_file:283340 isolated_file:0
 unevictable:0 dirty:289 writeback:0 unstable:0
 free:39060 slab_reclaimable:44235 slab_unreclaimable:1079
 mapped:4468 shmem:580 pagetables:301 bounce:0
 free_cma:0
DMA free:9044kB min:784kB low:980kB high:1176kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:6868kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15804kB mlocked:0kB dirty:4kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 865 2016 2016
Normal free:107016kB min:44012kB low:55012kB high:66016kB active_anon:9096kB inactive_anon:9344kB active_file:296716kB inactive_file:257136kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:885944kB mlocked:0kB dirty:1152kB writeback:0kB mapped:4kB shmem:0kB slab_reclaimable:176940kB slab_unreclaimable:4316kB kernel_stack:1104kB pagetables:1204kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 9207 9207
HighMem free:40180kB min:512kB low:15148kB high:29784kB active_anon:49940kB inactive_anon:16672kB active_file:209724kB inactive_file:869356kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1178552kB mlocked:0kB dirty:4kB writeback:0kB mapped:17868kB shmem:2320kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_Reserve[]: 0 0 0 0
DMA: 1*4kB 2*8kB 2*16kB 1*32kB 2*64kB 1*128kB 2*256kB 2*512kB 1*1024kB 1*2048kB 1*4096kB = 9044kB
Normal: 572*4kB 129*8kB 33*16kB 42*32kB 33*64kB 15*128kB 8*256kB 3*512kB 6*1024kB 3*2048kB 20*4096kB = 107016kB
HighMem: 407*4kB 199*8kB 124*16kB 107*32kB 53*64kB 10*128kB 5*256kB 4*512kB 3*1024kB 2*2048kB 4*4096kB = 40180kB
410530 total pagecahce pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 4883724kB
Total swap = 4883724kB
524268 pages RAM
296958 pages HighMem
5331 pages reserved
390516 pages shared	FLUCTUATES: 390508, 468, 412, 492, 484, 428, 524, 452, 468, ...
366021 pages non-shared

As mentioned, the "shared" number fluctuates, and the "Normal" free pages
count also fluctuates a little bit, but less.  (The 32kB free count is
sometimes 43 or 41 rather than 42, bringing the total to 107048 or 106984.)

I do see that the free space figures appear to agree.  I couldn't find a
number that appeared to change in sync with the "pages shared" figure.

I could remove Dave Hansen's patch and test again, if that would
help.

Any other ideas?

Thank you very much for the assistance!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
