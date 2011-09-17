Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0EF82940067
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 23:39:48 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p8H3djGt021527
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 20:39:45 -0700
Received: from yie21 (yie21.prod.google.com [10.243.66.21])
	by wpaz37.hot.corp.google.com with ESMTP id p8H3dijq029111
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 20:39:44 -0700
Received: by yie21 with SMTP id 21so4363451yie.26
        for <linux-mm@kvack.org>; Fri, 16 Sep 2011 20:39:44 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 7/8] kstaled: add histogram sampling functionality
Date: Fri, 16 Sep 2011 20:39:12 -0700
Message-Id: <1316230753-8693-8-git-send-email-walken@google.com>
In-Reply-To: <1316230753-8693-1-git-send-email-walken@google.com>
References: <1316230753-8693-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michael Wolf <mjwolf@us.ibm.com>

add statistics for pages that have been idle for 1,2,5,15,30,60,120 or
240 scan intervals into /dev/cgroup/*/memory.idle_page_stats


Signed-off-by: Michel Lespinasse <walken@google.com>
---
 include/linux/mmzone.h |    2 +
 mm/memcontrol.c        |  103 +++++++++++++++++++++++++++++++++++++++---------
 mm/memory_hotplug.c    |    6 +++
 3 files changed, 92 insertions(+), 19 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 272fbed..d8eca1b 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -633,6 +633,8 @@ typedef struct pglist_data {
 					     range, including holes */
 #ifdef CONFIG_KSTALED
 	unsigned long node_idle_scan_pfn;
+	u8 *node_idle_page_age;           /* number of scan intervals since
+					     each page was referenced */
 #endif
 	int node_id;
 	wait_queue_head_t kswapd_wait;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4a76fdcf..ef406a1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -207,6 +207,11 @@ struct mem_cgroup_eventfd_list {
 static void mem_cgroup_threshold(struct mem_cgroup *mem);
 static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
 
+#ifdef CONFIG_KSTALED
+static const int kstaled_buckets[] = {1, 2, 5, 15, 30, 60, 120, 240};
+#define NUM_KSTALED_BUCKETS ARRAY_SIZE(kstaled_buckets)
+#endif
+
 /*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
@@ -292,7 +297,8 @@ struct mem_cgroup {
 		unsigned long idle_clean;
 		unsigned long idle_dirty_file;
 		unsigned long idle_dirty_swap;
-	} idle_page_stats, idle_scan_stats;
+	} idle_page_stats[NUM_KSTALED_BUCKETS],
+	  idle_scan_stats[NUM_KSTALED_BUCKETS];
 	unsigned long idle_page_scans;
 #endif
 };
@@ -4686,18 +4692,29 @@ static int mem_cgroup_idle_page_stats_read(struct cgroup *cgrp,
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
 	unsigned int seqcount;
-	struct idle_page_stats stats;
+	struct idle_page_stats stats[NUM_KSTALED_BUCKETS];
 	unsigned long scans;
+	int bucket;
 
 	do {
 		seqcount = read_seqcount_begin(&mem->idle_page_stats_lock);
-		stats = mem->idle_page_stats;
+		memcpy(stats, mem->idle_page_stats, sizeof(stats));
 		scans = mem->idle_page_scans;
 	} while (read_seqcount_retry(&mem->idle_page_stats_lock, seqcount));
 
-	cb->fill(cb, "idle_clean", stats.idle_clean * PAGE_SIZE);
-	cb->fill(cb, "idle_dirty_file", stats.idle_dirty_file * PAGE_SIZE);
-	cb->fill(cb, "idle_dirty_swap", stats.idle_dirty_swap * PAGE_SIZE);
+	for (bucket = 0; bucket < NUM_KSTALED_BUCKETS; bucket++) {
+		char basename[32], name[32];
+		if (!bucket)
+			sprintf(basename, "idle");
+		else
+			sprintf(basename, "idle_%d", kstaled_buckets[bucket]);
+		sprintf(name, "%s_clean", basename);
+		cb->fill(cb, name, stats[bucket].idle_clean * PAGE_SIZE);
+		sprintf(name, "%s_dirty_file", basename);
+		cb->fill(cb, name, stats[bucket].idle_dirty_file * PAGE_SIZE);
+		sprintf(name, "%s_dirty_swap", basename);
+		cb->fill(cb, name, stats[bucket].idle_dirty_swap * PAGE_SIZE);
+	}
 	cb->fill(cb, "scans", scans);
 
 	return 0;
@@ -5620,12 +5637,25 @@ static unsigned int kstaled_scan_seconds;
 static DEFINE_SPINLOCK(kstaled_scan_seconds_lock);
 static DECLARE_WAIT_QUEUE_HEAD(kstaled_wait);
 
-static inline void kstaled_scan_page(struct page *page)
+static inline struct idle_page_stats *
+kstaled_idle_stats(struct mem_cgroup *mem, int age)
+{
+	int bucket = 0;
+
+	while (age >= kstaled_buckets[bucket + 1])
+		if (++bucket == NUM_KSTALED_BUCKETS - 1)
+			break;
+	return mem->idle_scan_stats + bucket;
+}
+
+static inline void kstaled_scan_page(struct page *page, u8 *idle_page_age)
 {
 	bool is_locked = false;
 	bool is_file;
 	struct pr_info info;
 	struct page_cgroup *pc;
+	struct mem_cgroup *mem;
+	int age;
 	struct idle_page_stats *stats;
 
 	/*
@@ -5699,17 +5729,25 @@ static inline void kstaled_scan_page(struct page *page)
 
 	/* Find out if the page is idle. Also test for pending mlock. */
 	page_referenced_kstaled(page, is_locked, &info);
-	if ((info.pr_flags & PR_REFERENCED) || (info.vm_flags & VM_LOCKED))
+	if ((info.pr_flags & PR_REFERENCED) || (info.vm_flags & VM_LOCKED)) {
+		*idle_page_age = 0;
 		goto out;
+	}
 
 	/* Locate kstaled stats for the page's cgroup. */
 	pc = lookup_page_cgroup(page);
 	if (!pc)
 		goto out;
 	lock_page_cgroup(pc);
+	mem = pc->mem_cgroup;
 	if (!PageCgroupUsed(pc))
 		goto unlock_page_cgroup_out;
-	stats = &pc->mem_cgroup->idle_scan_stats;
+
+	/* Page is idle, increment its age and get the right stats bucket */
+	age = *idle_page_age;
+	if (age < 255)
+		*idle_page_age = ++age;
+	stats = kstaled_idle_stats(mem, age);
 
 	/* Finally increment the correct statistic for this page. */
 	if (!(info.pr_flags & PR_DIRTY) &&
@@ -5733,11 +5771,22 @@ static bool kstaled_scan_node(pg_data_t *pgdat, int scan_seconds, bool reset)
 {
 	unsigned long flags;
 	unsigned long pfn, end, node_end;
+	u8 *idle_page_age;
 
 	pgdat_resize_lock(pgdat, &flags);
 
+	if (!pgdat->node_idle_page_age) {
+		pgdat->node_idle_page_age = vmalloc(pgdat->node_spanned_pages);
+		if (!pgdat->node_idle_page_age) {
+			pgdat_resize_unlock(pgdat, &flags);
+			return false;
+		}
+		memset(pgdat->node_idle_page_age, 0, pgdat->node_spanned_pages);
+	}
+
 	pfn = pgdat->node_start_pfn;
 	node_end = pfn + pgdat->node_spanned_pages;
+	idle_page_age = pgdat->node_idle_page_age - pfn;
 	if (!reset && pfn < pgdat->node_idle_scan_pfn)
 		pfn = pgdat->node_idle_scan_pfn;
 	end = min(pfn + DIV_ROUND_UP(pgdat->node_spanned_pages, scan_seconds),
@@ -5759,7 +5808,8 @@ static bool kstaled_scan_node(pg_data_t *pgdat, int scan_seconds, bool reset)
 				/* abort if the node got resized */
 				if (pfn < pgdat->node_start_pfn ||
 				    node_end > (pgdat->node_start_pfn +
-						pgdat->node_spanned_pages))
+						pgdat->node_spanned_pages) ||
+				    !pgdat->node_idle_page_age)
 					goto abort;
 #endif
 			}
@@ -5767,7 +5817,8 @@ static bool kstaled_scan_node(pg_data_t *pgdat, int scan_seconds, bool reset)
 			if (!pfn_valid(pfn))
 				continue;
 
-			kstaled_scan_page(pfn_to_page(pfn));
+			kstaled_scan_page(pfn_to_page(pfn),
+					  idle_page_age + pfn);
 		}
 	}
 
@@ -5778,6 +5829,26 @@ abort:
 	return pfn >= node_end;
 }
 
+static void kstaled_update_stats(struct mem_cgroup *mem)
+{
+	struct idle_page_stats tot;
+	int i;
+
+	memset(&tot, 0, sizeof(tot));
+
+	write_seqcount_begin(&mem->idle_page_stats_lock);
+	for (i = NUM_KSTALED_BUCKETS - 1; i >= 0; i--) {
+		tot.idle_clean      += mem->idle_scan_stats[i].idle_clean;
+		tot.idle_dirty_file += mem->idle_scan_stats[i].idle_dirty_file;
+		tot.idle_dirty_swap += mem->idle_scan_stats[i].idle_dirty_swap;
+		mem->idle_page_stats[i] = tot;
+	}
+	mem->idle_page_scans++;
+	write_seqcount_end(&mem->idle_page_stats_lock);
+
+	memset(&mem->idle_scan_stats, 0, sizeof(mem->idle_scan_stats));
+}
+
 static int kstaled(void *dummy)
 {
 	int delayed = 0;
@@ -5810,14 +5881,8 @@ static int kstaled(void *dummy)
 		if (scan_done) {
 			struct mem_cgroup *mem;
 
-			for_each_mem_cgroup_all(mem) {
-				write_seqcount_begin(&mem->idle_page_stats_lock);
-				mem->idle_page_stats = mem->idle_scan_stats;
-				mem->idle_page_scans++;
-				write_seqcount_end(&mem->idle_page_stats_lock);
-				memset(&mem->idle_scan_stats, 0,
-				       sizeof(mem->idle_scan_stats));
-			}
+			for_each_mem_cgroup_all(mem)
+				kstaled_update_stats(mem);
 		}
 
 		delta = jiffies - earlier;
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c46887b..0b490ac 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -211,6 +211,12 @@ static void grow_pgdat_span(struct pglist_data *pgdat, unsigned long start_pfn,
 
 	pgdat->node_spanned_pages = max(old_pgdat_end_pfn, end_pfn) -
 					pgdat->node_start_pfn;
+#ifdef CONFIG_KSTALED
+	if (pgdat->node_idle_page_age) {
+		vfree(pgdat->node_idle_page_age);
+		pgdat->node_idle_page_age = NULL;
+	}
+#endif
 }
 
 static int __meminit __add_zone(struct zone *zone, unsigned long phys_start_pfn)
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
