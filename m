Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 2252F6B000D
	for <linux-mm@kvack.org>; Sat, 26 Jan 2013 06:15:28 -0500 (EST)
Received: by mail-da0-f44.google.com with SMTP id z20so547733dae.31
        for <linux-mm@kvack.org>; Sat, 26 Jan 2013 03:15:27 -0800 (PST)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH] memcg: simplify lock of memcg page stat accounting
Date: Sat, 26 Jan 2013 19:12:36 +0800
Message-Id: <1359198756-3752-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, gthelen@google.com, hannes@cmpxchg.org, hughd@google.com, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

After removing duplicated information like PCG_*
flags in 'struct page_cgroup'(commit 2ff76f1193), there's a problem
between "move" and "page stat accounting"(only FILE_MAPPED is supported
now but other stats will be added in future):
assume CPU-A does "page stat accounting" and CPU-B does "move"

CPU-A                        CPU-B
TestSet PG_dirty
(delay)              	move_lock_mem_cgroup()
                        if (PageDirty(page)) {
                             old_memcg->nr_dirty --
                             new_memcg->nr_dirty++
                        }
                        pc->mem_cgroup = new_memcg;
                        move_unlock_mem_cgroup()

move_lock_mem_cgroup()
memcg = pc->mem_cgroup
memcg->nr_dirty++
move_unlock_mem_cgroup()

while accounting information of new_memcg may be double-counted. So we
use a bigger lock to solve this problem:  (commit: 89c06bd52f)

      move_lock_mem_cgroup() <-- mem_cgroup_begin_update_page_stat()
      TestSetPageDirty(page)
      update page stats (without any checks)
      move_unlock_mem_cgroup() <-- mem_cgroup_begin_update_page_stat()


But this method also has its pros and cons: at present we use two layers
of lock avoidance(memcg_moving and memcg->moving_account) then spinlock
on memcg (see mem_cgroup_begin_update_page_stat()), but the lock granularity
is a little bigger that not only the critical section but also some code
logic is in the range of locking which may be deadlock prone. As dirty
writeack stats are added, it gets into further difficulty with the page
cache radix tree lock and it seems that the lock requires nesting.
(https://lkml.org/lkml/2013/1/2/48)

So in order to make the lock simpler and clearer and also avoid the 'nesting'
problem, a choice may be:
(CPU-A does "page stat accounting" and CPU-B does "move")

       CPU-A                        CPU-B

move_lock_mem_cgroup()
memcg = pc->mem_cgroup
TestSetPageDirty(page)
move_unlock_mem_cgroup()
                             move_lock_mem_cgroup()
                             if (PageDirty) {
                                  old_memcg->nr_dirty --;
                                  new_memcg->nr_dirty ++;
                             }
                             pc->mem_cgroup = new_memcg
                             move_unlock_mem_cgroup()

memcg->nr_dirty ++


For CPU-A, we save pc->mem_cgroup in a temporary variable just before
TestSetPageDirty inside move_lock and then update stats if the page is set
PG_dirty successfully. But CPU-B may do "moving" in advance that
"old_memcg->nr_dirty --" will make old_memcg->nr_dirty incorrect but
soon CPU-A will do "memcg->nr_dirty ++" finally that amend the stats.

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
---
 include/linux/memcontrol.h |   14 +++++------
 mm/memcontrol.c            |    8 ++-----
 mm/rmap.c                  |   55 +++++++++++++++++++++++++++++++++-----------
 3 files changed, 51 insertions(+), 26 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 0108a56..12de53b 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -164,20 +164,20 @@ static inline void mem_cgroup_end_update_page_stat(struct page *page,
 	rcu_read_unlock();
 }
 
-void mem_cgroup_update_page_stat(struct page *page,
+void mem_cgroup_update_page_stat(struct mem_cgroup *memcg,
 				 enum mem_cgroup_page_stat_item idx,
 				 int val);
 
-static inline void mem_cgroup_inc_page_stat(struct page *page,
+static inline void mem_cgroup_inc_page_stat(struct mem_cgroup *memcg,
 					    enum mem_cgroup_page_stat_item idx)
 {
-	mem_cgroup_update_page_stat(page, idx, 1);
+	mem_cgroup_update_page_stat(memcg, idx, 1);
 }
 
-static inline void mem_cgroup_dec_page_stat(struct page *page,
+static inline void mem_cgroup_dec_page_stat(struct mem_cgroup *memcg,
 					    enum mem_cgroup_page_stat_item idx)
 {
-	mem_cgroup_update_page_stat(page, idx, -1);
+	mem_cgroup_update_page_stat(memcg, idx, -1);
 }
 
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
@@ -354,12 +354,12 @@ static inline void mem_cgroup_end_update_page_stat(struct page *page,
 {
 }
 
-static inline void mem_cgroup_inc_page_stat(struct page *page,
+static inline void mem_cgroup_inc_page_stat(struct mem_cgroup *memcg,
 					    enum mem_cgroup_page_stat_item idx)
 {
 }
 
-static inline void mem_cgroup_dec_page_stat(struct page *page,
+static inline void mem_cgroup_dec_page_stat(struct mem_cgroup *memcg,
 					    enum mem_cgroup_page_stat_item idx)
 {
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3817460..1b13e43 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2259,18 +2259,14 @@ void __mem_cgroup_end_update_page_stat(struct page *page, unsigned long *flags)
 	move_unlock_mem_cgroup(pc->mem_cgroup, flags);
 }
 
-void mem_cgroup_update_page_stat(struct page *page,
+void mem_cgroup_update_page_stat(struct mem_cgroup *memcg,
 				 enum mem_cgroup_page_stat_item idx, int val)
 {
-	struct mem_cgroup *memcg;
-	struct page_cgroup *pc = lookup_page_cgroup(page);
-	unsigned long uninitialized_var(flags);
 
 	if (mem_cgroup_disabled())
 		return;
 
-	memcg = pc->mem_cgroup;
-	if (unlikely(!memcg || !PageCgroupUsed(pc)))
+	if (unlikely(!memcg))
 		return;
 
 	switch (idx) {
diff --git a/mm/rmap.c b/mm/rmap.c
index 59b0dca..0d74c48 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1112,13 +1112,25 @@ void page_add_file_rmap(struct page *page)
 {
 	bool locked;
 	unsigned long flags;
+	bool ret;
+	struct mem_cgroup *memcg = NULL;
+	struct cgroup_subsys_state *css = NULL;
 
 	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
-	if (atomic_inc_and_test(&page->_mapcount)) {
+	memcg = try_get_mem_cgroup_from_page(page);
+	ret = atomic_inc_and_test(&page->_mapcount);
+	mem_cgroup_end_update_page_stat(page, &locked, &flags);
+
+	if (ret) {
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
-		mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_MAPPED);
+		if (memcg)
+			mem_cgroup_inc_page_stat(memcg, MEMCG_NR_FILE_MAPPED);
+	}
+
+	if (memcg) {
+		css = mem_cgroup_css(memcg);
+		css_put(css);
 	}
-	mem_cgroup_end_update_page_stat(page, &locked, &flags);
 }
 
 /**
@@ -1133,18 +1145,32 @@ void page_remove_rmap(struct page *page)
 	bool anon = PageAnon(page);
 	bool locked;
 	unsigned long flags;
+	struct mem_cgroup *memcg = NULL;
+	struct cgroup_subsys_state *css = NULL;
+	bool ret;
 
 	/*
 	 * The anon case has no mem_cgroup page_stat to update; but may
 	 * uncharge_page() below, where the lock ordering can deadlock if
 	 * we hold the lock against page_stat move: so avoid it on anon.
 	 */
-	if (!anon)
+	if (!anon) {
 		mem_cgroup_begin_update_page_stat(page, &locked, &flags);
+		memcg = try_get_mem_cgroup_from_page(page);
+		if (memcg)
+			css = mem_cgroup_css(memcg);
+	}
+
+	ret = atomic_add_negative(-1, &page->_mapcount);
+	if (!anon)
+		mem_cgroup_end_update_page_stat(page, &locked, &flags);
 
 	/* page still mapped by someone else? */
-	if (!atomic_add_negative(-1, &page->_mapcount))
-		goto out;
+	if (!ret) {
+		if (!anon && memcg)
+			css_put(css);
+		return;
+	}
 
 	/*
 	 * Now that the last pte has gone, s390 must transfer dirty
@@ -1173,8 +1199,12 @@ void page_remove_rmap(struct page *page)
 	 * Hugepages are not counted in NR_ANON_PAGES nor NR_FILE_MAPPED
 	 * and not charged by memcg for now.
 	 */
-	if (unlikely(PageHuge(page)))
-		goto out;
+	if (unlikely(PageHuge(page))) {
+		if (!anon && memcg)
+			css_put(css);
+		return;
+	}
+
 	if (anon) {
 		mem_cgroup_uncharge_page(page);
 		if (!PageTransHuge(page))
@@ -1184,8 +1214,10 @@ void page_remove_rmap(struct page *page)
 					      NR_ANON_TRANSPARENT_HUGEPAGES);
 	} else {
 		__dec_zone_page_state(page, NR_FILE_MAPPED);
-		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_MAPPED);
-		mem_cgroup_end_update_page_stat(page, &locked, &flags);
+		if (memcg) {
+			mem_cgroup_dec_page_stat(memcg, MEMCG_NR_FILE_MAPPED);
+			css_put(css);
+		}
 	}
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
@@ -1199,9 +1231,6 @@ void page_remove_rmap(struct page *page)
 	 * faster for those pages still in swapcache.
 	 */
 	return;
-out:
-	if (!anon)
-		mem_cgroup_end_update_page_stat(page, &locked, &flags);
 }
 
 /*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
