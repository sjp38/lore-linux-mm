Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1014E6B025E
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 19:18:54 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id l89so852356lfi.3
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 16:18:53 -0700 (PDT)
Received: from arcturus.aphlor.org (arcturus.ipv6.aphlor.org. [2a03:9800:10:4a::2])
        by mx.google.com with ESMTPS id u186si17048437wmg.3.2016.07.18.16.18.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 16:18:52 -0700 (PDT)
Received: from c-65-96-118-216.hsd1.ma.comcast.net ([65.96.118.216] helo=wopr.kernelslacker.org)
	by arcturus.aphlor.org with esmtpsa (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
	(Exim 4.87)
	(envelope-from <davej@codemonkey.org.uk>)
	id 1bPHoK-0005Jc-3d
	for linux-mm@kvack.org; Tue, 19 Jul 2016 00:18:52 +0100
Date: Mon, 18 Jul 2016 19:18:50 -0400
From: Dave Jones <davej@codemonkey.org.uk>
Subject: oom-reaper choosing wrong processes.
Message-ID: <20160718231850.GA23178@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

I have a patch I use when I do fuzz-testing runs, that adds some code to the oom killer
such that it only ever kills tasks whose process name begins 'trinity-'.
(The idea being, given that's the only thing really running on this box, killing anything
 else would be a mistake).  For the longest time it's been completely benign, but on 4.7rc7
I see this..


[ 4599.949520] Out of memory: Kill process 2692 (trinity-main) score 0 or sacrifice child
[ 4599.949550] Killed process 2692 (trinity-main) total-vm:3189400kB, anon-rss:1060kB, file-rss:864kB, shmem-rss:60kB
[ 4599.958881] oom_reaper: reaped process 2692 (trinity-main), now anon-rss:0kB, file-rss:0kB, shmem-rss:60kB
[ 4607.741744] oom_reaper: reaped process 21525 (trinity-c15), now anon-rss:0kB, file-rss:0kB, shmem-rss:82072kB
[ 4607.744269] oom_reaper: reaped process 21525 (trinity-c15), now anon-rss:0kB, file-rss:0kB, shmem-rss:82072kB
[ 4607.746502] oom_reaper: reaped process 26334 (trinity-c4), now anon-rss:0kB, file-rss:0kB, shmem-rss:140112kB
[ 4607.747159] oom_reaper: reaped process 21525 (trinity-c15), now anon-rss:0kB, file-rss:0kB, shmem-rss:82072kB
[ 4607.748741] oom_reaper: reaped process 26334 (trinity-c4), now anon-rss:0kB, file-rss:0kB, shmem-rss:140112kB
[ 4607.749447] oom_reaper: reaped process 21525 (trinity-c15), now anon-rss:0kB, file-rss:0kB, shmem-rss:82072kB
[ 4607.751078] oom_reaper: reaped process 26334 (trinity-c4), now anon-rss:0kB, file-rss:0kB, shmem-rss:140112kB
[ 4607.752320] oom_reaper: reaped process 21525 (trinity-c15), now anon-rss:0kB, file-rss:0kB, shmem-rss:82072kB
[ 4607.753335] oom_reaper: reaped process 26334 (trinity-c4), now anon-rss:0kB, file-rss:0kB, shmem-rss:140112kB
[ 4607.754481] oom_reaper: reaped process 21525 (trinity-c15), now anon-rss:0kB, file-rss:0kB, shmem-rss:82072kB
[ 4607.755643] oom_reaper: reaped process 26334 (trinity-c4), now anon-rss:0kB, file-rss:0kB, shmem-rss:140112kB
[ 4607.757109] oom_reaper: reaped process 21525 (trinity-c15), now anon-rss:0kB, file-rss:0kB, shmem-rss:82072kB
[ 4607.759743] oom_reaper: reaped process 21525 (trinity-c15), now anon-rss:0kB, file-rss:0kB, shmem-rss:82072kB

Looks good.

Then..

[ 4607.765352] sendmail-mta invoked oom-killer: gfp_mask=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), order=0, oom_score_adj=0
[ 4607.765359] sendmail-mta cpuset=/ mems_allowed=0
[ 4607.765365] CPU: 2 PID: 1842 Comm: sendmail-mta Not tainted 4.7.0-rc7-think+ #2
[ 4607.765369]  0000000000000000 00000000c4c0ff2b ffff88045038f718 ffffffffa9589f5b
[ 4607.765372]  ffff88044f39d440 ffff88045038fa60 ffff88045038f7a8 ffffffffa9288c68
[ 4607.765375]  0000000000000206 ffff88045038f748 ffffffffa90f9a88 0000000000000206
[ 4607.765375] Call Trace:
[ 4607.765382]  [<ffffffffa9589f5b>] dump_stack+0x68/0x9d
[ 4607.765385]  [<ffffffffa9288c68>] dump_header.isra.16+0x98/0x4f0
[ 4607.765389]  [<ffffffffa90f9a88>] ? preempt_count_sub+0x18/0xd0
[ 4607.765393]  [<ffffffffa9d6cc82>] ? _raw_spin_unlock_irqrestore+0x42/0x70
[ 4607.765396]  [<ffffffffa9593f84>] ? ___ratelimit+0x114/0x1a0
[ 4607.765398]  [<ffffffffa9289f7f>] oom_kill_process+0x3ff/0x7a0
[ 4607.765405]  [<ffffffffa928a923>] out_of_memory+0x583/0x5a0
[ 4607.765407]  [<ffffffffa928a6e3>] ? out_of_memory+0x343/0x5a0
[ 4607.765410]  [<ffffffffa928a3a0>] ? check_panic_on_oom+0x80/0x80
[ 4607.765413]  [<ffffffffa9141642>] ? trace_hardirqs_on_caller+0x182/0x280
[ 4607.765415]  [<ffffffffa9d65fda>] ? mutex_trylock+0x14a/0x240
[ 4607.765417]  [<ffffffffa929295b>] ? __alloc_pages_nodemask+0xf3b/0x1710
[ 4607.765420]  [<ffffffffa9292f4f>] __alloc_pages_nodemask+0x152f/0x1710
[ 4607.765424]  [<ffffffffa9291a20>] ? warn_alloc_failed+0x220/0x220
[ 4607.765426]  [<ffffffffa913bb2d>] ? get_lock_stats+0x3d/0x70
[ 4607.765428]  [<ffffffffa90f9a88>] ? preempt_count_sub+0x18/0xd0
[ 4607.765436]  [<ffffffffa9282dac>] ? pagecache_get_page+0x2c/0x370
[ 4607.765438]  [<ffffffffa9286513>] filemap_fault+0x5b3/0x880
[ 4607.765443]  [<ffffffffa942cd5f>] ext4_filemap_fault+0x4f/0x70
[ 4607.765446]  [<ffffffffa92d0113>] __do_fault+0x143/0x300
[ 4607.765449]  [<ffffffffa92cffd0>] ? wp_page_copy.isra.82+0x860/0x860
[ 4607.765452]  [<ffffffffa9149967>] ? do_raw_spin_unlock+0x97/0x130
[ 4607.765458]  [<ffffffffa92d70be>] handle_mm_fault+0x165e/0x2390
[ 4607.765461]  [<ffffffffa92d5a60>] ? copy_page_range+0xeb0/0xeb0
[ 4607.765463]  [<ffffffffa9035836>] ? native_sched_clock+0x66/0x160
[ 4607.765465]  [<ffffffffa9035836>] ? native_sched_clock+0x66/0x160
[ 4607.765468]  [<ffffffffa913c5bf>] ? __lock_is_held+0x8f/0xd0
[ 4607.765471]  [<ffffffffa92c99ab>] ? vmacache_find+0xeb/0x140
[ 4607.765474]  [<ffffffffa907240d>] __do_page_fault+0x1ed/0x650
[ 4607.765477]  [<ffffffffa9072890>] do_page_fault+0x20/0x70
[ 4607.765480]  [<ffffffffa927d51d>] ? context_tracking_exit+0x1d/0x20
[ 4607.765482]  [<ffffffffa9d6f21f>] page_fault+0x1f/0x30
[ 4607.765505] Mem-Info:
[ 4607.765518] active_anon:3867180 inactive_anon:426354 isolated_anon:96
                active_file:1238 inactive_file:1906 isolated_file:23
                unevictable:16 dirty:173 writeback:0 unstable:0
                slab_reclaimable:39583 slab_unreclaimable:16385
                mapped:76607 shmem:4291476 pagetables:2902 bounce:0
                free:34703 free_pcp:183 free_cma:0
[ 4607.765526] DMA free:15880kB min:60kB low:72kB high:84kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15896kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[ 4607.765530] lowmem_reserve[]: 0 3263 17181 17181
[ 4607.765537] DMA32 free:68284kB min:12824kB low:16164kB high:19504kB active_anon:2741916kB inactive_anon:548580kB active_file:60kB inactive_file:420kB unevictable:4kB isolated(anon):0kB isolated(file):0kB present:3459008kB managed:3407724kB mlocked:4kB dirty:128kB writeback:0kB mapped:221140kB shmem:3288392kB slab_reclaimable:23288kB slab_unreclaimable:7616kB kernel_stack:896kB pagetables:1100kB unstable:0kB bounce:0kB free_pcp:260kB local_pcp:120kB free_cma:0kB writeback_tmp:0kB pages_scanned:5008 all_unreclaimable? yes
[ 4607.765540] lowmem_reserve[]: 0 0 13917 13917
[ 4607.765547] Normal free:54648kB min:54696kB low:68944kB high:83192kB active_anon:12726804kB inactive_anon:1156836kB active_file:4892kB inactive_file:7204kB unevictable:60kB isolated(anon):384kB isolated(file):92kB present:17283072kB managed:14251916kB mlocked:60kB dirty:564kB writeback:0kB mapped:85288kB shmem:13877512kB slab_reclaimable:135044kB slab_unreclaimable:57908kB kernel_stack:4800kB pagetables:10508kB unstable:0kB bounce:0kB free_pcp:472kB local_pcp:124kB free_cma:0kB writeback_tmp:0kB pages_scanned:313472 all_unreclaimable? yes
[ 4607.765551] lowmem_reserve[]: 0 0 0 0
[ 4607.765568] DMA: 2*4kB (U) 2*8kB (U) 1*16kB (U) 3*32kB (U) 2*64kB (U) 2*128kB (U) 0*256kB 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15880kB
[ 4607.765590] DMA32: 376*4kB (UME) 398*8kB (UME) 312*16kB (UE) 163*32kB (UME) 62*64kB (UM) 30*128kB (U) 24*256kB (UE) 7*512kB (UE) 1*1024kB (U) 1*2048kB (M) 8*4096kB (M) = 68272kB
[ 4607.765605] Normal: 1358*4kB (UME) 1694*8kB (UME) 921*16kB (UEH) 474*32kB (UME) 87*64kB (UM) 2*128kB (U) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 54712kB
[ 4607.765607] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=1048576kB
[ 4607.765609] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[ 4607.765610] 4295139 total pagecache pages
[ 4607.765611] 299 pages in swap cache
[ 4607.765613] Swap cache stats: add 14353678, delete 14353379, find 1451516/2271689
[ 4607.765614] Free swap  = 0kB
[ 4607.765614] Total swap = 7964668kB
[ 4607.765615] 5189516 pages RAM
[ 4607.765616] 0 pages HighMem/MovableOnly
[ 4607.765617] 770632 pages reserved
[ 4607.765618] 0 pages hwpoisoned
[ 4607.765619] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[ 4607.765637] [  749]     0   749    13116      782      29       3      385             0 systemd-journal
[ 4607.765641] [  793]     0   793    10640       10      23       3      285         -1000 systemd-udevd
[ 4607.765647] [ 1647]     0  1647    11928       16      27       3      111             0 rpcbind
[ 4607.765651] [ 1653]     0  1653     5841        0      15       3       54             0 rpc.idmapd
[ 4607.765656] [ 1655]     0  1655    11052       24      26       3      114             0 systemd-logind
[ 4607.765687] [ 1657]     0  1657    64579      181      28       3      161             0 rsyslogd
[ 4607.765691] [ 1660]     0  1660     1058        0       8       3       38             0 acpid
[ 4607.765696] [ 1661]     0  1661     7414       22      18       3       52             0 cron
[ 4607.765700] [ 1662]     0  1662     6993        0      19       3       54             0 atd
[ 4607.765704] [ 1664]   105  1664    10744       40      26       3       79          -900 dbus-daemon
[ 4607.765708] [ 1671]     0  1671     6264       29      17       3      157             0 smartd
[ 4607.765712] [ 1738]     0  1738    16948        0      37       3      204         -1000 sshd
[ 4607.765716] [ 1742]     0  1742     9461        0      22       3      195             0 rpc.mountd
[ 4607.765721] [ 1776]     0  1776     3624        0      12       3       39             0 agetty
[ 4607.765725] [ 1797]     0  1797     3319        0      10       3       48             0 mcelog
[ 4607.765729] [ 1799]     0  1799     4824       21      15       3       39             0 irqbalance
[ 4607.765733] [ 1803]   108  1803    25492       42      24       3      124             0 ntpd
[ 4607.765737] [ 1842]     0  1842    19793       48      39       3      410             0 sendmail-mta
[ 4607.765746] [ 1878]     0  1878     5121        0      13       3      262             0 dhclient
[ 4607.765752] [ 2145]  1000  2145    15627        0      33       3      213             0 systemd
[ 4607.765756] [ 2148]  1000  2148    19584        4      40       3      438             0 (sd-pam)
[ 4607.765760] [ 2643]  1000  2643     7465      433      19       3      152             0 tmux
[ 4607.765764] [ 2644]  1000  2644     5864        0      16       3      508             0 bash
[ 4607.765768] [ 2678]  1000  2678     3328       89      11       3       19             0 test-multi.sh
[ 4607.765774] [ 2693]  1000  2693     5864        1      16       3      507             0 bash
[ 4607.765782] [ 6456]  1000  6456     3091       21      11       3       24             0 dmesg
[ 4607.765787] [18624]  1000 18624   750863    43368     520       6        0           500 trinity-c10
[ 4607.765792] [21525]  1000 21525   797320    20517     493       7        0           500 trinity-c15
[ 4607.765796] [22023]  1000 22023   797349     1985     319       7        0           500 trinity-c2
[ 4607.765814] [22658]  1000 22658   797382        1     458       7        0           500 trinity-c0
[ 4607.765818] [26334]  1000 26334   797217    34960     412       7        0           500 trinity-c4
[ 4607.765823] [26388]  1000 26388   797383     9401     118       7        0           500 trinity-c11
[ 4607.765826] oom_kill_process: would have killed process 749 (systemd-journal), but continuing instead...
[ 4608.147644] oom_reaper: reaped process 26334 (trinity-c4), now anon-rss:0kB, file-rss:0kB, shmem-rss:136724kB
[ 4608.148218] oom_reaper: reaped process 18624 (trinity-c10), now anon-rss:0kB, file-rss:0kB, shmem-rss:174356kB
[ 4608.149795] oom_reaper: reaped process 21525 (trinity-c15), now anon-rss:0kB, file-rss:0kB, shmem-rss:86288kB
[ 4608.150734] oom_reaper: reaped process 18624 (trinity-c10), now anon-rss:0kB, file-rss:0kB, shmem-rss:174348kB
[ 4608.152489] oom_reaper: reaped process 21525 (trinity-c15), now anon-rss:0kB, file-rss:0kB, shmem-rss:86288kB
[ 4608.156127] oom_reaper: reaped process 18624 (trinity-c10), now anon-rss:0kB, file-rss:0kB, shmem-rss:174336kB
[ 4608.158798] oom_reaper: reaped process 26334 (trinity-c4), now anon-rss:0kB, file-rss:0kB, shmem-rss:136652kB
[ 4608.161336] oom_reaper: reaped process 26334 (trinity-c4), now anon-rss:0kB, file-rss:0kB, shmem-rss:136652kB
[ 4608.163836] oom_reaper: reaped process 26334 (trinity-c4), now anon-rss:0kB, file-rss:0kB, shmem-rss:136652kB


Whoa. Why did it pick systemd-journal ?
My 'skip over !trinity processes' code kicks in, and it then kills the right processes, and the box lives on,
but if I hadn't have had that diff, the wrong process would have been killed.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
