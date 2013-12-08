Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 878946B0035
	for <linux-mm@kvack.org>; Sat,  7 Dec 2013 19:05:55 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id uo5so3191758pbc.29
        for <linux-mm@kvack.org>; Sat, 07 Dec 2013 16:05:55 -0800 (PST)
Received: from e28smtp05.in.ibm.com (e28smtp05.in.ibm.com. [122.248.162.5])
        by mx.google.com with ESMTPS id it5si2740215pbc.35.2013.12.07.16.05.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 07 Dec 2013 16:05:54 -0800 (PST)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 8 Dec 2013 05:35:50 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 24E7CE0024
	for <linux-mm@kvack.org>; Sun,  8 Dec 2013 05:38:03 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB805gBX49938682
	for <linux-mm@kvack.org>; Sun, 8 Dec 2013 05:35:43 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB805k6G026519
	for <linux-mm@kvack.org>; Sun, 8 Dec 2013 05:35:46 +0530
Date: Sun, 8 Dec 2013 08:05:44 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 4/6] sched/numa: use wrapper function task_node to get
 node which task is on
Message-ID: <52a3b7e2.65c5440a.2f3e.5e21SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386321136-27538-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386321136-27538-4-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386364176-it8qfec-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386364176-it8qfec-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 06, 2013 at 04:09:36PM -0500, Naoya Horiguchi wrote:
>On Fri, Dec 06, 2013 at 05:12:14PM +0800, Wanpeng Li wrote:
>> Use wrapper function task_node to get node which task is on.
>> 
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>
>Maybe we have another line to apply the same fix:
>
>./kernel/sched/debug.c:142:     SEQ_printf(m, " %d", cpu_to_node(task_cpu(p)));
>

Ok, I will fold it to next version. Thanks for your review. ;-)

Regards,
Wanpeng Li 

>But anyway,
>
>Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>
>Thanks,
>Naoya Horiguchi
>
>> ---
>>  kernel/sched/fair.c |    4 ++--
>>  1 files changed, 2 insertions(+), 2 deletions(-)
>> 
>> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
>> index 56bcc0c..e0b1063 100644
>> --- a/kernel/sched/fair.c
>> +++ b/kernel/sched/fair.c
>> @@ -1216,7 +1216,7 @@ static int task_numa_migrate(struct task_struct *p)
>>  	 * elsewhere, so there is no point in (re)trying.
>>  	 */
>>  	if (unlikely(!sd)) {
>> -		p->numa_preferred_nid = cpu_to_node(task_cpu(p));
>> +		p->numa_preferred_nid = task_node(p);
>>  		return -EINVAL;
>>  	}
>>  
>> @@ -1283,7 +1283,7 @@ static void numa_migrate_preferred(struct task_struct *p)
>>  	p->numa_migrate_retry = jiffies + HZ;
>>  
>>  	/* Success if task is already running on preferred CPU */
>> -	if (cpu_to_node(task_cpu(p)) == p->numa_preferred_nid)
>> +	if (task_node(p) == p->numa_preferred_nid)
>>  		return;
>>  
>>  	/* Otherwise, try migrate to a CPU on the preferred node */
>> -- 
>> 1.7.7.6
>> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
