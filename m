Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8D68B6B0311
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 14:36:38 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s74so14838801pfe.10
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 11:36:38 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id l192si5713298pga.90.2017.06.01.11.36.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 11:36:37 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [RFC PATCH v2 1/7] mm, oom: refactor select_bad_process() to take memcg as an argument
Date: Thu, 1 Jun 2017 19:35:09 +0100
Message-ID: <1496342115-3974-2-git-send-email-guro@fb.com>
In-Reply-To: <1496342115-3974-1-git-send-email-guro@fb.com>
References: <1496342115-3974-1-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

The select_bad_process() function will be used further
to select a process to kill in the victim cgroup.
This cgroup doesn't necessary match oc->memcg,
which is a cgroup, which limits were caused cgroup-wide OOM
(or NULL in case of global OOM).

So, refactor select_bad_process() to take a pointer to
a cgroup to iterate over as an argument.

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
 mm/oom_kill.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 04c9143..f8b0fb1 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -343,10 +343,11 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
  * Simple selection loop. We choose the process with the highest number of
  * 'points'. In case scan was aborted, oc->chosen is set to -1.
  */
-static void select_bad_process(struct oom_control *oc)
+static void select_bad_process(struct oom_control *oc,
+			       struct mem_cgroup *memcg)
 {
-	if (is_memcg_oom(oc))
-		mem_cgroup_scan_tasks(oc->memcg, oom_evaluate_task, oc);
+	if (memcg)
+		mem_cgroup_scan_tasks(memcg, oom_evaluate_task, oc);
 	else {
 		struct task_struct *p;
 
@@ -1032,7 +1033,7 @@ bool out_of_memory(struct oom_control *oc)
 		return true;
 	}
 
-	select_bad_process(oc);
+	select_bad_process(oc, oc->memcg);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
 		dump_header(oc, NULL);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
