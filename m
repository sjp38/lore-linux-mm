Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 96D886B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 12:35:52 -0400 (EDT)
Message-ID: <51FA8E3D.4070204@redhat.com>
Date: Thu, 01 Aug 2013 12:35:09 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH,RFC] numa,sched: use group fault statistics in numa placement
References: <1373901620-2021-1-git-send-email-mgorman@suse.de> <20130730113857.GR3008@twins.programming.kicks-ass.net> <20130801022319.4a6a977a@annuminas.surriel.com> <20130801103713.GO3008@twins.programming.kicks-ass.net>
In-Reply-To: <20130801103713.GO3008@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 08/01/2013 06:37 AM, Peter Zijlstra wrote:
> On Thu, Aug 01, 2013 at 02:23:19AM -0400, Rik van Riel wrote:
>> Subject: [PATCH,RFC] numa,sched: use group fault statistics in numa placement
>>
>> Here is a quick strawman on how the group fault stuff could be used
>> to help pick the best node for a task. This is likely to be quite
>> suboptimal and in need of tweaking. My main goal is to get this to
>> Peter & Mel before it's breakfast time on their side of the Atlantic...
>>
>> This goes on top of "sched, numa: Use {cpu, pid} to create task groups for shared faults"
>>
>> Enjoy :)
>>
>> +	/*
>> +	 * Should we stay on our own, or move in with the group?
>> +	 * The absolute count of faults may not be useful, but comparing
>> +	 * the fraction of accesses in each top node may give us a hint
>> +	 * where to start looking for a migration target.
>> +	 *
>> +	 *  max_group_faults     max_faults
>> +	 * ------------------ > ------------
>> +	 * total_group_faults   total_faults
>> +	 */
>> +	if (max_group_nid >= 0 && max_group_nid != max_nid) {
>> +		if (max_group_faults * total_faults >
>> +				max_faults * total_group_faults)
>> +			max_nid = max_group_nid;
>> +	}
>
> This makes sense.. another part of the problem, which you might already
> have spotted is selecting a task to swap with.
>
> If you only look at per task faults its often impossible to find a
> suitable swap task because moving you to a more suitable node would
> degrade the other task -- below a patch you've already seen but I
> haven't yet posted because I'm not at all sure its something 'sane' :-)

I did not realize you had not posted that patch yet, and was
actually building on top of it :)

I suspect that comparing both per-task and per-group fault weights
in task_numa_compare should make your code do the right thing in
task_numa_migrate.

I suspect there will be enough randomness in accesses that they
will never be exactly the same, so we might not need an explicit
tie breaker.

However, if numa_migrate_preferred fails, we may want to try
migrating to any node that has a better score than the current
one.  After all, if we have a group of tasks that would fit in
2 NUMA nodes, we don't want half of the tasks to not migrate
at all because the top node is full. We want them to move to
the #2 node at some point.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
