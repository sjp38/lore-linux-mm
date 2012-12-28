Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id E4E7E8D0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 21:49:50 -0500 (EST)
Message-ID: <50DD0874.1060901@redhat.com>
Date: Fri, 28 Dec 2012 10:48:20 +0800
From: Zhouping Liu <zliu@redhat.com>
MIME-Version: 1.0
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 0000000000000500
References: <1828895463.36547216.1356662710202.JavaMail.root@redhat.com>
In-Reply-To: <1828895463.36547216.1356662710202.JavaMail.root@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zlatko Calusic <zlatko.calusic@iskon.hr>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Johannes Weiner <jweiner@redhat.com>, mgorman@suse.de, hughd@google.com, Andrea Arcangeli <aarcange@redhat.com>, Hillf Danton <dhillf@gmail.com>, sedat.dilek@gmail.com

On 12/28/2012 10:45 AM, Zhouping Liu wrote:
>> Thank you for the report Zhouping!
>>
>> Would you be so kind to test the following patch and report results?
>> Apply the patch to the latest mainline.
> Hello Zlatko,
>
> I have tested the below patch(applied it on mainline directly),
> but IMO, I'd like to say it maybe don't fix the issue completely.
>
> run the reproducer[1] on two machine, one machine has 2 numa nodes(8Gb RAM),
> another one has 4 numa nodes(8Gb RAM), then the system hung all the time, such as the dmesg log:
>
> [  713.066937] Killed process 6085 (oom01) total-vm:18880768kB, anon-rss:7915612kB, file-rss:4kB
> [  959.555269] INFO: task kworker/13:2:147 blocked for more than 120 seconds.
> [  959.562144] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 1079.382018] INFO: task kworker/13:2:147 blocked for more than 120 seconds.
> [ 1079.388872] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 1199.209709] INFO: task kworker/13:2:147 blocked for more than 120 seconds.
> [ 1199.216562] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 1319.036939] INFO: task kworker/13:2:147 blocked for more than 120 seconds.
> [ 1319.043794] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 1438.864797] INFO: task kworker/13:2:147 blocked for more than 120 seconds.
> [ 1438.871649] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> [ 1558.691611] INFO: task kworker/13:2:147 blocked for more than 120 seconds.
> [ 1558.698466] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> ......
>
> I'm not sure whether it's your patch triggering the hung task or not, but reverted cda73a10eb3,
> the reproducer(oom01) can PASS without both 'NULL pointer dereference at 0000000000000500' and hung task issues.
>
> but some time, it's possible that the reproducer(oom01) cause hung task on a box with large RAM(100Gb+), so I can't judge it...

sorry, I forgot to link the reproducer.
oom01 in LTP test suite: 
https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/mem/oom/oom01.c

from my site, it can 100% reproduce the bug using oom01 test case.

Thanks,
Zhouping
>
> Thanks,
> Zhouping
>
>> Thanks,
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 23291b9..e55ce55 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -2564,6 +2564,7 @@ static bool prepare_kswapd_sleep(pg_data_t
>> *pgdat, int order, long remaining,
>>   static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>>   							int *classzone_idx)
>>   {
>> +	bool pgdat_is_balanced = false;
>>   	struct zone *unbalanced_zone;
>>   	int i;
>>   	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
>> @@ -2638,8 +2639,11 @@ loop_again:
>>   				zone_clear_flag(zone, ZONE_CONGESTED);
>>   			}
>>   		}
>> -		if (i < 0)
>> +
>> +		if (i < 0) {
>> +			pgdat_is_balanced = true;
>>   			goto out;
>> +		}
>>   
>>   		for (i = 0; i <= end_zone; i++) {
>>   			struct zone *zone = pgdat->node_zones + i;
>> @@ -2766,8 +2770,11 @@ loop_again:
>>   				pfmemalloc_watermark_ok(pgdat))
>>   			wake_up(&pgdat->pfmemalloc_wait);
>>   
>> -		if (pgdat_balanced(pgdat, order, *classzone_idx))
>> +		if (pgdat_balanced(pgdat, order, *classzone_idx)) {
>> +			pgdat_is_balanced = true;
>>   			break;		/* kswapd: all done */
>> +		}
>> +
>>   		/*
>>   		 * OK, kswapd is getting into trouble.  Take a nap, then take
>>   		 * another pass across the zones.
>> @@ -2775,7 +2782,7 @@ loop_again:
>>   		if (total_scanned && (sc.priority < DEF_PRIORITY - 2)) {
>>   			if (has_under_min_watermark_zone)
>>   				count_vm_event(KSWAPD_SKIP_CONGESTION_WAIT);
>> -			else
>> +			else if (unbalanced_zone)
>>   				wait_iff_congested(unbalanced_zone, BLK_RW_ASYNC, HZ/10);
>>   		}
>>   
>> @@ -2788,9 +2795,9 @@ loop_again:
>>   		if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
>>   			break;
>>   	} while (--sc.priority >= 0);
>> -out:
>>   
>> -	if (!pgdat_balanced(pgdat, order, *classzone_idx)) {
>> +out:
>> +	if (!pgdat_is_balanced) {
>>   		cond_resched();
>>   
>>   		try_to_freeze();
>>
>> --
>> Zlatko
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
