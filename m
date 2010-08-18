Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3E5F96B01F1
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 23:16:32 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7I3GTXk003517
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 18 Aug 2010 12:16:30 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 88FB13A62C2
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:16:29 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B4F245DD71
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:16:29 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3566C1DB8018
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:16:29 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DAB791DB8012
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 12:16:28 +0900 (JST)
Date: Wed, 18 Aug 2010 12:11:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch v2 1/2] oom: avoid killing a task if a thread sharing
 its mm cannot be killed
Message-Id: <20100818121137.20192c31.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1008171925250.2823@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008161810420.26680@chino.kir.corp.google.com>
	<20100818110746.5c030b34.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008171925250.2823@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Aug 2010 19:36:02 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 18 Aug 2010, KAMEZAWA Hiroyuki wrote:
> 
> > > The oom killer's goal is to kill a memory-hogging task so that it may
> > > exit, free its memory, and allow the current context to allocate the
> > > memory that triggered it in the first place.  Thus, killing a task is
> > > pointless if other threads sharing its mm cannot be killed because of its
> > > /proc/pid/oom_adj or /proc/pid/oom_score_adj value.
> > > 
> > > This patch checks all user threads on the system to determine whether
> > > oom_badness(p) should return 0 for p, which means it should not be killed.
> > > If a thread shares p's mm and is unkillable, p is considered to be
> > > unkillable as well.
> > > 
> > > Kthreads are not considered toward this rule since they only temporarily
> > > assume a task's mm via use_mm().
> > > 
> > > Signed-off-by: David Rientjes <rientjes@google.com>
> > 
> > Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> 
> Thanks!
> 
> > Thank you. BTW, do you have good idea for speed-up ?
> > This code seems terribly slow when a system has many processes.
> > 
> 
> I was thinking about adding an "unsinged long oom_kill_disable_count" to 
> struct mm_struct that would atomically increment anytime a task attached 
> to it had a signal->oom_score_adj of OOM_SCORE_ADJ_MIN.
> 
> The proc handler when changing /proc/pid/oom_score_adj would inc or dec 
> the counter depending on the new value, and exit_mm() would dec the 
> counter if current->signal->oom_score_adj is OOM_SCORE_ADJ_MIN.
> 
> What do you think?
> 

Hmm. I want to make hooks to "exit" small. 

One idea is.

add a new member
		mm->unkiilable_by_oom_jiffies.

And add
> +static bool is_mm_unfreeable(struct mm_struct *mm)
> +{
> +	struct task_struct *p;
> +
	if (mm->unkillable_by_oom_jiffies < jiffies)
		return true;

> +	for_each_process(p)
> +		if (p->mm == mm && !(p->flags & PF_KTHREAD) &&
> +		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) 

			mm->unkillable_by_oom_jiffies = jiffies + HZ;

> +			return true;
> +	return false;
> +}+static bool is_mm_unfreeable(struct mm_struct *mm)


Maybe no new lock is required and this not-accurate one will work enough.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
