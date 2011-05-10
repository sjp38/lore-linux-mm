Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 10FD26B0011
	for <linux-mm@kvack.org>; Tue, 10 May 2011 20:02:47 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p4ANes6O017483
	for <linux-mm@kvack.org>; Tue, 10 May 2011 16:40:54 -0700
Received: from pzk35 (pzk35.prod.google.com [10.243.19.163])
	by hpaq6.eem.corp.google.com with ESMTP id p4ANegud023845
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 10 May 2011 16:40:52 -0700
Received: by pzk35 with SMTP id 35so4121190pzk.39
        for <linux-mm@kvack.org>; Tue, 10 May 2011 16:40:52 -0700 (PDT)
Date: Tue, 10 May 2011 16:40:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/4] oom: oom-killer don't use permillage of system-ram
 internally
In-Reply-To: <20110510171724.16B3.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1105101632290.12477@chino.kir.corp.google.com>
References: <20110509182110.167F.A69D9226@jp.fujitsu.com> <20110510171335.16A7.A69D9226@jp.fujitsu.com> <20110510171724.16B3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: CAI Qian <caiqian@redhat.com>, avagin@gmail.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>

On Tue, 10 May 2011, KOSAKI Motohiro wrote:

> CAI Qian reported his kernel did hang-up if he ran fork intensive
> workload and then invoke oom-killer.
> 
> The problem is, Current oom calculation uses 0-1000 normalized value
> (The unit is a permillage of system-ram). Its low precision make
> a lot of same oom score. IOW, in his case, all processes have <1
> oom score and internal integral calculation round it to 1. Thus
> oom-killer kill ineligible process. This regression is caused by
> commit a63d83f427 (oom: badness heuristic rewrite).
> 
> The solution is, the internal calculation just use number of pages
> instead of permillage of system-ram. And convert it to permillage
> value at displaying time.
> 
> This patch doesn't change any ABI (included  /proc/<pid>/oom_score_adj)
> even though current logic has a lot of my dislike thing.
> 

s/permillage/proportion/

This is unacceptable, it does not allow users to tune oom_score_adj 
appropriately based on the scores exported by /proc/pid/oom_score to 
discount an amount of RAM from a thread's memory usage in systemwide, 
memory controller, cpuset, or mempolicy contexts.  This is only possible 
because the oom score is normalized.

What would be acceptable would be to increase the granularity of the score 
to 10000 or 100000 to differentiate between threads using 0.01% or 0.001% 
of RAM from each other, respectively.  The range of oom_score_adj would 
remain the same, however, and be multiplied by 10 or 100, respectively, 
when factored into the badness score baseline.  I don't believe userspace 
cares to differentiate between more than 0.1% of available memory.

The other issue that this patch addresses is the bonus given to root 
processes.  I agree that if a root process is using 4% of RAM that it 
should not be equal to all other threads using 1%.  I do believe that a 
root process using 60% of RAM should be equal priority to a thread using 
57%, however.  Perhaps a compromise would be to give root processes a 
bonus of 1% for every 30% of RAM they consume?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
