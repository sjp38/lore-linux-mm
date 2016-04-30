Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C9C736B007E
	for <linux-mm@kvack.org>; Sat, 30 Apr 2016 15:24:07 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r12so47603265wme.0
        for <linux-mm@kvack.org>; Sat, 30 Apr 2016 12:24:07 -0700 (PDT)
Received: from emh06.mail.saunalahti.fi (emh06.mail.saunalahti.fi. [62.142.5.116])
        by mx.google.com with ESMTPS id qy3si11970783lbb.40.2016.04.30.12.24.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 30 Apr 2016 12:24:04 -0700 (PDT)
Date: Sat, 30 Apr 2016 22:24:03 +0300
From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: __napi_alloc_skb failures locking up the box
Message-ID: <20160430192402.GA8366@raspberrypi.musicnaut.iki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Hi,

I have old NAS box (Thecus N2100) with 512 MB RAM, where rsync from NFS ->
disk reliably results in temporary out-of-memory conditions.

When this happens the dmesg gets flooded with below logs. If the serial
console logging is enabled, this will lock up the box completely and
the backup is not making any progress.

Shouldn't these allocation failures be ratelimited somehow (or even made
silent)? It doesn't sound right if I can lock up the system simply by
copying files...

...

[ 1706.105842] kworker/0:1H: page allocation failure: order:0, mode:0x2200020(GFP_NOWAIT|__GFP_HIGH|__GFP_NOTRACK)
[ 1706.105904] CPU: 0 PID: 519 Comm: kworker/0:1H Not tainted 4.6.0-rc5-iop32x-los_a50bb #1
[ 1706.105917] Hardware name: Thecus N2100
[ 1706.105973] Workqueue: rpciod rpc_async_schedule
[ 1706.105993] Backtrace: 
[ 1706.106037] [<c000d460>] (dump_backtrace) from [<c000d658>] (show_stack+0x18/0x1c)
[ 1706.106068]  r7:00000000 r6:00000060 r5:00000000 r4:00000000
[ 1706.106142] [<c000d640>] (show_stack) from [<c01c1e84>] (dump_stack+0x20/0x28)
[ 1706.106185] [<c01c1e64>] (dump_stack) from [<c007b9b0>] (warn_alloc_failed+0xf0/0x134)
[ 1706.106216] [<c007b8c4>] (warn_alloc_failed) from [<c007df78>] (__alloc_pages_nodemask+0x284/0x8fc)
[ 1706.106233]  r3:02200020 r2:00000000
[ 1706.106269]  r5:00000000 r4:c0524c40
[ 1706.106336] [<c007dcf4>] (__alloc_pages_nodemask) from [<c00b1948>] (new_slab+0x3c4/0x430)
[ 1706.106352]  r10:00000000 r9:c0321fdc r8:00000000 r7:df401d00 r6:00000015 r5:02000020
[ 1706.106422]  r4:df401d00
[ 1706.106460] [<c00b1584>] (new_slab) from [<c00b2bd8>] (___slab_alloc.constprop.8+0x238/0x298)
[ 1706.106477]  r10:00000000 r9:c0321fdc r8:02080020 r7:df401d00 r6:dfbef060 r5:00000000
[ 1706.106547]  r4:00000000
[ 1706.106581] [<c00b29a0>] (___slab_alloc.constprop.8) from [<c00b2f68>] (kmem_cache_alloc+0xbc/0xf8)
[ 1706.106597]  r10:00167e93 r9:340285ee r8:e11e1920 r7:60000013 r6:02080020 r5:df401d00
[ 1706.106668]  r4:00000000
[ 1706.106707] [<c00b2eac>] (kmem_cache_alloc) from [<c0321fdc>] (__build_skb+0x2c/0x98)
[ 1706.106723]  r7:cc592240 r6:000006e0 r5:de3523f0 r4:000006e0
[ 1706.106784] [<c0321fb0>] (__build_skb) from [<c032226c>] (__napi_alloc_skb+0xb0/0xfc)
[ 1706.106801]  r9:340285ee r8:e11e1920 r7:cc592240 r6:c0520ab8 r5:de3523f0 r4:000006e0
[ 1706.106903] [<c03221bc>] (__napi_alloc_skb) from [<c028a2fc>] (rtl8169_poll+0x3a0/0x588)
[ 1706.106920]  r7:de364000 r6:c000fd08 r5:000005ea r4:de3523f0
[ 1706.106986] [<c0289f5c>] (rtl8169_poll) from [<c032d098>] (net_rx_action+0x1cc/0x2ec)
[ 1706.107002]  r10:00022548 r9:df471ba8 r8:c05257e0 r7:0000012c r6:00000040 r5:00000001
[ 1706.107073]  r4:de3523f0
[ 1706.107131] [<c032cecc>] (net_rx_action) from [<c001bd68>] (__do_softirq+0xf4/0x254)
[ 1706.107147]  r10:00000101 r9:c052618c r8:40000001 r7:c0526188 r6:df470000 r5:00000003
[ 1706.107218]  r4:00000000
[ 1706.107255] [<c001bc74>] (__do_softirq) from [<c001bf58>] (do_softirq.part.2+0x34/0x40)
[ 1706.107271]  r10:00000001 r9:c0525a26 r8:c05555c0 r7:00000000 r6:deae8a80 r5:00000000
[ 1706.107341]  r4:20000013
[ 1706.107380] [<c001bf24>] (do_softirq.part.2) from [<c001c010>] (__local_bh_enable_ip+0xac/0xcc)
[ 1706.107396]  r5:00000000 r4:00000200
[ 1706.107459] [<c001bf64>] (__local_bh_enable_ip) from [<c0319538>] (release_sock+0x12c/0x158)
[ 1706.107477]  r5:00000000 r4:00000000
[ 1706.107538] [<c031940c>] (release_sock) from [<c03671b4>] (tcp_sendmsg+0xf8/0xa90)
[ 1706.107557]  r10:00004040 r9:deae8a80 r8:df471d74 r7:88cd7146 r6:0000059c r5:de8ccb00
[ 1706.107629]  r4:0000007c r3:00000001
[ 1706.107678] [<c03670bc>] (tcp_sendmsg) from [<c038d7f0>] (inet_sendmsg+0x3c/0x74)
[ 1706.107695]  r10:df471e2c r9:00000000 r8:df7eb604 r7:00000000 r6:00000000 r5:df02c780
[ 1706.107766]  r4:deae8a80
[ 1706.107800] [<c038d7b4>] (inet_sendmsg) from [<c03157f0>] (sock_sendmsg+0x1c/0x30)
[ 1706.107816]  r4:df471d74
[ 1706.107849] [<c03157d4>] (sock_sendmsg) from [<c03158f4>] (kernel_sendmsg+0x38/0x40)
[ 1706.107873] [<c03158bc>] (kernel_sendmsg) from [<c03afa2c>] (xs_send_kvec+0x94/0x9c)
[ 1706.107891]  r5:00000000 r4:df02c780
[ 1706.107934] [<c03af998>] (xs_send_kvec) from [<c03afaa0>] (xs_sendpages+0x6c/0x244)
[ 1706.107950]  r9:00000000 r8:df02c780 r7:0000007c r6:df7eb604 r5:00000001 r4:00000000
[ 1706.108026] [<c03afa34>] (xs_sendpages) from [<c03afd7c>] (xs_tcp_send_request+0x80/0x134)
[ 1706.108043]  r10:00000000 r9:00000000 r8:de8e8000 r7:de0d7258 r6:df7eb604 r5:00000001
[ 1706.108114]  r4:df7eb600
[ 1706.108172] [<c03afcfc>] (xs_tcp_send_request) from [<c03ad670>] (xprt_transmit+0x58/0x214)
[ 1706.108192]  r10:de92cc60 r9:00000000 r8:d3697fdd r7:df7eb674 r6:de0d7258 r5:df7eb600
[ 1706.108265]  r4:de8e8000
[ 1706.108303] [<c03ad618>] (xprt_transmit) from [<c03aac74>] (call_transmit+0x18c/0x230)
[ 1706.108321]  r7:df7eb600 r6:00000001 r5:df7eb600 r4:de0d7258
[ 1706.108388] [<c03aaae8>] (call_transmit) from [<c03b1ed8>] (__rpc_execute+0x54/0x2c4)
[ 1706.108404]  r8:c0508940 r7:00000000 r6:c03b1f08 r5:00000001 r4:de0d7258
[ 1706.108475] [<c03b1e84>] (__rpc_execute) from [<c03b215c>] (rpc_async_schedule+0x14/0x18)
[ 1706.108493]  r7:00000000 r6:dfbf0800 r5:de92cc60 r4:de0d727c
[ 1706.108564] [<c03b2148>] (rpc_async_schedule) from [<c002c79c>] (process_one_work+0x130/0x3ec)
[ 1706.108587] [<c002c66c>] (process_one_work) from [<c002caa8>] (worker_thread+0x50/0x5ac)
[ 1706.108604]  r10:de92cc60 r9:c0508940 r8:00000008 r7:c050b220 r6:c0508954 r5:de92cc78
[ 1706.108675]  r4:c0508940
[ 1706.108718] [<c002ca58>] (worker_thread) from [<c00319cc>] (kthread+0xc8/0xe4)
[ 1706.108734]  r10:00000000 r9:00000000 r8:00000000 r7:c002ca58 r6:de92cc60 r5:00000000
[ 1706.108804]  r4:de385880
[ 1706.108844] [<c0031904>] (kthread) from [<c000a390>] (ret_from_fork+0x14/0x24)
[ 1706.108861]  r7:00000000 r6:00000000 r5:c0031904 r4:de385880
[ 1706.108909] Mem-Info:
[ 1706.108950] active_anon:2694 inactive_anon:2799 isolated_anon:0
[ 1706.108950]  active_file:43728 inactive_file:71243 isolated_file:0
[ 1706.108950]  unevictable:0 dirty:1486 writeback:0 unstable:0
[ 1706.108950]  slab_reclaimable:3099 slab_unreclaimable:710
[ 1706.108950]  mapped:1763 shmem:19 pagetables:186 bounce:0
[ 1706.108950]  free:290 free_pcp:56 free_cma:0
[ 1706.109041] Normal free:1160kB min:2868kB low:3584kB high:4300kB active_anon:10776kB inactive_anon:11196kB active_file:174912kB inactive_file:284972kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:524288kB managed:514412kB mlocked:0kB dirty:5944kB writeback:0kB mapped:7052kB shmem:76kB slab_reclaimable:12396kB slab_unreclaimable:2840kB kernel_stack:584kB pagetables:744kB unstable:0kB bounce:0kB free_pcp:224kB local_pcp:224kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 1706.109059] lowmem_reserve[]: 0 0
[ 1706.109075] Normal: 80*4kB (UME) 105*8kB (UE) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1160kB
[ 1706.109137] 114997 total pagecache pages
[ 1706.109154] 0 pages in swap cache
[ 1706.109168] Swap cache stats: add 0, delete 0, find 0/0
[ 1706.109179] Free swap  = 1048572kB
[ 1706.109189] Total swap = 1048572kB
[ 1706.109199] 131072 pages RAM
[ 1706.109208] 0 pages HighMem/MovableOnly
[ 1706.109218] 2469 pages reserved
[ 1706.109238] SLUB: Unable to allocate memory on node -1, gfp=0x2080020(GFP_ATOMIC)
[ 1706.109255]   cache: kmalloc-192, object size: 192, buffer size: 192, default order: 0, min order: 0
[ 1706.109272]   node 0: slabs: 12, objs: 252, free: 0
[ 1706.109320] kworker/0:1H: page allocation failure: order:0, mode:0x2200020(GFP_NOWAIT|__GFP_HIGH|__GFP_NOTRACK)
[ 1706.109341] CPU: 0 PID: 519 Comm: kworker/0:1H Not tainted 4.6.0-rc5-iop32x-los_a50bb #1
[ 1706.109354] Hardware name: Thecus N2100
[ 1706.109371] Workqueue: rpciod rpc_async_schedule
[ 1706.109381] Backtrace: 
[ 1706.109412] [<c000d460>] (dump_backtrace) from [<c000d658>] (show_stack+0x18/0x1c)
[ 1706.109429]  r7:00000000 r6:00000060 r5:00000000 r4:00000000
[ 1706.109500] [<c000d640>] (show_stack) from [<c01c1e84>] (dump_stack+0x20/0x28)
[ 1706.109547] [<c01c1e64>] (dump_stack) from [<c007b9b0>] (warn_alloc_failed+0xf0/0x134)
[ 1706.109578] [<c007b8c4>] (warn_alloc_failed) from [<c007df78>] (__alloc_pages_nodemask+0x284/0x8fc)
[ 1706.109595]  r3:02200020 r2:00000000
[ 1706.109631]  r5:00000000 r4:c0524c40
[ 1706.109696] [<c007dcf4>] (__alloc_pages_nodemask) from [<c00b1948>] (new_slab+0x3c4/0x430)
[ 1706.109715]  r10:00000000 r9:c0321fdc r8:00000000 r7:df401d00 r6:00000015 r5:02000020
[ 1706.109786]  r4:df401d00
[ 1706.109823] [<c00b1584>] (new_slab) from [<c00b2bd8>] (___slab_alloc.constprop.8+0x238/0x298)
[ 1706.109839]  r10:00000000 r9:c0321fdc r8:02080020 r7:df401d00 r6:dfbef060 r5:00000000
[ 1706.109909]  r4:00000000
[ 1706.109943] [<c00b29a0>] (___slab_alloc.constprop.8) from [<c00b2f68>] (kmem_cache_alloc+0xbc/0xf8)
[ 1706.109959]  r10:00167e94 r9:340285ee r8:e11e1930 r7:60000013 r6:02080020 r5:df401d00
[ 1706.110030]  r4:00000000
[ 1706.110069] [<c00b2eac>] (kmem_cache_alloc) from [<c0321fdc>] (__build_skb+0x2c/0x98)
[ 1706.110086]  r7:cc593920 r6:000006e0 r5:de3523f0 r4:000006e0
[ 1706.110147] [<c0321fb0>] (__build_skb) from [<c032226c>] (__napi_alloc_skb+0xb0/0xfc)
[ 1706.110163]  r9:340285ee r8:e11e1930 r7:cc593920 r6:c0520ab8 r5:de3523f0 r4:000006e0
[ 1706.110267] [<c03221bc>] (__napi_alloc_skb) from [<c028a2fc>] (rtl8169_poll+0x3a0/0x588)
[ 1706.110286]  r7:de368000 r6:c000fd08 r5:000005ea r4:de3523f0
[ 1706.110352] [<c0289f5c>] (rtl8169_poll) from [<c032d098>] (net_rx_action+0x1cc/0x2ec)
[ 1706.110369]  r10:00022548 r9:df471ba8 r8:c05257e0 r7:0000012c r6:00000040 r5:00000001
[ 1706.110438]  r4:de3523f0
[ 1706.110499] [<c032cecc>] (net_rx_action) from [<c001bd68>] (__do_softirq+0xf4/0x254)
[ 1706.110518]  r10:00000101 r9:c052618c r8:40000001 r7:c0526188 r6:df470000 r5:00000003
[ 1706.110589]  r4:00000000
[ 1706.110628] [<c001bc74>] (__do_softirq) from [<c001bf58>] (do_softirq.part.2+0x34/0x40)
[ 1706.110644]  r10:00000001 r9:c0525a26 r8:c05555c0 r7:00000000 r6:deae8a80 r5:00000000
[ 1706.110714]  r4:20000013
[ 1706.110754] [<c001bf24>] (do_softirq.part.2) from [<c001c010>] (__local_bh_enable_ip+0xac/0xcc)
[ 1706.110770]  r5:00000000 r4:00000200
[ 1706.110833] [<c001bf64>] (__local_bh_enable_ip) from [<c0319538>] (release_sock+0x12c/0x158)
[ 1706.110849]  r5:00000000 r4:00000000
[ 1706.110906] [<c031940c>] (release_sock) from [<c03671b4>] (tcp_sendmsg+0xf8/0xa90)
[ 1706.110922]  r10:00004040 r9:deae8a80 r8:df471d74 r7:88cd7146 r6:0000059c r5:de8ccb00
[ 1706.110993]  r4:0000007c r3:00000001
[ 1706.111040] [<c03670bc>] (tcp_sendmsg) from [<c038d7f0>] (inet_sendmsg+0x3c/0x74)
[ 1706.111058]  r10:df471e2c r9:00000000 r8:df7eb604 r7:00000000 r6:00000000 r5:df02c780
[ 1706.111127]  r4:deae8a80
[ 1706.111161] [<c038d7b4>] (inet_sendmsg) from [<c03157f0>] (sock_sendmsg+0x1c/0x30)
[ 1706.111177]  r4:df471d74
[ 1706.111210] [<c03157d4>] (sock_sendmsg) from [<c03158f4>] (kernel_sendmsg+0x38/0x40)
[ 1706.111236] [<c03158bc>] (kernel_sendmsg) from [<c03afa2c>] (xs_send_kvec+0x94/0x9c)
[ 1706.111253]  r5:00000000 r4:df02c780
[ 1706.111295] [<c03af998>] (xs_send_kvec) from [<c03afaa0>] (xs_sendpages+0x6c/0x244)
[ 1706.111311]  r9:00000000 r8:df02c780 r7:0000007c r6:df7eb604 r5:00000001 r4:00000000
[ 1706.111387] [<c03afa34>] (xs_sendpages) from [<c03afd7c>] (xs_tcp_send_request+0x80/0x134)
[ 1706.111403]  r10:00000000 r9:00000000 r8:de8e8000 r7:de0d7258 r6:df7eb604 r5:00000001
[ 1706.111473]  r4:df7eb600
[ 1706.111527] [<c03afcfc>] (xs_tcp_send_request) from [<c03ad670>] (xprt_transmit+0x58/0x214)
[ 1706.111549]  r10:de92cc60 r9:00000000 r8:d3697fdd r7:df7eb674 r6:de0d7258 r5:df7eb600
[ 1706.111619]  r4:de8e8000
[ 1706.111656] [<c03ad618>] (xprt_transmit) from [<c03aac74>] (call_transmit+0x18c/0x230)
[ 1706.111672]  r7:df7eb600 r6:00000001 r5:df7eb600 r4:de0d7258
[ 1706.111740] [<c03aaae8>] (call_transmit) from [<c03b1ed8>] (__rpc_execute+0x54/0x2c4)
[ 1706.111757]  r8:c0508940 r7:00000000 r6:c03b1f08 r5:00000001 r4:de0d7258
[ 1706.111828] [<c03b1e84>] (__rpc_execute) from [<c03b215c>] (rpc_async_schedule+0x14/0x18)
[ 1706.111844]  r7:00000000 r6:dfbf0800 r5:de92cc60 r4:de0d727c
[ 1706.111912] [<c03b2148>] (rpc_async_schedule) from [<c002c79c>] (process_one_work+0x130/0x3ec)
[ 1706.111936] [<c002c66c>] (process_one_work) from [<c002caa8>] (worker_thread+0x50/0x5ac)
[ 1706.111953]  r10:de92cc60 r9:c0508940 r8:00000008 r7:c050b220 r6:c0508954 r5:de92cc78
[ 1706.112023]  r4:c0508940
[ 1706.112069] [<c002ca58>] (worker_thread) from [<c00319cc>] (kthread+0xc8/0xe4)
[ 1706.112087]  r10:00000000 r9:00000000 r8:00000000 r7:c002ca58 r6:de92cc60 r5:00000000
[ 1706.112157]  r4:de385880
[ 1706.112196] [<c0031904>] (kthread) from [<c000a390>] (ret_from_fork+0x14/0x24)
[ 1706.112212]  r7:00000000 r6:00000000 r5:c0031904 r4:de385880
[ 1706.112261] Mem-Info:
[ 1706.112299] active_anon:2694 inactive_anon:2799 isolated_anon:0
[ 1706.112299]  active_file:43728 inactive_file:71243 isolated_file:0
[ 1706.112299]  unevictable:0 dirty:1486 writeback:0 unstable:0
[ 1706.112299]  slab_reclaimable:3099 slab_unreclaimable:710
[ 1706.112299]  mapped:1763 shmem:19 pagetables:186 bounce:0
[ 1706.112299]  free:290 free_pcp:55 free_cma:0
[ 1706.112387] Normal free:1160kB min:2868kB low:3584kB high:4300kB active_anon:10776kB inactive_anon:11196kB active_file:174912kB inactive_file:284972kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:524288kB managed:514412kB mlocked:0kB dirty:5944kB writeback:0kB mapped:7052kB shmem:76kB slab_reclaimable:12396kB slab_unreclaimable:2840kB kernel_stack:584kB pagetables:744kB unstable:0kB bounce:0kB free_pcp:220kB local_pcp:220kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 1706.112406] lowmem_reserve[]: 0 0
[ 1706.112420] Normal: 80*4kB (UME) 105*8kB (UE) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1160kB
[ 1706.112481] 114997 total pagecache pages
[ 1706.112499] 0 pages in swap cache
[ 1706.112512] Swap cache stats: add 0, delete 0, find 0/0
[ 1706.112522] Free swap  = 1048572kB
[ 1706.112532] Total swap = 1048572kB
[ 1706.112543] 131072 pages RAM
[ 1706.112552] 0 pages HighMem/MovableOnly
[ 1706.112561] 2469 pages reserved
[ 1706.112582] SLUB: Unable to allocate memory on node -1, gfp=0x2080020(GFP_ATOMIC)
[ 1706.112601]   cache: kmalloc-192, object size: 192, buffer size: 192, default order: 0, min order: 0
[ 1706.112617]   node 0: slabs: 12, objs: 252, free: 0
[ 1706.112656] kworker/0:1H: page allocation failure: order:0, mode:0x2200020(GFP_NOWAIT|__GFP_HIGH|__GFP_NOTRACK)
[ 1706.112677] CPU: 0 PID: 519 Comm: kworker/0:1H Not tainted 4.6.0-rc5-iop32x-los_a50bb #1
[ 1706.112689] Hardware name: Thecus N2100
[ 1706.112707] Workqueue: rpciod rpc_async_schedule
[ 1706.112717] Backtrace: 
[ 1706.112750] [<c000d460>] (dump_backtrace) from [<c000d658>] (show_stack+0x18/0x1c)
[ 1706.112769]  r7:00000000 r6:00000060 r5:00000000 r4:00000000
[ 1706.112843] [<c000d640>] (show_stack) from [<c01c1e84>] (dump_stack+0x20/0x28)
[ 1706.112884] [<c01c1e64>] (dump_stack) from [<c007b9b0>] (warn_alloc_failed+0xf0/0x134)
[ 1706.112914] [<c007b8c4>] (warn_alloc_failed) from [<c007df78>] (__alloc_pages_nodemask+0x284/0x8fc)
[ 1706.112932]  r3:02200020 r2:00000000
[ 1706.112967]  r5:00000000 r4:c0524c40
[ 1706.113034] [<c007dcf4>] (__alloc_pages_nodemask) from [<c00b1948>] (new_slab+0x3c4/0x430)
[ 1706.113052]  r10:00000000 r9:c0321fdc r8:00000000 r7:df401d00 r6:00000015 r5:02000020
[ 1706.113122]  r4:df401d00
[ 1706.113160] [<c00b1584>] (new_slab) from [<c00b2bd8>] (___slab_alloc.constprop.8+0x238/0x298)
[ 1706.113176]  r10:00000000 r9:c0321fdc r8:02080020 r7:df401d00 r6:dfbef060 r5:00000000
[ 1706.113246]  r4:00000000
[ 1706.113279] [<c00b29a0>] (___slab_alloc.constprop.8) from [<c00b2f68>] (kmem_cache_alloc+0xbc/0xf8)
[ 1706.113297]  r10:00167e95 r9:340285ee r8:e11e1940 r7:60000013 r6:02080020 r5:df401d00
[ 1706.113367]  r4:00000000
[ 1706.113407] [<c00b2eac>] (kmem_cache_alloc) from [<c0321fdc>] (__build_skb+0x2c/0x98)
[ 1706.113425]  r7:cc593240 r6:000006e0 r5:de3523f0 r4:000006e0
[ 1706.113485] [<c0321fb0>] (__build_skb) from [<c032226c>] (__napi_alloc_skb+0xb0/0xfc)
[ 1706.113502]  r9:340285ee r8:e11e1940 r7:cc593240 r6:c0520ab8 r5:de3523f0 r4:000006e0
[ 1706.113603] [<c03221bc>] (__napi_alloc_skb) from [<c028a2fc>] (rtl8169_poll+0x3a0/0x588)
[ 1706.113623]  r7:de36c000 r6:c000fd08 r5:000005ea r4:de3523f0
[ 1706.113689] [<c0289f5c>] (rtl8169_poll) from [<c032d098>] (net_rx_action+0x1cc/0x2ec)
[ 1706.113706]  r10:00022548 r9:df471ba8 r8:c05257e0 r7:0000012c r6:00000040 r5:00000001
[ 1706.113776]  r4:de3523f0
[ 1706.113832] [<c032cecc>] (net_rx_action) from [<c001bd68>] (__do_softirq+0xf4/0x254)
[ 1706.113849]  r10:00000101 r9:c052618c r8:40000001 r7:c0526188 r6:df470000 r5:00000003
[ 1706.113920]  r4:00000000
[ 1706.113957] [<c001bc74>] (__do_softirq) from [<c001bf58>] (do_softirq.part.2+0x34/0x40)
[ 1706.113974]  r10:00000001 r9:c0525a26 r8:c05555c0 r7:00000000 r6:deae8a80 r5:00000000
[ 1706.114044]  r4:20000013
[ 1706.114083] [<c001bf24>] (do_softirq.part.2) from [<c001c010>] (__local_bh_enable_ip+0xac/0xcc)
[ 1706.114100]  r5:00000000 r4:00000200
[ 1706.114160] [<c001bf64>] (__local_bh_enable_ip) from [<c0319538>] (release_sock+0x12c/0x158)
[ 1706.114176]  r5:00000000 r4:00000000
[ 1706.114236] [<c031940c>] (release_sock) from [<c03671b4>] (tcp_sendmsg+0xf8/0xa90)
[ 1706.114255]  r10:00004040 r9:deae8a80 r8:df471d74 r7:88cd7146 r6:0000059c r5:de8ccb00
[ 1706.114325]  r4:0000007c r3:00000001
[ 1706.114371] [<c03670bc>] (tcp_sendmsg) from [<c038d7f0>] (inet_sendmsg+0x3c/0x74)
[ 1706.114389]  r10:df471e2c r9:00000000 r8:df7eb604 r7:00000000 r6:00000000 r5:df02c780
[ 1706.114460]  r4:deae8a80
[ 1706.114493] [<c038d7b4>] (inet_sendmsg) from [<c03157f0>] (sock_sendmsg+0x1c/0x30)
[ 1706.114510]  r4:df471d74
[ 1706.114544] [<c03157d4>] (sock_sendmsg) from [<c03158f4>] (kernel_sendmsg+0x38/0x40)
[ 1706.114569] [<c03158bc>] (kernel_sendmsg) from [<c03afa2c>] (xs_send_kvec+0x94/0x9c)
[ 1706.114585]  r5:00000000 r4:df02c780
[ 1706.114626] [<c03af998>] (xs_send_kvec) from [<c03afaa0>] (xs_sendpages+0x6c/0x244)
[ 1706.114642]  r9:00000000 r8:df02c780 r7:0000007c r6:df7eb604 r5:00000001 r4:00000000
[ 1706.114718] [<c03afa34>] (xs_sendpages) from [<c03afd7c>] (xs_tcp_send_request+0x80/0x134)
[ 1706.114734]  r10:00000000 r9:00000000 r8:de8e8000 r7:de0d7258 r6:df7eb604 r5:00000001
[ 1706.114805]  r4:df7eb600
[ 1706.114860] [<c03afcfc>] (xs_tcp_send_request) from [<c03ad670>] (xprt_transmit+0x58/0x214)
[ 1706.114880]  r10:de92cc60 r9:00000000 r8:d3697fdd r7:df7eb674 r6:de0d7258 r5:df7eb600
[ 1706.114951]  r4:de8e8000
[ 1706.114990] [<c03ad618>] (xprt_transmit) from [<c03aac74>] (call_transmit+0x18c/0x230)
[ 1706.115006]  r7:df7eb600 r6:00000001 r5:df7eb600 r4:de0d7258
[ 1706.115072] [<c03aaae8>] (call_transmit) from [<c03b1ed8>] (__rpc_execute+0x54/0x2c4)
[ 1706.115089]  r8:c0508940 r7:00000000 r6:c03b1f08 r5:00000001 r4:de0d7258
[ 1706.115160] [<c03b1e84>] (__rpc_execute) from [<c03b215c>] (rpc_async_schedule+0x14/0x18)
[ 1706.115176]  r7:00000000 r6:dfbf0800 r5:de92cc60 r4:de0d727c
[ 1706.115246] [<c03b2148>] (rpc_async_schedule) from [<c002c79c>] (process_one_work+0x130/0x3ec)
[ 1706.115271] [<c002c66c>] (process_one_work) from [<c002caa8>] (worker_thread+0x50/0x5ac)
[ 1706.115288]  r10:de92cc60 r9:c0508940 r8:00000008 r7:c050b220 r6:c0508954 r5:de92cc78
[ 1706.115359]  r4:c0508940
[ 1706.115404] [<c002ca58>] (worker_thread) from [<c00319cc>] (kthread+0xc8/0xe4)
[ 1706.115422]  r10:00000000 r9:00000000 r8:00000000 r7:c002ca58 r6:de92cc60 r5:00000000
[ 1706.115492]  r4:de385880
[ 1706.115532] [<c0031904>] (kthread) from [<c000a390>] (ret_from_fork+0x14/0x24)
[ 1706.115548]  r7:00000000 r6:00000000 r5:c0031904 r4:de385880
[ 1706.115596] Mem-Info:
[ 1706.115635] active_anon:2694 inactive_anon:2799 isolated_anon:0
[ 1706.115635]  active_file:43728 inactive_file:71243 isolated_file:0
[ 1706.115635]  unevictable:0 dirty:1486 writeback:0 unstable:0
[ 1706.115635]  slab_reclaimable:3099 slab_unreclaimable:710
[ 1706.115635]  mapped:1763 shmem:19 pagetables:186 bounce:0
[ 1706.115635]  free:290 free_pcp:55 free_cma:0
[ 1706.115725] Normal free:1160kB min:2868kB low:3584kB high:4300kB active_anon:10776kB inactive_anon:11196kB active_file:174912kB inactive_file:284972kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:524288kB managed:514412kB mlocked:0kB dirty:5944kB writeback:0kB mapped:7052kB shmem:76kB slab_reclaimable:12396kB slab_unreclaimable:2840kB kernel_stack:584kB pagetables:744kB unstable:0kB bounce:0kB free_pcp:220kB local_pcp:220kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 1706.115744] lowmem_reserve[]: 0 0
[ 1706.115758] Normal: 80*4kB (UME) 105*8kB (UE) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1160kB
[ 1706.115819] 114997 total pagecache pages
[ 1706.115836] 0 pages in swap cache
[ 1706.115849] Swap cache stats: add 0, delete 0, find 0/0
[ 1706.115859] Free swap  = 1048572kB
[ 1706.115869] Total swap = 1048572kB
[ 1706.115879] 131072 pages RAM
[ 1706.115888] 0 pages HighMem/MovableOnly
[ 1706.115898] 2469 pages reserved
[ 1706.115917] SLUB: Unable to allocate memory on node -1, gfp=0x2080020(GFP_ATOMIC)
[ 1706.115935]   cache: kmalloc-192, object size: 192, buffer size: 192, default order: 0, min order: 0
[ 1706.115950]   node 0: slabs: 12, objs: 252, free: 0
[ 1706.116178] kworker/0:1H: page allocation failure: order:0, mode:0x2200020(GFP_NOWAIT|__GFP_HIGH|__GFP_NOTRACK)
[ 1706.116220] CPU: 0 PID: 519 Comm: kworker/0:1H Not tainted 4.6.0-rc5-iop32x-los_a50bb #1
[ 1706.116234] Hardware name: Thecus N2100
[ 1706.116269] Workqueue: rpciod rpc_async_schedule
[ 1706.116285] Backtrace: 
[ 1706.116320] [<c000d460>] (dump_backtrace) from [<c000d658>] (show_stack+0x18/0x1c)
[ 1706.116348]  r7:00000000 r6:00000060 r5:00000000 r4:00000000
[ 1706.116422] [<c000d640>] (show_stack) from [<c01c1e84>] (dump_stack+0x20/0x28)
[ 1706.116462] [<c01c1e64>] (dump_stack) from [<c007b9b0>] (warn_alloc_failed+0xf0/0x134)
[ 1706.116494] [<c007b8c4>] (warn_alloc_failed) from [<c007df78>] (__alloc_pages_nodemask+0x284/0x8fc)
[ 1706.116512]  r3:02200020 r2:00000000
[ 1706.116547]  r5:00000000 r4:c0524c40
[ 1706.116611] [<c007dcf4>] (__alloc_pages_nodemask) from [<c00b1948>] (new_slab+0x3c4/0x430)
[ 1706.116630]  r10:00000000 r9:c0321fdc r8:00000000 r7:df401d00 r6:00000015 r5:02000020
[ 1706.116701]  r4:df401d00
[ 1706.116739] [<c00b1584>] (new_slab) from [<c00b2bd8>] (___slab_alloc.constprop.8+0x238/0x298)
[ 1706.116755]  r10:00000000 r9:c0321fdc r8:02080020 r7:df401d00 r6:dfbef060 r5:00000000
[ 1706.116825]  r4:00000000
[ 1706.116859] [<c00b29a0>] (___slab_alloc.constprop.8) from [<c00b2f68>] (kmem_cache_alloc+0xbc/0xf8)
[ 1706.116876]  r10:00167e96 r9:340285ee r8:e11e1950 r7:60000013 r6:02080020 r5:df401d00
[ 1706.116946]  r4:00000000
[ 1706.116986] [<c00b2eac>] (kmem_cache_alloc) from [<c0321fdc>] (__build_skb+0x2c/0x98)
[ 1706.117003]  r7:cc593920 r6:000006e0 r5:de3523f0 r4:000006e0
[ 1706.117063] [<c0321fb0>] (__build_skb) from [<c032226c>] (__napi_alloc_skb+0xb0/0xfc)
[ 1706.117079]  r9:340285ee r8:e11e1950 r7:cc593920 r6:c0520ab8 r5:de3523f0 r4:000006e0
[ 1706.117182] [<c03221bc>] (__napi_alloc_skb) from [<c028a2fc>] (rtl8169_poll+0x3a0/0x588)
[ 1706.117203]  r7:de370000 r6:c000fd08 r5:000005ea r4:de3523f0
[ 1706.117270] [<c0289f5c>] (rtl8169_poll) from [<c032d098>] (net_rx_action+0x1cc/0x2ec)
[ 1706.117287]  r10:00022548 r9:df471ba8 r8:c05257e0 r7:0000012c r6:00000040 r5:00000001
[ 1706.117356]  r4:de3523f0
[ 1706.117413] [<c032cecc>] (net_rx_action) from [<c001bd68>] (__do_softirq+0xf4/0x254)
[ 1706.117430]  r10:00000101 r9:c052618c r8:40000001 r7:c0526188 r6:df470000 r5:00000003
[ 1706.117500]  r4:00000000
[ 1706.117537] [<c001bc74>] (__do_softirq) from [<c001bf58>] (do_softirq.part.2+0x34/0x40)
[ 1706.117554]  r10:00000001 r9:c0525a26 r8:c05555c0 r7:00000000 r6:deae8a80 r5:00000000
[ 1706.117623]  r4:20000013
[ 1706.117662] [<c001bf24>] (do_softirq.part.2) from [<c001c010>] (__local_bh_enable_ip+0xac/0xcc)
[ 1706.117678]  r5:00000000 r4:00000200
[ 1706.117740] [<c001bf64>] (__local_bh_enable_ip) from [<c0319538>] (release_sock+0x12c/0x158)
[ 1706.117757]  r5:00000000 r4:00000000
[ 1706.117813] [<c031940c>] (release_sock) from [<c03671b4>] (tcp_sendmsg+0xf8/0xa90)
[ 1706.117831]  r10:00004040 r9:deae8a80 r8:df471d74 r7:88cd7146 r6:0000059c r5:de8ccb00
[ 1706.117901]  r4:0000007c r3:00000001
[ 1706.117947] [<c03670bc>] (tcp_sendmsg) from [<c038d7f0>] (inet_sendmsg+0x3c/0x74)
[ 1706.117965]  r10:df471e2c r9:00000000 r8:df7eb604 r7:00000000 r6:00000000 r5:df02c780
[ 1706.118035]  r4:deae8a80
[ 1706.118070] [<c038d7b4>] (inet_sendmsg) from [<c03157f0>] (sock_sendmsg+0x1c/0x30)
[ 1706.118086]  r4:df471d74
[ 1706.118119] [<c03157d4>] (sock_sendmsg) from [<c03158f4>] (kernel_sendmsg+0x38/0x40)
[ 1706.118144] [<c03158bc>] (kernel_sendmsg) from [<c03afa2c>] (xs_send_kvec+0x94/0x9c)
[ 1706.118161]  r5:00000000 r4:df02c780
[ 1706.118202] [<c03af998>] (xs_send_kvec) from [<c03afaa0>] (xs_sendpages+0x6c/0x244)
[ 1706.118218]  r9:00000000 r8:df02c780 r7:0000007c r6:df7eb604 r5:00000001 r4:00000000
[ 1706.118293] [<c03afa34>] (xs_sendpages) from [<c03afd7c>] (xs_tcp_send_request+0x80/0x134)
[ 1706.118309]  r10:00000000 r9:00000000 r8:de8e8000 r7:de0d7258 r6:df7eb604 r5:00000001
[ 1706.118380]  r4:df7eb600
[ 1706.118436] [<c03afcfc>] (xs_tcp_send_request) from [<c03ad670>] (xprt_transmit+0x58/0x214)
[ 1706.118455]  r10:de92cc60 r9:00000000 r8:d3697fdd r7:df7eb674 r6:de0d7258 r5:df7eb600
[ 1706.118528]  r4:de8e8000
[ 1706.118567] [<c03ad618>] (xprt_transmit) from [<c03aac74>] (call_transmit+0x18c/0x230)
[ 1706.118583]  r7:df7eb600 r6:00000001 r5:df7eb600 r4:de0d7258
[ 1706.118649] [<c03aaae8>] (call_transmit) from [<c03b1ed8>] (__rpc_execute+0x54/0x2c4)
[ 1706.118667]  r8:c0508940 r7:00000000 r6:c03b1f08 r5:00000001 r4:de0d7258
[ 1706.118736] [<c03b1e84>] (__rpc_execute) from [<c03b215c>] (rpc_async_schedule+0x14/0x18)
[ 1706.118751]  r7:00000000 r6:dfbf0800 r5:de92cc60 r4:de0d727c
[ 1706.118821] [<c03b2148>] (rpc_async_schedule) from [<c002c79c>] (process_one_work+0x130/0x3ec)
[ 1706.118847] [<c002c66c>] (process_one_work) from [<c002caa8>] (worker_thread+0x50/0x5ac)
[ 1706.118864]  r10:de92cc60 r9:c0508940 r8:00000008 r7:c050b220 r6:c0508954 r5:de92cc78
[ 1706.118935]  r4:c0508940
[ 1706.118980] [<c002ca58>] (worker_thread) from [<c00319cc>] (kthread+0xc8/0xe4)
[ 1706.118997]  r10:00000000 r9:00000000 r8:00000000 r7:c002ca58 r6:de92cc60 r5:00000000
[ 1706.119067]  r4:de385880
[ 1706.119106] [<c0031904>] (kthread) from [<c000a390>] (ret_from_fork+0x14/0x24)
[ 1706.119123]  r7:00000000 r6:00000000 r5:c0031904 r4:de385880
[ 1706.119171] Mem-Info:
[ 1706.119213] active_anon:2694 inactive_anon:2799 isolated_anon:0
[ 1706.119213]  active_file:43728 inactive_file:71243 isolated_file:0
[ 1706.119213]  unevictable:0 dirty:1486 writeback:0 unstable:0
[ 1706.119213]  slab_reclaimable:3099 slab_unreclaimable:710
[ 1706.119213]  mapped:1763 shmem:19 pagetables:186 bounce:0
[ 1706.119213]  free:290 free_pcp:55 free_cma:0
[ 1706.119304] Normal free:1160kB min:2868kB low:3584kB high:4300kB active_anon:10776kB inactive_anon:11196kB active_file:174912kB inactive_file:284972kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:524288kB managed:514412kB mlocked:0kB dirty:5944kB writeback:0kB mapped:7052kB shmem:76kB slab_reclaimable:12396kB slab_unreclaimable:2840kB kernel_stack:584kB pagetables:744kB unstable:0kB bounce:0kB free_pcp:220kB local_pcp:220kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 1706.119325] lowmem_reserve[]: 0 0
[ 1706.119341] Normal: 80*4kB (UME) 105*8kB (UE) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1160kB
[ 1706.119402] 114997 total pagecache pages
[ 1706.119420] 0 pages in swap cache
[ 1706.119434] Swap cache stats: add 0, delete 0, find 0/0
[ 1706.119444] Free swap  = 1048572kB
[ 1706.119454] Total swap = 1048572kB
[ 1706.119463] 131072 pages RAM
[ 1706.119473] 0 pages HighMem/MovableOnly
[ 1706.119483] 2469 pages reserved
[ 1706.119507] SLUB: Unable to allocate memory on node -1, gfp=0x2080020(GFP_ATOMIC)
[ 1706.119525]   cache: kmalloc-192, object size: 192, buffer size: 192, default order: 0, min order: 0
[ 1706.119541]   node 0: slabs: 12, objs: 252, free: 0
[ 1706.119581] kworker/0:1H: page allocation failure: order:0, mode:0x2200020(GFP_NOWAIT|__GFP_HIGH|__GFP_NOTRACK)
[ 1706.119603] CPU: 0 PID: 519 Comm: kworker/0:1H Not tainted 4.6.0-rc5-iop32x-los_a50bb #1
[ 1706.119616] Hardware name: Thecus N2100
[ 1706.119636] Workqueue: rpciod rpc_async_schedule
[ 1706.119646] Backtrace: 
[ 1706.119678] [<c000d460>] (dump_backtrace) from [<c000d658>] (show_stack+0x18/0x1c)
[ 1706.119697]  r7:00000000 r6:00000060 r5:00000000 r4:00000000
[ 1706.119768] [<c000d640>] (show_stack) from [<c01c1e84>] (dump_stack+0x20/0x28)
[ 1706.119808] [<c01c1e64>] (dump_stack) from [<c007b9b0>] (warn_alloc_failed+0xf0/0x134)
[ 1706.119839] [<c007b8c4>] (warn_alloc_failed) from [<c007df78>] (__alloc_pages_nodemask+0x284/0x8fc)
[ 1706.119857]  r3:02200020 r2:00000000
[ 1706.119893]  r5:00000000 r4:c0524c40
[ 1706.119959] [<c007dcf4>] (__alloc_pages_nodemask) from [<c00b1948>] (new_slab+0x3c4/0x430)
[ 1706.119976]  r10:00000000 r9:c0321fdc r8:00000000 r7:df401d00 r6:00000015 r5:02000020
[ 1706.120047]  r4:df401d00
[ 1706.120084] [<c00b1584>] (new_slab) from [<c00b2bd8>] (___slab_alloc.constprop.8+0x238/0x298)
[ 1706.120100]  r10:00000000 r9:c0321fdc r8:02080020 r7:df401d00 r6:dfbef060 r5:00000000
[ 1706.120170]  r4:00000000
[ 1706.120203] [<c00b29a0>] (___slab_alloc.constprop.8) from [<c00b2f68>] (kmem_cache_alloc+0xbc/0xf8)
[ 1706.120219]  r10:00167e97 r9:340285ee r8:e11e1960 r7:60000013 r6:02080020 r5:df401d00
[ 1706.120290]  r4:00000000
[ 1706.120328] [<c00b2eac>] (kmem_cache_alloc) from [<c0321fdc>] (__build_skb+0x2c/0x98)
[ 1706.120345]  r7:cc593240 r6:000006e0 r5:de3523f0 r4:000006e0
[ 1706.120405] [<c0321fb0>] (__build_skb) from [<c032226c>] (__napi_alloc_skb+0xb0/0xfc)
[ 1706.120421]  r9:340285ee r8:e11e1960 r7:cc593240 r6:c0520ab8 r5:de3523f0 r4:000006e0
[ 1706.120523] [<c03221bc>] (__napi_alloc_skb) from [<c028a2fc>] (rtl8169_poll+0x3a0/0x588)
[ 1706.120541]  r7:de374000 r6:c000fd08 r5:000005ea r4:de3523f0
[ 1706.120607] [<c0289f5c>] (rtl8169_poll) from [<c032d098>] (net_rx_action+0x1cc/0x2ec)
[ 1706.120624]  r10:00022548 r9:df471ba8 r8:c05257e0 r7:0000012c r6:00000040 r5:00000001
[ 1706.120694]  r4:de3523f0
[ 1706.120751] [<c032cecc>] (net_rx_action) from [<c001bd68>] (__do_softirq+0xf4/0x254)
[ 1706.120771]  r10:00000101 r9:c052618c r8:40000001 r7:c0526188 r6:df470000 r5:00000003
[ 1706.120842]  r4:00000000
[ 1706.120879] [<c001bc74>] (__do_softirq) from [<c001bf58>] (do_softirq.part.2+0x34/0x40)
[ 1706.120895]  r10:00000001 r9:c0525a26 r8:c05555c0 r7:00000000 r6:deae8a80 r5:00000000
[ 1706.120966]  r4:20000013
[ 1706.121006] [<c001bf24>] (do_softirq.part.2) from [<c001c010>] (__local_bh_enable_ip+0xac/0xcc)
[ 1706.121023]  r5:00000000 r4:00000200
[ 1706.121086] [<c001bf64>] (__local_bh_enable_ip) from [<c0319538>] (release_sock+0x12c/0x158)
[ 1706.121104]  r5:00000000 r4:00000000
[ 1706.121162] [<c031940c>] (release_sock) from [<c03671b4>] (tcp_sendmsg+0xf8/0xa90)
[ 1706.121178]  r10:00004040 r9:deae8a80 r8:df471d74 r7:88cd7146 r6:0000059c r5:de8ccb00
[ 1706.121249]  r4:0000007c r3:00000001
[ 1706.121295] [<c03670bc>] (tcp_sendmsg) from [<c038d7f0>] (inet_sendmsg+0x3c/0x74)
[ 1706.121313]  r10:df471e2c r9:00000000 r8:df7eb604 r7:00000000 r6:00000000 r5:df02c780
[ 1706.121382]  r4:deae8a80
[ 1706.121416] [<c038d7b4>] (inet_sendmsg) from [<c03157f0>] (sock_sendmsg+0x1c/0x30)
[ 1706.121432]  r4:df471d74
[ 1706.121466] [<c03157d4>] (sock_sendmsg) from [<c03158f4>] (kernel_sendmsg+0x38/0x40)
[ 1706.121491] [<c03158bc>] (kernel_sendmsg) from [<c03afa2c>] (xs_send_kvec+0x94/0x9c)
[ 1706.121508]  r5:00000000 r4:df02c780
[ 1706.121549] [<c03af998>] (xs_send_kvec) from [<c03afaa0>] (xs_sendpages+0x6c/0x244)
[ 1706.121566]  r9:00000000 r8:df02c780 r7:0000007c r6:df7eb604 r5:00000001 r4:00000000
[ 1706.121641] [<c03afa34>] (xs_sendpages) from [<c03afd7c>] (xs_tcp_send_request+0x80/0x134)
[ 1706.121657]  r10:00000000 r9:00000000 r8:de8e8000 r7:de0d7258 r6:df7eb604 r5:00000001
[ 1706.121727]  r4:df7eb600
[ 1706.121782] [<c03afcfc>] (xs_tcp_send_request) from [<c03ad670>] (xprt_transmit+0x58/0x214)
[ 1706.121802]  r10:de92cc60 r9:00000000 r8:d3697fdd r7:df7eb674 r6:de0d7258 r5:df7eb600
[ 1706.121873]  r4:de8e8000
[ 1706.121912] [<c03ad618>] (xprt_transmit) from [<c03aac74>] (call_transmit+0x18c/0x230)
[ 1706.121928]  r7:df7eb600 r6:00000001 r5:df7eb600 r4:de0d7258
[ 1706.121994] [<c03aaae8>] (call_transmit) from [<c03b1ed8>] (__rpc_execute+0x54/0x2c4)
[ 1706.122011]  r8:c0508940 r7:00000000 r6:c03b1f08 r5:00000001 r4:de0d7258
[ 1706.122081] [<c03b1e84>] (__rpc_execute) from [<c03b215c>] (rpc_async_schedule+0x14/0x18)
[ 1706.122098]  r7:00000000 r6:dfbf0800 r5:de92cc60 r4:de0d727c
[ 1706.122167] [<c03b2148>] (rpc_async_schedule) from [<c002c79c>] (process_one_work+0x130/0x3ec)
[ 1706.122192] [<c002c66c>] (process_one_work) from [<c002caa8>] (worker_thread+0x50/0x5ac)
[ 1706.122209]  r10:de92cc60 r9:c0508940 r8:00000008 r7:c050b220 r6:c0508954 r5:de92cc78
[ 1706.122279]  r4:c0508940
[ 1706.122324] [<c002ca58>] (worker_thread) from [<c00319cc>] (kthread+0xc8/0xe4)
[ 1706.122341]  r10:00000000 r9:00000000 r8:00000000 r7:c002ca58 r6:de92cc60 r5:00000000
[ 1706.122412]  r4:de385880
[ 1706.122449] [<c0031904>] (kthread) from [<c000a390>] (ret_from_fork+0x14/0x24)
[ 1706.122465]  r7:00000000 r6:00000000 r5:c0031904 r4:de385880
[ 1706.122513] Mem-Info:
[ 1706.122553] active_anon:2694 inactive_anon:2799 isolated_anon:0
[ 1706.122553]  active_file:43728 inactive_file:71243 isolated_file:0
[ 1706.122553]  unevictable:0 dirty:1486 writeback:0 unstable:0
[ 1706.122553]  slab_reclaimable:3099 slab_unreclaimable:710
[ 1706.122553]  mapped:1763 shmem:19 pagetables:186 bounce:0
[ 1706.122553]  free:290 free_pcp:55 free_cma:0
[ 1706.122638] Normal free:1160kB min:2868kB low:3584kB high:4300kB active_anon:10776kB inactive_anon:11196kB active_file:174912kB inactive_file:284972kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:524288kB managed:514412kB mlocked:0kB dirty:5944kB writeback:0kB mapped:7052kB shmem:76kB slab_reclaimable:12396kB slab_unreclaimable:2840kB kernel_stack:584kB pagetables:744kB unstable:0kB bounce:0kB free_pcp:220kB local_pcp:220kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 1706.122658] lowmem_reserve[]: 0 0
[ 1706.122674] Normal: 80*4kB (UME) 105*8kB (UE) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1160kB
[ 1706.122734] 114997 total pagecache pages
[ 1706.122752] 0 pages in swap cache
[ 1706.122767] Swap cache stats: add 0, delete 0, find 0/0
[ 1706.122777] Free swap  = 1048572kB
[ 1706.122787] Total swap = 1048572kB
[ 1706.122796] 131072 pages RAM
[ 1706.122805] 0 pages HighMem/MovableOnly
[ 1706.122815] 2469 pages reserved
[ 1706.122835] SLUB: Unable to allocate memory on node -1, gfp=0x2080020(GFP_ATOMIC)
[ 1706.122851]   cache: kmalloc-192, object size: 192, buffer size: 192, default order: 0, min order: 0
[ 1706.122868]   node 0: slabs: 12, objs: 252, free: 0
[ 1706.122903] kworker/0:1H: page allocation failure: order:0, mode:0x2200020(GFP_NOWAIT|__GFP_HIGH|__GFP_NOTRACK)
[ 1706.122927] CPU: 0 PID: 519 Comm: kworker/0:1H Not tainted 4.6.0-rc5-iop32x-los_a50bb #1
[ 1706.122939] Hardware name: Thecus N2100
[ 1706.122959] Workqueue: rpciod rpc_async_schedule
[ 1706.122968] Backtrace: 
[ 1706.123001] [<c000d460>] (dump_backtrace) from [<c000d658>] (show_stack+0x18/0x1c)
[ 1706.123019]  r7:00000000 r6:00000060 r5:00000000 r4:00000000
[ 1706.123091] [<c000d640>] (show_stack) from [<c01c1e84>] (dump_stack+0x20/0x28)
[ 1706.123131] [<c01c1e64>] (dump_stack) from [<c007b9b0>] (warn_alloc_failed+0xf0/0x134)
[ 1706.123161] [<c007b8c4>] (warn_alloc_failed) from [<c007df78>] (__alloc_pages_nodemask+0x284/0x8fc)
[ 1706.123177]  r3:02200020 r2:00000000
[ 1706.123213]  r5:00000000 r4:c0524c40
[ 1706.123279] [<c007dcf4>] (__alloc_pages_nodemask) from [<c00b1948>] (new_slab+0x3c4/0x430)
[ 1706.123296]  r10:00000000 r9:c0321fdc r8:00000000 r7:df401d00 r6:00000015 r5:02000020
[ 1706.123367]  r4:df401d00
[ 1706.123405] [<c00b1584>] (new_slab) from [<c00b2bd8>] (___slab_alloc.constprop.8+0x238/0x298)
[ 1706.123421]  r10:00000000 r9:c0321fdc r8:02080020 r7:df401d00 r6:dfbef060 r5:00000000
[ 1706.123491]  r4:00000000
[ 1706.123524] [<c00b29a0>] (___slab_alloc.constprop.8) from [<c00b2f68>] (kmem_cache_alloc+0xbc/0xf8)
[ 1706.123541]  r10:00167e98 r9:340285ee r8:e11e1970 r7:60000013 r6:02080020 r5:df401d00
[ 1706.123611]  r4:00000000
[ 1706.123650] [<c00b2eac>] (kmem_cache_alloc) from [<c0321fdc>] (__build_skb+0x2c/0x98)
[ 1706.123668]  r7:cc593920 r6:000006e0 r5:de3523f0 r4:000006e0
[ 1706.123729] [<c0321fb0>] (__build_skb) from [<c032226c>] (__napi_alloc_skb+0xb0/0xfc)
[ 1706.123745]  r9:340285ee r8:e11e1970 r7:cc593920 r6:c0520ab8 r5:de3523f0 r4:000006e0
[ 1706.123848] [<c03221bc>] (__napi_alloc_skb) from [<c028a2fc>] (rtl8169_poll+0x3a0/0x588)
[ 1706.123868]  r7:de378000 r6:c000fd08 r5:000005ea r4:de3523f0
[ 1706.123936] [<c0289f5c>] (rtl8169_poll) from [<c032d098>] (net_rx_action+0x1cc/0x2ec)
[ 1706.123953]  r10:00022548 r9:df471ba8 r8:c05257e0 r7:0000012c r6:00000040 r5:00000001
[ 1706.124023]  r4:de3523f0
[ 1706.124077] [<c032cecc>] (net_rx_action) from [<c001bd68>] (__do_softirq+0xf4/0x254)
[ 1706.124095]  r10:00000101 r9:c052618c r8:40000001 r7:c0526188 r6:df470000 r5:00000003
[ 1706.124165]  r4:00000000
[ 1706.124203] [<c001bc74>] (__do_softirq) from [<c001bf58>] (do_softirq.part.2+0x34/0x40)
[ 1706.124218]  r10:00000001 r9:c0525a26 r8:c05555c0 r7:00000000 r6:deae8a80 r5:00000000
[ 1706.124288]  r4:20000013
[ 1706.124327] [<c001bf24>] (do_softirq.part.2) from [<c001c010>] (__local_bh_enable_ip+0xac/0xcc)
[ 1706.124343]  r5:00000000 r4:00000200
[ 1706.124406] [<c001bf64>] (__local_bh_enable_ip) from [<c0319538>] (release_sock+0x12c/0x158)
[ 1706.124421]  r5:00000000 r4:00000000
[ 1706.124480] [<c031940c>] (release_sock) from [<c03671b4>] (tcp_sendmsg+0xf8/0xa90)
[ 1706.124497]  r10:00004040 r9:deae8a80 r8:df471d74 r7:88cd7146 r6:0000059c r5:de8ccb00
[ 1706.124568]  r4:0000007c r3:00000001
[ 1706.124615] [<c03670bc>] (tcp_sendmsg) from [<c038d7f0>] (inet_sendmsg+0x3c/0x74)
[ 1706.124633]  r10:df471e2c r9:00000000 r8:df7eb604 r7:00000000 r6:00000000 r5:df02c780
[ 1706.124704]  r4:deae8a80
[ 1706.124738] [<c038d7b4>] (inet_sendmsg) from [<c03157f0>] (sock_sendmsg+0x1c/0x30)
[ 1706.124754]  r4:df471d74
[ 1706.124787] [<c03157d4>] (sock_sendmsg) from [<c03158f4>] (kernel_sendmsg+0x38/0x40)
[ 1706.124813] [<c03158bc>] (kernel_sendmsg) from [<c03afa2c>] (xs_send_kvec+0x94/0x9c)
[ 1706.124828]  r5:00000000 r4:df02c780
[ 1706.124870] [<c03af998>] (xs_send_kvec) from [<c03afaa0>] (xs_sendpages+0x6c/0x244)
[ 1706.124887]  r9:00000000 r8:df02c780 r7:0000007c r6:df7eb604 r5:00000001 r4:00000000
[ 1706.124963] [<c03afa34>] (xs_sendpages) from [<c03afd7c>] (xs_tcp_send_request+0x80/0x134)
[ 1706.124980]  r10:00000000 r9:00000000 r8:de8e8000 r7:de0d7258 r6:df7eb604 r5:00000001
[ 1706.125050]  r4:df7eb600
[ 1706.125106] [<c03afcfc>] (xs_tcp_send_request) from [<c03ad670>] (xprt_transmit+0x58/0x214)
[ 1706.125126]  r10:de92cc60 r9:00000000 r8:d3697fdd r7:df7eb674 r6:de0d7258 r5:df7eb600
[ 1706.125197]  r4:de8e8000
[ 1706.125234] [<c03ad618>] (xprt_transmit) from [<c03aac74>] (call_transmit+0x18c/0x230)
[ 1706.125251]  r7:df7eb600 r6:00000001 r5:df7eb600 r4:de0d7258
[ 1706.125316] [<c03aaae8>] (call_transmit) from [<c03b1ed8>] (__rpc_execute+0x54/0x2c4)
[ 1706.125333]  r8:c0508940 r7:00000000 r6:c03b1f08 r5:00000001 r4:de0d7258
[ 1706.125402] [<c03b1e84>] (__rpc_execute) from [<c03b215c>] (rpc_async_schedule+0x14/0x18)
[ 1706.125419]  r7:00000000 r6:dfbf0800 r5:de92cc60 r4:de0d727c
[ 1706.125487] [<c03b2148>] (rpc_async_schedule) from [<c002c79c>] (process_one_work+0x130/0x3ec)
[ 1706.125511] [<c002c66c>] (process_one_work) from [<c002caa8>] (worker_thread+0x50/0x5ac)
[ 1706.125528]  r10:de92cc60 r9:c0508940 r8:00000008 r7:c050b220 r6:c0508954 r5:de92cc78
[ 1706.125597]  r4:c0508940
[ 1706.125643] [<c002ca58>] (worker_thread) from [<c00319cc>] (kthread+0xc8/0xe4)
[ 1706.125660]  r10:00000000 r9:00000000 r8:00000000 r7:c002ca58 r6:de92cc60 r5:00000000
[ 1706.125730]  r4:de385880
[ 1706.125767] [<c0031904>] (kthread) from [<c000a390>] (ret_from_fork+0x14/0x24)
[ 1706.125784]  r7:00000000 r6:00000000 r5:c0031904 r4:de385880
[ 1706.125832] Mem-Info:
[ 1706.125871] active_anon:2694 inactive_anon:2799 isolated_anon:0
[ 1706.125871]  active_file:43728 inactive_file:71243 isolated_file:0
[ 1706.125871]  unevictable:0 dirty:1486 writeback:0 unstable:0
[ 1706.125871]  slab_reclaimable:3099 slab_unreclaimable:710
[ 1706.125871]  mapped:1763 shmem:19 pagetables:186 bounce:0
[ 1706.125871]  free:290 free_pcp:55 free_cma:0
[ 1706.125956] Normal free:1160kB min:2868kB low:3584kB high:4300kB active_anon:10776kB inactive_anon:11196kB active_file:174912kB inactive_file:284972kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:524288kB managed:514412kB mlocked:0kB dirty:5944kB writeback:0kB mapped:7052kB shmem:76kB slab_reclaimable:12396kB slab_unreclaimable:2840kB kernel_stack:584kB pagetables:744kB unstable:0kB bounce:0kB free_pcp:220kB local_pcp:220kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 1706.125976] lowmem_reserve[]: 0 0
[ 1706.125990] Normal: 80*4kB (UME) 105*8kB (UE) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1160kB
[ 1706.126051] 114997 total pagecache pages
[ 1706.126068] 0 pages in swap cache
[ 1706.126081] Swap cache stats: add 0, delete 0, find 0/0
[ 1706.126091] Free swap  = 1048572kB
[ 1706.126100] Total swap = 1048572kB
[ 1706.126110] 131072 pages RAM
[ 1706.126119] 0 pages HighMem/MovableOnly
[ 1706.126128] 2469 pages reserved
[ 1706.126149] SLUB: Unable to allocate memory on node -1, gfp=0x2080020(GFP_ATOMIC)
[ 1706.126168]   cache: kmalloc-192, object size: 192, buffer size: 192, default order: 0, min order: 0
[ 1706.126183]   node 0: slabs: 12, objs: 252, free: 0
[ 1706.126360] kworker/0:1H: page allocation failure: order:0, mode:0x2200020(GFP_NOWAIT|__GFP_HIGH|__GFP_NOTRACK)
[ 1706.126399] CPU: 0 PID: 519 Comm: kworker/0:1H Not tainted 4.6.0-rc5-iop32x-los_a50bb #1
[ 1706.126411] Hardware name: Thecus N2100
[ 1706.126441] Workqueue: rpciod rpc_async_schedule
[ 1706.126456] Backtrace: 
[ 1706.126493] [<c000d460>] (dump_backtrace) from [<c000d658>] (show_stack+0x18/0x1c)
[ 1706.126519]  r7:00000000 r6:00000060 r5:00000000 r4:00000000
[ 1706.126594] [<c000d640>] (show_stack) from [<c01c1e84>] (dump_stack+0x20/0x28)
[ 1706.126638] [<c01c1e64>] (dump_stack) from [<c007b9b0>] (warn_alloc_failed+0xf0/0x134)
[ 1706.126669] [<c007b8c4>] (warn_alloc_failed) from [<c007df78>] (__alloc_pages_nodemask+0x284/0x8fc)
[ 1706.126686]  r3:02200020 r2:00000000
[ 1706.126721]  r5:00000000 r4:c0524c40
[ 1706.126789] [<c007dcf4>] (__alloc_pages_nodemask) from [<c00b1948>] (new_slab+0x3c4/0x430)
[ 1706.126807]  r10:00000000 r9:c0321fdc r8:00000000 r7:df401d00 r6:00000015 r5:02000020
[ 1706.126878]  r4:df401d00
[ 1706.126916] [<c00b1584>] (new_slab) from [<c00b2bd8>] (___slab_alloc.constprop.8+0x238/0x298)
[ 1706.126934]  r10:00000000 r9:c0321fdc r8:02080020 r7:df401d00 r6:dfbef060 r5:00000000
[ 1706.127003]  r4:00000000
[ 1706.127037] [<c00b29a0>] (___slab_alloc.constprop.8) from [<c00b2f68>] (kmem_cache_alloc+0xbc/0xf8)
[ 1706.127054]  r10:00167e99 r9:340285ee r8:e11e1980 r7:60000013 r6:02080020 r5:df401d00
[ 1706.127124]  r4:00000000
[ 1706.127162] [<c00b2eac>] (kmem_cache_alloc) from [<c0321fdc>] (__build_skb+0x2c/0x98)
[ 1706.127178]  r7:cc593240 r6:000006e0 r5:de3523f0 r4:000006e0
[ 1706.127238] [<c0321fb0>] (__build_skb) from [<c032226c>] (__napi_alloc_skb+0xb0/0xfc)
[ 1706.127254]  r9:340285ee r8:e11e1980 r7:cc593240 r6:c0520ab8 r5:de3523f0 r4:000006e0
[ 1706.127354] [<c03221bc>] (__napi_alloc_skb) from [<c028a2fc>] (rtl8169_poll+0x3a0/0x588)
[ 1706.127373]  r7:de37c000 r6:c000fd08 r5:000005ea r4:de3523f0
[ 1706.127438] [<c0289f5c>] (rtl8169_poll) from [<c032d098>] (net_rx_action+0x1cc/0x2ec)
[ 1706.127454]  r10:00022548 r9:df471ba8 r8:c05257e0 r7:0000012c r6:00000040 r5:00000001
[ 1706.127524]  r4:de3523f0
[ 1706.127581] [<c032cecc>] (net_rx_action) from [<c001bd68>] (__do_softirq+0xf4/0x254)
[ 1706.127598]  r10:00000101 r9:c052618c r8:40000001 r7:c0526188 r6:df470000 r5:00000003
[ 1706.127668]  r4:00000000
[ 1706.127705] [<c001bc74>] (__do_softirq) from [<c001bf58>] (do_softirq.part.2+0x34/0x40)
[ 1706.127722]  r10:00000001 r9:c0525a26 r8:c05555c0 r7:00000000 r6:deae8a80 r5:00000000
[ 1706.127793]  r4:20000013
[ 1706.127831] [<c001bf24>] (do_softirq.part.2) from [<c001c010>] (__local_bh_enable_ip+0xac/0xcc)
[ 1706.127848]  r5:00000000 r4:00000200
[ 1706.127910] [<c001bf64>] (__local_bh_enable_ip) from [<c0319538>] (release_sock+0x12c/0x158)
[ 1706.127926]  r5:00000000 r4:00000000
[ 1706.127981] [<c031940c>] (release_sock) from [<c03671b4>] (tcp_sendmsg+0xf8/0xa90)
[ 1706.127998]  r10:00004040 r9:deae8a80 r8:df471d74 r7:88cd7146 r6:0000059c r5:de8ccb00
[ 1706.128068]  r4:0000007c r3:00000001
[ 1706.128114] [<c03670bc>] (tcp_sendmsg) from [<c038d7f0>] (inet_sendmsg+0x3c/0x74)
[ 1706.128134]  r10:df471e2c r9:00000000 r8:df7eb604 r7:00000000 r6:00000000 r5:df02c780
[ 1706.128204]  r4:deae8a80
[ 1706.128238] [<c038d7b4>] (inet_sendmsg) from [<c03157f0>] (sock_sendmsg+0x1c/0x30)
[ 1706.128254]  r4:df471d74
[ 1706.128287] [<c03157d4>] (sock_sendmsg) from [<c03158f4>] (kernel_sendmsg+0x38/0x40)
[ 1706.128312] [<c03158bc>] (kernel_sendmsg) from [<c03afa2c>] (xs_send_kvec+0x94/0x9c)
[ 1706.128329]  r5:00000000 r4:df02c780
[ 1706.128371] [<c03af998>] (xs_send_kvec) from [<c03afaa0>] (xs_sendpages+0x6c/0x244)
[ 1706.128388]  r9:00000000 r8:df02c780 r7:0000007c r6:df7eb604 r5:00000001 r4:00000000
[ 1706.128463] [<c03afa34>] (xs_sendpages) from [<c03afd7c>] (xs_tcp_send_request+0x80/0x134)
[ 1706.128479]  r10:00000000 r9:00000000 r8:de8e8000 r7:de0d7258 r6:df7eb604 r5:00000001
[ 1706.128548]  r4:df7eb600
[ 1706.128607] [<c03afcfc>] (xs_tcp_send_request) from [<c03ad670>] (xprt_transmit+0x58/0x214)
[ 1706.128626]  r10:de92cc60 r9:00000000 r8:d3697fdd r7:df7eb674 r6:de0d7258 r5:df7eb600
[ 1706.128697]  r4:de8e8000
[ 1706.128737] [<c03ad618>] (xprt_transmit) from [<c03aac74>] (call_transmit+0x18c/0x230)
[ 1706.128753]  r7:df7eb600 r6:00000001 r5:df7eb600 r4:de0d7258
[ 1706.128821] [<c03aaae8>] (call_transmit) from [<c03b1ed8>] (__rpc_execute+0x54/0x2c4)
[ 1706.128838]  r8:c0508940 r7:00000000 r6:c03b1f08 r5:00000001 r4:de0d7258
[ 1706.128909] [<c03b1e84>] (__rpc_execute) from [<c03b215c>] (rpc_async_schedule+0x14/0x18)
[ 1706.128926]  r7:00000000 r6:dfbf0800 r5:de92cc60 r4:de0d727c
[ 1706.128996] [<c03b2148>] (rpc_async_schedule) from [<c002c79c>] (process_one_work+0x130/0x3ec)
[ 1706.129024] [<c002c66c>] (process_one_work) from [<c002caa8>] (worker_thread+0x50/0x5ac)
[ 1706.129041]  r10:de92cc60 r9:c0508940 r8:00000008 r7:c050b220 r6:c0508954 r5:de92cc78
[ 1706.129112]  r4:c0508940
[ 1706.129158] [<c002ca58>] (worker_thread) from [<c00319cc>] (kthread+0xc8/0xe4)
[ 1706.129174]  r10:00000000 r9:00000000 r8:00000000 r7:c002ca58 r6:de92cc60 r5:00000000
[ 1706.129243]  r4:de385880
[ 1706.129281] [<c0031904>] (kthread) from [<c000a390>] (ret_from_fork+0x14/0x24)
[ 1706.129296]  r7:00000000 r6:00000000 r5:c0031904 r4:de385880
[ 1706.129344] Mem-Info:
[ 1706.129386] active_anon:2694 inactive_anon:2799 isolated_anon:0
[ 1706.129386]  active_file:43728 inactive_file:71243 isolated_file:0
[ 1706.129386]  unevictable:0 dirty:1486 writeback:0 unstable:0
[ 1706.129386]  slab_reclaimable:3099 slab_unreclaimable:710
[ 1706.129386]  mapped:1763 shmem:19 pagetables:186 bounce:0
[ 1706.129386]  free:290 free_pcp:55 free_cma:0
[ 1706.129475] Normal free:1160kB min:2868kB low:3584kB high:4300kB active_anon:10776kB inactive_anon:11196kB active_file:174912kB inactive_file:284972kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:524288kB managed:514412kB mlocked:0kB dirty:5944kB writeback:0kB mapped:7052kB shmem:76kB slab_reclaimable:12396kB slab_unreclaimable:2840kB kernel_stack:584kB pagetables:744kB unstable:0kB bounce:0kB free_pcp:220kB local_pcp:220kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 1706.129499] lowmem_reserve[]: 0 0
[ 1706.129513] Normal: 80*4kB (UME) 105*8kB (UE) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1160kB
[ 1706.129577] 114997 total pagecache pages
[ 1706.129595] 0 pages in swap cache
[ 1706.129607] Swap cache stats: add 0, delete 0, find 0/0
[ 1706.129617] Free swap  = 1048572kB
[ 1706.129627] Total swap = 1048572kB
[ 1706.129636] 131072 pages RAM
[ 1706.129646] 0 pages HighMem/MovableOnly
[ 1706.129655] 2469 pages reserved
[ 1706.129676] SLUB: Unable to allocate memory on node -1, gfp=0x2080020(GFP_ATOMIC)
[ 1706.129694]   cache: kmalloc-192, object size: 192, buffer size: 192, default order: 0, min order: 0
[ 1706.129709]   node 0: slabs: 12, objs: 252, free: 0
[ 1706.129748] kworker/0:1H: page allocation failure: order:0, mode:0x2200020(GFP_NOWAIT|__GFP_HIGH|__GFP_NOTRACK)
[ 1706.129769] CPU: 0 PID: 519 Comm: kworker/0:1H Not tainted 4.6.0-rc5-iop32x-los_a50bb #1
[ 1706.129780] Hardware name: Thecus N2100
[ 1706.129799] Workqueue: rpciod rpc_async_schedule
[ 1706.129808] Backtrace: 
[ 1706.129840] [<c000d460>] (dump_backtrace) from [<c000d658>] (show_stack+0x18/0x1c)
[ 1706.129857]  r7:00000000 r6:00000060 r5:00000000 r4:00000000
[ 1706.129927] [<c000d640>] (show_stack) from [<c01c1e84>] (dump_stack+0x20/0x28)
[ 1706.129968] [<c01c1e64>] (dump_stack) from [<c007b9b0>] (warn_alloc_failed+0xf0/0x134)
[ 1706.129997] [<c007b8c4>] (warn_alloc_failed) from [<c007df78>] (__alloc_pages_nodemask+0x284/0x8fc)
[ 1706.130016]  r3:02200020 r2:00000000
[ 1706.130052]  r5:00000000 r4:c0524c40
[ 1706.130119] [<c007dcf4>] (__alloc_pages_nodemask) from [<c00b1948>] (new_slab+0x3c4/0x430)
[ 1706.130137]  r10:00000000 r9:c0321fdc r8:00000000 r7:df401d00 r6:00000015 r5:02000020
[ 1706.130209]  r4:df401d00
[ 1706.130246] [<c00b1584>] (new_slab) from [<c00b2bd8>] (___slab_alloc.constprop.8+0x238/0x298)
[ 1706.130262]  r10:00000000 r9:c0321fdc r8:02080020 r7:df401d00 r6:dfbef060 r5:00000000
[ 1706.130333]  r4:00000000
[ 1706.130367] [<c00b29a0>] (___slab_alloc.constprop.8) from [<c00b2f68>] (kmem_cache_alloc+0xbc/0xf8)
[ 1706.130384]  r10:00167e9a r9:340285ee r8:e11e1990 r7:60000013 r6:02080020 r5:df401d00
[ 1706.130454]  r4:00000000
[ 1706.130495] [<c00b2eac>] (kmem_cache_alloc) from [<c0321fdc>] (__build_skb+0x2c/0x98)
[ 1706.130512]  r7:cc593920 r6:000006e0 r5:de3523f0 r4:000006e0
[ 1706.130572] [<c0321fb0>] (__build_skb) from [<c032226c>] (__napi_alloc_skb+0xb0/0xfc)
[ 1706.130589]  r9:340285ee r8:e11e1990 r7:cc593920 r6:c0520ab8 r5:de3523f0 r4:000006e0
[ 1706.130687] [<c03221bc>] (__napi_alloc_skb) from [<c028a2fc>] (rtl8169_poll+0x3a0/0x588)
[ 1706.130707]  r7:de860000 r6:c000fd08 r5:000005ea r4:de3523f0
[ 1706.130777] [<c0289f5c>] (rtl8169_poll) from [<c032d098>] (net_rx_action+0x1cc/0x2ec)
[ 1706.130794]  r10:00022548 r9:df471ba8 r8:c05257e0 r7:0000012c r6:00000040 r5:00000001
[ 1706.130865]  r4:de3523f0
[ 1706.130922] [<c032cecc>] (net_rx_action) from [<c001bd68>] (__do_softirq+0xf4/0x254)
[ 1706.130939]  r10:00000101 r9:c052618c r8:40000001 r7:c0526188 r6:df470000 r5:00000003
[ 1706.131010]  r4:00000000
[ 1706.131048] [<c001bc74>] (__do_softirq) from [<c001bf58>] (do_softirq.part.2+0x34/0x40)
[ 1706.131064]  r10:00000001 r9:c0525a26 r8:c05555c0 r7:00000000 r6:deae8a80 r5:00000000
[ 1706.131134]  r4:20000013
[ 1706.131173] [<c001bf24>] (do_softirq.part.2) from [<c001c010>] (__local_bh_enable_ip+0xac/0xcc)
[ 1706.131189]  r5:00000000 r4:00000200
[ 1706.131251] [<c001bf64>] (__local_bh_enable_ip) from [<c0319538>] (release_sock+0x12c/0x158)
[ 1706.131268]  r5:00000000 r4:00000000
[ 1706.131324] [<c031940c>] (release_sock) from [<c03671b4>] (tcp_sendmsg+0xf8/0xa90)
[ 1706.131342]  r10:00004040 r9:deae8a80 r8:df471d74 r7:88cd7146 r6:0000059c r5:de8ccb00
[ 1706.131413]  r4:0000007c r3:00000001
[ 1706.131459] [<c03670bc>] (tcp_sendmsg) from [<c038d7f0>] (inet_sendmsg+0x3c/0x74)
[ 1706.131477]  r10:df471e2c r9:00000000 r8:df7eb604 r7:00000000 r6:00000000 r5:df02c780
[ 1706.131546]  r4:deae8a80
[ 1706.131581] [<c038d7b4>] (inet_sendmsg) from [<c03157f0>] (sock_sendmsg+0x1c/0x30)
[ 1706.131597]  r4:df471d74
[ 1706.131630] [<c03157d4>] (sock_sendmsg) from [<c03158f4>] (kernel_sendmsg+0x38/0x40)
[ 1706.131655] [<c03158bc>] (kernel_sendmsg) from [<c03afa2c>] (xs_send_kvec+0x94/0x9c)
[ 1706.131670]  r5:00000000 r4:df02c780
[ 1706.131713] [<c03af998>] (xs_send_kvec) from [<c03afaa0>] (xs_sendpages+0x6c/0x244)
[ 1706.131728]  r9:00000000 r8:df02c780 r7:0000007c r6:df7eb604 r5:00000001 r4:00000000
[ 1706.131805] [<c03afa34>] (xs_sendpages) from [<c03afd7c>] (xs_tcp_send_request+0x80/0x134)
[ 1706.131821]  r10:00000000 r9:00000000 r8:de8e8000 r7:de0d7258 r6:df7eb604 r5:00000001
[ 1706.131891]  r4:df7eb600
[ 1706.131945] [<c03afcfc>] (xs_tcp_send_request) from [<c03ad670>] (xprt_transmit+0x58/0x214)
[ 1706.131963]  r10:de92cc60 r9:00000000 r8:d3697fdd r7:df7eb674 r6:de0d7258 r5:df7eb600
[ 1706.132035]  r4:de8e8000
[ 1706.132072] [<c03ad618>] (xprt_transmit) from [<c03aac74>] (call_transmit+0x18c/0x230)
[ 1706.132088]  r7:df7eb600 r6:00000001 r5:df7eb600 r4:de0d7258
[ 1706.132153] [<c03aaae8>] (call_transmit) from [<c03b1ed8>] (__rpc_execute+0x54/0x2c4)
[ 1706.132169]  r8:c0508940 r7:00000000 r6:c03b1f08 r5:00000001 r4:de0d7258
[ 1706.132239] [<c03b1e84>] (__rpc_execute) from [<c03b215c>] (rpc_async_schedule+0x14/0x18)
[ 1706.132256]  r7:00000000 r6:dfbf0800 r5:de92cc60 r4:de0d727c
[ 1706.132327] [<c03b2148>] (rpc_async_schedule) from [<c002c79c>] (process_one_work+0x130/0x3ec)
[ 1706.132351] [<c002c66c>] (process_one_work) from [<c002caa8>] (worker_thread+0x50/0x5ac)
[ 1706.132368]  r10:de92cc60 r9:c0508940 r8:00000008 r7:c050b220 r6:c0508954 r5:de92cc78
[ 1706.132439]  r4:c0508940
[ 1706.132483] [<c002ca58>] (worker_thread) from [<c00319cc>] (kthread+0xc8/0xe4)
[ 1706.132500]  r10:00000000 r9:00000000 r8:00000000 r7:c002ca58 r6:de92cc60 r5:00000000
[ 1706.132570]  r4:de385880
[ 1706.132608] [<c0031904>] (kthread) from [<c000a390>] (ret_from_fork+0x14/0x24)
[ 1706.132625]  r7:00000000 r6:00000000 r5:c0031904 r4:de385880
[ 1706.132673] Mem-Info:
[ 1706.132714] active_anon:2694 inactive_anon:2799 isolated_anon:0
[ 1706.132714]  active_file:43728 inactive_file:71243 isolated_file:0
[ 1706.132714]  unevictable:0 dirty:1486 writeback:0 unstable:0
[ 1706.132714]  slab_reclaimable:3099 slab_unreclaimable:710
[ 1706.132714]  mapped:1763 shmem:19 pagetables:186 bounce:0
[ 1706.132714]  free:290 free_pcp:55 free_cma:0
[ 1706.132799] Normal free:1160kB min:2868kB low:3584kB high:4300kB active_anon:10776kB inactive_anon:11196kB active_file:174912kB inactive_file:284972kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:524288kB managed:514412kB mlocked:0kB dirty:5944kB writeback:0kB mapped:7052kB shmem:76kB slab_reclaimable:12396kB slab_unreclaimable:2840kB kernel_stack:584kB pagetables:744kB unstable:0kB bounce:0kB free_pcp:220kB local_pcp:220kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 1706.132820] lowmem_reserve[]: 0 0
[ 1706.132835] Normal: 80*4kB (UME) 105*8kB (UE) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1160kB
[ 1706.132896] 114997 total pagecache pages
[ 1706.132914] 0 pages in swap cache
[ 1706.132927] Swap cache stats: add 0, delete 0, find 0/0
[ 1706.132937] Free swap  = 1048572kB
[ 1706.132947] Total swap = 1048572kB
[ 1706.132957] 131072 pages RAM
[ 1706.132966] 0 pages HighMem/MovableOnly
[ 1706.132976] 2469 pages reserved
[ 1706.132996] SLUB: Unable to allocate memory on node -1, gfp=0x2080020(GFP_ATOMIC)
[ 1706.133014]   cache: kmalloc-192, object size: 192, buffer size: 192, default order: 0, min order: 0
[ 1706.133029]   node 0: slabs: 12, objs: 252, free: 0
[ 1706.133064] kworker/0:1H: page allocation failure: order:0, mode:0x2200020(GFP_NOWAIT|__GFP_HIGH|__GFP_NOTRACK)
[ 1706.133087] CPU: 0 PID: 519 Comm: kworker/0:1H Not tainted 4.6.0-rc5-iop32x-los_a50bb #1
[ 1706.133099] Hardware name: Thecus N2100
[ 1706.133118] Workqueue: rpciod rpc_async_schedule
[ 1706.133130] Backtrace: 
[ 1706.133162] [<c000d460>] (dump_backtrace) from [<c000d658>] (show_stack+0x18/0x1c)
[ 1706.133179]  r7:00000000 r6:00000060 r5:00000000 r4:00000000
[ 1706.133251] [<c000d640>] (show_stack) from [<c01c1e84>] (dump_stack+0x20/0x28)
[ 1706.133292] [<c01c1e64>] (dump_stack) from [<c007b9b0>] (warn_alloc_failed+0xf0/0x134)
[ 1706.133324] [<c007b8c4>] (warn_alloc_failed) from [<c007df78>] (__alloc_pages_nodemask+0x284/0x8fc)
[ 1706.133341]  r3:02200020 r2:00000000
[ 1706.133377]  r5:00000000 r4:c0524c40
[ 1706.133444] [<c007dcf4>] (__alloc_pages_nodemask) from [<c00b1948>] (new_slab+0x3c4/0x430)
[ 1706.133460]  r10:00000000 r9:c0321fdc r8:00000000 r7:df401d00 r6:00000015 r5:02000020
[ 1706.133531]  r4:df401d00
[ 1706.133569] [<c00b1584>] (new_slab) from [<c00b2bd8>] (___slab_alloc.constprop.8+0x238/0x298)
[ 1706.133585]  r10:00000000 r9:c0321fdc r8:02080020 r7:df401d00 r6:dfbef060 r5:00000000
[ 1706.133655]  r4:00000000
[ 1706.133688] [<c00b29a0>] (___slab_alloc.constprop.8) from [<c00b2f68>] (kmem_cache_alloc+0xbc/0xf8)
[ 1706.133705]  r10:00167e9b r9:340285ee r8:e11e19a0 r7:60000013 r6:02080020 r5:df401d00
[ 1706.133775]  r4:00000000
[ 1706.133816] [<c00b2eac>] (kmem_cache_alloc) from [<c0321fdc>] (__build_skb+0x2c/0x98)
[ 1706.133833]  r7:cc593240 r6:000006e0 r5:de3523f0 r4:000006e0
[ 1706.133893] [<c0321fb0>] (__build_skb) from [<c032226c>] (__napi_alloc_skb+0xb0/0xfc)
[ 1706.133910]  r9:340285ee r8:e11e19a0 r7:cc593240 r6:c0520ab8 r5:de3523f0 r4:000006e0
[ 1706.134009] [<c03221bc>] (__napi_alloc_skb) from [<c028a2fc>] (rtl8169_poll+0x3a0/0x588)
[ 1706.134028]  r7:de864000 r6:c000fd08 r5:000005ea r4:de3523f0
[ 1706.134094] [<c0289f5c>] (rtl8169_poll) from [<c032d098>] (net_rx_action+0x1cc/0x2ec)
[ 1706.134111]  r10:00022548 r9:df471ba8 r8:c05257e0 r7:0000012c r6:00000040 r5:00000001
[ 1706.134181]  r4:de3523f0
[ 1706.134239] [<c032cecc>] (net_rx_action) from [<c001bd68>] (__do_softirq+0xf4/0x254)
[ 1706.134257]  r10:00000101 r9:c052618c r8:40000001 r7:c0526188 r6:df470000 r5:00000003
[ 1706.134327]  r4:00000000
[ 1706.134364] [<c001bc74>] (__do_softirq) from [<c001bf58>] (do_softirq.part.2+0x34/0x40)
[ 1706.134380]  r10:00000001 r9:c0525a26 r8:c05555c0 r7:00000000 r6:deae8a80 r5:00000000
[ 1706.134451]  r4:20000013
[ 1706.134489] [<c001bf24>] (do_softirq.part.2) from [<c001c010>] (__local_bh_enable_ip+0xac/0xcc)
[ 1706.134506]  r5:00000000 r4:00000200
[ 1706.134566] [<c001bf64>] (__local_bh_enable_ip) from [<c0319538>] (release_sock+0x12c/0x158)
[ 1706.134582]  r5:00000000 r4:00000000
[ 1706.134639] [<c031940c>] (release_sock) from [<c03671b4>] (tcp_sendmsg+0xf8/0xa90)
[ 1706.134657]  r10:00004040 r9:deae8a80 r8:df471d74 r7:88cd7146 r6:0000059c r5:de8ccb00
[ 1706.134727]  r4:0000007c r3:00000001
[ 1706.134774] [<c03670bc>] (tcp_sendmsg) from [<c038d7f0>] (inet_sendmsg+0x3c/0x74)
[ 1706.134790]  r10:df471e2c r9:00000000 r8:df7eb604 r7:00000000 r6:00000000 r5:df02c780
[ 1706.134860]  r4:deae8a80
[ 1706.134893] [<c038d7b4>] (inet_sendmsg) from [<c03157f0>] (sock_sendmsg+0x1c/0x30)
[ 1706.134909]  r4:df471d74
[ 1706.134943] [<c03157d4>] (sock_sendmsg) from [<c03158f4>] (kernel_sendmsg+0x38/0x40)
[ 1706.134968] [<c03158bc>] (kernel_sendmsg) from [<c03afa2c>] (xs_send_kvec+0x94/0x9c)
[ 1706.134985]  r5:00000000 r4:df02c780
[ 1706.135027] [<c03af998>] (xs_send_kvec) from [<c03afaa0>] (xs_sendpages+0x6c/0x244)
[ 1706.135043]  r9:00000000 r8:df02c780 r7:0000007c r6:df7eb604 r5:00000001 r4:00000000
[ 1706.135118] [<c03afa34>] (xs_sendpages) from [<c03afd7c>] (xs_tcp_send_request+0x80/0x134)
[ 1706.135134]  r10:00000000 r9:00000000 r8:de8e8000 r7:de0d7258 r6:df7eb604 r5:00000001
[ 1706.135203]  r4:df7eb600
[ 1706.135260] [<c03afcfc>] (xs_tcp_send_request) from [<c03ad670>] (xprt_transmit+0x58/0x214)
[ 1706.135280]  r10:de92cc60 r9:00000000 r8:d3697fdd r7:df7eb674 r6:de0d7258 r5:df7eb600
[ 1706.135350]  r4:de8e8000
[ 1706.135388] [<c03ad618>] (xprt_transmit) from [<c03aac74>] (call_transmit+0x18c/0x230)
[ 1706.135407]  r7:df7eb600 r6:00000001 r5:df7eb600 r4:de0d7258
[ 1706.135472] [<c03aaae8>] (call_transmit) from [<c03b1ed8>] (__rpc_execute+0x54/0x2c4)
[ 1706.135489]  r8:c0508940 r7:00000000 r6:c03b1f08 r5:00000001 r4:de0d7258
[ 1706.135560] [<c03b1e84>] (__rpc_execute) from [<c03b215c>] (rpc_async_schedule+0x14/0x18)
[ 1706.135577]  r7:00000000 r6:dfbf0800 r5:de92cc60 r4:de0d727c
[ 1706.135648] [<c03b2148>] (rpc_async_schedule) from [<c002c79c>] (process_one_work+0x130/0x3ec)
[ 1706.135673] [<c002c66c>] (process_one_work) from [<c002caa8>] (worker_thread+0x50/0x5ac)
[ 1706.135690]  r10:de92cc60 r9:c0508940 r8:00000008 r7:c050b220 r6:c0508954 r5:de92cc78
[ 1706.135760]  r4:c0508940
[ 1706.135805] [<c002ca58>] (worker_thread) from [<c00319cc>] (kthread+0xc8/0xe4)
[ 1706.135820]  r10:00000000 r9:00000000 r8:00000000 r7:c002ca58 r6:de92cc60 r5:00000000
[ 1706.135890]  r4:de385880
[ 1706.135928] [<c0031904>] (kthread) from [<c000a390>] (ret_from_fork+0x14/0x24)
[ 1706.135943]  r7:00000000 r6:00000000 r5:c0031904 r4:de385880
[ 1706.135991] Mem-Info:
[ 1706.136030] active_anon:2694 inactive_anon:2799 isolated_anon:0
[ 1706.136030]  active_file:43728 inactive_file:71243 isolated_file:0
[ 1706.136030]  unevictable:0 dirty:1486 writeback:0 unstable:0
[ 1706.136030]  slab_reclaimable:3099 slab_unreclaimable:710
[ 1706.136030]  mapped:1763 shmem:19 pagetables:186 bounce:0
[ 1706.136030]  free:290 free_pcp:55 free_cma:0
[ 1706.136116] Normal free:1160kB min:2868kB low:3584kB high:4300kB active_anon:10776kB inactive_anon:11196kB active_file:174912kB inactive_file:284972kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:524288kB managed:514412kB mlocked:0kB dirty:5944kB writeback:0kB mapped:7052kB shmem:76kB slab_reclaimable:12396kB slab_unreclaimable:2840kB kernel_stack:584kB pagetables:744kB unstable:0kB bounce:0kB free_pcp:220kB local_pcp:220kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 1706.136136] lowmem_reserve[]: 0 0
[ 1706.136151] Normal: 80*4kB (UME) 105*8kB (UE) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1160kB
[ 1706.136215] 114997 total pagecache pages
[ 1706.136232] 0 pages in swap cache
[ 1706.136245] Swap cache stats: add 0, delete 0, find 0/0
[ 1706.136256] Free swap  = 1048572kB
[ 1706.136265] Total swap = 1048572kB
[ 1706.136274] 131072 pages RAM
[ 1706.136284] 0 pages HighMem/MovableOnly
[ 1706.136293] 2469 pages reserved
[ 1706.136312] SLUB: Unable to allocate memory on node -1, gfp=0x2080020(GFP_ATOMIC)
[ 1706.136331]   cache: kmalloc-192, object size: 192, buffer size: 192, default order: 0, min order: 0
[ 1706.136347]   node 0: slabs: 12, objs: 252, free: 0
[ 1706.136517] kworker/0:1H: page allocation failure: order:0, mode:0x2200020(GFP_NOWAIT|__GFP_HIGH|__GFP_NOTRACK)
[ 1706.136556] CPU: 0 PID: 519 Comm: kworker/0:1H Not tainted 4.6.0-rc5-iop32x-los_a50bb #1
[ 1706.136569] Hardware name: Thecus N2100
[ 1706.136599] Workqueue: rpciod rpc_async_schedule
[ 1706.136613] Backtrace: 
[ 1706.136648] [<c000d460>] (dump_backtrace) from [<c000d658>] (show_stack+0x18/0x1c)
[ 1706.136673]  r7:00000000 r6:00000060 r5:00000000 r4:00000000
[ 1706.136748] [<c000d640>] (show_stack) from [<c01c1e84>] (dump_stack+0x20/0x28)
[ 1706.136790] [<c01c1e64>] (dump_stack) from [<c007b9b0>] (warn_alloc_failed+0xf0/0x134)
[ 1706.136820] [<c007b8c4>] (warn_alloc_failed) from [<c007df78>] (__alloc_pages_nodemask+0x284/0x8fc)
[ 1706.136837]  r3:02200020 r2:00000000
[ 1706.136872]  r5:00000000 r4:c0524c40
[ 1706.136937] [<c007dcf4>] (__alloc_pages_nodemask) from [<c00b1948>] (new_slab+0x3c4/0x430)
[ 1706.136955]  r10:00000000 r9:c0321fdc r8:00000000 r7:df401d00 r6:00000015 r5:02000020
[ 1706.137025]  r4:df401d00
[ 1706.137064] [<c00b1584>] (new_slab) from [<c00b2bd8>] (___slab_alloc.constprop.8+0x238/0x298)
[ 1706.137081]  r10:00000000 r9:c0321fdc r8:02080020 r7:df401d00 r6:dfbef060 r5:00000000
[ 1706.137151]  r4:00000000
[ 1706.137184] [<c00b29a0>] (___slab_alloc.constprop.8) from [<c00b2f68>] (kmem_cache_alloc+0xbc/0xf8)
[ 1706.137200]  r10:00167e9c r9:340285ee r8:e11e19b0 r7:60000013 r6:02080020 r5:df401d00
[ 1706.137271]  r4:00000000
[ 1706.137312] [<c00b2eac>] (kmem_cache_alloc) from [<c0321fdc>] (__build_skb+0x2c/0x98)
[ 1706.137329]  r7:cc593920 r6:000006e0 r5:de3523f0 r4:000006e0
[ 1706.137389] [<c0321fb0>] (__build_skb) from [<c032226c>] (__napi_alloc_skb+0xb0/0xfc)
[ 1706.137405]  r9:340285ee r8:e11e19b0 r7:cc593920 r6:c0520ab8 r5:de3523f0 r4:000006e0
[ 1706.137509] [<c03221bc>] (__napi_alloc_skb) from [<c028a2fc>] (rtl8169_poll+0x3a0/0x588)
[ 1706.137531]  r7:de868000 r6:c000fd08 r5:000005ea r4:de3523f0
[ 1706.137598] [<c0289f5c>] (rtl8169_poll) from [<c032d098>] (net_rx_action+0x1cc/0x2ec)
[ 1706.137616]  r10:00022548 r9:df471ba8 r8:c05257e0 r7:0000012c r6:00000040 r5:00000001
[ 1706.137686]  r4:de3523f0
[ 1706.137744] [<c032cecc>] (net_rx_action) from [<c001bd68>] (__do_softirq+0xf4/0x254)
[ 1706.137762]  r10:00000101 r9:c052618c r8:40000001 r7:c0526188 r6:df470000 r5:00000003
[ 1706.137832]  r4:00000000
[ 1706.137869] [<c001bc74>] (__do_softirq) from [<c001bf58>] (do_softirq.part.2+0x34/0x40)
[ 1706.137886]  r10:00000001 r9:c0525a26 r8:c05555c0 r7:00000000 r6:deae8a80 r5:00000000
[ 1706.137955]  r4:20000013
[ 1706.137994] [<c001bf24>] (do_softirq.part.2) from [<c001c010>] (__local_bh_enable_ip+0xac/0xcc)
[ 1706.138009]  r5:00000000 r4:00000200
[ 1706.138070] [<c001bf64>] (__local_bh_enable_ip) from [<c0319538>] (release_sock+0x12c/0x158)
[ 1706.138087]  r5:00000000 r4:00000000
[ 1706.138143] [<c031940c>] (release_sock) from [<c03671b4>] (tcp_sendmsg+0xf8/0xa90)
[ 1706.138161]  r10:00004040 r9:deae8a80 r8:df471d74 r7:88cd7146 r6:0000059c r5:de8ccb00
[ 1706.138231]  r4:0000007c r3:00000001
[ 1706.138278] [<c03670bc>] (tcp_sendmsg) from [<c038d7f0>] (inet_sendmsg+0x3c/0x74)
[ 1706.138296]  r10:df471e2c r9:00000000 r8:df7eb604 r7:00000000 r6:00000000 r5:df02c780
[ 1706.138366]  r4:deae8a80
[ 1706.138400] [<c038d7b4>] (inet_sendmsg) from [<c03157f0>] (sock_sendmsg+0x1c/0x30)
[ 1706.138417]  r4:df471d74
[ 1706.138451] [<c03157d4>] (sock_sendmsg) from [<c03158f4>] (kernel_sendmsg+0x38/0x40)
[ 1706.138476] [<c03158bc>] (kernel_sendmsg) from [<c03afa2c>] (xs_send_kvec+0x94/0x9c)
[ 1706.138492]  r5:00000000 r4:df02c780
[ 1706.138534] [<c03af998>] (xs_send_kvec) from [<c03afaa0>] (xs_sendpages+0x6c/0x244)
[ 1706.138550]  r9:00000000 r8:df02c780 r7:0000007c r6:df7eb604 r5:00000001 r4:00000000
[ 1706.138625] [<c03afa34>] (xs_sendpages) from [<c03afd7c>] (xs_tcp_send_request+0x80/0x134)
[ 1706.138641]  r10:00000000 r9:00000000 r8:de8e8000 r7:de0d7258 r6:df7eb604 r5:00000001
[ 1706.138711]  r4:df7eb600
[ 1706.138767] [<c03afcfc>] (xs_tcp_send_request) from [<c03ad670>] (xprt_transmit+0x58/0x214)
[ 1706.138785]  r10:de92cc60 r9:00000000 r8:d3697fdd r7:df7eb674 r6:de0d7258 r5:df7eb600
[ 1706.138855]  r4:de8e8000
[ 1706.138895] [<c03ad618>] (xprt_transmit) from [<c03aac74>] (call_transmit+0x18c/0x230)
[ 1706.138911]  r7:df7eb600 r6:00000001 r5:df7eb600 r4:de0d7258
[ 1706.138978] [<c03aaae8>] (call_transmit) from [<c03b1ed8>] (__rpc_execute+0x54/0x2c4)
[ 1706.138994]  r8:c0508940 r7:00000000 r6:c03b1f08 r5:00000001 r4:de0d7258
[ 1706.139064] [<c03b1e84>] (__rpc_execute) from [<c03b215c>] (rpc_async_schedule+0x14/0x18)
[ 1706.139080]  r7:00000000 r6:dfbf0800 r5:de92cc60 r4:de0d727c
[ 1706.139152] [<c03b2148>] (rpc_async_schedule) from [<c002c79c>] (process_one_work+0x130/0x3ec)
[ 1706.139176] [<c002c66c>] (process_one_work) from [<c002caa8>] (worker_thread+0x50/0x5ac)
[ 1706.139193]  r10:de92cc60 r9:c0508940 r8:00000008 r7:c050b220 r6:c0508954 r5:de92cc78
[ 1706.139265]  r4:c0508940
[ 1706.139310] [<c002ca58>] (worker_thread) from [<c00319cc>] (kthread+0xc8/0xe4)
[ 1706.139326]  r10:00000000 r9:00000000 r8:00000000 r7:c002ca58 r6:de92cc60 r5:00000000
[ 1706.139396]  r4:de385880
[ 1706.139434] [<c0031904>] (kthread) from [<c000a390>] (ret_from_fork+0x14/0x24)
[ 1706.139450]  r7:00000000 r6:00000000 r5:c0031904 r4:de385880
[ 1706.139498] Mem-Info:
[ 1706.139539] active_anon:2694 inactive_anon:2799 isolated_anon:0
[ 1706.139539]  active_file:43728 inactive_file:71243 isolated_file:0
[ 1706.139539]  unevictable:0 dirty:1486 writeback:0 unstable:0
[ 1706.139539]  slab_reclaimable:3099 slab_unreclaimable:710
[ 1706.139539]  mapped:1763 shmem:19 pagetables:186 bounce:0
[ 1706.139539]  free:290 free_pcp:55 free_cma:0
[ 1706.139630] Normal free:1160kB min:2868kB low:3584kB high:4300kB active_anon:10776kB inactive_anon:11196kB active_file:174912kB inactive_file:284972kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:524288kB managed:514412kB mlocked:0kB dirty:5944kB writeback:0kB mapped:7052kB shmem:76kB slab_reclaimable:12396kB slab_unreclaimable:2840kB kernel_stack:584kB pagetables:744kB unstable:0kB bounce:0kB free_pcp:220kB local_pcp:220kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 1706.139649] lowmem_reserve[]: 0 0
[ 1706.139664] Normal: 80*4kB (UME) 105*8kB (UE) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1160kB
[ 1706.139727] 114997 total pagecache pages
[ 1706.139745] 0 pages in swap cache
[ 1706.139758] Swap cache stats: add 0, delete 0, find 0/0
[ 1706.139768] Free swap  = 1048572kB
[ 1706.139778] Total swap = 1048572kB
[ 1706.139787] 131072 pages RAM
[ 1706.139797] 0 pages HighMem/MovableOnly
[ 1706.139806] 2469 pages reserved
[ 1706.139829] SLUB: Unable to allocate memory on node -1, gfp=0x2080020(GFP_ATOMIC)
[ 1706.139847]   cache: kmalloc-192, object size: 192, buffer size: 192, default order: 0, min order: 0
[ 1706.139862]   node 0: slabs: 12, objs: 252, free: 0

A.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
