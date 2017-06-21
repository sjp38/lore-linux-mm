Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F4076B02FD
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 17:20:14 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s74so169795603pfe.10
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 14:20:14 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 7si15318238pll.337.2017.06.21.14.20.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 14:20:12 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [v3 3/6] mm, oom: cgroup-aware OOM killer debug info
Date: Wed, 21 Jun 2017 22:19:13 +0100
Message-ID: <1498079956-24467-4-git-send-email-guro@fb.com>
In-Reply-To: <1498079956-24467-1-git-send-email-guro@fb.com>
References: <1498079956-24467-1-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Dump the cgroup oom badness score, as well as the name
of chosen victim cgroup.

Here how it looks like in dmesg:
[   18.824495] Choosing a victim memcg because of the system-wide OOM
[   18.826911] Cgroup /A1: 200805
[   18.827996] Cgroup /A2: 273072
[   18.828937] Cgroup /A2/B3: 51
[   18.829795] Cgroup /A2/B4: 272969
[   18.830800] Cgroup /A2/B5: 52
[   18.831890] Chosen cgroup /A2/B4: 272969

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: kernel-team@fb.com
Cc: cgroups@vger.kernel.org
Cc: linux-doc@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 mm/memcontrol.c | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index bdb5103..4face20 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2669,7 +2669,15 @@ bool mem_cgroup_select_oom_victim(struct oom_control *oc)
 
 	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
 		return false;
+
+	pr_info("Choosing a victim memcg because of the %s",
+		oc->memcg ?
+		"memory limit reached of cgroup " :
+		"system-wide OOM\n");
 	if (oc->memcg) {
+		pr_cont_cgroup_path(oc->memcg->css.cgroup);
+		pr_cont("\n");
+
 		chosen_memcg = oc->memcg;
 		parent = oc->memcg;
 	}
@@ -2683,6 +2691,10 @@ bool mem_cgroup_select_oom_victim(struct oom_control *oc)
 
 			points = mem_cgroup_oom_badness(iter, oc->nodemask);
 
+			pr_info("Cgroup ");
+			pr_cont_cgroup_path(iter->css.cgroup);
+			pr_cont(": %ld\n", points);
+
 			if (points > chosen_memcg_points) {
 				chosen_memcg = iter;
 				chosen_memcg_points = points;
@@ -2731,6 +2743,10 @@ bool mem_cgroup_select_oom_victim(struct oom_control *oc)
 			oc->chosen_memcg = chosen_memcg;
 		}
 
+		pr_info("Chosen cgroup ");
+		pr_cont_cgroup_path(chosen_memcg->css.cgroup);
+		pr_cont(": %ld\n", oc->chosen_points);
+
 		/*
 		 * Even if we have to kill all tasks in the cgroup,
 		 * we need to select the biggest task to start with.
@@ -2739,7 +2755,9 @@ bool mem_cgroup_select_oom_victim(struct oom_control *oc)
 		 */
 		oc->chosen_points = 0;
 		mem_cgroup_scan_tasks(chosen_memcg, oom_evaluate_task, oc);
-	}
+	} else if (oc->chosen)
+		pr_info("Chosen task %s (%d) in root cgroup: %ld\n",
+			oc->chosen->comm, oc->chosen->pid, oc->chosen_points);
 
 	rcu_read_unlock();
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
