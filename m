Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B8AAD6B0003
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 02:13:22 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id w1-v6so3848477ply.12
        for <linux-mm@kvack.org>; Sun, 15 Jul 2018 23:13:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c4-v6si4890755pfa.285.2018.07.15.23.13.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Jul 2018 23:13:21 -0700 (PDT)
Date: Mon, 16 Jul 2018 08:13:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm] mm, oom: remove oom_lock from exit_mmap
Message-ID: <20180716061317.GA17280@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1807121432370.170100@chino.kir.corp.google.com>
 <20180713142612.GD19960@dhcp22.suse.cz>
 <44d26c25-6e09-49de-5e90-3c16115eb337@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <44d26c25-6e09-49de-5e90-3c16115eb337@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 14-07-18 06:18:58, Tetsuo Handa wrote:
> On 2018/07/13 23:26, Michal Hocko wrote:
> > On Thu 12-07-18 14:34:00, David Rientjes wrote:
> > [...]
> >> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> >> index 0fe4087d5151..e6328cef090f 100644
> >> --- a/mm/oom_kill.c
> >> +++ b/mm/oom_kill.c
> >> @@ -488,9 +488,11 @@ void __oom_reap_task_mm(struct mm_struct *mm)
> >>  	 * Tell all users of get_user/copy_from_user etc... that the content
> >>  	 * is no longer stable. No barriers really needed because unmapping
> >>  	 * should imply barriers already and the reader would hit a page fault
> >> -	 * if it stumbled over a reaped memory.
> >> +	 * if it stumbled over a reaped memory. If MMF_UNSTABLE is already set,
> >> +	 * reaping as already occurred so nothing left to do.
> >>  	 */
> >> -	set_bit(MMF_UNSTABLE, &mm->flags);
> >> +	if (test_and_set_bit(MMF_UNSTABLE, &mm->flags))
> >> +		return;
> > 
> > This could lead to pre mature oom victim selection
> > oom_reaper			exiting victim
> > oom_reap_task			exit_mmap
> >   __oom_reap_task_mm		  __oom_reap_task_mm
> > 				    test_and_set_bit(MMF_UNSTABLE) # wins the race
> >   test_and_set_bit(MMF_UNSTABLE)
> > set_bit(MMF_OOM_SKIP) # new victim can be selected now.
> > 
> > Besides that, why should we back off in the first place. We can
> > race the two without any problems AFAICS. We already do have proper
> > synchronization between the two due to mmap_sem and MMF_OOM_SKIP.
> > 
> > diff --git a/mm/mmap.c b/mm/mmap.c
> > index fc41c0543d7f..4642964f7741 100644
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -3073,9 +3073,7 @@ void exit_mmap(struct mm_struct *mm)
> >  		 * which clears VM_LOCKED, otherwise the oom reaper cannot
> >  		 * reliably test it.
> >  		 */
> > -		mutex_lock(&oom_lock);
> >  		__oom_reap_task_mm(mm);
> > -		mutex_unlock(&oom_lock);
> >  
> >  		set_bit(MMF_OOM_SKIP, &mm->flags);
> 
> David and Michal are using different version as a baseline here.
> David is making changes using timeout based back off (in linux-next.git)
> which is inappropriately trying to use MMF_UNSTABLE for two purposes.
> 
> Michal is making changes using current code (in linux.git) which does not
> address David's concern.

Yes I have based it on top of Linus tree because the point of this patch
is to get rid of the locking which is no longer needed. I do not see
what concern are you talking about.
> 
> My version ( https://marc.info/?l=linux-mm&m=153119509215026 ) is
> making changes using current code which also provides oom-badness
> based back off in order to address David's concern.
> 
> >  		down_write(&mm->mmap_sem);
> 
> Anyway, I suggest doing
> 
>   mutex_lock(&oom_lock);
>   set_bit(MMF_OOM_SKIP, &mm->flags);
>   mutex_unlock(&oom_lock);

Why do we need it?

> like I mentioned at
> http://lkml.kernel.org/r/201807130620.w6D6KiAJ093010@www262.sakura.ne.jp
> even if we make changes on top of linux-next's timeout based back off.

says
: (3) Prevent from selecting new OOM victim when there is an !MMF_OOM_SKIP mm
:     which current thread should wait for.
[...]
: Regarding (A), we can reduce the range oom_lock serializes from
: "__oom_reap_task_mm()" to "setting MMF_OOM_SKIP", for oom_lock is useful for (3).

But why there is a lock needed for this? This doesn't make much sense to
me. If we do not have MMF_OOM_SKIP set we still should have mm_is_oom_victim
so no new task should be selected. If we race with the oom reaper than
ok, we would just not select a new victim and retry later.
-- 
Michal Hocko
SUSE Labs
