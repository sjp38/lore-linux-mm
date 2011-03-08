Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D768C8D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 18:57:44 -0500 (EST)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p28NvgXE006209
	for <linux-mm@kvack.org>; Tue, 8 Mar 2011 15:57:42 -0800
Received: from gxk28 (gxk28.prod.google.com [10.202.11.28])
	by hpaq11.eem.corp.google.com with ESMTP id p28NvZTv030039
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 8 Mar 2011 15:57:41 -0800
Received: by gxk28 with SMTP id 28so2469632gxk.32
        for <linux-mm@kvack.org>; Tue, 08 Mar 2011 15:57:40 -0800 (PST)
Date: Tue, 8 Mar 2011 15:57:36 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] oom: prevent unnecessary oom kills or kernel panics
In-Reply-To: <20110308134233.GA26884@redhat.com>
Message-ID: <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com> <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>

On Tue, 8 Mar 2011, Oleg Nesterov wrote:

> > > By iterating over threads instead, it is possible to detect threads that
> > > are exiting and nominate them for oom kill so they get access to memory
> > > reserves.
> >
> > In fact, PF_EXITING is a sing of *THREAD* exiting, not process. Therefore
> > PF_EXITING is not a sign of memory freeing in nearly future. If other
> > CPUs don't try to free memory, prevent oom and waiting makes deadlock.
> 
> I agree. I don't understand this patch.
> 

Using for_each_process() does not consider threads that have failed to 
exit after the oom killed parent and, thus, we select another innocent 
task to kill when we're really just waiting for those threads to exit (and 
perhaps they need memory reserves in the exit path) or, in the worst case, 
panic if there is nothing else eligible.

The end result is that without this patch, we sometimes unnecessarily 
panic (and "sometimes" is defined as "many machines" for us) when nothing 
else is eligible for kill within an oom cpuset yet doing a 
do_each_thread() over that cpuset shows threads of previously oom killed 
parent that have yet to exit.

> > > @@ -324,7 +324,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
> > >  		 * the process of exiting and releasing its resources.
> > >  		 * Otherwise we could get an easy OOM deadlock.
> > >  		 */
> > > -		if (thread_group_empty(p) && (p->flags & PF_EXITING) && p->mm) {
> > > +		if ((p->flags & PF_EXITING) && p->mm) {
> 
> The previous check was not perfect, we know this.
> 
> But with this patch applied, the simple program below disables oom-killer
> completely. select_bad_process() can never succeed.
> 

The program illustrates a problem that shouldn't be fixed in 
select_bad_process() but rather in oom_kill_process() when choosing an 
eligible child of the selected task to kill in place of its parent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
