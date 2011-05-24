Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2037D6B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 21:35:13 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 73BBB3EE0C2
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:35:09 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 57FFA45DF31
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:35:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3310145DF30
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:35:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 222A7E08001
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:35:09 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B7E8EE78002
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:35:08 +0900 (JST)
Message-ID: <4DDB0B45.2080507@jp.fujitsu.com>
Date: Tue, 24 May 2011 10:35:01 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] oom: don't kill random process
References: <4DD61F80.1020505@jp.fujitsu.com> <4DD6207E.1070300@jp.fujitsu.com> <alpine.DEB.2.00.1105231529340.17840@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1105231529340.17840@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

(2011/05/24 7:32), David Rientjes wrote:
> On Fri, 20 May 2011, KOSAKI Motohiro wrote:
>
>> CAI Qian reported oom-killer killed all system daemons in his
>> system at first if he ran fork bomb as root. The problem is,
>> current logic give them bonus of 3% of system ram. Example,
>> he has 16GB machine, then root processes have ~500MB oom
>> immune. It bring us crazy bad result. _all_ processes have
>> oom-score=1 and then, oom killer ignore process memory usage
>> and kill random process. This regression is caused by commit
>> a63d83f427 (oom: badness heuristic rewrite).
>>
>> This patch changes select_bad_process() slightly. If oom points == 1,
>> it's a sign that the system have only root privileged processes or
>> similar. Thus, select_bad_process() calculate oom badness without
>> root bonus and select eligible process.
>>
>
> You said earlier that you thought it was a good idea to do a proportional
> based bonus for root processes.  Do you have a specific objection to
> giving root processes a 1% bonus for every 10% of used memory instead?

Because it's completely another topic. You have to maek another patch.



>> Also, this patch move finding sacrifice child logic into
>> select_bad_process(). It's necessary to implement adequate
>> no root bonus recalculation. and it makes good side effect,
>> current logic doesn't behave as the doc.
>>
>
> This is unnecessary and just makes the oom killer egregiously long.  We
> are already diagnosing problems here at Google where the oom killer holds
> tasklist_lock on the readside for far too long, causing other cpus waiting
> for a write_lock_irq(&tasklist_lock) to encounter issues when irqs are
> disabled and it is spinning.  A second tasklist scan is simply a
> non-starter.
>
>   [ This is also one of the reasons why we needed to introduce
>     mm->oom_disable_count to prevent a second, expensive tasklist scan. ]

You misunderstand the code. Both select_bad_process() and oom_kill_process()
are under tasklist_lock(). IOW, no change lock holding time.


>> Documentation/sysctl/vm.txt says
>>
>>      oom_kill_allocating_task
>>
>>      If this is set to non-zero, the OOM killer simply kills the task that
>>      triggered the out-of-memory condition.  This avoids the expensive
>>      tasklist scan.
>>
>> IOW, oom_kill_allocating_task shouldn't search sacrifice child.
>> This patch also fixes this issue.
>>
>
> oom_kill_allocating_task was introduced for SGI to prevent the expensive
> tasklist scan, the task that is actually allocating the memory isn't
> actually interesting and is usually random.  This should be turned into a
> documentation fix rather than changing the implementation.

No benefit. I don't take it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
