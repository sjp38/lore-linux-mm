Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 7F9326B007B
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 20:45:44 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 06/11] mm: memcg: move swapin charge functions above callsites
Date: Thu,  5 Jul 2012 02:44:58 +0200
Message-Id: <1341449103-1986-7-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org>
References: <1341449103-1986-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Charging cache pages may require swapin in the shmem case.  Save the
forward declaration and just move the swapin functions above the cache
charging functions.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c |   68 +++++++++++++++++++++++++-----------------------------
 1 files changed, 32 insertions(+), 36 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3d56b4e..4a41b55 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2729,37 +2729,6 @@ int mem_cgroup_newpage_charge(struct page *page,
 					MEM_CGROUP_CHARGE_TYPE_ANON);
 }
 
-static void
-__mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
-					enum charge_type ctype);
-
-int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
-				gfp_t gfp_mask)
-{
-	struct mem_cgroup *memcg = NULL;
-	enum charge_type type = MEM_CGROUP_CHARGE_TYPE_CACHE;
-	int ret;
-
-	if (mem_cgroup_disabled())
-		return 0;
-	if (PageCompound(page))
-		return 0;
-
-	if (unlikely(!mm))
-		mm = &init_mm;
-	if (!page_is_file_cache(page))
-		type = MEM_CGROUP_CHARGE_TYPE_SHMEM;
-
-	if (!PageSwapCache(page))
-		ret = mem_cgroup_charge_common(page, mm, gfp_mask, type);
-	else { /* page is swapcache/shmem */
-		ret = mem_cgroup_try_charge_swapin(mm, page, gfp_mask, &memcg);
-		if (!ret)
-			__mem_cgroup_commit_charge_swapin(page, memcg, type);
-	}
-	return ret;
-}
-
 /*
  * While swap-in, try_charge -> commit or cancel, the page is locked.
  * And when try_charge() successfully returns, one refcnt to memcg without
@@ -2806,6 +2775,15 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
 	return ret;
 }
 
+void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *memcg)
+{
+	if (mem_cgroup_disabled())
+		return;
+	if (!memcg)
+		return;
+	__mem_cgroup_cancel_charge(memcg, 1);
+}
+
 static void
 __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *memcg,
 					enum charge_type ctype)
@@ -2843,13 +2821,31 @@ void mem_cgroup_commit_charge_swapin(struct page *page,
 					  MEM_CGROUP_CHARGE_TYPE_ANON);
 }
 
-void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *memcg)
+int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
+				gfp_t gfp_mask)
 {
+	struct mem_cgroup *memcg = NULL;
+	enum charge_type type = MEM_CGROUP_CHARGE_TYPE_CACHE;
+	int ret;
+
 	if (mem_cgroup_disabled())
-		return;
-	if (!memcg)
-		return;
-	__mem_cgroup_cancel_charge(memcg, 1);
+		return 0;
+	if (PageCompound(page))
+		return 0;
+
+	if (unlikely(!mm))
+		mm = &init_mm;
+	if (!page_is_file_cache(page))
+		type = MEM_CGROUP_CHARGE_TYPE_SHMEM;
+
+	if (!PageSwapCache(page))
+		ret = mem_cgroup_charge_common(page, mm, gfp_mask, type);
+	else { /* page is swapcache/shmem */
+		ret = mem_cgroup_try_charge_swapin(mm, page, gfp_mask, &memcg);
+		if (!ret)
+			__mem_cgroup_commit_charge_swapin(page, memcg, type);
+	}
+	return ret;
 }
 
 static void mem_cgroup_do_uncharge(struct mem_cgroup *memcg,
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
