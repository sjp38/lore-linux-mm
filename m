Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D15B36B004D
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 02:47:55 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6V6lwYQ031229
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 31 Jul 2009 15:47:58 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D02ED45DE62
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 15:47:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EBD3245DE5D
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 15:47:56 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C65B11DB803A
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 15:47:56 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 37C771DB803C
	for <linux-mm@kvack.org>; Fri, 31 Jul 2009 15:47:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
In-Reply-To: <alpine.DEB.2.00.0907292356410.5581@chino.kir.corp.google.com>
References: <20090730090855.E415.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.0907292356410.5581@chino.kir.corp.google.com>
Message-Id: <20090731091744.B6DE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 31 Jul 2009 15:47:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

> On Thu, 30 Jul 2009, KOSAKI Motohiro wrote:
> 
> > > diff --git a/kernel/fork.c b/kernel/fork.c
> > > --- a/kernel/fork.c
> > > +++ b/kernel/fork.c
> > > @@ -426,7 +426,7 @@ static struct mm_struct * mm_init(struct mm_struct * mm, struct task_struct *p)
> > >  	init_rwsem(&mm->mmap_sem);
> > >  	INIT_LIST_HEAD(&mm->mmlist);
> > >  	mm->flags = (current->mm) ? current->mm->flags : default_dump_filter;
> > > -	mm->oom_adj = (current->mm) ? current->mm->oom_adj : 0;
> > > +	mm->oom_adj = p->oom_adj_child;
> > 
> > This code doesn't fix anything.
> > mm->oom_adj assignment still change vfork() parent process oom_adj value.
> > (Again, vfork() parent and child use the same mm)
> > 
> 
> That's because the oom killer only really considers the highest oom_adj 
> value amongst all threads that share the same mm.  Allowing those threads 
> to each have different oom_adj values leads (i) to an inconsistency in 
> reporting /proc/pid/oom_score for how the oom killer selects a task to 
> kill and (ii) the oom killer livelock that it fixes when one thread 
> happens to be OOM_DISABLE.

I agree both. again I only disagree ABI breakage regression and
stupid new /proc interface.
Paul already pointed out this issue can be fixed without ABI change.


> So, yes, changing the oom_adj value for a thread may have side-effects 
> on other threads that didn't exist prior to 2.6.31-rc1 because the oom_adj 
> value now represents a killable quantity of memory instead of a being a 
> characteristic of the task itself.  But we now provide the inheritance 
> property in a new way, via /proc/pid/oom_adj_child, that gives you all the 
> functionality that the previous way did but without the potential for 
> livelock.

maybe, I should say my stand-point obviously. I don't dislike your
per-process oom_adj concept.
I only oppose vfork breakage.

if you feel my stand point is double standard, I need explain me more.
So, I don't think per-process oom_adj makes any regression on _real_ world.
but vfork()'s one is real world issue.

I think they are totally different thing.


And, May I explay why I think your oom_adj_child is wrong idea?
The fact is: new feature introducing never fix regression. yes, some
application use new interface and disappear the problem. but other
application still hit the problem. that's not correct development style
in kernel.


> 
> > IOW, in vfork case, oom_adj_child parameter doesn't only change child oom_adj,
> > but also parent oom_adj value.
> 
> Changing oom_adj_child for a task never changes oom_adj for any mm, it 
> simply specifies what default value shall be given for a child's newly 
> initialized mm.  Chaning oom_adj, on the other hand, will 

Ah, ok. I miunderstood.
However, We can fix this issue without new interface, isn't it?


> > IOW, oom_adj_child is NOT child effective parameter.
> > 
> 
> It's not meant to be, it's only meant to specify a default value for newly 
> initialized mm's of its descendants.  What happens after that is governed 
> completely by the child's own /proc/pid/oom_adj.  That's pretty clearly 
> explained in Documentation/filesystems/proc.txt.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
