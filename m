Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0354C6B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 04:48:04 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id v125so85681836itc.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 01:48:03 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0131.outbound.protection.outlook.com. [157.55.234.131])
        by mx.google.com with ESMTPS id w39si20656964otd.90.2016.05.30.01.48.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 30 May 2016 01:48:03 -0700 (PDT)
Date: Mon, 30 May 2016 11:47:53 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 3/6] mm, oom_adj: make sure processes sharing mm have
 same view of oom_score_adj
Message-ID: <20160530084753.GH26059@esperanza>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
 <1464266415-15558-4-git-send-email-mhocko@kernel.org>
 <20160527111803.GG27686@dhcp22.suse.cz>
 <20160527161821.GE26059@esperanza>
 <20160530070705.GD22928@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160530070705.GD22928@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, May 30, 2016 at 09:07:05AM +0200, Michal Hocko wrote:
> On Fri 27-05-16 19:18:21, Vladimir Davydov wrote:
> > On Fri, May 27, 2016 at 01:18:03PM +0200, Michal Hocko wrote:
> > ...
> > > @@ -1087,7 +1105,25 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
> > >  	unlock_task_sighand(task, &flags);
> > >  err_put_task:
> > >  	put_task_struct(task);
> > > +
> > > +	if (mm) {
> > > +		struct task_struct *p;
> > > +
> > > +		rcu_read_lock();
> > > +		for_each_process(p) {
> > > +			task_lock(p);
> > > +			if (!p->vfork_done && process_shares_mm(p, mm)) {
> > > +				p->signal->oom_score_adj = oom_adj;
> > > +				if (!legacy && has_capability_noaudit(current, CAP_SYS_RESOURCE))
> > > +					p->signal->oom_score_adj_min = (short)oom_adj;
> > > +			}
> > > +			task_unlock(p);
> > 
> > I.e. you write to /proc/pid1/oom_score_adj and get
> > /proc/pid2/oom_score_adj updated if pid1 and pid2 share mm?
> > IMO that looks unexpected from userspace pov.
> 
> How much different it is from threads in the same thread group?
> Processes sharing the mm without signals is a rather weird threading
> model isn't it?

I think so too. I wouldn't be surprised if it turned out that nobody had
ever used it. But may be there's someone out there who does.

> Currently we just lie to users about their oom_score_adj
> in this weird corner case.

Hmm, looks like a bug, but nobody has ever complained about it.

> The only exception was OOM_SCORE_ADJ_MIN
> where we really didn't kill the task but all other values are simply
> ignored in practice.
> 
> > May be, we'd better add mm->oom_score_adj and set it to the min
> > signal->oom_score_adj over all processes sharing it? This would
> > require iterating over all processes every time oom_score_adj gets
> > updated, but that's a slow path.
> 
> Not sure I understand. So you would prefer that mm->oom_score_adj might
> disagree with p->signal->oom_score_adj?

No, I wouldn't. I'd rather agree that oom_score_adj should be per mm,
because we choose the victim basing solely on mm stats.

What I mean is we don't touch p->signal->oom_score_adj of other tasks
sharing mm, but instead store minimal oom_score_adj over all tasks
sharing mm in the mm_struct whenever a task's oom_score_adj is modified.
And use mm->oom_score_adj instead of signal->oom_score_adj in oom killer
code. This would save us from any accusations of user API modifications
and it would also make the oom code a bit easier to follow IMHO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
