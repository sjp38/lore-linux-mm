Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 788FF6810BE
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 03:12:47 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z81so3380496wrc.2
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 00:12:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v24si1161648wrd.208.2017.07.12.00.12.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Jul 2017 00:12:46 -0700 (PDT)
Date: Wed, 12 Jul 2017 09:12:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170712071241.GA28912@dhcp22.suse.cz>
References: <20170626130346.26314-1-mhocko@kernel.org>
 <alpine.DEB.2.10.1707101652260.54972@chino.kir.corp.google.com>
 <20170711065834.GF24852@dhcp22.suse.cz>
 <alpine.DEB.2.10.1707111336250.60183@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1707111336250.60183@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Andrea Argangeli <andrea@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 11-07-17 13:40:04, David Rientjes wrote:
> On Tue, 11 Jul 2017, Michal Hocko wrote:
> 
> > This?
> > ---
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 5dc0ff22d567..e155d1d8064f 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -470,11 +470,14 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
> >  {
> >  	struct mmu_gather tlb;
> >  	struct vm_area_struct *vma;
> > -	bool ret = true;
> >  
> >  	if (!down_read_trylock(&mm->mmap_sem))
> >  		return false;
> >  
> > +	/* There is nothing to reap so bail out without signs in the log */
> > +	if (!mm->mmap)
> > +		goto unlock;
> > +
> >  	/*
> >  	 * Tell all users of get_user/copy_from_user etc... that the content
> >  	 * is no longer stable. No barriers really needed because unmapping
> > @@ -508,9 +511,10 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
> >  			K(get_mm_counter(mm, MM_ANONPAGES)),
> >  			K(get_mm_counter(mm, MM_FILEPAGES)),
> >  			K(get_mm_counter(mm, MM_SHMEMPAGES)));
> > +unlock:
> >  	up_read(&mm->mmap_sem);
> >  
> > -	return ret;
> > +	return true;
> >  }
> >  
> >  #define MAX_OOM_REAP_RETRIES 10
> 
> Yes, this folded in with the original RFC patch appears to work better 
> with light testing.

Yes folding it into the original patch was the plan. I would really
appreciate some Tested-by here.

> However, I think MAX_OOM_REAP_RETRIES and/or the timeout of HZ/10 needs to 
> be increased as well to address the issue that Tetsuo pointed out.  The 
> oom reaper shouldn't be required to do any work unless it is resolving a 
> livelock, and that scenario should be relatively rare.  The oom killer 
> being a natural ultra slow path, I think it would be justifiable to wait 
> longer or retry more times than simply 1 second before declaring that 
> reaping is not possible.  It reduces the likelihood of additional oom 
> killing.

I believe that this is an independent issue and as such it should be
addressed separately along with some data backing up that decision. I am
not against improving the waiting logic. We would need some requeuing
when we cannot reap the victim because we cannot really wait too much
time on a single oom victim considering there might be many victims
queued (because of memcg ooms). This would obviously need some more code
and I am willing to implement that but I would like to see that this is
something that is a real problem first.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
