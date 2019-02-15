Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE762C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 10:42:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 677D02089F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 10:42:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 677D02089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 038648E0002; Fri, 15 Feb 2019 05:42:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F04528E0001; Fri, 15 Feb 2019 05:42:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA7358E0002; Fri, 15 Feb 2019 05:42:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id AB7508E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 05:42:54 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id t26so6511983pgu.18
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 02:42:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=EzMc9cGtej09Yxc60x0pST5uJRtsjWgkq34aYh7xTLk=;
        b=LDfUmfEnpgvzLOQ+sPTZz2I3yk7hFksrgpqV4KvMG1D8rWDXcdWP8LubLkaUWAVmP+
         UIed9QabRUd1IWOSRr1hcZq9cnfo7Aaxi14BGZr0RRgVs0RSF8e5HzNjeMvhtSsOIwcv
         UFjwHtHC3ADQgOZQTh+3qNX1v5t4a+KaIBDA4dsjuxxXmg9b9lRrpsNZ/GBxfgj+CGmU
         7TBh7/KTg+2i+Pz6CdQ4ZU+oFlr4mZywQVEilG9KTDRdHB0HXHhvC5RREGWRhh10bAWs
         3wCY8kD3YWqF/jMkC7qdEU87hyF9Vs3PS0FYWIMzb+1WxUeI5tW0+9p8pSl3vlMMRg6R
         DQ5g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AHQUAuaaH0kfkOTmvCKPDuf06PN/5mFi14bgNrIwYoDOpyYofza5ChvH
	6Dqfes4Rm2J8/73+SVher0+vxKChucYfQ3FHrzIjDt5OcAc0HK8ilTtgB3favPgSi0XtSDkg7yT
	GTTu+HHujwoFNYLZxyAvTLx1TEYnMDUrsrEoEwYkmXwDcOFsC7wFw5rAddR0gjy74Hg==
X-Received: by 2002:a17:902:22f:: with SMTP id 44mr9479224plc.137.1550227374299;
        Fri, 15 Feb 2019 02:42:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3IayVDsESF4NfZl0slqlsUWMnRcjaDuotWKBe5XwRCKUsdpdrvM8J54mpgd8fmAhcKG1yHfk
X-Received: by 2002:a17:902:22f:: with SMTP id 44mr9479160plc.137.1550227373104;
        Fri, 15 Feb 2019 02:42:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550227373; cv=none;
        d=google.com; s=arc-20160816;
        b=RpurbVuvEsGsqFc+jFZA5D9wuRJI60EuWKl7UqnAjue1NwHyzX9cg4oCduB5O3hEeK
         X+LQ/5GhCQ3Z10+5OBAwnAro1HGYiKTj7PsKI0c3+Pib1ABw7nsxvMrb6reZHyP8Z56M
         7w8dd1kwUUHaQWxxkjq705ToOzS7zrhgDjjzXhlCa5WT7iVeLoavwFBTVibI8cotfpbE
         1L13xgGwTW/D1JnEOZzPWKZoUt6ILzFwVIvjRIqxYSgQ6YrDVtR/xQ8tBzCDWB8tR42t
         ZmqffZnRzGiY4niZ/rObqirLmXaHRnpNF06T7OmM4QISqWkBk3a1GDla2o7CiBoDv7gQ
         yYtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=EzMc9cGtej09Yxc60x0pST5uJRtsjWgkq34aYh7xTLk=;
        b=aZ7cDWNzT9cGwyfyxQySEJGtS/cCudYcqJEXNub5rVJuE2qp8E4oA9peQSLoQHZ1kT
         gwziQveyH1drVSR0Nga3xp+70yWlSviOFcUuuE6U29iDA508ktKxxwzVdoP0ubzi0Ze/
         8BaN3nxGSOo3v+QJsnHsCGC0etSk3Ih8vjsRiDFNATwhSD8VSP3rR6OS0wHalxafFJF5
         q1GrFQ3EqUGlaA0XGpLYqWjkImPW56qmmGAvuyk+fibcWMDLp+T3BCp49v7frA/GBPxH
         aIcYuqEcuWpZveDkcsqNLpto8DQDJXz/3zJeQ48KM4KIblb2kTuNDvobwDpcQwE4kdVm
         nRhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id b5si4858060pgw.377.2019.02.15.02.42.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 02:42:52 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav107.sakura.ne.jp (fsav107.sakura.ne.jp [27.133.134.234])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x1FAgmU2018555;
	Fri, 15 Feb 2019 19:42:48 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav107.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav107.sakura.ne.jp);
 Fri, 15 Feb 2019 19:42:48 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav107.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x1FAghCI018519
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Fri, 15 Feb 2019 19:42:48 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH v3] mm,page_alloc: wait for oom_lock before retrying.
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>
References: <20900d89-b06d-2ec6-0ae0-beffc5874f26@I-love.SAKURA.ne.jp>
 <20190213165640.GV4525@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <87896c67-ddc9-56d9-8643-09865c6cbfe2@i-love.sakura.ne.jp>
Date: Fri, 15 Feb 2019 19:42:41 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190213165640.GV4525@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/02/14 1:56, Michal Hocko wrote:
> On Thu 14-02-19 01:30:28, Tetsuo Handa wrote:
> [...]
>> >From 63c5c8ee7910fa9ef1c4067f1cb35a779e9d582c Mon Sep 17 00:00:00 2001
>> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>> Date: Tue, 12 Feb 2019 20:12:35 +0900
>> Subject: [PATCH v3] mm,page_alloc: wait for oom_lock before retrying.
>>
>> When many hundreds of threads concurrently triggered a page fault, and
>> one of them invoked the global OOM killer, the owner of oom_lock is
>> preempted for minutes because they are rather depriving the owner of
>> oom_lock of CPU time rather than waiting for the owner of oom_lock to
>> make progress. We don't want to disable preemption while holding oom_lock
>> but we want the owner of oom_lock to complete as soon as possible.
>>
>> Thus, this patch kills the dangerous assumption that sleeping for one
>> jiffy is sufficient for allowing the owner of oom_lock to make progress.
> 
> What does this prevent any _other_ kernel path or even high priority
> userspace to preempt the oom killer path? This was the essential
> question the last time around and I do not see it covered here. I

Since you already NACKed disabling preemption at
https://marc.info/?i=20180322114002.GC23100@dhcp22.suse.cz , pointing out
"even high priority userspace to preempt the oom killer path" is invalid.

Since printk() is very slow, dump_header() can become slow, especially when
dump_tasks() is called. And changing dump_tasks() to use rcu_lock_break()
does not solve this problem, for this is a problem that once current thread
released CPU, current thread might be kept preempted for minutes.

Allowing OOM path to be preempted is what you prefer, isn't it? Then,
spending CPU time for something (what you call "any _other_ kernel path") is
accountable for delaying OOM path. But wasting CPU time when allocating
threads can do nothing but wait for the owner of oom_lock to complete OOM
path is not accountable for delaying OOM path.

Thus, there is nothing to cover for your "I do not see it covered here"
response, except how to avoid "wasting CPU time when allocating threads
can do nothing but wait for the owner of oom_lock to complete OOM path".

> strongly suspect that all these games with the locking is just a
> pointless tunning for an insane workload without fixing the underlying
> issue.

We could even change oom_lock to a local lock inside oom_kill_process(), for
all threads in a same allocating context will select the same OOM victim
(unless oom_kill_allocating_task case), and many threads already inside
oom_kill_process() will prevent themselves from selecting next OOM victim.
Although this approach wastes some CPU resources for needlessly selecting
same OOM victim for many times, this approach also can solve this problem.

It seems that you don't want to admit that "wasting CPU time when allocating
threads can do nothing but wait for the owner of oom_lock to complete OOM path"
as the underlying issue. But we can't fix it without throttling direct reclaim
paths. That's the evidence that this problem is not fixed for many years.
Please stop NACKing proposals without alternative implementations.

---
 drivers/tty/sysrq.c |   2 -
 include/linux/oom.h |   2 -
 mm/memcontrol.c     |  11 +-----
 mm/oom_kill.c       | 106 ++++++++++++++++++++++++++++++++++++++--------------
 mm/page_alloc.c     |  18 +--------
 5 files changed, 81 insertions(+), 58 deletions(-)

diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index fa0ce7d..aa7f857 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -369,10 +369,8 @@ static void moom_callback(struct work_struct *ignored)
 		.order = -1,
 	};
 
-	mutex_lock(&oom_lock);
 	if (!out_of_memory(&oc))
 		pr_info("OOM request ignored. No task eligible\n");
-	mutex_unlock(&oom_lock);
 }
 
 static DECLARE_WORK(moom_work, moom_callback);
diff --git a/include/linux/oom.h b/include/linux/oom.h
index d079920..865fddf 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -54,8 +54,6 @@ struct oom_control {
 	enum oom_constraint constraint;
 };
 
-extern struct mutex oom_lock;
-
 static inline void set_current_oom_origin(void)
 {
 	current->signal->oom_flag_origin = true;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5fc2e1a..31d3314 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1399,17 +1399,8 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		.gfp_mask = gfp_mask,
 		.order = order,
 	};
-	bool ret;
 
-	if (mutex_lock_killable(&oom_lock))
-		return true;
-	/*
-	 * A few threads which were not waiting at mutex_lock_killable() can
-	 * fail to bail out. Therefore, check again after holding oom_lock.
-	 */
-	ret = should_force_charge() || out_of_memory(&oc);
-	mutex_unlock(&oom_lock);
-	return ret;
+	return should_force_charge() || out_of_memory(&oc);
 }
 
 #if MAX_NUMNODES > 1
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3a24848..db804fa 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -54,14 +54,10 @@
 int sysctl_oom_dump_tasks = 1;
 
 /*
- * Serializes oom killer invocations (out_of_memory()) from all contexts to
- * prevent from over eager oom killing (e.g. when the oom killer is invoked
- * from different domains).
- *
  * oom_killer_disable() relies on this lock to stabilize oom_killer_disabled
  * and mark_oom_victim
  */
-DEFINE_MUTEX(oom_lock);
+static DEFINE_SPINLOCK(oom_disable_lock);
 
 #ifdef CONFIG_NUMA
 /**
@@ -430,7 +426,10 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 
 static void dump_oom_summary(struct oom_control *oc, struct task_struct *victim)
 {
+	static DEFINE_SPINLOCK(lock);
+
 	/* one line summary of the oom killer context. */
+	spin_lock(&lock);
 	pr_info("oom-kill:constraint=%s,nodemask=%*pbl",
 			oom_constraint_text[oc->constraint],
 			nodemask_pr_args(oc->nodemask));
@@ -438,6 +437,7 @@ static void dump_oom_summary(struct oom_control *oc, struct task_struct *victim)
 	mem_cgroup_print_oom_context(oc->memcg, victim);
 	pr_cont(",task=%s,pid=%d,uid=%d\n", victim->comm, victim->pid,
 		from_kuid(&init_user_ns, task_uid(victim)));
+	spin_unlock(&lock);
 }
 
 static void dump_header(struct oom_control *oc, struct task_struct *p)
@@ -677,9 +677,6 @@ static inline void wake_oom_reaper(struct task_struct *tsk)
  * mark_oom_victim - mark the given task as OOM victim
  * @tsk: task to mark
  *
- * Has to be called with oom_lock held and never after
- * oom has been disabled already.
- *
  * tsk->mm has to be non NULL and caller has to guarantee it is stable (either
  * under task_lock or operate on the current).
  */
@@ -687,11 +684,6 @@ static void mark_oom_victim(struct task_struct *tsk)
 {
 	struct mm_struct *mm = tsk->mm;
 
-	WARN_ON(oom_killer_disabled);
-	/* OOM killer might race with memcg OOM */
-	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
-		return;
-
 	/* oom_mm is bound to the signal struct life time. */
 	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm)) {
 		mmgrab(tsk->signal->oom_mm);
@@ -704,8 +696,14 @@ static void mark_oom_victim(struct task_struct *tsk)
 	 * any memory and livelock. freezing_slow_path will tell the freezer
 	 * that TIF_MEMDIE tasks should be ignored.
 	 */
-	__thaw_task(tsk);
-	atomic_inc(&oom_victims);
+	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
+		return;
+	spin_lock(&oom_disable_lock);
+	if (!oom_killer_disabled) {
+		__thaw_task(tsk);
+		atomic_inc(&oom_victims);
+	}
+	spin_unlock(&oom_disable_lock);
 	trace_mark_victim(tsk->pid);
 }
 
@@ -752,10 +750,9 @@ bool oom_killer_disable(signed long timeout)
 	 * Make sure to not race with an ongoing OOM killer. Check that the
 	 * current is not killed (possibly due to sharing the victim's memory).
 	 */
-	if (mutex_lock_killable(&oom_lock))
-		return false;
+	spin_lock(&oom_disable_lock);
 	oom_killer_disabled = true;
-	mutex_unlock(&oom_lock);
+	spin_unlock(&oom_disable_lock);
 
 	ret = wait_event_interruptible_timeout(oom_victims_wait,
 			!atomic_read(&oom_victims), timeout);
@@ -942,7 +939,9 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	struct task_struct *victim = oc->chosen;
 	struct mem_cgroup *oom_group;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
-					      DEFAULT_RATELIMIT_BURST);
+				      DEFAULT_RATELIMIT_BURST);
+	static DEFINE_MUTEX(oom_lock);
+	bool locked;
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -959,6 +958,20 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	}
 	task_unlock(victim);
 
+	/*
+	 * Try to yield CPU time for dump_header(). But tolerate mixed printk()
+	 * output if current thread was killed, for exiting quickly is better.
+	 */
+	locked = !mutex_lock_killable(&oom_lock);
+	/*
+	 * Try to avoid reporting same OOM victim for multiple times, for
+	 * concurrently allocating threads are waiting (after selecting the
+	 * same OOM victim) at mutex_lock_killable() above.
+	 */
+	if (tsk_is_oom_victim(victim)) {
+		put_task_struct(victim);
+		goto done;
+	}
 	if (__ratelimit(&oom_rs))
 		dump_header(oc, victim);
 
@@ -980,6 +993,9 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 				      (void*)message);
 		mem_cgroup_put(oom_group);
 	}
+ done:
+	if (locked)
+		mutex_unlock(&oom_lock);
 }
 
 /*
@@ -1032,16 +1048,54 @@ int unregister_oom_notifier(struct notifier_block *nb)
  */
 bool out_of_memory(struct oom_control *oc)
 {
-	unsigned long freed = 0;
 	enum oom_constraint constraint = CONSTRAINT_NONE;
 
 	if (oom_killer_disabled)
 		return false;
 
 	if (!is_memcg_oom(oc)) {
-		blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
-		if (freed > 0)
-			/* Got some memory back in the last second. */
+		/*
+		 * This mutex makes sure that concurrently allocating threads
+		 * yield CPU time for the OOM notifier reclaim attempt.
+		 *
+		 * Since currently we are not doing the last second allocation
+		 * attempt after the OOM notifier reclaim attempt, we need to
+		 * use heuristically decreasing last_freed for concurrently
+		 * allocating threads (which can become dozens to hundreds).
+		 */
+		static DEFINE_MUTEX(lock);
+		static unsigned long last_freed;
+		unsigned long freed;
+
+		if (mutex_trylock(&lock)) {
+			last_freed /= 2;
+			freed = last_freed;
+force_notify:
+			blocking_notifier_call_chain(&oom_notify_list, 0,
+						     &freed);
+			last_freed = freed;
+			mutex_unlock(&lock);
+		} else if (mutex_lock_killable(&lock) == 0) {
+			/*
+			 * If someone is waiting at mutex_lock_killable() here,
+			 * mutex_trylock() above can't succeed. Therefore,
+			 * although this path should be fast enough, let's be
+			 * prepared for the worst case where nobody can update
+			 * last_freed from mutex_trylock() path above.
+			 */
+			if (!last_freed)
+				goto force_notify;
+			freed = last_freed--;
+			mutex_unlock(&lock);
+		} else {
+			/*
+			 * If killable wait failed, task_will_free_mem(current)
+			 * below likely returns true. Therefore, just fall
+			 * through here.
+			 */
+			freed = 0;
+		}
+		if (freed)
 			return true;
 	}
 
@@ -1104,8 +1158,7 @@ bool out_of_memory(struct oom_control *oc)
 
 /*
  * The pagefault handler calls here because it is out of memory, so kill a
- * memory-hogging task. If oom_lock is held by somebody else, a parallel oom
- * killing is already in progress so do nothing.
+ * memory-hogging task.
  */
 void pagefault_out_of_memory(void)
 {
@@ -1120,8 +1173,5 @@ void pagefault_out_of_memory(void)
 	if (mem_cgroup_oom_synchronize(true))
 		return;
 
-	if (!mutex_trylock(&oom_lock))
-		return;
 	out_of_memory(&oc);
-	mutex_unlock(&oom_lock);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5ff93ad..dce737e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3775,24 +3775,11 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	*did_some_progress = 0;
 
 	/*
-	 * Acquire the oom lock.  If that fails, somebody else is
-	 * making progress for us.
-	 */
-	if (!mutex_trylock(&oom_lock)) {
-		*did_some_progress = 1;
-		schedule_timeout_uninterruptible(1);
-		return NULL;
-	}
-
-	/*
 	 * Go through the zonelist yet one more time, keep very high watermark
 	 * here, this is only to catch a parallel oom killing, we must fail if
-	 * we're still under heavy pressure. But make sure that this reclaim
-	 * attempt shall not depend on __GFP_DIRECT_RECLAIM && !__GFP_NORETRY
-	 * allocation which will never fail due to oom_lock already held.
+	 * we're still under heavy pressure.
 	 */
-	page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
-				      ~__GFP_DIRECT_RECLAIM, order,
+	page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL), order,
 				      ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
 	if (page)
 		goto out;
@@ -3843,7 +3830,6 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 					ALLOC_NO_WATERMARKS, ac);
 	}
 out:
-	mutex_unlock(&oom_lock);
 	return page;
 }
 
-- 
1.8.3.1

