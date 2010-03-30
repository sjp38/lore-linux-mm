Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B3C206B01EE
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 16:26:52 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [10.3.21.3])
	by smtp-out.google.com with ESMTP id o2UKQlM8023860
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 22:26:47 +0200
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by hpaq3.eem.corp.google.com with ESMTP id o2UKQh3x029542
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 22:26:46 +0200
Received: by pzk36 with SMTP id 36so2551496pzk.24
        for <linux-mm@kvack.org>; Tue, 30 Mar 2010 13:26:43 -0700 (PDT)
Date: Tue, 30 Mar 2010 13:26:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] oom: give current access to memory reserves if it has
 been killed
In-Reply-To: <20100330154659.GA12416@redhat.com>
Message-ID: <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com>
References: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com> <20100326150805.f5853d1c.akpm@linux-foundation.org> <20100326223356.GA20833@redhat.com> <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com>
 <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330154659.GA12416@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Mar 2010, Oleg Nesterov wrote:

> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -681,6 +681,16 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> >  	}
> >
> >  	/*
> > +	 * If current has a pending SIGKILL, then automatically select it.  The
> > +	 * goal is to allow it to allocate so that it may quickly exit and free
> > +	 * its memory.
> > +	 */
> > +	if (fatal_signal_pending(current)) {
> > +		__oom_kill_task(current);
> 
> I am worried...
> 
> Note that __oom_kill_task() does force_sig(SIGKILL) which assumes that
> ->sighand != NULL. This is not true if out_of_memory() is called after
> current has already passed exit_notify().
> 

We have an even bigger problem if current is in the oom killer at 
exit_notify() since it has already detached its ->mm in exit_mm() :)

> Hmm. looking at oom_kill.c... Afaics there are more problems with mt
> apllications. select_bad_process() does for_each_process() which can
> only see the group leaders. This is fine, but what if ->group_leader
> has already exited? In this case its ->mm == NULL, and we ignore the
> whole thread group.
> 
> IOW, unless I missed something, it is very easy to hide the process
> from oom-kill:
> 
> 	int main()
> 	{
> 		pthread_create(memory_hog_func);
> 		syscall(__NR_exit);
> 	}
> 

The check for !p->mm was moved in the -mm tree (and the oom killer was 
entirely rewritten in that tree, so I encourage you to work off of it 
instead) with 
oom-avoid-race-for-oom-killed-tasks-detaching-mm-prior-to-exit.patch to 
even after the check for PF_EXITING.  This is set in the exit path before 
the ->mm is detached so if the oom killer finds an already exiting task, 
it will become a no-op since it should eventually free memory and avoids a 
needless oom kill.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
