Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 83BE46B0088
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 03:49:57 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id wn1so4967437obc.19
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 00:49:57 -0800 (PST)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [122.248.162.2])
        by mx.google.com with ESMTPS id co8si9769538oec.112.2013.12.10.00.49.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 00:49:56 -0800 (PST)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 10 Dec 2013 14:19:41 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id E6000394005A
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 14:19:38 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBA8nZUb6291814
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 14:19:36 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBA8nbdr028817
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 14:19:38 +0530
Date: Tue, 10 Dec 2013 16:49:35 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 09/12] sched/numa: fix task scan rate adjustment
Message-ID: <52a6d5b4.48b13c0a.0edd.6b08SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386483293-15354-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386483293-15354-9-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386657875-icl2pjx6-mutt-n-horiguchi@ah.jp.nec.com>
 <20131210082758.GC11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131210082758.GC11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Dec 10, 2013 at 08:27:59AM +0000, Mel Gorman wrote:
>On Tue, Dec 10, 2013 at 01:44:35AM -0500, Naoya Horiguchi wrote:
>> Hi Wanpeng,
>> 
>> On Sun, Dec 08, 2013 at 02:14:50PM +0800, Wanpeng Li wrote:
>> > commit 04bb2f947 (sched/numa: Adjust scan rate in task_numa_placement) calculate
>> > period_slot which should be used as base value of scan rate increase if remote
>> > access dominate. However, current codes forget to use it, this patch fix it.
>> > 
>> > Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> > ---
>> >  kernel/sched/fair.c |    2 +-
>> >  1 files changed, 1 insertions(+), 1 deletions(-)
>> > 
>> > diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
>> > index 7073c76..b077f1b3 100644
>> > --- a/kernel/sched/fair.c
>> > +++ b/kernel/sched/fair.c
>> > @@ -1358,7 +1358,7 @@ static void update_task_scan_period(struct task_struct *p,
>> >  		 */
>> >  		period_slot = DIV_ROUND_UP(diff, NUMA_PERIOD_SLOTS);
>> >  		ratio = DIV_ROUND_UP(private * NUMA_PERIOD_SLOTS, (private + shared));
>> > -		diff = (diff * ratio) / NUMA_PERIOD_SLOTS;
>> > +		diff = (period_slot * ratio) / NUMA_PERIOD_SLOTS;
>> >  	}
>> >  
>> >  	p->numa_scan_period = clamp(p->numa_scan_period + diff,
>> 
>> It seems to me that the original code is correct, because the mathematical
>> meaning of this hunk is clear:
>> 
>>   diff = (diff calculated by local-remote ratio) * (private-shared ratio)
>> 
>
>Thanks Naoya.
>
>The original code is as intended and was meant to scale the difference
>between the NUMA_PERIOD_THRESHOLD and local/remote ratio when adjusting
>the scan period. The period_slot recalculation can be dropped.
>

Thanks Mel's pointing out. ;-)

Regards,
Wanpeng Li 

>-- 
>Mel Gorman
>SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
