Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id E8F206B003C
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 16:41:04 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so8312377wib.11
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 13:41:04 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id f9si4144634wie.75.2014.06.18.13.41.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Jun 2014 13:41:03 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 06/13] mm: memcontrol: remove explicit OOM parameter in charge path
Date: Wed, 18 Jun 2014 16:40:38 -0400
Message-Id: <1403124045-24361-7-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

From: Michal Hocko <mhocko@suse.cz>

For the page allocator, __GFP_NORETRY implies that no OOM should be
triggered, whereas memcg has an explicit parameter to disable OOM.

The only callsites that want OOM disabled are THP charges and charge
moving.  THP already uses __GFP_NORETRY and charge moving can use it
as well - one full reclaim cycle should be plenty.  Switch it over,
then remove the OOM parameter.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 32 ++++++++++----------------------
 1 file changed, 10 insertions(+), 22 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9c646b9b56f4..c765125694e2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2555,15 +2555,13 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
  * mem_cgroup_try_charge - try charging a memcg
  * @memcg: memcg to charge
  * @nr_pages: number of pages to charge
- * @oom: trigger OOM if reclaim fails
  *
  * Returns 0 if @memcg was charged successfully, -EINTR if the charge
  * was bypassed to root_mem_cgroup, and -ENOMEM if the charge failed.
  */
 static int mem_cgroup_try_charge(struct mem_cgroup *memcg,
 				 gfp_t gfp_mask,
-				 unsigned int nr_pages,
-				 bool oom)
+				 unsigned int nr_pages)
 {
 	unsigned int batch = max(CHARGE_BATCH, nr_pages);
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
@@ -2647,9 +2645,6 @@ retry:
 	if (fatal_signal_pending(current))
 		goto bypass;
 
-	if (!oom)
-		goto nomem;
-
 	mem_cgroup_oom(mem_over_limit, gfp_mask, get_order(batch));
 nomem:
 	if (!(gfp_mask & __GFP_NOFAIL))
@@ -2675,15 +2670,14 @@ done:
  */
 static struct mem_cgroup *mem_cgroup_try_charge_mm(struct mm_struct *mm,
 				 gfp_t gfp_mask,
-				 unsigned int nr_pages,
-				 bool oom)
+				 unsigned int nr_pages)
 
 {
 	struct mem_cgroup *memcg;
 	int ret;
 
 	memcg = get_mem_cgroup_from_mm(mm);
-	ret = mem_cgroup_try_charge(memcg, gfp_mask, nr_pages, oom);
+	ret = mem_cgroup_try_charge(memcg, gfp_mask, nr_pages);
 	css_put(&memcg->css);
 	if (ret == -EINTR)
 		memcg = root_mem_cgroup;
@@ -2900,8 +2894,7 @@ static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
 	if (ret)
 		return ret;
 
-	ret = mem_cgroup_try_charge(memcg, gfp, size >> PAGE_SHIFT,
-				    oom_gfp_allowed(gfp));
+	ret = mem_cgroup_try_charge(memcg, gfp, size >> PAGE_SHIFT);
 	if (ret == -EINTR)  {
 		/*
 		 * mem_cgroup_try_charge() chosed to bypass to root due to
@@ -3650,7 +3643,6 @@ int mem_cgroup_charge_anon(struct page *page,
 {
 	unsigned int nr_pages = 1;
 	struct mem_cgroup *memcg;
-	bool oom = true;
 
 	if (mem_cgroup_disabled())
 		return 0;
@@ -3662,14 +3654,9 @@ int mem_cgroup_charge_anon(struct page *page,
 	if (PageTransHuge(page)) {
 		nr_pages <<= compound_order(page);
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
-		/*
-		 * Never OOM-kill a process for a huge page.  The
-		 * fault handler will fall back to regular pages.
-		 */
-		oom = false;
 	}
 
-	memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, nr_pages, oom);
+	memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, nr_pages);
 	if (!memcg)
 		return -ENOMEM;
 	__mem_cgroup_commit_charge(memcg, page, nr_pages,
@@ -3706,7 +3693,7 @@ static int __mem_cgroup_try_charge_swapin(struct mm_struct *mm,
 		memcg = try_get_mem_cgroup_from_page(page);
 	if (!memcg)
 		memcg = get_mem_cgroup_from_mm(mm);
-	ret = mem_cgroup_try_charge(memcg, mask, 1, true);
+	ret = mem_cgroup_try_charge(memcg, mask, 1);
 	css_put(&memcg->css);
 	if (ret == -EINTR)
 		memcg = root_mem_cgroup;
@@ -3733,7 +3720,7 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm, struct page *page,
 	if (!PageSwapCache(page)) {
 		struct mem_cgroup *memcg;
 
-		memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, 1, true);
+		memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, 1);
 		if (!memcg)
 			return -ENOMEM;
 		*memcgp = memcg;
@@ -3802,7 +3789,7 @@ int mem_cgroup_charge_file(struct page *page, struct mm_struct *mm,
 		return 0;
 	}
 
-	memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, 1, true);
+	memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, 1);
 	if (!memcg)
 		return -ENOMEM;
 	__mem_cgroup_commit_charge(memcg, page, 1, type, false);
@@ -6414,7 +6401,8 @@ one_by_one:
 			batch_count = PRECHARGE_COUNT_AT_ONCE;
 			cond_resched();
 		}
-		ret = mem_cgroup_try_charge(memcg, GFP_KERNEL, 1, false);
+		ret = mem_cgroup_try_charge(memcg,
+					    GFP_KERNEL & ~__GFP_NORETRY, 1);
 		if (ret)
 			/* mem_cgroup_clear_mc() will do uncharge later */
 			return ret;
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
