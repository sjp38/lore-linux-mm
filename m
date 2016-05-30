Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id B0EF56B0260
	for <linux-mm@kvack.org>; Mon, 30 May 2016 06:26:55 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id w16so78377325lfd.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 03:26:55 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0113.outbound.protection.outlook.com. [104.47.1.113])
        by mx.google.com with ESMTPS id c142si29992361wmc.107.2016.05.30.03.26.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 30 May 2016 03:26:53 -0700 (PDT)
Date: Mon, 30 May 2016 13:26:44 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 3/6] mm, oom_adj: make sure processes sharing mm have
 same view of oom_score_adj
Message-ID: <20160530102644.GA8293@esperanza>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
 <1464266415-15558-4-git-send-email-mhocko@kernel.org>
 <20160527111803.GG27686@dhcp22.suse.cz>
 <20160527161821.GE26059@esperanza>
 <20160530070705.GD22928@dhcp22.suse.cz>
 <20160530084753.GH26059@esperanza>
 <20160530093950.GN22928@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160530093950.GN22928@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, May 30, 2016 at 11:39:50AM +0200, Michal Hocko wrote:
> On Mon 30-05-16 11:47:53, Vladimir Davydov wrote:
> > On Mon, May 30, 2016 at 09:07:05AM +0200, Michal Hocko wrote:
> > > On Fri 27-05-16 19:18:21, Vladimir Davydov wrote:
> > > > On Fri, May 27, 2016 at 01:18:03PM +0200, Michal Hocko wrote:
> > > > ...
> > > > > @@ -1087,7 +1105,25 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
> > > > >  	unlock_task_sighand(task, &flags);
> > > > >  err_put_task:
> > > > >  	put_task_struct(task);
> > > > > +
> > > > > +	if (mm) {
> > > > > +		struct task_struct *p;
> > > > > +
> > > > > +		rcu_read_lock();
> > > > > +		for_each_process(p) {
> > > > > +			task_lock(p);
> > > > > +			if (!p->vfork_done && process_shares_mm(p, mm)) {
> > > > > +				p->signal->oom_score_adj = oom_adj;
> > > > > +				if (!legacy && has_capability_noaudit(current, CAP_SYS_RESOURCE))
> > > > > +					p->signal->oom_score_adj_min = (short)oom_adj;
> > > > > +			}
> > > > > +			task_unlock(p);
> > > > 
> > > > I.e. you write to /proc/pid1/oom_score_adj and get
> > > > /proc/pid2/oom_score_adj updated if pid1 and pid2 share mm?
> > > > IMO that looks unexpected from userspace pov.
> > > 
> > > How much different it is from threads in the same thread group?
> > > Processes sharing the mm without signals is a rather weird threading
> > > model isn't it?
> > 
> > I think so too. I wouldn't be surprised if it turned out that nobody had
> > ever used it. But may be there's someone out there who does.
> 
> I have heard some rumors about users. But I haven't heard anything about
> their oom_score_adj usage patterns.
> 
> > > Currently we just lie to users about their oom_score_adj
> > > in this weird corner case.
> > 
> > Hmm, looks like a bug, but nobody has ever complained about it.
> 
> Yes and that leads me to a suspicion that we can do that. Maybe I should
> just add a note into the log that we are doing that so that people can
> complain? Something like the following
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index fa0b3ca94dfb..7f3495415719 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -1104,7 +1104,6 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
>  err_sighand:
>  	unlock_task_sighand(task, &flags);
>  err_put_task:
> -	put_task_struct(task);
>  
>  	if (mm) {
>  		struct task_struct *p;
> @@ -1113,6 +1112,10 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
>  		for_each_process(p) {
>  			task_lock(p);
>  			if (!p->vfork_done && process_shares_mm(p, mm)) {
> +				pr_info("updating oom_score_adj for %d (%s) from %d to %d because it shares mm with %d (%s). Report if this is unexpected.\n",
> +						task_pid_nr(p), p->comm,
> +						p->signal->oom_score_adj, oom_adj,
> +						task_pid_nr(task), task->comm);

IMO this could be acceptable from userspace pov, but I don't very much
like how vfork is special-cased here and in oom killer code.

>  				p->signal->oom_score_adj = oom_adj;
>  				if (!legacy && has_capability_noaudit(current, CAP_SYS_RESOURCE))
>  					p->signal->oom_score_adj_min = (short)oom_adj;
> @@ -1122,6 +1125,7 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
>  		rcu_read_unlock();
>  		mmdrop(mm);
>  	}
> +	put_task_struct(task);
>  out:
>  	mutex_unlock(&oom_adj_mutex);
>  	return err;
> 
> > > The only exception was OOM_SCORE_ADJ_MIN
> > > where we really didn't kill the task but all other values are simply
> > > ignored in practice.
> > > 
> > > > May be, we'd better add mm->oom_score_adj and set it to the min
> > > > signal->oom_score_adj over all processes sharing it? This would
> > > > require iterating over all processes every time oom_score_adj gets
> > > > updated, but that's a slow path.
> > > 
> > > Not sure I understand. So you would prefer that mm->oom_score_adj might
> > > disagree with p->signal->oom_score_adj?
> > 
> > No, I wouldn't. I'd rather agree that oom_score_adj should be per mm,
> > because we choose the victim basing solely on mm stats.
> > 
> > What I mean is we don't touch p->signal->oom_score_adj of other tasks
> > sharing mm, but instead store minimal oom_score_adj over all tasks
> > sharing mm in the mm_struct whenever a task's oom_score_adj is modified.
> > And use mm->oom_score_adj instead of signal->oom_score_adj in oom killer
> > code. This would save us from any accusations of user API modifications
> > and it would also make the oom code a bit easier to follow IMHO.
> 
> I understand your point but this is essentially lying because we
> consider a different value than the user can observe in userspace.
> Consider somebody doing insanity like
> 
> current->oom_score_adj = OOM_SCORE_ADJ_MIN
> p = clone(CLONE_VM)
> p->oom_score_adj = OOM_SCORE_ADJ_MAX
> 
> so one process would want to be always selected while the other one
> doesn't want to get killed. All they can see is that everything is
> put in place until the oom killer comes over and ignores that.

If we stored minimal oom_score_adj in mm struct, oom killer wouldn't
kill any of these processes, and it looks fine to me as long as we want
oom killer to be mm based, not task or signal_struct based.

Come to think of it, it'd be difficult to keep mm->oom_score_adj in sync
with p->signal->oom_score_adj, because we would need to update
mm->oom_score_adj not only on /proc write, but also on fork. May be, we
could keep all signal_structs sharing mm linked in per mm list so that
we could quickly update mm->oom_score_adj on fork? That way we wouldn't
need to special case vfork.

> 
> I think we should just be explicit. Maybe we want to treat
> OOM_SCORE_ADJ_MIN special - e.g. do not even try to set oom_score_adj if
> one of the sharing tasks is oom disabled. But I would rather wait for
> somebody to complain and explain why the usecase really makes sense than
> be all silent with implicit behavior.
> 
> Btw. we have already had per mm oom_core_adj but we had to revert it due
> to vfork behavior. See 0753ba01e126 ("mm: revert "oom: move oom_adj
> value""). This patch gets us back except it handles the vfork issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
