Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 579266B004F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 21:17:38 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n611I7xC025777
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Jul 2009 10:18:08 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5473145DE53
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 10:18:07 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 01FCF45DE4E
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 10:18:07 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D3E80E08001
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 10:18:06 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 79BB11DB803C
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 10:18:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Found the commit that causes the OOMs
In-Reply-To: <20090630140512.GA16923@localhost>
References: <1246291007.663.630.camel@macbook.infradead.org> <20090630140512.GA16923@localhost>
Message-Id: <20090701094446.85C8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Jul 2009 10:18:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, David Woodhouse <dwmw2@infradead.org>, David Howells <dhowells@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

> On Mon, Jun 29, 2009 at 11:56:47PM +0800, David Woodhouse wrote:
> > On Mon, 2009-06-29 at 16:54 +0100, David Howells wrote:
> > > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > >
> > > > Yes this time the OOM order/flags are much different from all previous OOMs.
> > > >
> > > > btw, I found that msgctl11 is pretty good at making a lot of SUnreclaim and
> > > > PageTables pages:
> > >
> > > I got David Woodhouse to run this on one of this boxes, but he doesn't see the
> > > problem, I think because he's got 4GB of RAM, and never comes close to running
> > > out.
> > >
> > > I've asked him to reboot with mem=1G to see if that helps reproduce it.
> >
> > msgctl11 invoked oom-killer: gfp_mask=0xd0, order=1, oom_adj=0
> > Pid: 5795, comm: msgctl11 Not tainted 2.6.31-rc1 #147
> > Call Trace:
> >  [<ffffffff81092c77>] oom_kill_process.clone.0+0xac/0x254
> >  [<ffffffff81092b5c>] ? badness+0x24d/0x2bc
> >  [<ffffffff81092f5f>] __out_of_memory+0x140/0x157
> >  [<ffffffff8109308f>] out_of_memory+0x119/0x150
> >  [<ffffffff81095c65>] ? drain_local_pages+0x16/0x18
> >  [<ffffffff810967ab>] __alloc_pages_nodemask+0x45a/0x55b
> >  [<ffffffff810a32b0>] ? __inc_zone_page_state+0x2e/0x30
> >  [<ffffffff810bb6b9>] alloc_pages_current+0xae/0xb6
> >  [<ffffffff810a604a>] ? do_wp_page+0x621/0x6c3
> >  [<ffffffff81094d7e>] __get_free_pages+0xe/0x4b
> >  [<ffffffff810403a7>] copy_process+0xab/0x11a5
> >  [<ffffffff810327c8>] ? check_preempt_wakeup+0x11a/0x142
> >  [<ffffffff810a7a06>] ? handle_mm_fault+0x678/0x6e9
> >  [<ffffffff810415ec>] do_fork+0x14b/0x338
> >  [<ffffffff8105b50a>] ? up_read+0xe/0x10
> >  [<ffffffff814ee655>] ? do_page_fault+0x2da/0x307
> >  [<ffffffff8100a55c>] sys_clone+0x28/0x2a
> >  [<ffffffff8100bfc3>] stub_clone+0x13/0x20
> >  [<ffffffff8100bcdb>] ? system_call_fastpath+0x16/0x1b
> > Mem-Info:
> > Node 0 DMA per-cpu:
> > CPU    0: hi:    0, btch:   1 usd:   0
> > CPU    1: hi:    0, btch:   1 usd:   0
> > CPU    2: hi:    0, btch:   1 usd:   0
> > CPU    3: hi:    0, btch:   1 usd:   0
> > CPU    4: hi:    0, btch:   1 usd:   0
> > CPU    5: hi:    0, btch:   1 usd:   0
> > CPU    6: hi:    0, btch:   1 usd:   0
> > CPU    7: hi:    0, btch:   1 usd:   0
> > Node 0 DMA32 per-cpu:
> > CPU    0: hi:  186, btch:  31 usd:   0
> > CPU    1: hi:  186, btch:  31 usd:  20
> > CPU    2: hi:  186, btch:  31 usd:  19
> > CPU    3: hi:  186, btch:  31 usd:  20
> > CPU    4: hi:  186, btch:  31 usd:  19
> > CPU    5: hi:  186, btch:  31 usd:  24
> > CPU    6: hi:  186, btch:  31 usd:  41
> > CPU    7: hi:  186, btch:  31 usd:  25
> > Active_anon:72835 active_file:89 inactive_anon:575
> >  inactive_file:103 unevictable:0 dirty:36 writeback:0 unstable:0
> >  free:2467 slab:38211 mapped:229 pagetables:66918 bounce:0
> > Node 0 DMA free:4036kB min:60kB low:72kB high:88kB active_anon:3228kB inactive_a
> > non:256kB active_file:0kB inactive_file:0kB unevictable:0kB present:15356kB page
> > s_scanned:0 all_unreclaimable? no
> > lowmem_reserve[]: 0 994 994 994
> > Node 0 DMA32 free:5832kB min:4000kB low:5000kB high:6000kB active_anon:288112kB
> > inactive_anon:2044kB active_file:356kB inactive_file:412kB unevictable:0kB prese
> > nt:1018080kB pages_scanned:0 all_unreclaimable? no
> > lowmem_reserve[]: 0 0 0 0
> > Node 0 DMA: 1*4kB 2*8kB 1*16kB 0*32kB 1*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 1*
> > 2048kB 0*4096kB = 3940kB
> > Node 0 DMA32: 852*4kB 1*8kB 0*16kB 1*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024k
> > B 0*2048kB 0*4096kB = 5304kB
> > 437 total pagecache pages
> > 0 pages in swap cache
> > Swap cache stats: add 0, delete 0, find 0/0
> > Free swap  = 0kB
> > Total swap = 0kB
> > 262144 pages RAM
> > 6503 pages reserved
> > 205864 pages shared
> > 226536 pages non-shared
> > Out of memory: kill process 3855 (msgctl11) score 179248 or a child
> > Killed process 4222 (msgctl11)
> 
> More data: I boot 2.6.30-rc1 with mem=1G and enabled 1GB swap and run msgctl11.
> 
> It goes OOM at the 2nd run. They are very interesting numbers: memory leaked?
> 
>         [ 2259.825958] msgctl11 invoked oom-killer: gfp_mask=0x84d0, order=0, oom_adj=0
>         [ 2259.828092] Pid: 29657, comm: msgctl11 Not tainted 2.6.31-rc1 #22
>         [ 2259.830505] Call Trace:
>         [ 2259.832010]  [<ffffffff8156f366>] ? _spin_unlock+0x26/0x30
>         [ 2259.834219]  [<ffffffff810c8b26>] oom_kill_process+0x176/0x270
>         [ 2259.837603]  [<ffffffff810c8def>] ? badness+0x18f/0x300
>         [ 2259.839906]  [<ffffffff810c9095>] __out_of_memory+0x135/0x170
>         [ 2259.842035]  [<ffffffff810c91c5>] out_of_memory+0xf5/0x180
>         [ 2259.844270]  [<ffffffff810cd86c>] __alloc_pages_nodemask+0x6ac/0x6c0
>         [ 2259.846743]  [<ffffffff810f8fa8>] alloc_pages_current+0x78/0x100
>         [ 2259.849083]  [<ffffffff81033515>] pte_alloc_one+0x15/0x50
>         [ 2259.851282]  [<ffffffff810e0eda>] __pte_alloc+0x2a/0xf0
>         [ 2259.853454]  [<ffffffff810e16e2>] handle_mm_fault+0x742/0x830
>         [ 2259.855793]  [<ffffffff815725cb>] do_page_fault+0x1cb/0x330
>         [ 2259.858033]  [<ffffffff8156fdf5>] page_fault+0x25/0x30
>         [ 2259.860301] Mem-Info:
>         [ 2259.861706] Node 0 DMA per-cpu:
>         [ 2259.862523] CPU    0: hi:    0, btch:   1 usd:   0
>         [ 2259.864454] CPU    1: hi:    0, btch:   1 usd:   0
>         [ 2259.866608] Node 0 DMA32 per-cpu:
>         [ 2259.867404] CPU    0: hi:  186, btch:  31 usd: 197
>         [ 2259.869283] CPU    1: hi:  186, btch:  31 usd: 175
>         [ 2259.870511] Active_anon:0 active_file:11 inactive_anon:0
> 
> zero anon pages!
>
>        [ 2259.870512]  inactive_file:0 unevictable:0 dirty:0 writeback:0 unstable:0
>        [ 2259.870513]  free:1986 slab:42170 mapped:96 pagetables:59427 bounce:0

I bet this is NOT zero. it only hidden. 

I guess this system's memory usage is,
   pagetables: 60k pages
   kernel stack: 60k pages
   anon (hidden): 60k pages
   slab: 40k pages
   other: 30k pages
   ===================
   total: 250k pages = 1GB

What is "hidden" anon pages?
each shrink_{in}active_list isolate 32 pages from lru. it mean anon or file lru
accounting decrease temporary.

if system have plenty thread or process, heavy memory pressure makes 
#-of-thread x 32pages isolation.

msgctl11 makes >10K processes.

I have debugging patch for this case.
Wu, Can you please try this patch?

if my guess is correct, we need to implement #-of-reclaim-process throttling
mechanism.

============================================
If the system have plenty thread,  concurrent reclaim can isolate very much pages.
Unfortunately, current /proc/meminfo and OOM log can't show it.

Machine
  IA64 x8 CPU
  MEM 8GB

reproduce way

% ./hackbench 140 process 1000
   => couse OOM

Active_anon:203 active_file:91 inactive_anon:104
 inactive_file:76 unevictable:0 dirty:0 writeback:72 unstable:0
 free:168 slab:4968 mapped:136 pagetables:28203 bounce:0
 isolate:49088
             ^^^^

---
 fs/proc/meminfo.c      |    6 ++++--
 include/linux/mmzone.h |    1 +
 mm/page_alloc.c        |    6 ++++--
 mm/vmscan.c            |    5 +++++
 mm/vmstat.c            |    1 +
 5 files changed, 15 insertions(+), 4 deletions(-)

Index: b/fs/proc/meminfo.c
===================================================================
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -95,7 +95,8 @@ static int meminfo_proc_show(struct seq_
 		"Committed_AS:   %8lu kB\n"
 		"VmallocTotal:   %8lu kB\n"
 		"VmallocUsed:    %8lu kB\n"
-		"VmallocChunk:   %8lu kB\n",
+		"VmallocChunk:   %8lu kB\n"
+		"IsolatePages:   %8lu kB\n",
 		K(i.totalram),
 		K(i.freeram),
 		K(i.bufferram),
@@ -139,7 +140,8 @@ static int meminfo_proc_show(struct seq_
 		K(committed),
 		(unsigned long)VMALLOC_TOTAL >> 10,
 		vmi.used >> 10,
-		vmi.largest_chunk >> 10
+		vmi.largest_chunk >> 10,
+		K(global_page_state(NR_ISOLATE)),
 		);
 
 	hugetlb_report_meminfo(m);
Index: b/include/linux/mmzone.h
===================================================================
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -107,6 +107,7 @@ enum zone_stat_item {
 	NUMA_LOCAL,		/* allocation from local node */
 	NUMA_OTHER,		/* allocation from other node */
 #endif
+	NR_ISOLATE,
 	NR_VM_ZONE_STAT_ITEMS };
 
 /*
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2119,7 +2119,8 @@ void show_free_areas(void)
 		" inactive_file:%lu"
 		" unevictable:%lu"
 		" dirty:%lu writeback:%lu unstable:%lu\n"
-		" free:%lu slab:%lu mapped:%lu pagetables:%lu bounce:%lu\n",
+		" free:%lu slab:%lu mapped:%lu pagetables:%lu bounce:%lu\n"
+		" isolate:%lu\n",
 		global_page_state(NR_ACTIVE_ANON),
 		global_page_state(NR_ACTIVE_FILE),
 		global_page_state(NR_INACTIVE_ANON),
@@ -2133,7 +2134,8 @@ void show_free_areas(void)
 			global_page_state(NR_SLAB_UNRECLAIMABLE),
 		global_page_state(NR_FILE_MAPPED),
 		global_page_state(NR_PAGETABLE),
-		global_page_state(NR_BOUNCE));
+		global_page_state(NR_BOUNCE),
+		global_page_state(NR_ISOLATE));
 
 	for_each_populated_zone(zone) {
 		int i;
Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1066,6 +1066,7 @@ static unsigned long shrink_inactive_lis
 		unsigned long nr_freed;
 		unsigned long nr_active;
 		unsigned int count[NR_LRU_LISTS] = { 0, };
+		unsigned int total_count;
 		int mode = lumpy_reclaim ? ISOLATE_BOTH : ISOLATE_INACTIVE;
 
 		nr_taken = sc->isolate_pages(sc->swap_cluster_max,
@@ -1082,6 +1083,7 @@ static unsigned long shrink_inactive_lis
 						-count[LRU_ACTIVE_ANON]);
 		__mod_zone_page_state(zone, NR_INACTIVE_ANON,
 						-count[LRU_INACTIVE_ANON]);
+		__mod_zone_page_state(zone, NR_ISOLATE, nr_taken);
 
 		if (scanning_global_lru(sc))
 			zone->pages_scanned += nr_scan;
@@ -1131,6 +1133,7 @@ static unsigned long shrink_inactive_lis
 			goto done;
 
 		spin_lock(&zone->lru_lock);
+		__mod_zone_page_state(zone, NR_ISOLATE, -nr_taken);
 		/*
 		 * Put back any unfreeable pages.
 		 */
@@ -1232,6 +1235,7 @@ static void move_active_pages_to_lru(str
 		}
 	}
 	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
+	__mod_zone_page_state(zone, NR_ISOLATE, -pgmoved);
 	if (!is_active_lru(lru))
 		__count_vm_events(PGDEACTIVATE, pgmoved);
 }
@@ -1267,6 +1271,7 @@ static void shrink_active_list(unsigned 
 		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -pgmoved);
 	else
 		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -pgmoved);
+	__mod_zone_page_state(zone, NR_ISOLATE, pgmoved);
 	spin_unlock_irq(&zone->lru_lock);
 
 	pgmoved = 0;  /* count referenced (mapping) mapped pages */
Index: b/mm/vmstat.c
===================================================================
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -697,6 +697,7 @@ static const char * const vmstat_text[] 
 	"unevictable_pgs_stranded",
 	"unevictable_pgs_mlockfreed",
 #endif
+	"isolate_pages",
 };
 
 static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
