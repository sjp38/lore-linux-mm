Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B56726B005D
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 03:06:47 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id n6U76jpU028261
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 00:06:46 -0700
Received: from pxi10 (pxi10.prod.google.com [10.243.27.10])
	by wpaz13.hot.corp.google.com with ESMTP id n6U76gMA017675
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 00:06:43 -0700
Received: by pxi10 with SMTP id 10so871718pxi.25
        for <linux-mm@kvack.org>; Thu, 30 Jul 2009 00:06:42 -0700 (PDT)
Date: Thu, 30 Jul 2009 00:06:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
In-Reply-To: <20090730090855.E415.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0907292356410.5581@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0907282125260.554@chino.kir.corp.google.com> <20090730090855.E415.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 30 Jul 2009, KOSAKI Motohiro wrote:

> > diff --git a/kernel/fork.c b/kernel/fork.c
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -426,7 +426,7 @@ static struct mm_struct * mm_init(struct mm_struct * mm, struct task_struct *p)
> >  	init_rwsem(&mm->mmap_sem);
> >  	INIT_LIST_HEAD(&mm->mmlist);
> >  	mm->flags = (current->mm) ? current->mm->flags : default_dump_filter;
> > -	mm->oom_adj = (current->mm) ? current->mm->oom_adj : 0;
> > +	mm->oom_adj = p->oom_adj_child;
> 
> This code doesn't fix anything.
> mm->oom_adj assignment still change vfork() parent process oom_adj value.
> (Again, vfork() parent and child use the same mm)
> 

That's because the oom killer only really considers the highest oom_adj 
value amongst all threads that share the same mm.  Allowing those threads 
to each have different oom_adj values leads (i) to an inconsistency in 
reporting /proc/pid/oom_score for how the oom killer selects a task to 
kill and (ii) the oom killer livelock that it fixes when one thread 
happens to be OOM_DISABLE.

So, yes, changing the oom_adj value for a thread may have side-effects 
on other threads that didn't exist prior to 2.6.31-rc1 because the oom_adj 
value now represents a killable quantity of memory instead of a being a 
characteristic of the task itself.  But we now provide the inheritance 
property in a new way, via /proc/pid/oom_adj_child, that gives you all the 
functionality that the previous way did but without the potential for 
livelock.

> IOW, in vfork case, oom_adj_child parameter doesn't only change child oom_adj,
> but also parent oom_adj value.

Changing oom_adj_child for a task never changes oom_adj for any mm, it 
simply specifies what default value shall be given for a child's newly 
initialized mm.  Chaning oom_adj, on the other hand, will 

> IOW, oom_adj_child is NOT child effective parameter.
> 

It's not meant to be, it's only meant to specify a default value for newly 
initialized mm's of its descendants.  What happens after that is governed 
completely by the child's own /proc/pid/oom_adj.  That's pretty clearly 
explained in Documentation/filesystems/proc.txt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
