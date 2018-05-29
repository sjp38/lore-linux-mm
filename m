Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 78EAC6B0007
	for <linux-mm@kvack.org>; Tue, 29 May 2018 03:17:40 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id a7-v6so12213862wrq.13
        for <linux-mm@kvack.org>; Tue, 29 May 2018 00:17:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h10-v6si11391150edr.245.2018.05.29.00.17.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 May 2018 00:17:39 -0700 (PDT)
Date: Tue, 29 May 2018 09:17:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
Message-ID: <20180529071736.GI27180@dhcp22.suse.cz>
References: <20180515091655.GD12670@dhcp22.suse.cz>
 <201805181914.IFF18202.FOJOVSOtLFMFHQ@I-love.SAKURA.ne.jp>
 <20180518122045.GG21711@dhcp22.suse.cz>
 <201805210056.IEC51073.VSFFHFOOQtJMOL@I-love.SAKURA.ne.jp>
 <20180522061850.GB20020@dhcp22.suse.cz>
 <201805231924.EED86916.FSQJMtHOLVOFOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201805231924.EED86916.FSQJMtHOLVOFOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: guro@fb.com, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

On Wed 23-05-18 19:24:48, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > I don't understand why you are talking about PF_WQ_WORKER case.
> > 
> > Because that seems to be the reason to have it there as per your
> > comment.
> 
> OK. Then, I will fold below change into my patch.
> 
>         if (did_some_progress) {
>                 no_progress_loops = 0;
>  +              /*
> -+               * This schedule_timeout_*() serves as a guaranteed sleep for
> -+               * PF_WQ_WORKER threads when __zone_watermark_ok() == false.
> ++               * Try to give the OOM killer/reaper/victims some time for
> ++               * releasing memory.
>  +               */
>  +              if (!tsk_is_oom_victim(current))
>  +                      schedule_timeout_uninterruptible(1);
> 
> But Roman, my patch conflicts with your "mm, oom: cgroup-aware OOM killer" patch
> in linux-next. And it seems to me that your patch contains a bug which leads to
> premature memory allocation failure explained below.
> 
> @@ -1029,6 +1050,7 @@ bool out_of_memory(struct oom_control *oc)
>  {
>         unsigned long freed = 0;
>         enum oom_constraint constraint = CONSTRAINT_NONE;
> +       bool delay = false; /* if set, delay next allocation attempt */
> 
>         if (oom_killer_disabled)
>                 return false;
> @@ -1073,27 +1095,39 @@ bool out_of_memory(struct oom_control *oc)
>             current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
>             current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
>                 get_task_struct(current);
> -               oc->chosen = current;
> +               oc->chosen_task = current;
>                 oom_kill_process(oc, "Out of memory (oom_kill_allocating_task)");
>                 return true;
>         }
> 
> +       if (mem_cgroup_select_oom_victim(oc)) {
> 
> /* mem_cgroup_select_oom_victim() returns true if select_victim_memcg() made
>    oc->chosen_memcg != NULL.
>    select_victim_memcg() makes oc->chosen_memcg = INFLIGHT_VICTIM if there is
>    inflight memcg. But oc->chosen_task remains NULL because it did not call
>    oom_evaluate_task(), didn't it? (And if it called oom_evaluate_task(),
>    put_task_struct() is missing here.) */
> 
> +               if (oom_kill_memcg_victim(oc)) {
> 
> /* oom_kill_memcg_victim() returns true if oc->chosen_memcg == INFLIGHT_VICTIM. */
> 
> +                       delay = true;
> +                       goto out;
> +               }
> +       }
> +
>         select_bad_process(oc);
>         /* Found nothing?!?! Either we hang forever, or we panic. */
> -       if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
> +       if (!oc->chosen_task && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
>                 dump_header(oc, NULL);
>                 panic("Out of memory and no killable processes...\n");
>         }
> -       if (oc->chosen && oc->chosen != (void *)-1UL) {
> +       if (oc->chosen_task && oc->chosen_task != (void *)-1UL) {
>                 oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
>                                  "Memory cgroup out of memory");
> -               /*
> -                * Give the killed process a good chance to exit before trying
> -                * to allocate memory again.
> -                */
> -               schedule_timeout_killable(1);
> +               delay = true;
>         }
> -       return !!oc->chosen;
> +
> +out:
> +       /*
> +        * Give the killed process a good chance to exit before trying
> +        * to allocate memory again.
> +        */
> +       if (delay)
> +               schedule_timeout_killable(1);
> +
> 
> /* out_of_memory() returns false because oc->chosen_task remains NULL. */
> 
> +       return !!oc->chosen_task;
>  }
> 

What about this fix Roman?
---
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 565e7da55318..fc06af041447 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1174,7 +1174,7 @@ bool out_of_memory(struct oom_control *oc)
 	if (delay)
 		schedule_timeout_killable(1);
 
-	return !!oc->chosen_task;
+	return !!(oc->chosen_task | oc->chosen_memcg);
 }
 
 /*
-- 
Michal Hocko
SUSE Labs
