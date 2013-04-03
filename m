Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id A80656B00D2
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 05:15:00 -0400 (EDT)
Message-ID: <515BF2E3.4000605@huawei.com>
Date: Wed, 3 Apr 2013 17:14:11 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 7/7] memcg: kill memcg refcnt
References: <515BF233.6070308@huawei.com>
In-Reply-To: <515BF233.6070308@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

Now memcg has the same life cycle as the corresponding cgroup.
Kill the useless refcnt.

Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 mm/memcontrol.c | 24 +-----------------------
 1 file changed, 1 insertion(+), 23 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 45129cd..9714a16 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -297,8 +297,6 @@ struct mem_cgroup {
 	bool		oom_lock;
 	atomic_t	under_oom;
 
-	atomic_t	refcnt;
-
 	int	swappiness;
 	/* OOM-Killer disable */
 	int		oom_kill_disable;
@@ -501,9 +499,6 @@ enum res_type {
  */
 static DEFINE_MUTEX(memcg_create_mutex);
 
-static void mem_cgroup_get(struct mem_cgroup *memcg);
-static void mem_cgroup_put(struct mem_cgroup *memcg);
-
 static inline
 struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
 {
@@ -6117,22 +6112,6 @@ static void free_rcu(struct rcu_head *rcu_head)
 	schedule_work(&memcg->work_freeing);
 }
 
-static void mem_cgroup_get(struct mem_cgroup *memcg)
-{
-	atomic_inc(&memcg->refcnt);
-}
-
-static void __mem_cgroup_put(struct mem_cgroup *memcg, int count)
-{
-	if (atomic_sub_and_test(count, &memcg->refcnt))
-		call_rcu(&memcg->rcu_freeing, free_rcu);
-}
-
-static void mem_cgroup_put(struct mem_cgroup *memcg)
-{
-	__mem_cgroup_put(memcg, 1);
-}
-
 /*
  * Returns the parent mem_cgroup in memcgroup hierarchy with hierarchy enabled.
  */
@@ -6192,7 +6171,6 @@ mem_cgroup_css_alloc(struct cgroup *cont)
 
 	memcg->last_scanned_node = MAX_NUMNODES;
 	INIT_LIST_HEAD(&memcg->oom_notify);
-	atomic_set(&memcg->refcnt, 1);
 	memcg->move_charge_at_immigrate = 0;
 	mutex_init(&memcg->thresholds_lock);
 	spin_lock_init(&memcg->move_lock);
@@ -6279,7 +6257,7 @@ static void mem_cgroup_css_free(struct cgroup *cont)
 
 	mem_cgroup_sockets_destroy(memcg);
 
-	mem_cgroup_put(memcg);
+	call_rcu(&memcg->rcu_freeing, free_rcu);
 }
 
 #ifdef CONFIG_MMU
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
