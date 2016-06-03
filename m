Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id D73956B007E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 02:23:50 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id o70so32984378lfg.1
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 23:23:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i16si54824094wmf.117.2016.06.02.23.23.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Jun 2016 23:23:49 -0700 (PDT)
Date: Fri, 3 Jun 2016 08:23:48 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm,oom_reaper: don't call mmput_async() without
 atomic_inc_not_zero()
Message-ID: <20160603062348.GA20676@dhcp22.suse.cz>
References: <1464423365-5555-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160601155313.dc3aa18eb6ad0e163d44b355@linux-foundation.org>
 <20160602064804.GF1995@dhcp22.suse.cz>
 <201606022120.FAG39003.OFFtHOVMFSJQLO@I-love.SAKURA.ne.jp>
 <20160602131108.GP1995@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160602131108.GP1995@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, arnd@arndb.de

On Thu 02-06-16 15:11:08, Michal Hocko wrote:
> On Thu 02-06-16 21:20:03, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Wed 01-06-16 15:53:13, Andrew Morton wrote:
> [...]
> > > > Is it even possible to hit that race? 
> > > 
> > > It is, we can have a concurrent mmput followed by mmdrop.
> > > 
> > > > find_lock_task_mm() takes some
> > > > care to prevent a NULL ->mm.  But I guess a concurrent mmput() doesn't
> > > > require task_lock().  Kinda makes me wonder what's the point in even
> > > > having find_lock_task_mm() if its guarantee on ->mm is useless...
> > > 
> > > find_lock_task_mm makes sure that the mm stays non-NULL while we hold
> > > the lock. We have to do all the necessary pinning while holding it.
> > > atomic_inc_not_zero will guarantee we are not racing with the finall
> > > mmput.
> > > 
> > > Does that make more sense now?
> > 
> > what Andrew wanted to confirm is "how can it be possible that
> > mm->mm_users < 1 when there is a tsk with tsk->mm != NULL", isn't it?
> > 
> > Indeed, find_lock_task_mm() returns a tsk where tsk->mm != NULL with
> > tsk->alloc_lock held. Therefore, tsk->mm != NULL implies mm->mm_users > 0
> > until we release tsk->alloc_lock , and we can do
> > 
> >  	p = find_lock_task_mm(tsk);
> >  	if (!p)
> >  		goto unlock_oom;
> >  
> >  	mm = p->mm;
> > -	if (!atomic_inc_not_zero(&mm->mm_users)) {
> > -		task_unlock(p);
> > -		goto unlock_oom;
> > -	}
> > +	atomic_inc(&mm->mm_users);
> >  
> >  	task_unlock(p);
> > 
> > in __oom_reap_task() (unless I'm missing something).
> 
> OK, I guess you are right. Care to send a patch?

I led it rest overnight and realized on the way to work this morning
that this is a left over from the earlier approach when mm_reaper got
mm rather than a task. We used to pin mm_count in oom_kill_process so
we had to do atomic_inc_not_zero on mm_users here. Now that we used
find_lock_task_mm we indeed can simply increase mm_users while holding
the lock.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
