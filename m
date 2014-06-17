Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4A6916B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 10:23:20 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id n3so5957411wiv.15
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 07:23:19 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v8si24417290wjq.85.2014.06.17.07.23.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 07:23:19 -0700 (PDT)
Date: Tue, 17 Jun 2014 16:23:17 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 03/12] mm: huge_memory: use GFP_TRANSHUGE when charging
 huge pages
Message-ID: <20140617142317.GD19886@dhcp22.suse.cz>
References: <1402948472-8175-1-git-send-email-hannes@cmpxchg.org>
 <1402948472-8175-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402948472-8175-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 16-06-14 15:54:23, Johannes Weiner wrote:
> Transparent huge page charges prefer falling back to regular pages
> rather than spending a lot of time in direct reclaim.
> 
> Desired reclaim behavior is usually declared in the gfp mask, but THP
> charges use GFP_KERNEL and then rely on the fact that OOM is disabled
> for THP charges, and that OOM-disabled charges currently skip reclaim.
> Needless to say, this is anything but obvious and quite error prone.
> 
> Convert THP charges to use GFP_TRANSHUGE instead, which implies
> __GFP_NORETRY, to indicate the low-latency requirement.

Maybe we can get one step further and even get rid of oom parameter.
It is only THP (handled by this patch) and mem_cgroup_do_precharge that
want OOM disabled explicitly.

GFP_KERNEL & (~__GFP_NORETRY) is ugly and something like GFP_NO_OOM
would be better but this is just a quick scratch.

What do you think?
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 52550bbff1ef..5d247822b03a 100644
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
@@ -2647,7 +2645,7 @@ retry:
 	if (fatal_signal_pending(current))
 		goto bypass;
 
-	if (!oom)
+	if (!oom_gfp_allowed(gfp_mask))
 		goto nomem;
 
 	mem_cgroup_oom(mem_over_limit, gfp_mask, get_order(batch));
@@ -2675,15 +2673,14 @@ done:
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
@@ -2900,8 +2897,7 @@ static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
 	if (ret)
 		return ret;
 
-	ret = mem_cgroup_try_charge(memcg, gfp, size >> PAGE_SHIFT,
-				    oom_gfp_allowed(gfp));
+	ret = mem_cgroup_try_charge(memcg, gfp, size >> PAGE_SHIFT);
 	if (ret == -EINTR)  {
 		/*
 		 * mem_cgroup_try_charge() chosed to bypass to root due to
@@ -3650,7 +3646,6 @@ int mem_cgroup_charge_anon(struct page *page,
 {
 	unsigned int nr_pages = 1;
 	struct mem_cgroup *memcg;
-	bool oom = true;
 
 	if (mem_cgroup_disabled())
 		return 0;
@@ -3666,10 +3661,10 @@ int mem_cgroup_charge_anon(struct page *page,
 		 * Never OOM-kill a process for a huge page.  The
 		 * fault handler will fall back to regular pages.
 		 */
-		oom = false;
+		VM_BUG_ON(oom_gfp_allowed(gfp_mask));
 	}
 
-	memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, nr_pages, oom);
+	memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, nr_pages);
 	if (!memcg)
 		return -ENOMEM;
 	__mem_cgroup_commit_charge(memcg, page, nr_pages,
@@ -3706,7 +3701,7 @@ static int __mem_cgroup_try_charge_swapin(struct mm_struct *mm,
 		memcg = try_get_mem_cgroup_from_page(page);
 	if (!memcg)
 		memcg = get_mem_cgroup_from_mm(mm);
-	ret = mem_cgroup_try_charge(memcg, mask, 1, true);
+	ret = mem_cgroup_try_charge(memcg, mask, 1);
 	css_put(&memcg->css);
 	if (ret == -EINTR)
 		memcg = root_mem_cgroup;
@@ -3733,7 +3728,7 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm, struct page *page,
 	if (!PageSwapCache(page)) {
 		struct mem_cgroup *memcg;
 
-		memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, 1, true);
+		memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, 1);
 		if (!memcg)
 			return -ENOMEM;
 		*memcgp = memcg;
@@ -3802,7 +3797,7 @@ int mem_cgroup_charge_file(struct page *page, struct mm_struct *mm,
 		return 0;
 	}
 
-	memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, 1, true);
+	memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, 1);
 	if (!memcg)
 		return -ENOMEM;
 	__mem_cgroup_commit_charge(memcg, page, 1, type, false);
@@ -6414,7 +6409,8 @@ one_by_one:
 			batch_count = PRECHARGE_COUNT_AT_ONCE;
 			cond_resched();
 		}
-		ret = mem_cgroup_try_charge(memcg, GFP_KERNEL, 1, false);
+		/* Do not trigger OOM killer from this path */
+		ret = mem_cgroup_try_charge(memcg, GFP_KERNEL & (~__GFP_NORETRY), 1);
 		if (ret)
 			/* mem_cgroup_clear_mc() will do uncharge later */
 			return ret;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
