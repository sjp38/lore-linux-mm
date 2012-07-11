Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 2DD946B0068
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 13:02:53 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 04/10] mm: memcg: only check for PageSwapCache when uncharging anon
Date: Wed, 11 Jul 2012 19:02:16 +0200
Message-Id: <1342026142-7284-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1342026142-7284-1-git-send-email-hannes@cmpxchg.org>
References: <1342026142-7284-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwp.linux@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Only anon pages that are uncharged at the time of the last page table
mapping vanishing may be in swapcache.

When shmem pages, file pages, swap-freed anon pages, or just migrated
pages are uncharged, they are known for sure to be not in swapcache.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fb8d525..a5c0693 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3094,8 +3094,6 @@ void mem_cgroup_uncharge_cache_page(struct page *page)
 {
 	VM_BUG_ON(page_mapped(page));
 	VM_BUG_ON(page->mapping);
-	if (PageSwapCache(page))
-		return;
 	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE, false);
 }
 
@@ -3160,8 +3158,6 @@ mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
 	if (!swapout) /* this was a swap cache but the swap is unused ! */
 		ctype = MEM_CGROUP_CHARGE_TYPE_DROP;
 
-	if (PageSwapCache(page))
-		return;
 	memcg = __mem_cgroup_uncharge_common(page, ctype, false);
 
 	/*
@@ -3351,11 +3347,10 @@ void mem_cgroup_end_migration(struct mem_cgroup *memcg,
 		unused = oldpage;
 	}
 	anon = PageAnon(used);
-	if (!PageSwapCache(unused))
-		__mem_cgroup_uncharge_common(unused,
-					     anon ? MEM_CGROUP_CHARGE_TYPE_ANON
-					     : MEM_CGROUP_CHARGE_TYPE_CACHE,
-					     true);
+	__mem_cgroup_uncharge_common(unused,
+				     anon ? MEM_CGROUP_CHARGE_TYPE_ANON
+				     : MEM_CGROUP_CHARGE_TYPE_CACHE,
+				     true);
 	css_put(&memcg->css);
 	/*
 	 * We disallowed uncharge of pages under migration because mapcount
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
