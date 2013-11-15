Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4EBC16B0031
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 17:41:22 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id ld10so4204127pab.34
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 14:41:21 -0800 (PST)
Received: from psmtp.com ([74.125.245.147])
        by mx.google.com with SMTP id bq8si3184599pab.58.2013.11.15.14.41.16
        for <linux-mm@kvack.org>;
        Fri, 15 Nov 2013 14:41:17 -0800 (PST)
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id rAFMfFb6000887
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 17:41:15 -0500
Received: from gelk.kernelslacker.org (ovpn-113-196.phx2.redhat.com [10.3.113.196])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id rAFMf9V2009922
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 17:41:15 -0500
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.7/8.14.7) with ESMTP id rAFMev10015808
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 17:40:57 -0500
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.7/8.14.7/Submit) id rAFMejW9015791
	for linux-mm@kvack.org; Fri, 15 Nov 2013 17:40:45 -0500
Date: Fri, 15 Nov 2013 17:40:45 -0500
From: Dave Jones <davej@redhat.com>
Subject: odd swap accounting messages during oom kill.
Message-ID: <20131115224045.GA11416@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

I had a machine that leaked a bunch of memory after a fuzz testing run,
so I tried to reboot it. During reboot, it did a swapoff, and the oom killer
triggered something kinda odd..

(This kernel is Linus' latest from some point this afternoon)



First, we oom and kill git. This is right before I decided to reboot.

[61030.363558] Out of memory: Kill process 27005 (git) score 2 or sacrifice child
[61034.176028] systemd invoked oom-killer: gfp_mask=0x200da, order=0, oom_score_adj=0
[61034.176658] systemd cpuset=/ mems_allowed=0
[61034.177580] CPU: 0 PID: 1 Comm: systemd Not tainted 3.12.0+ #8
[61034.179791]  ffff880243768600 ffff8802437719b0 ffffffff8172017e 0000000000000000
[61034.180786]  ffff880243771a40 ffffffff81151ebc 0000000000000046 ffffffff810acfc6
[61034.181686]  0000000000000202 ffffffff81c58660 ffff8802437719f0 ffffffff810ad19d
[61034.182897] Call Trace:
[61034.183767]  [<ffffffff8172017e>] dump_stack+0x4e/0x7a
[61034.184878]  [<ffffffff81151ebc>] dump_header.isra.12+0x7c/0x460
[61034.186996]  [<ffffffff810acfc6>] ? trace_hardirqs_on_caller+0x16/0x1e0
[61034.188083]  [<ffffffff810ad19d>] ? trace_hardirqs_on+0xd/0x10
[61034.188638]  [<ffffffff81729b52>] ? _raw_spin_unlock_irqrestore+0x42/0x70
[61034.189626]  [<ffffffff8115276b>] oom_kill_process+0x2fb/0x520
[61034.190524]  [<ffffffff81153168>] out_of_memory+0x5e8/0x650
[61034.191505]  [<ffffffff81159510>] __alloc_pages_nodemask+0xb10/0xb50
[61034.192399]  [<ffffffff8119d391>] alloc_pages_vma+0xf1/0x1b0
[61034.193283]  [<ffffffff8118e3cb>] ? read_swap_cache_async+0x11b/0x220
[61034.194226]  [<ffffffff8118e3cb>] read_swap_cache_async+0x11b/0x220
[61034.195693]  [<ffffffff8118e568>] swapin_readahead+0x98/0xe0
[61034.196748]  [<ffffffff8117c0f3>] handle_mm_fault+0x903/0xbb0
[61034.197741]  [<ffffffff8172dbb1>] ? __do_page_fault+0x101/0x610
[61034.198698]  [<ffffffff8172dc1f>] __do_page_fault+0x16f/0x610
[61034.199757]  [<ffffffff8111179f>] ? __acct_update_integrals+0x7f/0x100
[61034.200777]  [<ffffffff81729ab1>] ? _raw_spin_unlock+0x31/0x50
[61034.201761]  [<ffffffff810a997f>] ? trace_hardirqs_off_caller+0x1f/0xc0
[61034.202802]  [<ffffffff8172e0da>] do_page_fault+0x1a/0x70
[61034.203748]  [<ffffffff8172ab12>] page_fault+0x22/0x30
[61034.204693] Mem-Info:
[61034.206031] Node 0 DMA per-cpu:
[61034.206824] CPU    0: hi:    0, btch:   1 usd:   0
[61034.207783] CPU    1: hi:    0, btch:   1 usd:   0
[61034.208692] CPU    2: hi:    0, btch:   1 usd:   0
[61034.209567] CPU    3: hi:    0, btch:   1 usd:   0
[61034.210438] Node 0 DMA32 per-cpu:
[61034.211228] CPU    0: hi:  186, btch:  31 usd:  33
[61034.212102] CPU    1: hi:  186, btch:  31 usd:   1
[61034.212975] CPU    2: hi:  186, btch:  31 usd:   5
[61034.213869] CPU    3: hi:  186, btch:  31 usd:  27
[61034.214785] Node 0 Normal per-cpu:
[61034.216144] CPU    0: hi:  186, btch:  31 usd:  58
[61034.217086] CPU    1: hi:  186, btch:  31 usd:  86
[61034.218007] CPU    2: hi:  186, btch:  31 usd:  22
[61034.218927] CPU    3: hi:  186, btch:  31 usd: 182
[61034.219837] active_anon:695 inactive_anon:587 isolated_anon:0
[61034.219837]  active_file:25044 inactive_file:64529 isolated_file:0
[61034.219837]  unevictable:0 dirty:0 writeback:79 unstable:0
[61034.219837]  free:25981 slab_reclaimable:9919 slab_unreclaimable:1836972
[61034.219837]  mapped:5093 shmem:157 pagetables:1065 bounce:0
[61034.219837]  free_cma:0
[61034.225792] Node 0 DMA free:15872kB min:132kB low:164kB high:196kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15972kB managed:15888kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[61034.228825] lowmem_reserve[]: 0 2549 7749 7749
[61034.230209] Node 0 DMA32 free:42836kB min:22184kB low:27728kB high:33276kB active_anon:0kB inactive_anon:888kB active_file:29896kB inactive_file:88680kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2646084kB managed:2610340kB mlocked:0kB dirty:0kB writeback:96kB mapped:4352kB shmem:0kB slab_reclaimable:7728kB slab_unreclaimable:2416668kB kernel_stack:176kB pagetables:1492kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:188530 all_unreclaimable? yes
[61034.232607] lowmem_reserve[]: 0 0 5200 5200
[61034.233297] Node 0 Normal free:45216kB min:45260kB low:56572kB high:67888kB active_anon:2780kB inactive_anon:1460kB active_file:70280kB inactive_file:169436kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:5478400kB managed:5324908kB mlocked:0kB dirty:0kB writeback:220kB mapped:16020kB shmem:628kB slab_reclaimable:31948kB slab_unreclaimable:4931204kB kernel_stack:888kB pagetables:2768kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:10 all_unreclaimable? no
[61034.236044] lowmem_reserve[]: 0 0 0 0
[61034.236780] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15872kB
[61034.238257] Node 0 DMA32: 103*4kB (U) 17*8kB (U) 101*16kB (UE) 147*32kB (UE) 77*64kB (UEM) 79*128kB (UEM) 30*256kB (UEM) 14*512kB (UEM) 0*1024kB 1*2048kB (R) 1*4096kB (R) = 42900kB
[61034.239844] Node 0 Normal: 226*4kB (UR) 239*8kB (UEM) 279*16kB (UEM) 340*32kB (UEM) 131*64kB (UEM) 50*128kB (UEM) 9*256kB (E) 14*512kB (UEM) 1*1024kB (M) 1*2048kB (R) 0*4096kB = 45488kB
[61034.241494] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[61034.242297] 25925 total pagecache pages
[61034.243097] 700 pages in swap cache
[61034.243867] Swap cache stats: add 2829062, delete 2828362, find 15768380/16225121
[61034.244679] Free swap  = 7971264kB
[61034.245489] Total swap = 8011772kB

Note the Free swap number here ^^^


[61034.246319] 2035114 pages RAM
[61034.247145] 0 pages HighMem/MovableOnly
[61034.247977] 38373 pages reserved
[61034.248867] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
[61034.249785] [  203]     0   203   192744     3463     365       61             0 systemd-journal
[61034.250710] [  219]     0   219    10441      298      22      224         -1000 systemd-udevd
[61034.251640] [  312]     0   312    64189      344      28      188             0 rsyslogd
[61034.252612] [  314]     0   314    89322     1398      56      398             0 NetworkManager
[61034.253578] [  319]   997   319     7239      288      20      106             0 chronyd
[61034.254523] [  321]     0   321     6073      430      16      183             0 smartd
[61034.255492] [  322]     0   322     8251      350      20       80             0 systemd-logind
[61034.256495] [  323]    70   323     7052      373      26       95             0 avahi-daemon
[61034.257491] [  326]    81   326     6089      329      17      109          -900 dbus-daemon
[61034.258490] [  329]     0   329    31023      238      16      150             0 crond
[61034.259511] [  330]     0   330    27499      177      10       31             0 agetty
[61034.260524] [  336]    70   336     6986       54      24       57             0 avahi-daemon
[61034.261530] [  347]    32   347     9423      136      22      127             0 rpcbind
[61034.262513] [  350]     0   350    20157      653      41      212         -1000 sshd
[61034.263491] [  356]     0   356    25547      813      50     3109             0 dhclient
[61034.264467] [13479]  1000 13479     4001      136       8      556             0 trinity
[61034.265438] [13483]  1000 13483     4001       12       8      564             0 trinity
[61034.266395] [13488]  1000 13488     6557      136       9      556             0 trinity
[61034.267318] [13494]  1000 13494     6557       22       9      553             0 trinity
[61034.268192] [13669]  1000 13669     5533      136       9      556             0 trinity
[61034.269046] [13694]  1000 13694     5533        8       9      569             0 trinity
[61034.269889] [13744]  1000 13744     2465      136       9      557             0 trinity
[61034.270711] [13750]  1000 13750     2465       17       9      563             0 trinity
[61034.271529] [26758]     0 26758    32819      879      67      284             0 sshd
[61034.272315] [26781]  1000 26781    32854      208      65      316             0 sshd
[61034.273071] [26794]  1000 26794    29190      782      14      113             0 bash
[61034.273812] [27019]     0 27019    46776      650      45        0             0 sudo
[61034.274543] [27026]     0 27026    33251      323      21        0             0 reboot
[61034.275272] [27027]     0 27027     4357      207      13        0             0 systemd-tty-ask

And then we oom again..

[61034.275933] Out of memory: Kill process 26794 (bash) score 0 or sacrifice child
[61034.276577] Killed process 27019 (sudo) total-vm:187104kB, anon-rss:612kB, file-rss:1988kB
[61034.773283] systemd[1]: Unit rpcbind.service entered failed state.
[61035.281345] swapoff invoked oom-killer: gfp_mask=0x200da, order=0, oom_score_adj=0
[61035.281452] swapoff cpuset=/ mems_allowed=0
[61035.281480] CPU: 2 PID: 27030 Comm: swapoff Not tainted 3.12.0+ #8 
[61035.281554]  ffff88009ce131a0 ffff88019f2a5af8 ffffffff8172017e 0000000000000000
[61035.281585]  ffff88019f2a5b88 ffffffff81151ebc 0000000000000046 ffffffff810acfc6
[61035.281617]  0000000000000202 ffffffff81c58660 ffff88019f2a5b38 ffffffff810ad19d
[61035.281648] Call Trace:
[61035.281664]  [<ffffffff8172017e>] dump_stack+0x4e/0x7a
[61035.281685]  [<ffffffff81151ebc>] dump_header.isra.12+0x7c/0x460
[61035.281707]  [<ffffffff810acfc6>] ? trace_hardirqs_on_caller+0x16/0x1e0
[61035.281728]  [<ffffffff810ad19d>] ? trace_hardirqs_on+0xd/0x10
[61035.281750]  [<ffffffff81729b52>] ? _raw_spin_unlock_irqrestore+0x42/0x70
[61035.281774]  [<ffffffff8115276b>] oom_kill_process+0x2fb/0x520
[61035.281796]  [<ffffffff81153168>] out_of_memory+0x5e8/0x650
[61035.281817]  [<ffffffff81159510>] __alloc_pages_nodemask+0xb10/0xb50
[61035.281842]  [<ffffffff8119d391>] alloc_pages_vma+0xf1/0x1b0
[61035.281863]  [<ffffffff8118e3cb>] ? read_swap_cache_async+0x11b/0x220
[61035.281886]  [<ffffffff8118e3cb>] read_swap_cache_async+0x11b/0x220
[61035.281909]  [<ffffffff81191803>] try_to_unuse+0x103/0x5b0
[61035.281930]  [<ffffffff81192006>] SyS_swapoff+0x206/0x640
[61035.281951]  [<ffffffff81010a35>] ? syscall_trace_enter+0x145/0x2a0
[61035.281974]  [<ffffffff81732ce4>] tracesys+0xdd/0xe2
[61035.281992] Mem-Info:
[61035.282004] Node 0 DMA per-cpu:
[61035.282020] CPU    0: hi:    0, btch:   1 usd:   0
[61035.282038] CPU    1: hi:    0, btch:   1 usd:   0
[61035.282055] CPU    2: hi:    0, btch:   1 usd:   0
[61035.282073] CPU    3: hi:    0, btch:   1 usd:   0
[61035.282090] Node 0 DMA32 per-cpu:
[61035.282106] CPU    0: hi:  186, btch:  31 usd:  88
[61035.282123] CPU    1: hi:  186, btch:  31 usd:  43
[61035.282143] CPU    2: hi:  186, btch:  31 usd:  30
[61035.282636] CPU    3: hi:  186, btch:  31 usd:  66
[61035.283123] Node 0 Normal per-cpu:
[61035.283610] CPU    0: hi:  186, btch:  31 usd: 110
[61035.284097] CPU    1: hi:  186, btch:  31 usd: 160
[61035.284649] CPU    2: hi:  186, btch:  31 usd:  53
[61035.285129] CPU    3: hi:  186, btch:  31 usd: 133
[61035.285599] active_anon:753 inactive_anon:1317 isolated_anon:0
[61035.285599]  active_file:25152 inactive_file:64586 isolated_file:32
[61035.285599]  unevictable:0 dirty:0 writeback:3 unstable:0
[61035.285599]  free:25964 slab_reclaimable:9871 slab_unreclaimable:1836574
[61035.285599]  mapped:3424 shmem:347 pagetables:575 bounce:0
[61035.285599]  free_cma:0
[61035.288505] Node 0 DMA free:15872kB min:132kB low:164kB high:196kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15972kB managed:15888kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[61035.290808] lowmem_reserve[]: 0 2549 7749 7749
[61035.291373] Node 0 DMA32 free:43672kB min:22184kB low:27728kB high:33276kB active_anon:464kB inactive_anon:840kB active_file:29948kB inactive_file:88808kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2646084kB managed:2610340kB mlocked:0kB dirty:0kB writeback:0kB mapped:1944kB shmem:16kB slab_reclaimable:7648kB slab_unreclaimable:2416428kB kernel_stack:112kB pagetables:820kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:5539 all_unreclaimable? no
[61035.293740] lowmem_reserve[]: 0 0 5200 5200
[61035.294349] Node 0 Normal free:46424kB min:45260kB low:56572kB high:67888kB active_anon:2548kB inactive_anon:4428kB active_file:70660kB inactive_file:169536kB unevictable:0kB isolated(anon):0kB isolated(file):128kB present:5478400kB managed:5324908kB mlocked:0kB dirty:0kB writeback:0kB mapped:11752kB shmem:1372kB slab_reclaimable:31836kB slab_unreclaimable:4929852kB kernel_stack:896kB pagetables:1480kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:17174 all_unreclaimable? no
[61035.297078] lowmem_reserve[]: 0 0 0 0
[61035.297804] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15872kB
[61035.299297] Node 0 DMA32: 270*4kB (UM) 100*8kB (UM) 122*16kB (UEM) 155*32kB (UEM) 64*64kB (UEM) 79*128kB (UEM) 30*256kB (UEM) 14*512kB (UEM) 0*1024kB 1*2048kB (R) 1*4096kB (R) = 43992kB
[61035.300890] Node 0 Normal: 522*4kB (UMR) 357*8kB (UM) 308*16kB (UEM) 343*32kB (UEM) 104*64kB (UEM) 50*128kB (UEM) 9*256kB (E) 14*512kB (UEM) 1*1024kB (M) 1*2048kB (R) 0*4096kB = 46448kB
[61035.302496] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[61035.303353] 25936 total pagecache pages
[61035.304202] 310 pages in swap cache
[61035.305069] Swap cache stats: add 2831838, delete 2831528, find 15778023/16235093
[61035.305907] Free swap  = -16608kB

Whoa, free swap went negative!!

[61035.306778] Total swap = 0kB
[61035.307631] 2035114 pages RAM
[61035.308458] 0 pages HighMem/MovableOnly
[61035.309291] 38373 pages reserved
[61035.310159] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
[61035.311043] [  203]     0   203   193769     3535     365        5             0 systemd-journal
[61035.311956] [  219]     0   219    10441      479      22       43         -1000 systemd-udevd
[61035.312850] [  356]     0   356    25547     1178      50     2735             0 dhclient
[61035.313733] [26758]     0 26758    32819     1064      67      100             0 sshd
[61035.314657] [26794]  1000 26794    29190      783      14      112             0 bash
[61035.315553] [27030]     0 27030    30845      189      22        0             0 swapoff
[61035.316448] [27037]     0 27037     2810      212      10        0             0 systemd-user-se
[61035.317344] Out of memory: Kill process 27030 (swapoff) score -1369716241 or sacrifice child
[61035.318256] Killed process 27030 (swapoff) total-vm:123380kB, anon-rss:164kB, file-rss:592kB

Also check out the score for swapoff, that's also gone negative.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
