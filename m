Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 804E36B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 18:28:35 -0400 (EDT)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id p4NMSYwU018600
	for <linux-mm@kvack.org>; Mon, 23 May 2011 15:28:34 -0700
Received: from pvg13 (pvg13.prod.google.com [10.241.210.141])
	by kpbe18.cbf.corp.google.com with ESMTP id p4NMSWNi014644
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 May 2011 15:28:32 -0700
Received: by pvg13 with SMTP id 13so3215671pvg.26
        for <linux-mm@kvack.org>; Mon, 23 May 2011 15:28:32 -0700 (PDT)
Date: Mon, 23 May 2011 15:28:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/5] oom: oom-killer don't use proportion of system-ram
 internally
In-Reply-To: <4DD6204D.5020109@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1105231522410.17840@chino.kir.corp.google.com>
References: <4DD61F80.1020505@jp.fujitsu.com> <4DD6204D.5020109@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

On Fri, 20 May 2011, KOSAKI Motohiro wrote:

> CAI Qian reported his kernel did hang-up if he ran fork intensive
> workload and then invoke oom-killer.
> 
> The problem is, current oom calculation uses 0-1000 normalized value
> (The unit is a permillage of system-ram). Its low precision make
> a lot of same oom score. IOW, in his case, all processes have smaller
> oom score than 1 and internal calculation round it to 1.
> 
> Thus oom-killer kill ineligible process. This regression is caused by
> commit a63d83f427 (oom: badness heuristic rewrite).
> 
> The solution is, the internal calculation just use number of pages
> instead of permillage of system-ram. And convert it to permillage
> value at displaying time.
> 
> This patch doesn't change any ABI (included  /proc/<pid>/oom_score_adj)
> even though current logic has a lot of my dislike thing.
> 

Same response as when you initially proposed this patch: 
http://marc.info/?l=linux-kernel&m=130507086613317 -- you never replied to 
that.

The changelog doesn't accurately represent CAI Qian's problem; the issue 
is that root processes are given too large of a bonus in comparison to 
other threads that are using at most 1.9% of available memory.  That can 
be fixed, as I suggested by giving 1% bonus per 10% of memory used so that 
the process would have to be using 10% before it even receives a bonus.

I already suggested an alternative patch to CAI Qian to greatly increase 
the granularity of the oom score from a range of 0-1000 to 0-10000 to 
differentiate between tasks within 0.01% of available memory (16MB on CAI 
Qian's 16GB system).  I'll propose this officially in a separate email.

This patch also includes undocumented changes such as changing the bonus 
given to root processes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
