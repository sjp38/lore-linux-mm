Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 00AD96B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 05:23:29 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c82so67182422wme.2
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 02:23:28 -0700 (PDT)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id r129si262954wma.1.2016.06.27.02.23.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jun 2016 02:23:27 -0700 (PDT)
Received: by mail-wm0-f53.google.com with SMTP id v199so91769870wmv.0
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 02:23:27 -0700 (PDT)
Date: Mon, 27 Jun 2016 11:23:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
 TIF_MEMDIE
Message-ID: <20160627092326.GD31799@dhcp22.suse.cz>
References: <1466766121-8164-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160624215627.GA1148@redhat.com>
 <201606251444.EGJ69787.FtMOFJOLSHFQOV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606251444.EGJ69787.FtMOFJOLSHFQOV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: oleg@redhat.com, linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

On Sat 25-06-16 14:44:39, Tetsuo Handa wrote:
> Oleg Nesterov wrote:
> > Since I mentioned TIF_MEMDIE in another thread, I simply can't resist.
> > Sorry for grunting.
> > 
> > On 06/24, Tetsuo Handa wrote:
> > >
> > > --- a/include/linux/sched.h
> > > +++ b/include/linux/sched.h
> > > @@ -801,6 +801,7 @@ struct signal_struct {
> > >  	 * oom
> > >  	 */
> > >  	bool oom_flag_origin;
> > > +	bool oom_ignore_victims;        /* Ignore oom_victims value */
> > >  	short oom_score_adj;		/* OOM kill score adjustment */
> > >  	short oom_score_adj_min;	/* OOM kill score adjustment min value.
> > >  					 * Only settable by CAP_SYS_RESOURCE. */
> > 
> > Yet another kludge to fix yet another problem with TIF_MEMDIE. Not
> > to mention that that wh
> > 
> > Can't we state the fact TIF_MEMDIE is just broken? The very idea imo.
> 
> Yes. TIF_MEMDIE is a trouble maker.
> 
> Setting TIF_MEMDIE is per task_struct operation.
> Sending SIGKILL is per signal_struct operation.
> OOM killer is per mm_struct operation.

Yes this is really unfortunate. I am trying to converge to per mm
behavior as much as possible. We are getting there slowly but not yet
there.

[...]
> > Just one question. Why do we need this bit outside of oom-kill.c? It
> > affects page_alloc.c and this probably makes sense. But who get this
> > flag when we decide to kill the memory hog? A random thread foung by
> > find_lock_task_mm(), iow a random thread with ->mm != NULL, likely the
> > group leader. This simply can not be right no matter what.
> 
> I agree that setting TIF_MEMDIE to only first ->mm != NULL thread
> does not make sense.

Well the idea was that other threads will get TIF_MEMDIE if they need to
allocate and the initial thread (usually the group leader) will hold off
any other oom killing until it gets past its mmput. So the flag acts
both as memory reserve access key and the exclusion. I am not sure
setting the flag to all threads in the same thread group would help all
that much. Processes sharing the mm outside of the thread group should
behave in a similar way. The general reluctance to give access to all
threads was to prevent from thundering herd effect which is more likely
that way.

[...]

> > And in any case I don't understand this patch but I have to admit that
> > I failed to force myself to read the changelog and the actual change ;)
> > In any case I agree that we should not set MMF_MEMDIE if ->mm == NULL,
> > and if we ensure this then I do not understand why we can't rely on
> > MMF_OOM_REAPED. Ignoring the obvious races, if ->oom_victims != 0 then
> > find_lock_task_mm() should succed.
> 
> Since we are using
> 
>   mm = current->mm;
>   current->mm = NULL;
>   __mmput(mm); (may block for unbounded period waiting for somebody else's memory allocation)
>   exit_oom_victim(current);
> 
> sequence, we won't be able to make find_lock_task_mm(tsk) != NULL when
> tsk->signal->oom_victims != 0 unless we change this sequence.
> My patch tries to rescue it using tsk->signal->oom_ignore_victims flag.

I was thinking about this some more and I think that a better approach
would be to not forget the mm during the exit. The whole find_lock_task_mm
sounds like a workaround than a real solution. I am trying to understand
why do we really have to reset the current->mm to NULL during the exit.
If we cannot change this then we can at least keep a stable mm
somewhere. The code would get so much easier that way.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
