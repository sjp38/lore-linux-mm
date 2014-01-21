Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6B82D6B0071
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 16:05:49 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id n7so7783977qcx.30
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 13:05:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id c3si4030330qee.57.2014.01.21.13.05.47
        for <linux-mm@kvack.org>;
        Tue, 21 Jan 2014 13:05:48 -0800 (PST)
Message-ID: <52DEE10C.6030907@redhat.com>
Date: Tue, 21 Jan 2014 16:05:16 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/6] numa,sched: normalize faults_from stats and weigh
 by CPU use
References: <1390245667-24193-1-git-send-email-riel@redhat.com> <1390245667-24193-6-git-send-email-riel@redhat.com> <20140121155652.GL4963@suse.de>
In-Reply-To: <20140121155652.GL4963@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@redhat.com, chegu_vinod@hp.com

On 01/21/2014 10:56 AM, Mel Gorman wrote:
> On Mon, Jan 20, 2014 at 02:21:06PM -0500, riel@redhat.com wrote:

>> @@ -1434,6 +1436,11 @@ static void task_numa_placement(struct task_struct *p)
>>  	p->numa_scan_seq = seq;
>>  	p->numa_scan_period_max = task_scan_max(p);
>>  
>> +	total_faults = p->numa_faults_locality[0] +
>> +		       p->numa_faults_locality[1] + 1;
> 
> Depending on how you reacted to the review of other patches this may or
> may not have a helper now.

This is a faults "buffer", zeroed quickly after we take these
faults, so we should probably not tempt others by having a helper
function to get these numbers...

>> +	runtime = p->se.avg.runnable_avg_sum;
>> +	period = p->se.avg.runnable_avg_period;
>> +
> 
> Ok, IIRC these stats are based a decaying average based on recent
> history so heavy activity followed by long periods of idle will not skew
> the stats.

Turns out that using a longer time statistic results in a 1% performance
gain, so expect this code to change again in the next version :)

>> @@ -1458,8 +1465,18 @@ static void task_numa_placement(struct task_struct *p)
>>  			fault_types[priv] += p->numa_faults_buffer[i];
>>  			p->numa_faults_buffer[i] = 0;
>>  
>> +			/*
>> +			 * Normalize the faults_from, so all tasks in a group
>> +			 * count according to CPU use, instead of by the raw
>> +			 * number of faults. Tasks with little runtime have
>> +			 * little over-all impact on throughput, and thus their
>> +			 * faults are less important.
>> +			 */
>> +			f_weight = (16384 * runtime *
>> +				   p->numa_faults_from_buffer[i]) /
>> +				   (total_faults * period + 1);
> 
> Why 16384? It looks like a scaling factor to deal with integer approximations
> but I'm not 100% sure and I do not see how you arrived at that value.

Indeed, it is simply a fixed point math scaling factor.

I used 1024 before, but that is kind of a small number when we could
be dealing with a node that has 20% of the accesses, and a task that
used 10% CPU time.

Having the numbers a little larger could help, and certainly should
not hurt, as long as we keep the number small enough to avoid overflows.

>>  			p->numa_faults_from[i] >>= 1;
>> -			p->numa_faults_from[i] += p->numa_faults_from_buffer[i];
>> +			p->numa_faults_from[i] += f_weight;
>>  			p->numa_faults_from_buffer[i] = 0;
>>  
> 
> numa_faults_from needs a big comment that it's no longer about the
> number of faults in it. It's the sum of faults measured by the group
> weighted by the CPU

Agreed.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
