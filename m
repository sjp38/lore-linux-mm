Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6D5E66B0266
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 17:15:29 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id l4so4672253wre.10
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 14:15:29 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o10si4011791wrg.50.2017.11.30.14.15.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 14:15:27 -0800 (PST)
Date: Thu, 30 Nov 2017 14:15:25 -0800
From: akpm@linux-foundation.org
Subject: [patch 05/15] mm: memcontrol: eliminate raw access to stat and
 event counters
Message-ID: <5a2082fd.WjoupfO+d3NgxSKn%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.com, vdavydov.dev@gmail.com

From: Johannes Weiner <hannes@cmpxchg.org>
Subject: mm: memcontrol: eliminate raw access to stat and event counters

Replace all raw 'this_cpu_' modifications of the stat and event per-cpu
counters with API functions such as mod_memcg_state().

This makes the code easier to read, but is also in preparation for the
next patch, which changes the per-cpu implementation of those counters.

Link: http://lkml.kernel.org/r/20171103153336.24044-1-hannes@cmpxchg.org
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/memcontrol.h |   31 +++++++++++-------
 mm/memcontrol.c            |   59 ++++++++++++++---------------------
 2 files changed, 45 insertions(+), 45 deletions(-)

diff -puN include/linux/memcontrol.h~mm-memcontrol-eliminate-raw-access-to-stat-and-event-counters include/linux/memcontrol.h
--- a/include/linux/memcontrol.h~mm-memcontrol-eliminate-raw-access-to-stat-and-event-counters
+++ a/include/linux/memcontrol.h
@@ -272,13 +272,6 @@ static inline bool mem_cgroup_disabled(v
 	return !cgroup_subsys_enabled(memory_cgrp_subsys);
 }
 
-static inline void mem_cgroup_event(struct mem_cgroup *memcg,
-				    enum memcg_event_item event)
-{
-	this_cpu_inc(memcg->stat->events[event]);
-	cgroup_file_notify(&memcg->events_file);
-}
-
 bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg);
 
 int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
@@ -627,15 +620,23 @@ unsigned long mem_cgroup_soft_limit_recl
 						gfp_t gfp_mask,
 						unsigned long *total_scanned);
 
+/* idx can be of type enum memcg_event_item or vm_event_item */
+static inline void __count_memcg_events(struct mem_cgroup *memcg,
+					int idx, unsigned long count)
+{
+	if (!mem_cgroup_disabled())
+		__this_cpu_add(memcg->stat->events[idx], count);
+}
+
+/* idx can be of type enum memcg_event_item or vm_event_item */
 static inline void count_memcg_events(struct mem_cgroup *memcg,
-				      enum vm_event_item idx,
-				      unsigned long count)
+				      int idx, unsigned long count)
 {
 	if (!mem_cgroup_disabled())
 		this_cpu_add(memcg->stat->events[idx], count);
 }
 
-/* idx can be of type enum memcg_stat_item or node_stat_item */
+/* idx can be of type enum memcg_event_item or vm_event_item */
 static inline void count_memcg_page_event(struct page *page,
 					  int idx)
 {
@@ -654,12 +655,20 @@ static inline void count_memcg_event_mm(
 	rcu_read_lock();
 	memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
 	if (likely(memcg)) {
-		this_cpu_inc(memcg->stat->events[idx]);
+		count_memcg_events(memcg, idx, 1);
 		if (idx == OOM_KILL)
 			cgroup_file_notify(&memcg->events_file);
 	}
 	rcu_read_unlock();
 }
+
+static inline void mem_cgroup_event(struct mem_cgroup *memcg,
+				    enum memcg_event_item event)
+{
+	count_memcg_events(memcg, event, 1);
+	cgroup_file_notify(&memcg->events_file);
+}
+
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 void mem_cgroup_split_huge_fixup(struct page *head);
 #endif
diff -puN mm/memcontrol.c~mm-memcontrol-eliminate-raw-access-to-stat-and-event-counters mm/memcontrol.c
--- a/mm/memcontrol.c~mm-memcontrol-eliminate-raw-access-to-stat-and-event-counters
+++ a/mm/memcontrol.c
@@ -586,23 +586,23 @@ static void mem_cgroup_charge_statistics
 	 * counted as CACHE even if it's on ANON LRU.
 	 */
 	if (PageAnon(page))
-		__this_cpu_add(memcg->stat->count[MEMCG_RSS], nr_pages);
+		__mod_memcg_state(memcg, MEMCG_RSS, nr_pages);
 	else {
-		__this_cpu_add(memcg->stat->count[MEMCG_CACHE], nr_pages);
+		__mod_memcg_state(memcg, MEMCG_CACHE, nr_pages);
 		if (PageSwapBacked(page))
-			__this_cpu_add(memcg->stat->count[NR_SHMEM], nr_pages);
+			__mod_memcg_state(memcg, NR_SHMEM, nr_pages);
 	}
 
 	if (compound) {
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
-		__this_cpu_add(memcg->stat->count[MEMCG_RSS_HUGE], nr_pages);
+		__mod_memcg_state(memcg, MEMCG_RSS_HUGE, nr_pages);
 	}
 
 	/* pagein of a big page is an event. So, ignore page size */
 	if (nr_pages > 0)
-		__this_cpu_inc(memcg->stat->events[PGPGIN]);
+		__count_memcg_events(memcg, PGPGIN, 1);
 	else {
-		__this_cpu_inc(memcg->stat->events[PGPGOUT]);
+		__count_memcg_events(memcg, PGPGOUT, 1);
 		nr_pages = -nr_pages; /* for event */
 	}
 
@@ -2415,18 +2415,11 @@ void mem_cgroup_split_huge_fixup(struct
 	for (i = 1; i < HPAGE_PMD_NR; i++)
 		head[i].mem_cgroup = head->mem_cgroup;
 
-	__this_cpu_sub(head->mem_cgroup->stat->count[MEMCG_RSS_HUGE],
-		       HPAGE_PMD_NR);
+	__mod_memcg_state(head->mem_cgroup, MEMCG_RSS_HUGE, -HPAGE_PMD_NR);
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #ifdef CONFIG_MEMCG_SWAP
-static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
-				       int nr_entries)
-{
-	this_cpu_add(memcg->stat->count[MEMCG_SWAP], nr_entries);
-}
-
 /**
  * mem_cgroup_move_swap_account - move swap charge and swap_cgroup's record.
  * @entry: swap entry to be moved
@@ -2450,8 +2443,8 @@ static int mem_cgroup_move_swap_account(
 	new_id = mem_cgroup_id(to);
 
 	if (swap_cgroup_cmpxchg(entry, old_id, new_id) == old_id) {
-		mem_cgroup_swap_statistics(from, -1);
-		mem_cgroup_swap_statistics(to, 1);
+		mod_memcg_state(from, MEMCG_SWAP, -1);
+		mod_memcg_state(to, MEMCG_SWAP, 1);
 		return 0;
 	}
 	return -EINVAL;
@@ -4584,8 +4577,8 @@ static int mem_cgroup_move_account(struc
 	spin_lock_irqsave(&from->move_lock, flags);
 
 	if (!anon && page_mapped(page)) {
-		__this_cpu_sub(from->stat->count[NR_FILE_MAPPED], nr_pages);
-		__this_cpu_add(to->stat->count[NR_FILE_MAPPED], nr_pages);
+		__mod_memcg_state(from, NR_FILE_MAPPED, -nr_pages);
+		__mod_memcg_state(to, NR_FILE_MAPPED, nr_pages);
 	}
 
 	/*
@@ -4597,16 +4590,14 @@ static int mem_cgroup_move_account(struc
 		struct address_space *mapping = page_mapping(page);
 
 		if (mapping_cap_account_dirty(mapping)) {
-			__this_cpu_sub(from->stat->count[NR_FILE_DIRTY],
-				       nr_pages);
-			__this_cpu_add(to->stat->count[NR_FILE_DIRTY],
-				       nr_pages);
+			__mod_memcg_state(from, NR_FILE_DIRTY, -nr_pages);
+			__mod_memcg_state(to, NR_FILE_DIRTY, nr_pages);
 		}
 	}
 
 	if (PageWriteback(page)) {
-		__this_cpu_sub(from->stat->count[NR_WRITEBACK], nr_pages);
-		__this_cpu_add(to->stat->count[NR_WRITEBACK], nr_pages);
+		__mod_memcg_state(from, NR_WRITEBACK, -nr_pages);
+		__mod_memcg_state(to, NR_WRITEBACK, nr_pages);
 	}
 
 	/*
@@ -5642,11 +5633,11 @@ static void uncharge_batch(const struct
 	}
 
 	local_irq_save(flags);
-	__this_cpu_sub(ug->memcg->stat->count[MEMCG_RSS], ug->nr_anon);
-	__this_cpu_sub(ug->memcg->stat->count[MEMCG_CACHE], ug->nr_file);
-	__this_cpu_sub(ug->memcg->stat->count[MEMCG_RSS_HUGE], ug->nr_huge);
-	__this_cpu_sub(ug->memcg->stat->count[NR_SHMEM], ug->nr_shmem);
-	__this_cpu_add(ug->memcg->stat->events[PGPGOUT], ug->pgpgout);
+	__mod_memcg_state(ug->memcg, MEMCG_RSS, -ug->nr_anon);
+	__mod_memcg_state(ug->memcg, MEMCG_CACHE, -ug->nr_file);
+	__mod_memcg_state(ug->memcg, MEMCG_RSS_HUGE, -ug->nr_huge);
+	__mod_memcg_state(ug->memcg, NR_SHMEM, -ug->nr_shmem);
+	__count_memcg_events(ug->memcg, PGPGOUT, ug->pgpgout);
 	__this_cpu_add(ug->memcg->stat->nr_page_events, nr_pages);
 	memcg_check_events(ug->memcg, ug->dummy_page);
 	local_irq_restore(flags);
@@ -5874,7 +5865,7 @@ bool mem_cgroup_charge_skmem(struct mem_
 	if (in_softirq())
 		gfp_mask = GFP_NOWAIT;
 
-	this_cpu_add(memcg->stat->count[MEMCG_SOCK], nr_pages);
+	mod_memcg_state(memcg, MEMCG_SOCK, nr_pages);
 
 	if (try_charge(memcg, gfp_mask, nr_pages) == 0)
 		return true;
@@ -5895,7 +5886,7 @@ void mem_cgroup_uncharge_skmem(struct me
 		return;
 	}
 
-	this_cpu_sub(memcg->stat->count[MEMCG_SOCK], nr_pages);
+	mod_memcg_state(memcg, MEMCG_SOCK, -nr_pages);
 
 	refill_stock(memcg, nr_pages);
 }
@@ -6019,7 +6010,7 @@ void mem_cgroup_swapout(struct page *pag
 	oldid = swap_cgroup_record(entry, mem_cgroup_id(swap_memcg),
 				   nr_entries);
 	VM_BUG_ON_PAGE(oldid, page);
-	mem_cgroup_swap_statistics(swap_memcg, nr_entries);
+	mod_memcg_state(swap_memcg, MEMCG_SWAP, nr_entries);
 
 	page->mem_cgroup = NULL;
 
@@ -6085,7 +6076,7 @@ int mem_cgroup_try_charge_swap(struct pa
 		mem_cgroup_id_get_many(memcg, nr_pages - 1);
 	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg), nr_pages);
 	VM_BUG_ON_PAGE(oldid, page);
-	mem_cgroup_swap_statistics(memcg, nr_pages);
+	mod_memcg_state(memcg, MEMCG_SWAP, nr_pages);
 
 	return 0;
 }
@@ -6113,7 +6104,7 @@ void mem_cgroup_uncharge_swap(swp_entry_
 			else
 				page_counter_uncharge(&memcg->memsw, nr_pages);
 		}
-		mem_cgroup_swap_statistics(memcg, -nr_pages);
+		mod_memcg_state(memcg, MEMCG_SWAP, -nr_pages);
 		mem_cgroup_id_put_many(memcg, nr_pages);
 	}
 	rcu_read_unlock();
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
