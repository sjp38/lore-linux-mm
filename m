Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9006B000C
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 09:27:54 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id l9so3715037qtp.23
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 06:27:54 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id u190si1338669qka.45.2018.04.12.06.27.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Apr 2018 06:27:52 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH] mm: allow to decrease swap.max below actual swap usage
Date: Thu, 12 Apr 2018 14:27:05 +0100
Message-ID: <20180412132705.30316-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Shaohua Li <shli@fb.com>, Rik van Riel <riel@surriel.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Currently an attempt to set swap.max into a value lower
than the actual swap usage fails. And a user can't do much
with it, except turning off swap globally (using swapoff).

This is an actual problem we met in the production.
The default value for swap.max is "max", so turning swap on
globally may lead to swapping out in some cgroups.
As it's not possible to lower the allowed maximum,
it creates additional configuration issues.

For example, to disable swapping for a particular cgroup
it has to be re-created with memory.max set to 0.

This patch aims to fix this issue by allowing setting swap.max
into any value (which corresponds to cgroup v2 API design),
and schedule a background job to fit swap size into the new limit.

The following script can be used to test the memory.swap behavior:
  #!/bin/bash

  mkdir -p /sys/fs/cgroup/test_swap
  echo 100M > /sys/fs/cgroup/test_swap/memory.max
  echo max > /sys/fs/cgroup/test_swap/memory.swap.max

  mkdir -p /sys/fs/cgroup/test_swap_2
  echo 100M > /sys/fs/cgroup/test_swap_2/memory.max
  echo max > /sys/fs/cgroup/test_swap_2/memory.swap.max

  echo $$ > /sys/fs/cgroup/test_swap/cgroup.procs
  allocate 200M &

  echo $$ > /sys/fs/cgroup/test_swap_2/cgroup.procs
  allocate 200M &

  sleep 2

  cat /sys/fs/cgroup/test_swap/memory.swap.current
  cat /sys/fs/cgroup/test_swap_2/memory.swap.current

  echo max > /sys/fs/cgroup/test_swap/memory.max
  echo 50M > /sys/fs/cgroup/test_swap/memory.swap.max

  sleep 10

  cat /sys/fs/cgroup/test_swap/memory.swap.current
  cat /sys/fs/cgroup/test_swap_2/memory.swap.current

  pkill allocate

Original test results:
  106024960
  106348544
  ./swap.sh: line 23: echo: write error: Device or resource busy
  106024960
  106348544

With this patch applied:
  106045440
  106352640
  52428800
  106201088

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Shaohua Li <shli@fb.com>
Cc: Rik van Riel <riel@surriel.com>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org
---
 include/linux/memcontrol.h |  1 +
 include/linux/swap.h       |  9 +++++++
 include/linux/swapfile.h   |  3 ++-
 mm/frontswap.c             |  2 +-
 mm/memcontrol.c            | 27 +++++++++++++++----
 mm/swapfile.c              | 64 ++++++++++++++++++++++++++++++++++++++++++----
 6 files changed, 94 insertions(+), 12 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index af9eed2e3e04..a0825cc61ee7 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -186,6 +186,7 @@ struct mem_cgroup {
 
 	/* Range enforcement for interrupt charges */
 	struct work_struct high_work;
+	struct work_struct swap_work;
 
 	unsigned long soft_limit;
 
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 1985940af479..878f111d0603 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -650,6 +650,8 @@ extern int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry);
 extern void mem_cgroup_uncharge_swap(swp_entry_t entry, unsigned int nr_pages);
 extern long mem_cgroup_get_nr_swap_pages(struct mem_cgroup *memcg);
 extern bool mem_cgroup_swap_full(struct page *page);
+extern int mem_cgroup_shrink_swap(struct mem_cgroup *memcg,
+				  unsigned long nr_pages);
 #else
 static inline void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 {
@@ -675,6 +677,13 @@ static inline bool mem_cgroup_swap_full(struct page *page)
 {
 	return vm_swap_full();
 }
+
+static inline int mem_cgroup_shrink_swap(struct mem_cgroup *memcg,
+					 unsigned long nr_pages)
+{
+	return 0;
+}
+
 #endif
 
 #endif /* __KERNEL__*/
diff --git a/include/linux/swapfile.h b/include/linux/swapfile.h
index 06bd7b096167..16844259e802 100644
--- a/include/linux/swapfile.h
+++ b/include/linux/swapfile.h
@@ -9,6 +9,7 @@
 extern spinlock_t swap_lock;
 extern struct plist_head swap_active_head;
 extern struct swap_info_struct *swap_info[];
-extern int try_to_unuse(unsigned int, bool, unsigned long);
+extern int try_to_unuse(unsigned int type, bool fronstswap,
+			unsigned long pages_to_unuse, struct mem_cgroup *memcg);
 
 #endif /* _LINUX_SWAPFILE_H */
diff --git a/mm/frontswap.c b/mm/frontswap.c
index fec8b5044040..f7cb2e802fce 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -458,7 +458,7 @@ void frontswap_shrink(unsigned long target_pages)
 	ret = __frontswap_shrink(target_pages, &pages_to_unuse, &type);
 	spin_unlock(&swap_lock);
 	if (ret == 0)
-		try_to_unuse(type, true, pages_to_unuse);
+		try_to_unuse(type, true, pages_to_unuse, NULL);
 	return;
 }
 EXPORT_SYMBOL(frontswap_shrink);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3e7942c301a8..bacb1fd17100 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -60,6 +60,7 @@
 #include <linux/vmpressure.h>
 #include <linux/mm_inline.h>
 #include <linux/swap_cgroup.h>
+#include <linux/swapfile.h>
 #include <linux/cpu.h>
 #include <linux/oom.h>
 #include <linux/lockdep.h>
@@ -1870,6 +1871,23 @@ static void high_work_func(struct work_struct *work)
 	reclaim_high(memcg, MEMCG_CHARGE_BATCH, GFP_KERNEL);
 }
 
+static void swap_work_func(struct work_struct *work)
+{
+	struct mem_cgroup *memcg;
+
+	memcg = container_of(work, struct mem_cgroup, swap_work);
+
+	for (;;) {
+		unsigned long usage = page_counter_read(&memcg->swap);
+
+		if (usage <= memcg->swap.limit)
+			break;
+
+		if (mem_cgroup_shrink_swap(memcg, usage - memcg->swap.limit))
+			break;
+	}
+}
+
 /*
  * Scheduled by try_charge() to be executed from the userland return path
  * and reclaims memory over the high limit.
@@ -4394,6 +4412,7 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 		goto fail;
 
 	INIT_WORK(&memcg->high_work, high_work_func);
+	INIT_WORK(&memcg->swap_work, swap_work_func);
 	memcg->last_scanned_node = MAX_NUMNODES;
 	INIT_LIST_HEAD(&memcg->oom_notify);
 	mutex_init(&memcg->thresholds_lock);
@@ -4529,6 +4548,7 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 
 	vmpressure_cleanup(&memcg->vmpressure);
 	cancel_work_sync(&memcg->high_work);
+	cancel_work_sync(&memcg->swap_work);
 	mem_cgroup_remove_from_trees(memcg);
 	memcg_free_kmem(memcg);
 	mem_cgroup_free(memcg);
@@ -6415,11 +6435,8 @@ static ssize_t swap_max_write(struct kernfs_open_file *of,
 	if (err)
 		return err;
 
-	mutex_lock(&memcg_limit_mutex);
-	err = page_counter_limit(&memcg->swap, max);
-	mutex_unlock(&memcg_limit_mutex);
-	if (err)
-		return err;
+	xchg(&memcg->swap.limit, max);
+	schedule_work(&memcg->swap_work);
 
 	return nbytes;
 }
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 5a280972bd87..45ef9858645b 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2093,11 +2093,11 @@ static unsigned int find_next_to_unuse(struct swap_info_struct *si,
  * and then search for the process using it.  All the necessary
  * page table adjustments can then be made atomically.
  *
- * if the boolean frontswap is true, only unuse pages_to_unuse pages;
- * pages_to_unuse==0 means all pages; ignored if frontswap is false
+ * Only unuse pages_to_unuse pages; pages_to_unuse==0 means all pages.
  */
 int try_to_unuse(unsigned int type, bool frontswap,
-		 unsigned long pages_to_unuse)
+		 unsigned long pages_to_unuse,
+		 struct mem_cgroup *memcg)
 {
 	struct swap_info_struct *si = swap_info[type];
 	struct mm_struct *start_mm;
@@ -2192,6 +2192,17 @@ int try_to_unuse(unsigned int type, bool frontswap,
 		lock_page(page);
 		wait_on_page_writeback(page);
 
+		if (memcg && do_swap_account) {
+			swp_entry_t ent = { .val = page_private(page), };
+			unsigned short id = lookup_swap_cgroup_id(ent);
+
+			if (memcg != mem_cgroup_from_id(id)) {
+				unlock_page(page);
+				put_page(page);
+				continue;
+			}
+		}
+
 		/*
 		 * Remove all references to entry.
 		 */
@@ -2310,7 +2321,7 @@ int try_to_unuse(unsigned int type, bool frontswap,
 		 * interactive performance.
 		 */
 		cond_resched();
-		if (frontswap && pages_to_unuse > 0) {
+		if (pages_to_unuse > 0) {
 			if (!--pages_to_unuse)
 				break;
 		}
@@ -2618,6 +2629,49 @@ bool has_usable_swap(void)
 	return ret;
 }
 
+int mem_cgroup_shrink_swap(struct mem_cgroup *memcg, unsigned long nr_pages)
+{
+	struct swap_info_struct *p = NULL;
+	unsigned long to_shrink;
+	int err;
+
+	spin_lock(&swap_lock);
+	plist_for_each_entry(p, &swap_active_head, list) {
+		if (!(p->flags & SWP_WRITEOK))
+			continue;
+
+		to_shrink = min(512UL, nr_pages);
+
+		del_from_avail_list(p);
+		spin_lock(&p->lock);
+		plist_del(&p->list, &swap_active_head);
+		p->flags &= ~SWP_WRITEOK;
+		spin_unlock(&p->lock);
+		spin_unlock(&swap_lock);
+
+		disable_swap_slots_cache_lock();
+
+		set_current_oom_origin();
+		err = try_to_unuse(p->type, false, to_shrink, memcg);
+		clear_current_oom_origin();
+
+		reinsert_swap_info(p);
+		reenable_swap_slots_cache_unlock();
+
+		if (err)
+			return err;
+
+		nr_pages -= to_shrink;
+		if (!nr_pages)
+			return err;
+
+		spin_lock(&swap_lock);
+	}
+	spin_unlock(&swap_lock);
+
+	return 0;
+}
+
 SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 {
 	struct swap_info_struct *p = NULL;
@@ -2693,7 +2747,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	disable_swap_slots_cache_lock();
 
 	set_current_oom_origin();
-	err = try_to_unuse(p->type, false, 0); /* force unuse all pages */
+	err = try_to_unuse(p->type, false, 0, NULL); /* force unuse all pages */
 	clear_current_oom_origin();
 
 	if (err) {
-- 
2.14.3
