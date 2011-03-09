Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0DCC68D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 06:14:44 -0500 (EST)
Date: Wed, 9 Mar 2011 12:06:06 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch] oom: prevent unnecessary oom kills or kernel panics
Message-ID: <20110309110606.GA16719@redhat.com>
References: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com> <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com> <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>

On 03/08, David Rientjes wrote:
>
> On Tue, 8 Mar 2011, Oleg Nesterov wrote:
>
> > > > By iterating over threads instead, it is possible to detect threads that
> > > > are exiting and nominate them for oom kill so they get access to memory
> > > > reserves.
> > >
> > > In fact, PF_EXITING is a sing of *THREAD* exiting, not process. Therefore
> > > PF_EXITING is not a sign of memory freeing in nearly future. If other
> > > CPUs don't try to free memory, prevent oom and waiting makes deadlock.
> >
> > I agree. I don't understand this patch.
> >
>
> Using for_each_process() does not consider threads that have failed to
> exit after the oom killed parent and, thus, we select another innocent
> task to kill when we're really just waiting for those threads to exit

How so? select_bad_process() checks TIF_MEMDIE and returns ERR_PTR()
if it is set.

And, exactly because we use for_each_process() we do not need to check
other threads. The main thread can't disappear until they all exit.

Imho TIF_MEMDIE is not perfect and should be replaced by MMF_, but this
is another story. Hmm... and in any case, currently TIF_MEMDIE is not
always used correctly, afaics.

> The end result is that without this patch, we sometimes unnecessarily
> panic (and "sometimes" is defined as "many machines" for us) when nothing
> else is eligible for kill within an oom cpuset yet doing a
> do_each_thread() over that cpuset shows threads of previously oom killed
> parent that have yet to exit.
>
> > > > @@ -324,7 +324,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
> > > >  		 * the process of exiting and releasing its resources.
> > > >  		 * Otherwise we could get an easy OOM deadlock.
> > > >  		 */
> > > > -		if (thread_group_empty(p) && (p->flags & PF_EXITING) && p->mm) {
> > > > +		if ((p->flags & PF_EXITING) && p->mm) {
> >
> > The previous check was not perfect, we know this.
> >
> > But with this patch applied, the simple program below disables oom-killer
> > completely. select_bad_process() can never succeed.
> >
>
> The program illustrates a problem that shouldn't be fixed in
> select_bad_process() but rather in oom_kill_process() when choosing an
> eligible child of the selected task to kill in place of its parent.

Can't understand. oom_kill_process() is never called exactly because
select_bad_process() is fooled.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
