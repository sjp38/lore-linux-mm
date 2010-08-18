Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 212BF6B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 00:00:01 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7I3xwdu030316
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 18 Aug 2010 12:59:58 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F044145DE4F
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:59:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C77E345DE4D
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:59:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A44C21DB803E
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:59:57 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 578431DB8038
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:59:54 +0900 (JST)
Date: Wed, 18 Aug 2010 12:55:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch v2 1/2] oom: avoid killing a task if a thread sharing
 its mm cannot be killed
Message-Id: <20100818125501.90db0770.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1008172038140.11263@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008161810420.26680@chino.kir.corp.google.com>
	<20100818110746.5c030b34.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008171925250.2823@chino.kir.corp.google.com>
	<20100818121137.20192c31.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008172038140.11263@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Aug 2010 20:43:10 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 18 Aug 2010, KAMEZAWA Hiroyuki wrote:
> 
> > > I was thinking about adding an "unsinged long oom_kill_disable_count" to 
> > > struct mm_struct that would atomically increment anytime a task attached 
> > > to it had a signal->oom_score_adj of OOM_SCORE_ADJ_MIN.
> > > 
> > > The proc handler when changing /proc/pid/oom_score_adj would inc or dec 
> > > the counter depending on the new value, and exit_mm() would dec the 
> > > counter if current->signal->oom_score_adj is OOM_SCORE_ADJ_MIN.
> > > 
> > > What do you think?
> > > 
> > 
> > Hmm. I want to make hooks to "exit" small. 
> > 
> 
> 
> Is it worth adding
> 
> 	if (unlikely(current->signal->oom_score_adj == OOM_SCORE_ADJ_MIN))
> 		atomic_dec(&current->mm->oom_disable_count);
> 
> to exit_mm() under task_lock() to avoid the O(n^2) select_bad_process() on 
> oom?  Or do you think that's too expensive?
> 

Hmm, if this coutner is changed only under down_write(mmap_sem),
simple 'int' counter is enough quick. 

> > One idea is.
> > 
> > add a new member
> > 		mm->unkiilable_by_oom_jiffies.
> > 
> > And add
> > > +static bool is_mm_unfreeable(struct mm_struct *mm)
> > > +{
> > > +	struct task_struct *p;
> > > +
> > 	if (mm->unkillable_by_oom_jiffies < jiffies)
> > 		return true;
> > 
> > > +	for_each_process(p)
> > > +		if (p->mm == mm && !(p->flags & PF_KTHREAD) &&
> > > +		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) 
> > 
> > 			mm->unkillable_by_oom_jiffies = jiffies + HZ;
> > 
> > > +			return true;
> > > +	return false;
> > > +}+static bool is_mm_unfreeable(struct mm_struct *mm)
> > 
> 
> This probably isn't fast enough for the common case, which is when no 
> tasks for "mm" have an oom_score_adj of OOM_SCORE_ADJ_MIN, since it still 
> iterates through every task.
> 
you're right. 


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
