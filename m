Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4EBBB6B01F1
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 23:43:21 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o7I3hHg6022085
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 20:43:17 -0700
Received: from pwj6 (pwj6.prod.google.com [10.241.219.70])
	by wpaz24.hot.corp.google.com with ESMTP id o7I3hFWn000378
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 20:43:16 -0700
Received: by pwj6 with SMTP id 6so278498pwj.2
        for <linux-mm@kvack.org>; Tue, 17 Aug 2010 20:43:15 -0700 (PDT)
Date: Tue, 17 Aug 2010 20:43:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2 1/2] oom: avoid killing a task if a thread sharing
 its mm cannot be killed
In-Reply-To: <20100818121137.20192c31.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008172038140.11263@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008161810420.26680@chino.kir.corp.google.com> <20100818110746.5c030b34.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1008171925250.2823@chino.kir.corp.google.com> <20100818121137.20192c31.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 18 Aug 2010, KAMEZAWA Hiroyuki wrote:

> > I was thinking about adding an "unsinged long oom_kill_disable_count" to 
> > struct mm_struct that would atomically increment anytime a task attached 
> > to it had a signal->oom_score_adj of OOM_SCORE_ADJ_MIN.
> > 
> > The proc handler when changing /proc/pid/oom_score_adj would inc or dec 
> > the counter depending on the new value, and exit_mm() would dec the 
> > counter if current->signal->oom_score_adj is OOM_SCORE_ADJ_MIN.
> > 
> > What do you think?
> > 
> 
> Hmm. I want to make hooks to "exit" small. 
> 


Is it worth adding

	if (unlikely(current->signal->oom_score_adj == OOM_SCORE_ADJ_MIN))
		atomic_dec(&current->mm->oom_disable_count);

to exit_mm() under task_lock() to avoid the O(n^2) select_bad_process() on 
oom?  Or do you think that's too expensive?

> One idea is.
> 
> add a new member
> 		mm->unkiilable_by_oom_jiffies.
> 
> And add
> > +static bool is_mm_unfreeable(struct mm_struct *mm)
> > +{
> > +	struct task_struct *p;
> > +
> 	if (mm->unkillable_by_oom_jiffies < jiffies)
> 		return true;
> 
> > +	for_each_process(p)
> > +		if (p->mm == mm && !(p->flags & PF_KTHREAD) &&
> > +		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) 
> 
> 			mm->unkillable_by_oom_jiffies = jiffies + HZ;
> 
> > +			return true;
> > +	return false;
> > +}+static bool is_mm_unfreeable(struct mm_struct *mm)
> 

This probably isn't fast enough for the common case, which is when no 
tasks for "mm" have an oom_score_adj of OOM_SCORE_ADJ_MIN, since it still 
iterates through every task.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
