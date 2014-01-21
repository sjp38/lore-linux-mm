Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 083906B00A7
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 17:27:07 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id i8so7858554qcq.32
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 14:27:06 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id r2si4143693qeq.140.2014.01.21.14.27.05
        for <linux-mm@kvack.org>;
        Tue, 21 Jan 2014 14:27:05 -0800 (PST)
Message-ID: <52DEF41F.1040105@redhat.com>
Date: Tue, 21 Jan 2014 17:26:39 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] numa,sched: track from which nodes NUMA faults are
 triggered
References: <1390245667-24193-1-git-send-email-riel@redhat.com> <1390245667-24193-3-git-send-email-riel@redhat.com> <20140121122130.GG4963@suse.de>
In-Reply-To: <20140121122130.GG4963@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@redhat.com, chegu_vinod@hp.com

On 01/21/2014 07:21 AM, Mel Gorman wrote:
> On Mon, Jan 20, 2014 at 02:21:03PM -0500, riel@redhat.com wrote:

>> +++ b/include/linux/sched.h
>> @@ -1492,6 +1492,14 @@ struct task_struct {
>>  	unsigned long *numa_faults_buffer;
>>  
>>  	/*
>> +	 * Track the nodes where faults are incurred. This is not very
>> +	 * interesting on a per-task basis, but it help with smarter
>> +	 * numa memory placement for groups of processes.
>> +	 */
>> +	unsigned long *numa_faults_from;
>> +	unsigned long *numa_faults_from_buffer;
>> +
> 
> As an aside I wonder if we can derive any useful metric from this

It may provide for a better way to tune the numa scan interval
than the current code, since the "local vs remote" ratio is not
going to provide us much useful info when dealing with a workload
that is spread across multiple numa nodes.

>>  		grp->total_faults = p->total_numa_faults;
>> @@ -1526,7 +1536,7 @@ static void task_numa_group(struct task_struct *p, int cpupid, int flags,
>>  
>>  	double_lock(&my_grp->lock, &grp->lock);
>>  
>> -	for (i = 0; i < 2*nr_node_ids; i++) {
>> +	for (i = 0; i < 4*nr_node_ids; i++) {
>>  		my_grp->faults[i] -= p->numa_faults[i];
>>  		grp->faults[i] += p->numa_faults[i];
>>  	}
> 
> The same obscure trick is used throughout and I'm not sure how
> maintainable that will be. Would it be better to be explicit about this?

I have made a cleanup patch for this, using the defines you
suggested.

>> @@ -1634,6 +1649,7 @@ void task_numa_fault(int last_cpupid, int node, int pages, int flags)
>>  		p->numa_pages_migrated += pages;
>>  
>>  	p->numa_faults_buffer[task_faults_idx(node, priv)] += pages;
>> +	p->numa_faults_from_buffer[task_faults_idx(this_node, priv)] += pages;
>>  	p->numa_faults_locality[!!(flags & TNF_FAULT_LOCAL)] += pages;
> 
> this_node and node is similarly ambiguous in terms of name. Rename of
> data_node and cpu_node would have been clearer.

I added a patch in the next version of the series.

Don't want to make the series too large, though :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
