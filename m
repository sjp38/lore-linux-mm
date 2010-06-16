Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 43C9D6B01AC
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 15:54:57 -0400 (EDT)
Received: by wyf28 with SMTP id 28so6658085wyf.14
        for <linux-mm@kvack.org>; Wed, 16 Jun 2010 12:54:54 -0700 (PDT)
Date: Wed, 16 Jun 2010 16:54:47 -0300
From: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>
Subject: Re: [PATCH 9/9] oom: give the dying task a higher priority
Message-ID: <20100616195447.GH5009@uudg.org>
References: <20100616201948.72D7.A69D9226@jp.fujitsu.com>
 <20100616203517.72EF.A69D9226@jp.fujitsu.com>
 <20100616153120.GH9278@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100616153120.GH9278@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 17, 2010 at 12:31:20AM +0900, Minchan Kim wrote:
| >         /*
| >          * We give our sacrificial lamb high priority and access to
| >          * all the memory it needs. That way it should be able to
| >          * exit() and clear out its resources quickly...
| >          */
| >  	p->rt.time_slice = HZ;
| >  	set_tsk_thread_flag(p, TIF_MEMDIE);
...
| > +	if (rt_task(p)) {
| > +		p->rt.time_slice = HZ;
| > +		return;

I am not sure the code above will have any real effect for an RT task.
Kosaki-san, was this change motivated by test results or was it just a code
cleanup? I ask that out of curiosity.

| I have a question from long time ago. 
| If we change rt.time_slice _without_ setscheduler, is it effective?
| I mean scheduler pick up the task faster than other normal task?

$ git log --pretty=oneline -Stime_slice mm/oom_kill.c
1da177e4c3f41524e886b7f1b8a0c1fc7321cac2 Linux-2.6.12-rc2

This code ("time_slice = HZ;") is around for quite a while and
probably comes from a time where having a big time slice was enough to be
sure you would be the next on the line. I would say sched_setscheduler is
indeed necessary.

Regards,
Luis
-- 
[ Luis Claudio R. Goncalves             Red Hat  -  Realtime Team ]
[ Fingerprint: 4FDD B8C4 3C59 34BD 8BE9  2696 7203 D980 A448 C8F8 ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
