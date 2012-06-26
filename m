Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id CE5D86B0072
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 11:50:08 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 2/2] memcg: first step towards hierarchical controller
Date: Tue, 26 Jun 2012 19:47:14 +0400
Message-Id: <1340725634-9017-3-git-send-email-glommer@parallels.com>
In-Reply-To: <1340725634-9017-1-git-send-email-glommer@parallels.com>
References: <1340725634-9017-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>

Okay, so after recent discussions, I am proposing the following
patch. It won't remove hierarchy, or anything like that. Just default
to true in the root cgroup, and print a warning once if you try
to set it back to 0.

I am not adding it to feature-removal-schedule.txt because I don't
view it as a consensus. Rather, changing the default would allow us
to give it a time around in the open, and see if people complain
and what we can learn about that.

Signed-off-by: Glauber Costa <glommer@parallels.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Tejun Heo <tj@kernel.org>
---
 mm/memcontrol.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 85f7790..c37e4c1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3993,6 +3993,10 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
 	if (memcg->use_hierarchy == val)
 		goto out;
 
+	WARN_ONCE(!parent_memcg && memcg->use_hierarchy,
+	"Non-hierarchical memcg is considered for deprecation\n"
+	"Please consider reorganizing your tree to work with hierarchical accounting\n"
+	"If you have any reason not to, let us know at cgroups@vger.kernel.org\n");
 	/*
 	 * If parent's use_hierarchy is set, we can't make any modifications
 	 * in the child subtrees. If it is unset, then the change can
@@ -5221,6 +5225,7 @@ mem_cgroup_create(struct cgroup *cont)
 			INIT_WORK(&stock->work, drain_local_stock);
 		}
 		hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
+		memcg->use_hierarchy = true;
 	} else {
 		parent = mem_cgroup_from_cont(cont->parent);
 		memcg->use_hierarchy = parent->use_hierarchy;
-- 
1.7.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
