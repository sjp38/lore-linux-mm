Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0406B0007
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 19:09:38 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id c184so2275458ywh.5
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 16:09:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b85-v6sor4067388ybg.156.2018.04.16.16.09.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Apr 2018 16:09:37 -0700 (PDT)
Date: Mon, 16 Apr 2018 16:09:34 -0700
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 1/2] mm, memcontrol: Move swap charge handling into
 get_swap_page()
Message-ID: <20180416230934.GH1911913@devbig577.frc2.facebook.com>
References: <20180416230901.GG1911913@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180416230901.GG1911913@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com
Cc: guro@fb.com, riel@surriel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org

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
 mm/memcontrol.c |    3 +++
 mm/shmem.c      |    4 ----
 mm/swap_slots.c |   10 +++++++---
 mm/swap_state.c |    3 ---
 4 files changed, 10 insertions(+), 10 deletions(-)

--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6012,6 +6012,9 @@ int mem_cgroup_try_charge_swap(struct pa
 	if (!memcg)
 		return 0;
 
+	if (!entry.val)
+		return 0;
+
 	memcg = mem_cgroup_id_get_online(memcg);
 
 	if (!mem_cgroup_is_root(memcg) &&
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1322,9 +1322,6 @@ static int shmem_writepage(struct page *
 	if (!swap.val)
 		goto redirty;
 
-	if (mem_cgroup_try_charge_swap(page, swap))
-		goto free_swap;
-
 	/*
 	 * Add inode to shmem_unuse()'s list of swapped-out inodes,
 	 * if it's not already there.  Do it now before the page is
@@ -1353,7 +1350,6 @@ static int shmem_writepage(struct page *
 	}
 
 	mutex_unlock(&shmem_swaplist_mutex);
-free_swap:
 	put_swap_page(page, swap);
 redirty:
 	set_page_dirty(page);
--- a/mm/swap_slots.c
+++ b/mm/swap_slots.c
@@ -317,7 +317,7 @@ swp_entry_t get_swap_page(struct page *p
 	if (PageTransHuge(page)) {
 		if (IS_ENABLED(CONFIG_THP_SWAP))
 			get_swap_pages(1, true, &entry);
-		return entry;
+		goto out;
 	}
 
 	/*
@@ -347,10 +347,14 @@ repeat:
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
