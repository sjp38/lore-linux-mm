Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 752FE6B004A
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 19:41:20 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o81NfG5T008875
	for <linux-mm@kvack.org>; Wed, 1 Sep 2010 16:41:17 -0700
Received: from pwi1 (pwi1.prod.google.com [10.241.219.1])
	by kpbe11.cbf.corp.google.com with ESMTP id o81Nf9sa004246
	for <linux-mm@kvack.org>; Wed, 1 Sep 2010 16:41:10 -0700
Received: by pwi1 with SMTP id 1so50995pwi.17
        for <linux-mm@kvack.org>; Wed, 01 Sep 2010 16:41:09 -0700 (PDT)
Date: Wed, 1 Sep 2010 16:41:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/3 v3] oom: add per-mm oom disable count
In-Reply-To: <20100901083841.9722.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1009011637000.8831@chino.kir.corp.google.com>
References: <20100830130913.525F.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1008301409040.4852@chino.kir.corp.google.com> <20100901083841.9722.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 1 Sep 2010, KOSAKI Motohiro wrote:

> > > > @@ -745,6 +746,10 @@ static int exec_mmap(struct mm_struct *mm)
> > > >  	tsk->mm = mm;
> > > >  	tsk->active_mm = mm;
> > > >  	activate_mm(active_mm, mm);
> > > > +	if (tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> > > > +		atomic_dec(&active_mm->oom_disable_count);
> > > 
> > > When kernel thread makes user-land process (e.g. usermode-helper),
> > > active_mm might point to unrelated process. active_mm is only meaningful
> > > for scheduler code. please don't touch it. probably you intend to
> > > change old_mm.
> > 
> > This is safe because kthreads never have non-zero 
> > p->signal->oom_score_adj.
> 
> Hm? my example is wrong? my point is, you shouldn't touch active_mm.
> 

Ok, I'll use old_mm instead as a cleanup.  Thanks!

> > > > @@ -1690,6 +1697,10 @@ SYSCALL_DEFINE1(unshare, unsigned long, unshare_flags)
> > > >  			active_mm = current->active_mm;
> > > >  			current->mm = new_mm;
> > > >  			current->active_mm = new_mm;
> > > > +			if (current->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> > > > +				atomic_dec(&mm->oom_disable_count);
> > > > +				atomic_inc(&new_mm->oom_disable_count);
> > > > +			}
> > > >  			activate_mm(active_mm, new_mm);
> > > >  			new_mm = mm;
> > > >  		}
> > > 
> > > This place, we are grabbing task_lock(), but task_lock don't prevent
> > > to change signal->oom_score_adj from another thread. This seems racy.
> > > 
> > 
> > It does, task_lock(current) protects current->signal->oom_score_adj from 
> > changing in oom-add-per-mm-oom-disable-count.patch.
> > 
> > I'll add the task_lock(p) in mm_init(), thanks for the review!
> 
> Wait, can you please elabolate more? task_lock() only lock one thread.
> Why can it protect multi-thread race?
> 

We take task_lock(tsk) whenever we change tsk->signal->oom_score_adj.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
