Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 77BD86B0055
	for <linux-mm@kvack.org>; Tue, 26 May 2009 06:04:58 -0400 (EDT)
Received: from mlsv8.hitachi.co.jp (unknown [133.144.234.166])
	by mail9.hitachi.co.jp (Postfix) with ESMTP id D8EEB37C89
	for <linux-mm@kvack.org>; Tue, 26 May 2009 19:04:59 +0900 (JST)
Received: from mfbcchk3.hitachi.co.jp (unverified) by mfilter-s4.hitachi.co.jp
 (Content Technologies SMTPRS 4.3.17) with ESMTP id <T8e8ab863e10ac906b48c0@mfilter-s4.hitachi.co.jp> for <linux-mm@kvack.org>;
 Tue, 26 May 2009 19:04:56 +0900
Received: from vshuts2.hitachi.co.jp (vshuts2.hitachi.co.jp [10.201.6.71])
	by mfbcchk3.hitachi.co.jp (Switch-3.3.2/Switch-3.3.2) with ESMTP id n4QA4qf5028249
	for <linux-mm@kvack.org>; Tue, 26 May 2009 19:04:55 +0900
Received: from hsdlgw92.sdl.hitachi.co.jp (unknown [133.144.7.20])
	by vshuts2.hitachi.co.jp (Symantec Mail Security) with ESMTP id 8B04E8B0226
	for <linux-mm@kvack.org>; Tue, 26 May 2009 19:04:52 +0900 (JST)
Received: from sdl99w.sdl.hitachi.co.jp ([133.144.14.250])
 by vgate2.sdl.hitachi.co.jp (SAVSMTP 3.1.1.32) with SMTP id M2009052619045115830
 for <linux-mm@kvack.org>; Tue, 26 May 2009 19:04:51 +0900
Received: from [127.0.0.1] (IDENT:U2FsdGVkX18uj5W4c/biO10J3pk0ii/srEVl0EgSBCM@localhost.localdomain [127.0.0.1])
	by sdl99w.sdl.hitachi.co.jp (8.13.1/3.7W04031011) with ESMTP id n4QA4ZEe019257
	for <linux-mm@kvack.org>; Tue, 26 May 2009 19:04:35 +0900
Message-ID: <4A1BBEB3.1010701@hitachi.com>
Date: Tue, 26 May 2009 19:04:35 +0900
From: Satoru Moriya <satoru.moriya.br@hitachi.com>
MIME-Version: 1.0
Subject: Problem with oom-killer in memcg
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

When I tested memcg, I ran into a problem which causes system hang.

This is what I did.
- make a cgroup named important for memory
- add a process named big_memory into it
  - big_memory uses a lot of memory(allocates memory repeatedly)
  - big_memory's oom_adj is set to -17
- after a while, the system will hang

Judging from syslog and outputs of console, I think we are in the busy
loop below at that time.
1. oom-killer tries to kill big_memory because of memory shortage
2. oom-killer fails to kill big_memory because of oom_adj = -17

I think it's not good thing that troubles in cgroups affect 
all over the system. 

Further hardware and software details are found below.
Please let me know if I should provide more information etc.

Regards,

--

System environment
---------------------------
memory: 6GB
swap  : 2GB (partition)
kernel: 2.6.30-rc7

cgroup configuration
---------------------------
group(named important):
 memory.limit_in_bytes = 250M
 memory.memsw.limit_int_bytes=500M 
 tasks = big_memroy

processes in the "important" cgroup
------------------------------------
big_memory:
 - use a lot of memory(allocate memory repeatedly by malloc())
 - oom_adj = -17

syslog output (oom-killer part)
--------------------------------
[  740.621728] big_memory invoked oom-killer: gfp_mask=0xd0, order=0, oomkilladj=-17
[  740.622106] big_memory cpuset=/ mems_allowed=0
[  740.622314] Pid: 2801, comm: big_memory Not tainted 2.6.30-rc7 #1
[  740.622574] Call Trace:
[  740.622783]  [<ffffffff8029b3a0>] ? cpuset_print_task_mems_allowed+0x92/0x9d
[  740.622999]  [<ffffffff802d2bc3>] oom_kill_process+0xae/0x366
[  740.623210]  [<ffffffff802d3289>] ? select_bad_process+0xab/0x228
[  740.623422]  [<ffffffff802d38fc>] mem_cgroup_out_of_memory+0xbc/0xf8
[  740.623728]  [<ffffffff8031f228>] __mem_cgroup_try_charge+0x2db/0x318
[  740.623958]  [<ffffffff803200cd>] mem_cgroup_charge_common+0x74/0xbe
[  740.624170]  [<ffffffff803201f8>] mem_cgroup_newpage_charge+0xe1/0xee
[  740.624383]  [<ffffffff802f01fc>] handle_mm_fault+0x316/0xb6c
[  740.624657]  [<ffffffff8072fe2f>] do_page_fault+0x55a/0x5e4
[  740.624870]  [<ffffffff8072c74a>] ? trace_hardirqs_off_thunk+0x3a/0x6c
[  740.625082]  [<ffffffff8072cfaf>] page_fault+0x1f/0x30
[  740.625292] Task in /important killed as a result of limit of /important
[  740.625544] memory: usage 0kB, limit 256000kB, failcnt 1467
[  740.625753] memory+swap: usage 512000kB, limit 512000kB, failcnt 571
[  740.625963] Mem-Info:
[  740.626165] Node 0 DMA per-cpu:
[  740.626404] CPU    0: hi:    0, btch:   1 usd:   0
[  740.626656] CPU    1: hi:    0, btch:   1 usd:   0
[  740.626863] CPU    2: hi:    0, btch:   1 usd:   0
[  740.627071] CPU    3: hi:    0, btch:   1 usd:   0
[  740.627277] Node 0 DMA32 per-cpu:
[  740.627535] CPU    0: hi:  186, btch:  31 usd: 183
[  740.627742] CPU    1: hi:  186, btch:  31 usd:  29
[  740.627950] CPU    2: hi:  186, btch:  31 usd:   0
[  740.628156] CPU    3: hi:  186, btch:  31 usd:   0
[  740.628363] Node 0 Normal per-cpu:
[  740.628649] CPU    0: hi:  186, btch:  31 usd: 172
[  740.628857] CPU    1: hi:  186, btch:  31 usd: 184
[  740.629065] CPU    2: hi:  186, btch:  31 usd:  96
[  740.629272] CPU    3: hi:  186, btch:  31 usd: 118
[  740.629492] Active_anon:32254 active_file:67379 inactive_anon:48
[  740.629494]  inactive_file:24909 unevictable:3 dirty:0 writeback:0 unstable:0
[  740.629496]  free:1367086 slab:7269 mapped:10228 pagetables:5377 bounce:0
[  740.630165] Node 0 DMA free:2108kB min:24kB low:28kB high:36kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:15288kB pages_scanned:0 all_unreclaimable? no
[  740.630821] lowmem_reserve[]: 0 2990 6020 6020
[  740.631205] Node 0 DMA32 free:2903748kB min:4924kB low:6152kB high:7384kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:3062496kB pages_scanned:0 all_unreclaimable? no
[  740.631861] lowmem_reserve[]: 0 0 3030 3030
[  740.632291] Node 0 Normal free:2562488kB min:4992kB low:6240kB high:7488kB active_anon:129016kB inactive_anon:192kB active_file:269516kB inactive_file:99636kB unevictable:12kB present:3102720kB pages_scanned:0 all_unreclaimable? no
[  740.632934] lowmem_reserve[]: 0 0 0 0
[  740.633318] Node 0 DMA: 5*4kB 3*8kB 3*16kB 3*32kB 2*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2108kB
[  740.634233] Node 0 DMA32: 5*4kB 4*8kB 1*16kB 2*32kB 3*64kB 3*128kB 2*256kB 5*512kB 4*1024kB 6*2048kB 704*4096kB = 2903748kB
[  740.635155] Node 0 Normal: 181*4kB 106*8kB 63*16kB 38*32kB 26*64kB 25*128kB 12*256kB 12*512kB 7*1024kB 7*2048kB 616*4096kB = 2562516kB
[  740.636084] 92966 total pagecache pages
[  740.636288] 15 pages in swap cache
[  740.636494] Swap cache stats: add 128026, delete 128011, find 5/8
[  740.636750] Free swap  = 1584472kB
[  740.636955] Total swap = 2096472kB
[  740.744949] 1572848 pages RAM
[  740.745156] 59696 pages reserved
[  740.745359] 56853 pages shared
[  740.745612] 131436 pages non-shared
[  740.745819] Memory cgroup out of memory: kill process 2801 (big_memory) score 0 or a child
[  740.746252] big_memory invoked oom-killer: gfp_mask=0xd0, order=0, oomkilladj=-17
[  740.746675] big_memory cpuset=/ mems_allowed=0
[  740.746884] Pid: 2801, comm: big_memory Not tainted 2.6.30-rc7 #1
[  740.747093] Call Trace:
[  740.747301]  [<ffffffff8029b3a0>] ? cpuset_print_task_mems_allowed+0x92/0x9d
[  740.747564]  [<ffffffff802d2bc3>] oom_kill_process+0xae/0x366
[  740.747775]  [<ffffffff802d3289>] ? select_bad_process+0xab/0x228
[  740.747987]  [<ffffffff802d38fc>] mem_cgroup_out_of_memory+0xbc/0xf8
[  740.748201]  [<ffffffff8031f228>] __mem_cgroup_try_charge+0x2db/0x318
[  740.748414]  [<ffffffff803200cd>] mem_cgroup_charge_common+0x74/0xbe
[  740.748676]  [<ffffffff803201f8>] mem_cgroup_newpage_charge+0xe1/0xee
[  740.748889]  [<ffffffff802f01fc>] handle_mm_fault+0x316/0xb6c
[  740.749102]  [<ffffffff8072fe2f>] do_page_fault+0x55a/0x5e4
[  740.749313]  [<ffffffff8072c74a>] ? trace_hardirqs_off_thunk+0x3a/0x6c
[  740.749575]  [<ffffffff8072cfaf>] page_fault+0x1f/0x30
[  740.749784] Task in /important killed as a result of limit of /important
[  740.750031] memory: usage 0kB, limit 256000kB, failcnt 1467
[  740.750239] memory+swap: usage 512000kB, limit 512000kB, failcnt 571
[  740.750448] Mem-Info:
[  740.750699] Node 0 DMA per-cpu:
[  740.750940] CPU    0: hi:    0, btch:   1 usd:   0
[  740.751147] CPU    1: hi:    0, btch:   1 usd:   0
[  740.751354] CPU    2: hi:    0, btch:   1 usd:   0
[  740.751611] CPU    3: hi:    0, btch:   1 usd:   0
[  740.751817] Node 0 DMA32 per-cpu:
[  740.752057] CPU    0: hi:  186, btch:  31 usd: 183
[  740.752264] CPU    1: hi:  186, btch:  31 usd:  29
[  740.752471] CPU    2: hi:  186, btch:  31 usd:   0
[  740.752725] CPU    3: hi:  186, btch:  31 usd:   0
[  740.752932] Node 0 Normal per-cpu:
[  740.753172] CPU    0: hi:  186, btch:  31 usd: 172
[  740.753380] CPU    1: hi:  186, btch:  31 usd: 185
[  740.753636] CPU    2: hi:  186, btch:  31 usd:  92
[  740.753843] CPU    3: hi:  186, btch:  31 usd: 102
[  740.754054] Active_anon:32254 active_file:67379 inactive_anon:48
[  740.754056]  inactive_file:24909 unevictable:3 dirty:0 writeback:0 unstable:0
[  740.754058]  free:1367086 slab:7269 mapped:10228 pagetables:5377 bounce:0
[  740.754730] Node 0 DMA free:2108kB min:24kB low:28kB high:36kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:15288kB pages_scanned:0 all_unreclaimable? no
[  740.755322] lowmem_reserve[]: 0 2990 6020 6020
[  740.755753] Node 0 DMA32 free:2903748kB min:4924kB low:6152kB high:7384kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:3062496kB pages_scanned:0 all_unreclaimable? no
[  740.756347] lowmem_reserve[]: 0 0 3030 3030
[  740.756780] Node 0 Normal free:2562488kB min:4992kB low:6240kB high:7488kB active_anon:129016kB inactive_anon:192kB active_file:269516kB inactive_file:99636kB unevictable:12kB present:3102720kB pages_scanned:0 all_unreclaimable? no
[  740.757377] lowmem_reserve[]: 0 0 0 0
[  740.757808] Node 0 DMA: 5*4kB 3*8kB 3*16kB 3*32kB 2*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2108kB
[  740.758695] Node 0 DMA32: 5*4kB 4*8kB 1*16kB 2*32kB 3*64kB 3*128kB 2*256kB 5*512kB 4*1024kB 6*2048kB 704*4096kB = 2903748kB
[  740.759586] Node 0 Normal: 181*4kB 105*8kB 63*16kB 38*32kB 26*64kB 25*128kB 12*256kB 12*512kB 7*1024kB 7*2048kB 616*4096kB = 2562508kB
[  740.760433] 92966 total pagecache pages
[  740.760687] 15 pages in swap cache
[  740.760893] Swap cache stats: add 128026, delete 128011, find 5/8
[  740.761101] Free swap  = 1584472kB
[  740.761305] Total swap = 2096472kB
[  740.868764] 1572848 pages RAM
[  740.868970] 59696 pages reserved
[  740.869174] 56855 pages shared
[  740.869377] 131436 pages non-shared
[  740.869634] Memory cgroup out of memory: kill process 2801 (big_memory) score 0 or a child
[  740.870066] big_memory invoked oom-killer: gfp_mask=0xd0, order=0, oomkilladj=-17
[  740.870440] big_memory cpuset=/ mems_allowed=0
[  740.870696] Pid: 2801, comm: big_memory Not tainted 2.6.30-rc7 #1
[  740.870906] Call Trace:
[  740.871114]  [<ffffffff8029b3a0>] ? cpuset_print_task_mems_allowed+0x92/0x9d
[  740.871330]  [<ffffffff802d2bc3>] oom_kill_process+0xae/0x366
[  740.871588]  [<ffffffff802d3289>] ? select_bad_process+0xab/0x228
[  740.871800]  [<ffffffff802d38fc>] mem_cgroup_out_of_memory+0xbc/0xf8
[  740.872015]  [<ffffffff8031f228>] __mem_cgroup_try_charge+0x2db/0x318
[  740.872227]  [<ffffffff803200cd>] mem_cgroup_charge_common+0x74/0xbe
[  740.876510]  [<ffffffff803201f8>] mem_cgroup_newpage_charge+0xe1/0xee
[  740.876723]  [<ffffffff802f01fc>] handle_mm_fault+0x316/0xb6c
[  740.876935]  [<ffffffff8072fe2f>] do_page_fault+0x55a/0x5e4
[  740.877146]  [<ffffffff8072c74a>] ? trace_hardirqs_off_thunk+0x3a/0x6c
[  740.877359]  [<ffffffff8072cfaf>] page_fault+0x1f/0x30
[  740.877614] Task in /important killed as a result of limit of /important
[  740.877861] memory: usage 0kB, limit 256000kB, failcnt 1467
[  740.878069] memory+swap: usage 512000kB, limit 512000kB, failcnt 571
[  740.878279] Mem-Info:
[  740.878480] Node 0 DMA per-cpu:
[  740.878770] CPU    0: hi:    0, btch:   1 usd:   0
[  740.878978] CPU    1: hi:    0, btch:   1 usd:   0
[  740.879185] CPU    2: hi:    0, btch:   1 usd:   0
[  740.879392] CPU    3: hi:    0, btch:   1 usd:   0
[  740.879644] Node 0 DMA32 per-cpu:
[  740.879886] CPU    0: hi:  186, btch:  31 usd: 183
[  740.880093] CPU    1: hi:  186, btch:  31 usd:  29
[  740.880300] CPU    2: hi:  186, btch:  31 usd:   0
[  740.880555] CPU    3: hi:  186, btch:  31 usd:   0
[  740.880762] Node 0 Normal per-cpu:
[  740.881002] CPU    0: hi:  186, btch:  31 usd: 172
[  740.881209] CPU    1: hi:  186, btch:  31 usd: 185
[  740.881417] CPU    2: hi:  186, btch:  31 usd:  91
[  740.881670] CPU    3: hi:  186, btch:  31 usd: 102
[  740.881881] Active_anon:32254 active_file:67379 inactive_anon:48
[  740.881883]  inactive_file:24909 unevictable:3 dirty:0 writeback:0 unstable:0
[  740.881885]  free:1367086 slab:7269 mapped:10228 pagetables:5377 bounce:0
[  740.882554] Node 0 DMA free:2108kB min:24kB low:28kB high:36kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:15288kB pages_scanned:0 all_unreclaimable? no
[  740.883146] lowmem_reserve[]: 0 2990 6020 6020
[  740.883576] Node 0 DMA32 free:2903748kB min:4924kB low:6152kB high:7384kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:3062496kB pages_scanned:0 all_unreclaimable? no
[  740.884170] lowmem_reserve[]: 0 0 3030 3030
[  740.884598] Node 0 Normal free:2562488kB min:4992kB low:6240kB high:7488kB active_anon:129016kB inactive_anon:192kB active_file:269516kB inactive_file:99636kB unevictable:12kB present:3102720kB pages_scanned:0 all_unreclaimable? no
[  740.885197] lowmem_reserve[]: 0 0 0 0
[  740.885628] Node 0 DMA: 5*4kB 3*8kB 3*16kB 3*32kB 2*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2108kB
[  740.886472] Node 0 DMA32: 5*4kB 4*8kB 1*16kB 2*32kB 3*64kB 3*128kB 2*256kB 5*512kB 4*1024kB 6*2048kB 704*4096kB = 2903748kB
[  740.887364] Node 0 Normal: 181*4kB 105*8kB 63*16kB 38*32kB 26*64kB 25*128kB 12*256kB 12*512kB 7*1024kB 7*2048kB 616*4096kB = 2562508kB
[  740.888257] 92966 total pagecache pages
[  740.888462] 15 pages in swap cache
[  740.888715] Swap cache stats: add 128026, delete 128011, find 5/8
[  740.888924] Free swap  = 1584472kB
[  740.889129] Total swap = 2096472kB
[  740.996590] 1572848 pages RAM
[  740.996796] 59696 pages reserved
[  740.996999] 56859 pages shared
[  740.997203] 131436 pages non-shared
[  740.997408] Memory cgroup out of memory: kill process 2801 (big_memory) score 0 or a child
[  740.997893] big_memory invoked oom-killer: gfp_mask=0xd0, order=0, oomkilladj=-17
[  740.998268] big_memory cpuset=/ mems_allowed=0
[  740.998476] Pid: 2801, comm: big_memory Not tainted 2.6.30-rc7 #1
[  740.998734] Call Trace:
[  740.998944]  [<ffffffff8029b3a0>] ? cpuset_print_task_mems_allowed+0x92/0x9d
[  740.999160]  [<ffffffff802d2bc3>] oom_kill_process+0xae/0x366
[  740.999370]  [<ffffffff802d3289>] ? select_bad_process+0xab/0x228
[  740.999628]  [<ffffffff802d38fc>] mem_cgroup_out_of_memory+0xbc/0xf8
[  740.999842]  [<ffffffff8031f228>] __mem_cgroup_try_charge+0x2db/0x318
[  741.000054]  [<ffffffff803200cd>] mem_cgroup_charge_common+0x74/0xbe
[  741.000266]  [<ffffffff803201f8>] mem_cgroup_newpage_charge+0xe1/0xee
[  741.000478]  [<ffffffff802f01fc>] handle_mm_fault+0x316/0xb6c
[  741.000737]  [<ffffffff8072fe2f>] do_page_fault+0x55a/0x5e4
[  741.000949]  [<ffffffff8072c74a>] ? trace_hardirqs_off_thunk+0x3a/0x6c
[  741.001161]  [<ffffffff8072cfaf>] page_fault+0x1f/0x30
[  741.001370] Task in /important killed as a result of limit of /important
[  741.001664] memory: usage 0kB, limit 256000kB, failcnt 1467
[  741.001873] memory+swap: usage 512000kB, limit 512000kB, failcnt 571
[  741.002082] Mem-Info:
[  741.002284] Node 0 DMA per-cpu:
[  741.002569] CPU    0: hi:    0, btch:   1 usd:   0
[  741.002776] CPU    1: hi:    0, btch:   1 usd:   0
[  741.002983] CPU    2: hi:    0, btch:   1 usd:   0
[  741.003191] CPU    3: hi:    0, btch:   1 usd:   0
[  741.003397] Node 0 DMA32 per-cpu:
[  741.003682] CPU    0: hi:  186, btch:  31 usd: 183
[  741.003890] CPU    1: hi:  186, btch:  31 usd:  29
[  741.004097] CPU    2: hi:  186, btch:  31 usd:   0
[  741.004304] CPU    3: hi:  186, btch:  31 usd:   0
[  741.004555] Node 0 Normal per-cpu:
[  741.004796] CPU    0: hi:  186, btch:  31 usd: 172
[  741.005004] CPU    1: hi:  186, btch:  31 usd: 185
[  741.005210] CPU    2: hi:  186, btch:  31 usd:  90
[  741.005418] CPU    3: hi:  186, btch:  31 usd: 102
[  741.005674] Active_anon:32254 active_file:67379 inactive_anon:48
[  741.005676]  inactive_file:24909 unevictable:3 dirty:0 writeback:0 unstable:0
[  741.005678]  free:1367086 slab:7269 mapped:10228 pagetables:5377 bounce:0
[  741.006302] Node 0 DMA free:2108kB min:24kB low:28kB high:36kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:15288kB pages_scanned:0 all_unreclaimable? no
[  741.006940] lowmem_reserve[]: 0 2990 6020 6020
[  741.007325] Node 0 DMA32 free:2903748kB min:4924kB low:6152kB high:7384kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:3062496kB pages_scanned:0 all_unreclaimable? no
[  741.007963] lowmem_reserve[]: 0 0 3030 3030
[  741.008347] Node 0 Normal free:2562488kB min:4992kB low:6240kB high:7488kB active_anon:129016kB inactive_anon:192kB active_file:269516kB inactive_file:99636kB unevictable:12kB present:3102720kB pages_scanned:0 all_unreclaimable? no
[  741.008992] lowmem_reserve[]: 0 0 0 0
[  741.009375] Node 0 DMA: 5*4kB 3*8kB 3*16kB 3*32kB 2*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2108kB
[  741.010270] Node 0 DMA32: 5*4kB 4*8kB 1*16kB 2*32kB 3*64kB 3*128kB 2*256kB 5*512kB 4*1024kB 6*2048kB 704*4096kB = 2903748kB
[  741.011161] Node 0 Normal: 181*4kB 105*8kB 63*16kB 38*32kB 26*64kB 25*128kB 12*256kB 12*512kB 7*1024kB 7*2048kB 616*4096kB = 2562508kB
[  741.012055] 92966 total pagecache pages
[  741.012260] 15 pages in swap cache
[  741.012465] Swap cache stats: add 128026, delete 128011, find 5/8
[  741.012721] Free swap  = 1584472kB
[  741.012925] Total swap = 2096472kB
[  741.120400] 1572848 pages RAM
[  741.120659] 59696 pages reserved
[  741.120864] 56861 pages shared
[  741.121067] 131436 pages non-shared
[  741.121272] Memory cgroup out of memory: kill process 2801 (big_memory) score 0 or a child
[  741.121723] big_memory invoked oom-killer: gfp_mask=0xd0, order=0, oomkilladj=-17
[  741.122098] big_memory cpuset=/ mems_allowed=0
[  741.122306] Pid: 2801, comm: big_memory Not tainted 2.6.30-rc7 #1
[  741.122564] Call Trace:
[  741.122775]  [<ffffffff8029b3a0>] ? cpuset_print_task_mems_allowed+0x92/0x9d
[  741.122990]  [<ffffffff802d2bc3>] oom_kill_process+0xae/0x366
[  741.123201]  [<ffffffff802d3289>] ? select_bad_process+0xab/0x228
[  741.123413]  [<ffffffff802d38fc>] mem_cgroup_out_of_memory+0xbc/0xf8
[  741.123671]  [<ffffffff8031f228>] __mem_cgroup_try_charge+0x2db/0x318
[  741.123883]  [<ffffffff803200cd>] mem_cgroup_charge_common+0x74/0xbe
[  741.124096]  [<ffffffff803201f8>] mem_cgroup_newpage_charge+0xe1/0xee
[  741.124308]  [<ffffffff802f01fc>] handle_mm_fault+0x316/0xb6c
[  741.124568]  [<ffffffff8072fe2f>] do_page_fault+0x55a/0x5e4
[  741.124780]  [<ffffffff8072c74a>] ? trace_hardirqs_off_thunk+0x3a/0x6c
[  741.124993]  [<ffffffff8072cfaf>] page_fault+0x1f/0x30
[  741.125202] Task in /important killed as a result of limit of /important
[  741.125449] memory: usage 0kB, limit 256000kB, failcnt 1467
[  741.125705] memory+swap: usage 512000kB, limit 512000kB, failcnt 571
[  741.125914] Mem-Info:
[  741.126116] Node 0 DMA per-cpu:
[  741.126356] CPU    0: hi:    0, btch:   1 usd:   0
[  741.126610] CPU    1: hi:    0, btch:   1 usd:   0
[  741.126817] CPU    2: hi:    0, btch:   1 usd:   0
[  741.127024] CPU    3: hi:    0, btch:   1 usd:   0
[  741.127231] Node 0 DMA32 per-cpu:
[  741.127471] CPU    0: hi:  186, btch:  31 usd: 183
[  741.127723] CPU    1: hi:  186, btch:  31 usd:  29
[  741.127931] CPU    2: hi:  186, btch:  31 usd:   0
[  741.128138] CPU    3: hi:  186, btch:  31 usd:   0
[  741.128344] Node 0 Normal per-cpu:
[  741.128629] CPU    0: hi:  186, btch:  31 usd: 172
[  741.128836] CPU    1: hi:  186, btch:  31 usd: 185
[  741.129043] CPU    2: hi:  186, btch:  31 usd:  88
[  741.129251] CPU    3: hi:  186, btch:  31 usd: 102
[  741.129461] Active_anon:32254 active_file:67379 inactive_anon:48
[  741.129463]  inactive_file:24909 unevictable:3 dirty:0 writeback:0 unstable:0
[  741.129466]  free:1367086 slab:7269 mapped:10228 pagetables:5377 bounce:0
[  741.130135] Node 0 DMA free:2108kB min:24kB low:28kB high:36kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:15288kB pages_scanned:0 all_unreclaimable? no
[  741.130777] lowmem_reserve[]: 0 2990 6020 6020
[  741.131162] Node 0 DMA32 free:2903748kB min:4924kB low:6152kB high:7384kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:3062496kB pages_scanned:0 all_unreclaimable? no
[  741.131803] lowmem_reserve[]: 0 0 3030 3030
[  741.132188] Node 0 Normal free:2562488kB min:4992kB low:6240kB high:7488kB active_anon:129016kB inactive_anon:192kB active_file:269516kB inactive_file:99636kB unevictable:12kB present:3102720kB pages_scanned:0 all_unreclaimable? no
[  741.132832] lowmem_reserve[]: 0 0 0 0
[  741.133215] Node 0 DMA: 5*4kB 3*8kB 3*16kB 3*32kB 2*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2108kB
[  741.134106] Node 0 DMA32: 5*4kB 4*8kB 1*16kB 2*32kB 3*64kB 3*128kB 2*256kB 5*512kB 4*1024kB 6*2048kB 704*4096kB = 2903748kB
[  741.134999] Node 0 Normal: 181*4kB 105*8kB 63*16kB 38*32kB 26*64kB 25*128kB 12*256kB 12*512kB 7*1024kB 7*2048kB 616*4096kB = 2562508kB
[  741.135896] 92966 total pagecache pages
[  741.140165] 15 pages in swap cache
[  741.140370] Swap cache stats: add 128026, delete 128011, find 5/8
[  741.140624] Free swap  = 1584472kB
[  741.140828] Total swap = 2096472kB
[  741.248279] 1572848 pages RAM
[  741.248486] 59696 pages reserved
[  741.248737] 56863 pages shared
[  741.248941] 131436 pages non-shared
[  741.249147] Memory cgroup out of memory: kill process 2801 (big_memory) score 0 or a child
[  741.249627] big_memory invoked oom-killer: gfp_mask=0xd0, order=0, oomkilladj=-17
[  741.250002] big_memory cpuset=/ mems_allowed=0
[  741.250209] Pid: 2801, comm: big_memory Not tainted 2.6.30-rc7 #1
[  741.250418] Call Trace:
[  741.250677]  [<ffffffff8029b3a0>] ? cpuset_print_task_mems_allowed+0x92/0x9d
[  741.250894]  [<ffffffff802d2bc3>] oom_kill_process+0xae/0x366
[  741.251104]  [<ffffffff802d3289>] ? select_bad_process+0xab/0x228
[  741.251316]  [<ffffffff802d38fc>] mem_cgroup_out_of_memory+0xbc/0xf8
[  741.251580]  [<ffffffff8031f228>] __mem_cgroup_try_charge+0x2db/0x318
[  741.251792]  [<ffffffff803200cd>] mem_cgroup_charge_common+0x74/0xbe
[  741.252005]  [<ffffffff803201f8>] mem_cgroup_newpage_charge+0xe1/0xee
[  741.252217]  [<ffffffff802f01fc>] handle_mm_fault+0x316/0xb6c
[  741.252429]  [<ffffffff8072fe2f>] do_page_fault+0x55a/0x5e4
[  741.252686]  [<ffffffff8072c74a>] ? trace_hardirqs_off_thunk+0x3a/0x6c
[  741.252899]  [<ffffffff8072cfaf>] page_fault+0x1f/0x30
[  741.253109] Task in /important killed as a result of limit of /important
[  741.253355] memory: usage 0kB, limit 256000kB, failcnt 1467
[  741.253607] memory+swap: usage 512000kB, limit 512000kB, failcnt 571
[  741.253817] Mem-Info:
[  741.254019] Node 0 DMA per-cpu:
[  741.254260] CPU    0: hi:    0, btch:   1 usd:   0
[  741.254467] CPU    1: hi:    0, btch:   1 usd:   0
[  741.254721] CPU    2: hi:    0, btch:   1 usd:   0
[  741.254929] CPU    3: hi:    0, btch:   1 usd:   0
[  741.255136] Node 0 DMA32 per-cpu:
[  741.255376] CPU    0: hi:  186, btch:  31 usd: 183
[  741.255633] CPU    1: hi:  186, btch:  31 usd:  29
[  741.255840] CPU    2: hi:  186, btch:  31 usd:   0
[  741.256047] CPU    3: hi:  186, btch:  31 usd:   0
[  741.256253] Node 0 Normal per-cpu:
[  741.256538] CPU    0: hi:  186, btch:  31 usd: 172
[  741.256745] CPU    1: hi:  186, btch:  31 usd: 185
[  741.256952] CPU    2: hi:  186, btch:  31 usd:  87
[  741.257159] CPU    3: hi:  186, btch:  31 usd: 102
[  741.257370] Active_anon:32254 active_file:67379 inactive_anon:48
[  741.257372]  inactive_file:24909 unevictable:3 dirty:0 writeback:0 unstable:0
[  741.257374]  free:1367086 slab:7269 mapped:10228 pagetables:5377 bounce:0
[  741.258044] Node 0 DMA free:2108kB min:24kB low:28kB high:36kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:15288kB pages_scanned:0 all_unreclaimable? no
[  741.258687] lowmem_reserve[]: 0 2990 6020 6020
[  741.259071] Node 0 DMA32 free:2903748kB min:4924kB low:6152kB high:7384kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:3062496kB pages_scanned:0 all_unreclaimable? no
[  741.259712] lowmem_reserve[]: 0 0 3030 3030
[  741.260096] Node 0 Normal free:2562488kB min:4992kB low:6240kB high:7488kB active_anon:129016kB inactive_anon:192kB active_file:269516kB inactive_file:99636kB unevictable:12kB present:3102720kB pages_scanned:0 all_unreclaimable? no
[  741.260741] lowmem_reserve[]: 0 0 0 0
[  741.261125] Node 0 DMA: 5*4kB 3*8kB 3*16kB 3*32kB 2*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2108kB
[  741.262017] Node 0 DMA32: 5*4kB 4*8kB 1*16kB 2*32kB 3*64kB 3*128kB 2*256kB 5*512kB 4*1024kB 6*2048kB 704*4096kB = 2903748kB
[  741.262909] Node 0 Normal: 181*4kB 105*8kB 63*16kB 38*32kB 26*64kB 25*128kB 12*256kB 12*512kB 7*1024kB 7*2048kB 616*4096kB = 2562508kB
[  741.263798] 92966 total pagecache pages
[  741.264003] 15 pages in swap cache
[  741.264207] Swap cache stats: add 128026, delete 128011, find 5/8
[  741.264416] Free swap  = 1584472kB
[  741.264668] Total swap = 2096472kB
[  741.372119] 1572848 pages RAM
[  741.372327] 59696 pages reserved
[  741.372581] 56867 pages shared
[  741.372785] 131436 pages non-shared
[  741.372990] Memory cgroup out of memory: kill process 2801 (big_memory) score 0 or a child
[  741.373422] big_memory invoked oom-killer: gfp_mask=0xd0, order=0, oomkilladj=-17
[  741.373847] big_memory cpuset=/ mems_allowed=0
[  741.374055] Pid: 2801, comm: big_memory Not tainted 2.6.30-rc7 #1
[  741.374264] Call Trace:
[  741.374473]  [<ffffffff8029b3a0>] ? cpuset_print_task_mems_allowed+0x92/0x9d
[  741.374735]  [<ffffffff802d2bc3>] oom_kill_process+0xae/0x366
[  741.374946]  [<ffffffff802d3289>] ? select_bad_process+0xab/0x228
[  741.375158]  [<ffffffff802d38fc>] mem_cgroup_out_of_memory+0xbc/0xf8
[  741.375372]  [<ffffffff8031f228>] __mem_cgroup_try_charge+0x2db/0x318
[  741.375630]  [<ffffffff803200cd>] mem_cgroup_charge_common+0x74/0xbe
[  741.375843]  [<ffffffff803201f8>] mem_cgroup_newpage_charge+0xe1/0xee
[  741.376055]  [<ffffffff802f01fc>] handle_mm_fault+0x316/0xb6c
[  741.376267]  [<ffffffff8072fe2f>] do_page_fault+0x55a/0x5e4
[  741.376479]  [<ffffffff8072c74a>] ? trace_hardirqs_off_thunk+0x3a/0x6c
[  741.376738]  [<ffffffff8072cfaf>] page_fault+0x1f/0x30
[  741.376948] Task in /important killed as a result of limit of /important
[  741.377195] memory: usage 0kB, limit 256000kB, failcnt 1467
[  741.377403] memory+swap: usage 512000kB, limit 512000kB, failcnt 571
[  741.377659] Mem-Info:
[  741.377862] Node 0 DMA per-cpu:
[  741.378102] CPU    0: hi:    0, btch:   1 usd:   0
[  741.378309] CPU    1: hi:    0, btch:   1 usd:   0
[  741.378560] CPU    2: hi:    0, btch:   1 usd:   0
[  741.378768] CPU    3: hi:    0, btch:   1 usd:   0
[  741.378974] Node 0 DMA32 per-cpu:
[  741.379214] CPU    0: hi:  186, btch:  31 usd: 183
[  741.379422] CPU    1: hi:  186, btch:  31 usd:  29
[  741.379673] CPU    2: hi:  186, btch:  31 usd:   0
[  741.379881] CPU    3: hi:  186, btch:  31 usd:   0
[  741.380087] Node 0 Normal per-cpu:
[  741.380328] CPU    0: hi:  186, btch:  31 usd: 172
[  741.380580] CPU    1: hi:  186, btch:  31 usd: 185
[  741.380788] CPU    2: hi:  186, btch:  31 usd:  85
[  741.380995] CPU    3: hi:  186, btch:  31 usd: 102
[  741.381206] Active_anon:32254 active_file:67379 inactive_anon:48
[  741.381208]  inactive_file:24909 unevictable:3 dirty:0 writeback:0 unstable:0
[  741.381210]  free:1367086 slab:7269 mapped:10228 pagetables:5377 bounce:0
[  741.381882] Node 0 DMA free:2108kB min:24kB low:28kB high:36kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:15288kB pages_scanned:0 all_unreclaimable? no
[  741.382475] lowmem_reserve[]: 0 2990 6020 6020
[  741.382908] Node 0 DMA32 free:2903748kB min:4924kB low:6152kB high:7384kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:3062496kB pages_scanned:0 all_unreclaimable? no
[  741.383546] lowmem_reserve[]: 0 0 3030 3030
[  741.383930] Node 0 Normal free:2562488kB min:4992kB low:6240kB high:7488kB active_anon:129016kB inactive_anon:192kB active_file:269516kB inactive_file:99636kB unevictable:12kB present:3102720kB pages_scanned:0 all_unreclaimable? no
[  741.384576] lowmem_reserve[]: 0 0 0 0
[  741.384959] Node 0 DMA: 5*4kB 3*8kB 3*16kB 3*32kB 2*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2108kB
[  741.385851] Node 0 DMA32: 5*4kB 4*8kB 1*16kB 2*32kB 3*64kB 3*128kB 2*256kB 5*512kB 4*1024kB 6*2048kB 704*4096kB = 2903748kB
[  741.386743] Node 0 Normal: 181*4kB 105*8kB 63*16kB 38*32kB 26*64kB 25*128kB 12*256kB 12*512kB 7*1024kB 7*2048kB 616*4096kB = 2562508kB
[  741.387638] 92966 total pagecache pages
[  741.387843] 15 pages in swap cache
[  741.388048] Swap cache stats: add 128026, delete 128011, find 5/8
[  741.388257] Free swap  = 1584472kB
[  741.388460] Total swap = 2096472kB
[  741.495931] 1572848 pages RAM
[  741.496138] 59696 pages reserved
[  741.496341] 56869 pages shared
[  741.496591] 131436 pages non-shared
[  741.496798] Memory cgroup out of memory: kill process 2801 (big_memory) score 0 or a child
[  741.497229] big_memory invoked oom-killer: gfp_mask=0xd0, order=0, oomkilladj=-17
[  741.497653] big_memory cpuset=/ mems_allowed=0
[  741.497862] Pid: 2801, comm: big_memory Not tainted 2.6.30-rc7 #1
[  741.498070] Call Trace:
[  741.498279]  [<ffffffff8029b3a0>] ? cpuset_print_task_mems_allowed+0x92/0x9d
[  741.498544]  [<ffffffff802d2bc3>] oom_kill_process+0xae/0x366
[  741.498755]  [<ffffffff802d3289>] ? select_bad_process+0xab/0x228
[  741.498967]  [<ffffffff802d38fc>] mem_cgroup_out_of_memory+0xbc/0xf8
[  741.499180]  [<ffffffff8031f228>] __mem_cgroup_try_charge+0x2db/0x318
[  741.499393]  [<ffffffff803200cd>] mem_cgroup_charge_common+0x74/0xbe
[  741.499654]  [<ffffffff803201f8>] mem_cgroup_newpage_charge+0xe1/0xee
[  741.499867]  [<ffffffff802f01fc>] handle_mm_fault+0x316/0xb6c
[  741.500080]  [<ffffffff8072fe2f>] do_page_fault+0x55a/0x5e4
[  741.500291]  [<ffffffff8072c74a>] ? trace_hardirqs_off_thunk+0x3a/0x6c
[  741.500549]  [<ffffffff8072cfaf>] page_fault+0x1f/0x30
[  741.500758] Task in /important killed as a result of limit of /important
[  741.501005] memory: usage 0kB, limit 256000kB, failcnt 1467
[  741.501214] memory+swap: usage 512000kB, limit 512000kB, failcnt 571
[  741.501422] Mem-Info:
[  741.501670] Node 0 DMA per-cpu:
[  741.501912] CPU    0: hi:    0, btch:   1 usd:   0
[  741.502119] CPU    1: hi:    0, btch:   1 usd:   0
[  741.502326] CPU    2: hi:    0, btch:   1 usd:   0
[  741.502577] CPU    3: hi:    0, btch:   1 usd:   0
[  741.502784] Node 0 DMA32 per-cpu:
[  741.503024] CPU    0: hi:  186, btch:  31 usd: 183
[  741.503231] CPU    1: hi:  186, btch:  31 usd:  29
[  741.503438] CPU    2: hi:  186, btch:  31 usd:   0
[  741.503689] CPU    3: hi:  186, btch:  31 usd:   0
[  741.503896] Node 0 Normal per-cpu:
[  741.504136] CPU    0: hi:  186, btch:  31 usd: 172
[  741.504343] CPU    1: hi:  186, btch:  31 usd: 185
[  741.504596] CPU    2: hi:  186, btch:  31 usd:  84
[  741.504803] CPU    3: hi:  186, btch:  31 usd: 102
[  741.505014] Active_anon:32254 active_file:67379 inactive_anon:48
[  741.505016]  inactive_file:24909 unevictable:3 dirty:10 writeback:0 unstable:0
[  741.505018]  free:1367086 slab:7269 mapped:10228 pagetables:5377 bounce:0
[  741.509866] Node 0 DMA free:2108kB min:24kB low:28kB high:36kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:15288kB pages_scanned:0 all_unreclaimable? no
[  741.510459] lowmem_reserve[]: 0 2990 6020 6020
[  741.510891] Node 0 DMA32 free:2903748kB min:4924kB low:6152kB high:7384kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:3062496kB pages_scanned:0 all_unreclaimable? no
[  741.511485] lowmem_reserve[]: 0 0 3030 3030
[  741.511918] Node 0 Normal free:2562488kB min:4992kB low:6240kB high:7488kB active_anon:129016kB inactive_anon:192kB active_file:269516kB inactive_file:99636kB unevictable:12kB present:3102720kB pages_scanned:0 all_unreclaimable? no
[  741.512565] lowmem_reserve[]: 0 0 0 0
[  741.512948] Node 0 DMA: 5*4kB 3*8kB 3*16kB 3*32kB 2*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2108kB
[  741.513837] Node 0 DMA32: 5*4kB 4*8kB 1*16kB 2*32kB 3*64kB 3*128kB 2*256kB 5*512kB 4*1024kB 6*2048kB 704*4096kB = 2903748kB
[  741.514727] Node 0 Normal: 181*4kB 105*8kB 63*16kB 38*32kB 26*64kB 25*128kB 12*256kB 12*512kB 7*1024kB 7*2048kB 616*4096kB = 2562508kB
[  741.515620] 92975 total pagecache pages
[  741.515826] 15 pages in swap cache
[  741.516030] Swap cache stats: add 128026, delete 128011, find 5/8
[  741.516239] Free swap  = 1584472kB
[  741.516443] Total swap = 2096472kB
[  741.623909] 1572848 pages RAM
[  741.624116] 59696 pages reserved
[  741.624319] 56873 pages shared
[  741.624571] 131436 pages non-shared
[  741.624778] Memory cgroup out of memory: kill process 2801 (big_memory) score 0 or a child
[  741.625209] big_memory invoked oom-killer: gfp_mask=0xd0, order=0, oomkilladj=-17
[  741.625629] big_memory cpuset=/ mems_allowed=0
[  741.625837] Pid: 2801, comm: big_memory Not tainted 2.6.30-rc7 #1
[  741.626046] Call Trace:
[  741.626255]  [<ffffffff8029b3a0>] ? cpuset_print_task_mems_allowed+0x92/0x9d
[  741.626471]  [<ffffffff802d2bc3>] oom_kill_process+0xae/0x366
[  741.626736]  [<ffffffff802d3289>] ? select_bad_process+0xab/0x228
[  741.626948]  [<ffffffff802d38fc>] mem_cgroup_out_of_memory+0xbc/0xf8
[  741.627162]  [<ffffffff8031f228>] __mem_cgroup_try_charge+0x2db/0x318
[  741.627374]  [<ffffffff803200cd>] mem_cgroup_charge_common+0x74/0xbe
[  741.627636]  [<ffffffff803201f8>] mem_cgroup_newpage_charge+0xe1/0xee
[  741.627849]  [<ffffffff802f01fc>] handle_mm_fault+0x316/0xb6c
[  741.628061]  [<ffffffff8072fe2f>] do_page_fault+0x55a/0x5e4
[  741.628273]  [<ffffffff8072c74a>] ? trace_hardirqs_off_thunk+0x3a/0x6c
[  741.628485]  [<ffffffff8072cfaf>] page_fault+0x1f/0x30
[  741.628742] Task in /important killed as a result of limit of /important
[  741.628989] memory: usage 0kB, limit 256000kB, failcnt 1467
[  741.629197] memory+swap: usage 512000kB, limit 512000kB, failcnt 571
[  741.629406] Mem-Info:
[  741.629652] Node 0 DMA per-cpu:
[  741.629893] CPU    0: hi:    0, btch:   1 usd:   0
[  741.630101] CPU    1: hi:    0, btch:   1 usd:   0
[  741.630307] CPU    2: hi:    0, btch:   1 usd:   0
[  741.630565] CPU    3: hi:    0, btch:   1 usd:   0
[  741.630771] Node 0 DMA32 per-cpu:
[  741.631012] CPU    0: hi:  186, btch:  31 usd: 183
[  741.631219] CPU    1: hi:  186, btch:  31 usd:  29
[  741.631426] CPU    2: hi:  186, btch:  31 usd:   0
[  741.631679] CPU    3: hi:  186, btch:  31 usd:   0
[  741.631885] Node 0 Normal per-cpu:
[  741.632126] CPU    0: hi:  186, btch:  31 usd: 171
[  741.632333] CPU    1: hi:  186, btch:  31 usd: 185
[  741.632590] CPU    2: hi:  186, btch:  31 usd:  83
[  741.632797] CPU    3: hi:  186, btch:  31 usd: 102
[  741.633008] Active_anon:32254 active_file:67379 inactive_anon:48
[  741.633010]  inactive_file:24909 unevictable:3 dirty:10 writeback:0 unstable:0
[  741.633012]  free:1367086 slab:7269 mapped:10228 pagetables:5377 bounce:0
[  741.633845] Node 0 DMA free:2108kB min:24kB low:28kB high:36kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:15288kB pages_scanned:0 all_unreclaimable? no
[  741.634438] lowmem_reserve[]: 0 2990 6020 6020
[  741.634868] Node 0 DMA32 free:2903748kB min:4924kB low:6152kB high:7384kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:3062496kB pages_scanned:0 all_unreclaimable? no
[  741.635462] lowmem_reserve[]: 0 0 3030 3030
[  741.635891] Node 0 Normal free:2562488kB min:4992kB low:6240kB high:7488kB active_anon:129016kB inactive_anon:192kB active_file:269516kB inactive_file:99636kB unevictable:12kB present:3102720kB pages_scanned:0 all_unreclaimable? no
[  741.636488] lowmem_reserve[]: 0 0 0 0
[  741.636918] Node 0 DMA: 5*4kB 3*8kB 3*16kB 3*32kB 2*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2108kB
[  741.637810] Node 0 DMA32: 5*4kB 4*8kB 1*16kB 2*32kB 3*64kB 3*128kB 2*256kB 5*512kB 4*1024kB 6*2048kB 704*4096kB = 2903748kB
[  741.638699] Node 0 Normal: 181*4kB 105*8kB 63*16kB 38*32kB 26*64kB 25*128kB 12*256kB 12*512kB 7*1024kB 7*2048kB 616*4096kB = 2562508kB
[  741.639591] 92975 total pagecache pages
[  741.639796] 15 pages in swap cache
[  741.640001] Swap cache stats: add 128026, delete 128011, find 5/8
[  741.640210] Free swap  = 1584472kB
[  741.640413] Total swap = 2096472kB
[  741.747866] 1572848 pages RAM
[  741.748073] 59696 pages reserved
[  741.748276] 56876 pages shared
[  741.748479] 131436 pages non-shared
[  741.748735] Memory cgroup out of memory: kill process 2801 (big_memory) score 0 or a child
[  741.749167] big_memory invoked oom-killer: gfp_mask=0xd0, order=0, oomkilladj=-17
[  741.749589] big_memory cpuset=/ mems_allowed=0
[  741.749797] Pid: 2801, comm: big_memory Not tainted 2.6.30-rc7 #1
[  741.750006] Call Trace:
[  741.750215]  [<ffffffff8029b3a0>] ? cpuset_print_task_mems_allowed+0x92/0x9d
[  741.750431]  [<ffffffff802d2bc3>] oom_kill_process+0xae/0x366
[  741.750690]  [<ffffffff802d3289>] ? select_bad_process+0xab/0x228
[  741.750903]  [<ffffffff802d38fc>] mem_cgroup_out_of_memory+0xbc/0xf8
[  741.751117]  [<ffffffff8031f228>] __mem_cgroup_try_charge+0x2db/0x318
[  741.751330]  [<ffffffff803200cd>] mem_cgroup_charge_common+0x74/0xbe
[  741.751589]  [<ffffffff803201f8>] mem_cgroup_newpage_charge+0xe1/0xee
[  741.751802]  [<ffffffff802f01fc>] handle_mm_fault+0x316/0xb6c
[  741.752014]  [<ffffffff8072fe2f>] do_page_fault+0x55a/0x5e4
[  741.752226]  [<ffffffff8072c74a>] ? trace_hardirqs_off_thunk+0x3a/0x6c
[  741.752438]  [<ffffffff8072cfaf>] page_fault+0x1f/0x30
[  741.752696] Task in /important killed as a result of limit of /important
[  741.752944] memory: usage 0kB, limit 256000kB, failcnt 1467
[  741.753152] memory+swap: usage 512000kB, limit 512000kB, failcnt 571
[  741.753361] Mem-Info:
[  741.753612] Node 0 DMA per-cpu:
[  741.753854] CPU    0: hi:    0, btch:   1 usd:   0
[  741.754061] CPU    1: hi:    0, btch:   1 usd:   0
[  741.754268] CPU    2: hi:    0, btch:   1 usd:   0
[  741.754475] CPU    3: hi:    0, btch:   1 usd:   0
[  741.754727] Node 0 DMA32 per-cpu:
[  741.754968] CPU    0: hi:  186, btch:  31 usd: 183
[  741.755176] CPU    1: hi:  186, btch:  31 usd:  29
[  741.755383] CPU    2: hi:  186, btch:  31 usd:   0
[  741.755638] CPU    3: hi:  186, btch:  31 usd:   0
[  741.755845] Node 0 Normal per-cpu:
[  741.756085] CPU    0: hi:  186, btch:  31 usd: 171
[  741.756293] CPU    1: hi:  186, btch:  31 usd: 185
[  741.756544] CPU    2: hi:  186, btch:  31 usd:  81
[  741.756752] CPU    3: hi:  186, btch:  31 usd: 102
[  741.756962] Active_anon:32254 active_file:67379 inactive_anon:48
[  741.756964]  inactive_file:24909 unevictable:3 dirty:10 writeback:0 unstable:0
[  741.756966]  free:1367086 slab:7269 mapped:10228 pagetables:5377 bounce:0
[  741.757800] Node 0 DMA free:2108kB min:24kB low:28kB high:36kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:15288kB pages_scanned:0 all_unreclaimable? no
[  741.758395] lowmem_reserve[]: 0 2990 6020 6020
[  741.758826] Node 0 DMA32 free:2903748kB min:4924kB low:6152kB high:7384kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:3062496kB pages_scanned:0 all_unreclaimable? no
[  741.759420] lowmem_reserve[]: 0 0 3030 3030
[  741.759849] Node 0 Normal free:2562488kB min:4992kB low:6240kB high:7488kB active_anon:129016kB inactive_anon:192kB active_file:269516kB inactive_file:99636kB unevictable:12kB present:3102720kB pages_scanned:0 all_unreclaimable? no
[  741.760447] lowmem_reserve[]: 0 0 0 0
[  741.760877] Node 0 DMA: 5*4kB 3*8kB 3*16kB 3*32kB 2*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 2108kB
[  741.761768] Node 0 DMA32: 5*4kB 4*8kB 1*16kB 2*32kB 3*64kB 3*128kB 2*256kB 5*512kB 4*1024kB 6*2048kB 704*4096kB = 2903748kB
[  741.762656] Node 0 Normal: 181*4kB 105*8kB 63*16kB 38*32kB 26*64kB 25*128kB 12*256kB 12*512kB 7*1024kB 7*2048kB 616*4096kB = 2562508kB
[  741.763549] 92975 total pagecache pages
[  741.763754] 15 pages in swap cache
[  741.763959] Swap cache stats: add 128026, delete 128011, find 5/8
[  741.764168] Free swap  = 1584472kB
[  741.764371] Total swap = 2096472kB
[  741.871834] 1572848 pages RAM
[  741.872041] 59696 pages reserved
[  741.872244] 56878 pages shared
[  741.872447] 131436 pages non-shared
[  741.872701] Memory cgroup out of memory: kill process 2801 (big_memory) score 0 or a child
[  741.873133] Memory cgroup out of memory: kill process 2801 (big_memory) score 0 or a child
[  741.873579] Memory cgroup out of memory: kill process 2801 (big_memory) score 0 or a child
.....(repeat)

-- 
--- 
Satoru MORIYA
Linux Technology Center
Hitachi, Ltd., Systems Development Laboratory
E-mail: satoru.moriya.br@hitachi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
