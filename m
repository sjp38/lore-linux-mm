Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 50F1D6B003D
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 12:04:45 -0500 (EST)
Received: by mail-ee0-f43.google.com with SMTP id c41so1677482eek.30
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 09:04:44 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id w2si9398582eeg.91.2014.02.07.09.04.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 09:04:44 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 8/8] memcg: sanitize __mem_cgroup_try_charge() call protocol
Date: Fri,  7 Feb 2014 12:04:25 -0500
Message-Id: <1391792665-21678-9-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1391792665-21678-1-git-send-email-hannes@cmpxchg.org>
References: <1391792665-21678-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Some callsites pass a memcg directly, some callsites pass a mm that
first has to be translated to an mm.  This makes for a terrible
function interface.

Just push the mm-to-memcg translation into the respective callsites
and always pass a memcg to mem_cgroup_try_charge().

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 135 +++++++++++++++++++++++---------------------------------
 1 file changed, 54 insertions(+), 81 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9eabe4473649..0049081b834d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2609,7 +2609,7 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
 }
 
 
-/* See __mem_cgroup_try_charge() for details */
+/* See mem_cgroup_try_charge() for details */
 enum {
 	CHARGE_OK,		/* success */
 	CHARGE_RETRY,		/* need to retry but retry is not bad */
@@ -2682,45 +2682,34 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	return CHARGE_NOMEM;
 }
 
-/*
- * __mem_cgroup_try_charge() does
- * 1. detect memcg to be charged against from passed *mm and *ptr,
- * 2. update res_counter
- * 3. call memory reclaim if necessary.
- *
- * In some special case, if the task is fatal, fatal_signal_pending() or
- * has TIF_MEMDIE, this function returns -EINTR while writing root_mem_cgroup
- * to *ptr. There are two reasons for this. 1: fatal threads should quit as soon
- * as possible without any hazards. 2: all pages should have a valid
- * pc->mem_cgroup. If mm is NULL and the caller doesn't pass a valid memcg
- * pointer, that is treated as a charge to root_mem_cgroup.
- *
- * So __mem_cgroup_try_charge() will return
- *  0       ...  on success, filling *ptr with a valid memcg pointer.
- *  -ENOMEM ...  charge failure because of resource limits.
- *  -EINTR  ...  if thread is fatal. *ptr is filled with root_mem_cgroup.
+/**
+ * mem_cgroup_try_charge - try charging a memcg
+ * @memcg: memcg to charge
+ * @nr_pages: number of pages to charge
+ * @oom: trigger OOM if reclaim fails
  *
- * Unlike the exported interface, an "oom" parameter is added. if oom==true,
- * the oom-killer can be invoked.
+ * Returns 0 if @memcg was charged successfully, -EINTR if the charge
+ * was bypassed to root_mem_cgroup, and -ENOMEM if the charge failed.
  */
-static int __mem_cgroup_try_charge(struct mm_struct *mm,
-				   gfp_t gfp_mask,
-				   unsigned int nr_pages,
-				   struct mem_cgroup **ptr,
-				   bool oom)
+static int mem_cgroup_try_charge(struct mem_cgroup *memcg,
+				 gfp_t gfp_mask,
+				 unsigned int nr_pages,
+				 bool oom)
 {
 	unsigned int batch = max(CHARGE_BATCH, nr_pages);
 	int nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
-	struct mem_cgroup *memcg = NULL;
 	int ret;
 
+	if (mem_cgroup_is_root(memcg))
+		goto done;
 	/*
-	 * Unlike gloval-vm's OOM-kill, we're not in memory shortage
-	 * in system level. So, allow to go ahead dying process in addition to
-	 * MEMDIE process.
+	 * Unlike in global OOM situations, memcg is not in a physical
+	 * memory shortage.  Allow dying and OOM-killed tasks to
+	 * bypass the last charges so that they can exit quickly and
+	 * free their memory.
 	 */
-	if (unlikely(test_thread_flag(TIF_MEMDIE)
-		     || fatal_signal_pending(current)))
+	if (unlikely(test_thread_flag(TIF_MEMDIE) ||
+		     fatal_signal_pending(current)))
 		goto bypass;
 
 	if (unlikely(task_in_memcg_oom(current)))
@@ -2729,14 +2718,6 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 	if (gfp_mask & __GFP_NOFAIL)
 		oom = false;
 again:
-	if (*ptr) { /* css should be a valid one */
-		memcg = *ptr;
-		css_get(&memcg->css);
-	} else {
-		memcg = get_mem_cgroup_from_mm(mm);
-	}
-	if (mem_cgroup_is_root(memcg))
-		goto done;
 	if (consume_stock(memcg, nr_pages))
 		goto done;
 
@@ -2744,10 +2725,8 @@ again:
 		bool invoke_oom = oom && !nr_oom_retries;
 
 		/* If killed, bypass charge */
-		if (fatal_signal_pending(current)) {
-			css_put(&memcg->css);
+		if (fatal_signal_pending(current))
 			goto bypass;
-		}
 
 		ret = mem_cgroup_do_charge(memcg, gfp_mask, batch,
 					   nr_pages, invoke_oom);
@@ -2756,17 +2735,12 @@ again:
 			break;
 		case CHARGE_RETRY: /* not in OOM situation but retry */
 			batch = nr_pages;
-			css_put(&memcg->css);
-			memcg = NULL;
 			goto again;
 		case CHARGE_WOULDBLOCK: /* !__GFP_WAIT */
-			css_put(&memcg->css);
 			goto nomem;
 		case CHARGE_NOMEM: /* OOM routine works */
-			if (!oom || invoke_oom) {
-				css_put(&memcg->css);
+			if (!oom || invoke_oom)
 				goto nomem;
-			}
 			nr_oom_retries--;
 			break;
 		}
@@ -2775,16 +2749,11 @@ again:
 	if (batch > nr_pages)
 		refill_stock(memcg, batch - nr_pages);
 done:
-	css_put(&memcg->css);
-	*ptr = memcg;
 	return 0;
 nomem:
-	if (!(gfp_mask & __GFP_NOFAIL)) {
-		*ptr = NULL;
+	if (!(gfp_mask & __GFP_NOFAIL))
 		return -ENOMEM;
-	}
 bypass:
-	*ptr = root_mem_cgroup;
 	return -EINTR;
 }
 
@@ -2983,20 +2952,17 @@ static int mem_cgroup_slabinfo_read(struct seq_file *m, void *v)
 static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
 {
 	struct res_counter *fail_res;
-	struct mem_cgroup *_memcg;
 	int ret = 0;
 
 	ret = res_counter_charge(&memcg->kmem, size, &fail_res);
 	if (ret)
 		return ret;
 
-	_memcg = memcg;
-	ret = __mem_cgroup_try_charge(NULL, gfp, size >> PAGE_SHIFT,
-				      &_memcg, oom_gfp_allowed(gfp));
-
+	ret = mem_cgroup_try_charge(memcg, gfp, size >> PAGE_SHIFT,
+				    oom_gfp_allowed(gfp));
 	if (ret == -EINTR)  {
 		/*
-		 * __mem_cgroup_try_charge() chosed to bypass to root due to
+		 * mem_cgroup_try_charge() chosed to bypass to root due to
 		 * OOM kill or fatal signal.  Since our only options are to
 		 * either fail the allocation or charge it to this cgroup, do
 		 * it as a temporary condition. But we can't fail. From a
@@ -3006,7 +2972,7 @@ static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
 		 *
 		 * This condition will only trigger if the task entered
 		 * memcg_charge_kmem in a sane state, but was OOM-killed during
-		 * __mem_cgroup_try_charge() above. Tasks that were already
+		 * mem_cgroup_try_charge() above. Tasks that were already
 		 * dying when the allocation triggers should have been already
 		 * directed to the root cgroup in memcontrol.h
 		 */
@@ -3864,8 +3830,8 @@ out:
 static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask, enum charge_type ctype)
 {
-	struct mem_cgroup *memcg = NULL;
 	unsigned int nr_pages = 1;
+	struct mem_cgroup *memcg;
 	bool oom = true;
 	int ret;
 
@@ -3879,8 +3845,14 @@ static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
 		oom = false;
 	}
 
-	ret = __mem_cgroup_try_charge(mm, gfp_mask, nr_pages, &memcg, oom);
-	if (ret == -ENOMEM)
+	memcg = get_mem_cgroup_from_mm(mm);
+	ret = mem_cgroup_try_charge(memcg, gfp_mask, nr_pages, oom);
+	css_put(&memcg->css);
+	if (ret == -EINTR) {
+		memcg = root_mem_cgroup;
+		ret = 0;
+	}
+	if (ret)
 		return ret;
 	__mem_cgroup_commit_charge(memcg, page, nr_pages, ctype, false);
 	return 0;
@@ -3909,7 +3881,7 @@ static int __mem_cgroup_try_charge_swapin(struct mm_struct *mm,
 					  gfp_t mask,
 					  struct mem_cgroup **memcgp)
 {
-	struct mem_cgroup *memcg;
+	struct mem_cgroup *memcg = NULL;
 	struct page_cgroup *pc;
 	int ret;
 
@@ -3923,21 +3895,17 @@ static int __mem_cgroup_try_charge_swapin(struct mm_struct *mm,
 	 */
 	if (PageCgroupUsed(pc))
 		return 0;
-	if (!do_swap_account)
-		goto charge_cur_mm;
-	memcg = try_get_mem_cgroup_from_page(page);
+	if (do_swap_account)
+		memcg = try_get_mem_cgroup_from_page(page);
 	if (!memcg)
-		goto charge_cur_mm;
-	*memcgp = memcg;
-	ret = __mem_cgroup_try_charge(NULL, mask, 1, memcgp, true);
+		memcg = get_mem_cgroup_from_mm(mm);
+	ret = mem_cgroup_try_charge(memcg, mask, 1, true);
 	css_put(&memcg->css);
-	if (ret == -EINTR)
-		ret = 0;
-	return ret;
-charge_cur_mm:
-	ret = __mem_cgroup_try_charge(mm, mask, 1, memcgp, true);
-	if (ret == -EINTR)
+	if (ret == -EINTR) {
+		memcg = root_mem_cgroup;
 		ret = 0;
+	}
+	*memcgp = memcg;
 	return ret;
 }
 
@@ -3954,11 +3922,17 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm, struct page *page,
 	 * there's also a KSM case which does need to charge the page.
 	 */
 	if (!PageSwapCache(page)) {
+		struct mem_cgroup *memcg;
 		int ret;
 
-		ret = __mem_cgroup_try_charge(mm, gfp_mask, 1, memcgp, true);
-		if (ret == -EINTR)
+		memcg = get_mem_cgroup_from_mm(mm);
+		ret = mem_cgroup_try_charge(memcg, gfp_mask, 1, true);
+		css_put(&memcg->css);
+		if (ret == -EINTR) {
+			memcg = root_mem_cgroup;
 			ret = 0;
+		}
+		*memcgp = memcg;
 		return ret;
 	}
 	return __mem_cgroup_try_charge_swapin(mm, page, gfp_mask, memcgp);
@@ -6607,8 +6581,7 @@ one_by_one:
 			batch_count = PRECHARGE_COUNT_AT_ONCE;
 			cond_resched();
 		}
-		ret = __mem_cgroup_try_charge(NULL,
-					GFP_KERNEL, 1, &memcg, false);
+		ret = mem_cgroup_try_charge(memcg, GFP_KERNEL, 1, false);
 		if (ret)
 			/* mem_cgroup_clear_mc() will do uncharge later */
 			return ret;
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
