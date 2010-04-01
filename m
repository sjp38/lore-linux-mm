Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C970B6B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 10:01:31 -0400 (EDT)
Date: Thu, 1 Apr 2010 15:59:27 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch] oom: give current access to memory reserves if it has
	been killed
Message-ID: <20100401135927.GA12460@redhat.com>
References: <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330154659.GA12416@redhat.com> <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com> <20100331175836.GA11635@redhat.com> <20100331204718.GD11635@redhat.com> <alpine.DEB.2.00.1004010133190.6285@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1004010133190.6285@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 04/01, David Rientjes wrote:
>
> On Wed, 31 Mar 2010, Oleg Nesterov wrote:
>
> > Probably something like the patch below makes sense. Note that
> > "skip kernel threads" logic is wrong too, we should check PF_KTHREAD.
> > Probably it is better to check it in select_bad_process() instead,
> > near is_global_init().
>
> is_global_init() will be true for p->flags & PF_KTHREAD.

No, is_global_init() && PF_KTHREAD have nothing to do with each other.

> > @@ -159,13 +172,9 @@ unsigned int oom_badness(struct task_str
> >  	if (p->flags & PF_OOM_ORIGIN)
> >  		return 1000;
> >
> > -	task_lock(p);
> > -	mm = p->mm;
> > -	if (!mm) {
> > -		task_unlock(p);
> > +	p = find_lock_task_mm(p);
> > +	if (!p)
> >  		return 0;
> > -	}
> > -
> >  	/*
> >  	 * The baseline for the badness score is the proportion of RAM that each
> >  	 * task's rss and swap space use.
> > @@ -330,12 +339,6 @@ static struct task_struct *select_bad_pr
> >  			*ppoints = 1000;
> >  		}
> >
> > -		/*
> > -		 * skip kernel threads and tasks which have already released
> > -		 * their mm.
> > -		 */
> > -		if (!p->mm)
> > -			continue;
> >  		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> >  			continue;
>
> You can't do this for the reason I cited in another email, oom_badness()
> returning 0 does not exclude a task from being chosen by
> selcet_bad_process(), it will use that task if nothing else has been found
> yet.  We must explicitly filter it from consideration by checking for
> !p->mm.

Yes, you are right. OK, oom_badness() can never return points < 0,
we can make it int and oom_badness() can return -1 if !mm. IOW,

	- unsigned int points;
	+ int points;
	...

	points = oom_badness(...);
	if (points >= 0 && (points > *ppoints || !chosen))
		chosen = p;

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
