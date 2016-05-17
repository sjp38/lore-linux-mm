Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF9D6B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 16:28:59 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r12so16884387wme.0
        for <linux-mm@kvack.org>; Tue, 17 May 2016 13:28:59 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id n81si28585856wma.66.2016.05.17.13.28.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 13:28:58 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id n129so7663588wmn.1
        for <linux-mm@kvack.org>; Tue, 17 May 2016 13:28:58 -0700 (PDT)
Date: Tue, 17 May 2016 22:28:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] oom: consider multi-threaded tasks in task_will_free_mem
Message-ID: <20160517202856.GF12220@dhcp22.suse.cz>
References: <1460452756-15491-1-git-send-email-mhocko@kernel.org>
 <20160426135752.GC20813@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160426135752.GC20813@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 26-04-16 15:57:52, Michal Hocko wrote:
> On Tue 12-04-16 11:19:16, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > task_will_free_mem is a misnomer for a more complex PF_EXITING test
> > for early break out from the oom killer because it is believed that
> > such a task would release its memory shortly and so we do not have
> > to select an oom victim and perform a disruptive action.
> > 
> > Currently we make sure that the given task is not participating in the
> > core dumping because it might get blocked for a long time - see
> > d003f371b270 ("oom: don't assume that a coredumping thread will exit
> > soon").
> > 
> > The check can still do better though. We shouldn't consider the task
> > unless the whole thread group is going down. This is rather unlikely
> > but not impossible. A single exiting thread would surely leave all the
> > address space behind. If we are really unlucky it might get stuck on the
> > exit path and keep its TIF_MEMDIE and so block the oom killer.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> > 
> > Hi,
> > I hope I got it right but I would really appreciate if Oleg found some
> > time and double checked after me. The fix is more cosmetic than anything
> > else but I guess it is worth it.
> 
> ping...

Andrew, this is not in the mmotm tree now because I didn't feel really
confortable with the patch without Oleg seeing it. But it seems Oleg is
ok [1] with it so could you push it to Linus along with the rest of oom
pile please?

[1] http://lkml.kernel.org/r/20160517184225.GB32068@redhat.com

> > 
> > Thanks!
> > 
> >  include/linux/oom.h | 15 +++++++++++++--
> >  1 file changed, 13 insertions(+), 2 deletions(-)
> > 
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
> > +
> > +	return true;
> >  }
> >  
> >  /* sysctls */
> > -- 
> > 2.8.0.rc3
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
