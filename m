Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id C9779828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 07:20:15 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id g62so22702864wme.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 04:20:15 -0800 (PST)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id hq2si9860948wjb.240.2016.02.18.04.20.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 04:20:14 -0800 (PST)
Received: by mail-wm0-f46.google.com with SMTP id g62so22702352wme.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 04:20:14 -0800 (PST)
Date: Thu, 18 Feb 2016 13:20:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/6] mm,oom: wait for OOM victims when using
 oom_kill_allocating_task == 1
Message-ID: <20160218122012.GE18149@dhcp22.suse.cz>
References: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
 <201602171936.JDC18598.JHOFtLVOQSFMOF@I-love.SAKURA.ne.jp>
 <20160217133242.GJ29196@dhcp22.suse.cz>
 <201602181945.EDI35454.MVOHLQSOFFJOtF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602181945.EDI35454.MVOHLQSOFFJOtF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 18-02-16 19:45:45, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 17-02-16 19:36:36, Tetsuo Handa wrote:
> > > From 0b36864d4100ecbdcaa2fc2d1927c9e270f1b629 Mon Sep 17 00:00:00 2001
> > > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > Date: Wed, 17 Feb 2016 16:37:59 +0900
> > > Subject: [PATCH 6/6] mm,oom: wait for OOM victims when using oom_kill_allocating_task == 1
> > >
> > > Currently, out_of_memory() does not wait for existing TIF_MEMDIE threads
> > > if /proc/sys/vm/oom_kill_allocating_task is set to 1. This can result in
> > > killing more OOM victims than needed. We can wait for the OOM reaper to
> > > reap memory used by existing TIF_MEMDIE threads if possible. If the OOM
> > > reaper is not available, the system will be kept OOM stalled until an
> > > OOM-unkillable thread does a GFP_FS allocation request and calls
> > > oom_kill_allocating_task == 0 path.
> > >
> > > This patch changes oom_kill_allocating_task == 1 case to call
> > > select_bad_process() in order to wait for existing TIF_MEMDIE threads.
> >
> > The primary motivation for oom_kill_allocating_task was to reduce the
> > overhead of select_bad_process. See fe071d7e8aae ("oom: add
> > oom_kill_allocating_task sysctl"). So this basically defeats the whole
> > purpose of the feature.
> >
> 
> I didn't know that. But I think that printk()ing all candidates much more
> significantly degrades performance than scanning the tasklist.

I assume those who care do set oom_dump_tasks = 0.

> It would be
> nice if setting /proc/sys/vm/oom_dump_tasks = N (N > 1) shows only top N
> memory-hog processes.

You would need scanning of all tasks anyway and sorting etc... Not worth
bothering IMO.
 
[...]
> We have
> 
>   "Out of memory (oom_kill_allocating_task)"
>   "Out of memory"
>   "Memory cgroup out of memory"
> 
> but we don't have
> 
>   "Memory cgroup out of memory (oom_kill_allocating_task)"
> 
> I don't know whether we should use this condition for memcg OOM case.

memcg oom killer ignores follow oom_kill_allocating_task.
 
> >  	/*
> >  	 * If any of p's children has a different mm and is eligible for kill,
> >  	 * the one with the highest oom_badness() score is sacrificed for its
> > @@ -734,6 +737,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> >  	}
> >  	read_unlock(&tasklist_lock);
> >
> > +kill:
> >  	p = find_lock_task_mm(victim);
> >  	if (!p) {
> >  		put_task_struct(victim);
> > @@ -888,6 +892,9 @@ bool out_of_memory(struct oom_control *oc)
> >  	if (sysctl_oom_kill_allocating_task && current->mm &&
> >  	    !oom_unkillable_task(current, NULL, oc->nodemask) &&
> >  	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
> > +		if (test_thread_flag(TIF_MEMDIE))
> > +			panic("Out of memory (oom_kill_allocating_task) not able to make a forward progress");
> > +
> 
> If current thread got TIF_MEMDIE, current thread will not call out_of_memory()
> again because current thread will exit the allocation (unless __GFP_NOFAIL)
> due to use of ALLOC_NO_WATERMARKS.

exactly __GFP_NOFAIL has to be handled properly.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
