Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id F06D06B000A
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 08:11:02 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 5/5] memcg: do not walk all the way to the root for memcg
Date: Tue,  5 Mar 2013 17:10:58 +0400
Message-Id: <1362489058-3455-6-git-send-email-glommer@parallels.com>
In-Reply-To: <1362489058-3455-1-git-send-email-glommer@parallels.com>
References: <1362489058-3455-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, handai.szj@gmail.com, anton.vorontsov@linaro.org, Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

Since the root is special anyway, and we always get its figures from
global counters anyway, there is no make all cgroups its descendants,
wrt res_counters. The sad effect of doing that is that we need to lock
the root for all allocations, since it is a common ancestor of
everybody.

Not having the root as a common ancestor should lead to better
scalability for not-uncommon case of tasks in the cgroup being
node-bound to different nodes in NUMA systems.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Mel Gorman <mgorman@suse.de>
CC: Andrew Morton <akpm@linux-foundation.org>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6019a32..252dc00 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6464,7 +6464,7 @@ mem_cgroup_css_online(struct cgroup *cont)
 	memcg->oom_kill_disable = parent->oom_kill_disable;
 	memcg->swappiness = mem_cgroup_swappiness(parent);
 
-	if (parent->use_hierarchy) {
+	if (parent && !mem_cgroup_is_root(parent) && parent->use_hierarchy) {
 		res_counter_init(&memcg->res, &parent->res);
 		res_counter_init(&memcg->memsw, &parent->memsw);
 		res_counter_init(&memcg->kmem, &parent->kmem);
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
