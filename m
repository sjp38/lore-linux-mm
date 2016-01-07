Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4E8226B0006
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 04:15:15 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id f206so88943735wmf.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 01:15:15 -0800 (PST)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id dc4si165664665wjc.52.2016.01.07.01.15.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 01:15:14 -0800 (PST)
Received: by mail-wm0-f54.google.com with SMTP id u188so89951751wmu.1
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 01:15:13 -0800 (PST)
Date: Thu, 7 Jan 2016 10:15:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Exclude TIF_MEMDIE processes from candidates.
Message-ID: <20160107091512.GB27868@dhcp22.suse.cz>
References: <201512292258.ABF87505.OFOSJLHMFVOQFt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201512292258.ABF87505.OFOSJLHMFVOQFt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rientjes@google.com
Cc: akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 29-12-15 22:58:22, Tetsuo Handa wrote:
[...]
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 4b0a5d8..a1a0f39 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -111,6 +111,18 @@ struct task_struct *find_lock_task_mm(struct task_struct *p)
>  
>  	rcu_read_lock();
>  
> +	/*
> +	 * Treat the whole process p as unkillable when one of subthreads has
> +	 * TIF_MEMDIE pending. Otherwise, we may end up setting TIF_MEMDIE on
> +	 * the same victim forever (e.g. making SysRq-f unusable).
> +	 */
> +	for_each_thread(p, t) {
> +		if (likely(!test_tsk_thread_flag(t, TIF_MEMDIE)))
> +			continue;
> +		t = NULL;
> +		goto found;
> +	}
> +

I do not think the placement in find_lock_task_mm is desirable nor
correct. This function is used in multiple contexts outside of the oom
proper. It only returns a locked task_struct for a thread that belongs
to the process.

>  	for_each_thread(p, t) {
>  		task_lock(t);
>  		if (likely(t->mm))

What you are seeing is clearly undesirable of course but I believe we
should handle it at oom_kill_process layer. Blindly selecting a child
process even when it doesn't sit on some memory or when it has already
been killed is wrong. The heuristic is clearly too naive and so we
should touch it rather than compensating it somewhere else. What about
the following simple approach? It does two things and I will split it
up if this looks like a desirable approach. Please note I haven't tested
it because it is more of an idea than a finished thing. What do you think?
---
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 0e4af31db96f..a7c965777001 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -638,6 +638,73 @@ static bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
 }
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
+
+/*
+ * If any of victim's children has a different mm and is eligible for kill,
+ * the one with the highest oom_badness() score is sacrificed for its
+ * parent.  This attempts to lose the minimal amount of work done while
+ * still freeing memory.
+ */
+static struct task_struct *
+try_to_sacrifice_child(struct oom_control *oc, struct task_struct *victim,
+		       unsigned long totalpages, struct mem_cgroup *memcg)
+{
+	struct task_struct *child_victim = NULL;
+	unsigned int victim_points = 0;
+	struct task_struct *t;
+
+	read_lock(&tasklist_lock);
+	for_each_thread(victim, t) {
+		struct task_struct *child;
+
+		list_for_each_entry(child, &t->children, sibling) {
+			unsigned int child_points;
+
+			/*
+			 * Skip over already OOM killed children as this hasn't
+			 * helped to resolve the situation obviously.
+			 * oom_scan_process_thread would abort scanning when
+			 * seeing them but this is not the case so we must be
+			 * doing forced OOM kill and so we do not want to loop
+			 * over the same tasks again
+			 */
+			if (test_tsk_thread_flag(child, TIF_MEMDIE))
+				continue;
+
+			if (process_shares_mm(child, victim->mm))
+				continue;
+
+			child_points = oom_badness(child, memcg, oc->nodemask,
+								totalpages);
+			if (child_points > victim_points) {
+				if (child_victim)
+					put_task_struct(child_victim);
+				child_victim = child;
+				victim_points = child_points;
+				get_task_struct(child_victim);
+			}
+		}
+	}
+	read_unlock(&tasklist_lock);
+
+	if (!child_victim)
+		goto out;
+
+	/*
+	 * Protecting the parent makes sense only if killing the child
+	 * would release at least some memory (at least 1MB).
+	 */
+	if (K(victim_points) >= 1024) {
+		put_task_struct(victim);
+		victim = child_victim;
+	} else {
+		put_task_struct(child_victim);
+	}
+
+out:
+	return victim;
+}
+
 /*
  * Must be called while holding a reference to p, which will be released upon
  * returning.
@@ -647,10 +714,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 		      struct mem_cgroup *memcg, const char *message)
 {
 	struct task_struct *victim = p;
-	struct task_struct *child;
-	struct task_struct *t;
 	struct mm_struct *mm;
-	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
 	bool can_oom_reap = true;
@@ -674,34 +738,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
 		message, task_pid_nr(p), p->comm, points);
 
-	/*
-	 * If any of p's children has a different mm and is eligible for kill,
-	 * the one with the highest oom_badness() score is sacrificed for its
-	 * parent.  This attempts to lose the minimal amount of work done while
-	 * still freeing memory.
-	 */
-	read_lock(&tasklist_lock);
-	for_each_thread(p, t) {
-		list_for_each_entry(child, &t->children, sibling) {
-			unsigned int child_points;
-
-			if (process_shares_mm(child, p->mm))
-				continue;
-			/*
-			 * oom_badness() returns 0 if the thread is unkillable
-			 */
-			child_points = oom_badness(child, memcg, oc->nodemask,
-								totalpages);
-			if (child_points > victim_points) {
-				put_task_struct(victim);
-				victim = child;
-				victim_points = child_points;
-				get_task_struct(victim);
-			}
-		}
-	}
-	read_unlock(&tasklist_lock);
-
+	victim = try_to_sacrifice_child(oc, victim, totalpages, memcg);
 	p = find_lock_task_mm(victim);
 	if (!p) {
 		put_task_struct(victim);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
