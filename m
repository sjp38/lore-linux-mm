Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6E6F46B025E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 11:35:35 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 132so11766911lfz.3
        for <linux-mm@kvack.org>; Thu, 26 May 2016 08:35:35 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id b186si5462319wmc.47.2016.05.26.08.35.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 08:35:34 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id a136so6523976wme.0
        for <linux-mm@kvack.org>; Thu, 26 May 2016 08:35:34 -0700 (PDT)
Date: Thu, 26 May 2016 17:35:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/6] mm, oom: do not loop over all tasks if there are
 noexternal tasks sharing mm
Message-ID: <20160526153532.GG23675@dhcp22.suse.cz>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
 <1464266415-15558-2-git-send-email-mhocko@kernel.org>
 <201605262330.EEB52182.OtMFOJHFLOSFVQ@I-love.SAKURA.ne.jp>
 <20160526145930.GF23675@dhcp22.suse.cz>
 <201605270025.IAC48454.QSHOOMFOLtFJFV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201605270025.IAC48454.QSHOOMFOLtFJFV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Fri 27-05-16 00:25:23, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 26-05-16 23:30:06, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > > index 5bb2f7698ad7..0e33e912f7e4 100644
> > > > --- a/mm/oom_kill.c
> > > > +++ b/mm/oom_kill.c
> > > > @@ -820,6 +820,13 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> > > >  	task_unlock(victim);
> > > >  
> > > >  	/*
> > > > +	 * skip expensive iterations over all tasks if we know that there
> > > > +	 * are no users outside of threads in the same thread group
> > > > +	 */
> > > > +	if (atomic_read(&mm->mm_users) <= get_nr_threads(victim))
> > > > +		goto oom_reap;
> > > 
> > > Is this really safe? Isn't it possible that victim thread's thread group has
> > > more than atomic_read(&mm->mm_users) threads which are past exit_mm() and blocked
> > > at exit_task_work() which are before __exit_signal() from release_task() from
> > > exit_notify()?
> > 
> > You are right. The race window between exit_mm and __exit_signal is
> > really large. I thought about == check instead but that wouldn't work
> > for the same reason, dang, it looked so promissing.
> > 
> > Scratch this patch then.
> > 
> 
> I think that remembering whether this mm might be shared between
> multiple thread groups at clone() time (i.e. whether
> clone(CLONE_VM without CLONE_SIGHAND) was ever requested on this mm)
> is safe (given that that thread already got SIGKILL or is exiting).

I was already playing with that idea but I didn't want to add anything
to the fork path which is really hot. This patch is not really needed
for the rest. It just felt like a nice optimization. I do not think it
is worth deeper changes in the fast paths.

> By the way, in oom_kill_process(), how (p->flags & PF_KTHREAD) case can
> become true when process_shares_mm() is true?

not sure I understand. But the PF_KTHREAD check is there to catch
use_mm() usage by kernel threads.

> Even if it can become true,
> why can't we reap that mm? Is (p->flags & PF_KTHREAD) case only for
> not to send SIGKILL rather than not to reap that mm?

If we reaped the mm then the kernel thread could blow up when accessing
a memory.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
