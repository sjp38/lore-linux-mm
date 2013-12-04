Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id 66CC76B003C
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 00:20:21 -0500 (EST)
Received: by mail-yh0-f51.google.com with SMTP id c41so9484616yho.38
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 21:20:21 -0800 (PST)
Received: from mail-yh0-x22e.google.com (mail-yh0-x22e.google.com [2607:f8b0:4002:c01::22e])
        by mx.google.com with ESMTPS id u45si45370071yhc.3.2013.12.03.21.20.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Dec 2013 21:20:20 -0800 (PST)
Received: by mail-yh0-f46.google.com with SMTP id l109so10867417yhq.5
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 21:20:20 -0800 (PST)
Date: Tue, 3 Dec 2013 21:20:17 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 7/8] mm, memcg: allow processes handling oom notifications
 to access reserves
In-Reply-To: <alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1312032118570.29733@chino.kir.corp.google.com>
References: <20131119131400.GC20655@dhcp22.suse.cz> <20131119134007.GD20655@dhcp22.suse.cz> <alpine.DEB.2.02.1311192352070.20752@chino.kir.corp.google.com> <20131120152251.GA18809@dhcp22.suse.cz> <alpine.DEB.2.02.1311201917520.7167@chino.kir.corp.google.com>
 <20131128115458.GK2761@dhcp22.suse.cz> <alpine.DEB.2.02.1312021504170.13465@chino.kir.corp.google.com> <alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

Now that a per-process flag is available, define it for processes that
handle userspace oom notifications.  This is an optimization to avoid
mantaining a list of such processes attached to a memcg at any given time
and iterating it at charge time.

This flag gets set whenever a process has registered for an oom
notification and is cleared whenever it unregisters.

When memcg reclaim has failed to free any memory, it is necessary for
userspace oom handlers to be able to dip into reserves to pagefault text,
allocate kernel memory to read the "tasks" file, allocate heap, etc.

System oom conditions are not addressed at this time, but the same per-
process flag can be used in the page allocator to determine if access
should be given to userspace oom handlers to per-zone memory reserves at
a later time once there is consensus.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/sched.h |  1 +
 mm/memcontrol.c       | 47 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 47 insertions(+), 1 deletion(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1695,6 +1695,7 @@ extern void thread_group_cputime_adjusted(struct task_struct *p, cputime_t *ut,
 #define PF_SPREAD_SLAB	0x02000000	/* Spread some slab caches over cpuset */
 #define PF_NO_SETAFFINITY 0x04000000	/* Userland is not allowed to meddle with cpus_allowed */
 #define PF_MCE_EARLY    0x08000000      /* Early kill for mce process policy */
+#define PF_OOM_HANDLER	0x10000000	/* Userspace process handling oom conditions */
 #define PF_MUTEX_TESTER	0x20000000	/* Thread belongs to the rt mutex tester */
 #define PF_FREEZER_SKIP	0x40000000	/* Freezer should not count it as freezable */
 #define PF_SUSPEND_TASK 0x80000000      /* this thread called freeze_processes and should not be frozen */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2590,6 +2590,33 @@ enum {
 	CHARGE_WOULDBLOCK,	/* GFP_WAIT wasn't set and no enough res. */
 };
 
+/*
+ * Processes handling oom conditions are allowed to utilize memory reserves so
+ * that they may handle the condition.
+ */
+static int mem_cgroup_oom_handler_charge(struct mem_cgroup *memcg,
+					 unsigned long csize,
+					 struct mem_cgroup **mem_over_limit)
+{
+	struct res_counter *fail_res;
+	int ret;
+
+	ret = res_counter_charge_nofail_max(&memcg->res, csize, &fail_res,
+					    memcg->oom_reserve);
+	if (!ret && do_swap_account) {
+		ret = res_counter_charge_nofail_max(&memcg->memsw, csize,
+						    &fail_res,
+						    memcg->oom_reserve);
+		if (ret) {
+			res_counter_uncharge(&memcg->res, csize);
+			*mem_over_limit = mem_cgroup_from_res_counter(fail_res,
+								      memsw);
+
+		}
+	}
+	return !ret ? CHARGE_OK : CHARGE_NOMEM;
+}
+
 static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 				unsigned int nr_pages, unsigned int min_pages,
 				bool invoke_oom)
@@ -2649,6 +2676,13 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	if (mem_cgroup_wait_acct_move(mem_over_limit))
 		return CHARGE_RETRY;
 
+	if (current->flags & PF_OOM_HANDLER) {
+		ret = mem_cgroup_oom_handler_charge(memcg, csize,
+						    &mem_over_limit);
+		if (ret == CHARGE_OK)
+			return CHARGE_OK;
+	}
+
 	if (invoke_oom)
 		mem_cgroup_oom(mem_over_limit, gfp_mask, get_order(csize));
 
@@ -2696,7 +2730,8 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 		     || fatal_signal_pending(current)))
 		goto bypass;
 
-	if (unlikely(task_in_memcg_oom(current)))
+	if (unlikely(task_in_memcg_oom(current)) &&
+	    !(current->flags & PF_OOM_HANDLER))
 		goto bypass;
 
 	/*
@@ -5825,6 +5860,11 @@ static int mem_cgroup_oom_register_event(struct cgroup_subsys_state *css,
 	if (!event)
 		return -ENOMEM;
 
+	/*
+	 * Setting PF_OOM_HANDLER before taking memcg_oom_lock ensures it is
+	 * set before getting added to memcg->oom_notify.
+	 */
+	current->flags |= PF_OOM_HANDLER;
 	spin_lock(&memcg_oom_lock);
 
 	event->eventfd = eventfd;
@@ -5856,6 +5896,11 @@ static void mem_cgroup_oom_unregister_event(struct cgroup_subsys_state *css,
 		}
 	}
 
+	/*
+	 * Clearing PF_OOM_HANDLER before dropping memcg_oom_lock ensures it is
+	 * cleared before receiving another notification.
+	 */
+	current->flags &= ~PF_OOM_HANDLER;
 	spin_unlock(&memcg_oom_lock);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
