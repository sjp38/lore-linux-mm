Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8EF368E00BD
	for <linux-mm@kvack.org>; Sun, 27 Jan 2019 03:37:28 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id t2so5298890edb.22
        for <linux-mm@kvack.org>; Sun, 27 Jan 2019 00:37:28 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s17si894189edr.396.2019.01.27.00.37.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Jan 2019 00:37:26 -0800 (PST)
Date: Sun, 27 Jan 2019 09:37:24 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] oom, oom_reaper: do not enqueue same task twice
Message-ID: <20190127083724.GA18811@dhcp22.suse.cz>
References: <1cdbef13-564d-61a6-95f4-579d2cad243d@gmail.com>
 <20190125163731.GJ50184@devbig004.ftw2.facebook.com>
 <a95d004a-4358-7efc-6d21-12aac4411b32@gmail.com>
 <480296c4-ed7a-3265-e84a-298e42a0f1d5@I-love.SAKURA.ne.jp>
 <6da6ca69-5a6e-a9f6-d091-f89a8488982a@gmail.com>
 <72aa8863-a534-b8df-6b9e-f69cf4dd5c4d@i-love.sakura.ne.jp>
 <33a07810-6dbc-36be-5bb6-a279773ccf69@i-love.sakura.ne.jp>
 <34e97b46-0792-cc66-e0f2-d72576cdec59@i-love.sakura.ne.jp>
 <2b0c7d6c-c58a-da7d-6f0a-4900694ec2d3@gmail.com>
 <1d161137-55a5-126f-b47e-b2625bd798ca@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1d161137-55a5-126f-b47e-b2625bd798ca@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Arkadiusz =?utf-8?Q?Mi=C5=9Bkiewicz?= <a.miskiewicz@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, Aleksa Sarai <asarai@suse.de>, Jay Kamat <jgkamat@fb.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

On Sat 26-01-19 22:10:52, Tetsuo Handa wrote:
[...]
> >From 9c9e935fc038342c48461aabca666f1b544e32b1 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sat, 26 Jan 2019 21:57:25 +0900
> Subject: [PATCH v2] oom, oom_reaper: do not enqueue same task twice
> 
> Arkadiusz reported that enabling memcg's group oom killing causes
> strange memcg statistics where there is no task in a memcg despite
> the number of tasks in that memcg is not 0. It turned out that there
> is a bug in wake_oom_reaper() which allows enqueuing same task twice
> which makes impossible to decrease the number of tasks in that memcg
> due to a refcount leak.
> 
> This bug existed since the OOM reaper became invokable from
> task_will_free_mem(current) path in out_of_memory() in Linux 4.7,
> but memcg's group oom killing made it easier to trigger this bug by
> calling wake_oom_reaper() on the same task from one out_of_memory()
> request.
> 
> Fix this bug using an approach used by commit 855b018325737f76
> ("oom, oom_reaper: disable oom_reaper for oom_kill_allocating_task").
> As a side effect of this patch, this patch also avoids enqueuing
> multiple threads sharing memory via task_will_free_mem(current) path.

Thanks for the analysis and the patch. This should work, I believe but
I am not really thrilled to overload the meaning of the MMF_UNSTABLE.
The flag is meant to signal accessing address space is not stable and it
is not aimed to synchronize oom reaper with the oom path.

Can we make use mark_oom_victim directly? I didn't get to think that
through right now so I might be missing something but this should
prevent repeating queueing as well.

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f0e8cd9edb1a..dac4f2197e53 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -690,7 +690,7 @@ static void mark_oom_victim(struct task_struct *tsk)
 	WARN_ON(oom_killer_disabled);
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
-		return;
+		return false;
 
 	/* oom_mm is bound to the signal struct life time. */
 	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm)) {
@@ -707,6 +707,8 @@ static void mark_oom_victim(struct task_struct *tsk)
 	__thaw_task(tsk);
 	atomic_inc(&oom_victims);
 	trace_mark_victim(tsk->pid);
+
+	return true;
 }
 
 /**
@@ -873,7 +875,7 @@ static void __oom_kill_process(struct task_struct *victim)
 	 * reserves from the user space under its control.
 	 */
 	do_send_sig_info(SIGKILL, SEND_SIG_PRIV, victim, PIDTYPE_TGID);
-	mark_oom_victim(victim);
+	can_oom_reap = mark_oom_victim(victim);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
@@ -954,8 +956,8 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	 */
 	task_lock(p);
 	if (task_will_free_mem(p)) {
-		mark_oom_victim(p);
-		wake_oom_reaper(p);
+		if (mark_oom_victim(p)
+			wake_oom_reaper(p);
 		task_unlock(p);
 		put_task_struct(p);
 		return;
@@ -1084,8 +1086,8 @@ bool out_of_memory(struct oom_control *oc)
 	 * quickly exit and free its memory.
 	 */
 	if (task_will_free_mem(current)) {
-		mark_oom_victim(current);
-		wake_oom_reaper(current);
+		if (mark_oom_victim(current))
+			wake_oom_reaper(current);
 		return true;
 	}
 
-- 
Michal Hocko
SUSE Labs
