Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4C13A6B0005
	for <linux-mm@kvack.org>; Wed, 23 May 2018 06:25:08 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id n25-v6so16706098otf.13
        for <linux-mm@kvack.org>; Wed, 23 May 2018 03:25:08 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id c130-v6si6378309oih.282.2018.05.23.03.25.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 03:25:06 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with oom_lock held.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20180515091655.GD12670@dhcp22.suse.cz>
	<201805181914.IFF18202.FOJOVSOtLFMFHQ@I-love.SAKURA.ne.jp>
	<20180518122045.GG21711@dhcp22.suse.cz>
	<201805210056.IEC51073.VSFFHFOOQtJMOL@I-love.SAKURA.ne.jp>
	<20180522061850.GB20020@dhcp22.suse.cz>
In-Reply-To: <20180522061850.GB20020@dhcp22.suse.cz>
Message-Id: <201805231924.EED86916.FSQJMtHOLVOFOF@I-love.SAKURA.ne.jp>
Date: Wed, 23 May 2018 19:24:48 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, guro@fb.com
Cc: rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

Michal Hocko wrote:
> > I don't understand why you are talking about PF_WQ_WORKER case.
> 
> Because that seems to be the reason to have it there as per your
> comment.

OK. Then, I will fold below change into my patch.

        if (did_some_progress) {
                no_progress_loops = 0;
 +              /*
-+               * This schedule_timeout_*() serves as a guaranteed sleep for
-+               * PF_WQ_WORKER threads when __zone_watermark_ok() == false.
++               * Try to give the OOM killer/reaper/victims some time for
++               * releasing memory.
 +               */
 +              if (!tsk_is_oom_victim(current))
 +                      schedule_timeout_uninterruptible(1);

But Roman, my patch conflicts with your "mm, oom: cgroup-aware OOM killer" patch
in linux-next. And it seems to me that your patch contains a bug which leads to
premature memory allocation failure explained below.

@@ -1029,6 +1050,7 @@ bool out_of_memory(struct oom_control *oc)
 {
        unsigned long freed = 0;
        enum oom_constraint constraint = CONSTRAINT_NONE;
+       bool delay = false; /* if set, delay next allocation attempt */

        if (oom_killer_disabled)
                return false;
@@ -1073,27 +1095,39 @@ bool out_of_memory(struct oom_control *oc)
            current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
            current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
                get_task_struct(current);
-               oc->chosen = current;
+               oc->chosen_task = current;
                oom_kill_process(oc, "Out of memory (oom_kill_allocating_task)");
                return true;
        }

+       if (mem_cgroup_select_oom_victim(oc)) {

/* mem_cgroup_select_oom_victim() returns true if select_victim_memcg() made
   oc->chosen_memcg != NULL.
   select_victim_memcg() makes oc->chosen_memcg = INFLIGHT_VICTIM if there is
   inflight memcg. But oc->chosen_task remains NULL because it did not call
   oom_evaluate_task(), didn't it? (And if it called oom_evaluate_task(),
   put_task_struct() is missing here.) */

+               if (oom_kill_memcg_victim(oc)) {

/* oom_kill_memcg_victim() returns true if oc->chosen_memcg == INFLIGHT_VICTIM. */

+                       delay = true;
+                       goto out;
+               }
+       }
+
        select_bad_process(oc);
        /* Found nothing?!?! Either we hang forever, or we panic. */
-       if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
+       if (!oc->chosen_task && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
                dump_header(oc, NULL);
                panic("Out of memory and no killable processes...\n");
        }
-       if (oc->chosen && oc->chosen != (void *)-1UL) {
+       if (oc->chosen_task && oc->chosen_task != (void *)-1UL) {
                oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
                                 "Memory cgroup out of memory");
-               /*
-                * Give the killed process a good chance to exit before trying
-                * to allocate memory again.
-                */
-               schedule_timeout_killable(1);
+               delay = true;
        }
-       return !!oc->chosen;
+
+out:
+       /*
+        * Give the killed process a good chance to exit before trying
+        * to allocate memory again.
+        */
+       if (delay)
+               schedule_timeout_killable(1);
+

/* out_of_memory() returns false because oc->chosen_task remains NULL. */

+       return !!oc->chosen_task;
 }

Can we apply my patch prior to your "mm, oom: cgroup-aware OOM killer" patch
(which eliminates "delay" and "out:" from your patch) so that people can easily
backport my patch? Or, do you want to apply a fix (which eliminates "delay" and
"out:" from linux-next) prior to my patch?
