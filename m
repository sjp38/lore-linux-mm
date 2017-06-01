Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 90D746B02B4
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 14:36:23 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b86so12097160wmi.6
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 11:36:23 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id z56si23615186edc.200.2017.06.01.11.36.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 11:36:22 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [RFC PATCH v2 3/7] mm, oom: export oom_evaluate_task() and select_bad_process()
Date: Thu, 1 Jun 2017 19:35:11 +0100
Message-ID: <1496342115-3974-4-git-send-email-guro@fb.com>
In-Reply-To: <1496342115-3974-1-git-send-email-guro@fb.com>
References: <1496342115-3974-1-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Export the oom_evaluate_task() and select_bad_process()
functions to reuse them for victim selection logic
in the cgroup-aware OOM killer.

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
 include/linux/oom.h | 3 +++
 mm/oom_kill.c       | 5 ++---
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 47d9495..edf7a77 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -80,6 +80,9 @@ extern void oom_killer_enable(void);
 extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 
 extern void __oom_kill_process(struct task_struct *victim);
+extern int oom_evaluate_task(struct task_struct *task, void *arg);
+extern void select_bad_process(struct oom_control *oc,
+			       struct mem_cgroup *memcg);
 
 /* sysctls */
 extern int sysctl_oom_dump_tasks;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 11b60a5..8cf77fb 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -288,7 +288,7 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc)
 	return CONSTRAINT_NONE;
 }
 
-static int oom_evaluate_task(struct task_struct *task, void *arg)
+int oom_evaluate_task(struct task_struct *task, void *arg)
 {
 	struct oom_control *oc = arg;
 	unsigned long points;
@@ -343,8 +343,7 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
  * Simple selection loop. We choose the process with the highest number of
  * 'points'. In case scan was aborted, oc->chosen is set to -1.
  */
-static void select_bad_process(struct oom_control *oc,
-			       struct mem_cgroup *memcg)
+void select_bad_process(struct oom_control *oc, struct mem_cgroup *memcg)
 {
 	if (memcg)
 		mem_cgroup_scan_tasks(memcg, oom_evaluate_task, oc);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
