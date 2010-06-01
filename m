Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4B5FB6B01B6
	for <linux-mm@kvack.org>; Mon, 31 May 2010 21:10:34 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o511Al2J003784
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 1 Jun 2010 10:10:47 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DBBF545DE54
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 10:10:46 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B77D245DE51
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 10:10:46 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 991E9E08003
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 10:10:46 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 48A261DB803F
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 10:10:46 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/5] oom: select_bad_process: PF_EXITING check should take ->mm into account
In-Reply-To: <20100531164354.GA9991@redhat.com>
References: <20100531183335.1846.A69D9226@jp.fujitsu.com> <20100531164354.GA9991@redhat.com>
Message-Id: <20100601093951.2430.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  1 Jun 2010 10:10:45 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi

> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -287,7 +287,7 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
> >  		 * the process of exiting and releasing its resources.
> >  		 * Otherwise we could get an easy OOM deadlock.
> >  		 */
> > -		if (p->flags & PF_EXITING) {
> > +		if ((p->flags & PF_EXITING) && p->mm) {
> 
> (strictly speaking, this change is needed after 3/5 which removes the
>  top-level "if (!p->mm)" check in select_bad_process).
> 
> 
> I'd like to add a note... with or without this, we have problems
> with the coredump. A thread participating in the coredumping
> (group-leader in this case) can have PF_EXITING && mm, but this doesn't
> mean it is going to exit soon, and the dumper can use a lot more memory.

Sure. I think coredump sould do nothing if oom occur.
So, merely making PF_COREDUMP is bad idea? I mean


task-flags		allocator
------------------------------------------------
none			N/A
TIF_MEMDIE		allow to use emergency memory.
			don't call page reclaim.
PF_COREDUMP		N/A
TIF_MEMDIE+PF_COREDUMP	disallow to use emergency memory.
			don't call page reclaim.

In other word, coredump path makes allocation failure if the task
marked as TIF_MEMDIE.
And, userland oom helper should be marked PF_OOM_ORIGIN perhaps.


> Otoh, if select_bad_process() chooses the thread which dumps the core,
> SIGKILL can't stop it. This should be fixed in do_coredump() paths, this
> is the long-standing problem.
> 
> And, as it was already discussed, we only check the group-leader here.
> But I can't suggest something better.

I guess signal_group_exit() is enough in practical case. I mean
exit(2) is only used by pthread_exit(3), so practically the last thread
in the process don't die by using exit(2).

I don't say signal_group_exit() is no side-effect. but I guess originally
intention was testing during _process_ exiting. 

Am I missing something?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
