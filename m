Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1526E6B003A
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 08:29:14 -0500 (EST)
Received: by mail-we0-f174.google.com with SMTP id x55so4040207wes.5
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 05:29:14 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q6si6188362wic.40.2014.02.04.05.29.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 05:29:14 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH -v2 4/6] memcg: make sure that memcg is not offline when charging
Date: Tue,  4 Feb 2014 14:28:58 +0100
Message-Id: <1391520540-17436-5-git-send-email-mhocko@suse.cz>
In-Reply-To: <1391520540-17436-1-git-send-email-mhocko@suse.cz>
References: <1391520540-17436-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

The current charge path might race with memcg offlining because holding
css reference doesn't neither prevent from task move to a different
group nor stop css offline. When a charging task is the last one in the
group and it is moved to a different group in the middle of the charge
the old memcg might get offlined. As a result res counter might be
charged after mem_cgroup_reparent_charges (called from memcg css_offline
callback) and so the charge would never be freed. This has been worked
around by 96f1c58d8534 (mm: memcg: fix race condition between memcg
teardown and swapin) which tries to catch such a leaked charges later
during css_free. It is more optimal to heal this race in the long term
though.

In order to make this raceless we have to check that the memcg is online
and res_counter_charge in the same RCU read section. The online check can
be done simply by calling css_tryget & css_put which are now wrapped
into mem_cgroup_is_online helper.

Callers are then updated to retry with a new memcg which is associated
with the current mm. There always has to be a valid memcg encountered
sooner or later because task had to be moved to a valid and online
cgroup.

The only exception is mem_cgroup_do_precharge which should never see
this race because it is called from cgroup {can_}attach callbacks and so
the whole cgroup cannot go away.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 70 +++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 66 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2fcdee529ad3..d06743a9a765 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2624,8 +2624,31 @@ enum {
 	CHARGE_RETRY,		/* need to retry but retry is not bad */
 	CHARGE_NOMEM,		/* we can't do more. return -ENOMEM */
 	CHARGE_WOULDBLOCK,	/* GFP_WAIT wasn't set and no enough res. */
+	CHARGE_OFFLINE,		/* memcg is offline already so no further
+				 * charges are allowed
+				 */
 };
 
+/*
+ * Checks whether given memcg is still online (css_offline hasn't
+ * been called yet).
+ *
+ * Caller has to hold rcu read lock.
+ */
+static bool mem_cgroup_is_online(struct mem_cgroup *memcg)
+{
+	bool online;
+
+	rcu_read_lock_held();
+
+	online = css_tryget(&memcg->css);
+	if (online)
+		css_put(&memcg->css);
+
+	return online;
+
+}
+
 static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 				unsigned int nr_pages, unsigned int min_pages,
 				bool invoke_oom)
@@ -2636,20 +2659,37 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	unsigned long flags = 0;
 	int ret;
 
+	/*
+	 * Although the holder keeps a css reference for memcg this doesn't
+	 * prevent it from being offlined in the meantime. We have to make sure
+	 * that res counter is charged before css_offline reparents its pages
+	 * otherwise the charge might leak. Therefore both css_tryget has to
+	 * happen in the same rcu read section as res_counter charge.
+	 */
+	rcu_read_lock();
+	if (unlikely(!mem_cgroup_is_online(memcg))) {
+		rcu_read_unlock();
+		return CHARGE_OFFLINE;
+	}
 	ret = res_counter_charge(&memcg->res, csize, &fail_res);
-
 	if (likely(!ret)) {
-		if (!do_swap_account)
+		if (!do_swap_account) {
+			rcu_read_unlock();
 			return CHARGE_OK;
+		}
 		ret = res_counter_charge(&memcg->memsw, csize, &fail_res);
-		if (likely(!ret))
+		if (likely(!ret)) {
+			rcu_read_unlock();
 			return CHARGE_OK;
+		}
 
 		res_counter_uncharge(&memcg->res, csize);
 		mem_over_limit = mem_cgroup_from_res_counter(fail_res, memsw);
 		flags |= MEM_CGROUP_RECLAIM_NOSWAP;
 	} else
 		mem_over_limit = mem_cgroup_from_res_counter(fail_res, res);
+	rcu_read_unlock();
+
 	/*
 	 * Never reclaim on behalf of optional batching, retry with a
 	 * single page instead.
@@ -2756,6 +2796,12 @@ static int mem_cgroup_try_charge_memcg(gfp_t gfp_mask,
 				goto nomem;
 			nr_oom_retries--;
 			break;
+		/*
+		 * memcg went offline, the caller should fallback to
+		 * a different group.
+		 */
+		case CHARGE_OFFLINE:
+			return -EAGAIN;
 		}
 	} while (ret != CHARGE_OK);
 
@@ -2783,6 +2829,7 @@ static struct mem_cgroup *mem_cgroup_try_charge_mm(struct mm_struct *mm,
 	int ret;
 
 	VM_BUG_ON(!mm);
+again:
 	memcg = try_get_mem_cgroup_from_mm(mm);
 	if (!memcg)
 		goto bypass;
@@ -2793,6 +2840,8 @@ static struct mem_cgroup *mem_cgroup_try_charge_mm(struct mm_struct *mm,
 		goto bypass;
 	else if (ret == -ENOMEM)
 		memcg = NULL;
+	else if (ret == -EAGAIN)
+		goto again;
 	return memcg;
 bypass:
 	return root_mem_cgroup;
@@ -3617,6 +3666,7 @@ __memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **_memcg, int order)
 	if (!current->mm || current->memcg_kmem_skip_account)
 		return true;
 
+again:
 	memcg = try_get_mem_cgroup_from_mm(current->mm);
 
 	/*
@@ -3633,10 +3683,12 @@ __memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **_memcg, int order)
 	}
 
 	ret = memcg_charge_kmem(memcg, gfp, PAGE_SIZE << order);
+	css_put(&memcg->css);
 	if (!ret)
 		*_memcg = memcg;
+	else if (ret == -EAGAIN)
+		goto again;
 
-	css_put(&memcg->css);
 	return (ret == 0);
 }
 
@@ -3959,6 +4011,8 @@ static int __mem_cgroup_try_charge_swapin(struct mm_struct *mm,
 	if (ret == -EINTR) {
 		*memcgp = root_mem_cgroup;
 		ret = 0;
+	} else if (ret == -EAGAIN) {
+		goto charge_cur_mm;
 	}
 	return ret;
 charge_cur_mm:
@@ -6657,6 +6711,14 @@ one_by_one:
 			cond_resched();
 		}
 		ret = mem_cgroup_try_charge_memcg(GFP_KERNEL, 1, memcg, false);
+
+		/*
+		 * The target memcg cannot go offline because we are in
+		 * move path and cgroup core doesn't allow to offline
+		 * such groups.
+		 */
+		BUG_ON(ret == -EAGAIN);
+
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
