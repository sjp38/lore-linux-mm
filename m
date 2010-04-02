Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E6A376B01FA
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 07:16:14 -0400 (EDT)
Date: Fri, 2 Apr 2010 13:14:06 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch] oom: give current access to memory reserves if it has
	been killed
Message-ID: <20100402111406.GA4432@redhat.com>
References: <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330154659.GA12416@redhat.com> <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com> <20100331175836.GA11635@redhat.com> <20100331204718.GD11635@redhat.com> <alpine.DEB.2.00.1004010133190.6285@chino.kir.corp.google.com> <20100401135927.GA12460@redhat.com> <alpine.DEB.2.00.1004011210380.30661@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1004011210380.30661@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 04/01, David Rientjes wrote:
>
> On Thu, 1 Apr 2010, Oleg Nesterov wrote:
>
> > > You can't do this for the reason I cited in another email, oom_badness()
> > > returning 0 does not exclude a task from being chosen by
> > > selcet_bad_process(), it will use that task if nothing else has been found
> > > yet.  We must explicitly filter it from consideration by checking for
> > > !p->mm.
> >
> > Yes, you are right. OK, oom_badness() can never return points < 0,
> > we can make it int and oom_badness() can return -1 if !mm. IOW,
> >
> > 	- unsigned int points;
> > 	+ int points;
> > 	...
> >
> > 	points = oom_badness(...);
> > 	if (points >= 0 && (points > *ppoints || !chosen))
> > 		chosen = p;
> >
>
> oom_badness() and its predecessor badness() in mainline never return
> negative scores, so I don't see the value in doing this; just filter the
> task in select_bad_process() with !p->mm as it has always been done.

David, you continue to ignore my arguments ;) select_bad_process()
must not filter out the tasks with ->mm == NULL.

Once again:

	void *memory_hog_thread(void *arg)
	{
		for (;;)
			malloc(A_LOT);
	}

	int main(void)
	{
		pthread_create(memory_hog_thread, ...);
		syscall(__NR_exit, 0);
	}

Now, even if we fix PF_EXITING check, select_bad_process() will always
ignore this process. The group leader has ->mm == NULL.

See?

That is why I think we need something like find_lock_task_mm() in the
pseudo-patch I sent.

Or I missed something?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
