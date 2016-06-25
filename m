Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DFB4A6B0005
	for <linux-mm@kvack.org>; Sat, 25 Jun 2016 01:44:48 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so281979331pfa.2
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 22:44:48 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a63si11387366pfb.33.2016.06.24.22.44.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Jun 2016 22:44:48 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear TIF_MEMDIE
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1466766121-8164-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160624215627.GA1148@redhat.com>
In-Reply-To: <20160624215627.GA1148@redhat.com>
Message-Id: <201606251444.EGJ69787.FtMOFJOLSHFQOV@I-love.SAKURA.ne.jp>
Date: Sat, 25 Jun 2016 14:44:39 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: oleg@redhat.com
Cc: mhocko@kernel.org, linux-mm@kvack.org, mhocko@suse.com, vdavydov@virtuozzo.com, rientjes@google.com

Oleg Nesterov wrote:
> Since I mentioned TIF_MEMDIE in another thread, I simply can't resist.
> Sorry for grunting.
> 
> On 06/24, Tetsuo Handa wrote:
> >
> > --- a/include/linux/sched.h
> > +++ b/include/linux/sched.h
> > @@ -801,6 +801,7 @@ struct signal_struct {
> >  	 * oom
> >  	 */
> >  	bool oom_flag_origin;
> > +	bool oom_ignore_victims;        /* Ignore oom_victims value */
> >  	short oom_score_adj;		/* OOM kill score adjustment */
> >  	short oom_score_adj_min;	/* OOM kill score adjustment min value.
> >  					 * Only settable by CAP_SYS_RESOURCE. */
> 
> Yet another kludge to fix yet another problem with TIF_MEMDIE. Not
> to mention that that wh
> 
> Can't we state the fact TIF_MEMDIE is just broken? The very idea imo.

Yes. TIF_MEMDIE is a trouble maker.

Setting TIF_MEMDIE is per task_struct operation.
Sending SIGKILL is per signal_struct operation.
OOM killer is per mm_struct operation.

> I am starting to seriously think we should kill this flag, fix the
> compilation errors, remove the dead code (including the oom_victims
> logic), and then try to add something else. Say, even MMF_MEMDIE looks
> better although I understand it is not that simple.

I wish that TIF_MEMDIE is per signal_struct flag. But since we allow
mm-less TIF_MEMDIE thread to use ALLOC_NO_WATERMARKS via TIF_MEMDIE
inside __mmput() from mmput() from exit_mm() from do_exit(), we can't
replace

  test_thread_flag(TIF_MEMDIE)

in gfp_to_alloc_flags() with

  current->signal->oom_killed

or

  current->mm && (current->mm->flags & MMF_MEMDIE)

. But

> 
> Just one question. Why do we need this bit outside of oom-kill.c? It
> affects page_alloc.c and this probably makes sense. But who get this
> flag when we decide to kill the memory hog? A random thread foung by
> find_lock_task_mm(), iow a random thread with ->mm != NULL, likely the
> group leader. This simply can not be right no matter what.

I agree that setting TIF_MEMDIE to only first ->mm != NULL thread
does not make sense.

I've proposed setting TIF_MEMDIE to all ->mm != NULL threads which are
killed by the OOM killer because doing so won't increase the risk of
depleting the memory reserves, for TIF_MEMDIE helps only if that thread is
doing memory allocation
( http://lkml.kernel.org/r/1458529634-5951-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp ),
but it did not happen.

> 
> And in any case I don't understand this patch but I have to admit that
> I failed to force myself to read the changelog and the actual change ;)
> In any case I agree that we should not set MMF_MEMDIE if ->mm == NULL,
> and if we ensure this then I do not understand why we can't rely on
> MMF_OOM_REAPED. Ignoring the obvious races, if ->oom_victims != 0 then
> find_lock_task_mm() should succed.

Since we are using

  mm = current->mm;
  current->mm = NULL;
  __mmput(mm); (may block for unbounded period waiting for somebody else's memory allocation)
  exit_oom_victim(current);

sequence, we won't be able to make find_lock_task_mm(tsk) != NULL when
tsk->signal->oom_victims != 0 unless we change this sequence.
My patch tries to rescue it using tsk->signal->oom_ignore_victims flag.

> 
> Oleg.
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
