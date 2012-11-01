Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id F38F76B009E
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 08:09:20 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v6 10/29] memcg: use static branches when code not in use
Date: Thu,  1 Nov 2012 16:07:26 +0400
Message-Id: <1351771665-11076-11-git-send-email-glommer@parallels.com>
In-Reply-To: <1351771665-11076-1-git-send-email-glommer@parallels.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

We can use static branches to patch the code in or out when not used.

Because the _ACTIVE bit on kmem_accounted is only set after the
increment is done, we guarantee that the root memcg will always be
selected for kmem charges until all call sites are patched (see
memcg_kmem_enabled).  This guarantees that no mischarges are applied.

static branch decrement happens when the last reference count from the
kmem accounting in memcg dies. This will only happen when the charges
drop down to 0.

When that happen, we need to disable the static branch only on those
memcgs that enabled it. To achieve this, we would be forced to
complicate the code by keeping track of which memcgs were the ones
that actually enabled limits, and which ones got it from its parents.

It is a lot simpler just to do static_key_slow_inc() on every child
that is accounted.

[ v4: adapted this patch to the changes in kmem_accounted ]

Signed-off-by: Glauber Costa <glommer@parallels.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
Acked-by: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Suleiman Souhlal <suleiman@google.com>
CC: Tejun Heo <tj@kernel.org>
---
 include/linux/memcontrol.h |  4 ++-
 mm/memcontrol.c            | 79 +++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 78 insertions(+), 5 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index e6ca1cf..2a2ae05 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -22,6 +22,7 @@
 #include <linux/cgroup.h>
 #include <linux/vm_event_item.h>
 #include <linux/hardirq.h>
+#include <linux/jump_label.h>
 
 struct mem_cgroup;
 struct page_cgroup;
@@ -410,9 +411,10 @@ static inline void sock_release_memcg(struct sock *sk)
 #endif /* CONFIG_INET && CONFIG_MEMCG_KMEM */
 
 #ifdef CONFIG_MEMCG_KMEM
+extern struct static_key memcg_kmem_enabled_key;
 static inline bool memcg_kmem_enabled(void)
 {
-	return true;
+	return static_key_false(&memcg_kmem_enabled_key);
 }
 
 /*
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 91a021a..403f5a7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -344,10 +344,13 @@ struct mem_cgroup {
 /* internal only representation about the status of kmem accounting. */
 enum {
 	KMEM_ACCOUNTED_ACTIVE = 0, /* accounted by this cgroup itself */
+	KMEM_ACCOUNTED_ACTIVATED, /* static key enabled. */
 	KMEM_ACCOUNTED_DEAD, /* dead memcg with pending kmem charges */
 };
 
-#define KMEM_ACCOUNTED_MASK (1 << KMEM_ACCOUNTED_ACTIVE)
+/* We account when limit is on, but only after call sites are patched */
+#define KMEM_ACCOUNTED_MASK \
+		((1 << KMEM_ACCOUNTED_ACTIVE) | (1 << KMEM_ACCOUNTED_ACTIVATED))
 
 #ifdef CONFIG_MEMCG_KMEM
 static inline void memcg_kmem_set_active(struct mem_cgroup *memcg)
@@ -360,6 +363,11 @@ static bool memcg_kmem_is_active(struct mem_cgroup *memcg)
 	return test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
 }
 
+static void memcg_kmem_set_activated(struct mem_cgroup *memcg)
+{
+	set_bit(KMEM_ACCOUNTED_ACTIVATED, &memcg->kmem_account_flags);
+}
+
 static void memcg_kmem_mark_dead(struct mem_cgroup *memcg)
 {
 	if (test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags))
@@ -530,6 +538,26 @@ static void disarm_sock_keys(struct mem_cgroup *memcg)
 }
 #endif
 
+#ifdef CONFIG_MEMCG_KMEM
+struct static_key memcg_kmem_enabled_key;
+
+static void disarm_kmem_keys(struct mem_cgroup *memcg)
+{
+	if (memcg_kmem_is_active(memcg))
+		static_key_slow_dec(&memcg_kmem_enabled_key);
+}
+#else
+static void disarm_kmem_keys(struct mem_cgroup *memcg)
+{
+}
+#endif /* CONFIG_MEMCG_KMEM */
+
+static void disarm_static_keys(struct mem_cgroup *memcg)
+{
+	disarm_sock_keys(memcg);
+	disarm_kmem_keys(memcg);
+}
+
 static void drain_all_stock_async(struct mem_cgroup *memcg);
 
 static struct mem_cgroup_per_zone *
@@ -4167,6 +4195,8 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
 {
 	int ret = -EINVAL;
 #ifdef CONFIG_MEMCG_KMEM
+	bool must_inc_static_branch = false;
+
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 	/*
 	 * For simplicity, we won't allow this to be disabled.  It also can't
@@ -4197,7 +4227,15 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
 		ret = res_counter_set_limit(&memcg->kmem, val);
 		VM_BUG_ON(ret);
 
-		memcg_kmem_set_active(memcg);
+		/*
+		 * After this point, kmem_accounted (that we test atomically in
+		 * the beginning of this conditional), is no longer 0. This
+		 * guarantees only one process will set the following boolean
+		 * to true. We don't need test_and_set because we're protected
+		 * by the set_limit_mutex anyway.
+		 */
+		memcg_kmem_set_activated(memcg);
+		must_inc_static_branch = true;
 		/*
 		 * kmem charges can outlive the cgroup. In the case of slab
 		 * pages, for instance, a page contain objects from various
@@ -4210,6 +4248,27 @@ static int memcg_update_kmem_limit(struct cgroup *cont, u64 val)
 out:
 	mutex_unlock(&set_limit_mutex);
 	cgroup_unlock();
+
+	/*
+	 * We are by now familiar with the fact that we can't inc the static
+	 * branch inside cgroup_lock. See disarm functions for details. A
+	 * worker here is overkill, but also wrong: After the limit is set, we
+	 * must start accounting right away. Since this operation can't fail,
+	 * we can safely defer it to here - no rollback will be needed.
+	 *
+	 * The boolean used to control this is also safe, because
+	 * KMEM_ACCOUNTED_ACTIVATED guarantees that only one process will be
+	 * able to set it to true;
+	 */
+	if (must_inc_static_branch) {
+		static_key_slow_inc(&memcg_kmem_enabled_key);
+		/*
+		 * setting the active bit after the inc will guarantee no one
+		 * starts accounting before all call sites are patched
+		 */
+		memcg_kmem_set_active(memcg);
+	}
+
 #endif
 	return ret;
 }
@@ -4221,8 +4280,20 @@ static void memcg_propagate_kmem(struct mem_cgroup *memcg)
 		return;
 	memcg->kmem_account_flags = parent->kmem_account_flags;
 #ifdef CONFIG_MEMCG_KMEM
-	if (memcg_kmem_is_active(memcg))
+	/*
+	 * When that happen, we need to disable the static branch only on those
+	 * memcgs that enabled it. To achieve this, we would be forced to
+	 * complicate the code by keeping track of which memcgs were the ones
+	 * that actually enabled limits, and which ones got it from its
+	 * parents.
+	 *
+	 * It is a lot simpler just to do static_key_slow_inc() on every child
+	 * that is accounted.
+	 */
+	if (memcg_kmem_is_active(memcg)) {
 		mem_cgroup_get(memcg);
+		static_key_slow_inc(&memcg_kmem_enabled_key);
+	}
 #endif
 }
 
@@ -5147,7 +5218,7 @@ static void free_work(struct work_struct *work)
 	 * to move this code around, and make sure it is outside
 	 * the cgroup_lock.
 	 */
-	disarm_sock_keys(memcg);
+	disarm_static_keys(memcg);
 	if (size < PAGE_SIZE)
 		kfree(memcg);
 	else
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
