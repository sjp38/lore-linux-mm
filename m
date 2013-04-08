Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 36E4B6B009B
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 02:38:23 -0400 (EDT)
Message-ID: <51626570.8000400@huawei.com>
Date: Mon, 8 Apr 2013 14:36:32 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 12/12] memcg: don't need to free memcg via RCU or workqueue
References: <5162648B.9070802@huawei.com>
In-Reply-To: <5162648B.9070802@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>

Now memcg has the same life cycle with its corresponding cgroup, and
a cgroup is freed via RCU and then mem_cgroup_css_free() is called
in a work function, so we can simply call __mem_cgroup_free() in
mem_cgroup_css_free().

This actually reverts 59927fb984de1703c67bc640c3e522d8b5276c73
("memcg: free mem_cgroup by RCU to fix oops").

Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 mm/memcontrol.c | 51 +++++----------------------------------------------
 1 file changed, 5 insertions(+), 46 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a6d44bc..5aa6e91 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -261,28 +261,10 @@ struct mem_cgroup {
 	 */
 	struct res_counter res;
 
-	union {
-		/*
-		 * the counter to account for mem+swap usage.
-		 */
-		struct res_counter memsw;
-
-		/*
-		 * rcu_freeing is used only when freeing struct mem_cgroup,
-		 * so put it into a union to avoid wasting more memory.
-		 * It must be disjoint from the css field.  It could be
-		 * in a union with the res field, but res plays a much
-		 * larger part in mem_cgroup life than memsw, and might
-		 * be of interest, even at time of free, when debugging.
-		 * So share rcu_head with the less interesting memsw.
-		 */
-		struct rcu_head rcu_freeing;
-		/*
-		 * We also need some space for a worker in deferred freeing.
-		 * By the time we call it, rcu_freeing is no longer in use.
-		 */
-		struct work_struct work_freeing;
-	};
+	/*
+	 * the counter to account for mem+swap usage.
+	 */
+	struct res_counter memsw;
 
 	/*
 	 * the counter to account for kernel memory usage.
@@ -6097,29 +6079,6 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 		vfree(memcg);
 }
 
-
-/*
- * Helpers for freeing a kmalloc()ed/vzalloc()ed mem_cgroup by RCU,
- * but in process context.  The work_freeing structure is overlaid
- * on the rcu_freeing structure, which itself is overlaid on memsw.
- */
-static void free_work(struct work_struct *work)
-{
-	struct mem_cgroup *memcg;
-
-	memcg = container_of(work, struct mem_cgroup, work_freeing);
-	__mem_cgroup_free(memcg);
-}
-
-static void free_rcu(struct rcu_head *rcu_head)
-{
-	struct mem_cgroup *memcg;
-
-	memcg = container_of(rcu_head, struct mem_cgroup, rcu_freeing);
-	INIT_WORK(&memcg->work_freeing, free_work);
-	schedule_work(&memcg->work_freeing);
-}
-
 /*
  * Returns the parent mem_cgroup in memcgroup hierarchy with hierarchy enabled.
  */
@@ -6269,7 +6228,7 @@ static void mem_cgroup_css_free(struct cgroup *cont)
 
 	mem_cgroup_sockets_destroy(memcg);
 
-	call_rcu(&memcg->rcu_freeing, free_rcu);
+	__mem_cgroup_free(memcg);
 }
 
 #ifdef CONFIG_MMU
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
