Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C27CD6B020D
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 17:08:38 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o38L8YvI013233
	for <linux-mm@kvack.org>; Thu, 8 Apr 2010 14:08:35 -0700
Received: from pzk16 (pzk16.prod.google.com [10.243.19.144])
	by kpbe20.cbf.corp.google.com with ESMTP id o38L8XAT030312
	for <linux-mm@kvack.org>; Thu, 8 Apr 2010 14:08:33 -0700
Received: by pzk16 with SMTP id 16so778739pzk.22
        for <linux-mm@kvack.org>; Thu, 08 Apr 2010 14:08:33 -0700 (PDT)
Date: Thu, 8 Apr 2010 14:08:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] oom: give current access to memory reserves if it has
 been killed
In-Reply-To: <20100401152638.GC14603@redhat.com>
Message-ID: <alpine.DEB.2.00.1004081405180.8347@chino.kir.corp.google.com>
References: <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330154659.GA12416@redhat.com>
 <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com> <20100331175836.GA11635@redhat.com> <alpine.DEB.2.00.1003311342410.25284@chino.kir.corp.google.com> <20100331224904.GA4025@redhat.com> <alpine.DEB.2.00.1004010044320.6285@chino.kir.corp.google.com>
 <20100401152638.GC14603@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 1 Apr 2010, Oleg Nesterov wrote:

> > > > > Say, oom_forkbomb_penalty() does list_for_each_entry(tsk->children).
> > > > > Again, this is not right even if we forget about !child->mm check.
> > > > > This list_for_each_entry() can only see the processes forked by the
> > > > > main thread.
> > > > >
> > > >
> > > > That's the intention.
> > >
> > > Why? shouldn't oom_badness() return the same result for any thread
> > > in thread group? We should take all childs into account.
> > >
> >
> > oom_forkbomb_penalty() only cares about first-descendant children that
> > do not share the same memory,
> 
> I see, but the code doesn't really do this. I mean, it doesn't really
> see the first-descendant children, only those which were forked by the
> main thread.
> 
> Look. We have a main thread M and the sub-thread T. T forks a lot of
> processes which use a lot of memory. These processes _are_ the first
> descendant children of the M+T thread group, they should be accounted.
> But M->children list is empty.
> 
> oom_forkbomb_penalty() and oom_kill_process() should do
> 
> 	t = tsk;
> 	do {
> 		list_for_each_entry(child, &t->children, sibling) {
> 			... take child into account ...
> 		}
> 	} while_each_thread(tsk, t);
> 
> 

In this case, it seems more appropriate that we would penalize T and not M 
since it's not necessarily responsible for the behavior of the children it 
forks.  T is the buggy/malicious program, not M.

> See the patch below. Yes, this is minor, but it is always good to avoid
> the unnecessary locks, and thread_group_cputime() is O(N).
> 
> Not only for performance reasons. This allows to change the locking in
> thread_group_cputime() if needed without fear to deadlock with task_lock().
> 
> Oleg.
> 
> --- x/mm/oom_kill.c
> +++ x/mm/oom_kill.c
> @@ -97,13 +97,16 @@ static unsigned long oom_forkbomb_penalt
>  		return 0;
>  	list_for_each_entry(child, &tsk->children, sibling) {
>  		struct task_cputime task_time;
> -		unsigned long runtime;
> +		unsigned long runtime, this_rss;
>  
>  		task_lock(child);
>  		if (!child->mm || child->mm == tsk->mm) {
>  			task_unlock(child);
>  			continue;
>  		}
> +		this_rss = get_mm_rss(child->mm);
> +		task_unlock(child);
> +
>  		thread_group_cputime(child, &task_time);
>  		runtime = cputime_to_jiffies(task_time.utime) +
>  			  cputime_to_jiffies(task_time.stime);
> @@ -113,10 +116,9 @@ static unsigned long oom_forkbomb_penalt
>  		 * get to execute at all in such cases anyway.
>  		 */
>  		if (runtime < HZ) {
> -			child_rss += get_mm_rss(child->mm);
> +			child_rss += this_rss;
>  			forkcount++;
>  		}
> -		task_unlock(child);
>  	}
>  
>  	/*

This patch looks good, will you send it to Andrew with a changelog and 
sign-off line?  Also feel free to add:

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
