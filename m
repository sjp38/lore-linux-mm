Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49589C76186
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 11:47:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2C0F205ED
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 11:47:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2C0F205ED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=I-love.SAKURA.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 877C06B000A; Wed, 17 Jul 2019 07:47:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82B5A8E0001; Wed, 17 Jul 2019 07:47:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 766A36B000D; Wed, 17 Jul 2019 07:47:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4465D6B000A
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 07:47:45 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id o19so14533455pgl.14
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 04:47:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=0un4jofWYCfZVleWCjWRuyr9I+86o/I2+u2PWt8nJ9c=;
        b=KviWYK/Y5XBWoERTacmR+wRPyfrydF0Ugy/5W5yUBFASrZ44G8NMqsc5gqIwFTVIix
         T3zITq9y7f6PW23LFEZx0Ifj9sB/GBk4aOA2cFT2w5uSihr/IGxfWy9u+D4iobdTM9xd
         C0rR0ld3gSqEd0p2vieVj8TrtPfcj2iY3YZmHgmjHd+lIqnM+IGErreMF0M9dHi3nkF3
         PtviW1TmWez4UZRuo1lPc4gYQmxzWWdzzd+Zw1vyYz86ZelQ3wZZURXS9FLU9pKiwDeT
         yY9DYUpHGuhnvzfgHBYD7bBdG8gslP2W/WIk2lil9pOXIGzAuTXqYAIbrvxR7cCz2Tz1
         NTCw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAXqouce5E+WeGR3lA7QbjsiPtG9TiNdhbwUy16sVmYJH72FcKt+
	aZZ7quI+B4JgvxBxENBEhdtRssGcmCIFyGDqAdzZvpag9zzIM/qvK9LcS9yM0sMEpWdMVHZhvVU
	qSb2TcTZl9yKaQZau/DOcYnRx+/DF3eNUmfrA4fJitCTsXRggn2NpEpoErYSbwTiOFw==
X-Received: by 2002:a17:90a:2228:: with SMTP id c37mr43953760pje.9.1563364064934;
        Wed, 17 Jul 2019 04:47:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOydT0jWwqrtMaLyEB9Uh18Inite7LMwZF771uwGuxScEt1LfOQeR2iO/7M/1EKzcnZ8d5
X-Received: by 2002:a17:90a:2228:: with SMTP id c37mr43953661pje.9.1563364063653;
        Wed, 17 Jul 2019 04:47:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563364063; cv=none;
        d=google.com; s=arc-20160816;
        b=aGUE+uxmgCH78sFUnH4QTcuoJRdAiBbzJ/kpaWPqodlVlWI7h5EUjwfA+W9zrupreT
         VpOa6u3sBLRmocY9X8+Hg871ThWkalv51kD221C1Pnzi5/25LpeKtCL9dSXcjnVg9Jic
         auQZiCIBSSLGfT3Y012+mR3vEtISA2V/dQXN6rsKmDoRxfbGbRTHdVPUch754R67Dfdd
         glKSImxdzmPw6EAxpFRpTi/HNBM7ZMKEoBb7uDigySW51o6JVtNJ+Pu0D8MUBZhFqy56
         1ja6VqN1RVjsym0DITtqCzkILO9jIf8/9cvHqMKfkoRzlfLIGr3yKBv/BO3Zz327CLHW
         0FYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=0un4jofWYCfZVleWCjWRuyr9I+86o/I2+u2PWt8nJ9c=;
        b=s4nG1ix19MjMIhs6WtFRaQ1BKJ6zrDIeUqdrHzLn2h5te4IV/L9xqlZOWf+bN1ze5L
         +BBwhZ7UvuIO/z8AH+SeHEtiVYUdZ97pmECPcoDzKir07ayKVllthG1TQPLGoMaA9HXL
         PulyuWCjmywutxoAX998GXmS/byUqPz6vfvimCzKQFrzWKNHOPdxN4FPJUvaJ8Da9Pm3
         /Fb8UCjDVr7nbCI0RaBm2fHY14mBYN/pwZUrYHQcBeQMjPAUR/T9pqJH/OEMkE+W8V48
         xNnKuX9XNZzkFPxAECs4DqVMrsQHI7izbvy8O3mSzg+ltgW5D2J0lX8BaoL4aImGJ4jc
         UV/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id ay3si21709433plb.174.2019.07.17.04.47.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 04:47:43 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav305.sakura.ne.jp (fsav305.sakura.ne.jp [153.120.85.136])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x6HAt9P3017937;
	Wed, 17 Jul 2019 19:55:09 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav305.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav305.sakura.ne.jp);
 Wed, 17 Jul 2019 19:55:09 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav305.sakura.ne.jp)
Received: from ccsecurity.localdomain (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x6HAt284017875
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Wed, 17 Jul 2019 19:55:09 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>,
        Shakeel Butt <shakeelb@google.com>
Subject: [PATCH] mm, oom: avoid printk() iteration under RCU
Date: Wed, 17 Jul 2019 19:55:01 +0900
Message-Id: <1563360901-8277-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently dump_tasks() might call printk() for many thousands times under
RCU, which might take many minutes for slow consoles. Therefore, split
dump_tasks() into three stages; take a snapshot of possible OOM victim
candidates under RCU, dump the snapshot from reschedulable context, and
destroy the snapshot.

In a future patch, the first stage would be moved to select_bad_process()
and the third stage would be moved to after oom_kill_process(), and will
simplify refcount handling.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Roman Gushchin <guro@fb.com>
---
 include/linux/sched.h |  1 +
 mm/oom_kill.c         | 67 +++++++++++++++++++++++++--------------------------
 2 files changed, 34 insertions(+), 34 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 8dc1811..cb6696b 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1246,6 +1246,7 @@ struct task_struct {
 #ifdef CONFIG_MMU
 	struct task_struct		*oom_reaper_list;
 #endif
+	struct list_head		oom_victim_list;
 #ifdef CONFIG_VMAP_STACK
 	struct vm_struct		*stack_vm_area;
 #endif
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index eda2e2a..bd22ca0 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -377,36 +377,13 @@ static void select_bad_process(struct oom_control *oc)
 	}
 }
 
-static int dump_task(struct task_struct *p, void *arg)
-{
-	struct oom_control *oc = arg;
-	struct task_struct *task;
-
-	if (oom_unkillable_task(p))
-		return 0;
-
-	/* p may not have freeable memory in nodemask */
-	if (!is_memcg_oom(oc) && !oom_cpuset_eligible(p, oc))
-		return 0;
 
-	task = find_lock_task_mm(p);
-	if (!task) {
-		/*
-		 * This is a kthread or all of p's threads have already
-		 * detached their mm's.  There's no need to report
-		 * them; they can't be oom killed anyway.
-		 */
-		return 0;
+static int add_candidate_task(struct task_struct *p, void *arg)
+{
+	if (!oom_unkillable_task(p)) {
+		get_task_struct(p);
+		list_add_tail(&p->oom_victim_list, (struct list_head *) arg);
 	}
-
-	pr_info("[%7d] %5d %5d %8lu %8lu %8ld %8lu         %5hd %s\n",
-		task->pid, from_kuid(&init_user_ns, task_uid(task)),
-		task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
-		mm_pgtables_bytes(task->mm),
-		get_mm_counter(task->mm, MM_SWAPENTS),
-		task->signal->oom_score_adj, task->comm);
-	task_unlock(task);
-
 	return 0;
 }
 
@@ -422,19 +399,41 @@ static int dump_task(struct task_struct *p, void *arg)
  */
 static void dump_tasks(struct oom_control *oc)
 {
-	pr_info("Tasks state (memory values in pages):\n");
-	pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
+	static LIST_HEAD(list);
+	struct task_struct *p;
+	struct task_struct *t;
 
 	if (is_memcg_oom(oc))
-		mem_cgroup_scan_tasks(oc->memcg, dump_task, oc);
+		mem_cgroup_scan_tasks(oc->memcg, add_candidate_task, &list);
 	else {
-		struct task_struct *p;
-
 		rcu_read_lock();
 		for_each_process(p)
-			dump_task(p, oc);
+			add_candidate_task(p, &list);
 		rcu_read_unlock();
 	}
+	pr_info("Tasks state (memory values in pages):\n");
+	pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
+	list_for_each_entry(p, &list, oom_victim_list) {
+		cond_resched();
+		/* p may not have freeable memory in nodemask */
+		if (!is_memcg_oom(oc) && !oom_cpuset_eligible(p, oc))
+			continue;
+		/* All of p's threads might have already detached their mm's. */
+		t = find_lock_task_mm(p);
+		if (!t)
+			continue;
+		pr_info("[%7d] %5d %5d %8lu %8lu %8ld %8lu         %5hd %s\n",
+			t->pid, from_kuid(&init_user_ns, task_uid(t)),
+			t->tgid, t->mm->total_vm, get_mm_rss(t->mm),
+			mm_pgtables_bytes(t->mm),
+			get_mm_counter(t->mm, MM_SWAPENTS),
+			t->signal->oom_score_adj, t->comm);
+		task_unlock(t);
+	}
+	list_for_each_entry_safe(p, t, &list, oom_victim_list) {
+		list_del(&p->oom_victim_list);
+		put_task_struct(p);
+	}
 }
 
 static void dump_oom_summary(struct oom_control *oc, struct task_struct *victim)
-- 
1.8.3.1

