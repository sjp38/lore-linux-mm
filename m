Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 296FA6B0260
	for <linux-mm@kvack.org>; Mon, 30 May 2016 07:11:51 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id rs7so84363791lbb.2
        for <linux-mm@kvack.org>; Mon, 30 May 2016 04:11:51 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id uc3si29907964wjc.58.2016.05.30.04.11.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 04:11:49 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id n129so21554910wmn.1
        for <linux-mm@kvack.org>; Mon, 30 May 2016 04:11:49 -0700 (PDT)
Date: Mon, 30 May 2016 13:11:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/6] mm, oom_adj: make sure processes sharing mm have
 same view of oom_score_adj
Message-ID: <20160530111148.GQ22928@dhcp22.suse.cz>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
 <1464266415-15558-4-git-send-email-mhocko@kernel.org>
 <20160527111803.GG27686@dhcp22.suse.cz>
 <20160527161821.GE26059@esperanza>
 <20160530070705.GD22928@dhcp22.suse.cz>
 <20160530084753.GH26059@esperanza>
 <20160530093950.GN22928@dhcp22.suse.cz>
 <20160530102644.GA8293@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160530102644.GA8293@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 30-05-16 13:26:44, Vladimir Davydov wrote:
> On Mon, May 30, 2016 at 11:39:50AM +0200, Michal Hocko wrote:
[...]
> > Yes and that leads me to a suspicion that we can do that. Maybe I should
> > just add a note into the log that we are doing that so that people can
> > complain? Something like the following
> > diff --git a/fs/proc/base.c b/fs/proc/base.c
> > index fa0b3ca94dfb..7f3495415719 100644
> > --- a/fs/proc/base.c
> > +++ b/fs/proc/base.c
> > @@ -1104,7 +1104,6 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
> >  err_sighand:
> >  	unlock_task_sighand(task, &flags);
> >  err_put_task:
> > -	put_task_struct(task);
> >  
> >  	if (mm) {
> >  		struct task_struct *p;
> > @@ -1113,6 +1112,10 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
> >  		for_each_process(p) {
> >  			task_lock(p);
> >  			if (!p->vfork_done && process_shares_mm(p, mm)) {
> > +				pr_info("updating oom_score_adj for %d (%s) from %d to %d because it shares mm with %d (%s). Report if this is unexpected.\n",
> > +						task_pid_nr(p), p->comm,
> > +						p->signal->oom_score_adj, oom_adj,
> > +						task_pid_nr(task), task->comm);
> 
> IMO this could be acceptable from userspace pov, but I don't very much
> like how vfork is special-cased here and in oom killer code.

Well, the vfork has to be special cased here. We definitely have to
support
	vfork()
	set_oom_score_adj()
	exec()

use case. And I do not see other way without adding something to the
clone hot paths which sounds like not justifiable considering we are
talking about a really rare usecase that basically nobody cares about.
 
[...]
> > so one process would want to be always selected while the other one
> > doesn't want to get killed. All they can see is that everything is
> > put in place until the oom killer comes over and ignores that.
> 
> If we stored minimal oom_score_adj in mm struct, oom killer wouldn't
> kill any of these processes, and it looks fine to me as long as we want
> oom killer to be mm based, not task or signal_struct based.
> 
> Come to think of it, it'd be difficult to keep mm->oom_score_adj in sync
> with p->signal->oom_score_adj, because we would need to update
> mm->oom_score_adj not only on /proc write, but also on fork. May be, we
> could keep all signal_structs sharing mm linked in per mm list so that
> we could quickly update mm->oom_score_adj on fork? That way we wouldn't
> need to special case vfork.

Yes the current approach is slightly racy but I do not see that would
matter all that much. What you are suggesting might work but I am not
really sure we want to complicate the whole thing now. Sure if we see
that those races are real we can try to find a better solution, but I
would like to start as easy as possible and placing all the logic into
the oom_score_adj proc handler sounds like a good spot to me.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
