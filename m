Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AA3DC6B0047
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 19:54:59 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7VNsvZ8026174
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Sep 2010 08:54:57 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FDB045DE4C
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 08:54:57 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 37EC445DE4F
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 08:54:57 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 18ABCE38001
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 08:54:57 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CEDA71DB8013
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 08:54:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 1/3 v3] oom: add per-mm oom disable count
In-Reply-To: <alpine.DEB.2.00.1008301409040.4852@chino.kir.corp.google.com>
References: <20100830130913.525F.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1008301409040.4852@chino.kir.corp.google.com>
Message-Id: <20100901083841.9722.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Sep 2010 08:54:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > @@ -745,6 +746,10 @@ static int exec_mmap(struct mm_struct *mm)
> > >  	tsk->mm = mm;
> > >  	tsk->active_mm = mm;
> > >  	activate_mm(active_mm, mm);
> > > +	if (tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> > > +		atomic_dec(&active_mm->oom_disable_count);
> > 
> > When kernel thread makes user-land process (e.g. usermode-helper),
> > active_mm might point to unrelated process. active_mm is only meaningful
> > for scheduler code. please don't touch it. probably you intend to
> > change old_mm.
> 
> This is safe because kthreads never have non-zero 
> p->signal->oom_score_adj.

Hm? my example is wrong? my point is, you shouldn't touch active_mm.


> > > @@ -1690,6 +1697,10 @@ SYSCALL_DEFINE1(unshare, unsigned long, unshare_flags)
> > >  			active_mm = current->active_mm;
> > >  			current->mm = new_mm;
> > >  			current->active_mm = new_mm;
> > > +			if (current->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> > > +				atomic_dec(&mm->oom_disable_count);
> > > +				atomic_inc(&new_mm->oom_disable_count);
> > > +			}
> > >  			activate_mm(active_mm, new_mm);
> > >  			new_mm = mm;
> > >  		}
> > 
> > This place, we are grabbing task_lock(), but task_lock don't prevent
> > to change signal->oom_score_adj from another thread. This seems racy.
> > 
> 
> It does, task_lock(current) protects current->signal->oom_score_adj from 
> changing in oom-add-per-mm-oom-disable-count.patch.
> 
> I'll add the task_lock(p) in mm_init(), thanks for the review!

Wait, can you please elabolate more? task_lock() only lock one thread.
Why can it protect multi-thread race?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
