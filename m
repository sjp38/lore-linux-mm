Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0C6426B01CA
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 14:48:46 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o58Imhg7022973
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 11:48:43 -0700
Received: from pxi19 (pxi19.prod.google.com [10.243.27.19])
	by kpbe17.cbf.corp.google.com with ESMTP id o58ImgUs026553
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 11:48:42 -0700
Received: by pxi19 with SMTP id 19so1834574pxi.3
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 11:48:41 -0700 (PDT)
Date: Tue, 8 Jun 2010 11:48:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 06/18] oom: avoid sending exiting tasks a SIGKILL
In-Reply-To: <20100608203250.7660.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006081147540.18848@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061524190.32225@chino.kir.corp.google.com> <20100608203250.7660.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, KOSAKI Motohiro wrote:

> > It's unnecessary to SIGKILL a task that is already PF_EXITING and can
> > actually cause a NULL pointer dereference of the sighand if it has already
> > been detached.  Instead, simply set TIF_MEMDIE so it has access to memory
> > reserves and can quickly exit as the comment implies.
> > 
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Signed-off-by: David Rientjes <rientjes@google.com>
> > ---
> >  mm/oom_kill.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -458,7 +458,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> >  	 * its children or threads, just set TIF_MEMDIE so it can die quickly
> >  	 */
> >  	if (p->flags & PF_EXITING) {
> > -		__oom_kill_task(p, 0);
> > +		set_tsk_thread_flag(p, TIF_MEMDIE);
> >  		return 0;
> >  	}
> >  
> 
> I don't pulled PF_EXITING related thing.
> 

What are you pulling?  You're not a maintainer!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
