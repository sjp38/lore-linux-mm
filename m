Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 893F06B01F0
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 08:40:39 -0400 (EDT)
Date: Fri, 9 Apr 2010 14:38:23 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch] oom: give current access to memory reserves if it has
	been killed
Message-ID: <20100409123823.GA6661@redhat.com>
References: <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330154659.GA12416@redhat.com> <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com> <20100331175836.GA11635@redhat.com> <alpine.DEB.2.00.1003311342410.25284@chino.kir.corp.google.com> <20100331224904.GA4025@redhat.com> <alpine.DEB.2.00.1004010044320.6285@chino.kir.corp.google.com> <20100401152638.GC14603@redhat.com> <alpine.DEB.2.00.1004081405180.8347@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1004081405180.8347@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 04/08, David Rientjes wrote:
>
> On Thu, 1 Apr 2010, Oleg Nesterov wrote:
>
> > Look. We have a main thread M and the sub-thread T. T forks a lot of
> > processes which use a lot of memory. These processes _are_ the first
> > descendant children of the M+T thread group, they should be accounted.
> > But M->children list is empty.
> >
> > oom_forkbomb_penalty() and oom_kill_process() should do
> >
> > 	t = tsk;
> > 	do {
> > 		list_for_each_entry(child, &t->children, sibling) {
> > 			... take child into account ...
> > 		}
> > 	} while_each_thread(tsk, t);
> >
>
> In this case, it seems more appropriate that we would penalize T and not M

We can't. Any fatal signal sent to any sub-thread kills the whole thread
group. It is not possible to kill T but not M.

> since it's not necessarily responsible for the behavior of the children it
> forks. T is the buggy/malicious program, not M.

Since a) they share the same ->mm and b) they share their children, I
don't think we should separate T and M.

->children is per_thread. But this is only because we have some strange
historiral oddities like __WNOTHREAD. Otherwise, it is not correct to
assume that the child of T is not the child of M. Any process is the
child of its parent's thread group, not the thread which actually called
fork().

> > --- x/mm/oom_kill.c
> > +++ x/mm/oom_kill.c
> > @@ -97,13 +97,16 @@ static unsigned long oom_forkbomb_penalt
> >  		return 0;
> >  	list_for_each_entry(child, &tsk->children, sibling) {
> >  		struct task_cputime task_time;
> > -		unsigned long runtime;
> > +		unsigned long runtime, this_rss;
> >
> >  		task_lock(child);
> >  		if (!child->mm || child->mm == tsk->mm) {
> >  			task_unlock(child);
> >  			continue;
> >  		}
> > +		this_rss = get_mm_rss(child->mm);
> > +		task_unlock(child);
> > +
> >  	/*
>
> This patch looks good, will you send it to Andrew with a changelog and 
> sign-off line?  Also feel free to add:
>
> Acked-by: David Rientjes <rientjes@google.com>

Thanks! already in -mm.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
