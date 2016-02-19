Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 10C066B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 09:37:11 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id gc3so107662397obb.3
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 06:37:11 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id w128si17033471oie.5.2016.02.19.06.37.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Feb 2016 06:37:10 -0800 (PST)
Subject: Re: [PATCH] mm: memcontrol: Pass NULL memcg for oom_badness() check.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1455889898-5659-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160219140406.GF12690@dhcp22.suse.cz>
In-Reply-To: <20160219140406.GF12690@dhcp22.suse.cz>
Message-Id: <201602192336.EJF90671.HMFLFSVOFJOtOQ@I-love.SAKURA.ne.jp>
Date: Fri, 19 Feb 2016 23:36:55 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, hannes@cmpxchg.org, vdavydov@virtuozzo.com, linux-mm@kvack.org

Michal Hocko wrote:
> On Fri 19-02-16 22:51:38, Tetsuo Handa wrote:
> > Currently, mem_cgroup_out_of_memory() is calling
> > oom_scan_process_thread(&oc, task, totalpages) which includes
> > a call to oom_unkillable_task(task, NULL, NULL) and then is
> > calling oom_badness(task, memcg, NULL, totalpages) which includes
> > a call to oom_unkillable_task(task, memcg, NULL).
> > 
> > Since for_each_mem_cgroup_tree() iterates on only tasks from the given
> > memcg hierarchy, there is no point with passing non-NULL memcg argument
> > to oom_unkillable_task() via oom_badness().
> > 
> > Replace memcg argument with NULL in order to save a call to
> > task_in_mem_cgroup(task, memcg) in oom_unkillable_task()
> > which is always true.
> 
> yes this is true but oom_badness is called from super slow path here so
> I am not sure this change will buy anything. It makes the code little
> bit more confusing because now you have to think twice (or git blame) to
> see why the memcg == NULL is really OK.
> 
> So I do not think this is an improvement. If anything wouldn't it be
> cleaner to remove memcg parameter from oom_badness altogether and
> instead do the task_in_mem_cgroup check where it is really needed?
> In other words do the check in oom_kill_process when evaluating children
> to sacrifice them?

This patch is a clarification before proposing
http://lkml.kernel.org/r/1455892411-7611-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
which converts two oom_unkillable_task() calls into one and
fixes infinite loop which will occur after we merge the OOM reaper.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
