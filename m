Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id A29A86B004A
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 14:57:59 -0500 (EST)
Received: by bkwq16 with SMTP id q16so4867718bkw.14
        for <linux-mm@kvack.org>; Mon, 05 Mar 2012 11:57:58 -0800 (PST)
Message-ID: <1330977506.1589.59.camel@lappy>
Subject: OOM killer even when not overcommiting
From: Sasha Levin <levinsasha928@gmail.com>
Date: Mon, 05 Mar 2012 21:58:26 +0200
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>

Hi all,

I assumed that when setting overcommit_memory=2 and overcommit_ratio<100 that the OOM killer won't ever get invoked (since we're not overcommiting memory), but it looks like I'm mistaken since apparently a simple mmap from userspace will trigger the OOM killer if it requests more memory than available.

Is it how it's supposed to work? Why does it resort to OOM killing instead of just failing the allocation?

Here is the dump I get when the OOM kicks in:

[ 3102.565520] trinity used greatest stack depth: 3472 bytes left
[ 3108.706940] trinity invoked oom-killer: gfp_mask=0x84d0, order=0, oom_adj=0, oom_score_adj=0
[ 3108.709101] trinity cpuset=/ mems_allowed=0
[ 3108.710152] Pid: 5694, comm: trinity Not tainted 3.3.0-rc5-next-20120302-sasha #31
[ 3108.711978] Call Trace:
[ 3108.712569]  [<ffffffff826e87d0>] ? _raw_spin_unlock+0x30/0x60
[ 3108.713981]  [<ffffffff8117485a>] dump_header+0x8a/0xd0
[ 3108.715234]  [<ffffffff81174f76>] oom_kill_process+0x2e6/0x320
[ 3108.716638]  [<ffffffff811753fa>] out_of_memory+0x17a/0x210
[ 3108.718035]  [<ffffffff8117ab0c>] __alloc_pages_nodemask+0x81c/0x980
[ 3108.719371]  [<ffffffff811b4170>] alloc_pages_current+0xa0/0x110
[ 3108.720458]  [<ffffffff81085796>] pte_alloc_one+0x16/0x40
[ 3108.721534]  [<ffffffff81192b3d>] __pte_alloc+0x2d/0x190
[ 3108.722696]  [<ffffffff811cb79e>] do_huge_pmd_anonymous_page+0x5e/0x230
[ 3108.724484]  [<ffffffff81196b8e>] handle_mm_fault+0x28e/0x330
[ 3108.725860]  [<ffffffff81196e3c>] __get_user_pages+0x14c/0x640
[ 3108.727231]  [<ffffffff8119b78b>] ? mmap_region+0x2bb/0x510
[ 3108.728561]  [<ffffffff81198a77>] __mlock_vma_pages_range+0x87/0xa0
[ 3108.730350]  [<ffffffff81198e4a>] mlock_vma_pages_range+0x9a/0xa0
[ 3108.734486]  [<ffffffff8119b75b>] mmap_region+0x28b/0x510
[ 3108.736185]  [<ffffffff810e30c1>] ? get_parent_ip+0x11/0x50
[ 3108.737937]  [<ffffffff8119bd2c>] do_mmap_pgoff+0x34c/0x390
[ 3108.741945]  [<ffffffff8119bdca>] ? sys_mmap_pgoff+0x5a/0x240
[ 3108.743288]  [<ffffffff8119bde8>] sys_mmap_pgoff+0x78/0x240
[ 3108.744781]  [<ffffffff8187dbee>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 3108.746301]  [<ffffffff81051ea9>] sys_mmap+0x29/0x30
[ 3108.747597]  [<ffffffff826e9efd>] system_call_fastpath+0x1a/0x1f
[ 3108.748967] Mem-Info:
[ 3108.749499] Node 0 DMA per-cpu:
[ 3108.750253] CPU    0: hi:    0, btch:   1 usd:   0
[ 3108.751387] CPU    1: hi:    0, btch:   1 usd:   0
[ 3108.752530] CPU    2: hi:    0, btch:   1 usd:   0
[ 3108.753637] CPU    3: hi:    0, btch:   1 usd:   0
[ 3108.754738] Node 0 DMA32 per-cpu:
[ 3108.755591] CPU    0: hi:  186, btch:  31 usd:   0
[ 3108.756728] CPU    1: hi:  186, btch:  31 usd:   0
[ 3108.757901] CPU    2: hi:  186, btch:  31 usd:  30
[ 3108.759059] CPU    3: hi:  186, btch:  31 usd:   9
[ 3108.760297] active_anon:3646 inactive_anon:25 isolated_anon:0
[ 3108.760298]  active_file:0 inactive_file:0 isolated_file:0
[ 3108.760299]  unevictable:178176 dirty:0 writeback:0 unstable:0
[ 3108.760300]  free:12235 slab_reclaimable:11196 slab_unreclaimable:18070
[ 3108.760301]  mapped:9 shmem:4 pagetables:904 bounce:0
[ 3108.766381] Node 0 DMA free:4692kB min:680kB low:848kB high:1020kB active_anon:92kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:10240kB isolated(anon):0kB isolated(file):0kB present:15656kB mlocked:20kB dirty:0kB writeback:0kB mapped:8kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:40kB kernel_stack:8kB pagetables:716kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[ 3108.774660] lowmem_reserve[]: 0 992 992 992
[ 3108.776050] Node 0 DMA32 free:44292kB min:44372kB low:55464kB high:66556kB active_anon:14492kB inactive_anon:100kB active_file:0kB inactive_file:0kB unevictable:702464kB isolated(anon):0kB isolated(file):0kB present:1016064kB mlocked:1372kB dirty:0kB writeback:0kB mapped:28kB shmem:16kB slab_reclaimable:44784kB slab_unreclaimable:72240kB kernel_stack:1160kB pagetables:2900kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:21 all_unreclaimable? yes
[ 3108.784537] lowmem_reserve[]: 0 0 0 0
[ 3108.785548] Node 0 DMA: 1*4kB 3*8kB 3*16kB 3*32kB 2*64kB 2*128kB 2*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 4652kB
[ 3108.788376] Node 0 DMA32: 95*4kB 87*8kB 263*16kB 427*32kB 128*64kB 30*128kB 10*256kB 7*512kB 1*1024kB 3*2048kB 0*4096kB = 44292kB
[ 3108.801455] 29 total pagecache pages
[ 3108.801991] 0 pages in swap cache
[ 3108.802761] Swap cache stats: add 0, delete 0, find 0/0
[ 3108.803987] Free swap  = 0kB
[ 3108.804658] Total swap = 0kB
[ 3108.808256] 262128 pages RAM
[ 3108.808959] 21499 pages reserved
[ 3108.809702] 2099 pages shared
[ 3108.810390] 224544 pages non-shared
[ 3108.811200] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[ 3108.812904] [ 3032]     0  3032     4507       95   3       0             0 sh
[ 3108.814571] [ 3049]     0  3049     3970      881   1       0             0 trinity
[ 3108.816307] [ 3051]     0  3051     3994      885   1       0             0 trinity
[ 3108.818072] [ 3053]     0  3053     4036      894   1       0             0 trinity
[ 3108.819243] [ 3055]     0  3055     3970      882   3       0             0 trinity
[ 3108.820553] [ 5694]     0  5694   531859   178526   1       0             0 trinity
[ 3108.821871] [ 6191]     0  6191     3970      884   3       0             0 trinity
[ 3108.823510] [ 6193]     0  6193     3970      881   3       0             0 trinity
[ 3108.825261] Out of memory: Kill process 5694 (trinity) score 713 or sacrifice child
[ 3108.826997] Killed process 5694 (trinity) total-vm:2127436kB, anon-rss:714096kB, file-rss:8kB
[ 3109.360692] trinity used greatest stack depth: 2912 bytes left

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
