Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8B9216B0023
	for <linux-mm@kvack.org>; Fri, 13 May 2011 06:13:19 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 36CFC3EE0C5
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:13:17 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0799245DE99
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:13:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 96B3245DE93
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:13:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 86D841DB8043
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:13:16 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F2811DB8040
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:13:16 +0900 (JST)
Message-ID: <4DCD049B.4050003@jp.fujitsu.com>
Date: Fri, 13 May 2011 19:14:51 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] oom: improve dump_tasks() show items
References: <20110509182110.167F.A69D9226@jp.fujitsu.com> <20110510171335.16A7.A69D9226@jp.fujitsu.com> <20110510171600.16AB.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1105101623220.12477@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1105101623220.12477@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: CAI Qian <caiqian@redhat.com>, avagin@gmail.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>

Hi

Sorry for the delay. I did hit machine crash in this week and I lost
a lot of e-mail.


> On Tue, 10 May 2011, KOSAKI Motohiro wrote:
>
>> Recently, oom internal logic was dramatically changed. Thus
>> dump_tasks() is no longer useful. it has some meaningless
>> items and don't have some oom socre related items.
>>
>
> This changelog is inaccurate.
>
> dump_tasks() is actually useful as it currently stands; there are things
> that you may add or remove but saying that it is "no longer useful" is an
> exaggeration.

Hm. OK.

>
>> This patch adapt displaying fields to new oom logic.
>>
>> details
>> ==========
>> removed: pid (we always kill process. don't need thread id),
>>           mm->total_vm (we no longer uses virtual memory size)
>
> Showing mm->total_vm is still interesting to know what the old heuristic
> would have used rather than the new heuristic, I'd prefer if we kept it.

OK, reasonable.



>
>>           signal->oom_adj (we no longer uses it internally)
>> added: ppid (we often kill sacrifice child process)
>> modify: RSS (account mm->nr_ptes too)
>
> I'd prefer if ptes were shown independently from rss instead of adding it
> to the thread's true rss usage and representing it as such.

No. nr-pte should always be accounted as rss. I plan to change RLIMIT_RSS too.
Because, when end users change RLIMIT_RSS, they intend to limit number of physical
memory usage. It's not only subset. current total_rss = anon-rss + file-rss is
only implementation limit. In the other hand, if we makes separate RLIMIT, RLIMIT_RSS
and RLIMIT_PTE, RLIMIT_RSS don't prevent zero page DoS attack. it's no optimal.


> I think the cpu should also be removed.

ok.


> For the next version, could you show the old output and comparsion to new
> output in the changelog?

Will do.


>
>>
>> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
>> ---
>>
>> Strictly speaking. this is NOT a part of oom fixing patches. but it's
>> necessary when I parse QAI's test result.
>>
>>
>>   mm/oom_kill.c |   14 ++++++++------
>>   1 files changed, 8 insertions(+), 6 deletions(-)
>>
>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>> index f52e85c..118d958 100644
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -355,7 +355,7 @@ static void dump_tasks(const struct mem_cgroup *mem, const nodemask_t *nodemask)
>>   	struct task_struct *p;
>>   	struct task_struct *task;
>>
>> -	pr_info("[ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name\n");
>> +	pr_info("[   pid]   ppid   uid      rss  cpu score_adj name\n");
>>   	for_each_process(p) {
>>   		if (oom_unkillable_task(p, mem, nodemask))
>>   			continue;
>> @@ -370,11 +370,13 @@ static void dump_tasks(const struct mem_cgroup *mem, const nodemask_t *nodemask)
>>   			continue;
>>   		}
>>
>> -		pr_info("[%5d] %5d %5d %8lu %8lu %3u     %3d         %5d %s\n",
>> -			task->pid, task_uid(task), task->tgid,
>> -			task->mm->total_vm, get_mm_rss(task->mm),
>> -			task_cpu(task), task->signal->oom_adj,
>> -			task->signal->oom_score_adj, task->comm);
>> +		pr_info("[%6d] %6d %5d %8lu %4u %9d %s\n",
>> +			task_tgid_nr(task), task_tgid_nr(task->real_parent),
>> +			task_uid(task),
>> +			get_mm_rss(task->mm) + p->mm->nr_ptes,
>> +			task_cpu(task),
>> +			task->signal->oom_score_adj,
>> +			task->comm);
>>   		task_unlock(task);
>>   	}
>>   }
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
