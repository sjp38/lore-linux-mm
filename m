Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CBFCC6B002B
	for <linux-mm@kvack.org>; Mon,  2 May 2011 07:08:45 -0400 (EDT)
Date: Mon, 2 May 2011 19:08:40 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] mm: cut down __GFP_NORETRY page allocation
 failures
Message-ID: <20110502110840.GA31900@localhost>
References: <BANLkTinM9DjK9QsGtN0Sh308rr+86UMF0A@mail.gmail.com>
 <20110426063421.GC19717@localhost>
 <BANLkTi=xDozFNBXNdGDLK6EwWrfHyBifQw@mail.gmail.com>
 <20110426092029.GA27053@localhost>
 <20110426124743.e58d9746.akpm@linux-foundation.org>
 <20110428133644.GA12400@localhost>
 <20110429022824.GA8061@localhost>
 <20110430141741.GA4511@localhost>
 <20110501163542.GA3204@barrios-desktop>
 <20110502102945.GA7688@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110502102945.GA7688@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Li Shaohua <shaohua.li@intel.com>, Hugh Dickins <hughd@google.com>

> > Do you see my old patch? The patch want't incomplet but it's not bad for showing an idea.
> > http://marc.info/?l=linux-mm&m=129187231129887&w=4
> > The idea is to keep a page at leat for direct reclaimed process.
> > Could it mitigate your problem or could you enhacne the idea?
> > I think it's very simple and fair solution.
> 
> No it's not helping my problem, nr_alloc_fail and CAL are still high:
> 
> root@fat /home/wfg# ./test-dd-sparse.sh
> start time: 246
> total time: 531
> nr_alloc_fail 14097
> allocstall 1578332
> LOC:     542698     538947     536986     567118     552114     539605     541201     537623   Local timer interrupts
> RES:       3368       1908       1474       1476       2809       1602       1500       1509   Rescheduling interrupts
> CAL:     223844     224198     224268     224436     223952     224056     223700     223743   Function call interrupts
> TLB:        381         27         22         19         96        404        111         67   TLB shootdowns
> 
> root@fat /home/wfg# getdelays -dip `pidof dd`
> print delayacct stats ON
> printing IO accounting
> PID     5202
> 
> 
> CPU             count     real total  virtual total    delay total
>                  1132     3635447328     3627947550   276722091605
> IO              count    delay total  delay average
>                     2      187809974             62ms
> SWAP            count    delay total  delay average
>                     0              0              0ms
> RECLAIM         count    delay total  delay average
>                  1334    35304580824             26ms
> dd: read=278528, write=0, cancelled_write=0
> 
> I guess your patch is mainly fixing the high order allocations while
> my workload is mainly order 0 readahead page allocations. There are
> 1000 forks, however the "start time: 246" seems to indicate that the
> order-1 reclaim latency is not improved.
> 
> I'll try modifying your patch and see how it works out. The obvious
> change is to apply it to the order-0 case. Hope this won't create much
> more isolated pages.

I tried the below modified patch, removing the high order test and the
drain_all_pages() call. The results are not idea either:

root@fat /home/wfg# ./test-dd-sparse.sh
start time: 246
total time: 526
nr_alloc_fail 15582
allocstall 1583727
LOC:     532518     528880     528184     533426     532765     530526     531177     528757   Local timer interrupts
RES:       2350       1929       1538       1430       3359       1547       1422       1502   Rescheduling interrupts
CAL:     200017     200384     200336     199763     200369     199776     199504     199407   Function call interrupts
TLB:        285         19         24         10        121        306        113         69   TLB shootdowns

CPU             count     real total  virtual total    delay total
                 1154     3767427264     3742671454   273770720370
IO              count    delay total  delay average
                    1      279795961            279ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average
                 1385    27228068276             19ms
dd: read=12288, write=0, cancelled_write=0

Thanks,
Fengguang
---
Subject: Keep freed pages in direct reclaim
Date: Thu, 9 Dec 2010 14:01:32 +0900

From: Minchan Kim <minchan.kim@gmail.com>

direct reclaimed process often sleep and race with other processes.
Although direct reclaim proceess requires high order pags(order > 0) and
reclaims page successfully, other processes which require order-0 page
could steal the high order page for direct reclaimed process.

After all, direct reclaimed process try it again and it still has a
possibility of above scenario. It can make bad effects following as

1. direct reclaimed process latency is big
2. eviction working set page due to lumpy reclaim
3. continue to wake up kswapd

This patch solves it.

Fengguang:
fix
[ 1514.892933] BUG: unable to handle kernel
[ 1514.892958] ---[ end trace be7cb17861e1d25b ]---
[ 1514.893589] NULL pointer dereference at           (null)
[ 1514.893968] IP: [<ffffffff81101b2e>] shrink_page_list+0x3dc/0x501

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/buffer.c          |    2 +-
 include/linux/swap.h |    4 +++-
 mm/page_alloc.c      |   25 +++++++++++++++++++++----
 mm/vmscan.c          |   23 +++++++++++++++++++----
 4 files changed, 44 insertions(+), 10 deletions(-)

--- linux-next.orig/fs/buffer.c	2011-05-02 17:18:01.000000000 +0800
+++ linux-next/fs/buffer.c	2011-05-02 18:30:17.000000000 +0800
@@ -289,7 +289,7 @@ static void free_more_memory(void)
 						&zone);
 		if (zone)
 			try_to_free_pages(node_zonelist(nid, GFP_NOFS), 0,
-						GFP_NOFS, NULL);
+						GFP_NOFS, NULL, NULL);
 	}
 }
 
--- linux-next.orig/include/linux/swap.h	2011-05-02 17:18:01.000000000 +0800
+++ linux-next/include/linux/swap.h	2011-05-02 18:30:17.000000000 +0800
@@ -249,8 +249,10 @@ static inline void lru_cache_add_file(st
 #define ISOLATE_BOTH 2		/* Isolate both active and inactive pages. */
 
 /* linux/mm/vmscan.c */
+extern noinline_for_stack void free_page_list(struct list_head *free_pages);
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
-					gfp_t gfp_mask, nodemask_t *mask);
+					gfp_t gfp_mask, nodemask_t *mask,
+					struct list_head *freed_pages);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
 						  gfp_t gfp_mask, bool noswap,
 						  unsigned int swappiness);
--- linux-next.orig/mm/page_alloc.c	2011-05-02 17:18:01.000000000 +0800
+++ linux-next/mm/page_alloc.c	2011-05-02 18:31:30.000000000 +0800
@@ -1891,6 +1891,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_m
 	struct page *page = NULL;
 	struct reclaim_state reclaim_state;
 	bool drained = false;
+	LIST_HEAD(freed_pages);
 
 	cond_resched();
 
@@ -1901,16 +1902,31 @@ __alloc_pages_direct_reclaim(gfp_t gfp_m
 	reclaim_state.reclaimed_slab = 0;
 	current->reclaim_state = &reclaim_state;
 
-	*did_some_progress = try_to_free_pages(zonelist, order, gfp_mask, nodemask);
-
+	/*
+	 * If request is high order, keep the pages which are reclaimed
+	 * in own list for preventing the lose by other processes.
+	 */
+	*did_some_progress = try_to_free_pages(zonelist, order, gfp_mask,
+				nodemask, &freed_pages);
 	current->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
 	current->flags &= ~PF_MEMALLOC;
 
+	if (!list_empty(&freed_pages)) {
+		free_page_list(&freed_pages);
+		/* drain_all_pages(); */
+		/* drained = true; */
+		page = get_page_from_freelist(gfp_mask, nodemask, order,
+					zonelist, high_zoneidx,
+					alloc_flags, preferred_zone,
+					migratetype);
+		if (page)
+			goto out;
+	}
 	cond_resched();
 
 	if (unlikely(!(*did_some_progress)))
-		return NULL;
+		goto out;
 
 retry:
 	page = get_page_from_freelist(gfp_mask, nodemask, order,
@@ -1927,7 +1943,8 @@ retry:
 		drained = true;
 		goto retry;
 	}
-
+out:
+	VM_BUG_ON(!list_empty(&freed_pages));
 	return page;
 }
 
--- linux-next.orig/mm/vmscan.c	2011-05-02 17:18:01.000000000 +0800
+++ linux-next/mm/vmscan.c	2011-05-02 18:30:17.000000000 +0800
@@ -112,6 +112,9 @@ struct scan_control {
 	 * are scanned.
 	 */
 	nodemask_t	*nodemask;
+
+	/* keep freed pages */
+	struct list_head *freed_pages;
 };
 
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
@@ -681,7 +684,7 @@ static enum page_references page_check_r
 	return PAGEREF_RECLAIM;
 }
 
-static noinline_for_stack void free_page_list(struct list_head *free_pages)
+noinline_for_stack void free_page_list(struct list_head *free_pages)
 {
 	struct pagevec freed_pvec;
 	struct page *page, *tmp;
@@ -712,6 +715,10 @@ static unsigned long shrink_page_list(st
 	unsigned long nr_dirty = 0;
 	unsigned long nr_congested = 0;
 	unsigned long nr_reclaimed = 0;
+	struct list_head *free_list = &free_pages;
+
+	if (sc->freed_pages)
+		free_list = sc->freed_pages;
 
 	cond_resched();
 
@@ -904,7 +911,7 @@ free_it:
 		 * Is there need to periodically free_page_list? It would
 		 * appear not as the counts should be low
 		 */
-		list_add(&page->lru, &free_pages);
+		list_add(&page->lru, free_list);
 		continue;
 
 cull_mlocked:
@@ -940,7 +947,13 @@ keep_lumpy:
 	if (nr_dirty == nr_congested && nr_dirty != 0)
 		zone_set_flag(zone, ZONE_CONGESTED);
 
-	free_page_list(&free_pages);
+	/*
+	 * If reclaim is direct path and high order, caller should
+	 * free reclaimed pages. It is for preventing reclaimed pages
+	 * lose by other processes.
+	 */
+	if (!sc->freed_pages)
+		free_page_list(&free_pages);
 
 	list_splice(&ret_pages, page_list);
 	count_vm_events(PGACTIVATE, pgactivate);
@@ -2118,7 +2131,8 @@ out:
 }
 
 unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
-				gfp_t gfp_mask, nodemask_t *nodemask)
+				gfp_t gfp_mask, nodemask_t *nodemask,
+				struct list_head *freed_pages)
 {
 	unsigned long nr_reclaimed;
 	struct scan_control sc = {
@@ -2131,6 +2145,7 @@ unsigned long try_to_free_pages(struct z
 		.order = order,
 		.mem_cgroup = NULL,
 		.nodemask = nodemask,
+		.freed_pages = freed_pages,
 	};
 
 	trace_mm_vmscan_direct_reclaim_begin(order,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
