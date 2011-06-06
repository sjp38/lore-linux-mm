Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 3F29D6B004A
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 10:45:22 -0400 (EDT)
Received: by pwi12 with SMTP id 12so2639590pwi.14
        for <linux-mm@kvack.org>; Mon, 06 Jun 2011 07:45:09 -0700 (PDT)
Date: Mon, 6 Jun 2011 23:44:59 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v2 0/5] Fix oom killer doesn't work at all if system
 have > gigabytes memory  (aka CAI founded issue)
Message-ID: <20110606144458.GG1686@barrios-laptop>
References: <348391538.318712.1306828778575.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
 <4DE4A2A0.6090704@jp.fujitsu.com>
 <4DE4BC64.3040807@jp.fujitsu.com>
 <20110601033258.GA12653@barrios-laptop>
 <4DEC4463.1060206@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4DEC4463.1060206@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: caiqian@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, oleg@redhat.com

On Mon, Jun 06, 2011 at 12:07:15PM +0900, KOSAKI Motohiro wrote:
> >> Of course, we recommend to drop privileges as far as possible
> >> instead of keeping them. Thus, oom killer don't have to check
> >> any capability. It implicitly suggest wrong programming style.
> >>
> >> This patch change root process check way from CAP_SYS_ADMIN to
> >> just euid==0.
> > 
> > I like this but I have some comments.
> > Firstly, it's not dependent with your series so I think this could
> > be merged firstly.
> 
> I agree.
> 
> > Before that, I would like to make clear my concern.
> > As I look below comment, 3% bonus is dependent with __vm_enough_memory's logic?
> 
> No. completely independent.
> 
> vm_enough_memory() check the task _can_ allocate more memory. IOW, the task
> is subjective. And oom-killer check the task should be protected from oom-killer.
> IOW, the task is objective.
> 

Hmm, maybe I can't understand your point.
My though was below.

Assumption)
1. root allocation bonus point -> 10% 
2. OOM have no bonus about root process

Scenario)
1.
System has 101 free pages and 10 normal tasks.
Ideally, 10 tasks allocates free memory fairly so each task will have 10 pages.
So OOM killer can select victim fairly when new task which requires 10 pages forks.

2.
System has 101 free pages and 10 tasks. (9 normal task , 1 root task)
10 * 9 + 11 will be consumed. So each normal task will have 10 pages
but a root task have 11 pages.
So OOM killer can always selectd root process as vicim.(We assumed
OOM doesn't have a bonus on root process)

Conclusion)
For solving above problem, we have to give bonus which was given
in allocation to OOM, too. It's fair.
So I think it has a dependency.

-- 
Kind regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
