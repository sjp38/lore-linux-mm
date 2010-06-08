Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 210366B01C1
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 19:40:15 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id o58NeB9Y027941
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 16:40:11 -0700
Received: from pvh1 (pvh1.prod.google.com [10.241.210.193])
	by kpbe12.cbf.corp.google.com with ESMTP id o58NeA1g021454
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 16:40:10 -0700
Received: by pvh1 with SMTP id 1so186857pvh.1
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 16:40:10 -0700 (PDT)
Date: Tue, 8 Jun 2010 16:40:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 01/18] oom: check PF_KTHREAD instead of !mm to skip
 kthreads
In-Reply-To: <20100608123320.11e501a4.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1006081639420.19582@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061521160.32225@chino.kir.corp.google.com> <20100608123320.11e501a4.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, Andrew Morton wrote:

> > From: Oleg Nesterov <oleg@redhat.com>
> > 
> > select_bad_process() thinks a kernel thread can't have ->mm != NULL, this
> > is not true due to use_mm().
> > 
> > Change the code to check PF_KTHREAD.
> > 
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> > Signed-off-by: David Rientjes <rientjes@google.com>
> > ---
> >  mm/oom_kill.c |    9 +++------
> >  1 files changed, 3 insertions(+), 6 deletions(-)
> > 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -256,14 +256,11 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
> >  	for_each_process(p) {
> >  		unsigned long points;
> >  
> > -		/*
> > -		 * skip kernel threads and tasks which have already released
> > -		 * their mm.
> > -		 */
> > +		/* skip tasks that have already released their mm */
> >  		if (!p->mm)
> >  			continue;
> > -		/* skip the init task */
> > -		if (is_global_init(p))
> > +		/* skip the init task and kthreads */
> > +		if (is_global_init(p) || (p->flags & PF_KTHREAD))
> >  			continue;
> >  		if (mem && !task_in_mem_cgroup(p, mem))
> >  			continue;
> 
> Applied, thanks.  A minor bugfix.
> 

Thanks!  I didn't see it added to -mm, though, so I'll assume it's being 
queued for 2.6.35-rc3 instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
