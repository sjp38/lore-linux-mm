Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id D4F626B0003
	for <linux-mm@kvack.org>; Sat,  2 Jan 2016 10:48:02 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id bx1so196129528obb.0
        for <linux-mm@kvack.org>; Sat, 02 Jan 2016 07:48:02 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g10si15071603oif.121.2016.01.02.07.48.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 02 Jan 2016 07:48:01 -0800 (PST)
Subject: Re: [PATCH 0/3] OOM detection rework v4
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
	<201512242141.EAH69761.MOVFQtHSFOJFLO@I-love.SAKURA.ne.jp>
	<201512282108.EDI82328.OHFLtVJOSQFMFO@I-love.SAKURA.ne.jp>
	<20151229163249.GD10321@dhcp22.suse.cz>
	<201512310005.DFJ21839.QOOSVFFHMLJOtF@I-love.SAKURA.ne.jp>
In-Reply-To: <201512310005.DFJ21839.QOOSVFFHMLJOtF@I-love.SAKURA.ne.jp>
Message-Id: <201601030047.HJF60980.HJOSFQOMLVFFtO@I-love.SAKURA.ne.jp>
Date: Sun, 3 Jan 2016 00:47:30 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Mon 28-12-15 21:08:56, Tetsuo Handa wrote:
> > > Tetsuo Handa wrote:
> > > > I got OOM killers while running heavy disk I/O (extracting kernel source,
> > > > running lxr's genxref command). (Environ: 4 CPUs / 2048MB RAM / no swap / XFS)
> > > > Do you think these OOM killers reasonable? Too weak against fragmentation?
> > > 
> > > Well, current patch invokes OOM killers when more than 75% of memory is used
> > > for file cache (active_file: + inactive_file:). I think this is a surprising
> > > thing for administrators and we want to retry more harder (but not forever,
> > > please).
> > 
> > Here again, it would be good to see what is the comparision between
> > the original and the new behavior. 75% of a page cache is certainly
> > unexpected but those pages might be pinned for other reasons and so
> > unreclaimable and basically IO bound. This is hard to optimize for
> > without causing any undesirable side effects for other loads. I will
> > have a look at the oom reports later but having a comparision would be
> > a great start.
> 
> Prior to "mm, oom: rework oom detection" patch (the original), this stressor
> never invoked the OOM killer. After this patch (the new), this stressor easily
> invokes the OOM killer. Both the original and the new case, active_file: +
> inactive_file: occupies nearly 75%. I think we lost invisible retry logic for
> order > 0 allocation requests.
> 

I retested with below debug printk() patch.

----------
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9d70a80..e433504 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3014,7 +3014,7 @@ static inline bool is_thp_gfp_mask(gfp_t gfp_mask)
 static inline bool
 should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 		     struct alloc_context *ac, int alloc_flags,
-		     bool did_some_progress,
+		     unsigned long did_some_progress,
 		     int no_progress_loops)
 {
 	struct zone *zone;
@@ -3024,8 +3024,10 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 	 * Make sure we converge to OOM if we cannot make any progress
 	 * several times in the row.
 	 */
-	if (no_progress_loops > MAX_RECLAIM_RETRIES)
+	if (no_progress_loops > MAX_RECLAIM_RETRIES) {
+		printk(KERN_INFO "Reached MAX_RECLAIM_RETRIES.\n");
 		return false;
+	}
 
 	/* Do not retry high order allocations unless they are __GFP_REPEAT */
 	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
@@ -3086,6 +3088,8 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 
 			return true;
 		}
+		printk(KERN_INFO "zone=%s reclaimable=%lu available=%lu no_progress_loops=%u did_some_progress=%lu\n",
+		       zone->name, reclaimable, available, no_progress_loops, did_some_progress);
 	}
 
 	return false;
@@ -3273,7 +3277,7 @@ retry:
 		no_progress_loops++;
 
 	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
-				 did_some_progress > 0, no_progress_loops))
+				 did_some_progress, no_progress_loops))
 		goto retry;
 
 	/* Reclaim has failed us, start killing things */
----------

The output showed that __zone_watermark_ok() returning false on both DMA32 and DMA
zones is the trigger of the OOM killer invocation. Direct reclaim is constantly
reclaiming some pages, but I guess freelist for 2 <= order < MAX_ORDER are empty.
That trigger was introduced by commit 97a16fc82a7c5b0c ("mm, page_alloc: only
enforce watermarks for order-0 allocations"), and "mm, oom: rework oom detection"
patch hits the trigger.

----------
[  154.547143] zone=DMA32 reclaimable=323478 available=325894 no_progress_loops=0 did_some_progress=58
[  154.551119] zone=DMA32 reclaimable=323153 available=325770 no_progress_loops=0 did_some_progress=58
[  154.571983] zone=DMA32 reclaimable=319582 available=322161 no_progress_loops=0 did_some_progress=56
[  154.576121] zone=DMA32 reclaimable=319647 available=322016 no_progress_loops=0 did_some_progress=56
[  154.583523] zone=DMA32 reclaimable=319467 available=321801 no_progress_loops=0 did_some_progress=55
[  154.593948] zone=DMA32 reclaimable=317400 available=320988 no_progress_loops=0 did_some_progress=56
[  154.730880] zone=DMA32 reclaimable=312385 available=313952 no_progress_loops=0 did_some_progress=48
[  154.733226] zone=DMA32 reclaimable=312337 available=313919 no_progress_loops=0 did_some_progress=48
[  154.737270] zone=DMA32 reclaimable=312417 available=313871 no_progress_loops=0 did_some_progress=48
[  154.739569] zone=DMA32 reclaimable=312369 available=313844 no_progress_loops=0 did_some_progress=48
[  154.743195] zone=DMA32 reclaimable=312385 available=313790 no_progress_loops=0 did_some_progress=48
[  154.745534] zone=DMA32 reclaimable=312365 available=313813 no_progress_loops=0 did_some_progress=48
[  154.748431] zone=DMA32 reclaimable=312272 available=313728 no_progress_loops=0 did_some_progress=48
[  154.750973] zone=DMA32 reclaimable=312273 available=313760 no_progress_loops=0 did_some_progress=48
[  154.753503] zone=DMA32 reclaimable=312289 available=313958 no_progress_loops=0 did_some_progress=48
[  154.753584] zone=DMA32 reclaimable=312241 available=313958 no_progress_loops=0 did_some_progress=48
[  154.753660] zone=DMA32 reclaimable=312193 available=313958 no_progress_loops=0 did_some_progress=48
[  154.781574] zone=DMA32 reclaimable=312147 available=314095 no_progress_loops=0 did_some_progress=48
[  154.784281] zone=DMA32 reclaimable=311539 available=314015 no_progress_loops=0 did_some_progress=49
[  154.786639] zone=DMA32 reclaimable=311498 available=314040 no_progress_loops=0 did_some_progress=49
[  154.788761] zone=DMA32 reclaimable=311432 available=314040 no_progress_loops=0 did_some_progress=49
[  154.791047] zone=DMA32 reclaimable=311366 available=314040 no_progress_loops=0 did_some_progress=49
[  154.793388] zone=DMA32 reclaimable=311300 available=314040 no_progress_loops=0 did_some_progress=49
[  154.795802] zone=DMA32 reclaimable=311153 available=314006 no_progress_loops=0 did_some_progress=49
[  154.804685] zone=DMA32 reclaimable=309950 available=313140 no_progress_loops=0 did_some_progress=49
[  154.807039] zone=DMA32 reclaimable=309867 available=313138 no_progress_loops=0 did_some_progress=49
[  154.809440] zone=DMA32 reclaimable=309761 available=313080 no_progress_loops=0 did_some_progress=49
[  154.811583] zone=DMA32 reclaimable=309735 available=313120 no_progress_loops=0 did_some_progress=49
[  154.814090] zone=DMA32 reclaimable=309561 available=313068 no_progress_loops=0 did_some_progress=49
[  154.817381] zone=DMA32 reclaimable=309463 available=313030 no_progress_loops=0 did_some_progress=49
[  154.824387] zone=DMA32 reclaimable=309414 available=313030 no_progress_loops=0 did_some_progress=49
[  154.829582] zone=DMA32 reclaimable=308907 available=312734 no_progress_loops=0 did_some_progress=50
[  154.831562] zone=DMA reclaimable=2 available=1728 no_progress_loops=0 did_some_progress=50
[  154.838499] fork invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)
[  154.841167] fork cpuset=/ mems_allowed=0
[  154.842348] CPU: 1 PID: 9599 Comm: fork Tainted: G        W       4.4.0-rc7-next-20151231+ #273
[  154.844308] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  154.846654]  0000000000000000 0000000045061c6b ffff88007a5dbb00 ffffffff81398b83
[  154.848559]  0000000000000000 ffff88007a5dbba0 ffffffff811bc81c 0000000000000206
[  154.850488]  ffffffff818104b0 ffff88007a5dbb40 ffffffff810bdd79 0000000000000206
[  154.852386] Call Trace:
[  154.853350]  [<ffffffff81398b83>] dump_stack+0x4b/0x68
[  154.854731]  [<ffffffff811bc81c>] dump_header+0x5b/0x3b0
[  154.856309]  [<ffffffff810bdd79>] ? trace_hardirqs_on_caller+0xf9/0x1c0
[  154.858046]  [<ffffffff810bde4d>] ? trace_hardirqs_on+0xd/0x10
[  154.859593]  [<ffffffff81143d36>] oom_kill_process+0x366/0x540
[  154.861142]  [<ffffffff8114414f>] out_of_memory+0x1ef/0x5a0
[  154.862655]  [<ffffffff8114420d>] ? out_of_memory+0x2ad/0x5a0
[  154.864194]  [<ffffffff81149c72>] __alloc_pages_nodemask+0xda2/0xde0
[  154.865852]  [<ffffffff810bdd00>] ? trace_hardirqs_on_caller+0x80/0x1c0
[  154.867844]  [<ffffffff81149e6c>] alloc_kmem_pages_node+0x4c/0xc0
[  154.868726] zone=DMA32 reclaimable=309003 available=312677 no_progress_loops=0 did_some_progress=48
[  154.868727] zone=DMA reclaimable=2 available=1728 no_progress_loops=0 did_some_progress=48
[  154.875357]  [<ffffffff8106d441>] copy_process.part.31+0x131/0x1b40
[  154.877845]  [<ffffffff8111d8da>] ? __audit_syscall_entry+0xaa/0xf0
[  154.880397]  [<ffffffff8106f01b>] _do_fork+0xdb/0x5d0
[  154.882259]  [<ffffffff8111d8da>] ? __audit_syscall_entry+0xaa/0xf0
[  154.884722]  [<ffffffff810030c1>] ? do_audit_syscall_entry+0x61/0x70
[  154.887201]  [<ffffffff81003254>] ? syscall_trace_enter_phase1+0x134/0x150
[  154.889666]  [<ffffffff81003017>] ? trace_hardirqs_on_thunk+0x17/0x19
[  154.891519]  [<ffffffff8106f594>] SyS_clone+0x14/0x20
[  154.893059]  [<ffffffff816feeb2>] entry_SYSCALL_64_fastpath+0x12/0x76
[  154.894859] Mem-Info:
[  154.895851] active_anon:31807 inactive_anon:2093 isolated_anon:0
[  154.895851]  active_file:242656 inactive_file:67266 isolated_file:0
[  154.895851]  unevictable:0 dirty:8 writeback:0 unstable:0
[  154.895851]  slab_reclaimable:15100 slab_unreclaimable:20839
[  154.895851]  mapped:1681 shmem:2162 pagetables:18491 bounce:0
[  154.895851]  free:4243 free_pcp:343 free_cma:0
[  154.905459] Node 0 DMA free:6908kB min:44kB low:52kB high:64kB active_anon:3408kB inactive_anon:120kB active_file:4kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15988kB managed:15904kB mlocked:0kB dirty:0kB writeback:0kB mapped:64kB shmem:124kB slab_reclaimable:872kB slab_unreclaimable:3032kB kernel_stack:176kB pagetables:328kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  154.916097] lowmem_reserve[]: 0 1714 1714 1714
[  154.917857] Node 0 DMA32 free:17996kB min:5172kB low:6464kB high:7756kB active_anon:121688kB inactive_anon:8252kB active_file:970620kB inactive_file:269060kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2080640kB managed:1758944kB mlocked:0kB dirty:32kB writeback:0kB mapped:6660kB shmem:8524kB slab_reclaimable:59528kB slab_unreclaimable:80460kB kernel_stack:47312kB pagetables:70972kB unstable:0kB bounce:0kB free_pcp:1356kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[  154.929908] lowmem_reserve[]: 0 0 0 0
[  154.931918] Node 0 DMA: 107*4kB (UME) 72*8kB (ME) 47*16kB (UME) 19*32kB (UME) 9*64kB (ME) 1*128kB (M) 3*256kB (M) 2*512kB (E) 2*1024kB (UM) 0*2048kB 0*4096kB = 6908kB
[  154.937453] Node 0 DMA32: 1113*4kB (UME) 1400*8kB (UME) 116*16kB (UM) 15*32kB (UM) 1*64kB (M) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 18052kB
[  154.941617] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  154.944167] 312171 total pagecache pages
[  154.945926] 0 pages in swap cache
[  154.947521] Swap cache stats: add 0, delete 0, find 0/0
[  154.949436] Free swap  = 0kB
[  154.950920] Total swap = 0kB
[  154.952531] 524157 pages RAM
[  154.954063] 0 pages HighMem/MovableOnly
[  154.955785] 80445 pages reserved
[  154.957362] 0 pages hwpoisoned
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
