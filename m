Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E7D16B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 02:48:07 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id o70so19688072lfg.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 23:48:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xb5si61811687wjb.223.2016.06.01.23.48.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Jun 2016 23:48:05 -0700 (PDT)
Date: Thu, 2 Jun 2016 08:48:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm,oom_reaper: don't call mmput_async() without
 atomic_inc_not_zero()
Message-ID: <20160602064804.GF1995@dhcp22.suse.cz>
References: <1464423365-5555-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160601155313.dc3aa18eb6ad0e163d44b355@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160601155313.dc3aa18eb6ad0e163d44b355@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, Arnd Bergmann <arnd@arndb.de>

On Wed 01-06-16 15:53:13, Andrew Morton wrote:
> On Sat, 28 May 2016 17:16:05 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> 
> > Commit e2fe14564d3316d1 ("oom_reaper: close race with exiting task")
> > reduced frequency of needlessly selecting next OOM victim, but was
> > calling mmput_async() when atomic_inc_not_zero() failed.
> 
> Changelog fail.
> 
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -478,6 +478,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
> >  	mm = p->mm;
> >  	if (!atomic_inc_not_zero(&mm->mm_users)) {
> >  		task_unlock(p);
> > +		mm = NULL;
> >  		goto unlock_oom;
> >  	}
> 
> This looks like a pretty fatal bug.  I assume the result of hitting
> that race will be a kernel crash, yes?

Yes it is a nasty bug. It was (re)introduced by the final touch to the
goto paths. And yes it can cause a crash.

> Is it even possible to hit that race? 

It is, we can have a concurrent mmput followed by mmdrop.

> find_lock_task_mm() takes some
> care to prevent a NULL ->mm.  But I guess a concurrent mmput() doesn't
> require task_lock().  Kinda makes me wonder what's the point in even
> having find_lock_task_mm() if its guarantee on ->mm is useless...

find_lock_task_mm makes sure that the mm stays non-NULL while we hold
the lock. We have to do all the necessary pinning while holding it.
atomic_inc_not_zero will guarantee we are not racing with the finall
mmput.

Does that make more sense now?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
