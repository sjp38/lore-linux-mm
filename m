Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0EB876B0255
	for <linux-mm@kvack.org>; Sun, 13 Sep 2015 15:00:12 -0400 (EDT)
Received: by qgev79 with SMTP id v79so99810135qge.0
        for <linux-mm@kvack.org>; Sun, 13 Sep 2015 12:00:11 -0700 (PDT)
Received: from mail-qk0-x236.google.com (mail-qk0-x236.google.com. [2607:f8b0:400d:c09::236])
        by mx.google.com with ESMTPS id p72si9063263qkh.25.2015.09.13.12.00.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Sep 2015 12:00:11 -0700 (PDT)
Received: by qkfq186 with SMTP id q186so50629302qkf.1
        for <linux-mm@kvack.org>; Sun, 13 Sep 2015 12:00:10 -0700 (PDT)
Date: Sun, 13 Sep 2015 15:00:08 -0400
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH v3 2/2] memcg: punt high overage reclaim to
 return-to-userland path
Message-ID: <20150913190008.GB25369@htj.duckdns.org>
References: <20150913185940.GA25369@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150913185940.GA25369@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@kernel.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

Currently, try_charge() tries to reclaim memory synchronously when the
high limit is breached; however, if the allocation doesn't have
__GFP_WAIT, synchronous reclaim is skipped.  If a process performs
only speculative allocations, it can blow way past the high limit.
This is actually easily reproducible by simply doing "find /".
slab/slub allocator tries speculative allocations first, so as long as
there's memory which can be consumed without blocking, it can keep
allocating memory regardless of the high limit.

This patch makes try_charge() always punt the over-high reclaim to the
return-to-userland path.  If try_charge() detects that high limit is
breached, it adds the overage to current->memcg_nr_pages_over_high and
schedules execution of mem_cgroup_handle_over_high() which performs
synchronous reclaim from the return-to-userland path.

As long as kernel doesn't have a run-away allocation spree, this
should provide enough protection while making kmemcg behave more
consistently.  It also has the following benefits.

- All over-high reclaims can use GFP_KERNEL regardless of the specific
  gfp mask in use, e.g. GFP_NOFS, when the limit was breached.

- It copes with prio inversion.  Previously, a low-prio task with
  small memory.high might perform over-high reclaim with a bunch of
  locks held.  If a higher prio task needed any of these locks, it
  would have to wait until the low prio task finished reclaim and
  released the locks.  By handing over-high reclaim to the task exit
  path this issue can be avoided.

v3: - Description updated.

v2: - Switched to reclaiming only the overage caused by current rather
      than the difference between usage and high as suggested by
      Michal.
    - Don't record the memcg which went over high limit.  This makes
      exit path handling unnecessary.  Dropped.
    - Drop mentions of avoiding high stack usage from description as
      suggested by Vladimir.  max limit still triggers direct reclaim.

Signed-off-by: Tejun Heo <tj@kernel.org>
Acked-by: Michal Hocko <mhocko@kernel.org>
Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |    6 +++++
 include/linux/sched.h      |    3 ++
 include/linux/tracehook.h  |    3 ++
 mm/memcontrol.c            |   47 +++++++++++++++++++++++++++++++++++++--------
 4 files changed, 51 insertions(+), 8 deletions(-)

--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -402,6 +402,8 @@ static inline int mem_cgroup_inactive_an
 	return inactive * inactive_ratio < active;
 }
 
+void mem_cgroup_handle_over_high(void);
+
 void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 				struct task_struct *p);
 
@@ -621,6 +623,10 @@ static inline void mem_cgroup_end_page_s
 {
 }
 
+static inline void mem_cgroup_handle_over_high(void)
+{
+}
+
 static inline void mem_cgroup_oom_enable(void)
 {
 }
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1787,6 +1787,9 @@ struct task_struct {
 	struct mem_cgroup *memcg_in_oom;
 	gfp_t memcg_oom_gfp_mask;
 	int memcg_oom_order;
+
+	/* number of pages to reclaim on returning to userland */
+	unsigned int memcg_nr_pages_over_high;
 #endif
 #ifdef CONFIG_UPROBES
 	struct uprobe_task *utask;
--- a/include/linux/tracehook.h
+++ b/include/linux/tracehook.h
@@ -50,6 +50,7 @@
 #include <linux/ptrace.h>
 #include <linux/security.h>
 #include <linux/task_work.h>
+#include <linux/memcontrol.h>
 struct linux_binprm;
 
 /*
@@ -188,6 +189,8 @@ static inline void tracehook_notify_resu
 	smp_mb__after_atomic();
 	if (unlikely(current->task_works))
 		task_work_run();
+
+	mem_cgroup_handle_over_high();
 }
 
 #endif	/* <linux/tracehook.h> */
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -62,6 +62,7 @@
 #include <linux/oom.h>
 #include <linux/lockdep.h>
 #include <linux/file.h>
+#include <linux/tracehook.h>
 #include "internal.h"
 #include <net/sock.h>
 #include <net/ip.h>
@@ -1963,6 +1964,31 @@ static int memcg_cpu_hotplug_callback(st
 	return NOTIFY_OK;
 }
 
+/*
+ * Scheduled by try_charge() to be executed from the userland return path
+ * and reclaims memory over the high limit.
+ */
+void mem_cgroup_handle_over_high(void)
+{
+	unsigned int nr_pages = current->memcg_nr_pages_over_high;
+	struct mem_cgroup *memcg, *pos;
+
+	if (likely(!nr_pages))
+		return;
+
+	pos = memcg = get_mem_cgroup_from_mm(current->mm);
+
+	do {
+		if (page_counter_read(&pos->memory) <= pos->high)
+			continue;
+		mem_cgroup_events(pos, MEMCG_HIGH, 1);
+		try_to_free_mem_cgroup_pages(pos, nr_pages, GFP_KERNEL, true);
+	} while ((pos = parent_mem_cgroup(pos)));
+
+	css_put(&memcg->css);
+	current->memcg_nr_pages_over_high = 0;
+}
+
 static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		      unsigned int nr_pages)
 {
@@ -2071,17 +2097,22 @@ done_restock:
 	css_get_many(&memcg->css, batch);
 	if (batch > nr_pages)
 		refill_stock(memcg, batch - nr_pages);
-	if (!(gfp_mask & __GFP_WAIT))
-		goto done;
+
 	/*
-	 * If the hierarchy is above the normal consumption range,
-	 * make the charging task trim their excess contribution.
+	 * If the hierarchy is above the normal consumption range, schedule
+	 * reclaim on returning to userland.  We can perform reclaim here
+	 * if __GFP_WAIT but let's always punt for simplicity and so that
+	 * GFP_KERNEL can consistently be used during reclaim.  @memcg is
+	 * not recorded as it most likely matches current's and won't
+	 * change in the meantime.  As high limit is checked again before
+	 * reclaim, the cost of mismatch is negligible.
 	 */
 	do {
-		if (page_counter_read(&memcg->memory) <= memcg->high)
-			continue;
-		mem_cgroup_events(memcg, MEMCG_HIGH, 1);
-		try_to_free_mem_cgroup_pages(memcg, nr_pages, gfp_mask, true);
+		if (page_counter_read(&memcg->memory) > memcg->high) {
+			current->memcg_nr_pages_over_high += nr_pages;
+			set_notify_resume(current);
+			break;
+		}
 	} while ((memcg = parent_mem_cgroup(memcg)));
 done:
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
