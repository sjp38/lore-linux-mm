Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 942996B003D
	for <linux-mm@kvack.org>; Fri, 11 Dec 2009 16:47:02 -0500 (EST)
Date: Fri, 11 Dec 2009 16:46:51 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH v2] vmscan: limit concurrent reclaimers in shrink_zone
Message-ID: <20091211164651.036f5340@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: lwoodman@redhat.com
Cc: akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

Under very heavy multi-process workloads, like AIM7, the VM can
get into trouble in a variety of ways.  The trouble start when
there are hundreds, or even thousands of processes active in the
page reclaim code.

Not only can the system suffer enormous slowdowns because of
lock contention (and conditional reschedules) between thousands
of processes in the page reclaim code, but each process will try
to free up to SWAP_CLUSTER_MAX pages, even when the system already
has lots of memory free.

It should be possible to avoid both of those issues at once, by
simply limiting how many processes are active in the page reclaim
code simultaneously.

If too many processes are active doing page reclaim in one zone,
simply go to sleep in shrink_zone().

On wakeup, check whether enough memory has been freed already
before jumping into the page reclaim code ourselves.  We want
to use the same threshold here that is used in the page allocator
for deciding whether or not to call the page reclaim code in the
first place, otherwise some unlucky processes could end up freeing
memory for the rest of the system.

Reported-by: Larry Woodman <lwoodman@redhat.com>
Signed-off-by: Rik van Riel <riel@redhat.com>

--- 
v2:
- fix typos in sysctl.c and vm.txt
- move the code in sysctl.c out from under the ifdef
- only __GFP_FS|__GFP_IO tasks can wait

 Documentation/sysctl/vm.txt |   18 ++++++++++++++
 include/linux/mmzone.h      |    4 +++
 include/linux/swap.h        |    1 +
 kernel/sysctl.c             |    7 +++++
 mm/page_alloc.c             |    3 ++
 mm/vmscan.c                 |   40 +++++++++++++++++++++++++++++++++
 6 files changed, 73 insertions(+), 0 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index fc5790d..8bd1a96 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -32,6 +32,7 @@ Currently, these files are in /proc/sys/vm:
 - legacy_va_layout
 - lowmem_reserve_ratio
 - max_map_count
+- max_zone_concurrent_reclaimers
 - memory_failure_early_kill
 - memory_failure_recovery
 - min_free_kbytes
@@ -278,6 +279,23 @@ The default value is 65536.
 
 =============================================================
 
+max_zone_concurrent_reclaimers:
+
+The number of processes that are allowed to simultaneously reclaim
+memory from a particular memory zone.
+
+With certain workloads, hundreds of processes end up in the page
+reclaim code simultaneously.  This can cause large slowdowns due
+to lock contention, freeing of way too much memory and occasionally
+false OOM kills.
+
+To avoid these problems, only allow a smaller number of processes
+to reclaim pages from each memory zone simultaneously.
+
+The default value is 8.
+
+=============================================================
+
 memory_failure_early_kill:
 
 Control how to kill processes when uncorrected memory error (typically
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 30fe668..ed614b8 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -345,6 +345,10 @@ struct zone {
 	/* Zone statistics */
 	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
 
+	/* Number of processes running page reclaim code on this zone. */
+	atomic_t		concurrent_reclaimers;
+	wait_queue_head_t	reclaim_wait;
+
 	/*
 	 * prev_priority holds the scanning priority for this zone.  It is
 	 * defined as the scanning priority at which we achieved our reclaim
diff --git a/include/linux/swap.h b/include/linux/swap.h
index a2602a8..661eec7 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -254,6 +254,7 @@ extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
 extern long vm_total_pages;
+extern int max_zone_concurrent_reclaimers;
 
 #ifdef CONFIG_NUMA
 extern int zone_reclaim_mode;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 6ff0ae6..4ec17ed 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1271,6 +1271,13 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one,
 	},
 #endif
+	{
+		.procname	= "max_zone_concurrent_reclaimers",
+		.data		= &max_zone_concurrent_reclaimers,
+		.maxlen		= sizeof(max_zone_concurrent_reclaimers),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 
 /*
  * NOTE: do not add new entries to this table unless you have read
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 11ae66e..ca9cae1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3852,6 +3852,9 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 
 		zone->prev_priority = DEF_PRIORITY;
 
+		atomic_set(&zone->concurrent_reclaimers, 0);
+		init_waitqueue_head(&zone->reclaim_wait);
+
 		zone_pcp_init(zone);
 		for_each_lru(l) {
 			INIT_LIST_HEAD(&zone->lru[l].list);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2bbee91..ecfe28c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -40,6 +40,7 @@
 #include <linux/memcontrol.h>
 #include <linux/delayacct.h>
 #include <linux/sysctl.h>
+#include <linux/wait.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -129,6 +130,17 @@ struct scan_control {
 int vm_swappiness = 60;
 long vm_total_pages;	/* The total number of pages which the VM controls */
 
+/*
+ * Maximum number of processes concurrently running the page
+ * reclaim code in a memory zone.  Having too many processes
+ * just results in them burning CPU time waiting for locks,
+ * so we're better off limiting page reclaim to a sane number
+ * of processes at a time.  We do this per zone so local node
+ * reclaim on one NUMA node will not block other nodes from
+ * making progress.
+ */
+int max_zone_concurrent_reclaimers = 8;
+
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
 
@@ -1600,6 +1612,31 @@ static void shrink_zone(int priority, struct zone *zone,
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 	int noswap = 0;
 
+	if (!current_is_kswapd() && atomic_read(&zone->concurrent_reclaimers) >
+				max_zone_concurrent_reclaimers &&
+				(sc->gfp_mask & (__GFP_IO|__GFP_FS)) ==
+				(__GFP_IO|__GFP_FS)) {
+		/*
+		 * Do not add to the lock contention if this zone has
+		 * enough processes doing page reclaim already, since
+		 * we would just make things slower.
+		 */
+		sleep_on(&zone->reclaim_wait);
+
+		/*
+		 * If other processes freed enough memory while we waited,
+		 * break out of the loop and go back to the allocator.
+		 */
+		if (zone_watermark_ok(zone, sc->order, low_wmark_pages(zone),
+					0, 0)) {
+			wake_up(&zone->reclaim_wait);
+			sc->nr_reclaimed += nr_to_reclaim;
+			return;
+		}
+	}
+
+	atomic_inc(&zone->concurrent_reclaimers);
+
 	/* If we have no swap space, do not bother scanning anon pages. */
 	if (!sc->may_swap || (nr_swap_pages <= 0)) {
 		noswap = 1;
@@ -1655,6 +1692,9 @@ static void shrink_zone(int priority, struct zone *zone,
 		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
 
 	throttle_vm_writeout(sc->gfp_mask);
+
+	atomic_dec(&zone->concurrent_reclaimers);
+	wake_up(&zone->reclaim_wait);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
