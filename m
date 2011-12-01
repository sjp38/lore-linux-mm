Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 83E756B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 07:46:39 -0500 (EST)
Date: Thu, 1 Dec 2011 23:46:34 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [3.2-rc3] OOM killer doesn't kill the obvious memory hog
Message-ID: <20111201124634.GY7046@dastard>
References: <20111201093644.GW7046@dastard>
 <20111201185001.5bf85500.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111201185001.5bf85500.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Dec 01, 2011 at 06:50:01PM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 1 Dec 2011 20:36:44 +1100
> Dave Chinner <david@fromorbit.com> wrote:
> 
> > Testing a 17TB filesystem with xfstests on a VM with 4GB RAM, test
> > 017 reliably triggers the OOM killer, which eventually panics the
> > machine after it has killed everything but the process consuming all
> > the memory. The console output I captured from the last kill where
> > the panic occurs:
> > 
> 
> your xfs_db is configured to have oom_score_adj==-1000.

So who is setting that? I've got plenty of occurrences where xfs_db
does get killed running from the test suite. e.g. from test 019:

[  283.294569] xfs_db invoked oom-killer: gfp_mask=0x280da, order=0, oom_adj=0, oom_score_adj=0
[  283.299206] xfs_db cpuset=/ mems_allowed=0
[  283.300755] Pid: 11341, comm: xfs_db Not tainted 3.2.0-rc3-dgc+ #114
[  283.302514] Call Trace:
[  283.303616]  [<ffffffff810debfd>] ? cpuset_print_task_mems_allowed+0x9d/0xb0
[  283.305848]  [<ffffffff8111afae>] dump_header.isra.8+0x7e/0x1c0
[  283.308354]  [<ffffffff816b56d0>] ? ___ratelimit+0xa0/0x120
[  283.310645]  [<ffffffff8111b9c7>] out_of_memory+0x3b7/0x550
[  283.312634]  [<ffffffff81120976>] __alloc_pages_nodemask+0x726/0x740
[  283.315345]  [<ffffffff8115700a>] alloc_pages_vma+0x9a/0x150
[  283.317343]  [<ffffffff81139e1a>] do_wp_page+0x3ca/0x740
[  283.319512]  [<ffffffff8113b8bd>] handle_pte_fault+0x44d/0x8b0
[  283.321953]  [<ffffffff81155183>] ? alloc_pages_current+0xa3/0x110
[  283.323943]  [<ffffffff8113c035>] handle_mm_fault+0x155/0x250
[  283.326375]  [<ffffffff81ac7021>] ? _cond_resched+0x1/0x40
[  283.328605]  [<ffffffff81acc9c2>] do_page_fault+0x142/0x4f0
[  283.330898]  [<ffffffff8107958d>] ? set_next_entity+0xad/0xd0
[  283.332754]  [<ffffffff810796c7>] ? pick_next_task_fair+0xc7/0x110
[  283.334974]  [<ffffffff81acc4c5>] do_async_page_fault+0x35/0x80
[  283.337460]  [<ffffffff81ac9875>] async_page_fault+0x25/0x30
[  283.339397] Mem-Info:
[  283.340253] Node 0 DMA per-cpu:
[  283.341839] CPU    0: hi:    0, btch:   1 usd:   0
[  283.343502] CPU    1: hi:    0, btch:   1 usd:   0
[  283.345062] CPU    2: hi:    0, btch:   1 usd:   0
[  283.346635] CPU    3: hi:    0, btch:   1 usd:   0
[  283.348320] CPU    4: hi:    0, btch:   1 usd:   0
[  283.349632] CPU    5: hi:    0, btch:   1 usd:   0
[  283.350886] CPU    6: hi:    0, btch:   1 usd:   0
[  283.352290] CPU    7: hi:    0, btch:   1 usd:   0
[  283.353692] Node 0 DMA32 per-cpu:
[  283.354654] CPU    0: hi:  186, btch:  31 usd:   0
[  283.355968] CPU    1: hi:  186, btch:  31 usd:   6
[  283.356995] CPU    2: hi:  186, btch:  31 usd:   5
[  283.357840] CPU    3: hi:  186, btch:  31 usd:   0
[  283.358694] CPU    4: hi:  186, btch:  31 usd:   0
[  283.359549] CPU    5: hi:  186, btch:  31 usd:   0
[  283.360635] CPU    6: hi:  186, btch:  31 usd:   0
[  283.361478] CPU    7: hi:  186, btch:  31 usd:   0
[  283.362323] Node 0 Normal per-cpu:
[  283.362941] CPU    0: hi:  186, btch:  31 usd:  57
[  283.363790] CPU    1: hi:  186, btch:  31 usd: 171
[  283.364886] CPU    2: hi:  186, btch:  31 usd:   3
[  283.365781] CPU    3: hi:  186, btch:  31 usd:   0
[  283.366633] CPU    4: hi:  186, btch:  31 usd:   0
[  283.367484] CPU    5: hi:  186, btch:  31 usd:  33
[  283.368584] CPU    6: hi:  186, btch:  31 usd:   0
[  283.369483] CPU    7: hi:  186, btch:  31 usd:   0
[  283.370333] active_anon:790116 inactive_anon:198062 isolated_anon:0
[  283.370334]  active_file:19 inactive_file:161 isolated_file:0
[  283.370335]  unevictable:0 dirty:0 writeback:123 unstable:0
[  283.370336]  free:6585 slab_reclaimable:2052 slab_unreclaimable:4014
[  283.370337]  mapped:64 shmem:11 pagetables:2741 bounce:0
[  283.375779] Node 0 DMA free:15888kB min:28kB low:32kB high:40kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15664kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[  283.382547] lowmem_reserve[]: 0 3512 4017 4017
[  283.383536] Node 0 DMA32 free:9072kB min:7076kB low:8844kB high:10612kB active_anon:2960704kB inactive_anon:592396kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3596500kB mlocked:0kB dirty:0kB writeback:480kB mapped:4kB shmem:0kB slab_reclaimable:4kB slab_unreclaimable:620kB kernel_stack:0kB pagetables:7692kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[  283.390563] lowmem_reserve[]: 0 0 505 505
[  283.391390] Node 0 Normal free:1380kB min:1016kB low:1268kB high:1524kB active_anon:199760kB inactive_anon:199852kB active_file:76kB inactive_file:644kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:517120kB mlocked:0kB dirty:0kB writeback:12kB mapped:252kB shmem:44kB slab_reclaimable:8204kB slab_unreclaimable:15436kB kernel_stack:1184kB pagetables:3272kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  283.398685] lowmem_reserve[]: 0 0 0 0
[  283.399421] Node 0 DMA: 0*4kB 0*8kB 1*16kB 0*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15888kB
[  283.401673] Node 0 DMA32: 15*4kB 4*8kB 3*16kB 1*32kB 1*64kB 0*128kB 1*256kB 2*512kB 2*1024kB 1*2048kB 1*4096kB = 9708kB
[  283.403790] Node 0 Normal: 305*4kB 17*8kB 4*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1420kB
[  283.406200] 2722 total pagecache pages
[  283.406867] 2622 pages in swap cache
[  283.407498] Swap cache stats: add 124512, delete 121890, find 2/4
[  283.408766] Free swap  = 0kB
[  283.409324] Total swap = 497976kB
[  283.417994] 1048560 pages RAM
[  283.418661] 36075 pages reserved
[  283.419235] 595 pages shared
[  283.419747] 1003827 pages non-shared
[  283.420587] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  283.421963] [  939]     0   939     5295       38   4     -17         -1000 udevd
[  283.423296] [  998]     0   998     5294       62   2     -17         -1000 udevd
[  283.424900] [  999]     0   999     5294       55   0     -17         -1000 udevd
[  283.426266] [ 1417]     0  1417     4731       63   1       0             0 rpcbind
[  283.427620] [ 1435]   102  1435     5825      110   0       0             0 rpc.statd
[  283.429436] [ 1452]     0  1452     7875       56   1       0             0 rpc.idmapd
[  283.430842] [ 1720]     0  1720    29565      156   6       0             0 rsyslogd
[  283.432526] [ 1797]     0  1797     1019       32   5       0             0 acpid
[  283.433904] [ 1861]     0  1861     4158       37   6       0             0 atd
[  283.435191] [ 1895]     0  1895     5090       58   2       0             0 cron
[  283.436754] [ 2045]   104  2045     5883       55   6       0             0 dbus-daemon
[  283.438224] [ 2069]     0  2069     5407      144   3       0             0 rpc.mountd
[  283.439616] [ 2147] 65534  2147     4218       40   4       0             0 pmproxy
[  283.441116] [ 2260]     0  2260     1737      118   1     -17         -1000 dhclient
[  283.442524] [ 2272]     0  2272    12405      137   3     -17         -1000 sshd
[  283.444069] [ 2284]     0  2284    17516      189   4       0             0 winbindd
[  283.445533] [ 2292]     0  2292    17516      189   4       0             0 winbindd
[  283.446891] [ 2345]     0  2345     4841       90   3       0             0 pmcd
[  283.448453] [ 2622]     0  2622     3324       47   1       0             0 pmie
[  283.449791] [ 2680]     0  2680     1530       24   1       0             0 getty
[  283.451093] [ 2681]     0  2681     1530       25   0       0             0 getty
[  283.452692] [ 2682]     0  2682     1530       25   0       0             0 getty
[  283.454001] [ 2683]     0  2683     1530       24   1       0             0 getty
[  283.455317] [ 2684]     0  2684     1530       25   5       0             0 getty
[  283.456849] [ 2685]     0  2685     1530       25   1       0             0 getty
[  283.458222] [ 2686]     0  2686     1530       24   4       0             0 getty
[  283.459532] [ 2687]     0  2687    20357      186   6       0             0 sshd
[  283.461086] [ 2691]  1000  2691    20357      184   4       0             0 sshd
[  283.462423] [ 2696]  1000  2696     5594      847   3       0             0 bash
[  283.463711] [ 2757]     0  2757    11422       86   5       0             0 sudo
[  283.465257] [ 2758]     0  2758     2862      213   0       0             0 check
[  283.466562] [11154]     0 11154     2466      200   3       0             0 019
[  283.467833] [11337]     0 11337     1036       24   6       0             0 xfs_check
[  283.469432] [11339]     0 11339     2466      200   5       0             0 019
[  283.470712] [11340]     0 11340     4198       89   0       0             0 perl
[  283.472284] [11341]     0 11341 10031496   981936   2       0             0 xfs_db
[  283.473722] Out of memory: Kill process 11341 (xfs_db) score 944 or sacrifice child
[  283.475112] Killed process 11341 (xfs_db) total-vm:40125984kB, anon-rss:3927736kB, file-rss:8kB

> 
> /*
>  * /proc/<pid>/oom_score_adj set to OOM_SCORE_ADJ_MIN disables oom killing for
>  * pid.
>  */
> #define OOM_SCORE_ADJ_MIN       (-1000)
> 
>  
> IIUC, this task cannot be killed by oom-killer because of oom_score_adj settings.

It's not me or the test suite that setting this, so it's something
the kernel must be doing automagically.

> 
> > [  302.152922] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
> > [  302.175536] [16484]     0 16484     2457        7   0     -17         -1000 017
> > [  302.177336] [16665]     0 16665     1036        0   2     -17         -1000 xfs_check
> > [  302.179001] [16666]     0 16666 10031571   986414   6     -17         -1000 xfs_db
> >
> 
> The task has 986414 pages on a host which has 1048560 pages of total RAM.
> 
> This seem suicide. If you want to kill xfs_db, set oom_score_adj = 0 or higher.

Like I said: I'm not changing a thing, nor is the test suite - test
017 results in xfs_db being unkillable, test 019 does not. They are
executed in test suite environment from the
same parent process. But somehow test 017 results in an unkillable
xfs_db process, and test 019 does not. Nothing is touching
oom_score_adj at all, so it should have a zero value. Why doesn't
it?

Indeed, why do the sshd processes have non-default oom_score_adj
in the test 017 case and not for test 019? They shouldn't be any
different, either, but they are. Why?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
