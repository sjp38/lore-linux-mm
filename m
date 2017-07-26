Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7543B6B0292
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 15:24:11 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h29so192657243pfd.2
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 12:24:11 -0700 (PDT)
Received: from mail-pg0-f43.google.com (mail-pg0-f43.google.com. [74.125.83.43])
        by mx.google.com with ESMTPS id s10si10211073pgc.281.2017.07.26.12.24.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 12:24:10 -0700 (PDT)
Received: by mail-pg0-f43.google.com with SMTP id 123so88117026pgj.1
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 12:24:10 -0700 (PDT)
From: Matthias Kaehlcke <mka@chromium.org>
Subject: [PATCH] mm: memcontrol: Cast mismatched enum types passed to memcg state and event functions
Date: Wed, 26 Jul 2017 12:23:56 -0700
Message-Id: <20170726192356.18420-1-mka@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Doug Anderson <dianders@chromium.org>, Matthias Kaehlcke <mka@chromium.org>

In multiple instances enum values of an incorrect type are passed to
mod_memcg_state() and other memcg functions. Apparently this is
intentional, however clang rightfully generates tons of warnings about
the mismatched types. Cast the offending values to the type expected
by the called function. The casts add noise, but this seems preferable
over losing the typesafe interface or/and disabling the warning.

Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
---
 include/linux/memcontrol.h | 11 ++++++-----
 mm/memcontrol.c            | 11 +++++++----
 mm/swap.c                  |  2 +-
 mm/vmscan.c                | 12 ++++++++----
 4 files changed, 22 insertions(+), 14 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 3914e3dd6168..66a0c92a9869 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -576,7 +576,7 @@ static inline void __mod_lruvec_state(struct lruvec *lruvec,
 	if (mem_cgroup_disabled())
 		return;
 	pn = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
-	__mod_memcg_state(pn->memcg, idx, val);
+	__mod_memcg_state(pn->memcg, (enum memcg_stat_item)idx, val);
 	__this_cpu_add(pn->lruvec_stat->count[idx], val);
 }
 
@@ -589,7 +589,7 @@ static inline void mod_lruvec_state(struct lruvec *lruvec,
 	if (mem_cgroup_disabled())
 		return;
 	pn = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
-	mod_memcg_state(pn->memcg, idx, val);
+	mod_memcg_state(pn->memcg, (enum memcg_stat_item)idx, val);
 	this_cpu_add(pn->lruvec_stat->count[idx], val);
 }
 
@@ -601,7 +601,7 @@ static inline void __mod_lruvec_page_state(struct page *page,
 	__mod_node_page_state(page_pgdat(page), idx, val);
 	if (mem_cgroup_disabled() || !page->mem_cgroup)
 		return;
-	__mod_memcg_state(page->mem_cgroup, idx, val);
+	__mod_memcg_state(page->mem_cgroup, (enum memcg_stat_item)idx, val);
 	pn = page->mem_cgroup->nodeinfo[page_to_nid(page)];
 	__this_cpu_add(pn->lruvec_stat->count[idx], val);
 }
@@ -614,7 +614,7 @@ static inline void mod_lruvec_page_state(struct page *page,
 	mod_node_page_state(page_pgdat(page), idx, val);
 	if (mem_cgroup_disabled() || !page->mem_cgroup)
 		return;
-	mod_memcg_state(page->mem_cgroup, idx, val);
+	mod_memcg_state(page->mem_cgroup, (enum memcg_stat_item)idx, val);
 	pn = page->mem_cgroup->nodeinfo[page_to_nid(page)];
 	this_cpu_add(pn->lruvec_stat->count[idx], val);
 }
@@ -635,7 +635,8 @@ static inline void count_memcg_page_event(struct page *page,
 					  enum memcg_stat_item idx)
 {
 	if (page->mem_cgroup)
-		count_memcg_events(page->mem_cgroup, idx, 1);
+		count_memcg_events(page->mem_cgroup,
+			(enum vm_event_item)idx, 1);
 }
 
 static inline void count_memcg_event_mm(struct mm_struct *mm,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3df3c04d73ab..8b7b700cd53c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3573,7 +3573,8 @@ static int mem_cgroup_oom_control_read(struct seq_file *sf, void *v)
 
 	seq_printf(sf, "oom_kill_disable %d\n", memcg->oom_kill_disable);
 	seq_printf(sf, "under_oom %d\n", (bool)memcg->under_oom);
-	seq_printf(sf, "oom_kill %lu\n", memcg_sum_events(memcg, OOM_KILL));
+	seq_printf(sf, "oom_kill %lu\n",
+		memcg_sum_events(memcg, (enum memcg_event_item)OOM_KILL));
 	return 0;
 }
 
@@ -3650,10 +3651,11 @@ void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
 	struct mem_cgroup *memcg = mem_cgroup_from_css(wb->memcg_css);
 	struct mem_cgroup *parent;
 
-	*pdirty = memcg_page_state(memcg, NR_FILE_DIRTY);
+	*pdirty = memcg_page_state(memcg, (enum memcg_stat_item)NR_FILE_DIRTY);
 
 	/* this should eventually include NR_UNSTABLE_NFS */
-	*pwriteback = memcg_page_state(memcg, NR_WRITEBACK);
+	*pwriteback = memcg_page_state(memcg,
+			(enum memcg_stat_item)NR_WRITEBACK);
 	*pfilepages = mem_cgroup_nr_lru_pages(memcg, (1 << LRU_INACTIVE_FILE) |
 						     (1 << LRU_ACTIVE_FILE));
 	*pheadroom = PAGE_COUNTER_MAX;
@@ -5174,7 +5176,8 @@ static int memory_events_show(struct seq_file *m, void *v)
 	seq_printf(m, "high %lu\n", memcg_sum_events(memcg, MEMCG_HIGH));
 	seq_printf(m, "max %lu\n", memcg_sum_events(memcg, MEMCG_MAX));
 	seq_printf(m, "oom %lu\n", memcg_sum_events(memcg, MEMCG_OOM));
-	seq_printf(m, "oom_kill %lu\n", memcg_sum_events(memcg, OOM_KILL));
+	seq_printf(m, "oom_kill %lu\n",
+		memcg_sum_events(memcg, (enum memcg_event_item)OOM_KILL));
 
 	return 0;
 }
diff --git a/mm/swap.c b/mm/swap.c
index 60b1d2a75852..be08c0e27259 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -591,7 +591,7 @@ static void lru_lazyfree_fn(struct page *page, struct lruvec *lruvec,
 		add_page_to_lru_list(page, lruvec, LRU_INACTIVE_FILE);
 
 		__count_vm_events(PGLAZYFREE, hpage_nr_pages(page));
-		count_memcg_page_event(page, PGLAZYFREE);
+		count_memcg_page_event(page, (enum memcg_stat_item)PGLAZYFREE);
 		update_page_reclaim_stat(lruvec, 1, 0);
 	}
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a1af041930a6..14c465395b39 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1294,7 +1294,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 
 			count_vm_event(PGLAZYFREED);
-			count_memcg_page_event(page, PGLAZYFREED);
+			count_memcg_page_event(page,
+				(enum memcg_stat_item)PGLAZYFREED);
 		} else if (!mapping || !__remove_mapping(mapping, page, true))
 			goto keep_locked;
 		/*
@@ -1324,7 +1325,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (!PageMlocked(page)) {
 			SetPageActive(page);
 			pgactivate++;
-			count_memcg_page_event(page, PGACTIVATE);
+			count_memcg_page_event(page,
+				(enum memcg_stat_item)PGACTIVATE);
 		}
 keep_locked:
 		unlock_page(page);
@@ -2099,7 +2101,8 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	active = lruvec_lru_size(lruvec, active_lru, sc->reclaim_idx);
 
 	if (memcg)
-		refaults = memcg_page_state(memcg, WORKINGSET_ACTIVATE);
+		refaults = memcg_page_state(memcg,
+				(enum memcg_stat_item)WORKINGSET_ACTIVATE);
 	else
 		refaults = node_page_state(pgdat, WORKINGSET_ACTIVATE);
 
@@ -2795,7 +2798,8 @@ static void snapshot_refaults(struct mem_cgroup *root_memcg, pg_data_t *pgdat)
 		struct lruvec *lruvec;
 
 		if (memcg)
-			refaults = memcg_page_state(memcg, WORKINGSET_ACTIVATE);
+			refaults = memcg_page_state(memcg,
+			    (enum memcg_stat_item)WORKINGSET_ACTIVATE);
 		else
 			refaults = node_page_state(pgdat, WORKINGSET_ACTIVATE);
 
-- 
2.14.0.rc0.400.g1c36432dff-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
