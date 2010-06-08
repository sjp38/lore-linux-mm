Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B11FE6B01C3
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 19:02:34 -0400 (EDT)
Date: Tue, 8 Jun 2010 16:02:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 16/18] oom: badness heuristic rewrite
Message-Id: <20100608160216.bc52112b.akpm@linux-foundation.org>
In-Reply-To: <20100608194533.7657.A69D9226@jp.fujitsu.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006061526540.32225@chino.kir.corp.google.com>
	<20100608194533.7657.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue,  8 Jun 2010 20:41:56 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

>
> ...
>
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -4,6 +4,8 @@
> >   *  Copyright (C)  1998,2000  Rik van Riel
> >   *	Thanks go out to Claus Fischer for some serious inspiration and
> >   *	for goading me into coding this file...
> > + *  Copyright (C)  2010  Google, Inc.
> > + *	Rewritten by David Rientjes
> 
> don't put it.
> 

Seems OK to me.  It's a fairly substantial change and people have added
their (c) in the past for smaller kernel changes.  I guess one could even
do this for a one-liner.

>
> ...
>
> >  	/*
> > -	 * Niced processes are most likely less important, so double
> > -	 * their badness points.
> > +	 * The memory controller may have a limit of 0 bytes, so avoid a divide
> > +	 * by zero if necessary.
> >  	 */
> > -	if (task_nice(p) > 0)
> > -		points *= 2;
> 
> You removed 
>   - run time check
>   - cpu time check
>   - nice check
> 
> but no described the reason. reviewers are puzzled. How do we review
> this though we don't get your point? please write
> 
>  - What benerit is there?
>  - Why do you think no bad effect?
>  - How confirm do you?

yup.

> 
> > +	if (!totalpages)
> > +		totalpages = 1;
> >  
> >  	/*
> > -	 * Superuser processes are usually more important, so we make it
> > -	 * less likely that we kill those.
> > +	 * The baseline for the badness score is the proportion of RAM that each
> > +	 * task's rss and swap space use.
> >  	 */
> > -	if (has_capability_noaudit(p, CAP_SYS_ADMIN) ||
> > -	    has_capability_noaudit(p, CAP_SYS_RESOURCE))
> > -		points /= 4;
> > +	points = (get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS)) * 1000 /
> > +			totalpages;
> > +	task_unlock(p);
> >  
> >  	/*
> > -	 * We don't want to kill a process with direct hardware access.
> > -	 * Not only could that mess up the hardware, but usually users
> > -	 * tend to only have this flag set on applications they think
> > -	 * of as important.
> > +	 * Root processes get 3% bonus, just like the __vm_enough_memory()
> > +	 * implementation used by LSMs.
> >  	 */
> > -	if (has_capability_noaudit(p, CAP_SYS_RAWIO))
> > -		points /= 4;
> > +	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
> > +		points -= 30;
> 
> 
> CAP_SYS_ADMIN seems no good idea. CAP_SYS_ADMIN imply admin's interactive
> process. but killing interactive process only cause force logout. but
> killing system daemon can makes more catastrophic disaster.
> 
> 
> Last of all, I'll pulled this one. but only do cherry-pick.
> 

This change was unchangelogged, I don't know what it's for and I don't
understand your comment about it.

Apart from that, I'm doing great!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
