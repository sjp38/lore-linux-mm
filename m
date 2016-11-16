Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1D8906B0316
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 22:12:26 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 3so130129687pgd.3
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 19:12:26 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 23si29455179pgb.38.2016.11.15.19.12.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 19:12:25 -0800 (PST)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -v5 2/9] mm, memcg: Support to charge/uncharge multiple swap entries
Date: Wed, 16 Nov 2016 11:10:50 +0800
Message-Id: <20161116031057.12977-3-ying.huang@intel.com>
In-Reply-To: <20161116031057.12977-1-ying.huang@intel.com>
References: <20161116031057.12977-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org

From: Huang Ying <ying.huang@intel.com>

This patch make it possible to charge or uncharge a set of continuous
swap entries in the swap cgroup.  The number of swap entries is
specified via an added parameter.

This will be used for the THP (Transparent Huge Page) swap support.
Where a swap cluster backing a THP may be allocated and freed as a
whole.  So a set of (HPAGE_PMD_NR) continuous swap entries backing one
THP need to be charged or uncharged together.  This will batch the
cgroup operations for the THP swap too.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: cgroups@vger.kernel.org
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/swap.h        | 12 ++++++----
 include/linux/swap_cgroup.h |  6 +++--
 mm/memcontrol.c             | 55 +++++++++++++++++++++++++--------------------
 mm/shmem.c                  |  2 +-
 mm/swap_cgroup.c            | 40 ++++++++++++++++++++++++---------
 mm/swap_state.c             |  2 +-
 mm/swapfile.c               |  2 +-
 7 files changed, 76 insertions(+), 43 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index bfee1af..35484c9 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -555,8 +555,10 @@ static inline int mem_cgroup_swappiness(struct mem_cgroup *mem)
 
 #ifdef CONFIG_MEMCG_SWAP
 extern void mem_cgroup_swapout(struct page *page, swp_entry_t entry);
-extern int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry);
-extern void mem_cgroup_uncharge_swap(swp_entry_t entry);
+extern int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry,
+				      unsigned int nr_entries);
+extern void mem_cgroup_uncharge_swap(swp_entry_t entry,
+				     unsigned int nr_entries);
 extern long mem_cgroup_get_nr_swap_pages(struct mem_cgroup *memcg);
 extern bool mem_cgroup_swap_full(struct page *page);
 #else
@@ -565,12 +567,14 @@ static inline void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 }
 
 static inline int mem_cgroup_try_charge_swap(struct page *page,
-					     swp_entry_t entry)
+					     swp_entry_t entry,
+					     unsigned int nr_entries)
 {
 	return 0;
 }
 
-static inline void mem_cgroup_uncharge_swap(swp_entry_t entry)
+static inline void mem_cgroup_uncharge_swap(swp_entry_t entry,
+					    unsigned int nr_entries)
 {
 }
 
diff --git a/include/linux/swap_cgroup.h b/include/linux/swap_cgroup.h
index 145306b..b2b8ec7 100644
--- a/include/linux/swap_cgroup.h
+++ b/include/linux/swap_cgroup.h
@@ -7,7 +7,8 @@
 
 extern unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
 					unsigned short old, unsigned short new);
-extern unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id);
+extern unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id,
+					 unsigned int nr_ents);
 extern unsigned short lookup_swap_cgroup_id(swp_entry_t ent);
 extern int swap_cgroup_swapon(int type, unsigned long max_pages);
 extern void swap_cgroup_swapoff(int type);
@@ -15,7 +16,8 @@ extern void swap_cgroup_swapoff(int type);
 #else
 
 static inline
-unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
+unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id,
+				  unsigned int nr_ents)
 {
 	return 0;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 91dfc7c..a025dce 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2394,10 +2394,9 @@ void mem_cgroup_split_huge_fixup(struct page *head)
 
 #ifdef CONFIG_MEMCG_SWAP
 static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
-					 bool charge)
+				       int nr_entries)
 {
-	int val = (charge) ? 1 : -1;
-	this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_SWAP], val);
+	this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_SWAP], nr_entries);
 }
 
 /**
@@ -2423,8 +2422,8 @@ static int mem_cgroup_move_swap_account(swp_entry_t entry,
 	new_id = mem_cgroup_id(to);
 
 	if (swap_cgroup_cmpxchg(entry, old_id, new_id) == old_id) {
-		mem_cgroup_swap_statistics(from, false);
-		mem_cgroup_swap_statistics(to, true);
+		mem_cgroup_swap_statistics(from, -1);
+		mem_cgroup_swap_statistics(to, 1);
 		return 0;
 	}
 	return -EINVAL;
@@ -5444,7 +5443,7 @@ void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
 		 * let's not wait for it.  The page already received a
 		 * memory+swap charge, drop the swap entry duplicate.
 		 */
-		mem_cgroup_uncharge_swap(entry);
+		mem_cgroup_uncharge_swap(entry, nr_pages);
 	}
 }
 
@@ -5866,9 +5865,9 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	 * ancestor for the swap instead and transfer the memory+swap charge.
 	 */
 	swap_memcg = mem_cgroup_id_get_online(memcg);
-	oldid = swap_cgroup_record(entry, mem_cgroup_id(swap_memcg));
+	oldid = swap_cgroup_record(entry, mem_cgroup_id(swap_memcg), 1);
 	VM_BUG_ON_PAGE(oldid, page);
-	mem_cgroup_swap_statistics(swap_memcg, true);
+	mem_cgroup_swap_statistics(swap_memcg, 1);
 
 	page->mem_cgroup = NULL;
 
@@ -5895,16 +5894,19 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 		css_put(&memcg->css);
 }
 
-/*
- * mem_cgroup_try_charge_swap - try charging a swap entry
+/**
+ * mem_cgroup_try_charge_swap - try charging a set of swap entries
  * @page: page being added to swap
- * @entry: swap entry to charge
+ * @entry: the first swap entry to charge
+ * @nr_entries: the number of swap entries to charge
  *
- * Try to charge @entry to the memcg that @page belongs to.
+ * Try to charge @nr_entries swap entries starting from @entry to the
+ * memcg that @page belongs to.
  *
  * Returns 0 on success, -ENOMEM on failure.
  */
-int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry)
+int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry,
+			       unsigned int nr_entries)
 {
 	struct mem_cgroup *memcg;
 	struct page_counter *counter;
@@ -5922,25 +5924,29 @@ int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry)
 	memcg = mem_cgroup_id_get_online(memcg);
 
 	if (!mem_cgroup_is_root(memcg) &&
-	    !page_counter_try_charge(&memcg->swap, 1, &counter)) {
+	    !page_counter_try_charge(&memcg->swap, nr_entries, &counter)) {
 		mem_cgroup_id_put(memcg);
 		return -ENOMEM;
 	}
 
-	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg));
+	if (nr_entries > 1)
+		mem_cgroup_id_get_many(memcg, nr_entries - 1);
+	oldid = swap_cgroup_record(entry, mem_cgroup_id(memcg), nr_entries);
 	VM_BUG_ON_PAGE(oldid, page);
-	mem_cgroup_swap_statistics(memcg, true);
+	mem_cgroup_swap_statistics(memcg, nr_entries);
 
 	return 0;
 }
 
 /**
- * mem_cgroup_uncharge_swap - uncharge a swap entry
- * @entry: swap entry to uncharge
+ * mem_cgroup_uncharge_swap - uncharge a set of swap entries
+ * @entry: the first swap entry to uncharge
+ * @nr_entries: the number of swap entries to uncharge
  *
- * Drop the swap charge associated with @entry.
+ * Drop the swap charge associated with @nr_entries swap entries
+ * starting from @entry.
  */
-void mem_cgroup_uncharge_swap(swp_entry_t entry)
+void mem_cgroup_uncharge_swap(swp_entry_t entry, unsigned int nr_entries)
 {
 	struct mem_cgroup *memcg;
 	unsigned short id;
@@ -5948,17 +5954,18 @@ void mem_cgroup_uncharge_swap(swp_entry_t entry)
 	if (!do_swap_account)
 		return;
 
-	id = swap_cgroup_record(entry, 0);
+	id = swap_cgroup_record(entry, 0, nr_entries);
 	rcu_read_lock();
 	memcg = mem_cgroup_from_id(id);
 	if (memcg) {
 		if (!mem_cgroup_is_root(memcg)) {
 			if (cgroup_subsys_on_dfl(memory_cgrp_subsys))
-				page_counter_uncharge(&memcg->swap, 1);
+				page_counter_uncharge(&memcg->swap, nr_entries);
 			else
-				page_counter_uncharge(&memcg->memsw, 1);
+				page_counter_uncharge(&memcg->memsw,
+						      nr_entries);
 		}
-		mem_cgroup_swap_statistics(memcg, false);
+		mem_cgroup_swap_statistics(memcg, -nr_entries);
 		mem_cgroup_id_put(memcg);
 	}
 	rcu_read_unlock();
diff --git a/mm/shmem.c b/mm/shmem.c
index 2c74186..83ee18f 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1249,7 +1249,7 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 	if (!swap.val)
 		goto redirty;
 
-	if (mem_cgroup_try_charge_swap(page, swap))
+	if (mem_cgroup_try_charge_swap(page, swap, 1))
 		goto free_swap;
 
 	/*
diff --git a/mm/swap_cgroup.c b/mm/swap_cgroup.c
index 310ac0b..8cee2d1 100644
--- a/mm/swap_cgroup.c
+++ b/mm/swap_cgroup.c
@@ -58,21 +58,27 @@ static int swap_cgroup_prepare(int type)
 	return -ENOMEM;
 }
 
+static struct swap_cgroup *__lookup_swap_cgroup(struct swap_cgroup_ctrl *ctrl,
+						pgoff_t offset)
+{
+	struct page *mappage;
+	struct swap_cgroup *sc;
+
+	mappage = ctrl->map[offset / SC_PER_PAGE];
+	sc = page_address(mappage);
+	return sc + offset % SC_PER_PAGE;
+}
+
 static struct swap_cgroup *lookup_swap_cgroup(swp_entry_t ent,
 					struct swap_cgroup_ctrl **ctrlp)
 {
 	pgoff_t offset = swp_offset(ent);
 	struct swap_cgroup_ctrl *ctrl;
-	struct page *mappage;
-	struct swap_cgroup *sc;
 
 	ctrl = &swap_cgroup_ctrl[swp_type(ent)];
 	if (ctrlp)
 		*ctrlp = ctrl;
-
-	mappage = ctrl->map[offset / SC_PER_PAGE];
-	sc = page_address(mappage);
-	return sc + offset % SC_PER_PAGE;
+	return __lookup_swap_cgroup(ctrl, offset);
 }
 
 /**
@@ -105,25 +111,39 @@ unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
 }
 
 /**
- * swap_cgroup_record - record mem_cgroup for this swp_entry.
- * @ent: swap entry to be recorded into
+ * swap_cgroup_record - record mem_cgroup for a set of swap entries
+ * @ent: the first swap entry to be recorded into
  * @id: mem_cgroup to be recorded
+ * @nr_ents: number of swap entries to be recorded
  *
  * Returns old value at success, 0 at failure.
  * (Of course, old value can be 0.)
  */
-unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
+unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id,
+				  unsigned int nr_ents)
 {
 	struct swap_cgroup_ctrl *ctrl;
 	struct swap_cgroup *sc;
 	unsigned short old;
 	unsigned long flags;
+	pgoff_t offset = swp_offset(ent);
+	pgoff_t end = offset + nr_ents;
 
 	sc = lookup_swap_cgroup(ent, &ctrl);
 
 	spin_lock_irqsave(&ctrl->lock, flags);
 	old = sc->id;
-	sc->id = id;
+	for (;;) {
+		VM_BUG_ON(sc->id != old);
+		sc->id = id;
+		offset++;
+		if (offset == end)
+			break;
+		if (offset % SC_PER_PAGE)
+			sc++;
+		else
+			sc = __lookup_swap_cgroup(ctrl, offset);
+	}
 	spin_unlock_irqrestore(&ctrl->lock, flags);
 
 	return old;
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 35d7e0e..d3f047b 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -172,7 +172,7 @@ int add_to_swap(struct page *page, struct list_head *list)
 	if (!entry.val)
 		return 0;
 
-	if (mem_cgroup_try_charge_swap(page, entry)) {
+	if (mem_cgroup_try_charge_swap(page, entry, 1)) {
 		swapcache_free(entry);
 		return 0;
 	}
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 34888e5b..fe0a559 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -806,7 +806,7 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 
 	/* free if no reference */
 	if (!usage) {
-		mem_cgroup_uncharge_swap(entry);
+		mem_cgroup_uncharge_swap(entry, 1);
 		dec_cluster_info_page(p, p->cluster_info, offset);
 		if (offset < p->lowest_bit)
 			p->lowest_bit = offset;
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
