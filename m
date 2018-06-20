Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id AF4346B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 06:37:46 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o15-v6so1941818wmf.1
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 03:37:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r9-v6sor1015487eda.39.2018.06.20.03.37.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Jun 2018 03:37:44 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH] memcg, oom: move out_of_memory back to the charge path
Date: Wed, 20 Jun 2018 12:37:36 +0200
Message-Id: <20180620103736.13880-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

3812c8c8f395 ("mm: memcg: do not trap chargers with full callstack on OOM")
has changed the ENOMEM semantic of memcg charges. Rather than invoking
the oom killer from the charging context it delays the oom killer to the
page fault path (pagefault_out_of_memory). This in turn means that many
users (e.g. slab or g-u-p) will get ENOMEM when the corresponding memcg
hits the hard limit and the memcg is is OOM. This is behavior is
inconsistent with !memcg case where the oom killer is invoked from the
allocation context and the allocator keeps retrying until it succeeds.

The difference in the behavior is user visible. mmap(MAP_POPULATE) might
result in not fully populated ranges while the mmap return code doesn't
tell that to the userspace. Random syscalls might fail with ENOMEM etc.

The primary motivation of the different memcg oom semantic was the
deadlock avoidance. Things have changed since then, though. We have
an async oom teardown by the oom reaper now and so we do not have to
rely on the victim to tear down its memory anymore. Therefore we can
return to the original semantic as long as the memcg oom killer is not
handed over to the users space.

There is still one thing to be careful about here though. If the oom
killer is not able to make any forward progress - e.g. because there is
no eligible task to kill - then we have to bail out of the charge path
to prevent from same class of deadlocks. We have basically two options
here. Either we fail the charge with ENOMEM or force the charge and
allow overcharge. The first option has been considered more harmful than
useful because rare inconsistencies in the ENOMEM behavior is hard to
test for and error prone. Basically the same reason why the page
allocator doesn't fail allocations under such conditions. The later
might allow runaways but those should be really unlikely unless somebody
misconfigures the system. E.g. allowing to migrate tasks away from the
memcg to a different unlimited memcg with move_charge_at_immigrate
disabled.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
we have discussed this at LSFMM this year and my recollection is that
we have agreed that we should do this. So I am sending the patch as an
RFC. Please note I have only forward ported the patch without any
testing yet. I would like to see a general agreement before I spend more
time on this.

Thoughts? Objections?

 mm/memcontrol.c | 67 +++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 56 insertions(+), 11 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e6f0d5ef320a..7fe3ce1fd625 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1483,28 +1483,54 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
 		__wake_up(&memcg_oom_waitq, TASK_NORMAL, 0, memcg);
 }
 
-static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
+enum oom_status {
+	OOM_SUCCESS,
+	OOM_FAILED,
+	OOM_ASYNC,
+	OOM_SKIPPED
+};
+
+static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
 {
-	if (!current->memcg_may_oom || order > PAGE_ALLOC_COSTLY_ORDER)
-		return;
+	if (order > PAGE_ALLOC_COSTLY_ORDER)
+		return OOM_SKIPPED;
 	/*
 	 * We are in the middle of the charge context here, so we
 	 * don't want to block when potentially sitting on a callstack
 	 * that holds all kinds of filesystem and mm locks.
 	 *
-	 * Also, the caller may handle a failed allocation gracefully
-	 * (like optional page cache readahead) and so an OOM killer
-	 * invocation might not even be necessary.
+	 * cgroup1 allows disabling the OOM killer and waiting for outside
+	 * handling until the charge can succeed; remember the context and put
+	 * the task to sleep at the end of the page fault when all locks are
+	 * released.
+	 *
+	 * On the other hand, in-kernel OOM killer allows for an async victim
+	 * memory reclaim (oom_reaper) and that means that we are not solely
+	 * relying on the oom victim to make a forward progress and we can
+	 * invoke the oom killer here.
 	 *
-	 * That's why we don't do anything here except remember the
-	 * OOM context and then deal with it at the end of the page
-	 * fault when the stack is unwound, the locks are released,
-	 * and when we know whether the fault was overall successful.
+	 * Please note that mem_cgroup_oom_synchronize might fail to find a
+	 * victim and then we have rely on mem_cgroup_oom_synchronize otherwise
+	 * we would fall back to the global oom killer in pagefault_out_of_memory
 	 */
+	if (!memcg->oom_kill_disable) {
+		if (mem_cgroup_out_of_memory(memcg, mask, order))
+			return OOM_SUCCESS;
+
+		WARN(!current->memcg_may_oom,
+				"Memory cgroup charge failed because of no reclaimable memory! "
+				"This looks like a misconfiguration or a kernel bug.");
+		return OOM_FAILED;
+	}
+
+	if (!current->memcg_may_oom)
+		return OOM_SKIPPED;
 	css_get(&memcg->css);
 	current->memcg_in_oom = memcg;
 	current->memcg_oom_gfp_mask = mask;
 	current->memcg_oom_order = order;
+
+	return OOM_ASYNC;
 }
 
 /**
@@ -1899,6 +1925,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	unsigned long nr_reclaimed;
 	bool may_swap = true;
 	bool drained = false;
+	bool oomed = false;
 
 	if (mem_cgroup_is_root(memcg))
 		return 0;
@@ -1986,6 +2013,9 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	if (nr_retries--)
 		goto retry;
 
+	if (gfp_mask & __GFP_RETRY_MAYFAIL && oomed)
+		goto nomem;
+
 	if (gfp_mask & __GFP_NOFAIL)
 		goto force;
 
@@ -1994,8 +2024,23 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 
 	memcg_memory_event(mem_over_limit, MEMCG_OOM);
 
-	mem_cgroup_oom(mem_over_limit, gfp_mask,
+	/*
+	 * keep retrying as long as the memcg oom killer is able to make
+	 * a forward progress or bypass the charge if the oom killer
+	 * couldn't make any progress.
+	 */
+	oom_status = mem_cgroup_oom(mem_over_limit, gfp_mask,
 		       get_order(nr_pages * PAGE_SIZE));
+	switch (oom_status) {
+	case OOM_SUCCESS:
+		nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
+		oomed = true;
+		goto retry;
+	case OOM_FAILED:
+		goto force;
+	default:
+		goto nomem;
+	}
 nomem:
 	if (!(gfp_mask & __GFP_NOFAIL))
 		return -ENOMEM;
-- 
2.17.1
