Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5BD646B0011
	for <linux-mm@kvack.org>; Fri, 13 May 2011 06:28:56 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 878EF3EE0C1
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:28:53 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A24B45DE58
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:28:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C21645DE56
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:28:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3CDC7E08001
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:28:53 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E922DEF8002
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:28:52 +0900 (JST)
Message-ID: <4DCD0845.10409@jp.fujitsu.com>
Date: Fri, 13 May 2011 19:30:29 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] oom: oom-killer don't use permillage of system-ram
 internally
References: <20110509182110.167F.A69D9226@jp.fujitsu.com> <20110510171335.16A7.A69D9226@jp.fujitsu.com> <20110510171724.16B3.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1105101632290.12477@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1105101632290.12477@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: CAI Qian <caiqian@redhat.com>, avagin@gmail.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>

(2011/05/11 8:40), David Rientjes wrote:
> On Tue, 10 May 2011, KOSAKI Motohiro wrote:
>
>> CAI Qian reported his kernel did hang-up if he ran fork intensive
>> workload and then invoke oom-killer.
>>
>> The problem is, Current oom calculation uses 0-1000 normalized value
>> (The unit is a permillage of system-ram). Its low precision make
>> a lot of same oom score. IOW, in his case, all processes have<1
>> oom score and internal integral calculation round it to 1. Thus
>> oom-killer kill ineligible process. This regression is caused by
>> commit a63d83f427 (oom: badness heuristic rewrite).
>>
>> The solution is, the internal calculation just use number of pages
>> instead of permillage of system-ram. And convert it to permillage
>> value at displaying time.
>>
>> This patch doesn't change any ABI (included  /proc/<pid>/oom_score_adj)
>> even though current logic has a lot of my dislike thing.
>>
>
> s/permillage/proportion/
>
> This is unacceptable, it does not allow users to tune oom_score_adj
> appropriately based on the scores exported by /proc/pid/oom_score to
> discount an amount of RAM from a thread's memory usage in systemwide,
> memory controller, cpuset, or mempolicy contexts.  This is only possible
> because the oom score is normalized.

You misunderstand the code. The patch doesn't change oom_score.
The patch change fs/proc too.

>
> What would be acceptable would be to increase the granularity of the score
> to 10000 or 100000 to differentiate between threads using 0.01% or 0.001%
> of RAM from each other, respectively.  The range of oom_score_adj would
> remain the same, however, and be multiplied by 10 or 100, respectively,
> when factored into the badness score baseline.  I don't believe userspace
> cares to differentiate between more than 0.1% of available memory.

Currently, SGI buy 16TB memory. 16TB x 0.1% = 1.6GB. I don't think your
fork bomb process use bigger than 1.6GB. Thus your patch is unacceptable.

So, please read the code again. or run it.

> The other issue that this patch addresses is the bonus given to root
> processes.  I agree that if a root process is using 4% of RAM that it
> should not be equal to all other threads using 1%.  I do believe that a
> root process using 60% of RAM should be equal priority to a thread using
> 57%, however.  Perhaps a compromise would be to give root processes a
> bonus of 1% for every 30% of RAM they consume?

I think you are talking about patch [4/4], right? patch [3/4] and [4/4]
are attacking another issue. big machine issue and root user issue.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
