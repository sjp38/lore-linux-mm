Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 404CFC7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:17:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8ADFC218DA
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:17:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8ADFC218DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=I-love.SAKURA.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E71576B0003; Wed, 24 Jul 2019 00:17:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E222E6B0005; Wed, 24 Jul 2019 00:17:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D12608E0002; Wed, 24 Jul 2019 00:17:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id A40196B0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 00:17:07 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id d13so25001344oth.20
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 21:17:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=2FVIHyOEB+KhXakmAyRqc1O9my/dWkpIFHbS+upS7+s=;
        b=QmdVaqMLL4669AjSD2D7XVwjUg3BfdUJp7kSn+Xopjk8cJIqSo8Nvj+KOe83DxytW4
         +xuT8gpiaVBoKVn/Ydd5l+9lCTnlzRdl3mPkFy+Ids8vwPpIJmXGT5cZoVkRCmFUF5B9
         9QGNCO/W2Yk7AEn1cInItWFku3/w1IiyPL/ZEsm9HZtu/3wsJL12vtZxv2NYBb9Rx9G9
         PlMBieVY00XTKYBGdRpGdcUu/unGAcoLsuYuWXWMn21CgJOPeGfaS0KQg8uM6hJQ/e3S
         VjdMrnqBYt4+izyDPiEatKDb2vXjNPrBBl0h5qsoBXQW2j1yg8dtdnfipnLFSPq8SR5f
         qStg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAXkYEerhYSVV+qbHFjoq6MIIIX7KXvhYS3Lfxn9Q5GXz3Qb8FcJ
	iucjraIwv8sZb+5XlgssHcKsuA3+SaSGK/e1Abgb6NvTU/8+shAin/fgY+nK+LVNt12fMZhHPHw
	6LSJMlY0WJicowYHnBIjfnCXiu5qX7bTKmj6najobITkH76T5zL8BOIbDpwX2WaIhOQ==
X-Received: by 2002:a05:6830:2010:: with SMTP id e16mr1019065otp.344.1563941827247;
        Tue, 23 Jul 2019 21:17:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8NOLVp3QwjPQ2q9i3e8fhHcqm3r1CUCa1svUQqDsZ00c/tkbTtNKZAUMGdNKlEJoZsw9V
X-Received: by 2002:a05:6830:2010:: with SMTP id e16mr1019006otp.344.1563941826003;
        Tue, 23 Jul 2019 21:17:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563941825; cv=none;
        d=google.com; s=arc-20160816;
        b=E7Dcfs7o8TezDUAGKzi9EUsNdXco82wIAu1fzOw2fGW4hovNWViFOP4Z7ftDGoYS/D
         bFMvjcmnW4aUuZn/VnGJE491NSNUfreHM0SwdbtGOHEQzcsmJO6+JVS74zvVGUOUm4oC
         oyWN29YJ1n95oP8ya+xUEU+68yXj16Tde96rH8oZKaYM6FRG4pHQfkDgAFakgkxv1t/j
         XoS8N1KpC6wxHJcY4Nd340DIo+UCwtKYram3b8XnRbeqh1zOxHqDIxpId74liowNXeVm
         0QuUHe8QmYK8fWUkbi3SpqlIYgaT2geUB2U52+WIpo96RSn1sv9VwBLa80HKuPtKipVI
         05gA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=2FVIHyOEB+KhXakmAyRqc1O9my/dWkpIFHbS+upS7+s=;
        b=jeetvWyjQHglH6WjypWpKOWY8eMNCZq1yorTqVbAuIQbVhZPsm16CMkrK9W41APA7W
         oA0G4XA8z38s/grp38QD6+tcVrM+5FE5h20RVr0ctWf/yAq8N6U9NhuDtNQIdLcR4fJZ
         nQRU2xQ3FqHdxw+Bg800xTytRnvtEmvL14mnEB3miylMxDL/s1oJt3tHm75hTToOFGPh
         RJUiATxOnvhiu8a01UrObsMv6csrgAwFcAG7Z+MEW90mm1i3ZmUICiJ89dRaNVOxMkPc
         2TWhRW1Omb/jsU8RybjC6MlPYO4CcW39YG5Sd5pfQbkdTQHMROiBG2Zp0JqkMUfi+2BR
         l8/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id v17si31007418oth.44.2019.07.23.21.17.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 21:17:05 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav303.sakura.ne.jp (fsav303.sakura.ne.jp [153.120.85.134])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x6O4GpFB096743;
	Wed, 24 Jul 2019 13:16:51 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav303.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav303.sakura.ne.jp);
 Wed, 24 Jul 2019 13:16:51 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav303.sakura.ne.jp)
Received: from ccsecurity.localdomain (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x6O4GjRL096662
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Wed, 24 Jul 2019 13:16:51 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>,
        Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>
Subject: [PATCH] mm, oom: simplify task's refcount handling
Date: Wed, 24 Jul 2019 12:54:36 +0900
Message-Id: <1563940476-6162-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently out_of_memory() is full of get_task_struct()/put_task_struct()
calls. Since "mm, oom: avoid printk() iteration under RCU" introduced
a list for holding a snapshot of all OOM victim candidates, let's share
that list for select_bad_process() and oom_kill_process() in order to
simplify task's refcount handling.

As a result of this patch, get_task_struct()/put_task_struct() calls
in out_of_memory() are reduced to only 2 times respectively.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: David Rientjes <rientjes@google.com>
---
 include/linux/sched.h |   2 +-
 mm/oom_kill.c         | 122 ++++++++++++++++++++++++--------------------------
 2 files changed, 60 insertions(+), 64 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 48c1a4c..4062999 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1247,7 +1247,7 @@ struct task_struct {
 #ifdef CONFIG_MMU
 	struct task_struct		*oom_reaper_list;
 #endif
-	struct list_head		oom_victim_list;
+	struct list_head		oom_candidate;
 #ifdef CONFIG_VMAP_STACK
 	struct vm_struct		*stack_vm_area;
 #endif
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 110f948..311e0e9 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -63,6 +63,7 @@
  * and mark_oom_victim
  */
 DEFINE_MUTEX(oom_lock);
+static LIST_HEAD(oom_candidate_list);
 
 static inline bool is_memcg_oom(struct oom_control *oc)
 {
@@ -167,6 +168,41 @@ static bool oom_unkillable_task(struct task_struct *p)
 	return false;
 }
 
+static int add_candidate_task(struct task_struct *p, void *unused)
+{
+	if (!oom_unkillable_task(p)) {
+		get_task_struct(p);
+		list_add_tail(&p->oom_candidate, &oom_candidate_list);
+	}
+	return 0;
+}
+
+static void link_oom_candidates(struct oom_control *oc)
+{
+	struct task_struct *p;
+
+	if (is_memcg_oom(oc))
+		mem_cgroup_scan_tasks(oc->memcg, add_candidate_task, NULL);
+	else {
+		rcu_read_lock();
+		for_each_process(p)
+			add_candidate_task(p, NULL);
+		rcu_read_unlock();
+	}
+
+}
+
+static void unlink_oom_candidates(void)
+{
+	struct task_struct *p;
+	struct task_struct *t;
+
+	list_for_each_entry_safe(p, t, &oom_candidate_list, oom_candidate) {
+		list_del(&p->oom_candidate);
+		put_task_struct(p);
+	}
+}
+
 /*
  * Print out unreclaimble slabs info when unreclaimable slabs amount is greater
  * than all user memory (LRU pages)
@@ -344,16 +380,11 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 		goto next;
 
 select:
-	if (oc->chosen)
-		put_task_struct(oc->chosen);
-	get_task_struct(task);
 	oc->chosen = task;
 	oc->chosen_points = points;
 next:
 	return 0;
 abort:
-	if (oc->chosen)
-		put_task_struct(oc->chosen);
 	oc->chosen = (void *)-1UL;
 	return 1;
 }
@@ -364,27 +395,13 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
  */
 static void select_bad_process(struct oom_control *oc)
 {
-	if (is_memcg_oom(oc))
-		mem_cgroup_scan_tasks(oc->memcg, oom_evaluate_task, oc);
-	else {
-		struct task_struct *p;
-
-		rcu_read_lock();
-		for_each_process(p)
-			if (oom_evaluate_task(p, oc))
-				break;
-		rcu_read_unlock();
-	}
-}
-
+	struct task_struct *p;
 
-static int add_candidate_task(struct task_struct *p, void *arg)
-{
-	if (!oom_unkillable_task(p)) {
-		get_task_struct(p);
-		list_add_tail(&p->oom_victim_list, (struct list_head *) arg);
+	list_for_each_entry(p, &oom_candidate_list, oom_candidate) {
+		cond_resched();
+		if (oom_evaluate_task(p, oc))
+			break;
 	}
-	return 0;
 }
 
 /**
@@ -399,21 +416,12 @@ static int add_candidate_task(struct task_struct *p, void *arg)
  */
 static void dump_tasks(struct oom_control *oc)
 {
-	static LIST_HEAD(list);
 	struct task_struct *p;
 	struct task_struct *t;
 
-	if (is_memcg_oom(oc))
-		mem_cgroup_scan_tasks(oc->memcg, add_candidate_task, &list);
-	else {
-		rcu_read_lock();
-		for_each_process(p)
-			add_candidate_task(p, &list);
-		rcu_read_unlock();
-	}
 	pr_info("Tasks state (memory values in pages):\n");
 	pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
-	list_for_each_entry(p, &list, oom_victim_list) {
+	list_for_each_entry(p, &oom_candidate_list, oom_candidate) {
 		cond_resched();
 		/* p may not have freeable memory in nodemask */
 		if (!is_memcg_oom(oc) && !oom_cpuset_eligible(p, oc))
@@ -430,10 +438,6 @@ static void dump_tasks(struct oom_control *oc)
 			t->signal->oom_score_adj, t->comm);
 		task_unlock(t);
 	}
-	list_for_each_entry_safe(p, t, &list, oom_victim_list) {
-		list_del(&p->oom_victim_list);
-		put_task_struct(p);
-	}
 }
 
 static void dump_oom_summary(struct oom_control *oc, struct task_struct *victim)
@@ -859,17 +863,11 @@ static void __oom_kill_process(struct task_struct *victim, const char *message)
 	bool can_oom_reap = true;
 
 	p = find_lock_task_mm(victim);
-	if (!p) {
-		put_task_struct(victim);
+	if (!p)
 		return;
-	} else if (victim != p) {
-		get_task_struct(p);
-		put_task_struct(victim);
-		victim = p;
-	}
 
-	/* Get a reference to safely compare mm after task_unlock(victim) */
-	mm = victim->mm;
+	/* Get a reference to safely compare mm after task_unlock(p) */
+	mm = p->mm;
 	mmgrab(mm);
 
 	/* Raise event before sending signal: task reaper must see this */
@@ -881,16 +879,15 @@ static void __oom_kill_process(struct task_struct *victim, const char *message)
 	 * in order to prevent the OOM victim from depleting the memory
 	 * reserves from the user space under its control.
 	 */
-	do_send_sig_info(SIGKILL, SEND_SIG_PRIV, victim, PIDTYPE_TGID);
-	mark_oom_victim(victim);
+	do_send_sig_info(SIGKILL, SEND_SIG_PRIV, p, PIDTYPE_TGID);
+	mark_oom_victim(p);
 	pr_err("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB, UID:%u\n",
-		message, task_pid_nr(victim), victim->comm,
-		K(victim->mm->total_vm),
-		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
-		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
-		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)),
-		from_kuid(&init_user_ns, task_uid(victim)));
-	task_unlock(victim);
+	       message, task_pid_nr(p), p->comm, K(mm->total_vm),
+	       K(get_mm_counter(mm, MM_ANONPAGES)),
+	       K(get_mm_counter(mm, MM_FILEPAGES)),
+	       K(get_mm_counter(mm, MM_SHMEMPAGES)),
+	       from_kuid(&init_user_ns, task_uid(p)));
+	task_unlock(p);
 
 	/*
 	 * Kill all user processes sharing victim->mm in other thread groups, if
@@ -929,7 +926,6 @@ static void __oom_kill_process(struct task_struct *victim, const char *message)
 		wake_oom_reaper(victim);
 
 	mmdrop(mm);
-	put_task_struct(victim);
 }
 #undef K
 
@@ -940,10 +936,8 @@ static void __oom_kill_process(struct task_struct *victim, const char *message)
 static int oom_kill_memcg_member(struct task_struct *task, void *message)
 {
 	if (task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN &&
-	    !is_global_init(task)) {
-		get_task_struct(task);
+	    !is_global_init(task))
 		__oom_kill_process(task, message);
-	}
 	return 0;
 }
 
@@ -964,7 +958,6 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 		mark_oom_victim(victim);
 		wake_oom_reaper(victim);
 		task_unlock(victim);
-		put_task_struct(victim);
 		return;
 	}
 	task_unlock(victim);
@@ -1073,6 +1066,8 @@ bool out_of_memory(struct oom_control *oc)
 	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
 		return true;
 
+	link_oom_candidates(oc);
+
 	/*
 	 * Check if there were limitations on the allocation (only relevant for
 	 * NUMA and memcg) that may require different handling.
@@ -1086,10 +1081,9 @@ bool out_of_memory(struct oom_control *oc)
 	    current->mm && !oom_unkillable_task(current) &&
 	    oom_cpuset_eligible(current, oc) &&
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
-		get_task_struct(current);
 		oc->chosen = current;
 		oom_kill_process(oc, "Out of memory (oom_kill_allocating_task)");
-		return true;
+		goto done;
 	}
 
 	select_bad_process(oc);
@@ -1108,6 +1102,8 @@ bool out_of_memory(struct oom_control *oc)
 	if (oc->chosen && oc->chosen != (void *)-1UL)
 		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
 				 "Memory cgroup out of memory");
+ done:
+	unlink_oom_candidates();
 	return !!oc->chosen;
 }
 
-- 
1.8.3.1

