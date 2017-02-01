Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BA1F46B0033
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 00:47:29 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 14so475037562pgg.4
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 21:47:29 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id g21si13434576pgh.125.2017.01.31.21.47.27
        for <linux-mm@kvack.org>;
        Tue, 31 Jan 2017 21:47:28 -0800 (PST)
Date: Wed, 1 Feb 2017 14:47:24 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 0/6]mm: add new LRU list for MADV_FREE pages
Message-ID: <20170201054724.GA9438@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1485748619.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, danielmicay@gmail.com

Hi Shaohua,

On Sun, Jan 29, 2017 at 09:51:17PM -0800, Shaohua Li wrote:
> Hi,
> 
> We are trying to use MADV_FREE in jemalloc. Several issues are found. Without
> solving the issues, jemalloc can't use the MADV_FREE feature.
> - Doesn't support system without swap enabled. Because if swap is off, we can't
>   or can't efficiently age anonymous pages. And since MADV_FREE pages are mixed
>   with other anonymous pages, we can't reclaim MADV_FREE pages. In current
>   implementation, MADV_FREE will fallback to MADV_DONTNEED without swap enabled.
>   But in our environment, a lot of machines don't enable swap. This will prevent
>   our setup using MADV_FREE.
> - Increases memory pressure. page reclaim bias file pages reclaim against
>   anonymous pages. This doesn't make sense for MADV_FREE pages, because those
>   pages could be freed easily and refilled with very slight penality. Even page
>   reclaim doesn't bias file pages, there is still an issue, because MADV_FREE
>   pages and other anonymous pages are mixed together. To reclaim a MADV_FREE
>   page, we probably must scan a lot of other anonymous pages, which is
>   inefficient. In our test, we usually see oom with MADV_FREE enabled and nothing
>   without it.
> - RSS accounting. MADV_FREE pages are accounted as normal anon pages and
>   reclaimed lazily, so application's RSS becomes bigger. This confuses our
>   workloads. We have monitoring daemon running and if it finds applications' RSS
>   becomes abnormal, the daemon will kill the applications even kernel can reclaim
>   the memory easily. Currently we don't export separate RSS accounting for
>   MADV_FREE pages. This will prevent our setup using MADV_FREE too.
> 
> For the first two issues, introducing a new LRU list for MADV_FREE pages could
> solve the issues. We can directly reclaim MADV_FREE pages without writting them
> out to swap, so the first issue could be fixed. If only MADV_FREE pages are in
> the new list, page reclaim can easily reclaim such pages without interference
> of file or anonymous pages. The memory pressure issue will disappear.
> 
> Actually Minchan posted patches to add the LRU list before, but he didn't
> pursue. So I picked up them and the patches are based on Minchan's previous
> patches. The main difference between my patches and Minchan previous patches is
> page reclaim policy. Minchan's patches introduces a knob to balance the reclaim
> of MADV_FREE pages and anon/file pages, while the patches always reclaim
> MADV_FREE pages first if there are. I described the reason in patch 5.

First of all, thanks for th effort to support MADV_FREE for swapless system,
Shaohua!

CCing Daniel,

The reason I have postponed is due to controverial part about balancing
used-once vs. madv_freed apges. I thought it doesn't make sense to reclaim
madv_freed pages first even if there are lots of used-once pages.

Recently, Johannes posted patches for balancing file/anon and it was based
on the cost model, IIRC. I wanted to base on it.

The idea is VM reclaims file-based pages and if refault happens, we can measure
refault distance and sizeof(LRU_LAZYFREE list). If refault distance is smaller
than lazyfree LRU list's size, it means the file-backed page have been kept
in memory if we have discarded lazyfree pages so it adds more cost to reclaim
lazyfree LRU list more agressively.

I tested your patch with simple MADV_FREE workload(just alloc and then repeated
touch/madv_free) with background stream-read process. In that case, the
MADV_FREE workload regressed in half without any gain for stream-read process.

I tested hacky code to simulate feedback loop I suggested idea and it restores
the performance regression. I'm not saying below hacky patch should merge in
but I think we should have used-once reclaim feedback logic to prevent
unnecessary purging for madv_freed pages.

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 589a165..39d4bba 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -703,6 +703,7 @@ typedef struct pglist_data {
 	/* Per-node vmstats */
 	struct per_cpu_nodestat __percpu *per_cpu_nodestats;
 	atomic_long_t		vm_stat[NR_VM_NODE_STAT_ITEMS];
+	bool lazyfree;
 } pg_data_t;
 
 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f809f04..cf54b81 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2364,22 +2364,25 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 	struct blk_plug plug;
 	bool scan_adjusted;
 
-	/* reclaim all lazyfree pages so don't apply priority  */
-	nr[LRU_LAZYFREE] = lruvec_lru_size(lruvec, LRU_LAZYFREE, sc->reclaim_idx);
-	while (nr[LRU_LAZYFREE]) {
-		nr_to_scan = min(nr[LRU_LAZYFREE], SWAP_CLUSTER_MAX);
-		nr[LRU_LAZYFREE] -= nr_to_scan;
-		nr_reclaimed += shrink_inactive_list(nr_to_scan, lruvec, sc,
-			LRU_LAZYFREE);
-
-		if (nr_reclaimed >= nr_to_reclaim)
-			break;
-		cond_resched();
-	}
+	if (pgdat->lazyfree) {
+		/* reclaim all lazyfree pages so don't apply priority  */
+		nr[LRU_LAZYFREE] = lruvec_lru_size(lruvec, LRU_LAZYFREE, sc->reclaim_idx);
+		while (nr[LRU_LAZYFREE]) {
+			nr_to_scan = min(nr[LRU_LAZYFREE], SWAP_CLUSTER_MAX);
+			nr[LRU_LAZYFREE] -= nr_to_scan;
+			nr_reclaimed += shrink_inactive_list(nr_to_scan, lruvec, sc,
+				LRU_LAZYFREE);
+
+			if (nr_reclaimed >= nr_to_reclaim)
+				break;
+			cond_resched();
+		}
 
-	if (nr_reclaimed >= nr_to_reclaim) {
-		sc->nr_reclaimed += nr_reclaimed;
-		return;
+		if (nr_reclaimed >= nr_to_reclaim) {
+			sc->nr_reclaimed += nr_reclaimed;
+			pgdat->lazyfree = false;
+			return;
+		}
 	}
 
 	get_scan_count(lruvec, memcg, sc, nr, lru_pages);
diff --git a/mm/workingset.c b/mm/workingset.c
index c573cb2..2a01b91 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -233,7 +233,7 @@ void *workingset_eviction(struct address_space *mapping, struct page *page)
 bool workingset_refault(void *shadow)
 {
 	unsigned long refault_distance;
-	unsigned long active_file;
+	unsigned long active_file, lazyfree;
 	struct mem_cgroup *memcg;
 	unsigned long eviction;
 	struct lruvec *lruvec;
@@ -268,6 +268,7 @@ bool workingset_refault(void *shadow)
 	lruvec = mem_cgroup_lruvec(pgdat, memcg);
 	refault = atomic_long_read(&lruvec->inactive_age);
 	active_file = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE, MAX_NR_ZONES);
+	lazyfree = lruvec_lru_size(lruvec, LRU_LAZYFREE, MAX_NR_ZONES);
 	rcu_read_unlock();
 
 	/*
@@ -290,6 +291,9 @@ bool workingset_refault(void *shadow)
 
 	inc_node_state(pgdat, WORKINGSET_REFAULT);
 
+	if (refault_distance <= lazyfree)
+		pgdat->lazyfree = true;
+
 	if (refault_distance <= active_file) {
 		inc_node_state(pgdat, WORKINGSET_ACTIVATE);
 		return true;

> 
> For the third issue, we can add a separate RSS count for MADV_FREE pages. The
> count will be increased in madvise syscall and decreased in page reclaim (eg,
> unmap). One issue is activate_page(). A MADV_FREE page can be promoted to
> active page there. But there isn't mm_struct context at that place. Iterating
> vma there sounds too silly. The patchset don't fix this issue yet. Hopefully
> somebody can share a hint how to fix this issue.
> 
> Thanks,
> Shaohua
> 
> Minchan previous patches:
> http://marc.info/?l=linux-mm&m=144800657002763&w=2
> 
> Shaohua Li (6):
>   mm: add wrap for page accouting index
>   mm: add lazyfree page flag
>   mm: add LRU_LAZYFREE lru list
>   mm: move MADV_FREE pages into LRU_LAZYFREE list
>   mm: reclaim lazyfree pages
>   mm: enable MADV_FREE for swapless system
> 
>  drivers/base/node.c                       |  2 +
>  drivers/staging/android/lowmemorykiller.c |  3 +-
>  fs/proc/meminfo.c                         |  1 +
>  fs/proc/task_mmu.c                        |  8 ++-
>  include/linux/mm_inline.h                 | 41 +++++++++++++
>  include/linux/mmzone.h                    |  9 +++
>  include/linux/page-flags.h                |  6 ++
>  include/linux/swap.h                      |  2 +-
>  include/linux/vm_event_item.h             |  2 +-
>  include/trace/events/mmflags.h            |  1 +
>  include/trace/events/vmscan.h             | 31 +++++-----
>  kernel/power/snapshot.c                   |  1 +
>  mm/compaction.c                           | 11 ++--
>  mm/huge_memory.c                          |  6 +-
>  mm/khugepaged.c                           |  6 +-
>  mm/madvise.c                              | 11 +---
>  mm/memcontrol.c                           |  4 ++
>  mm/memory-failure.c                       |  3 +-
>  mm/memory_hotplug.c                       |  3 +-
>  mm/mempolicy.c                            |  3 +-
>  mm/migrate.c                              | 29 ++++------
>  mm/page_alloc.c                           | 10 ++++
>  mm/rmap.c                                 |  7 ++-
>  mm/swap.c                                 | 51 +++++++++-------
>  mm/vmscan.c                               | 96 +++++++++++++++++++++++--------
>  mm/vmstat.c                               |  4 ++
>  26 files changed, 242 insertions(+), 109 deletions(-)
> 
> -- 
> 2.9.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
