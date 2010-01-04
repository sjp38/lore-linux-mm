Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 90613600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 04:35:23 -0500 (EST)
Received: by yxe36 with SMTP id 36so16322878yxe.11
        for <linux-mm@kvack.org>; Mon, 04 Jan 2010 01:35:21 -0800 (PST)
Message-ID: <4B41B653.2060204@gmail.com>
Date: Mon, 04 Jan 2010 17:35:15 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] page allocator: fix update NR_FREE_PAGES only as necessary
References: <20100104144332.96A2.A69D9226@jp.fujitsu.com> <4B4186A7.5080402@gmail.com> <20100104151444.96A8.A69D9226@jp.fujitsu.com>
In-Reply-To: <20100104151444.96A8.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, mel@csn.ul.ie, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>
>> struct per_cpu_pageset {
>>    .................................................
>> #ifdef CONFIG_SMP
>>       s8 stat_threshold;
>>       s8 vm_stat_diff[NR_VM_ZONE_STAT_ITEMS];
>> #endif
>> } ____cacheline_aligned_in_smp;
>>
>> The field 'stat_threshold' is in the CONFIG_SMP macro, does it not need
>> the spinlock? I will read the code more carefully.
>> I saw the macro, so I thought it need the spinlock. :)
>>      
> Generally,  per-cpu data isn't accessed from another cpu. it only need to care
> process-context vs irq-context race.
>
>
>    
If the  __mod_zone_page_state() can be used without caring about the 
spinlock, I think there
are several places we can move __mod_zone_page_state() out the guard 
area of spinlock to
release the pressure of the zone->lock,such as in rmqueue_bulk().





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
