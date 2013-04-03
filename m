Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 263CB6B00CE
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 05:13:39 -0400 (EDT)
Message-ID: <515BF2B1.9060909@huawei.com>
Date: Wed, 3 Apr 2013 17:13:21 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 6/7] memcg: don't need to get a reference to the parent
References: <515BF233.6070308@huawei.com>
In-Reply-To: <515BF233.6070308@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

The cgroup core guarantees it's always safe to access the parent.

Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 mm/memcontrol.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ad576e8..45129cd 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6124,12 +6124,8 @@ static void mem_cgroup_get(struct mem_cgroup *memcg)
 
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
@@ -6229,14 +6225,6 @@ mem_cgroup_css_online(struct cgroup *cont)
 		res_counter_init(&memcg->res, &parent->res);
 		res_counter_init(&memcg->memsw, &parent->memsw);
 		res_counter_init(&memcg->kmem, &parent->kmem);
-
-		/*
-		 * We increment refcnt of the parent to ensure that we can
-		 * safely access it on res_counter_charge/uncharge.
-		 * This refcnt will be decremented when freeing this
-		 * mem_cgroup(see mem_cgroup_put).
-		 */
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
