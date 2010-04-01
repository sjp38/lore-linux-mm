Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 26E826B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 10:40:58 -0400 (EDT)
Date: Thu, 1 Apr 2010 16:39:10 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch] oom: give current access to memory reserves if it has
	been killed
Message-ID: <20100401143910.GB14603@redhat.com>
References: <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330154659.GA12416@redhat.com> <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com> <20100331175836.GA11635@redhat.com> <alpine.DEB.2.00.1003311342410.25284@chino.kir.corp.google.com> <20100331224904.GA4025@redhat.com> <20100331233058.GA6081@redhat.com> <alpine.DEB.2.00.1003311641470.2150@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003311641470.2150@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 03/31, David Rientjes wrote:
>
> On Thu, 1 Apr 2010, Oleg Nesterov wrote:
>
> > > Why? You ignored this part:
> > >
> > > 	Say, right after exit_mm() we are doing acct_process(), and f_op->write()
> > > 	needs a page. So, you are saying that in this case __page_cache_alloc()
> > > 	can never trigger out_of_memory() ?
> > >
> > > why this is not possible?
> > >
> > > David, I am not arguing, I am asking.
> >
> > In case I wasn't clear...
> >
> > Yes, currently __oom_kill_task(p) is not possible if p->mm == NULL.
> >
> > But your patch adds
> >
> > 	if (fatal_signal_pending(current))
> > 		__oom_kill_task(current);
> >
> > into out_of_memory().
> >
>
> Ok, and it's possible during the tasklist scan if current is PF_EXITING
> and that gets passed to oom_kill_process(),

Yes, but this is harmless, afaics. The task is either current or it was
found by select_bad_process() under tasklist. This means it is safe to
use force_sig (but as I said, we should not use force_sig() anyway).

> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -459,7 +459,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  	 * its children or threads, just set TIF_MEMDIE so it can die quickly
>  	 */
>  	if (p->flags & PF_EXITING) {
> -		__oom_kill_task(p);
> +		set_tsk_thread_flag(p, TIF_MEMDIE);

So, probably this makes sense anyway but not strictly necessary, up to you.

>  	if (fatal_signal_pending(current)) {
> -		__oom_kill_task(current);
> +		set_tsk_thread_flag(current, TIF_MEMDIE);

Yes, I think this fix is needed.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
