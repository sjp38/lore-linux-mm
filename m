Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 159E96B0311
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 10:44:08 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id v74so25493214oie.10
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 07:44:08 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id o203si2826389oib.94.2017.06.16.07.44.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 07:44:07 -0700 (PDT)
Subject: Re: [PATCH] mm/list_lru.c: use cond_resched_lock() for nlru->lock
References: <1497228440-10349-1-git-send-email-stummala@codeaurora.org>
 <20170615140523.76f8fc3ca21dae3704f06a56@linux-foundation.org>
From: Sahitya Tummala <stummala@codeaurora.org>
Message-ID: <3c478a65-6cd1-0ee9-2470-7ca368dd88bf@codeaurora.org>
Date: Fri, 16 Jun 2017 20:14:00 +0530
MIME-Version: 1.0
In-Reply-To: <20170615140523.76f8fc3ca21dae3704f06a56@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Polakov <apolyakov@beget.ru>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On 6/16/2017 2:35 AM, Andrew Morton wrote:

> diff --git a/mm/list_lru.c b/mm/list_lru.c
>> index 5d8dffd..1af0709 100644
>> --- a/mm/list_lru.c
>> +++ b/mm/list_lru.c
>> @@ -249,6 +249,8 @@ restart:
>>   		default:
>>   			BUG();
>>   		}
>> +		if (cond_resched_lock(&nlru->lock))
>> +			goto restart;
>>   	}
>>   
>>   	spin_unlock(&nlru->lock);
> This is rather worrying.
>
> a) Why are we spending so long holding that lock that this is occurring?

At the time of crash I see that __list_lru_walk_one() shows number of
entries isolated as 1774475 with nr_items still pending as 130748. On my
system, I see that for dentries of 100000, it takes around 75ms for
__list_lru_walk_one() to complete. So for a total of 1900000 dentries as
in issue scenario, it will take upto 1425ms, which explains why the spin
lockup condition got hit on the other CPU.

It looks like __list_lru_walk_one() is expected to take more time if
there are more number of dentries present. And I think it is a valid
scenario to have those many number dentries.

> b) With this patch, we're restarting the entire scan.  Are there
>     situations in which this loop will never terminate, or will take a
>     very long time?  Suppose that this process is getting rescheds
>     blasted at it for some reason?

In the above scenario, I observed that the dentry entries from lru list
are removedall the time i.e LRU_REMOVED is returned from the
isolate (dentry_lru_isolate()) callback. I don't know if there is any case
where we skip several entries in the lru list and restartseveral times due
to this cond_resched_lock(). This can happen even with theexisting code
if LRU_RETRY is returned often from the isolate callback.
> IOW this looks like a bit of a band-aid and a deeper analysis and
> understanding might be needed.

-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
