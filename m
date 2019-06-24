Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 791A6C4646B
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:27:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FD9920663
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 21:27:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="nSpH5bFJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FD9920663
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3F616B0008; Mon, 24 Jun 2019 17:27:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF04E8E0003; Mon, 24 Jun 2019 17:27:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE0868E0002; Mon, 24 Jun 2019 17:27:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 750646B0008
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:27:08 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id k19so9768324pgl.0
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 14:27:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=jaauUWabecQwQ5Q70jIH+5Q73ClPU59UVRRBap690W4=;
        b=VLPIJNNrRJyEvNY13KXz8WnazAb//s53feO38GEO92wHeldCP6vYFGHM5HlpEZCDnV
         XzkTxmswQtAH54l/CMSiMRSEiNVj1EDYGReS87GB3q6bphhF9QstE76QfFQ/06FbDv1K
         TRfEpDCZDdZzeyzjpcAODUGUbIXlku+qXn0QLHN11/3U1jvk+lw08riZ9xskYDo4S6Mf
         vOkF99RCyynDbXEcLCirck46/JKYO3Mxbm6UZysJckc3lHMDQGoro1bwA8/blGH09bMK
         CBD3InuUbMg7VF3rwoUpvHoBEUNf+qNJP9TOE5xVx7yeZL+CSL8lK45/5y1oz01Ef1Zz
         bUtg==
X-Gm-Message-State: APjAAAV6P08/GHIWTwLqdGy6aTdelIVsrXgkDmteQQDuLBklEqanyGK6
	PXLNtQggO0NC4IRRIUGB75qJZvHD/jkXoCHNx41yNYn2giKOFWgudGqMDqYCqqseatiTx4rVKYL
	9Ui9qqv4v6pTps5ASjhulYOI9rHl0JVtcEwGW7tmreeBXpb0Rwos93OEcukHbvJ1j0Q==
X-Received: by 2002:a63:7749:: with SMTP id s70mr22520408pgc.242.1561411623399;
        Mon, 24 Jun 2019 14:27:03 -0700 (PDT)
X-Received: by 2002:a63:7749:: with SMTP id s70mr22520328pgc.242.1561411622288;
        Mon, 24 Jun 2019 14:27:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561411622; cv=none;
        d=google.com; s=arc-20160816;
        b=gNoyqhFKTVH5PuPJV8qGjv8m7XxIhD3EXKCgoaQe0Ebfe+9P1GUg6JhiAplbi4c+tf
         P6VjfDr0fmTDWccv0xycPdHAHY27JTFp/12LMqAbjwhA4QXVdte3HQvGLad1tNC7CBTO
         J4csFdLP5VNGVqdpi6wnZdHJCdfGjuQKIYiTAc0TOEkLB3uhusXb61iof3q4YnBdZAyE
         RxT6rPIzmJBqp4Z/rYWQXFyPiDo8u9tSPS/6PIGV0Rk/tUxXcWV7d2ANVdRQnz6qBnns
         2Oa9QYanpSeTriux4azDc7ltU9cs1cxGiWEsYQUXY0N0TnyS1gnenIgKIGD+tIgh7VcF
         pXhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=jaauUWabecQwQ5Q70jIH+5Q73ClPU59UVRRBap690W4=;
        b=moT3+9JIarpIeXxWRRKmR9BzpMD+styM7JhMsu5aCda/7vMMK6AjqHQF9fQNIHPLoJ
         Q//D1CzJ7g3CiwaakkMYBof14ocSpFhpotBIxHG9BXbPT0w5mbLl8OJPXI2Hqt35zjCh
         1cYYdGEQX4tD+vAblAqvubpDBhPtBmM0YL02PdbQ9ceGpnZyGkTpEICilOZeWSpSehlR
         5HrZdznVLAXjp6cd5RrL0PSSdeG/8iSABi1Cuus9G40nXcnoJ2ebVOez9AiTTh9FtmTf
         nt9uTRXb4xKSLBRTbfgDdy+9SLzTu1shrYNWPH9dC60QRKlnRyTB7aoY3zBPmX/S6F8V
         24sg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=nSpH5bFJ;
       spf=pass (google.com: domain of 3juarxqgkcngmb4e88f5aiiaf8.6igfchor-ggep46e.ila@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3JUARXQgKCNgMB4E88F5AIIAF8.6IGFCHOR-GGEP46E.ILA@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id y21sor7721619pfm.25.2019.06.24.14.27.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 14:27:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3juarxqgkcngmb4e88f5aiiaf8.6igfchor-ggep46e.ila@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=nSpH5bFJ;
       spf=pass (google.com: domain of 3juarxqgkcngmb4e88f5aiiaf8.6igfchor-ggep46e.ila@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3JUARXQgKCNgMB4E88F5AIIAF8.6IGFCHOR-GGEP46E.ILA@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=jaauUWabecQwQ5Q70jIH+5Q73ClPU59UVRRBap690W4=;
        b=nSpH5bFJw8ezGsmwSi2rzrMus3Anp17johkJQyAG2G7JqAbelPEdakMFH/NdyTRVMs
         /WANijmqB6eW00w3FD76Vz5V99NvA/I4Pc6f8GmNVCGaUu27vJOZ9K94Rb9Oe9og5O/F
         /nOQdJ/ZP8YHEC95IARa7HQAeD4lFqpQ26YotsUNWvKqgtcuy4lJyT5EXgbHyjuYRnl2
         xYzXwc17gUgxRiz2RXZjXE880Ewkd5JcotUXdCw/6a69vxVqyMrkU7QV/yrpNx7Jz/qw
         LwEwckhismEjUaUDYJ6YIN/zeUPdYbx8Q6FsfxYe1puMIqRTfmwB8U0HbhPkRZrZJ8/0
         s2Bg==
X-Google-Smtp-Source: APXvYqxTVYyeiEGbsAPD+rbQmU7OP+F2TEhzLPCSQtqirFtgy0xbSaaq9tQz4tKPecocEomfIoNzNROavMVt+w==
X-Received: by 2002:a63:8c0f:: with SMTP id m15mr12981076pgd.441.1561411621640;
 Mon, 24 Jun 2019 14:27:01 -0700 (PDT)
Date: Mon, 24 Jun 2019 14:26:30 -0700
In-Reply-To: <20190624212631.87212-1-shakeelb@google.com>
Message-Id: <20190624212631.87212-2-shakeelb@google.com>
Mime-Version: 1.0
References: <20190624212631.87212-1-shakeelb@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v3 2/3] mm, oom: remove redundant task_in_mem_cgroup() check
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, 
	KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, 
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Paul Jackson <pj@sgi.com>, 
	Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

oom_unkillable_task() can be called from three different contexts i.e.
global OOM, memcg OOM and oom_score procfs interface. At the moment
oom_unkillable_task() does a task_in_mem_cgroup() check on the given
process. Since there is no reason to perform task_in_mem_cgroup()
check for global OOM and oom_score procfs interface, those contexts
provide NULL memcg and skips the task_in_mem_cgroup() check. However for
memcg OOM context, the oom_unkillable_task() is always called from
mem_cgroup_scan_tasks() and thus task_in_mem_cgroup() check becomes
redundant. So, just remove the task_in_mem_cgroup() check altogether.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
Changelog since v2:
- Further divided the patch into two patches.
- Incorporated the task_in_mem_cgroup() from Tetsuo.

Changelog since v1:
- Divide the patch into two patches.

 fs/proc/base.c             |  2 +-
 include/linux/memcontrol.h |  7 -------
 include/linux/oom.h        |  2 +-
 mm/memcontrol.c            | 26 --------------------------
 mm/oom_kill.c              | 19 +++++++------------
 5 files changed, 9 insertions(+), 47 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index b8d5d100ed4a..5eacce5e924a 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -532,7 +532,7 @@ static int proc_oom_score(struct seq_file *m, struct pid_namespace *ns,
 	unsigned long totalpages = totalram_pages() + total_swap_pages;
 	unsigned long points = 0;
 
-	points = oom_badness(task, NULL, NULL, totalpages) *
+	points = oom_badness(task, NULL, totalpages) *
 					1000 / totalpages;
 	seq_printf(m, "%lu\n", points);
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 9abf31bbe53a..2cbce1fe7780 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -407,7 +407,6 @@ static inline struct lruvec *mem_cgroup_lruvec(struct pglist_data *pgdat,
 
 struct lruvec *mem_cgroup_page_lruvec(struct page *, struct pglist_data *);
 
-bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg);
 struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
 struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm);
@@ -896,12 +895,6 @@ static inline bool mm_match_cgroup(struct mm_struct *mm,
 	return true;
 }
 
-static inline bool task_in_mem_cgroup(struct task_struct *task,
-				      const struct mem_cgroup *memcg)
-{
-	return true;
-}
-
 static inline struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
 {
 	return NULL;
diff --git a/include/linux/oom.h b/include/linux/oom.h
index d07992009265..b75104690311 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -108,7 +108,7 @@ static inline vm_fault_t check_stable_address_space(struct mm_struct *mm)
 bool __oom_reap_task_mm(struct mm_struct *mm);
 
 extern unsigned long oom_badness(struct task_struct *p,
-		struct mem_cgroup *memcg, const nodemask_t *nodemask,
+		const nodemask_t *nodemask,
 		unsigned long totalpages);
 
 extern bool out_of_memory(struct oom_control *oc);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index db46a9dc37ab..27c92c2b99be 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1259,32 +1259,6 @@ void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
 		*lru_size += nr_pages;
 }
 
-bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg)
-{
-	struct mem_cgroup *task_memcg;
-	struct task_struct *p;
-	bool ret;
-
-	p = find_lock_task_mm(task);
-	if (p) {
-		task_memcg = get_mem_cgroup_from_mm(p->mm);
-		task_unlock(p);
-	} else {
-		/*
-		 * All threads may have already detached their mm's, but the oom
-		 * killer still needs to detect if they have already been oom
-		 * killed to prevent needlessly killing additional tasks.
-		 */
-		rcu_read_lock();
-		task_memcg = mem_cgroup_from_task(task);
-		css_get(&task_memcg->css);
-		rcu_read_unlock();
-	}
-	ret = mem_cgroup_is_descendant(task_memcg, memcg);
-	css_put(&task_memcg->css);
-	return ret;
-}
-
 /**
  * mem_cgroup_margin - calculate chargeable space of a memory cgroup
  * @memcg: the memory cgroup
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index bd80997e0969..e0cdcbd58b0b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -153,17 +153,13 @@ static inline bool is_memcg_oom(struct oom_control *oc)
 
 /* return true if the task is not adequate as candidate victim task. */
 static bool oom_unkillable_task(struct task_struct *p,
-		struct mem_cgroup *memcg, const nodemask_t *nodemask)
+				const nodemask_t *nodemask)
 {
 	if (is_global_init(p))
 		return true;
 	if (p->flags & PF_KTHREAD)
 		return true;
 
-	/* When mem_cgroup_out_of_memory() and p is not member of the group */
-	if (memcg && !task_in_mem_cgroup(p, memcg))
-		return true;
-
 	/* p may not have freeable memory in nodemask */
 	if (!has_intersects_mems_allowed(p, nodemask))
 		return true;
@@ -194,20 +190,19 @@ static bool is_dump_unreclaim_slabs(void)
  * oom_badness - heuristic function to determine which candidate task to kill
  * @p: task struct of which task we should calculate
  * @totalpages: total present RAM allowed for page allocation
- * @memcg: task's memory controller, if constrained
  * @nodemask: nodemask passed to page allocator for mempolicy ooms
  *
  * The heuristic for determining which task to kill is made to be as simple and
  * predictable as possible.  The goal is to return the highest value for the
  * task consuming the most memory to avoid subsequent oom failures.
  */
-unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
+unsigned long oom_badness(struct task_struct *p,
 			  const nodemask_t *nodemask, unsigned long totalpages)
 {
 	long points;
 	long adj;
 
-	if (oom_unkillable_task(p, memcg, nodemask))
+	if (oom_unkillable_task(p, nodemask))
 		return 0;
 
 	p = find_lock_task_mm(p);
@@ -318,7 +313,7 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	struct oom_control *oc = arg;
 	unsigned long points;
 
-	if (oom_unkillable_task(task, NULL, oc->nodemask))
+	if (oom_unkillable_task(task, oc->nodemask))
 		goto next;
 
 	/*
@@ -342,7 +337,7 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 		goto select;
 	}
 
-	points = oom_badness(task, NULL, oc->nodemask, oc->totalpages);
+	points = oom_badness(task, oc->nodemask, oc->totalpages);
 	if (!points || points < oc->chosen_points)
 		goto next;
 
@@ -390,7 +385,7 @@ static int dump_task(struct task_struct *p, void *arg)
 	struct oom_control *oc = arg;
 	struct task_struct *task;
 
-	if (oom_unkillable_task(p, NULL, oc->nodemask))
+	if (oom_unkillable_task(p, oc->nodemask))
 		return 0;
 
 	task = find_lock_task_mm(p);
@@ -1090,7 +1085,7 @@ bool out_of_memory(struct oom_control *oc)
 	check_panic_on_oom(oc, constraint);
 
 	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
-	    current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
+	    current->mm && !oom_unkillable_task(current, oc->nodemask) &&
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
 		get_task_struct(current);
 		oc->chosen = current;
-- 
2.22.0.410.gd8fdbe21b5-goog

