Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id DF3406B000E
	for <linux-mm@kvack.org>; Sat, 24 Mar 2018 12:51:42 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id l188so2230769ywd.6
        for <linux-mm@kvack.org>; Sat, 24 Mar 2018 09:51:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n123sor4233058ywe.371.2018.03.24.09.51.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 24 Mar 2018 09:51:41 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 1/2] mm, memcontrol: Move swap charge handling into get_swap_page()
Date: Sat, 24 Mar 2018 09:51:26 -0700
Message-Id: <20180324165127.701194-2-tj@kernel.org>
In-Reply-To: <20180324165127.701194-1-tj@kernel.org>
References: <20180324165127.701194-1-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com
Cc: guro@fb.com, riel@surriel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>

get_swap_page() is always followed by mem_cgroup_try_charge_swap().
This patch moves mem_cgroup_try_charge_swap() into get_swap_page() and
makes get_swap_page() call the function even after swap allocation
failure.

This simplifies the callers and consolidates memcg related logic and
will ease adding swap related memcg events.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Rik van Riel <riel@surriel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/memcontrol.c |  3 +++
 mm/shmem.c      |  4 ----
 mm/swap_slots.c | 10 +++++++---
 mm/swap_state.c |  3 ---
 4 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d5bf01d..9f9c8a7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5987,6 +5987,9 @@ int mem_cgroup_try_charge_swap(struct page *page, swp_entry_t entry)
 	if (!memcg)
 		return 0;
 
+	if (!entry.val)
+		return 0;
+
 	memcg = mem_cgroup_id_get_online(memcg);
 
 	if (!mem_cgroup_is_root(memcg) &&
diff --git a/mm/shmem.c b/mm/shmem.c
index 1907688..4a07d21 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1313,9 +1313,6 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 	if (!swap.val)
 		goto redirty;
 
-	if (mem_cgroup_try_charge_swap(page, swap))
-		goto free_swap;
-
 	/*
 	 * Add inode to shmem_unuse()'s list of swapped-out inodes,
 	 * if it's not already there.  Do it now before the page is
@@ -1344,7 +1341,6 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 	}
 
 	mutex_unlock(&shmem_swaplist_mutex);
-free_swap:
 	put_swap_page(page, swap);
 redirty:
 	set_page_dirty(page);
diff --git a/mm/swap_slots.c b/mm/swap_slots.c
index bebc192..7546eb2 100644
--- a/mm/swap_slots.c
+++ b/mm/swap_slots.c
@@ -319,7 +319,7 @@ swp_entry_t get_swap_page(struct page *page)
 	if (PageTransHuge(page)) {
 		if (IS_ENABLED(CONFIG_THP_SWAP))
 			get_swap_pages(1, true, &entry);
-		return entry;
+		goto out;
 	}
 
 	/*
@@ -349,11 +349,15 @@ swp_entry_t get_swap_page(struct page *page)
 		}
 		mutex_unlock(&cache->alloc_lock);
 		if (entry.val)
-			return entry;
+			goto out;
 	}
 
 	get_swap_pages(1, false, &entry);
-
+out:
+	if (mem_cgroup_try_charge_swap(page, entry)) {
+		put_swap_page(page, entry);
+		entry.val = 0;
+	}
 	return entry;
 }
 
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 39ae7cf..41f0809 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -216,9 +216,6 @@ int add_to_swap(struct page *page)
 	if (!entry.val)
 		return 0;
 
-	if (mem_cgroup_try_charge_swap(page, entry))
-		goto fail;
-
 	/*
 	 * Radix-tree node allocations from PF_MEMALLOC contexts could
 	 * completely exhaust the page allocator. __GFP_NOMEMALLOC
-- 
2.9.5
