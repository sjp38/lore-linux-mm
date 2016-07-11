Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF1C6B0005
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 08:50:55 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a4so69259189lfa.1
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 05:50:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 192si14960698wmf.136.2016.07.11.05.50.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Jul 2016 05:50:53 -0700 (PDT)
Date: Mon, 11 Jul 2016 14:50:51 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/6] mm,oom: Use list of mm_struct used by OOM victims.
Message-ID: <20160711125051.GF1811@dhcp22.suse.cz>
References: <201607080058.BFI87504.JtFOOFQFVHSLOM@I-love.SAKURA.ne.jp>
 <201607080103.CDH12401.LFOHStQFOOFVJM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607080103.CDH12401.LFOHStQFOOFVJM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

On Fri 08-07-16 01:03:11, Tetsuo Handa wrote:
> >From 5fbd16cffd5dc51f9ba8591fc18d315ff6ff9b96 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Fri, 8 Jul 2016 00:33:13 +0900
> Subject: [PATCH 3/6] mm,oom: Use list of mm_struct used by OOM victims.
> 
> Currently, we walk process list in order to find existing TIF_MEMDIE
> threads. But if we remember list of mm_struct used by TIF_MEMDIE threads,
> we can avoid walking process list. Next patch in this series allows
> OOM reaper to use list of mm_struct introduced by this patch.

I believe the changelog doesn't tell the whole story and it is silent
about many aspects which are not obvious at first sight. E.g. why it is
any better to iterate over all mms rather than existing tasks? This is a
slow path. Also it is quite possible to have thousands of mms linked on
the list because of many memcgs hitting the oom. Sure, highly unlikely,
but it would be better to note that this has been considered being
acceptable with an explanation why.

> This patch reverts commit e2fe14564d3316d1 ("oom_reaper: close race with
> exiting task") because oom_has_pending_mm() will prevent that race.

I guess a worth a separate patch.

> Since CONFIG_MMU=y kernel has OOM reaper callback hook which can remove
> mm_struct from the list, let the OOM reaper call exit_oom_mm(mm). This
> patch temporarily fails to call exit_oom_mm(mm) when find_lock_task_mm()
> in oom_reap_task() failed. It will be fixed by next patch.
> 
> But since CONFIG_MMU=n kernel does not have OOM reaper callback hook,
> call exit_oom_mm(mm) from __mmput(mm) if that mm is used by OOM victims.

I guess referring to the MMU configuration is more confusing than
helpful. The life time on the list is quite straightforward. mm is is
unlinked by exit_oom_mm after the address space has been unmapped from
__mmput or from the oom_reaper when available. This will guarantee that
the mm doesn't block the next oom victim selection after the memory was
reclaimed.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  include/linux/mm_types.h |  7 +++++
>  include/linux/oom.h      |  3 ++
>  kernel/fork.c            |  4 +++
>  mm/memcontrol.c          |  5 ++++
>  mm/oom_kill.c            | 72 +++++++++++++++++++++++++++++++-----------------
>  5 files changed, 66 insertions(+), 25 deletions(-)
> 
[...]
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 7926993..8e469e0 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -722,6 +722,10 @@ static inline void __mmput(struct mm_struct *mm)
>  	}
>  	if (mm->binfmt)
>  		module_put(mm->binfmt->module);
> +#ifndef CONFIG_MMU
> +	if (mm->oom_mm.victim)
> +		exit_oom_mm(mm);
> +#endif

This ifdef is not really needed. There is no reason we should wait for
the oom_reaper to unlink the mm.

>  	mmdrop(mm);
>  }
>  
[...]
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 9f0022e..87e7ff3 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -275,6 +275,28 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc,
>  }
>  #endif
>  
> +static LIST_HEAD(oom_mm_list);
> +
> +void exit_oom_mm(struct mm_struct *mm)
> +{
> +	mutex_lock(&oom_lock);
> +	list_del(&mm->oom_mm.list);
> +	put_task_struct(mm->oom_mm.victim);
> +	mm->oom_mm.victim = NULL;
> +	mmdrop(mm);
> +	mutex_unlock(&oom_lock);
> +}
> +
> +bool oom_has_pending_mm(struct mem_cgroup *memcg, const nodemask_t *nodemask)
> +{
> +	struct mm_struct *mm;
> +
> +	list_for_each_entry(mm, &oom_mm_list, oom_mm.list)
> +		if (!oom_unkillable_task(mm->oom_mm.victim, memcg, nodemask))
> +			return true;

The condition is quite hard to read. Moreover 2 of 4 conditions are
never true. Wouldn't it be better to do something like the following?

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d120cb103507..df4b2b3ad7d0 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -132,6 +132,20 @@ static inline bool is_sysrq_oom(struct oom_control *oc)
 	return oc->order == -1;
 }
 
+static bool task_in_oom_domain(struct task_struct *p,
+		struct mem_cgroup *memcg, const nodemask_t *nodemask)
+{
+	/* When mem_cgroup_out_of_memory() and p is not member of the group */
+	if (memcg && !task_in_mem_cgroup(p, memcg))
+		return false;
+
+	/* p may not have freeable memory in nodemask */
+	if (!has_intersects_mems_allowed(p, nodemask))
+		return false;
+
+	return true;
+}
+
 /* return true if the task is not adequate as candidate victim task. */
 static bool oom_unkillable_task(struct task_struct *p,
 		struct mem_cgroup *memcg, const nodemask_t *nodemask)
@@ -141,12 +155,7 @@ static bool oom_unkillable_task(struct task_struct *p,
 	if (p->flags & PF_KTHREAD)
 		return true;
 
-	/* When mem_cgroup_out_of_memory() and p is not member of the group */
-	if (memcg && !task_in_mem_cgroup(p, memcg))
-		return true;
-
-	/* p may not have freeable memory in nodemask */
-	if (!has_intersects_mems_allowed(p, nodemask))
+	if (!task_in_oom_domain(p, memcg, nodemask))
 		return true;
 
 	return false;
@@ -292,7 +301,7 @@ bool oom_has_pending_mm(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 	struct mm_struct *mm;
 
 	list_for_each_entry(mm, &oom_mm_list, oom_mm.list)
-		if (!oom_unkillable_task(mm->oom_mm.victim, memcg, nodemask))
+		if (task_in_oom_domain(mm->oom_mm.victim, memcg, nodemask))
 			return true;
 	return false;
 }

[...]
> @@ -653,6 +657,9 @@ subsys_initcall(oom_init)
>   */
>  void mark_oom_victim(struct task_struct *tsk)
>  {
> +	struct mm_struct *mm = tsk->mm;
> +	struct task_struct *old_tsk = mm->oom_mm.victim;
> +
>  	WARN_ON(oom_killer_disabled);
>  	/* OOM killer might race with memcg OOM */
>  	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
> @@ -666,6 +673,18 @@ void mark_oom_victim(struct task_struct *tsk)
>  	 */
>  	__thaw_task(tsk);
>  	atomic_inc(&oom_victims);
> +	/*
> +	 * Since mark_oom_victim() is called from multiple threads,
> +	 * connect this mm to oom_mm_list only if not yet connected.
> +	 */
> +	get_task_struct(tsk);
> +	mm->oom_mm.victim = tsk;
> +	if (!old_tsk) {
> +		atomic_inc(&mm->mm_count);
> +		list_add_tail(&mm->oom_mm.list, &oom_mm_list);
> +	} else {
> +		put_task_struct(old_tsk);
> +	}

Isn't this overcomplicated? Why do we need to replace the old task by
the current one?

>  }
>  
>  /**
> @@ -1026,6 +1045,9 @@ bool out_of_memory(struct oom_control *oc)
>  		return true;
>  	}
>  
> +	if (!is_sysrq_oom(oc) && oom_has_pending_mm(oc->memcg, oc->nodemask))
> +		return true;
> +
>  	p = select_bad_process(oc, &points, totalpages);
>  	/* Found nothing?!?! Either we hang forever, or we panic. */
>  	if (!p && !is_sysrq_oom(oc)) {
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
