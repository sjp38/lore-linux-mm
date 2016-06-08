Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2416B025E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 04:33:37 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id rs7so599785lbb.2
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 01:33:37 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id k128si16577673wmb.34.2016.06.08.01.33.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 01:33:36 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id m124so1015015wme.3
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 01:33:35 -0700 (PDT)
Date: Wed, 8 Jun 2016 10:33:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: oom: deduplicate victim selection code for memcg
 and global oom
Message-ID: <20160608083334.GF22570@dhcp22.suse.cz>
References: <40e03fd7aaf1f55c75d787128d6d17c5a71226c2.1464358556.git.vdavydov@virtuozzo.com>
 <3bbc7b70dae6ace0b8751e0140e878acfdfffd74.1464358556.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3bbc7b70dae6ace0b8751e0140e878acfdfffd74.1464358556.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 27-05-16 17:17:42, Vladimir Davydov wrote:
[...]
> @@ -970,26 +1028,25 @@ bool out_of_memory(struct oom_control *oc)
>  	    !oom_unkillable_task(current, NULL, oc->nodemask) &&
>  	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
>  		get_task_struct(current);
> -		oom_kill_process(oc, current, 0, totalpages,
> -				 "Out of memory (oom_kill_allocating_task)");
> +		oom_kill_process(oc, current, 0, totalpages);
>  		return true;
>  	}

Do we really want to introduce sysctl_oom_kill_allocating_task to memcg
as well? The heuristic is quite dubious even for the global context IMHO
because it leads to a very random behavior.
  
>  	p = select_bad_process(oc, &points, totalpages);
>  	/* Found nothing?!?! Either we hang forever, or we panic. */
> -	if (!p && !is_sysrq_oom(oc)) {
> +	if (!p && !is_sysrq_oom(oc) && !oc->memcg) {
>  		dump_header(oc, NULL);
>  		panic("Out of memory and no killable processes...\n");
>  	}
>  	if (p && p != (void *)-1UL) {
> -		oom_kill_process(oc, p, points, totalpages, "Out of memory");
> +		oom_kill_process(oc, p, points, totalpages);
>  		/*
>  		 * Give the killed process a good chance to exit before trying
>  		 * to allocate memory again.
>  		 */
>  		schedule_timeout_killable(1);
>  	}
> -	return true;
> +	return !!p;
>  }

Now if you look at out_of_memory() the only shared "heuristic" with the
memcg part is the bypass for the exiting tasks. Plus both need the
oom_lock.
You have to special case oom notifiers, panic on no victim handling and
I guess the oom_kill_allocating task is not intentional either. So I
am not really sure this is an improvement. I even hate how we conflate
sysrq vs. regular global oom context together but my cleanup for that
has failed in the past.

The victim selection code can be reduced because it is basically
shared between the two, only the iterator differs. But I guess that
can be eliminated by a simple helper.
---
 include/linux/oom.h |  5 +++++
 mm/memcontrol.c     | 47 ++++++-----------------------------------
 mm/oom_kill.c       | 60 ++++++++++++++++++++++++++++-------------------------
 3 files changed, 43 insertions(+), 69 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 606137b3b778..7b3eb253ba23 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -34,6 +34,9 @@ struct oom_control {
 	 * for display purposes.
 	 */
 	const int order;
+
+	struct task_struct *chosen;
+	unsigned long chosen_points;
 };
 
 /*
@@ -80,6 +83,8 @@ static inline void try_oom_reaper(struct task_struct *tsk)
 }
 #endif
 
+extern int oom_evaluate_task(struct oom_control *oc, struct task_struct *p,
+		unsigned long totalpages);
 extern unsigned long oom_badness(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask,
 		unsigned long totalpages);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 83a6a2b92301..9c51b4d11691 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1264,10 +1264,8 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		.order = order,
 	};
 	struct mem_cgroup *iter;
-	unsigned long chosen_points = 0;
 	unsigned long totalpages;
 	unsigned int points = 0;
-	struct task_struct *chosen = NULL;
 
 	mutex_lock(&oom_lock);
 
@@ -1289,53 +1287,20 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		struct task_struct *task;
 
 		css_task_iter_start(&iter->css, &it);
-		while ((task = css_task_iter_next(&it))) {
-			switch (oom_scan_process_thread(&oc, task)) {
-			case OOM_SCAN_SELECT:
-				if (chosen)
-					put_task_struct(chosen);
-				chosen = task;
-				chosen_points = ULONG_MAX;
-				get_task_struct(chosen);
-				/* fall through */
-			case OOM_SCAN_CONTINUE:
-				continue;
-			case OOM_SCAN_ABORT:
-				css_task_iter_end(&it);
-				mem_cgroup_iter_break(memcg, iter);
-				if (chosen)
-					put_task_struct(chosen);
-				/* Set a dummy value to return "true". */
-				chosen = (void *) 1;
-				goto unlock;
-			case OOM_SCAN_OK:
+		while ((task = css_task_iter_next(&it)))
+			if (!oom_evaluate_task(&oc, task, totalpages))
 				break;
-			};
-			points = oom_badness(task, memcg, NULL, totalpages);
-			if (!points || points < chosen_points)
-				continue;
-			/* Prefer thread group leaders for display purposes */
-			if (points == chosen_points &&
-			    thread_group_leader(chosen))
-				continue;
-
-			if (chosen)
-				put_task_struct(chosen);
-			chosen = task;
-			chosen_points = points;
-			get_task_struct(chosen);
-		}
 		css_task_iter_end(&it);
 	}
 
-	if (chosen) {
-		points = chosen_points * 1000 / totalpages;
-		oom_kill_process(&oc, chosen, points, totalpages,
+	if (oc.chosen) {
+		points = oc.chosen_points * 1000 / totalpages;
+		oom_kill_process(&oc, oc.chosen, points, totalpages,
 				 "Memory cgroup out of memory");
 	}
 unlock:
 	mutex_unlock(&oom_lock);
-	return chosen;
+	return oc.chosen;
 }
 
 #if MAX_NUMNODES > 1
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index c11f8bdd0c12..bce3ea262110 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -296,6 +296,34 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	return OOM_SCAN_OK;
 }
 
+int oom_evaluate_task(struct oom_control *oc, struct task_struct *p, unsigned long totalpages)
+{
+	unsigned long points;
+
+	switch (oom_scan_process_thread(oc, p)) {
+	case OOM_SCAN_SELECT:
+		points = ULONG_MAX;
+		goto select_task;
+	case OOM_SCAN_CONTINUE:
+		return 1;
+	case OOM_SCAN_ABORT:
+		return 0;
+	case OOM_SCAN_OK:
+		break;
+	};
+	points = oom_badness(p, oc->memcg, oc->nodemask, totalpages);
+	if (points || points < oc->chosen_points)
+		return 1;
+
+select_task:
+	if (oc->chosen)
+		put_task_struct(oc->chosen);
+	get_task_struct(p);
+	oc->chosen = p;
+	oc->chosen_points = points;
+	return 1;
+}
+
 /*
  * Simple selection loop. We chose the process with the highest
  * number of 'points'.  Returns -1 on scan abort.
@@ -304,39 +332,15 @@ static struct task_struct *select_bad_process(struct oom_control *oc,
 		unsigned int *ppoints, unsigned long totalpages)
 {
 	struct task_struct *p;
-	struct task_struct *chosen = NULL;
-	unsigned long chosen_points = 0;
 
 	rcu_read_lock();
-	for_each_process(p) {
-		unsigned int points;
-
-		switch (oom_scan_process_thread(oc, p)) {
-		case OOM_SCAN_SELECT:
-			chosen = p;
-			chosen_points = ULONG_MAX;
-			/* fall through */
-		case OOM_SCAN_CONTINUE:
-			continue;
-		case OOM_SCAN_ABORT:
-			rcu_read_unlock();
-			return (struct task_struct *)(-1UL);
-		case OOM_SCAN_OK:
+	for_each_process(p)
+		if (!oom_evaluate_task(oc, p, totalpages))
 			break;
-		};
-		points = oom_badness(p, NULL, oc->nodemask, totalpages);
-		if (!points || points < chosen_points)
-			continue;
-
-		chosen = p;
-		chosen_points = points;
-	}
-	if (chosen)
-		get_task_struct(chosen);
 	rcu_read_unlock();
 
-	*ppoints = chosen_points * 1000 / totalpages;
-	return chosen;
+	*ppoints = oc->chosen_points * 1000 / totalpages;
+	return oc->chosen;
 }
 
 /**

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
