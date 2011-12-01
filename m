Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id E077B6B004D
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 04:37:01 -0500 (EST)
Date: Thu, 1 Dec 2011 20:36:44 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: [3.2-rc3] OOM killer doesn't kill the obvious memory hog
Message-ID: <20111201093644.GW7046@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

Testing a 17TB filesystem with xfstests on a VM with 4GB RAM, test
017 reliably triggers the OOM killer, which eventually panics the
machine after it has killed everything but the process consuming all
the memory. The console output I captured from the last kill where
the panic occurs:

[  302.040482] Pid: 16666, comm: xfs_db Not tainted 3.2.0-rc3-dgc+ #105
[  302.041959] Call Trace:
[  302.042547]  [<ffffffff810debfd>] ? cpuset_print_task_mems_allowed+0x9d/0xb0
[  302.044380]  [<ffffffff8111afae>] dump_header.isra.8+0x7e/0x1c0
[  302.045770]  [<ffffffff8111b22c>] ? oom_badness+0x13c/0x150
[  302.047074]  [<ffffffff8111bb23>] out_of_memory+0x513/0x550
[  302.048524]  [<ffffffff81120976>] __alloc_pages_nodemask+0x726/0x740
[  302.049993]  [<ffffffff81155183>] alloc_pages_current+0xa3/0x110
[  302.051384]  [<ffffffff8111814f>] __page_cache_alloc+0x8f/0xa0
[  302.052960]  [<ffffffff811185be>] ? find_get_page+0x1e/0x90
[  302.054267]  [<ffffffff8111a2dd>] filemap_fault+0x2bd/0x480
[  302.055570]  [<ffffffff8106ead8>] ? flush_tlb_page+0x48/0xb0
[  302.056748]  [<ffffffff81138a1f>] __do_fault+0x6f/0x4f0
[  302.057616]  [<ffffffff81139cfc>] ? do_wp_page+0x2ac/0x740
[  302.058609]  [<ffffffff8113b567>] handle_pte_fault+0xf7/0x8b0
[  302.059557]  [<ffffffff8107933a>] ? finish_task_switch+0x4a/0xf0
[  302.060718]  [<ffffffff8113c035>] handle_mm_fault+0x155/0x250
[  302.061679]  [<ffffffff81acc902>] do_page_fault+0x142/0x4f0
[  302.062599]  [<ffffffff8107958d>] ? set_next_entity+0xad/0xd0
[  302.063548]  [<ffffffff8103f6d2>] ? __switch_to+0x132/0x310
[  302.064575]  [<ffffffff8107933a>] ? finish_task_switch+0x4a/0xf0
[  302.065586]  [<ffffffff81acc405>] do_async_page_fault+0x35/0x80
[  302.066570]  [<ffffffff81ac97b5>] async_page_fault+0x25/0x30
[  302.067509] Mem-Info:
[  302.067992] Node 0 DMA per-cpu:
[  302.068652] CPU    0: hi:    0, btch:   1 usd:   0
[  302.069444] CPU    1: hi:    0, btch:   1 usd:   0
[  302.070239] CPU    2: hi:    0, btch:   1 usd:   0
[  302.071034] CPU    3: hi:    0, btch:   1 usd:   0
[  302.071830] CPU    4: hi:    0, btch:   1 usd:   0
[  302.072776] CPU    5: hi:    0, btch:   1 usd:   0
[  302.073577] CPU    6: hi:    0, btch:   1 usd:   0
[  302.074374] CPU    7: hi:    0, btch:   1 usd:   0
[  302.075172] Node 0 DMA32 per-cpu:
[  302.075745] CPU    0: hi:  186, btch:  31 usd:   0
[  302.076712] CPU    1: hi:  186, btch:  31 usd:   0
[  302.077517] CPU    2: hi:  186, btch:  31 usd:   0
[  302.078313] CPU    3: hi:  186, btch:  31 usd:   1
[  302.079104] CPU    4: hi:  186, btch:  31 usd:   0
[  302.080274] CPU    5: hi:  186, btch:  31 usd:   0
[  302.081482] CPU    6: hi:  186, btch:  31 usd:   0
[  302.082689] CPU    7: hi:  186, btch:  31 usd:  36
[  302.084210] Node 0 Normal per-cpu:
[  302.085104] CPU    0: hi:  186, btch:  31 usd:   1
[  302.086363] CPU    1: hi:  186, btch:  31 usd:  30
[  302.087575] CPU    2: hi:  186, btch:  31 usd:   0
[  302.089193] CPU    3: hi:  186, btch:  31 usd:  16
[  302.090448] CPU    4: hi:  186, btch:  31 usd:  14
[  302.091646] CPU    5: hi:  186, btch:  31 usd:   0
[  302.092992] CPU    6: hi:  186, btch:  31 usd:  30
[  302.093968] CPU    7: hi:  186, btch:  31 usd:  14
[  302.094945] active_anon:789505 inactive_anon:197012 isolated_anon:0
[  302.094946]  active_file:11 inactive_file:18 isolated_file:0
[  302.094947]  unevictable:0 dirty:0 writeback:29 unstable:0
[  302.094948]  free:6465 slab_reclaimable:2020 slab_unreclaimable:3473
[  302.094949]  mapped:5 shmem:1 pagetables:2539 bounce:0
[  302.101211] Node 0 DMA free:15888kB min:28kB low:32kB high:40kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0s
[  302.108917] lowmem_reserve[]: 0 3512 4017 4017
[  302.109885] Node 0 DMA32 free:9020kB min:7076kB low:8844kB high:10612kB active_anon:2962672kB inactive_anon:592684kB active_file:44kB inactive_file:0kB unevictable:s
[  302.117811] lowmem_reserve[]: 0 0 505 505
[  302.118938] Node 0 Normal free:952kB min:1016kB low:1268kB high:1524kB active_anon:195348kB inactive_anon:195364kB active_file:0kB inactive_file:72kB unevictable:0ks
[  302.126920] lowmem_reserve[]: 0 0 0 0
[  302.127744] Node 0 DMA: 0*4kB 0*8kB 1*16kB 0*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15888kB
[  302.130415] Node 0 DMA32: 68*4kB 48*8kB 35*16kB 16*32kB 9*64kB 3*128kB 2*256kB 2*512kB 1*1024kB 0*2048kB 1*4096kB = 9344kB
[  302.133101] Node 0 Normal: 117*4kB 1*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 988kB
[  302.135488] 185 total pagecache pages
[  302.136455] 149 pages in swap cache
[  302.137171] Swap cache stats: add 126014, delete 125865, find 94/133
[  302.138523] Free swap  = 0kB
[  302.139114] Total swap = 497976kB
[  302.149921] 1048560 pages RAM
[  302.150591] 36075 pages reserved
[  302.151254] 35 pages shared
[  302.151830] 1004770 pages non-shared
[  302.152922] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[  302.154450] [  939]     0   939     5295        1   4     -17         -1000 udevd
[  302.156160] [ 1002]     0  1002     5294        1   4     -17         -1000 udevd
[  302.157673] [ 1003]     0  1003     5294        0   4     -17         -1000 udevd
[  302.159200] [ 2399]     0  2399     1737        0   7     -17         -1000 dhclient
[  302.161078] [ 2442]     0  2442    12405        0   4     -17         -1000 sshd
[  302.162581] [ 2446]     0  2446    20357        1   0     -17         -1000 sshd
[  302.164408] [ 2450]  1000  2450    20357        0   1     -17         -1000 sshd
[  302.165901] [ 2455]  1000  2455     5592        0   7     -17         -1000 bash
[  302.167401] [ 2516]     0  2516    20357        1   6     -17         -1000 sshd
[  302.169199] [ 2520]  1000  2520    20357        0   4     -17         -1000 sshd
[  302.170702] [ 2527]  1000  2527     5606        1   6     -17         -1000 bash
[  302.172508] [ 5516]     0  5516     5089        0   2     -17         -1000 sudo
[  302.174008] [ 5517]     0  5517     2862        1   0     -17         -1000 check
[  302.175536] [16484]     0 16484     2457        7   0     -17         -1000 017
[  302.177336] [16665]     0 16665     1036        0   2     -17         -1000 xfs_check
[  302.179001] [16666]     0 16666 10031571   986414   6     -17         -1000 xfs_db
[  302.180890] Kernel panic - not syncing: Out of memory and no killable processes...
[  302.180892]
[  302.182585] Pid: 16666, comm: xfs_db Not tainted 3.2.0-rc3-dgc+ #105
[  302.183764] Call Trace:
[  302.184528]  [<ffffffff81abe166>] panic+0x91/0x19d
[  302.185790]  [<ffffffff8111bb38>] out_of_memory+0x528/0x550
[  302.187244]  [<ffffffff81120976>] __alloc_pages_nodemask+0x726/0x740
[  302.188780]  [<ffffffff81155183>] alloc_pages_current+0xa3/0x110
[  302.189951]  [<ffffffff8111814f>] __page_cache_alloc+0x8f/0xa0
[  302.191039]  [<ffffffff811185be>] ? find_get_page+0x1e/0x90
[  302.192168]  [<ffffffff8111a2dd>] filemap_fault+0x2bd/0x480
[  302.193215]  [<ffffffff8106ead8>] ? flush_tlb_page+0x48/0xb0
[  302.194343]  [<ffffffff81138a1f>] __do_fault+0x6f/0x4f0
[  302.195312]  [<ffffffff81139cfc>] ? do_wp_page+0x2ac/0x740
[  302.196490]  [<ffffffff8113b567>] handle_pte_fault+0xf7/0x8b0
[  302.197554]  [<ffffffff8107933a>] ? finish_task_switch+0x4a/0xf0
[  302.198670]  [<ffffffff8113c035>] handle_mm_fault+0x155/0x250
[  302.199755]  [<ffffffff81acc902>] do_page_fault+0x142/0x4f0
[  302.200921]  [<ffffffff8107958d>] ? set_next_entity+0xad/0xd0
[  302.201987]  [<ffffffff8103f6d2>] ? __switch_to+0x132/0x310
[  302.203023]  [<ffffffff8107933a>] ? finish_task_switch+0x4a/0xf0
[  302.204321]  [<ffffffff81acc405>] do_async_page_fault+0x35/0x80
[  302.205417]  [<ffffffff81ac97b5>] async_page_fault+0x25/0x30

It looks to me like the process causing the page fault and trying to
allocate more memory (xfs_db) is also the one consuming all the
memory and by all metrics is the obvious candidate to kill. So, why
does the OOM killer kill everything else but the memory hog and then
panic the machine?

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
