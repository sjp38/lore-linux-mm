Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 96B2F6B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 14:03:06 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id i8so6129350qcq.4
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 11:03:06 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id nh12si1291994qeb.4.2014.01.20.11.03.05
        for <linux-mm@kvack.org>;
        Mon, 20 Jan 2014 11:03:05 -0800 (PST)
Message-ID: <52DD72C8.2050602@redhat.com>
Date: Mon, 20 Jan 2014 14:02:32 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/7] numa,sched: normalize faults_from stats and weigh
 by CPU use
References: <1389993129-28180-1-git-send-email-riel@redhat.com> <1389993129-28180-7-git-send-email-riel@redhat.com> <20140120165747.GL31570@twins.programming.kicks-ass.net>
In-Reply-To: <20140120165747.GL31570@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, chegu_vinod@hp.com, mgorman@suse.de, mingo@redhat.com

On 01/20/2014 11:57 AM, Peter Zijlstra wrote:
> On Fri, Jan 17, 2014 at 04:12:08PM -0500, riel@redhat.com wrote:
>> diff --git a/include/linux/sched.h b/include/linux/sched.h
>> index 0af6c1a..52de567 100644
>> --- a/include/linux/sched.h
>> +++ b/include/linux/sched.h
>> @@ -1471,6 +1471,8 @@ struct task_struct {
>>  	int numa_preferred_nid;
>>  	unsigned long numa_migrate_retry;
>>  	u64 node_stamp;			/* migration stamp  */
>> +	u64 last_task_numa_placement;
>> +	u64 last_sum_exec_runtime;
>>  	struct callback_head numa_work;
>>  
>>  	struct list_head numa_entry;
> 
>> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
>> index 8e0a53a..0d395a0 100644
>> --- a/kernel/sched/fair.c
>> +++ b/kernel/sched/fair.c
>> @@ -1422,11 +1422,41 @@ static void update_task_scan_period(struct task_struct *p,
>>  	memset(p->numa_faults_locality, 0, sizeof(p->numa_faults_locality));
>>  }
>>  
>> +/*
>> + * Get the fraction of time the task has been running since the last
>> + * NUMA placement cycle. The scheduler keeps similar statistics, but
>> + * decays those on a 32ms period, which is orders of magnitude off
>> + * from the dozens-of-seconds NUMA balancing period. Use the scheduler
>> + * stats only if the task is so new there are no NUMA statistics yet.
>> + */
>> +static u64 numa_get_avg_runtime(struct task_struct *p, u64 *period)
>> +{
>> +	u64 runtime, delta, now;
>> +	/* Use the start of this time slice to avoid calculations. */
>> +	now = p->se.exec_start;
>> +	runtime = p->se.sum_exec_runtime;
>> +
>> +	if (p->last_task_numa_placement) {
>> +		delta = runtime - p->last_sum_exec_runtime;
>> +		*period = now - p->last_task_numa_placement;
>> +	} else {
>> +		delta = p->se.avg.runnable_avg_sum;
>> +		*period = p->se.avg.runnable_avg_period;
>> +	}
>> +
>> +	p->last_sum_exec_runtime = runtime;
>> +	p->last_task_numa_placement = now;
>> +
>> +	return delta;
>> +}
> 
> Have you tried what happens if you use p->se.avg.runnable_avg_sum /
> p->se.avg.runnable_avg_period instead? If that also works it avoids
> growing the datastructures and keeping of yet another set of runtime
> stats.

That is what I started out with, and the results were not
as stable as with this calculation.

Having said that, I did that before I came up with patch 7/7,
so maybe the effect would no longer be as pronounced any more
as it was before...

I can send in a simplified version, if you prefer.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
