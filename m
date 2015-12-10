Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 83A7C6B025A
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 06:39:53 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so46392301pac.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 03:39:53 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id 70si19855013pfn.58.2015.12.10.03.39.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 03:39:52 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 6/7] mm: free swap cache aggressively if memcg swap is full
Date: Thu, 10 Dec 2015 14:39:19 +0300
Message-ID: <2c7ac3a5c2a2fb9b1c5136d8409652ed7ecc260f.1449742561.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1449742560.git.vdavydov@virtuozzo.com>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Swap cache pages are freed aggressively if swap is nearly full (>50%
currently), because otherwise we are likely to stop scanning anonymous
when we near the swap limit even if there is plenty of freeable swap
cache pages. We should follow the same trend in case of memory cgroup,
which has its own swap limit.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/linux/swap.h |  6 ++++++
 mm/memcontrol.c      | 23 +++++++++++++++++++++++
 mm/memory.c          |  3 ++-
 mm/swapfile.c        |  2 +-
 mm/vmscan.c          |  2 +-
 5 files changed, 33 insertions(+), 3 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index e3344d8ca2e9..1d708860be97 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -552,6 +552,7 @@ extern void mem_cgroup_swapout(struct page *page, swp_entry_t entry);
 extern int mem_cgroup_charge_swap(struct page *page, swp_entry_t entry);
 extern void mem_cgroup_uncharge_swap(swp_entry_t entry);
 extern long mem_cgroup_get_nr_swap_pages(struct mem_cgroup *memcg);
+extern bool mem_cgroup_swap_full(struct page *page);
 #else
 static inline void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 {
@@ -570,6 +571,11 @@ static inline long mem_cgroup_get_nr_swap_pages(struct mem_cgroup *memcg)
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
index 2ee823d62f80..e5bd43340cd8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5839,6 +5839,29 @@ long mem_cgroup_get_nr_swap_pages(struct mem_cgroup *memcg)
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
+	if (!do_swap_account || !PageSwapCache(page))
+		return false;
+
+	memcg = page->mem_cgroup;
+	if (!memcg)
+		return false;
+
+	for (; memcg != root_mem_cgroup; memcg = parent_mem_cgroup(memcg)) {
+		if (page_counter_read(&memcg->swap) * 2 >=
+				READ_ONCE(memcg->swap.limit))
+			return true;
+	}
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
index 7073faecb38f..c0aba04f7a59 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1011,7 +1011,7 @@ int free_swap_and_cache(swp_entry_t entry)
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
