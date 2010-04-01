Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2633C6B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 14:58:37 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o31IwQw4018883
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 11:58:27 -0700
Received: from pwj3 (pwj3.prod.google.com [10.241.219.67])
	by wpaz9.hot.corp.google.com with ESMTP id o31IwPoJ021139
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 11:58:25 -0700
Received: by pwj3 with SMTP id 3so408300pwj.22
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 11:58:24 -0700 (PDT)
Date: Thu, 1 Apr 2010 11:58:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] oom: give current access to memory reserves if it has
 been killed
In-Reply-To: <20100401143910.GB14603@redhat.com>
Message-ID: <alpine.DEB.2.00.1004011156040.30661@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330154659.GA12416@redhat.com> <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com>
 <20100331175836.GA11635@redhat.com> <alpine.DEB.2.00.1003311342410.25284@chino.kir.corp.google.com> <20100331224904.GA4025@redhat.com> <20100331233058.GA6081@redhat.com> <alpine.DEB.2.00.1003311641470.2150@chino.kir.corp.google.com>
 <20100401143910.GB14603@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 1 Apr 2010, Oleg Nesterov wrote:

> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -459,7 +459,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> >  	 * its children or threads, just set TIF_MEMDIE so it can die quickly
> >  	 */
> >  	if (p->flags & PF_EXITING) {
> > -		__oom_kill_task(p);
> > +		set_tsk_thread_flag(p, TIF_MEMDIE);
> 
> So, probably this makes sense anyway but not strictly necessary, up to you.
> 

It matches the already-existing comment that only says we need to set 
TIF_MEMDIE so it can quickly exit rather than call __oom_kill_task(), so 
it seems worthwhile.

> >  	if (fatal_signal_pending(current)) {
> > -		__oom_kill_task(current);
> > +		set_tsk_thread_flag(current, TIF_MEMDIE);
> 
> Yes, I think this fix is needed.
> 

Ok, I'll add your acked-by and send this to Andrew with a follow-up that 
consolidates __oom_kill_task() into oom_kill_task(), thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
