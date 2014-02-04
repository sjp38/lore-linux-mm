Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id B56576B0037
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 08:29:11 -0500 (EST)
Received: by mail-we0-f177.google.com with SMTP id t61so4048833wes.22
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 05:29:11 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n18si6191214wij.19.2014.02.04.05.29.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 05:29:10 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH -v2 2/6] memcg: cleanup charge routines
Date: Tue,  4 Feb 2014 14:28:56 +0100
Message-Id: <1391520540-17436-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1391520540-17436-1-git-send-email-mhocko@suse.cz>
References: <1391520540-17436-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

The current core of memcg charging is wild to say the least.
__mem_cgroup_try_charge which is in the center tries to be too clever
and it handles two independent cases
	* when the memcg to be charged is known in advance
	* when the given mm_struct is charged
The resulting callchains are quite complex:

memcg_charge_kmem(mm=NULL, memcg)  mem_cgroup_newpage_charge(mm)
 |                                | _________________________________________ mem_cgroup_cache_charge(current->mm)
 |                                |/                                            |
 | ______________________________ mem_cgroup_charge_common(mm, memcg=NULL)      |
 |/                                                                             /
 |                                                                             /
 | ____________________________ mem_cgroup_try_charge_swapin(mm, memcg=NULL)  /
 |/                               | _________________________________________/
 |                                |/
 |                                |                         /* swap accounting */   /* no swap accounting */
 | _____________________________  __mem_cgroup_try_charge_swapin(mm=NULL, memcg) || (mm, memcg=NULL)
 |/
 | ____________________________ mem_cgroup_do_precharge(mm=NULL, memcg)
 |/
__mem_cgroup_try_charge
  mem_cgroup_do_charge
    res_counter_charge
    mem_cgroup_reclaim
    mem_cgroup_wait_acct_move
    mem_cgroup_oom

This patch splits __mem_cgroup_try_charge into two logical parts.
mem_cgroup_try_charge_mm which is responsible for charges for the given
mm_struct and it returns the charged memcg or NULL under OOM while
mem_cgroup_try_charge_memcg charges a known memcg and returns an error
code.

The only tricky part which remains is __mem_cgroup_try_charge_swapin
because it can return 0 if PageCgroupUsed is already set and then we do
not want to commit the charge. This is done with a magic combination of
memcg = NULL and ret = 0. So the function preserves its memcgp parameter
and sets the given memcg to NULL when it sees PageCgroupUsed
(__mem_cgroup_commit_charge_swapin then ignores such a commit).

Not only the code is easier to follow the change reduces the code size
too:
size mm/built-in.o.before mm/built-in.o.after
   text    data     bss     dec     hex filename
464718   83038   49904  597660   91e9c mm/built-in.o.before
463894   83038   49904  596836   91b64 mm/built-in.o.after

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 205 +++++++++++++++++++++++++++-----------------------------
 1 file changed, 98 insertions(+), 107 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 042e4ff36c05..72fbe0fb3320 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2618,7 +2618,7 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
 }
 
 
-/* See __mem_cgroup_try_charge() for details */
+/* See mem_cgroup_do_charge() for details */
 enum {
 	CHARGE_OK,		/* success */
 	CHARGE_RETRY,		/* need to retry but retry is not bad */
@@ -2691,108 +2691,69 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	return CHARGE_NOMEM;
 }
 
+static bool current_bypass_charge(void)
+{
+	/*
+	 * Unlike gloval-vm's OOM-kill, we're not in memory shortage
+	 * in system level. So, allow to go ahead dying process in addition to
+	 * MEMDIE process.
+	 */
+	if (unlikely(test_thread_flag(TIF_MEMDIE)
+		     || fatal_signal_pending(current)))
+		return true;
+
+	return false;
+}
+
 /*
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
+ * mem_cgroup_try_charge_memcg - core of the memcg charging code. The caller
+ * keeps a css reference to the given memcg. We do not charge root_mem_cgroup.
+ * OOM is triggered only if allowed by the given oom parameter (except for
+ * __GFP_NOFAIL when it is ignored).
  *
- * Unlike the exported interface, an "oom" parameter is added. if oom==true,
- * the oom-killer can be invoked.
+ * Returns 0 on success, -ENOMEM when the given memcg is under OOM and -EINTR
+ * when the charge is bypassed (either when fatal signals are pending or
+ * __GFP_NOFAIL allocation cannot be charged).
  */
-static int __mem_cgroup_try_charge(struct mm_struct *mm,
-				   gfp_t gfp_mask,
+static int mem_cgroup_try_charge_memcg(gfp_t gfp_mask,
 				   unsigned int nr_pages,
-				   struct mem_cgroup **ptr,
+				   struct mem_cgroup *memcg,
 				   bool oom)
 {
 	unsigned int batch = max(CHARGE_BATCH, nr_pages);
 	int nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
-	struct mem_cgroup *memcg = NULL;
 	int ret;
 
-	/*
-	 * Unlike gloval-vm's OOM-kill, we're not in memory shortage
-	 * in system level. So, allow to go ahead dying process in addition to
-	 * MEMDIE process.
-	 */
-	if (unlikely(test_thread_flag(TIF_MEMDIE)
-		     || fatal_signal_pending(current)))
+	if (mem_cgroup_is_root(memcg) || current_bypass_charge())
 		goto bypass;
 
 	if (unlikely(task_in_memcg_oom(current)))
 		goto nomem;
 
+	if (consume_stock(memcg, nr_pages))
+		return 0;
+
 	if (gfp_mask & __GFP_NOFAIL)
 		oom = false;
 
-	/*
-	 * We always charge the cgroup the mm_struct belongs to.
-	 * The mm_struct's mem_cgroup changes on task migration if the
-	 * thread group leader migrates. It's possible that mm is not
-	 * set, if so charge the root memcg (happens for pagecache usage).
-	 */
-	if (!*ptr && !mm)
-		*ptr = root_mem_cgroup;
-again:
-	if (*ptr) { /* css should be a valid one */
-		memcg = *ptr;
-		if (mem_cgroup_is_root(memcg))
-			goto done;
-		if (consume_stock(memcg, nr_pages))
-			goto done;
-		css_get(&memcg->css);
-	} else {
-		memcg = try_get_mem_cgroup_from_mm(mm);
-		if (!memcg) {
-			memcg = root_mem_cgroup;
-			goto done;
-		}
-		if (mem_cgroup_is_root(memcg))
-			goto done_put;
-		if (consume_stock(memcg, nr_pages))
-			goto done_put;
-	}
-
 	do {
 		bool invoke_oom = oom && !nr_oom_retries;
 
 		/* If killed, bypass charge */
-		if (fatal_signal_pending(current)) {
-			css_put(&memcg->css);
+		if (fatal_signal_pending(current))
 			goto bypass;
-		}
 
 		ret = mem_cgroup_do_charge(memcg, gfp_mask, batch,
 					   nr_pages, invoke_oom);
 		switch (ret) {
-		case CHARGE_OK:
-			break;
 		case CHARGE_RETRY: /* not in OOM situation but retry */
 			batch = nr_pages;
-			css_put(&memcg->css);
-			memcg = NULL;
-			goto again;
+			break;
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
@@ -2800,22 +2761,51 @@ again:
 
 	if (batch > nr_pages)
 		refill_stock(memcg, batch - nr_pages);
-done_put:
-	css_put(&memcg->css);
-done:
-	*ptr = memcg;
+
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
 
 /*
+ * Charges and returns memcg associated with the given mm (or root_mem_cgroup
+ * if mm is NULL). Returns NULL if memcg is under OOM.
+ */
+static struct mem_cgroup *mem_cgroup_try_charge_mm(struct mm_struct *mm,
+				   gfp_t gfp_mask,
+				   unsigned int nr_pages,
+				   bool oom)
+{
+	struct mem_cgroup *memcg;
+	int ret;
+
+	/*
+	 * We always charge the cgroup the mm_struct belongs to.
+	 * The mm_struct's mem_cgroup changes on task migration if the
+	 * thread group leader migrates. It's possible that mm is not
+	 * set, if so charge the root memcg (happens for pagecache usage).
+	 */
+	if (!mm)
+		goto bypass;
+	memcg = try_get_mem_cgroup_from_mm(mm);
+	if (!memcg)
+		goto bypass;
+
+	ret = mem_cgroup_try_charge_memcg(gfp_mask, nr_pages, memcg, oom);
+	css_put(&memcg->css);
+	if (ret == -EINTR)
+		goto bypass;
+	else if (ret == -ENOMEM)
+		memcg = NULL;
+	return memcg;
+bypass:
+	return root_mem_cgroup;
+}
+
+/*
  * Somemtimes we have to undo a charge we got by try_charge().
  * This function is for that and do uncharge, put css's refcnt.
  * gotten by try_charge().
@@ -3010,21 +3000,19 @@ static int mem_cgroup_slabinfo_read(struct seq_file *m, void *v)
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
+	ret = mem_cgroup_try_charge_memcg(gfp, size >> PAGE_SHIFT,
+				      memcg, oom_gfp_allowed(gfp));
 
 	if (ret == -EINTR)  {
 		/*
-		 * __mem_cgroup_try_charge() chosed to bypass to root due to
-		 * OOM kill or fatal signal.  Since our only options are to
+		 * mem_cgroup_try_charge_memcg() chosed to bypass to root due
+		 * to OOM kill or fatal signal.  Since our only options are to
 		 * either fail the allocation or charge it to this cgroup, do
 		 * it as a temporary condition. But we can't fail. From a
 		 * kmem/slab perspective, the cache has already been selected,
@@ -3033,7 +3021,7 @@ static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
 		 *
 		 * This condition will only trigger if the task entered
 		 * memcg_charge_kmem in a sane state, but was OOM-killed during
-		 * __mem_cgroup_try_charge() above. Tasks that were already
+		 * mem_cgroup_try_charge_memcg() above. Tasks that were already
 		 * dying when the allocation triggers should have been already
 		 * directed to the root cgroup in memcontrol.h
 		 */
@@ -3906,10 +3894,9 @@ out:
 static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask, enum charge_type ctype)
 {
-	struct mem_cgroup *memcg = NULL;
+	struct mem_cgroup *memcg;
 	unsigned int nr_pages = 1;
 	bool oom = true;
-	int ret;
 
 	if (PageTransHuge(page)) {
 		nr_pages <<= compound_order(page);
@@ -3921,9 +3908,9 @@ static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
 		oom = false;
 	}
 
-	ret = __mem_cgroup_try_charge(mm, gfp_mask, nr_pages, &memcg, oom);
-	if (ret == -ENOMEM)
-		return ret;
+	memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, nr_pages, oom);
+	if (!memcg)
+		return -ENOMEM;
 	__mem_cgroup_commit_charge(memcg, page, nr_pages, ctype, false);
 	return 0;
 }
@@ -3947,8 +3934,7 @@ int mem_cgroup_newpage_charge(struct page *page,
  * "commit()" or removed by "cancel()"
  */
 static int __mem_cgroup_try_charge_swapin(struct mm_struct *mm,
-					  struct page *page,
-					  gfp_t mask,
+					  struct page *page, gfp_t mask,
 					  struct mem_cgroup **memcgp)
 {
 	struct mem_cgroup *memcg;
@@ -3962,31 +3948,36 @@ static int __mem_cgroup_try_charge_swapin(struct mm_struct *mm,
 	 * already charged pages, too.  The USED bit is protected by
 	 * the page lock, which serializes swap cache removal, which
 	 * in turn serializes uncharging.
+	 * Have to set memcg to NULL so that __mem_cgroup_commit_charge_swapin
+	 * will ignore such a page.
 	 */
-	if (PageCgroupUsed(pc))
+	if (PageCgroupUsed(pc)) {
+		*memcgp = NULL;
 		return 0;
+	}
 	if (!do_swap_account)
 		goto charge_cur_mm;
 	memcg = try_get_mem_cgroup_from_page(page);
 	if (!memcg)
 		goto charge_cur_mm;
 	*memcgp = memcg;
-	ret = __mem_cgroup_try_charge(NULL, mask, 1, memcgp, true);
+	ret = mem_cgroup_try_charge_memcg(mask, 1, memcg, true);
 	css_put(&memcg->css);
-	if (ret == -EINTR)
+	if (ret == -EINTR) {
+		*memcgp = root_mem_cgroup;
 		ret = 0;
+	}
 	return ret;
 charge_cur_mm:
-	ret = __mem_cgroup_try_charge(mm, mask, 1, memcgp, true);
-	if (ret == -EINTR)
-		ret = 0;
-	return ret;
+	*memcgp = mem_cgroup_try_charge_mm(mm, mask, 1, true);
+	if (!*memcgp)
+		return -ENOMEM;
+	return 0;
 }
 
 int mem_cgroup_try_charge_swapin(struct mm_struct *mm, struct page *page,
 				 gfp_t gfp_mask, struct mem_cgroup **memcgp)
 {
-	*memcgp = NULL;
 	if (mem_cgroup_disabled())
 		return 0;
 	/*
@@ -3996,13 +3987,14 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm, struct page *page,
 	 * there's also a KSM case which does need to charge the page.
 	 */
 	if (!PageSwapCache(page)) {
-		int ret;
+		int ret = 0;
 
-		ret = __mem_cgroup_try_charge(mm, gfp_mask, 1, memcgp, true);
-		if (ret == -EINTR)
-			ret = 0;
+		*memcgp = mem_cgroup_try_charge_mm(mm, gfp_mask, 1, true);
+		if (!*memcgp)
+			ret = -ENOMEM;
 		return ret;
 	}
+
 	return __mem_cgroup_try_charge_swapin(mm, page, gfp_mask, memcgp);
 }
 
@@ -4048,7 +4040,6 @@ void mem_cgroup_commit_charge_swapin(struct page *page,
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask)
 {
-	struct mem_cgroup *memcg = NULL;
 	enum charge_type type = MEM_CGROUP_CHARGE_TYPE_CACHE;
 	int ret;
 
@@ -4060,6 +4051,7 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 	if (!PageSwapCache(page))
 		ret = mem_cgroup_charge_common(page, mm, gfp_mask, type);
 	else { /* page is swapcache/shmem */
+		struct mem_cgroup *memcg;
 		ret = __mem_cgroup_try_charge_swapin(mm, page,
 						     gfp_mask, &memcg);
 		if (!ret)
@@ -6671,8 +6663,7 @@ one_by_one:
 			batch_count = PRECHARGE_COUNT_AT_ONCE;
 			cond_resched();
 		}
-		ret = __mem_cgroup_try_charge(NULL,
-					GFP_KERNEL, 1, &memcg, false);
+		ret = mem_cgroup_try_charge_memcg(GFP_KERNEL, 1, memcg, false);
 		if (ret)
 			/* mem_cgroup_clear_mc() will do uncharge later */
 			return ret;
-- 
1.9.rc1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
