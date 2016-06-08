Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 94D296B025F
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 18:27:24 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id t8so22875885oif.2
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 15:27:24 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s133si1861803oig.13.2016.06.08.15.27.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Jun 2016 15:27:23 -0700 (PDT)
Subject: Re: [PATCH] oom_reaper: avoid pointless atomic_inc_not_zero usage.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1465024759-8074-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160606141340.86c96c1d3dc29823438313d9@linux-foundation.org>
	<20160608100418.33b7566b08de7223b2dc2986@linux-foundation.org>
In-Reply-To: <20160608100418.33b7566b08de7223b2dc2986@linux-foundation.org>
Message-Id: <201606090727.EHB64549.LFFMOVtSHJOOFQ@I-love.SAKURA.ne.jp>
Date: Thu, 9 Jun 2016 07:27:03 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org, mhocko@suse.com, arnd@arndb.de

Andrew Morton wrote:
> On Mon, 6 Jun 2016 14:13:40 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Sat,  4 Jun 2016 16:19:19 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> > 
> > > Since commit 36324a990cf578b5 ("oom: clear TIF_MEMDIE after oom_reaper
> > > managed to unmap the address space") changed to use find_lock_task_mm()
> > > for finding a mm_struct to reap, it is guaranteed that mm->mm_users > 0
> > > because find_lock_task_mm() returns a task_struct with ->mm != NULL.
> > > Therefore, we can safely use atomic_inc().
> > > 
> > > ...
> > >
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -474,13 +474,8 @@ static bool __oom_reap_task(struct task_struct *tsk)
> > >  	p = find_lock_task_mm(tsk);
> > >  	if (!p)
> > >  		goto unlock_oom;
> > > -
> > >  	mm = p->mm;
> > > -	if (!atomic_inc_not_zero(&mm->mm_users)) {
> > > -		task_unlock(p);
> > > -		goto unlock_oom;
> > > -	}
> > > -
> > > +	atomic_inc(&mm->mm_users);
> > >  	task_unlock(p);
> > >  
> > >  	if (!down_read_trylock(&mm->mmap_sem)) {
> > 
> > In an off-list email (please don't do that!) you asked me to replace
> > mmoom_reaper-dont-call-mmput_async-without-atomic_inc_not_zero.patch
> > with this above patch.
> > 
> > But the
> > mmoom_reaper-dont-call-mmput_async-without-atomic_inc_not_zero.patch
> > changelog is pretty crappy:
> > 
> > : Commit e2fe14564d3316d1 ("oom_reaper: close race with exiting task")
> > : reduced frequency of needlessly selecting next OOM victim, but was
> > : calling mmput_async() when atomic_inc_not_zero() failed.
> > 
> > because it doesn't explain that the patch potentially fixes a kernel
> > crash.
> > 
> > And the changelog for this above patch is similarly crappy - it fails
> > to described the end-user visible effects of the bug which is being
> > fixed.  Please *always* do this.  Always always always.
> > 
> > Please send me a complete changelog for this patch, thanks.
> 
> Ping?  Can we have a better changelog on this one?
> 
> That changelog will help us to decide whether to backport this into
> 4.6.x.
> 
No need to backport. There was no possibility of kernel crash from the
beginning. What I thought it might cause a problem did not exist.
We just forgot to convert atomic_inc_not_zero() to atomic_inc().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
