Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 13B8B6B0078
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 20:50:32 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o820oTkN011601
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 2 Sep 2010 09:50:30 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2606E45DE7A
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 09:50:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EFD5445DE70
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 09:50:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DF11AE38003
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 09:50:27 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 85EFDEF8001
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 09:50:27 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 1/3 v3] oom: add per-mm oom disable count
In-Reply-To: <alpine.DEB.2.00.1009011637000.8831@chino.kir.corp.google.com>
References: <20100901083841.9722.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1009011637000.8831@chino.kir.corp.google.com>
Message-Id: <20100902092235.D062.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  2 Sep 2010 09:50:26 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > > > @@ -1690,6 +1697,10 @@ SYSCALL_DEFINE1(unshare, unsigned long, unshare_flags)
> > > > >  			active_mm = current->active_mm;
> > > > >  			current->mm = new_mm;
> > > > >  			current->active_mm = new_mm;
> > > > > +			if (current->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> > > > > +				atomic_dec(&mm->oom_disable_count);
> > > > > +				atomic_inc(&new_mm->oom_disable_count);
> > > > > +			}
> > > > >  			activate_mm(active_mm, new_mm);
> > > > >  			new_mm = mm;
> > > > >  		}
> > > > 
> > > > This place, we are grabbing task_lock(), but task_lock don't prevent
> > > > to change signal->oom_score_adj from another thread. This seems racy.
> > > > 
> > > 
> > > It does, task_lock(current) protects current->signal->oom_score_adj from 
> > > changing in oom-add-per-mm-oom-disable-count.patch.
> > > 
> > > I'll add the task_lock(p) in mm_init(), thanks for the review!
> > 
> > Wait, can you please elabolate more? task_lock() only lock one thread.
> > Why can it protect multi-thread race?
> > 
> 
> We take task_lock(tsk) whenever we change tsk->signal->oom_score_adj.

example, Process P1 has threads T1 and T2.
oom_score_adj_write() take task_lock(T1) and siglock(P1). unshare() take
task_lock(T2). How protect?





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
