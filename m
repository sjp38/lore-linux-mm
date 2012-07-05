Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 0E59C6B0075
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 20:45:47 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 09/11] mm: memcg: split swapin charge function into private and public part
Date: Thu,  5 Jul 2012 02:45:01 +0200
Message-Id: <1341449103-1986-10-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org>
References: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

When shmem is charged upon swapin, it does not need to check twice
whether the memory controller is enabled.

Also, shmem pages do not have to be checked for everything that
regular anon pages have to be checked for, so let shmem use the
internal version directly and allow future patches to move around
checks that are only required when swapping in anon pages.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c |   24 +++++++++++++++---------
 1 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6fe4101..a8bf86a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2734,18 +2734,14 @@ int mem_cgroup_newpage_charge(struct page *page,
  * struct page_cgroup is acquired. This refcnt will be consumed by
  * "commit()" or removed by "cancel()"
  */
-int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
-				 struct page *page,
-				 gfp_t mask, struct mem_cgroup **memcgp)
+static int __mem_cgroup_try_charge_swapin(struct mm_struct *mm,
+					  struct page *page,
+					  gfp_t mask,
+					  struct mem_cgroup **memcgp)
 {
 	struct mem_cgroup *memcg;
 	int ret;
 
-	*memcgp = NULL;
-
-	if (mem_cgroup_disabled())
-		return 0;
-
 	if (!do_swap_account)
 		goto charge_cur_mm;
 	/*
@@ -2772,6 +2768,15 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
 	return ret;
 }
 
+int mem_cgroup_try_charge_swapin(struct mm_struct *mm, struct page *page,
+				 gfp_t gfp_mask, struct mem_cgroup **memcgp)
+{
+	*memcgp = NULL;
+	if (mem_cgroup_disabled())
+		return 0;
+	return __mem_cgroup_try_charge_swapin(mm, page, gfp_mask, memcgp);
+}
+
 void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *memcg)
 {
 	if (mem_cgroup_disabled())
@@ -2833,7 +2838,8 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 	if (!PageSwapCache(page))
 		ret = mem_cgroup_charge_common(page, mm, gfp_mask, type);
 	else { /* page is swapcache/shmem */
-		ret = mem_cgroup_try_charge_swapin(mm, page, gfp_mask, &memcg);
+		ret = __mem_cgroup_try_charge_swapin(mm, page,
+						     gfp_mask, &memcg);
 		if (!ret)
 			__mem_cgroup_commit_charge_swapin(page, memcg, type);
 	}
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
