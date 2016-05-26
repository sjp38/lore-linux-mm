Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 89FC86B007E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 11:25:34 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id sq19so144598953igc.0
        for <linux-mm@kvack.org>; Thu, 26 May 2016 08:25:34 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s197si3077127ois.185.2016.05.26.08.25.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 May 2016 08:25:33 -0700 (PDT)
Subject: Re: [PATCH 1/6] mm, oom: do not loop over all tasks if there are noexternal tasks sharing mm
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
	<1464266415-15558-2-git-send-email-mhocko@kernel.org>
	<201605262330.EEB52182.OtMFOJHFLOSFVQ@I-love.SAKURA.ne.jp>
	<20160526145930.GF23675@dhcp22.suse.cz>
In-Reply-To: <20160526145930.GF23675@dhcp22.suse.cz>
Message-Id: <201605270025.IAC48454.QSHOOMFOLtFJFV@I-love.SAKURA.ne.jp>
Date: Fri, 27 May 2016 00:25:23 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Thu 26-05-16 23:30:06, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > index 5bb2f7698ad7..0e33e912f7e4 100644
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -820,6 +820,13 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> > >  	task_unlock(victim);
> > >  
> > >  	/*
> > > +	 * skip expensive iterations over all tasks if we know that there
> > > +	 * are no users outside of threads in the same thread group
> > > +	 */
> > > +	if (atomic_read(&mm->mm_users) <= get_nr_threads(victim))
> > > +		goto oom_reap;
> > 
> > Is this really safe? Isn't it possible that victim thread's thread group has
> > more than atomic_read(&mm->mm_users) threads which are past exit_mm() and blocked
> > at exit_task_work() which are before __exit_signal() from release_task() from
> > exit_notify()?
> 
> You are right. The race window between exit_mm and __exit_signal is
> really large. I thought about == check instead but that wouldn't work
> for the same reason, dang, it looked so promissing.
> 
> Scratch this patch then.
> 

I think that remembering whether this mm might be shared between
multiple thread groups at clone() time (i.e. whether
clone(CLONE_VM without CLONE_SIGHAND) was ever requested on this mm)
is safe (given that that thread already got SIGKILL or is exiting).

By the way, in oom_kill_process(), how (p->flags & PF_KTHREAD) case can
become true when process_shares_mm() is true? Even if it can become true,
why can't we reap that mm? Is (p->flags & PF_KTHREAD) case only for
not to send SIGKILL rather than not to reap that mm?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
