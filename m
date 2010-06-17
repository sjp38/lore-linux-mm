Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2BACC6B01B8
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 01:14:52 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o5H5ElNl027967
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 22:14:47 -0700
Received: from pva18 (pva18.prod.google.com [10.241.209.18])
	by kpbe14.cbf.corp.google.com with ESMTP id o5H5EP0u027227
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 22:14:46 -0700
Received: by pva18 with SMTP id 18so123013pva.32
        for <linux-mm@kvack.org>; Wed, 16 Jun 2010 22:14:45 -0700 (PDT)
Date: Wed, 16 Jun 2010 22:14:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 16/18] oom: badness heuristic rewrite
In-Reply-To: <20100608160216.bc52112b.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1006162213130.19549@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061526540.32225@chino.kir.corp.google.com> <20100608194533.7657.A69D9226@jp.fujitsu.com> <20100608160216.bc52112b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, Andrew Morton wrote:

> > > +	if (!totalpages)
> > > +		totalpages = 1;
> > >  
> > >  	/*
> > > -	 * Superuser processes are usually more important, so we make it
> > > -	 * less likely that we kill those.
> > > +	 * The baseline for the badness score is the proportion of RAM that each
> > > +	 * task's rss and swap space use.
> > >  	 */
> > > -	if (has_capability_noaudit(p, CAP_SYS_ADMIN) ||
> > > -	    has_capability_noaudit(p, CAP_SYS_RESOURCE))
> > > -		points /= 4;
> > > +	points = (get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS)) * 1000 /
> > > +			totalpages;
> > > +	task_unlock(p);
> > >  
> > >  	/*
> > > -	 * We don't want to kill a process with direct hardware access.
> > > -	 * Not only could that mess up the hardware, but usually users
> > > -	 * tend to only have this flag set on applications they think
> > > -	 * of as important.
> > > +	 * Root processes get 3% bonus, just like the __vm_enough_memory()
> > > +	 * implementation used by LSMs.
> > >  	 */
> > > -	if (has_capability_noaudit(p, CAP_SYS_RAWIO))
> > > -		points /= 4;
> > > +	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
> > > +		points -= 30;
> > 
> > 
> > CAP_SYS_ADMIN seems no good idea. CAP_SYS_ADMIN imply admin's interactive
> > process. but killing interactive process only cause force logout. but
> > killing system daemon can makes more catastrophic disaster.
> > 
> > 
> > Last of all, I'll pulled this one. but only do cherry-pick.
> > 
> 
> This change was unchangelogged, I don't know what it's for and I don't
> understand your comment about it.
> 

It was in the changelog (recall that the badness() function represents a 
proportion of available memory used by a task, so subtracting 30 is the 
equivalent of 3% of available memory):

Root tasks are given 3% extra memory just like __vm_enough_memory()
provides in LSMs.  In the event of two tasks consuming similar amounts of
memory, it is generally better to save root's task.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
