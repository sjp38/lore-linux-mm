Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C6EBC31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 23:12:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AEE882089E
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 23:12:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="jZfxRwku"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEE882089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F3648E0004; Mon, 17 Jun 2019 19:12:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A24B8E0001; Mon, 17 Jun 2019 19:12:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 091778E0004; Mon, 17 Jun 2019 19:12:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id DCC8F8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 19:12:19 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id g30so10720762qtm.17
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 16:12:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=TTbfAoCu4GcLQkkLsQIxh3IHCYFVhiWbbnmqLqGCZT0=;
        b=kYUgMO7Y+8+Hx6p1F7WIhpvyuGmiEKJkmkujLOp8XkM4x4W1istsT8yVolPQJXiZ7a
         NJVIRkkYsU6SJiuOCDlPkY/k0ExFlcT2VB1bC1KqfyTHyqJWmdCnODLWMC/yKkf9RJMM
         WzJ1WUZbwBOyiYKr4azmMv8c21VOrXAarW7bZi6UshOfq4HeaVMFGyHbpBMl3GaiKGBh
         YyZ1DhWx8fnDFlOqqbpQkEDb6aZiUKwx0o9e6UiQf35gwEW5yyiQ60YjmmMJXg4LEovx
         W4kwe1csFvdEHV9CMjNvScnXk41pjQ4KM3HptJerZDOwXPZjFeM46CCK9xd+96dh8EUY
         s5OA==
X-Gm-Message-State: APjAAAUDzQtDVu33lOHeX3cfGjSEGyZGoSVZacQlsFiS44WOUsxlN3Wh
	1lOg7jZ3ZpoZYPxukTerormd0Dqx51QZeomldeYsj47+HX8SrkbYY8Z+RC+fl+mCnfRg9xokbft
	j+GPYL4v2Xyj/vu3kPfoGDlzbbwfMOODDGgdeQMnuhLBSShwyZ21hJuxUP1W6zB0OFA==
X-Received: by 2002:a0c:b59c:: with SMTP id g28mr24707174qve.244.1560813139547;
        Mon, 17 Jun 2019 16:12:19 -0700 (PDT)
X-Received: by 2002:a0c:b59c:: with SMTP id g28mr24707139qve.244.1560813138913;
        Mon, 17 Jun 2019 16:12:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560813138; cv=none;
        d=google.com; s=arc-20160816;
        b=HEar1Hom7Zz7Sa8uC1LdL/pP52bB2B3ocati0JcpXRQfEylgaid26bu21TEzuVE6rU
         06tuTYucoLuw39Tbi4E0dY2QwyA/38h07km0X4VMVqj9yejRM72IoDtG88NShTlQZiCl
         o47r3+VC5Kguz45HVJW8izAtQS2lwhMgnItVhXt2wx7PvqR+h26uXJQq97pzcPj6lEu2
         Gxuw1JVD4x5tNCtNsCn891CTXwUHLSjpeh0dZGnCzao4JIKXOpPP1Z54uFJcXK+yKsag
         uZrGDqfqpa3JYjF4gkn2Bq1UjWXb+R9JrEngvownmnnT2V/dulggE8VryluWrJa0/+XI
         eShg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=TTbfAoCu4GcLQkkLsQIxh3IHCYFVhiWbbnmqLqGCZT0=;
        b=gaJUOkrV/YZiGFI6Lk14VWZK/F7wqucs1y47d7ib/cj1QUj0YWhLItuqEanGQLKtNk
         xLgyo1jFNzfSCnEzgjXS2iWIw5YZ6IIavxKB4DPXo7tHzABoJXKoRHJotzeMpyIVttqS
         jDqiEjB33mFVOplJGrclNGLaFXlYs/oB5JinxEPNN6fVsOz1cuPrBtXzdUjzxdxviXTo
         zZry8tMb7+ExwDTSRFlXh9cJqOtKx9ZId6ixo25ACw/KWcSYKFcmqXfjO+JW7PsqV0aM
         uuAdWzJneSu3fyj+ICg9Qh2wsLkFn1Rvj40n8E7Lj5Q4bq/D9trii1wHfjGuVYK1n2zp
         FuLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jZfxRwku;
       spf=pass (google.com: domain of 3uh4ixqgkcj0pe7hbbi8dlldib.9ljifkru-jjhs79h.lod@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Uh4IXQgKCJ0PE7HBBI8DLLDIB.9LJIFKRU-JJHS79H.LOD@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id z28sor4196639qtu.73.2019.06.17.16.12.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 16:12:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3uh4ixqgkcj0pe7hbbi8dlldib.9ljifkru-jjhs79h.lod@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jZfxRwku;
       spf=pass (google.com: domain of 3uh4ixqgkcj0pe7hbbi8dlldib.9ljifkru-jjhs79h.lod@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Uh4IXQgKCJ0PE7HBBI8DLLDIB.9LJIFKRU-JJHS79H.LOD@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=TTbfAoCu4GcLQkkLsQIxh3IHCYFVhiWbbnmqLqGCZT0=;
        b=jZfxRwkuPiIZFdGi8/rcF/0bUZMdwezu9vWxjpUUpRPuvxG5dw4JNY14gsHU9oJO7L
         5Ij05KVs3YqhUSK4gIWk7xpWLfYXFKMftiSRm/Mgqzn7g0EmryRy3F2zWB6hOQWfPRY/
         JlTfwaY6GRkIfoFywWkH69cSk8CbEx2ZgsPSAm37sfkCwaVzqIx7vOf58IUykipTNvNi
         oBlN9+odE31x0bFBwmGnoXtcusvTakGy0oF8zsTPvn+VP6/+vhFxO+qPt5Mq50KOZFVi
         UvttSwG9/I+2SkU2G5Q/7CvQfoEiGhjcidF4r4zlvCxa4iexnTrcJDXbiNWo9kJ4rcBV
         +EAA==
X-Google-Smtp-Source: APXvYqxzU6qeR8sKemK093KPas/vEHXa3zteT7sWEEHxpSEXDl1Y6eqEq1INAQbGNd3g0D1h3RhweCuzOwlhjg==
X-Received: by 2002:ac8:17f7:: with SMTP id r52mr98077354qtk.235.1560813138436;
 Mon, 17 Jun 2019 16:12:18 -0700 (PDT)
Date: Mon, 17 Jun 2019 16:12:06 -0700
Message-Id: <20190617231207.160865-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v2 1/2] mm, oom: refactor dump_tasks for memcg OOMs
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

dump_tasks() currently goes through all the processes present on the
system even for memcg OOMs. Change dump_tasks() similar to
select_bad_process() and use mem_cgroup_scan_tasks() to selectively
traverse the processes of the memcgs during memcg OOM.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
Changelog since v1:
- Divide the patch into two patches.

 mm/oom_kill.c | 68 ++++++++++++++++++++++++++++++---------------------
 1 file changed, 40 insertions(+), 28 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 05aaa1a5920b..bd80997e0969 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -385,10 +385,38 @@ static void select_bad_process(struct oom_control *oc)
 	oc->chosen_points = oc->chosen_points * 1000 / oc->totalpages;
 }
 
+static int dump_task(struct task_struct *p, void *arg)
+{
+	struct oom_control *oc = arg;
+	struct task_struct *task;
+
+	if (oom_unkillable_task(p, NULL, oc->nodemask))
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
@@ -396,37 +424,21 @@ static void select_bad_process(struct oom_control *oc)
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
@@ -458,7 +470,7 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 			dump_unreclaimable_slab();
 	}
 	if (sysctl_oom_dump_tasks)
-		dump_tasks(oc->memcg, oc->nodemask);
+		dump_tasks(oc);
 	if (p)
 		dump_oom_summary(oc, p);
 }
-- 
2.22.0.410.gd8fdbe21b5-goog

