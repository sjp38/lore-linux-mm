Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id A02B66B0031
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 22:20:35 -0400 (EDT)
Received: by mail-qa0-f51.google.com with SMTP id j7so4657484qaq.24
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 19:20:35 -0700 (PDT)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.230])
        by mx.google.com with ESMTP id o36si7295568qgo.11.2014.06.27.19.20.34
        for <linux-mm@kvack.org>;
        Fri, 27 Jun 2014 19:20:34 -0700 (PDT)
Message-ID: <53AE2672.9060902@ubuntu.com>
Date: Fri, 27 Jun 2014 22:20:34 -0400
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: alloc_pages_slowpath failing for no apparent reason
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

While playing minecraft after my system has been running for some time,
I get memory allocation failures for no apparent reason.  It appears
that the radeon driver is trying to allocate an order 4 page, with GFP
flags of WAIT | IO | FS | COMP | ZERO | KMEMCG, and this fails despite
there being plenty of 64k pages in the buddy list for both ZONE_DMA32 and
ZONE_NORMAL.  What could possibly cause this?  Here is the log:

[106595.211623] [drm:radeon_cs_ioctl] *ERROR* Failed to parse relocation -12!
[106595.212779] warn_alloc_failed: 83 callbacks suppressed
[106595.212781] java: page allocation failure: order:4, mode:0x10c0d0
[106595.212784] CPU: 2 PID: 22245 Comm: java Not tainted 3.13.0-29-generic #53-Ubuntu
[106595.212785] Hardware name: System manufacturer System Product Name/P8P67 PRO REV 3.1, BIOS 1904 0
8/15/2011
[106595.212786]  0000000000000000 ffff8801253dd938 ffffffff8171a214 000000000010c0d0
[106595.212788]  ffff8801253dd9c0 ffffffff81153bab ffff88012f7f8e38 ffff8801253dd960
[106595.212790]  ffffffff81156696 ffff8801253dd990 0000000000000286 0000000000000003
[106595.212792] Call Trace:
[106595.212798]  [<ffffffff8171a214>] dump_stack+0x45/0x56
[106595.212800]  [<ffffffff81153bab>] warn_alloc_failed+0xeb/0x140
[106595.212802]  [<ffffffff81156696>] ? drain_local_pages+0x16/0x20
[106595.212804]  [<ffffffff81158352>] __alloc_pages_nodemask+0x972/0xb80
[106595.212807]  [<ffffffff811964e3>] alloc_pages_current+0xa3/0x160
[106595.212809]  [<ffffffff81152c7e>] __get_free_pages+0xe/0x50
[106595.212812]  [<ffffffff8116f6ee>] kmalloc_order_trace+0x2e/0xa0
[106595.212814]  [<ffffffff811a1661>] __kmalloc+0x211/0x230
[106595.212835]  [<ffffffffa0458c2d>] ? radeon_cs_ioctl+0x1dd/0x9e0 [radeon]
[106595.212847]  [<ffffffffa0458c55>] radeon_cs_ioctl+0x205/0x9e0 [radeon]
[106595.212849]  [<ffffffff8101b7c9>] ? sched_clock+0x9/0x10
[106595.212851]  [<ffffffff8109d2e5>] ? sched_clock_cpu+0xb5/0x100
[106595.212859]  [<ffffffffa026dc22>] drm_ioctl+0x502/0x630 [drm]
[106595.212863]  [<ffffffff810d9459>] ? futex_wake+0x1a9/0x1d0
[106595.212869]  [<ffffffffa040c0fe>] radeon_drm_ioctl+0x4e/0x90 [radeon]
[106595.212872]  [<ffffffff811cf9c0>] do_vfs_ioctl+0x2e0/0x4c0
[106595.212874]  [<ffffffff8109dd94>] ? vtime_account_user+0x54/0x60
[106595.212876]  [<ffffffff811cfc21>] SyS_ioctl+0x81/0xa0
[106595.212879]  [<ffffffff8172adff>] tracesys+0xe1/0xe6
[106595.212880] Mem-Info:
[106595.212881] Node 0 DMA per-cpu:
[106595.212882] CPU    0: hi:    0, btch:   1 usd:   0
[106595.212883] CPU    1: hi:    0, btch:   1 usd:   0
[106595.212884] CPU    2: hi:    0, btch:   1 usd:   0
[106595.212885] CPU    3: hi:    0, btch:   1 usd:   0
[106595.212886] Node 0 DMA32 per-cpu:
[106595.212887] CPU    0: hi:  186, btch:  31 usd:   0
[106595.212888] CPU    1: hi:  186, btch:  31 usd:   0
[106595.212889] CPU    2: hi:  186, btch:  31 usd:   0
[106595.212890] CPU    3: hi:  186, btch:  31 usd:   0
[106595.212891] Node 0 Normal per-cpu:
[106595.212892] CPU    0: hi:  186, btch:  31 usd:   0
[106595.212893] CPU    1: hi:  186, btch:  31 usd:   0
[106595.212894] CPU    2: hi:  186, btch:  31 usd:   0
[106595.212895] CPU    3: hi:  186, btch:  31 usd:   0
[106595.212897] active_anon:373732 inactive_anon:168207 isolated_anon:0
[106595.212897]  active_file:87894 inactive_file:202511 isolated_file:0
[106595.212897]  unevictable:4 dirty:137 writeback:0 unstable:0
[106595.212897]  free:40691 slab_reclaimable:37781 slab_unreclaimable:14708
[106595.212897]  mapped:28022 shmem:6233 pagetables:7960 bounce:0
[106595.212897]  free_cma:0
[106595.212899] Node 0 DMA free:15900kB min:264kB low:328kB high:396kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[106595.212903] lowmem_reserve[]: 0 3217 3912 3912
[106595.212905] Node 0 DMA32 free:121552kB min:55360kB low:69200kB high:83040kB active_anon:1286900kB inactive_anon:443620kB active_file:308180kB inactive_file:766640kB unevictable:16kB isolated(anon):0kB isolated(file):0kB present:3376348kB managed:3297396kB mlocked:16kB dirty:104kB writeback:0kB mapped:106112kB shmem:24028kB slab_reclaimable:122824kB slab_unreclaimable:37524kB kernel_stack:2656kB pagetables:24660kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[106595.212908] lowmem_reserve[]: 0 0 694 694
[106595.212910] Node 0 Normal free:25312kB min:11952kB low:14940kB high:17928kB active_anon:208028kB inactive_anon:229208kB active_file:43396kB inactive_file:43404kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:778240kB managed:711468kB mlocked:0kB dirty:444kB writeback:0kB mapped:5976kB shmem:904kB slab_reclaimable:28300kB slab_unreclaimable:21308kB kernel_stack:1176kB pagetables:7180kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[106595.212913] lowmem_reserve[]: 0 0 0 0
[106595.212915] Node 0 DMA: 1*4kB (U) 1*8kB (U) 1*16kB (U) 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15900kB
[106595.212948] Node 0 DMA32: 17854*4kB (UEMR) 2829*8kB (UEM) 1547*16kB (UEM) 58*32kB (UEM) 15*64kB (UE) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 121616kB
[106595.212954] Node 0 Normal: 652*4kB (UEMR) 1455*8kB (UEM) 377*16kB (UEM) 163*32kB (UEM) 14*64kB (UM) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 26392kB
[106595.212961] Node 0 hugepages_total=1 hugepages_free=1 hugepages_surp=1 hugepages_size=2048kB
[106595.212962] 312090 total pagecache pages
[106595.212963] 15451 pages in swap cache
[106595.212965] Swap cache stats: add 833481, delete 818030, find 381508/435184
[106595.212965] Free swap  = 1584484kB
[106595.212966] Total swap = 2097148kB
[106595.212967] 1042643 pages RAM
[106595.212968] 0 pages HighMem/MovableOnly
[106595.212968] 16693 pages reserved

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBCgAGBQJTriZyAAoJEI5FoCIzSKrwsbIH/RDPYPZN9EGVnJVzCuehn1YK
XqJtEivJ+z/gd/zqOnBlgDXrIJHg9yklfD0/tFMmzcInQFwpQ5A8gVko9GvaiByS
WLdeUEtTLHOmbKArwrJPpjq/qUaQTdoUQ175sjdqffpugQMX/SY0MjgJ4KjiqgRS
1j0/jaLxXa6R2+6GtwYFJiBU5UX8q21/Id5pKKFP5NGIXl0NOfsB1GzRMw2j7uqZ
pVhn95p8OmoH5Kuya0uwcmnkFQP4O5M1goiQuHd8HkpGaCa0A1ErCA5df6hUxsKn
ChhIfjYwb2BnneUsAHBfnhUg/NPieuLANZs9wKkO3Z6PILJIGKB5s2m4TqN1J0o=
=AT+k
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
