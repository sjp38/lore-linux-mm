Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 09C236B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 16:25:48 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id s63so16853930wme.2
        for <linux-mm@kvack.org>; Tue, 17 May 2016 13:25:47 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id 137si28594530wmp.46.2016.05.17.13.25.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 13:25:46 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id g17so1031269wme.2
        for <linux-mm@kvack.org>; Tue, 17 May 2016 13:25:46 -0700 (PDT)
Date: Tue, 17 May 2016 22:25:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] oom: consider multi-threaded tasks in task_will_free_mem
Message-ID: <20160517202544.GE12220@dhcp22.suse.cz>
References: <1460452756-15491-1-git-send-email-mhocko@kernel.org>
 <20160517184225.GB32068@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160517184225.GB32068@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 17-05-16 20:42:25, Oleg Nesterov wrote:
> On 04/12, Michal Hocko wrote:
> >
> > We shouldn't consider the task
> > unless the whole thread group is going down.
> 
> Yes, agreed. I'd even say that oom-killer should never look at individual
> task/threads, it should work with mm's. And one of the big mistakes (imo)
> was the s/for_each_process/for_each_thread/ change in select_bad_process()
> a while ago.
> 
> Michal, I won't even try to actually review this patch, I lost any hope
> to understand OOM-killer a long ago ;) But I do agree with this change,
> we obviously should not rely on PF_EXITING.
> 
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
> > +
> > +	return true;
> 
> So this looks certainly better to me, but perhaps it should do
> 
> 	if (SIGNAL_GROUP_COREDUMP)
> 		return false;
> 
> 	if (SIGNAL_GROUP_EXIT)
> 		return true;
> 
> 	if (thread_group_empty() && PF_EXITING)
> 		return true;
> 
> 	return false;
> 
> ?
> 
> I won't insist, I do not even know if this would be better or not. But if
> SIGNAL_GROUP_EXIT is set all sub-threads should go away even if PF_EXITING
> is not set yet because this task didn't dequeue SIGKILL yet.
> 
> Up to you in any case.

I have structured the checks this way because I expect I would like to
have all early break outs as false. This will help when we want to
extend those with further more specific checks. E.g. if the task is
sharing the mm with another thread group.

Anyway thanks for the review Oleg!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
