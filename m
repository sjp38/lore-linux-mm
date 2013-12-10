Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5A3EB6B0037
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 01:52:19 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id uo5so7030867pbc.15
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 22:52:19 -0800 (PST)
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com. [202.81.31.140])
        by mx.google.com with ESMTPS id v7si9549762pbi.158.2013.12.09.22.52.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 22:52:18 -0800 (PST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 10 Dec 2013 16:51:58 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id D87B62CE802D
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 17:51:55 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBA6XbIi62456032
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 17:33:44 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBA6plW8012115
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 17:51:48 +1100
Date: Tue, 10 Dec 2013 14:51:45 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 09/12] sched/numa: fix task scan rate adjustment
Message-ID: <52a6ba22.0722440a.0a6c.ffffd911SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386483293-15354-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386483293-15354-9-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386657875-icl2pjx6-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386657875-icl2pjx6-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Naoya,
On Tue, Dec 10, 2013 at 01:44:35AM -0500, Naoya Horiguchi wrote:
>Hi Wanpeng,
>
>On Sun, Dec 08, 2013 at 02:14:50PM +0800, Wanpeng Li wrote:
>> commit 04bb2f947 (sched/numa: Adjust scan rate in task_numa_placement) calculate
>> period_slot which should be used as base value of scan rate increase if remote
>> access dominate. However, current codes forget to use it, this patch fix it.
>> 
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  kernel/sched/fair.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>> 
>> diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
>> index 7073c76..b077f1b3 100644
>> --- a/kernel/sched/fair.c
>> +++ b/kernel/sched/fair.c
>> @@ -1358,7 +1358,7 @@ static void update_task_scan_period(struct task_struct *p,
>>  		 */
>>  		period_slot = DIV_ROUND_UP(diff, NUMA_PERIOD_SLOTS);
>>  		ratio = DIV_ROUND_UP(private * NUMA_PERIOD_SLOTS, (private + shared));
>> -		diff = (diff * ratio) / NUMA_PERIOD_SLOTS;
>> +		diff = (period_slot * ratio) / NUMA_PERIOD_SLOTS;
>>  	}
>>  
>>  	p->numa_scan_period = clamp(p->numa_scan_period + diff,
>
>It seems to me that the original code is correct, because the mathematical
>meaning of this hunk is clear:
>
>  diff = (diff calculated by local-remote ratio) * (private-shared ratio)
>
>If you use period_slot here, diff always becomes less then 1/10 finally by
>the second ratio multiplication (because we divide by NUMA_PERIOD_SLOTS twice),
>and I don't see the justification.
>
>And if my idea is correct, we don't have to recalculate period_slot when
>we multiply private-shared ratio. So we can remove that line.

Thanks for your review. I agree with you when I first review this codes.
It introduced by commit 04bb2f94 (sched/numa: Adjust scan rate in 
task_numa_placement), what's your original target, Rik ?

>
>Thanks,
>Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
