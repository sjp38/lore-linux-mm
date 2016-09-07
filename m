Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 81CC06B0069
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 19:53:37 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id hi6so65957982pac.0
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 16:53:37 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id y6si41974292pfy.74.2016.09.07.09.47.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Sep 2016 09:47:04 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -v3 03/10] mm, memcg: Support to charge/uncharge multiple swap entries
Date: Wed,  7 Sep 2016 09:46:02 -0700
Message-Id: <1473266769-2155-4-git-send-email-ying.huang@intel.com>
In-Reply-To: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
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
whole.  So a set of continuous swap entries (512 on x86_64) backing one
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
 mm/swap_cgroup.c            | 17 ++++++++++----
 mm/swap_state.c             |  2 +-
 mm/swapfile.c               |  2 +-
 7 files changed, 59 insertions(+), 37 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index ed41bec..75aad24 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -550,8 +550,10 @@ static inline int mem_cgroup_swappiness(struct mem_cgroup *mem)
 
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
@@ -560,12 +562,14 @@ static inline void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
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
index bdb796f..9662fcf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2370,10 +2370,9 @@ void mem_cgroup_split_huge_fixup(struct page *head)
 
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
@@ -2399,8 +2398,8 @@ static int mem_cgroup_move_swap_account(swp_entry_t entry,
 	new_id = mem_cgroup_id(to);
 
 	if (swap_cgroup_cmpxchg(entry, old_id, new_id) == old_id) {
-		mem_cgroup_swap_statistics(from, false);
-		mem_cgroup_swap_statistics(to, true);
+		mem_cgroup_swap_statistics(from, -1);
+		mem_cgroup_swap_statistics(to, 1);
 		return 0;
 	}
 	return -EINVAL;
@@ -5417,7 +5416,7 @@ void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
 		 * let's not wait for it.  The page already received a
 		 * memory+swap charge, drop the swap entry duplicate.
 		 */
-		mem_cgroup_uncharge_swap(entry);
+		mem_cgroup_uncharge_swap(entry, nr_pages);
 	}
 }
 
@@ -5825,9 +5824,9 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	 * ancestor for the swap instead and transfer the memory+swap charge.
 	 */
 	swap_memcg = mem_cgroup_id_get_online(memcg);
-	oldid = swap_cgroup_record(entry, mem_cgroup_id(swap_memcg));
+	oldid = swap_cgroup_record(entry, mem_cgroup_id(swap_memcg), 1);
 	VM_BUG_ON_PAGE(oldid, page);
-	mem_cgroup_swap_statistics(swap_memcg, true);
+	mem_cgroup_swap_statistics(swap_memcg, 1);
 
 	page->mem_cgroup = NULL;
 
@@ -5854,16 +5853,19 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
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
@@ -5881,25 +5883,29 @@ int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry)
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
@@ -5907,17 +5913,18 @@ void mem_cgroup_uncharge_swap(swp_entry_t entry)
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
index ac35ebd..baeb2f9 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1248,7 +1248,7 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 	if (!swap.val)
 		goto redirty;
 
-	if (mem_cgroup_try_charge_swap(page, swap))
+	if (mem_cgroup_try_charge_swap(page, swap, 1))
 		goto free_swap;
 
 	/*
diff --git a/mm/swap_cgroup.c b/mm/swap_cgroup.c
index 4ae3e7b..4d3484f 100644
--- a/mm/swap_cgroup.c
+++ b/mm/swap_cgroup.c
@@ -139,14 +139,16 @@ unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
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
 	struct swap_cgroup_iter iter;
 	unsigned short old;
@@ -154,7 +156,14 @@ unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
 	swap_cgroup_iter_init(&iter, ent);
 
 	old = iter.sc->id;
-	iter.sc->id = id;
+	for (;;) {
+		VM_BUG_ON(iter.sc->id != old);
+		iter.sc->id = id;
+		nr_ents--;
+		if (!nr_ents)
+			break;
+		swap_cgroup_iter_advance(&iter);
+	}
 
 	swap_cgroup_iter_exit(&iter);
 	return old;
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 8679c99..c335251 100644
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
index 4b78402..17f25e2 100644
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
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
