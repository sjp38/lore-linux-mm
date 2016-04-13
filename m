Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0DC94828DF
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 09:09:01 -0400 (EDT)
Received: by mail-wm0-f48.google.com with SMTP id n3so77142057wmn.0
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 06:09:01 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id z69si29288843wmz.108.2016.04.13.06.08.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Apr 2016 06:08:59 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id n3so13855358wmn.1
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 06:08:59 -0700 (PDT)
Date: Wed, 13 Apr 2016 15:08:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] oom: consider multi-threaded tasks in task_will_free_mem
Message-ID: <20160413130858.GI14351@dhcp22.suse.cz>
References: <1460452756-15491-1-git-send-email-mhocko@kernel.org>
 <570E27D6.9060908@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <570E27D6.9060908@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 13-04-16 20:04:54, Tetsuo Handa wrote:
> On 2016/04/12 18:19, Michal Hocko wrote:
[...]
> > Hi,
> > I hope I got it right but I would really appreciate if Oleg found some
> > time and double checked after me. The fix is more cosmetic than anything
> > else but I guess it is worth it.
> 
> I don't know what
> 
>     fatal_signal_pending() can be true because of SIGNAL_GROUP_COREDUMP so
>     out_of_memory() and mem_cgroup_out_of_memory() shouldn't blindly trust it.
> 
> in commit d003f371b270 is saying (how SIGNAL_GROUP_COREDUMP can make
> fatal_signal_pending() true when fatal_signal_pending() is defined as

I guess this is about zap_process() but Olge would be more appropriate
to clarify. Anyway I fail to see how this is realted to this particular
patch.

[...]

> > diff --git a/include/linux/oom.h b/include/linux/oom.h
> > index 628a43242a34..b09c7dc523ff 100644
> > --- a/include/linux/oom.h
> > +++ b/include/linux/oom.h
> > @@ -102,13 +102,24 @@ extern struct task_struct *find_lock_task_mm(struct task_struct *p);
> >  
> >  static inline bool task_will_free_mem(struct task_struct *task)
> >  {
> > +	struct signal_struct *sig = task->signal;
> > +
> >  	/*
> >  	 * A coredumping process may sleep for an extended period in exit_mm(),
> >  	 * so the oom killer cannot assume that the process will promptly exit
> >  	 * and release memory.
> >  	 */
> > -	return (task->flags & PF_EXITING) &&
> > -		!(task->signal->flags & SIGNAL_GROUP_COREDUMP);
> > +	if (sig->flags & SIGNAL_GROUP_COREDUMP)
> > +		return false;
> > +
> > +	if (!(task->flags & PF_EXITING))
> > +		return false;
> > +
> > +	/* Make sure that the whole thread group is going down */
> > +	if (!thread_group_empty(task) && !(sig->flags & SIGNAL_GROUP_EXIT))
> > +		return false;
> 
> The whole thread group is going down does not mean we make sure that
> we will send SIGKILL to other thread groups sharing the same memory which
> is possibly holding mmap_sem for write, does it?

And the patch description doesn't say anything about processes sharing
mm. This is supposed to be a minor fix of an obviously suboptimal
behavior of task_will_free_mem. Can we stick to the proposed patch,
please?

If we really do care about processes sharing mm _that_much_ then it
should be handled in the separate patch.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
