Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id D32316B007B
	for <linux-mm@kvack.org>; Fri, 12 Dec 2014 05:39:23 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id i17so5282446qcy.32
        for <linux-mm@kvack.org>; Fri, 12 Dec 2014 02:39:23 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a4si1023752qag.7.2014.12.12.02.39.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Dec 2014 02:39:21 -0800 (PST)
Date: Fri, 12 Dec 2014 11:39:09 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/7] slub: Fastpath optimization (especially for RT) V1
Message-ID: <20141212113909.6747e273@redhat.com>
In-Reply-To: <20141211183758.22e224a0@redhat.com>
References: <20141210163017.092096069@linux.com>
	<20141211183758.22e224a0@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, brouer@redhat.com, Alexander Duyck <alexander.h.duyck@redhat.com>

On Thu, 11 Dec 2014 18:37:58 +0100
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> Warning, I'm getting crashes with this patchset, during my network load testing.
> I don't have a nice crash dump to show, yet, but it is in the slub code.

Crash/OOM during IP-forwarding network overload test[1] with pktgen,
single flow thus activating a single CPU on target (device under test).

Testing done with net-next at commit 52c9b12d380, with patchset applied.
Baseline testing have been done without patchset.

[1] https://github.com/netoptimizer/network-testing/blob/master/pktgen/pktgen02_burst.sh

[  135.258503] console [netcon0] enabled
[  164.970377] ixgbe 0000:04:00.0 eth4: detected SFP+: 5
[  165.078455] ixgbe 0000:04:00.0 eth4: NIC Link is Up 10 Gbps, Flow Control: None
[  165.266662] ixgbe 0000:04:00.1 eth5: detected SFP+: 6
[  165.396958] ixgbe 0000:04:00.1 eth5: NIC Link is Up 10 Gbps, Flow Control: None
[...]
[  290.298350] ksoftirqd/11: page allocation failure: order:0, mode:0x20
[  290.298632] CPU: 11 PID: 64 Comm: ksoftirqd/11 Not tainted 3.18.0-rc7-net-next+ #852
[  290.299109] Hardware name: Supermicro X9DAX/X9DAX, BIOS 3.0a 09/27/2013
[  290.299377]  0000000000000000 ffff88046c4eba28 ffffffff8164f6f2 ffff88047fd6d1a0
[  290.300169]  0000000000000020 ffff88046c4ebab8 ffffffff8111d241 0000000000000000
[  290.300833]  0000003000000000 ffff88047ffd9b38 ffff880003d86400 0000000000000040
[  290.301496] Call Trace:
[  290.301763]  [<ffffffff8164f6f2>] dump_stack+0x4e/0x71
[  290.302035]  [<ffffffff8111d241>] warn_alloc_failed+0xd1/0x130
[  290.302307]  [<ffffffff81120ced>] __alloc_pages_nodemask+0x71d/0xa80
[  290.302572]  [<ffffffff81536b70>] __alloc_page_frag+0x130/0x150
[  290.302840]  [<ffffffff8153b63e>] __alloc_rx_skb+0x5e/0x110
[  290.303112]  [<ffffffff8153b74d>] __napi_alloc_skb+0x1d/0x40
[  290.303383]  [<ffffffffa00f15b1>] ixgbe_clean_rx_irq+0xf1/0x8e0 [ixgbe]
[  290.303655]  [<ffffffffa00f2a7d>] ixgbe_poll+0x41d/0x7c0 [ixgbe]
[  290.303920]  [<ffffffff8154817c>] net_rx_action+0x14c/0x270
[  290.304185]  [<ffffffff8107ad7a>] __do_softirq+0x10a/0x220
[  290.304455]  [<ffffffff8107aeb0>] run_ksoftirqd+0x20/0x50
[  290.304724]  [<ffffffff810962e9>] smpboot_thread_fn+0x159/0x270
[  290.304991]  [<ffffffff81096190>] ? SyS_setgroups+0x180/0x180
[  290.305260]  [<ffffffff81092846>] kthread+0xd6/0xf0
[  290.305525]  [<ffffffff81092770>] ? kthread_create_on_node+0x170/0x170
[  290.305568] rsyslogd invoked oom-killer: gfp_mask=0x201da, order=0, oom_score_adj=0
[  290.305570] rsyslogd cpuset=/ mems_allowed=0
[  290.306534]  [<ffffffff81656a2c>] ret_from_fork+0x7c/0xb0
[  290.306800]  [<ffffffff81092770>] ? kthread_create_on_node+0x170/0x170
[  290.307068] CPU: 1 PID: 2264 Comm: rsyslogd Not tainted 3.18.0-rc7-net-next+ #852
[  290.307553] Hardware name: Supermicro X9DAX/X9DAX, BIOS 3.0a 09/27/2013
[  290.307823]  0000000000000000 ffff88045248f8f8 ffffffff8164f6f2 0000000012a112a1
[  290.308480]  0000000000000000 ffff88045248f978 ffffffff8164c061 ffff88045248f958
[  290.309137]  ffffffff810bd1e9 ffff88045248fa18 ffffffff8112a42b ffff88045248f948
[  290.309805] Call Trace:
[  290.310064]  [<ffffffff8164f6f2>] dump_stack+0x4e/0x71
[  290.310326]  [<ffffffff8164c061>] dump_header.isra.8+0x96/0x201
[  290.310593]  [<ffffffff810bd1e9>] ? rcu_oom_notify+0xd9/0xf0
[  290.310863]  [<ffffffff8112a42b>] ? shrink_zones+0x25b/0x390
[  290.316403]  [<ffffffff8111b4c2>] oom_kill_process+0x202/0x370
[  290.316672]  [<ffffffff8107ee72>] ? has_capability_noaudit+0x12/0x20
[  290.316943]  [<ffffffff8111bcbe>] out_of_memory+0x4ee/0x530
[  290.317212]  [<ffffffff8112100e>] __alloc_pages_nodemask+0xa3e/0xa80
[  290.317480]  [<ffffffff8115d5a7>] alloc_pages_current+0x97/0x120
[  290.317749]  [<ffffffff81117dc7>] __page_cache_alloc+0xa7/0xd0
[  290.318010]  [<ffffffff8111a387>] filemap_fault+0x1c7/0x400
[  290.318278]  [<ffffffff8113da06>] __do_fault+0x36/0xd0
[  290.318544]  [<ffffffff8113fc8f>] do_read_fault.isra.78+0x1bf/0x2c0
[  290.318815]  [<ffffffff810ae1c0>] ? autoremove_wake_function+0x40/0x40
[  290.319083]  [<ffffffff8114128e>] handle_mm_fault+0x67e/0xc20
[  290.319346]  [<ffffffff81042dba>] __do_page_fault+0x18a/0x5a0
[  290.319610]  [<ffffffff810ae180>] ? abort_exclusive_wait+0xa0/0xa0
[  290.319877]  [<ffffffff810431dc>] do_page_fault+0xc/0x10
[  290.320142]  [<ffffffff81658062>] page_fault+0x22/0x30
[  290.320441] Mem-Info:
[  290.320703] Node 0 DMA per-cpu:
[  290.321011] CPU    0: hi:    0, btch:   1 usd:   0
[  290.321272] CPU    1: hi:    0, btch:   1 usd:   0
[  290.321532] CPU    2: hi:    0, btch:   1 usd:   0
[  290.321792] CPU    3: hi:    0, btch:   1 usd:   0
[  290.322055] CPU    4: hi:    0, btch:   1 usd:   0
[  290.322319] CPU    5: hi:    0, btch:   1 usd:   0
[  290.322581] CPU    6: hi:    0, btch:   1 usd:   0
[  290.322845] CPU    7: hi:    0, btch:   1 usd:   0
[  290.323108] CPU    8: hi:    0, btch:   1 usd:   0
[  290.323367] CPU    9: hi:    0, btch:   1 usd:   0
[  290.323625] CPU   10: hi:    0, btch:   1 usd:   0
[  290.323885] CPU   11: hi:    0, btch:   1 usd:   0
[  290.324143] Node 0 DMA32 per-cpu:
[  290.324445] CPU    0: hi:  186, btch:  31 usd:   0
[  290.324704] CPU    1: hi:  186, btch:  31 usd:   0
[  290.324962] CPU    2: hi:  186, btch:  31 usd:   0
[  290.325227] CPU    3: hi:  186, btch:  31 usd:   0
[  290.325488] CPU    4: hi:  186, btch:  31 usd:   0
[  290.325753] CPU    5: hi:  186, btch:  31 usd:   0
[  290.326016] CPU    6: hi:  186, btch:  31 usd:   0
[  290.326279] CPU    7: hi:  186, btch:  31 usd:   0
[  290.326546] CPU    8: hi:  186, btch:  31 usd:   0
[  290.326811] CPU    9: hi:  186, btch:  31 usd:   0
[  290.327075] CPU   10: hi:  186, btch:  31 usd:   0
[  290.327344] CPU   11: hi:  186, btch:  31 usd:   0
[  290.327609] Node 0 Normal per-cpu:
[  290.327916] CPU    0: hi:  186, btch:  31 usd:  25
[  290.328179] CPU    1: hi:  186, btch:  31 usd:   0
[  290.328444] CPU    2: hi:  186, btch:  31 usd:   0
[  290.328708] CPU    3: hi:  186, btch:  31 usd:   0
[  290.328969] CPU    4: hi:  186, btch:  31 usd:   0
[  290.329230] CPU    5: hi:  186, btch:  31 usd:   0
[  290.329491] CPU    6: hi:  186, btch:  31 usd:   0
[  290.329753] CPU    7: hi:  186, btch:  31 usd:   0
[  290.330014] CPU    8: hi:  186, btch:  31 usd:   0
[  290.330275] CPU    9: hi:  186, btch:  31 usd:   0
[  290.330536] CPU   10: hi:  186, btch:  31 usd:   0
[  290.330801] CPU   11: hi:  186, btch:  31 usd:   0
[  290.331066] active_anon:109 inactive_anon:0 isolated_anon:0
[  290.331066]  active_file:132 inactive_file:104 isolated_file:0
[  290.331066]  unevictable:2141 dirty:0 writeback:0 unstable:0
[  290.331066]  free:26484 slab_reclaimable:3264 slab_unreclaimable:3985491
[  290.331066]  mapped:1957 shmem:17 pagetables:618 bounce:0
[  290.331066]  free_cma:0
[  290.332411] Node 0 DMA free:15856kB min:64kB low:80kB high:96kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15972kB managed:15888kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[  290.333825] lowmem_reserve[]: 0 1917 15995 15995
[  290.334317] Node 0 DMA32 free:64740kB min:8092kB low:10112kB high:12136kB active_anon:296kB inactive_anon:0kB active_file:136kB inactive_file:32kB unevictable:1940kB isolated(anon):0kB isolated(file):0kB present:2042792kB managed:1964512kB mlocked:1956kB dirty:0kB writeback:0kB mapped:1516kB shmem:0kB slab_reclaimable:1436kB slab_unreclaimable:1864332kB kernel_stack:144kB pagetables:460kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:25708 all_unreclaimable? yes
[  290.335947] lowmem_reserve[]: 0 0 14077 14077
[  290.336439] Node 0 Normal free:24532kB min:59424kB low:74280kB high:89136kB active_anon:140kB inactive_anon:0kB active_file:392kB inactive_file:384kB unevictable:6624kB isolated(anon):0kB isolated(file):0kB present:14680064kB managed:14415676kB mlocked:6624kB dirty:0kB writeback:0kB mapped:6312kB shmem:68kB slab_reclaimable:11620kB slab_unreclaimable:14078392kB kernel_stack:2864kB pagetables:2012kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  290.338061] lowmem_reserve[]: 0 0 0 0
[  290.338546] Node 0 DMA: 0*4kB 0*8kB 1*16kB (U) 1*32kB (U) 1*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15856kB
[  290.339996] Node 0 DMA32: 473*4kB (UEM) 221*8kB (UEM) 116*16kB (UEM) 86*32kB (UEM) 55*64kB (UEM) 24*128kB (UEM) 12*256kB (UM) 3*512kB (EM) 1*1024kB (E) 2*2048kB (UR) 10*4096kB (MR) = 65548kB
[  290.341804] Node 0 Normal: 994*4kB (UEM) 577*8kB (EM) 203*16kB (EM) 113*32kB (UEM) 47*64kB (UEM) 13*128kB (UM) 4*256kB (UM) 0*512kB 0*1024kB 0*2048kB 1*4096kB (R) = 25248kB
[  290.343466] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  290.343947] 2081 total pagecache pages
[  290.344210] 13 pages in swap cache
[  290.344473] Swap cache stats: add 4436, delete 4423, find 5/8
[  290.344739] Free swap  = 8198904kB
[  290.345000] Total swap = 8216572kB
[  290.345262] 4184707 pages RAM
[  290.345523] 0 pages HighMem/MovableOnly
[  290.345788] 85688 pages reserved
[  290.346049] 0 pages hwpoisoned
[  290.346307] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
[  290.346788] [  680]     0   680     2678      264       9      107         -1000 udevd
[  290.347267] [ 1833]     0  1833    10161        0      24       70             0 monitor
[  290.347750] [ 1834]     0  1834    10196      517      27      131             0 ovsdb-server
[  290.348230] [ 1844]     0  1844    10299       50      24       67             0 monitor
[  290.348711] [ 1845]     0  1845    10338     2114      41        0             0 ovs-vswitchd
[  290.349194] [ 2261]     0  2261    62333      386      22      139             0 rsyslogd
[  290.349676] [ 2293]    81  2293     5366      344      13       69             0 dbus-daemon
[  290.350157] [ 2315]    68  2315     9070      403      29      313             0 hald
[  290.350632] [ 2316]     0  2316     5097      339      23       45             0 hald-runner
[  290.351111] [ 2345]     0  2345     5627        0      25       42             0 hald-addon-inpu
[  290.351594] [ 2354]    68  2354     4498      339      20       37             0 hald-addon-acpi
[  290.352069] [ 2363]     0  2363     2677      256       9      106         -1000 udevd
[  290.352540] [ 2471]     0  2471    30430      129      18      558             0 pmqos-static.py
[  290.353011] [ 2486]     0  2486    16672      368      33      179         -1000 sshd
[  290.353481] [ 2497]     0  2497    44314      550      61     1064             0 tuned
[  290.353956] [ 2511]     0  2511    29328      363      16      152             0 crond
[  290.354430] [ 2528]     0  2528     5400        0      14       46             0 atd
[  290.354906] [ 2541]     0  2541    26020      228      12       28             0 rhsmcertd
[  290.355386] [ 2562]     0  2562     1031      308       9       18             0 mingetty
[  290.355858] [ 2564]     0  2564     1031      308       9       18             0 mingetty
[  290.356336] [ 2566]     0  2566     1031      308       9       17             0 mingetty
[  290.356813] [ 2568]     0  2568     1031      308       9       18             0 mingetty
[  290.357291] [ 2570]     0  2570     1031      308       9       18             0 mingetty
[  290.357766] [ 2571]     0  2571     2677      256       9      106         -1000 udevd
[  290.358245] [ 2573]     0  2573     1031      308       9       18             0 mingetty
[  290.358719] [ 2576]     0  2576    25109      985      52      212             0 sshd
[  290.359196] [ 2598]   500  2598    25109      695      50      235             0 sshd
[  290.359673] [ 2611]   500  2611    27820      348      19      806             0 bash
[  290.360147] Out of memory: Kill process 1845 (ovs-vswitchd) score 0 or sacrifice child
[  290.360624] Killed process 1845 (ovs-vswitchd) total-vm:41352kB, anon-rss:732kB, file-rss:7724kB
[  290.450766] ksoftirqd/11: page allocation failure: order:0, mode:0x204020
[  290.451031] ksoftirqd/11: page allocation failure: order:0, mode:0x204020
[  290.451033] CPU: 11 PID: 64 Comm: ksoftirqd/11 Not tainted 3.18.0-rc7-net-next+ #852
[  290.451033] Hardware name: Supermicro X9DAX/X9DAX, BIOS 3.0a 09/27/2013
[  290.451034]  0000000000000000 ffff88046c4eb2e8 ffffffff8164f6f2 0000000014801480
[  290.451035]  0000000000204020 ffff88046c4eb378 ffffffff8111d241 0000000000000000
[  290.451036]  0000003000000000 ffff88047ffd9b38 0000000000000001 0000000000000040
[  290.451037] Call Trace:
[  290.451040]  [<ffffffff8164f6f2>] dump_stack+0x4e/0x71
[  290.451042]  [<ffffffff8111d241>] warn_alloc_failed+0xd1/0x130
[  290.451045]  [<ffffffff81137c89>] ? compaction_suitable+0x19/0x20
[  290.451046]  [<ffffffff81120ced>] __alloc_pages_nodemask+0x71d/0xa80
[  290.451049]  [<ffffffff81348aea>] ? vsnprintf+0x3ba/0x590
[  290.451052]  [<ffffffff8115d5a7>] alloc_pages_current+0x97/0x120
[  290.451054]  [<ffffffff8116563d>] new_slab+0x2ad/0x310
[  290.451056]  [<ffffffff811660e7>] __slab_alloc.isra.63+0x207/0x4d0
[  290.451057]  [<ffffffff8116645b>] kmem_cache_alloc_node+0xab/0x110
[  290.451059]  [<ffffffff81536e47>] __alloc_skb+0x47/0x1d0
[  290.451063]  [<ffffffff8138f5a1>] ? vgacon_set_cursor_size.isra.7+0xa1/0x120
[  290.451066]  [<ffffffff815636c4>] netpoll_send_udp+0x84/0x3f0
[  290.451068]  [<ffffffffa028b8bf>] write_msg+0xcf/0x140 [netconsole]
[  290.451070]  [<ffffffff810b3edb>] call_console_drivers.constprop.24+0x9b/0xa0
[  290.451071]  [<ffffffff810b452d>] console_unlock+0x36d/0x450
[  290.451072]  [<ffffffff810b4960>] vprintk_emit+0x350/0x570
[  290.451073]  [<ffffffff8164be24>] printk+0x5c/0x5e
[  290.451075]  [<ffffffff8111d23c>] warn_alloc_failed+0xcc/0x130
[  290.451077]  [<ffffffff8154987c>] ? dev_hard_start_xmit+0x16c/0x320
[  290.451079]  [<ffffffff81120ced>] __alloc_pages_nodemask+0x71d/0xa80
[  290.451081]  [<ffffffff81567c22>] ? sch_direct_xmit+0x112/0x220
[  290.451083]  [<ffffffff8115d5a7>] alloc_pages_current+0x97/0x120
[  290.451084]  [<ffffffff8116563d>] new_slab+0x2ad/0x310
[  290.451085]  [<ffffffff811660e7>] __slab_alloc.isra.63+0x207/0x4d0
[  292.302602] hald-addon-acpi invoked oom-killer: gfp_mask=0x201da, order=0, oom_score_adj=0
[  292.303094] hald-addon-acpi cpuset=/ mems_allowed=0
[  292.303456] CPU: 4 PID: 2354 Comm: hald-addon-acpi Not tainted 3.18.0-rc7-net-next+ #852
[  292.303939] Hardware name: Supermicro X9DAX/X9DAX, BIOS 3.0a 09/27/2013
[  292.304209]  0000000000000000 ffff88044f2af8f8 ffffffff8164f6f2 00000000000038ce
[  292.304884]  0000000000000000 ffff88044f2af978 ffffffff8164c061 ffff88044f2af958
[  292.305560]  ffffffff810bd1e9 ffff88044f2afa18 ffffffff8112a42b ffff88044f2af948
[  292.306231] Call Trace:
[  292.306497]  [<ffffffff8164f6f2>] dump_stack+0x4e/0x71
[  292.306768]  [<ffffffff8164c061>] dump_header.isra.8+0x96/0x201
[  292.307038]  [<ffffffff810bd1e9>] ? rcu_oom_notify+0xd9/0xf0
[  292.307305]  [<ffffffff8112a42b>] ? shrink_zones+0x25b/0x390
[  292.307577]  [<ffffffff8111b4c2>] oom_kill_process+0x202/0x370
[  292.307846]  [<ffffffff8107ee72>] ? has_capability_noaudit+0x12/0x20
[  292.308117]  [<ffffffff8111bcbe>] out_of_memory+0x4ee/0x530
[  292.308386]  [<ffffffff8112100e>] __alloc_pages_nodemask+0xa3e/0xa80
[  292.308659]  [<ffffffff8115d5a7>] alloc_pages_current+0x97/0x120
[  292.308930]  [<ffffffff81117dc7>] __page_cache_alloc+0xa7/0xd0
[  292.309200]  [<ffffffff8111a387>] filemap_fault+0x1c7/0x400
[  292.309470]  [<ffffffff8113da06>] __do_fault+0x36/0xd0
[  292.309740]  [<ffffffff8113fc8f>] do_read_fault.isra.78+0x1bf/0x2c0
[  292.310010]  [<ffffffff8114128e>] handle_mm_fault+0x67e/0xc20
[  292.310280]  [<ffffffff810970d5>] ? finish_task_switch+0x45/0xf0
[  292.310551]  [<ffffffff81042dba>] __do_page_fault+0x18a/0x5a0
[  292.310821]  [<ffffffff816559d2>] ? do_nanosleep+0x92/0xe0
[  292.311087]  [<ffffffff810c4d88>] ? hrtimer_nanosleep+0xb8/0x1a0
[  292.311353]  [<ffffffff810c3e90>] ? hrtimer_get_res+0x50/0x50
[  292.311618]  [<ffffffff810431dc>] do_page_fault+0xc/0x10
[  292.311884]  [<ffffffff81658062>] page_fault+0x22/0x30
[  292.312145] Mem-Info:
[  292.312403] Node 0 DMA per-cpu:
[  292.312714] CPU    0: hi:    0, btch:   1 usd:   0
[  292.312977] CPU    1: hi:    0, btch:   1 usd:   0
[  292.313241] CPU    2: hi:    0, btch:   1 usd:   0
[  292.313505] CPU    3: hi:    0, btch:   1 usd:   0
[  292.313772] CPU    4: hi:    0, btch:   1 usd:   0
[  292.314038] CPU    5: hi:    0, btch:   1 usd:   0
[  292.314304] CPU    6: hi:    0, btch:   1 usd:   0
[  292.314571] CPU    7: hi:    0, btch:   1 usd:   0
[  292.314840] CPU    8: hi:    0, btch:   1 usd:   0
[  292.315107] CPU    9: hi:    0, btch:   1 usd:   0
[  292.315372] CPU   10: hi:    0, btch:   1 usd:   0
[  292.315640] CPU   11: hi:    0, btch:   1 usd:   0
[  292.315905] Node 0 DMA32 per-cpu:
[  292.316219] CPU    0: hi:  186, btch:  31 usd:   0
[  292.316487] CPU    1: hi:  186, btch:  31 usd:   0
[  292.316754] CPU    2: hi:  186, btch:  31 usd:   0
[  292.317019] CPU    3: hi:  186, btch:  31 usd:   0
[  292.317284] CPU    4: hi:  186, btch:  31 usd:   0
[  292.317553] CPU    5: hi:  186, btch:  31 usd:   0
[  292.317819] CPU    6: hi:  186, btch:  31 usd:   0
[  292.318086] CPU    7: hi:  186, btch:  31 usd:   0
[  292.318352] CPU    8: hi:  186, btch:  31 usd:   0
[  292.318623] CPU    9: hi:  186, btch:  31 usd:   0
[  292.318892] CPU   10: hi:  186, btch:  31 usd:   0
[  292.319161] CPU   11: hi:  186, btch:  31 usd:   0
[  292.319427] Node 0 Normal per-cpu:
[  292.319742] CPU    0: hi:  186, btch:  31 usd:   2
[  292.320009] CPU    1: hi:  186, btch:  31 usd:   0
[  292.320275] CPU    2: hi:  186, btch:  31 usd:   0
[  292.320542] CPU    3: hi:  186, btch:  31 usd:   0
[  292.320811] CPU    4: hi:  186, btch:  31 usd:   0
[  292.321079] CPU    5: hi:  186, btch:  31 usd:   0
[  292.321346] CPU    6: hi:  186, btch:  31 usd:   0
[  292.321614] CPU    7: hi:  186, btch:  31 usd:   0
[  292.321880] CPU    8: hi:  186, btch:  31 usd:   0
[  292.322146] CPU    9: hi:  186, btch:  31 usd:   0
[  292.322412] CPU   10: hi:  186, btch:  31 usd:   0
[  292.322681] CPU   11: hi:  186, btch:  31 usd:   0
[  292.322947] active_anon:0 inactive_anon:2 isolated_anon:0
[  292.322947]  active_file:81 inactive_file:42 isolated_file:0
[  292.322947]  unevictable:0 dirty:0 writeback:0 unstable:0
[  292.322947]  free:24558 slab_reclaimable:3128 slab_unreclaimable:3989981
[  292.322947]  mapped:39 shmem:0 pagetables:577 bounce:0
[  292.322947]  free_cma:0
[  292.324305] Node 0 DMA free:15856kB min:64kB low:80kB high:96kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15972kB managed:15888kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[  292.325716] lowmem_reserve[]: 0 1917 15995 15995
[  292.326216] Node 0 DMA32 free:59736kB min:8092kB low:10112kB high:12136kB active_anon:0kB inactive_anon:0kB active_file:84kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2042792kB managed:1964512kB mlocked:0kB dirty:0kB writeback:0kB mapped:156kB shmem:0kB slab_reclaimable:1356kB slab_unreclaimable:1872080kB kernel_stack:144kB pagetables:304kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:820 all_unreclaimable? yes
[  292.327636] lowmem_reserve[]:Normal free:22900kB min:59424kB low:74280kB high:89136kB active_anon:0kB inactive_anon:8kB active_file:240kB inactive_file:200kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:14680064kB managed:14415676kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:11156kB slab_unreclaimable:14087812kB kernel_stack:2848kB pagetables:2004kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:3288 all_unreclaimable? yes
[  292.360844] monitor invoked oom-killer: gfp_mask=0x201da, order=0, oom_score_adj=0
[  292.361326] monitor cpuset=/ mems_allowed=0
[  292.361687] CPU: 1 PID: 1844 Comm: monitor Not tainted 3.18.0-rc7-net-next+ #852
[  292.362162] Hardware name: Supermicro X9DAX/X9DAX, BIOS 3.0a 09/27/2013
[  292.362429]  0000000000000000 ffff880456aef8f8 ffffffff8164f6f2 0000000000003cf9
[  292.363095]  0000000000000000 ffff880456aef978 ffffffff8164c061 ffff880456aef958
[  292.363764]  ffffffff810bd1e9 ffff880456aefa18 ffffffff8112a42b ffff880456aef988
[  292.364433] Call Trace:
[  292.364695]  [<ffffffff8164f6f2>] dump_stack+0x4e/0x71
[  292.381944] active_anon:0 inactive_anon:2 isolated_anon:0
[  292.381944]  active_file:81 inactive_file:42 isolated_file:0
[  292.381944]  unevictable:0 dirty:0 writeback:0 unstable:0
[  292.381944]  free:24864 slab_reclaimable:3128 slab_unreclaimable:3989981
[  292.381944]  mapped:39 shmem:0 pagetables:577 bounce:0
[  292.381944]  free_cma:0
DMA free:15856kB min:64kB low:80kB high:96kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15972kB managed:15888kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
DMA32 free:60068kB min:8092kB low:10112kB high:12136kB active_anon:0kB inactive_anon:0kB active_file:84kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2042792kB managed:1964512kB mlocked:0kB dirty:0kB writeback:0kB mapped:156kB shmem:0kB slab_reclaimable:1356kB slab_unreclaimable:1872080kB kernel_stack:144kB pagetables:304kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:516 all_unreclaimable? yes
Normal free:23532kB min:59424kB low:74280kB high:89136kB active_anon:0kB inactive_anon:8kB active_file:240kB inactive_file:200kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:14680064kB managed:14415676kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:11156kB slab_unreclaimable:14087812kB kernel_stack:2848kB pagetables:2004kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:3240 all_unreclaimable? yes
[  292.419725] ovsdb-server invoked oom-killer: gfp_mask=0x200da, order=0, oom_score_adj=0
[  292.420210] ovsdb-server cpuset=/ mems_allowed=0
[  292.420570] CPU: 2 PID: 1834 Comm: ovsdb-server Not tainted 3.18.0-rc7-net-next+ #852
[  292.421053] Hardware name: Supermicro X9DAX/X9DAX, BIOS 3.0a 09/27/2013
[  292.421320]  0000000000000000[  292.440836] active_anon:0 inactive_anon:2 isolated_anon:0
[  292.440836]  active_file:81 inactive_file:42 isolated_file:0
[  292.440836]  unevictable:0 dirty:0 writeback:0 unstable:0
[  292.440836]  free:24864 slab_reclaimable:3128 slab_unreclaimable:3989981
[  292.440836]  mapped:39 shmem:0 pagetables:577 bounce:0
[  292.440836]  free_cma:0
DMA free:15856kB min:64kB low:80kB high:96kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15972kB managed:15888kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
DMA32 free:60068kB min:8092kB low:10112kB high:12136kB active_anon:0kB inactive_anon:0kB active_file:84kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2042792kB managed:1964512kB mlocked:0kB dirty:0kB writeback:0kB mapped:156kB shmem:0kB slab_reclaimable:1356kB slab_unreclaimable:1872080kB kernel_stack:144kB pagetables:304kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:516 all_unreclaimable? yes
Normal free:23532kB min:59424kB low:74280kB high:89136kB active_anon:0kB inactive_anon:8kB active_file:240kB inactive_file:200kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:14680064kB managed:14415676kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:11156kB slab_unreclaimable:14087812kB kernel_stack:2848kB pagetables:2004kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:3240 all_unreclaimable? yes
[  292.502168] active_anon:0 inactive_anon:2 isolated_anon:0
[  292.502168]  active_file:81 inactive_file:42 isolated_file:0
[  292.502168]  unevictable:0 dirty:0 writeback:0 unstable:0
[  292.502168]  free:24864 slab_reclaimable:3128 slab_unreclaimable:3989981
[  292.502168]  mapped:39 shmem:0 pagetables:577 bounce:0
[  292.502168]  free_cma:0
DMA free:15856kB min:64kB low:80kB high:96kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15972kB managed:15888kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
DMA32 free:60068kB min:8092kB low:10112kB high:12136kB active_anon:0kB inactive_anon:0kB active_file:84kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2042792kB managed:1964512kB mlocked:0kB dirty:0kB writeback:0kB mapped:156kB shmem:0kB slab_reclaimable:1356kB slab_unreclaimable:1872080kB kernel_stack:144kB pagetables:304kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:516 all_unreclaimable? yes
Normal free:23532kB min:59424kB low:74280kB high:89136kB active_anon:0kB inactive_anon:8kB active_file:240kB inactive_file:200kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:14680064kB managed:14415676kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:11156kB slab_unreclaimable:14087812kB kernel_stack:2848kB pagetables:2004kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:3240 all_unreclaimable? yes
[  292.539902] hald invoked oom-killer: gfp_mask=0x200da, order=0, oom_score_adj=0
[  292.540379] hald cpuset=/ mems_allowed=0
[  292.540736] CPU: 9 PID: 2315 Comm: hald Not tainted 3.18.0-rc7-net-next+ #852
[  292.541004] Hardware name: Supermicro X9DAX/X9DAX, BIOS 3.0a 09/27/2013
[  292.541266]  0000000000000000 ffff88044f8eb4a8 ffffffff8164f6f2 0000000000004977
[  292.541934]  0000000000000000 ffff88044f8eb528 ffffffff8164c061 ffff88044f8eb508
[  292.542600]  ffffffff810bd1e9 ffff88044f8eb5c8 ffffffff8112a42b ffff88044f8eb4f8
[  292.543265] Call Trace:
[  292.543530]  [<ffffffff8164f6f2>] dump_stack+0x4e/0x71
[  292.543797]  [<ffffffff8164c061>] dump_header.isra.8+0x96/0x201
[  292.544064]  [<ffffffff810bd1e9>] ? rcu_oom_notify+0xd9/0xf0
[  292.544331]  [<ffffffff8112a42b>] ? shrink_zones+0x25b/0x390
[  292.544597]  [<ffffffff8111b4c2>] oom_kill_process+0x202/0x370
[  292.544867]  [<ffffffff8111aff5>] ? oom_unkillable_task.isra.5+0xc5/0xf0
[  292.545134]  [<ffffffff8111bcbe>] out_of_memory+0x4ee/0x530
[  292.545399]  [<ffffffff8112100e>] __alloc_pages_nodemask+0xa3e/0xa80
[  292.545664]  [<ffffffff8115fa1f>] alloc_pages_vma+0x9f/0x1b0
[  292.545934]  [<ffffffff8115283b>] read_swap_cache_async+0x13b/0x1e0
[  292.546202]  [<ffffffff81152a06>] swapin_readahead+0x126/0x190
[  292.546467]  [<ffffffff81118ada>] ? pagecache_get_page+0x2a/0x1e0
[  292.564580] active_anon:0 inactive_anon:2 isolated_anon:0
[  292.564580]  active_file:81 inactive_file:42 isolated_file:0
[  292.564580]  unevictable:0 dirty:0 writeback:0 unstable:0
[  292.564580]  free:24864 slab_reclaimable:3128 slab_unreclaimable:3989981
[  292.564580]  mapped:39 shmem:0 pagetables:480 bounce:0
[  292.564580]  free_cma:0
DMA free:15856kB min:64kB low:80kB high:96kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15972kB managed:15888kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
DMA32 free:60068kB min:8092kB low:10112kB high:12136kB active_anon:0kB inactive_anon:0kB active_file:84kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2042792kB managed:1964512kB mlocked:0kB dirty:0kB writeback:0kB mapped:156kB shmem:0kB slab_reclaimable:1356kB slab_unreclaimable:1872080kB kernel_stack:144kB pagetables:304kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:516 all_unreclaimable? yes
Normal free:23532kB min:59424kB low:74280kB high:89136kB active_anon:0kB inactive_anon:8kB active_file:240kB inactive_file:200kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:14680064kB managed:14415676kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:11156kB slab_unreclaimable:14087812kB kernel_stack:2848kB pagetables:1616kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:3240 all_unreclaimable? yes

[  293.207640] Call Trace:
[  293.207903]  [<ffffffff8164f6f2>] dump_stack+0x4e/0x71
[  293.208166]  [<ffffffff8164c061>] dump_header.isra.8+0x96/0x201
[  293.208431]  [<ffffffff810bd1e9>] ? rcu_oom_notify+0xd9/0xf0
[  293.208696]  [<ffffffff8112a42b>] ? shrink_zones+0x25b/0x390
[  293.208963]  [<ffffffff8111b4c2>] oom_kill_process+0x202/0x370
[  293.209232]  [<ffffffff8111aff5>] ? oom_unkillable_task.isra.5+0xc5/0xf0
[  293.209500]  [<ffffffff8111bcbe>] out_of_memory+0x4ee/0x530
[  293.209761]  [<ffffffff8112100e>] __alloc_pages_nodemask+0xa3e/0xa80
[  293.210029]  [<ffffffff8115fa1f>] alloc_pages_vma+0x9f/0x1b0
[  293.210297]  [<ffffffff8115283b>] read_swap_cache_async+0x13b/0x1e0
[  293.210562]  [<ffffffff81152a06>] swapin_readahead+0x126/0x190
[  293.210828]  [<ffffffff81118ada>] ? pagecache_get_page+0x2a/0x1e0
[  293.211092]  [<ffffffff811415d8>] handle_mm_fault+0x9c8/0xc20
[  293.211357]  [<ffffffff810a364f>] ? dequeue_entity+0x10f/0x600
[  293.211626]  [<ffffffff81042dba>] __do_page_fault+0x18a/0x5a0
[  293.211892]  [<ffffffff810970d5>] ? finish_task_switch+0x45/0xf0
[  293.212156]  [<ffffffff81651070>] ? __schedule+0x290/0x7f0
[  293.212416]  [<ffffffff810431dc>] do_page_fault+0xc/0x10
[  293.212676]  [<ffffffff81658062>] page_fault+0x22/0x30
[  293.212937]  [<ffffffff8118b189>] ? do_sys_poll+0x179/0x5b0
[  293.213196]  [<ffffffff8118b13d>] ? do_sys_poll+0x12d/0x5b0
[  293.213459]  [<ffffffff815ead03>] ? unix_stream_sendmsg+0x413/0x450
[  293.213724]  [<ffffffff81189f00>] ? poll_select_copy_remaining+0x140/0x140
[  293.213992]  [<ffffffff81189f00>] ? poll_select_copy_remaining+0x140/0x140
[  293.214259]  [<ffffffff81189f00>] ? poll_select_copy_remaining+0x140/0x140
[  293.214528]  [<ffffffff81189f00>] ? poll_select_copy_remaining+0x140/0x140
[  293.214792]  [<ffffffff81189f00>] ? poll_select_copy_remaining+0x140/0x140
[  293.215056]  [<ffffffff81189f00>] ? poll_select_copy_remaining+0x140/0x140
[  293.215321]  [<ffffffff8117ac45>] ? SYSC_newfstat+0x25/0x30
[  293.215586]  [<ffffffff8118b697>] SyS_poll+0x77/0x100
[  293.215851]  [<ffffffff81656ad2>] system_call_fastpath+0x12/0x17
[  293.216115] Mem-Info:
[  293.216374] Node 0 DMA per-cpu:
[  293.216685] CPU    0: hi:    0, btch:   1 usd:   0
[  293.216948] CPU    1: hi:    0, btch:   1 usd:   0
[  293.217209] CPU    2: hi:    0, btch:   1 usd:   0
[  293.217473] CPU    3: hi:    0, btch:   1 usd:   0
[  293.217734] CPU    4: hi:    0, btch:   1 usd:   0
[  293.217999] CPU    5: hi:    0, btch:   1 usd:   0
[  293.218261] CPU    6: hi:    0, btch:   1 usd:   0
[  293.218525] CPU    7: hi:    0, btch:   1 usd:   0
[  293.218787] CPU    8: hi:    0, btch:   1 usd:   0
[  293.219051] CPU    9: hi:    0, btch:   1 usd:   0
[  293.219314] CPU   10: hi:    0, btch:   1 usd:   0
[  293.219580] CPU   11: hi:    0, btch:   1 usd:   0
[  293.219843] Node 0 DMA32 per-cpu:
[  293.220149] CPU    0: hi:  186, btch:  31 usd:   0
[  293.220411] CPU    1: hi:  186, btch:  31 usd:   0
[  293.220677] CPU    2: hi:  186, btch:  31 usd:   0
[  293.220940] CPU    3: hi:  186, btch:  31 usd:   0
[  293.221203] CPU    4: hi:  186, btch:  31 usd:   0
[  293.221467] CPU    5: hi:  186, btch:  31 usd:   0
[  293.221730] CPU    6: hi:  186, btch:  31 usd:   0
[  293.221992] CPU    7: hi:  186, btch:  31 usd:   0
[  293.222253] CPU    8: hi:  186, btch:  31 usd:   0
[  293.222519] CPU    9: hi:  186, btch:  31 usd:   0
[  293.222782] CPU   10: hi:  186, btch:  31 usd:   0
[  293.223043] CPU   11: hi:  186, btch:  31 usd:   0
[  293.223306] Node 0 Normal per-cpu:
[  293.223615] CPU    0: hi:  186, btch:  31 usd:   0
[  293.223878] CPU    1: hi:  186, btch:  31 usd:   0
[  293.224142] CPU    2: hi:  186, btch:  31 usd:   0
[  293.224404] CPU    3: hi:  186, btch:  31 usd:   0
[  293.224672] CPU    4: hi:  186, btch:  31 usd:   0
[  293.224934] CPU    5: hi:  186, btch:  31 usd:   0
[  293.225198] CPU    6: hi:  186, btch:  31 usd:   0
[  293.225462] CPU    7: hi:  186, btch:  31 usd:   0
[  293.225726] CPU    8: hi:  186, btch:  31 usd:   0
[  293.225989] CPU    9: hi:  186, btch:  31 usd:   0
[  293.226249] CPU   10: hi:  186, btch:  31 usd:   0
[  293.226507] CPU   11: hi:  186, btch:  31 usd:   0
[  293.226769] active_anon:0 inactive_anon:0 isolated_anon:0
[  293.226769]  active_file:148 inactive_file:26 isolated_file:0
[  293.226769]  unevictable:0 dirty:0 writeback:0 unstable:0
[  293.226769]  free:25182 slab_reclaimable:3095 slab_unreclaimable:3990011
[  293.226769]  mapped:17 shmem:0 pagetables:427 bounce:0
[  293.226769]  free_cma:0
[  293.228100] Node 0 DMA free:15856kB min:64kB low:80kB high:96kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15972kB managed:15888kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[  293.229516] lowmem_reserve[]: 0 1917 15995 15995
[  293.230008] Node 0 DMA32 free:60388kB min:8092kB low:10112kB high:12136kB active_anon:0kB inactive_anon:0kB active_file:84kB inactive_file:48kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2042792kB managed:1964512kB mlocked:0kB dirty:0kB writeback:0kB mapped:68kB shmem:0kB slab_reclaimable:1356kB slab_unreclaimable:1872156kB kernel_stack:144kB pagetables:232kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:5548 all_unreclaimable? yes
[  293.236698] lowmem_reserve[]: 0 0 14077 14077
[  293.237185] Node 0 Normal free:24484kB min:59424kB low:74280kB high:89136kB active_anon:0kB inactive_anon:0kB active_file:508kB inactive_file:56kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:14680064kB managed:14415676kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:11024kB slab_unreclaimable:14087856kB kernel_stack:2832kB pagetables:1476kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:3904 all_unreclaimable? yes
[  293.238816] lowmem_reserve[]: 0 0 0 0
[  293.239309] Node 0 DMA: 0*4kB 0*8kB 1*16kB (U) 1*32kB (U) 1*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15856kB
[  293.240758] Node 0 DMA32: 408*4kB (UEM) 43*8kB (UEM) 23*16kB (EM) 20*32kB (EM) 17*64kB (EM) 10*128kB (UEM) 9*256kB (UM) 5*512kB (EM) 3*1024kB (EM) 3*2048kB (MR) 10*4096kB (MR) = 60392kB
[  293.242558] Node 0 Normal: 912*4kB (UEM) 585*8kB (UEM) 193*16kB (UEM) 100*32kB (UEM) 46*64kB (UEM) 16*128kB (M) 3*256kB (UM) 0*512kB 0*1024kB 0*2048kB 1*4096kB (R) = 24472kB
[  293.244228] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  293.244707] 172 total pagecache pages
[  293.244964] 0 pages in swap cache
[  293.245226] Swap cache stats: add 4615, delete 4615, find 2631/2669
[  293.245492] Free swap  = 8209840kB
[  293.245751] Total swap = 8216572kB
[  293.246012] 4184707 pages RAM
[  293.246272] 0 pages HighMem/MovableOnly
[  293.246535] 85688 pages reserved
[  293.246797] 0 pages hwpoisoned
[  293.247059] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
[  293.247544] [  680]     0   680     2678        0       9      107         -1000 udevd
[  293.248022] [ 1833]     0  1833    10161        0      24       70             0 monitor
[  293.248502] [ 1834]     0  1834    10196        0      27      131             0 ovsdb-server
[  293.248984] [ 1844]     0  1844    10299        0      24       82             0 monitor
[  293.249467] [ 2261]     0  2261    62333        0      22      143             0 rsyslogd
[  293.249949] [ 2293]    81  2293     5366        1      13       69             0 dbus-daemon
[  293.250431] [ 2345]     0  2345     5627        0      25       42             0 hald-addon-inpu
[  293.250912] [ 2354]    68  2354     4498        1      20       37             0 hald-addon-acpi
[  293.251396] [ 2363]     0  2363     2677        0       9      106         -1000 udevd
[  293.251870] [ 2486]     0  2486    16672        0      33      179         -1000 sshd
[  293.252346] [ 2511]     0  2511    29328        1      16      152             0 crond
[  293.252825] [ 2528]     0  2528     5400        0      14       46             0 atd
[  293.253304] [ 2541]     0  2541    26020        1      12       28             0 rhsmcertd
[  293.253787] [ 2562]     0  2562     1031        1       9       18             0 mingetty
[  293.254267] [ 2564]     0  2564     1031        1       9       18             0 mingetty
[  293.254747] [ 2566]     0  2566     1031        1       9       17             0 mingetty
[  293.255218] [ 2568]     0  2568     1031        1       9       18             0 mingetty
[  293.255688] [ 2570]     0  2570     1031        1       9       18             0 mingetty
[  293.256157] [ 2571]     0  2571     2677        0       9      106         -1000 udevd
[  293.256634] [ 2573]     0  2573     1031        1       9       18             0 mingetty
[  293.257108] [ 2576]     0  2576    25109        1      52      234             0 sshd
[  293.257585] [ 2598]   500  2598    25109        0      50      247             0 sshd
[  293.258059] Out of memory: Kill process 2598 (sshd) score 0 or sacrifice child
[  293.258536] Killed process 2598 (sshd) total-vm:100436kB, anon-rss:0kB, file-rss:0kB
[... etc ...]

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
