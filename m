Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id BBFAF6B0033
	for <linux-mm@kvack.org>; Fri, 17 May 2013 03:06:00 -0400 (EDT)
Message-ID: <5195D6A4.8060109@huawei.com>
Date: Fri, 17 May 2013 15:05:08 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 8/9] memcg: kill memcg refcnt
References: <5195D5F8.7000609@huawei.com>
In-Reply-To: <5195D5F8.7000609@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

Now memcg has the same life cycle as its corresponding cgroup.
Kill the useless refcnt.

Signed-off-by: Li Zefan <lizefan@huawei.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c | 18 +-----------------
 1 file changed, 1 insertion(+), 17 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c6d267a..348126a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -303,8 +303,6 @@ struct mem_cgroup {
 	bool		oom_lock;
 	atomic_t	under_oom;
 
-	atomic_t	refcnt;
-
 	int	swappiness;
 	/* OOM-Killer disable */
 	int		oom_kill_disable;
@@ -508,8 +506,6 @@ enum res_type {
  */
 static DEFINE_MUTEX(memcg_create_mutex);
 
-static void mem_cgroup_put(struct mem_cgroup *memcg);
-
 static inline
 struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
 {
@@ -6170,17 +6166,6 @@ static void free_rcu(struct rcu_head *rcu_head)
 	schedule_work(&memcg->work_freeing);
 }
 
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
@@ -6240,7 +6225,6 @@ mem_cgroup_css_alloc(struct cgroup *cont)
 
 	memcg->last_scanned_node = MAX_NUMNODES;
 	INIT_LIST_HEAD(&memcg->oom_notify);
-	atomic_set(&memcg->refcnt, 1);
 	memcg->move_charge_at_immigrate = 0;
 	mutex_init(&memcg->thresholds_lock);
 	spin_lock_init(&memcg->move_lock);
@@ -6332,7 +6316,7 @@ static void mem_cgroup_css_free(struct cgroup *cont)
 
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
