Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F39696B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 18:32:52 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p4NMWn5o026244
	for <linux-mm@kvack.org>; Mon, 23 May 2011 15:32:49 -0700
Received: from pvg11 (pvg11.prod.google.com [10.241.210.139])
	by hpaq2.eem.corp.google.com with ESMTP id p4NMWKQv011983
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 May 2011 15:32:48 -0700
Received: by pvg11 with SMTP id 11so3365868pvg.41
        for <linux-mm@kvack.org>; Mon, 23 May 2011 15:32:48 -0700 (PDT)
Date: Mon, 23 May 2011 15:32:46 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/5] oom: don't kill random process
In-Reply-To: <4DD6207E.1070300@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1105231529340.17840@chino.kir.corp.google.com>
References: <4DD61F80.1020505@jp.fujitsu.com> <4DD6207E.1070300@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

On Fri, 20 May 2011, KOSAKI Motohiro wrote:

> CAI Qian reported oom-killer killed all system daemons in his
> system at first if he ran fork bomb as root. The problem is,
> current logic give them bonus of 3% of system ram. Example,
> he has 16GB machine, then root processes have ~500MB oom
> immune. It bring us crazy bad result. _all_ processes have
> oom-score=1 and then, oom killer ignore process memory usage
> and kill random process. This regression is caused by commit
> a63d83f427 (oom: badness heuristic rewrite).
> 
> This patch changes select_bad_process() slightly. If oom points == 1,
> it's a sign that the system have only root privileged processes or
> similar. Thus, select_bad_process() calculate oom badness without
> root bonus and select eligible process.
> 

You said earlier that you thought it was a good idea to do a proportional 
based bonus for root processes.  Do you have a specific objection to 
giving root processes a 1% bonus for every 10% of used memory instead?

> Also, this patch move finding sacrifice child logic into
> select_bad_process(). It's necessary to implement adequate
> no root bonus recalculation. and it makes good side effect,
> current logic doesn't behave as the doc.
> 

This is unnecessary and just makes the oom killer egregiously long.  We 
are already diagnosing problems here at Google where the oom killer holds 
tasklist_lock on the readside for far too long, causing other cpus waiting 
for a write_lock_irq(&tasklist_lock) to encounter issues when irqs are 
disabled and it is spinning.  A second tasklist scan is simply a 
non-starter.

 [ This is also one of the reasons why we needed to introduce
   mm->oom_disable_count to prevent a second, expensive tasklist scan. ]

> Documentation/sysctl/vm.txt says
> 
>     oom_kill_allocating_task
> 
>     If this is set to non-zero, the OOM killer simply kills the task that
>     triggered the out-of-memory condition.  This avoids the expensive
>     tasklist scan.
> 
> IOW, oom_kill_allocating_task shouldn't search sacrifice child.
> This patch also fixes this issue.
> 

oom_kill_allocating_task was introduced for SGI to prevent the expensive 
tasklist scan, the task that is actually allocating the memory isn't 
actually interesting and is usually random.  This should be turned into a 
documentation fix rather than changing the implementation.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
