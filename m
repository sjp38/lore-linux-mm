Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0C04402ED
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 07:30:48 -0500 (EST)
Received: by mail-lb0-f180.google.com with SMTP id kw15so44463903lbb.0
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 04:30:47 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id n5si7562493lfd.222.2015.12.17.04.30.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Dec 2015 04:30:46 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH v2 6/7] mm: free swap cache aggressively if memcg swap is full
Date: Thu, 17 Dec 2015 15:29:59 +0300
Message-ID: <83c9cff28990636841b966f8d6e4a43c1fd342e7.1450352792.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1450352791.git.vdavydov@virtuozzo.com>
References: <cover.1450352791.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Swap cache pages are freed aggressively if swap is nearly full (>50%
currently), because otherwise we are likely to stop scanning anonymous
when we near the swap limit even if there is plenty of freeable swap
cache pages. We should follow the same trend in case of memory cgroup,
which has its own swap limit.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
Changes in v2:
 - Remove unnecessary PageSwapCache check from mem_cgroup_swap_full.
 - Do not check swap limit on the legacy hierarchy.

 include/linux/swap.h |  6 ++++++
 mm/memcontrol.c      | 22 ++++++++++++++++++++++
 mm/memory.c          |  3 ++-
 mm/swapfile.c        |  2 +-
 mm/vmscan.c          |  2 +-
 5 files changed, 32 insertions(+), 3 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index c544998dfbe7..5ebdbabc62f0 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -552,6 +552,7 @@ extern void mem_cgroup_swapout(struct page *page, swp_entry_t entry);
 extern int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry);
 extern void mem_cgroup_uncharge_swap(swp_entry_t entry);
 extern long mem_cgroup_get_nr_swap_pages(struct mem_cgroup *memcg);
+extern bool mem_cgroup_swap_full(struct page *page);
 #else
 static inline void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 {
@@ -571,6 +572,11 @@ static inline long mem_cgroup_get_nr_swap_pages(struct mem_cgroup *memcg)
 {
 	return get_nr_swap_pages();
 }
+
+static inline bool mem_cgroup_swap_full(struct page *page)
+{
+	return vm_swap_full();
+}
 #endif
 
 #endif /* __KERNEL__*/
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e0e498f5ca32..fc25dc211eaf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5749,6 +5749,28 @@ long mem_cgroup_get_nr_swap_pages(struct mem_cgroup *memcg)
 	return nr_swap_pages;
 }
 
+bool mem_cgroup_swap_full(struct page *page)
+{
+	struct mem_cgroup *memcg;
+
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+
+	if (vm_swap_full())
+		return true;
+	if (!do_swap_account || !cgroup_subsys_on_dfl(memory_cgrp_subsys))
+		return false;
+
+	memcg = page->mem_cgroup;
+	if (!memcg)
+		return false;
+
+	for (; memcg != root_mem_cgroup; memcg = parent_mem_cgroup(memcg))
+		if (page_counter_read(&memcg->swap) * 2 >= memcg->swap.limit)
+			return true;
+
+	return false;
+}
+
 /* for remember boot option*/
 #ifdef CONFIG_MEMCG_SWAP_ENABLED
 static int really_do_swap_account __initdata = 1;
diff --git a/mm/memory.c b/mm/memory.c
index 3b115dcaa26e..2bd6a78c142b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2563,7 +2563,8 @@ int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	swap_free(entry);
-	if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
+	if (mem_cgroup_swap_full(page) ||
+	    (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
 		try_to_free_swap(page);
 	unlock_page(page);
 	if (page != swapcache) {
diff --git a/mm/swapfile.c b/mm/swapfile.c
index efa279221302..ab1a8a619676 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1009,7 +1009,7 @@ int free_swap_and_cache(swp_entry_t entry)
 		 * Also recheck PageSwapCache now page is locked (above).
 		 */
 		if (PageSwapCache(page) && !PageWriteback(page) &&
-				(!page_mapped(page) || vm_swap_full())) {
+		    (!page_mapped(page) || mem_cgroup_swap_full(page))) {
 			delete_from_swap_cache(page);
 			SetPageDirty(page);
 		}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ab52d865d922..1cd88e9b0383 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1206,7 +1206,7 @@ cull_mlocked:
 
 activate_locked:
 		/* Not a candidate for swapping, so reclaim swap space. */
-		if (PageSwapCache(page) && vm_swap_full())
+		if (PageSwapCache(page) && mem_cgroup_swap_full(page))
 			try_to_free_swap(page);
 		VM_BUG_ON_PAGE(PageActive(page), page);
 		SetPageActive(page);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
