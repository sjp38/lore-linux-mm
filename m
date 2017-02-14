Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 40E846B03B9
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:50:49 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id an2so57365072wjc.3
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 08:50:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y6si1381203wra.254.2017.02.14.08.50.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 14 Feb 2017 08:50:48 -0800 (PST)
Subject: Re: [PATCH] oom_reaper: switch to struct list_head for reap queue
References: <20170214150714.6195-1-asarai@suse.de>
 <20170214163005.GA2450@cmpxchg.org>
From: Aleksa Sarai <asarai@suse.de>
Message-ID: <e876e49b-8b65-d827-af7d-cbf8aef97585@suse.de>
Date: Wed, 15 Feb 2017 03:52:11 +1100
MIME-Version: 1.0
In-Reply-To: <20170214163005.GA2450@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cyphar@cyphar.com

>> Rather than implementing an open addressing linked list structure
>> ourselves, use the standard list_head structure to improve consistency
>> with the rest of the kernel and reduce confusion.
>>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Oleg Nesterov <oleg@redhat.com>
>> Signed-off-by: Aleksa Sarai <asarai@suse.de>
>> ---
>>  include/linux/sched.h |  6 +++++-
>>  kernel/fork.c         |  4 ++++
>>  mm/oom_kill.c         | 24 +++++++++++++-----------
>>  3 files changed, 22 insertions(+), 12 deletions(-)
>>
>> diff --git a/include/linux/sched.h b/include/linux/sched.h
>> index e93594b88130..d8bcd0f8c5fe 100644
>> --- a/include/linux/sched.h
>> +++ b/include/linux/sched.h
>> @@ -1960,7 +1960,11 @@ struct task_struct {
>>  #endif
>>  	int pagefault_disabled;
>>  #ifdef CONFIG_MMU
>> -	struct task_struct *oom_reaper_list;
>> +	/*
>> +	 * List of threads that have to be reaped by OOM (rooted at
>> +	 * &oom_reaper_list in mm/oom_kill.c).
>> +	 */
>> +	struct list_head oom_reaper_list;
>
> This is an extra pointer to task_struct and more lines of code to
> accomplish the same thing. Why would we want to do that?

I don't think it's more "actual" lines of code (I think the wrapping is 
inflating the line number count), but switching it means that it's more 
in line with other queues in the kernel (it took me a bit to figure out 
what was going on with oom_reaper_list beforehand).

-- 
Aleksa Sarai
Software Engineer (Containers)
SUSE Linux GmbH
https://www.cyphar.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
