Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 129536B003C
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 21:58:58 -0400 (EDT)
Message-ID: <51BA7808.10004@huawei.com>
Date: Fri, 14 Jun 2013 09:55:20 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH v4 7/9] memcg: don't need to get a reference to the parent
References: <51BA7794.2000305@huawei.com>
In-Reply-To: <51BA7794.2000305@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

The cgroup core guarantees it's always safe to access the parent.

v2:
- added a comment in mem_cgroup_put() as suggested by Michal
- removed mem_cgroup_get(), otherwise gcc will warn that it's not used

Signed-off-by: Li Zefan <lizefan@huawei.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c | 19 +++----------------
 1 file changed, 3 insertions(+), 16 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a63d9f1..443fb45 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -513,7 +513,6 @@ enum res_type {
  */
 static DEFINE_MUTEX(memcg_create_mutex);
 
-static void mem_cgroup_get(struct mem_cgroup *memcg);
 static void mem_cgroup_put(struct mem_cgroup *memcg);
 
 static inline
@@ -6210,19 +6209,10 @@ static void free_rcu(struct rcu_head *rcu_head)
 	schedule_work(&memcg->work_freeing);
 }
 
-static void mem_cgroup_get(struct mem_cgroup *memcg)
-{
-	atomic_inc(&memcg->refcnt);
-}
-
 static void __mem_cgroup_put(struct mem_cgroup *memcg, int count)
 {
-	if (atomic_sub_and_test(count, &memcg->refcnt)) {
-		struct mem_cgroup *parent = parent_mem_cgroup(memcg);
+	if (atomic_sub_and_test(count, &memcg->refcnt))
 		call_rcu(&memcg->rcu_freeing, free_rcu);
-		if (parent)
-			mem_cgroup_put(parent);
-	}
 }
 
 static void mem_cgroup_put(struct mem_cgroup *memcg)
@@ -6325,12 +6315,9 @@ mem_cgroup_css_online(struct cgroup *cont)
 		res_counter_init(&memcg->kmem, &parent->kmem);
 
 		/*
-		 * We increment refcnt of the parent to ensure that we can
-		 * safely access it on res_counter_charge/uncharge.
-		 * This refcnt will be decremented when freeing this
-		 * mem_cgroup(see mem_cgroup_put).
+		 * No need to take a reference to the parent because cgroup
+		 * core guarantees its existence.
 		 */
-		mem_cgroup_get(parent);
 	} else {
 		res_counter_init(&memcg->res, NULL);
 		res_counter_init(&memcg->memsw, NULL);
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
