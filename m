Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id AB42D6B025E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 13:04:20 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id h144so30034003ita.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 10:04:20 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id fn4si2172178pac.157.2016.06.08.10.04.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 10:04:19 -0700 (PDT)
Date: Wed, 8 Jun 2016 10:04:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] oom_reaper: avoid pointless atomic_inc_not_zero usage.
Message-Id: <20160608100418.33b7566b08de7223b2dc2986@linux-foundation.org>
In-Reply-To: <20160606141340.86c96c1d3dc29823438313d9@linux-foundation.org>
References: <1465024759-8074-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160606141340.86c96c1d3dc29823438313d9@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Arnd Bergmann <arnd@arndb.de>

On Mon, 6 Jun 2016 14:13:40 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> On Sat,  4 Jun 2016 16:19:19 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> 
> > Since commit 36324a990cf578b5 ("oom: clear TIF_MEMDIE after oom_reaper
> > managed to unmap the address space") changed to use find_lock_task_mm()
> > for finding a mm_struct to reap, it is guaranteed that mm->mm_users > 0
> > because find_lock_task_mm() returns a task_struct with ->mm != NULL.
> > Therefore, we can safely use atomic_inc().
> > 
> > ...
> >
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -474,13 +474,8 @@ static bool __oom_reap_task(struct task_struct *tsk)
> >  	p = find_lock_task_mm(tsk);
> >  	if (!p)
> >  		goto unlock_oom;
> > -
> >  	mm = p->mm;
> > -	if (!atomic_inc_not_zero(&mm->mm_users)) {
> > -		task_unlock(p);
> > -		goto unlock_oom;
> > -	}
> > -
> > +	atomic_inc(&mm->mm_users);
> >  	task_unlock(p);
> >  
> >  	if (!down_read_trylock(&mm->mmap_sem)) {
> 
> In an off-list email (please don't do that!) you asked me to replace
> mmoom_reaper-dont-call-mmput_async-without-atomic_inc_not_zero.patch
> with this above patch.
> 
> But the
> mmoom_reaper-dont-call-mmput_async-without-atomic_inc_not_zero.patch
> changelog is pretty crappy:
> 
> : Commit e2fe14564d3316d1 ("oom_reaper: close race with exiting task")
> : reduced frequency of needlessly selecting next OOM victim, but was
> : calling mmput_async() when atomic_inc_not_zero() failed.
> 
> because it doesn't explain that the patch potentially fixes a kernel
> crash.
> 
> And the changelog for this above patch is similarly crappy - it fails
> to described the end-user visible effects of the bug which is being
> fixed.  Please *always* do this.  Always always always.
> 
> Please send me a complete changelog for this patch, thanks.

Ping?  Can we have a better changelog on this one?

That changelog will help us to decide whether to backport this into
4.6.x.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
