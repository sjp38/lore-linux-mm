Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8BA3C6B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 07:37:12 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c82so69977566wme.2
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 04:37:12 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id i188si13400577wma.123.2016.06.27.04.37.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jun 2016 04:37:11 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id c82so23767351wme.3
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 04:37:11 -0700 (PDT)
Date: Mon, 27 Jun 2016 13:37:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm, oom: don't set TIF_MEMDIE on a mm-less thread.
Message-ID: <20160627113709.GG31799@dhcp22.suse.cz>
References: <1466697527-7365-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <201606240124.FEI12978.OFQOSMJtOHFFLV@I-love.SAKURA.ne.jp>
 <20160624095439.GA20203@dhcp22.suse.cz>
 <201606241956.IDD09840.FSFOOVMJOHQLtF@I-love.SAKURA.ne.jp>
 <20160624120454.GB20203@dhcp22.suse.cz>
 <201606250119.IIJ30735.FMSHQFVtOLOJOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606250119.IIJ30735.FMSHQFVtOLOJOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, oleg@redhat.com, vdavydov@virtuozzo.com, rientjes@google.com

On Sat 25-06-16 01:19:12, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 4c21f744daa6..97be9324a58b 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -671,6 +671,22 @@ void mark_oom_victim(struct task_struct *tsk)
> >  	/* OOM killer might race with memcg OOM */
> >  	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
> >  		return;
> > +#ifndef CONFIG_MMU
> > +	/*
> > +	 * we shouldn't risk setting TIF_MEMDIE on a task which has passed its
> > +	 * exit_mm task->mm = NULL and exit_oom_victim otherwise it could
> > +	 * theoretically keep its TIF_MEMDIE for ever while waiting for a parent
> > +	 * to get it out of zombie state. MMU doesn't have this problem because
> > +	 * it has the oom_reaper to clear the flag asynchronously.
> > +	 */
> > +	task_lock(tsk);
> > +	if (!tsk->mm) {
> > +		clear_tsk_thread_flag(tsk, TIF_MEMDIE);
> > +		task_unlock(tsk);
> > +		return;
> > +	}
> > +	taks_unlock(tsk);
> 
> This makes mark_oom_victim(tsk) for tsk->mm == NULL a no-op unless tsk is
> currently doing memory allocation. And it is possible that tsk is blocked
> waiting for somebody else's memory allocation after returning from
> exit_mm() from do_exit(), isn't it? Then, how is this better than current
> code (i.e. sets TIF_MEMDIE to a mm-less thread group leader)?

Well, the whole point of the check is to not set the flag after we
could have passed exit_mm->exit_oom_victim and keep it for the rest of
(unbounded) victim life as there is nothing else to do so.
If the tsk is waiting for something then we are screwed same way we were
before. Or have I missed your point?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
