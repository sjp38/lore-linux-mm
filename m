Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DD5BC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 22:50:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1CBCA218D2
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 22:50:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1CBCA218D2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D14338E0002; Wed, 30 Jan 2019 17:50:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9B018E0001; Wed, 30 Jan 2019 17:50:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B62F68E0002; Wed, 30 Jan 2019 17:50:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 89E508E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 17:50:14 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id v188so679766ita.0
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 14:50:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=4XyBlERSwd1po5TEs01Gi8RirNTwcbgAO3539lqn/0g=;
        b=OurbNW+gJAslMcwN5Kmvqbekt57IWGhfTn5PY95gKZnEJyY7DKaa7TuH5QVxuHjjJw
         6KJkTLVY9l0YfOQAhGj8lb5DAHl3LN5VS299qVUhqd5BoVWvRH4zIFogolp53lIZGYBZ
         /jRAUgg376FDo2BK99DvJituucJWvsPQfKY3qir7+34uio+4RaNa2Bn4ybeaL2DgQCbH
         l2O1D1hhCXFnej79FLAWdC6upzFnT0TnG5h1pKUJGJGg59Dzjt8zaiDLQbusLAV6m73a
         KJzDTu+HUlRAs1qVn+z1sP/Z2HJyQQ/rNoU2coZfNWCe/G+O+9YjimxKiMB9HnA3t4Qi
         Ol3g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AJcUukdDlVVldK7H3sg57xL8I/oNY4SiplEQa13AWyEnJzWqWVUiT6i6
	RIIsm4h88M45KSmmCJApsSmjzmNu/Jye0yEDqm9Oiwb63KJ+Eo51ZARVWfOroeMhW6pFj0IQxoF
	rmjNDJkGyBzS3nDA9uyb/AbmKoUpbNKi3I4DGmea6+x2fYdn883QqrgxNR+vDCiyARg==
X-Received: by 2002:a24:9791:: with SMTP id k139mr16575927ite.49.1548888614308;
        Wed, 30 Jan 2019 14:50:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbFd+cqJ9g0K/GlF/vD2aGslfdyfh7z4K5jZo2+klVMG2O6hE2Z/xRnfooVvFnICX9Pjzw1
X-Received: by 2002:a24:9791:: with SMTP id k139mr16575906ite.49.1548888613298;
        Wed, 30 Jan 2019 14:50:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548888613; cv=none;
        d=google.com; s=arc-20160816;
        b=uFfX7/tFnkLM5pZXPkpT15zuia2OtMTCvFstOH25XZ5XeqUDrdSits8I0EJDME6Q6M
         VOtDOgDUtq+I4/sT7NZao8sN69WR1s2g4ZJF0ZbLUZEiKKsrSIvoSGSPNHNb9PTXxbrR
         wMoQv07516UTbYD47h2C2HZbM3tbCQW9/p2T5GmGj8c9cXkOJ6sG2EQ+xKmaIKvMkbXz
         89dS/6EL73ArlKFUEfJff7iPav2R5eHDc71FUEFhco5XaQSqPGaYqociMY6osG/Ad2Nn
         qlbK9NEXaYx7QqtP1zkKmMp2H9iz5RbcMbfVm7JKF39UpPqtKVSWGwv4IZRU1CoplySO
         R0eQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=4XyBlERSwd1po5TEs01Gi8RirNTwcbgAO3539lqn/0g=;
        b=a9BfYqPM8CSfvmMTc+ZYwo9mSfVxcDojOp3OlptAAvNZb7vLXQbBdUW91glFjGfuCn
         TmKeg1t+ecsnv+RjfaQ7JXdiwGR/yuKErFZovaRmKJJnUHCN+T5gL8jNr0oL9iZMI5Zh
         OPLyUi6aQ8GFrcfuW/o+GE0RWrMvTWS+8COAol8q4P3/IihTC8agmqVrkKwcp1r+tE10
         GKEDdPAPV7TqGNqxIAdDlx1/O4TK0+bAXdygZSHarzKvgFtwiN8xrIcYHi0BgFLiGpai
         C69kLhkfXZUNCqNFbuRc6Im8MD+BUryjKNMoXlquQgnz46NVecOh/gkfoOAXIaAeQ9Fj
         aJ8g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id s45si1939008ite.80.2019.01.30.14.50.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 14:50:12 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav303.sakura.ne.jp (fsav303.sakura.ne.jp [153.120.85.134])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x0UMo2aj047097;
	Thu, 31 Jan 2019 07:50:03 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav303.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav303.sakura.ne.jp);
 Thu, 31 Jan 2019 07:50:02 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav303.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36] (may be forged))
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x0UMo2FR046597
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Thu, 31 Jan 2019 07:50:02 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: [PATCH v2] mm, oom: Tolerate processes sharing mm with different view
 of oom_score_adj.
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
        David Rientjes <rientjes@google.com>, linux-mm@kvack.org,
        Yong-Taek Lee <ytk.lee@samsung.com>,
        Paul McKenney <paulmck@linux.vnet.ibm.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>
References: <1547636121-9229-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190116110937.GI24149@dhcp22.suse.cz>
 <88e10029-f3d9-5bb5-be46-a3547c54de28@I-love.SAKURA.ne.jp>
 <20190116121915.GJ24149@dhcp22.suse.cz>
 <6118fa8a-7344-b4b2-36ce-d77d495fba69@i-love.sakura.ne.jp>
 <20190116134131.GP24149@dhcp22.suse.cz>
 <20190117155159.GA4087@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <edad66e0-1947-eb42-f4db-7f826d3157d7@i-love.sakura.ne.jp>
Date: Thu, 31 Jan 2019 07:49:35 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190117155159.GA4087@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch reverts both commit 44a70adec910d692 ("mm, oom_adj: make sure
processes sharing mm have same view of oom_score_adj") and commit
97fd49c2355ffded ("mm, oom: kill all tasks sharing the mm") in order to
close a race and reduce the latency at __set_oom_adj(), and reduces the
warning at __oom_kill_process() in order to minimize the latency.

Commit 36324a990cf578b5 ("oom: clear TIF_MEMDIE after oom_reaper managed
to unmap the address space") introduced the worst case mentioned in
44a70adec910d692. But since the OOM killer skips mm with MMF_OOM_SKIP set,
only administrators can trigger the worst case.

Since 44a70adec910d692 did not take latency into account, we can "hold RCU
for minutes and trigger RCU stall warnings" by calling printk() on many
thousands of thread groups. Also, current code becomes a DoS attack vector
which will allow "stalling for more than one month in unkillable state"
simply printk()ing same messages when many thousands of thread groups
tried to iterate __set_oom_adj() on each other.

I also noticed that 44a70adec910d692 is racy [1], and trying to fix the
race will require a global lock which is too costly for rare events. And
Michal Hocko is thinking to change the oom_score_adj implementation to per
mm_struct (with shadowed score stored in per task_struct in order to
support vfork() => __set_oom_adj() => execve() sequence) so that we don't
need the global lock.

If the worst case in 44a70adec910d692 happened, it is an administrator's
request. Therefore, before changing the oom_score_adj implementation,
let's eliminate the DoS attack vector first.

[1] https://lkml.kernel.org/r/20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p8

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Reported-by: Yong-Taek Lee <ytk.lee@samsung.com>
Nacked-by: Michal Hocko <mhocko@suse.com>
---
 fs/proc/base.c     | 46 ----------------------------------------------
 include/linux/mm.h |  2 --
 mm/oom_kill.c      | 10 ++++++----
 3 files changed, 6 insertions(+), 52 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 633a634..41ece8f 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1020,7 +1020,6 @@ static ssize_t oom_adj_read(struct file *file, char __user *buf, size_t count,
 static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
 {
 	static DEFINE_MUTEX(oom_adj_mutex);
-	struct mm_struct *mm = NULL;
 	struct task_struct *task;
 	int err = 0;
 
@@ -1050,55 +1049,10 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
 		}
 	}
 
-	/*
-	 * Make sure we will check other processes sharing the mm if this is
-	 * not vfrok which wants its own oom_score_adj.
-	 * pin the mm so it doesn't go away and get reused after task_unlock
-	 */
-	if (!task->vfork_done) {
-		struct task_struct *p = find_lock_task_mm(task);
-
-		if (p) {
-			if (atomic_read(&p->mm->mm_users) > 1) {
-				mm = p->mm;
-				mmgrab(mm);
-			}
-			task_unlock(p);
-		}
-	}
-
 	task->signal->oom_score_adj = oom_adj;
 	if (!legacy && has_capability_noaudit(current, CAP_SYS_RESOURCE))
 		task->signal->oom_score_adj_min = (short)oom_adj;
 	trace_oom_score_adj_update(task);
-
-	if (mm) {
-		struct task_struct *p;
-
-		rcu_read_lock();
-		for_each_process(p) {
-			if (same_thread_group(task, p))
-				continue;
-
-			/* do not touch kernel threads or the global init */
-			if (p->flags & PF_KTHREAD || is_global_init(p))
-				continue;
-
-			task_lock(p);
-			if (!p->vfork_done && process_shares_mm(p, mm)) {
-				pr_info("updating oom_score_adj for %d (%s) from %d to %d because it shares mm with %d (%s). Report if this is unexpected.\n",
-						task_pid_nr(p), p->comm,
-						p->signal->oom_score_adj, oom_adj,
-						task_pid_nr(task), task->comm);
-				p->signal->oom_score_adj = oom_adj;
-				if (!legacy && has_capability_noaudit(current, CAP_SYS_RESOURCE))
-					p->signal->oom_score_adj_min = (short)oom_adj;
-			}
-			task_unlock(p);
-		}
-		rcu_read_unlock();
-		mmdrop(mm);
-	}
 err_unlock:
 	mutex_unlock(&oom_adj_mutex);
 	put_task_struct(task);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80bb640..28879c1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2690,8 +2690,6 @@ static inline int in_gate_area(struct mm_struct *mm, unsigned long addr)
 }
 #endif	/* __HAVE_ARCH_GATE_AREA */
 
-extern bool process_shares_mm(struct task_struct *p, struct mm_struct *mm);
-
 #ifdef CONFIG_SYSCTL
 extern int sysctl_drop_caches;
 int drop_caches_sysctl_handler(struct ctl_table *, int,
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f0e8cd9..c7005b1 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -478,7 +478,7 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
  * task's threads: if one of those is using this mm then this task was also
  * using it.
  */
-bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
+static bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
 {
 	struct task_struct *t;
 
@@ -896,12 +896,14 @@ static void __oom_kill_process(struct task_struct *victim)
 			continue;
 		if (same_thread_group(p, victim))
 			continue;
-		if (is_global_init(p)) {
+		if (is_global_init(p) ||
+		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
 			can_oom_reap = false;
-			set_bit(MMF_OOM_SKIP, &mm->flags);
-			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
+			if (!test_bit(MMF_OOM_SKIP, &mm->flags))
+				pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
 					task_pid_nr(victim), victim->comm,
 					task_pid_nr(p), p->comm);
+			set_bit(MMF_OOM_SKIP, &mm->flags);
 			continue;
 		}
 		/*
-- 
1.8.3.1

