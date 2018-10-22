Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B2416B0006
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 03:59:01 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id m7-v6so37840144iop.9
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 00:59:01 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id v11si8055937itj.98.2018.10.22.00.58.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 00:59:00 -0700 (PDT)
Message-Id: <201810220758.w9M7wojE016890@www262.sakura.ne.jp>
Subject: Re: [RFC PATCH 1/2] mm, oom: marks all killed tasks as oom victims
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Mon, 22 Oct 2018 16:58:50 +0900
References: <20181022071323.9550-1-mhocko@kernel.org> <20181022071323.9550-2-mhocko@kernel.org>
In-Reply-To: <20181022071323.9550-2-mhocko@kernel.org>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

Michal Hocko wrote:
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -898,6 +898,7 @@ static void __oom_kill_process(struct task_struct *victim)
>  		if (unlikely(p->flags & PF_KTHREAD))
>  			continue;
>  		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, PIDTYPE_TGID);
> +		mark_oom_victim(p);
>  	}
>  	rcu_read_unlock();
>  
> -- 

Wrong. Either

---
 mm/oom_kill.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f10aa53..99b36ff 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -879,6 +879,8 @@ static void __oom_kill_process(struct task_struct *victim)
 	 */
 	rcu_read_lock();
 	for_each_process(p) {
+		struct task_struct *t;
+
 		if (!process_shares_mm(p, mm))
 			continue;
 		if (same_thread_group(p, victim))
@@ -898,6 +900,11 @@ static void __oom_kill_process(struct task_struct *victim)
 		if (unlikely(p->flags & PF_KTHREAD))
 			continue;
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, PIDTYPE_TGID);
+		t = find_lock_task_mm(p);
+		if (!t)
+			continue;
+		mark_oom_victim(t);
+		task_unlock(t);
 	}
 	rcu_read_unlock();
 
-- 
1.8.3.1

or

---
 mm/oom_kill.c | 32 +++++++++++++++++++-------------
 1 file changed, 19 insertions(+), 13 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f10aa53..7fa9b7c 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -854,13 +854,6 @@ static void __oom_kill_process(struct task_struct *victim)
 	count_vm_event(OOM_KILL);
 	memcg_memory_event_mm(mm, MEMCG_OOM_KILL);
 
-	/*
-	 * We should send SIGKILL before granting access to memory reserves
-	 * in order to prevent the OOM victim from depleting the memory
-	 * reserves from the user space under its control.
-	 */
-	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, PIDTYPE_TGID);
-	mark_oom_victim(victim);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
@@ -879,11 +872,23 @@ static void __oom_kill_process(struct task_struct *victim)
 	 */
 	rcu_read_lock();
 	for_each_process(p) {
-		if (!process_shares_mm(p, mm))
+		struct task_struct *t;
+
+		/*
+		 * No use_mm() user needs to read from the userspace so we are
+		 * ok to reap it.
+		 */
+		if (unlikely(p->flags & PF_KTHREAD))
+			continue;
+		t = find_lock_task_mm(p);
+		if (!t)
 			continue;
-		if (same_thread_group(p, victim))
+		if (likely(t->mm != mm)) {
+			task_unlock(t);
 			continue;
+		}
 		if (is_global_init(p)) {
+			task_unlock(t);
 			can_oom_reap = false;
 			set_bit(MMF_OOM_SKIP, &mm->flags);
 			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
@@ -892,12 +897,13 @@ static void __oom_kill_process(struct task_struct *victim)
 			continue;
 		}
 		/*
-		 * No use_mm() user needs to read from the userspace so we are
-		 * ok to reap it.
+		 * We should send SIGKILL before granting access to memory
+		 * reserves in order to prevent the OOM victim from depleting
+		 * the memory reserves from the user space under its control.
 		 */
-		if (unlikely(p->flags & PF_KTHREAD))
-			continue;
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, PIDTYPE_TGID);
+		mark_oom_victim(t);
+		task_unlock(t);
 	}
 	rcu_read_unlock();
 
-- 
1.8.3.1

will be needed.
