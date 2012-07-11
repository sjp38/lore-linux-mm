Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 05A246B007B
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 13:02:53 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 06/10] mm: memcg: remove unneeded shmem charge type
Date: Wed, 11 Jul 2012 19:02:18 +0200
Message-Id: <1342026142-7284-7-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1342026142-7284-1-git-send-email-hannes@cmpxchg.org>
References: <1342026142-7284-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwp.linux@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

shmem page charges have not needed a separate charge type to tell them
from regular file pages since 08e552c 'memcg: synchronized LRU'.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |   11 +----------
 1 files changed, 1 insertions(+), 10 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 081780b..2c7d164c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -379,7 +379,6 @@ static bool move_file(void)
 enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
 	MEM_CGROUP_CHARGE_TYPE_ANON,
-	MEM_CGROUP_CHARGE_TYPE_SHMEM,	/* used by page migration of shmem */
 	MEM_CGROUP_CHARGE_TYPE_SWAPOUT,	/* for accounting swapcache */
 	MEM_CGROUP_CHARGE_TYPE_DROP,	/* a page was unused swap cache */
 	NR_CHARGE_TYPE,
@@ -2903,8 +2902,6 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 
 	if (unlikely(!mm))
 		mm = &init_mm;
-	if (!page_is_file_cache(page))
-		type = MEM_CGROUP_CHARGE_TYPE_SHMEM;
 
 	if (!PageSwapCache(page))
 		ret = mem_cgroup_charge_common(page, mm, gfp_mask, type);
@@ -3311,10 +3308,8 @@ void mem_cgroup_prepare_migration(struct page *page, struct page *newpage,
 	 */
 	if (PageAnon(page))
 		ctype = MEM_CGROUP_CHARGE_TYPE_ANON;
-	else if (page_is_file_cache(page))
-		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
 	else
-		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
+		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
 	/*
 	 * The page is committed to the memcg, but it's not actually
 	 * charged to the res_counter since we plan on replacing the
@@ -3408,10 +3403,6 @@ void mem_cgroup_replace_page_cache(struct page *oldpage,
 	 */
 	if (!memcg)
 		return;
-
-	if (PageSwapBacked(oldpage))
-		type = MEM_CGROUP_CHARGE_TYPE_SHMEM;
-
 	/*
 	 * Even if newpage->mapping was NULL before starting replacement,
 	 * the newpage may be on LRU(or pagevec for LRU) already. We lock
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
