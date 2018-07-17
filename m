Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A23736B0010
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 00:14:32 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id t26-v6so2858059pfh.0
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 21:14:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m24-v6sor8984574pgd.251.2018.07.16.21.14.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Jul 2018 21:14:31 -0700 (PDT)
Date: Mon, 16 Jul 2018 21:14:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] mm, oom: remove oom_lock from exit_mmap
In-Reply-To: <20180713142612.GD19960@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1807162111490.157949@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1807121432370.170100@chino.kir.corp.google.com> <20180713142612.GD19960@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 13 Jul 2018, Michal Hocko wrote:

> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 0fe4087d5151..e6328cef090f 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -488,9 +488,11 @@ void __oom_reap_task_mm(struct mm_struct *mm)
> >  	 * Tell all users of get_user/copy_from_user etc... that the content
> >  	 * is no longer stable. No barriers really needed because unmapping
> >  	 * should imply barriers already and the reader would hit a page fault
> > -	 * if it stumbled over a reaped memory.
> > +	 * if it stumbled over a reaped memory. If MMF_UNSTABLE is already set,
> > +	 * reaping as already occurred so nothing left to do.
> >  	 */
> > -	set_bit(MMF_UNSTABLE, &mm->flags);
> > +	if (test_and_set_bit(MMF_UNSTABLE, &mm->flags))
> > +		return;
> 
> This could lead to pre mature oom victim selection
> oom_reaper			exiting victim
> oom_reap_task			exit_mmap
>   __oom_reap_task_mm		  __oom_reap_task_mm
> 				    test_and_set_bit(MMF_UNSTABLE) # wins the race
>   test_and_set_bit(MMF_UNSTABLE)
> set_bit(MMF_OOM_SKIP) # new victim can be selected now.
> 

This is not the current state of the code in the -mm tree: MMF_OOM_SKIP 
only gets set by the oom reaper when the timeout has expired when the 
victim has failed to free memory in the exit path.

> Besides that, why should we back off in the first place. We can
> race the two without any problems AFAICS. We already do have proper
> synchronization between the two due to mmap_sem and MMF_OOM_SKIP.
> 

test_and_set_bit() here is not strictly required, I thought it was better 
since any unmapping done in this context is going to be handled by 
whichever thread set MMF_UNSTABLE.
