Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 4F7D06B0010
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 05:55:02 -0500 (EST)
Message-ID: <510658FC.50009@oracle.com>
Date: Mon, 28 Jan 2013 18:54:52 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: [PATCH v2 6/6] memcg: init/free swap cgroup strucutres upon create/free
 child memcg
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org

Initialize swap_cgroup strucutres when creating a non-root memcg,
swap_cgroup_init() will be called for multiple times but only does
buffer allocation per the first non-root memcg.

Free swap_cgroup structures correspondingly on the last non-root memcg
removal.

Signed-off-by: Jie Liu <jeff.liu@oracle.com>
CC: Glauber Costa <glommer@parallels.com>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Mel Gorman <mgorman@suse.de>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Sha Zhengju <handai.szj@taobao.com>

---
 mm/memcontrol.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index afe5e86..031d242 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5998,6 +5998,7 @@ static void free_work(struct work_struct *work)
 
 	memcg = container_of(work, struct mem_cgroup, work_freeing);
 	__mem_cgroup_free(memcg);
+	swap_cgroup_free();
 }
 
 static void free_rcu(struct rcu_head *rcu_head)
@@ -6116,6 +6117,8 @@ mem_cgroup_css_alloc(struct cgroup *cont)
 			INIT_WORK(&stock->work, drain_local_stock);
 		}
 	} else {
+		if (swap_cgroup_init())
+			goto free_out;
 		parent = mem_cgroup_from_cont(cont->parent);
 		memcg->use_hierarchy = parent->use_hierarchy;
 		memcg->oom_kill_disable = parent->oom_kill_disable;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
