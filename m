Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF178C31E5D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 16:00:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A891208CB
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 16:00:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ob/UZNpG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A891208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0ED6A6B0007; Mon, 17 Jun 2019 12:00:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09F1A8E0002; Mon, 17 Jun 2019 12:00:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E80CF8E0001; Mon, 17 Jun 2019 12:00:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id B44E96B0007
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 12:00:04 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id x18so5085969otp.9
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 09:00:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=6OF/I8mViVS6VwGoK9t/TkowxaH44NQujziCKAFpMDc=;
        b=XuyfZWUHEGtv1XUzg1BemaYKkQq2zJoKEn0jwy4tjCTyIOGVme3nbYA/JIwgoxYP9W
         fzGQkwnXqyOSpxkHkK3MqXC7cLN+Vi/Nn1vZ1k3tnzPHfiCfGXgnPqRfuaGmZpKLMCSt
         fk04oyA/ob6ZdSyVm/YaakHYYMX4YdXlP8KPYSW20w9vGbHzOZ4GndMGo/MawlWbOZBj
         HUTuFL95FLpceoKKTudJgSVFCGB1tO5VYitBp72CIiSGlxzoLAYQAe6r9Xc+rC1QAl6J
         oAppHUUxGJR+KI94PKYehjOLPg0S3Sr8HUsTCUnRZ48a2hpGB13w8HVTdVPZdIRhfli3
         zXqA==
X-Gm-Message-State: APjAAAWhobyk1UFs/248udXmmruZNs7ESJMCr/rnENzN8mKME+0TmOZH
	rOTRowlSKnWPnHsn2lgr3PA/HgmB/AimujWCw/9PKGr6YCAjDwVRsag8XTOd8Zajxhq0csHdDPE
	AWjT7vNgH6wG2AUWpmlODtw7gqa7SKnLqioMojdgLcSj4beszvu8SfkNidB4kAE1h+Q==
X-Received: by 2002:aca:ef42:: with SMTP id n63mr10889489oih.177.1560787204190;
        Mon, 17 Jun 2019 09:00:04 -0700 (PDT)
X-Received: by 2002:aca:ef42:: with SMTP id n63mr10889439oih.177.1560787203258;
        Mon, 17 Jun 2019 09:00:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560787203; cv=none;
        d=google.com; s=arc-20160816;
        b=KLft+qnwbhtNpCfsXc9EeA2nomV/IcQqjtPJjpCi+Byr6pj7GSTluGerZtOzvqqYnx
         Vo8Emk3IxCQgfj3WrPNRxn6o90I0Ln4g+q4GlW9M91m45SdkUizWBcR4QRe2Z5reSZDj
         cOY6zz2LbB3dGHcgvyHINlDWhvKF7LXZDMnCqGOpM+ykmO4bOJQ+CFqnX+OqfSIAUMzF
         cT5m4LG/Z456FQNWwaDJmRljWL3rdp4ZDCb3IryiN/U3ZyFW1V2v2dlalzyk485h49W5
         cPLpZh5x8l4z0p0T9bQB0ns5rdJ5GtKUZuTYa+tENQez+qFhp3teQpk9S+9MxjIaZjdd
         tMEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=6OF/I8mViVS6VwGoK9t/TkowxaH44NQujziCKAFpMDc=;
        b=RMUywjEFPMmzG21oyWhULVGkGVXmOmu0ytaPfz0vtVRZdLDS/oEtQDL2vSqXZjsnhI
         rtw912bZxbDylIJ3P9LdFOZbT6J6nmn0hnkfaWOO4HvCcPh6eiuxR6PTQ1AT6W+hGH9a
         Pt1NwQMh+xnt/bbwlr2hmt1deQaX7lKaHazWjBslqn12/+Yx+JKjPbqGgXqeelysRlRK
         o4KVtkUbFskEEBQXV+de4BHeNhjSei8REsXAtT8b/oOmOyFtf3AsTkTELIshoF8oVPpt
         eZiWxj9c1GwH0c4NJNOYtwmKbskLvjJqb0ADKiBI4roXO2c79qVY4kJvxm1JxOeYxEry
         7FDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="ob/UZNpG";
       spf=pass (google.com: domain of 3arkhxqgkciexmfpjjqglttlqj.htrqnsz2-rrp0fhp.twl@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3ArkHXQgKCIExmfpjjqglttlqj.htrqnsz2-rrp0fhp.twl@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id a131sor4488484oib.73.2019.06.17.09.00.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 09:00:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3arkhxqgkciexmfpjjqglttlqj.htrqnsz2-rrp0fhp.twl@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="ob/UZNpG";
       spf=pass (google.com: domain of 3arkhxqgkciexmfpjjqglttlqj.htrqnsz2-rrp0fhp.twl@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3ArkHXQgKCIExmfpjjqglttlqj.htrqnsz2-rrp0fhp.twl@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=6OF/I8mViVS6VwGoK9t/TkowxaH44NQujziCKAFpMDc=;
        b=ob/UZNpGxGPuF0OzSr4yeSWfIhOdnYSQGvAhj9DxsKpWZaLHEMyF+kLANJU5hFdcvW
         0dl8fnSbB4XcNXABqAjMH4UDEZvd/s1ql9mumUa+KVBf6QAUN7ay18H/v5sbj5OGz9Br
         +fVmQEkyUjwCYAgpqwHLsiJB37ZJojWELK5ziJ3+1+DCvkgsq0po/LlG/rmE7BBt2SUq
         UwqNJ/F6t0lmPzthj1U0o87GNOmVAuViobWjvZ6c7F5lJe0DjYepiF4XWlRgvm10JdBv
         nJkd+aiEenu+daU8g5bnkoWD+JOBlJFc8bEkQAJzjZn3o0DTakI6KihKzku0iZeFKuTk
         HM/A==
X-Google-Smtp-Source: APXvYqw79N91taxJtuNvC4ql7FsQuNTdHnWvRgS0qX8lER0ovOxErjWwzD8UXKz0aKsJ1UGmr1SZtb87+JnEEw==
X-Received: by 2002:aca:cc8e:: with SMTP id c136mr11155223oig.18.1560787202795;
 Mon, 17 Jun 2019 09:00:02 -0700 (PDT)
Date: Mon, 17 Jun 2019 08:59:54 -0700
Message-Id: <20190617155954.155791-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH] mm, oom: fix oom_unkillable_task for memcg OOMs
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, 
	Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently oom_unkillable_task() checks mems_allowed even for memcg OOMs
which does not make sense as memcg OOMs can not be triggered due to
numa constraints. Fixing that.

Also if memcg is given, oom_unkillable_task() will check the task's
memcg membership as well to detect oom killability. However all the
memcg related code paths leading to oom_unkillable_task(), other than
dump_tasks(), come through mem_cgroup_scan_tasks() which traverses
tasks through memcgs. Once dump_tasks() is converted to use
mem_cgroup_scan_tasks(), there is no need to do memcg membership check
in oom_unkillable_task().

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 fs/proc/base.c      |   3 +-
 include/linux/oom.h |   3 +-
 mm/oom_kill.c       | 100 +++++++++++++++++++++++++-------------------
 3 files changed, 60 insertions(+), 46 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index b8d5d100ed4a..69b0d1b6583d 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -532,8 +532,7 @@ static int proc_oom_score(struct seq_file *m, struct pid_namespace *ns,
 	unsigned long totalpages = totalram_pages() + total_swap_pages;
 	unsigned long points = 0;
 
-	points = oom_badness(task, NULL, NULL, totalpages) *
-					1000 / totalpages;
+	points = oom_badness(task, NULL, totalpages) * 1000 / totalpages;
 	seq_printf(m, "%lu\n", points);
 
 	return 0;
diff --git a/include/linux/oom.h b/include/linux/oom.h
index d07992009265..39c42caa3231 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -108,8 +108,7 @@ static inline vm_fault_t check_stable_address_space(struct mm_struct *mm)
 bool __oom_reap_task_mm(struct mm_struct *mm);
 
 extern unsigned long oom_badness(struct task_struct *p,
-		struct mem_cgroup *memcg, const nodemask_t *nodemask,
-		unsigned long totalpages);
+		struct oom_control *oc, unsigned long totalpages);
 
 extern bool out_of_memory(struct oom_control *oc);
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 05aaa1a5920b..47ded0e07e98 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -152,20 +152,25 @@ static inline bool is_memcg_oom(struct oom_control *oc)
 }
 
 /* return true if the task is not adequate as candidate victim task. */
-static bool oom_unkillable_task(struct task_struct *p,
-		struct mem_cgroup *memcg, const nodemask_t *nodemask)
+static bool oom_unkillable_task(struct task_struct *p, struct oom_control *oc)
 {
 	if (is_global_init(p))
 		return true;
 	if (p->flags & PF_KTHREAD)
 		return true;
+	if (!oc)
+		return false;
 
-	/* When mem_cgroup_out_of_memory() and p is not member of the group */
-	if (memcg && !task_in_mem_cgroup(p, memcg))
-		return true;
+	/*
+	 * For memcg OOM, we reach here through mem_cgroup_scan_tasks(), no
+	 * need to check p's membership. Also the following checks are
+	 * irrelevant to memcg OOMs.
+	 */
+	if (is_memcg_oom(oc))
+		return false;
 
 	/* p may not have freeable memory in nodemask */
-	if (!has_intersects_mems_allowed(p, nodemask))
+	if (!has_intersects_mems_allowed(p, oc->nodemask))
 		return true;
 
 	return false;
@@ -193,21 +198,20 @@ static bool is_dump_unreclaim_slabs(void)
 /**
  * oom_badness - heuristic function to determine which candidate task to kill
  * @p: task struct of which task we should calculate
+ * @oc: pointer to struct oom_control
  * @totalpages: total present RAM allowed for page allocation
- * @memcg: task's memory controller, if constrained
- * @nodemask: nodemask passed to page allocator for mempolicy ooms
  *
  * The heuristic for determining which task to kill is made to be as simple and
  * predictable as possible.  The goal is to return the highest value for the
  * task consuming the most memory to avoid subsequent oom failures.
  */
-unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
-			  const nodemask_t *nodemask, unsigned long totalpages)
+unsigned long oom_badness(struct task_struct *p, struct oom_control *oc,
+			  unsigned long totalpages)
 {
 	long points;
 	long adj;
 
-	if (oom_unkillable_task(p, memcg, nodemask))
+	if (oom_unkillable_task(p, oc))
 		return 0;
 
 	p = find_lock_task_mm(p);
@@ -318,7 +322,7 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	struct oom_control *oc = arg;
 	unsigned long points;
 
-	if (oom_unkillable_task(task, NULL, oc->nodemask))
+	if (oom_unkillable_task(task, oc))
 		goto next;
 
 	/*
@@ -342,7 +346,7 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 		goto select;
 	}
 
-	points = oom_badness(task, NULL, oc->nodemask, oc->totalpages);
+	points = oom_badness(task, oc, oc->totalpages);
 	if (!points || points < oc->chosen_points)
 		goto next;
 
@@ -385,10 +389,38 @@ static void select_bad_process(struct oom_control *oc)
 	oc->chosen_points = oc->chosen_points * 1000 / oc->totalpages;
 }
 
+static int dump_task(struct task_struct *p, void *arg)
+{
+	struct oom_control *oc = arg;
+	struct task_struct *task;
+
+	if (oom_unkillable_task(p, oc))
+		return 0;
+
+	task = find_lock_task_mm(p);
+	if (!task) {
+		/*
+		 * This is a kthread or all of p's threads have already
+		 * detached their mm's.  There's no need to report
+		 * them; they can't be oom killed anyway.
+		 */
+		return 0;
+	}
+
+	pr_info("[%7d] %5d %5d %8lu %8lu %8ld %8lu         %5hd %s\n",
+		task->pid, from_kuid(&init_user_ns, task_uid(task)),
+		task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
+		mm_pgtables_bytes(task->mm),
+		get_mm_counter(task->mm, MM_SWAPENTS),
+		task->signal->oom_score_adj, task->comm);
+	task_unlock(task);
+
+	return 0;
+}
+
 /**
  * dump_tasks - dump current memory state of all system tasks
- * @memcg: current's memory controller, if constrained
- * @nodemask: nodemask passed to page allocator for mempolicy ooms
+ * @oc: pointer to struct oom_control
  *
  * Dumps the current memory state of all eligible tasks.  Tasks not in the same
  * memcg, not in the same cpuset, or bound to a disjoint set of mempolicy nodes
@@ -396,37 +428,21 @@ static void select_bad_process(struct oom_control *oc)
  * State information includes task's pid, uid, tgid, vm size, rss,
  * pgtables_bytes, swapents, oom_score_adj value, and name.
  */
-static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
+static void dump_tasks(struct oom_control *oc)
 {
-	struct task_struct *p;
-	struct task_struct *task;
-
 	pr_info("Tasks state (memory values in pages):\n");
 	pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
-	rcu_read_lock();
-	for_each_process(p) {
-		if (oom_unkillable_task(p, memcg, nodemask))
-			continue;
 
-		task = find_lock_task_mm(p);
-		if (!task) {
-			/*
-			 * This is a kthread or all of p's threads have already
-			 * detached their mm's.  There's no need to report
-			 * them; they can't be oom killed anyway.
-			 */
-			continue;
-		}
+	if (is_memcg_oom(oc))
+		mem_cgroup_scan_tasks(oc->memcg, dump_task, oc);
+	else {
+		struct task_struct *p;
 
-		pr_info("[%7d] %5d %5d %8lu %8lu %8ld %8lu         %5hd %s\n",
-			task->pid, from_kuid(&init_user_ns, task_uid(task)),
-			task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
-			mm_pgtables_bytes(task->mm),
-			get_mm_counter(task->mm, MM_SWAPENTS),
-			task->signal->oom_score_adj, task->comm);
-		task_unlock(task);
+		rcu_read_lock();
+		for_each_process(p)
+			dump_task(p, oc);
+		rcu_read_unlock();
 	}
-	rcu_read_unlock();
 }
 
 static void dump_oom_summary(struct oom_control *oc, struct task_struct *victim)
@@ -458,7 +474,7 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 			dump_unreclaimable_slab();
 	}
 	if (sysctl_oom_dump_tasks)
-		dump_tasks(oc->memcg, oc->nodemask);
+		dump_tasks(oc);
 	if (p)
 		dump_oom_summary(oc, p);
 }
@@ -1078,7 +1094,7 @@ bool out_of_memory(struct oom_control *oc)
 	check_panic_on_oom(oc, constraint);
 
 	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
-	    current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
+	    current->mm && !oom_unkillable_task(current, oc) &&
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
 		get_task_struct(current);
 		oc->chosen = current;
-- 
2.22.0.410.gd8fdbe21b5-goog

