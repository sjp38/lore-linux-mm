Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DDE696B01F3
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 06:56:18 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id o7GAuF8f024711
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 03:56:15 -0700
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by hpaq12.eem.corp.google.com with ESMTP id o7GAuAs1026692
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 03:56:13 -0700
Received: by pwj8 with SMTP id 8so2956134pwj.15
        for <linux-mm@kvack.org>; Mon, 16 Aug 2010 03:56:10 -0700 (PDT)
Date: Mon, 16 Aug 2010 03:56:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] oom: avoid killing a task if a thread sharing its
 mm cannot be killed
In-Reply-To: <20100816055204.GA9498@redhat.com>
Message-ID: <alpine.DEB.2.00.1008160350110.5305@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008142128050.31510@chino.kir.corp.google.com> <20100815151819.GA3531@redhat.com> <alpine.DEB.2.00.1008151409020.8727@chino.kir.corp.google.com> <20100816055204.GA9498@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Aug 2010, Oleg Nesterov wrote:

> > There's no other way to detect threads in other thread groups that share
> > the same mm since subthreads of a process can have an oom_score_adj that
> > differ from that process, this includes the possibility of
> > OOM_SCORE_ADJ_MIN that we're interested in here.
> 
> Yes, you are right. Still, at least you can do
> 
> 	for_each_process(p) {
> 		if (p->mm != mm)
> 			continue;
> 		...
> 
> to quickly skip the thread group which doesn't share the same ->mm.
> 

Right, thanks.  I'll make that optimization and send out a second version 
of this series with the other changes you suggested.

> > > > -	if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> > > > +	if (is_mm_unfreeable(p->mm)) {
> > >
> > > oom_badness() becomes O(n**2), not good.
> > >
> >
> > No, oom_badness() becomes O(n) from O(1); select_bad_process() becomes
> > slower for eligible tasks.
> 
> I meant, select_bad_process() becomes O(n^2). oom_badness() is O(n), yes.
> 

I'll follow my own suggestion for deferring this check to 
oom_kill_process() since it's certainly an unusual case if the tasks are 
sharing memory.  It'll require a second entire tasklist scan when it 
occurs, but definitely speeds up the common case.

> > > And, more importantly. This patch makes me think ->oom_score_adj should
> > > be moved from ->signal to ->mm.
> > >
> >
> > I did that several months ago but people were unhappy with how a parent's
> > oom_score_adj value would change if it did a vfork() and the child's
> > oom_score_adj value was changed prior to execve().
> 
> I see. But this patch in essence moves OOM_SCORE_ADJ_MIN from ->signal
> to ->mm (and btw personally I think this makes sense).
> 

Yes, and I still would have liked to embed it in struct mm_struct like I 
originally proposed, but I understand how some people didn't care much for 
the vfork() inheritance problem.  There are applications in the wild such 
as job schedulers that are OOM_DISABLE themselves and fork children and 
then reset their oom_adj value prior to exec.  So they do vfork() -> 
change child's oom_adj -> execve().  That currently works since the 
child's ->signal isn't shared (and before that, oom_adj was embedded in 
struct task_struct) and we can't change that behavior to also change the 
parent's oom_adj value at the same time because it shares an ->mm out from 
under them.

Thanks for reviewing the patches Oleg!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
