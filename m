Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B3E236B0279
	for <linux-mm@kvack.org>; Thu, 25 May 2017 08:15:56 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p74so226545445pfd.11
        for <linux-mm@kvack.org>; Thu, 25 May 2017 05:15:56 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id r67si28188061pfe.5.2017.05.25.05.15.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 May 2017 05:15:55 -0700 (PDT)
Message-ID: <5926CA8B.8080102@huawei.com>
Date: Thu, 25 May 2017 20:14:03 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] mm: fix mlock incorrent event account
References: <1495699179-7566-1-git-send-email-zhongjiang@huawei.com> <20170525081330.GG12721@dhcp22.suse.cz>
In-Reply-To: <20170525081330.GG12721@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, qiuxishi@huawei.com, linux-mm@kvack.org

On 2017/5/25 16:13, Michal Hocko wrote:
> On Thu 25-05-17 15:59:39, zhongjiang wrote:
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> when clear_page_mlock call, we had finish the page isolate successfully,
>> but it fails to increase the UNEVICTABLE_PGMUNLOCKED account.
>>
>> The patch add the event account when successful page isolation.
> Could you describe _what_ is the problem, how it can be _triggered_
> and _how_ serious it is. Is it something that can be triggered from
> userspace? The mlock code is really tricky and it is far from trivial
> to see whether this is obviously right or a wrong assumption on your
> side. Before people go and spend time reviewing it is fair to introduce
> them to the problem.
>
> I believe this is not the first time I am giving you this feedback
> so I would _really_ appreciated if you tried harder with the changelog.
> It is much simpler to write a patch than review it in many cases.
 HI, MIchal
 
  I am sorry for that. I will keep in mind. 

  As for the above issue. I get the conclusin after reviewing the code.
  I will further prove wheher the issue is exist or not.

  Thanks
  zhongjiang
>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>> ---
>>  mm/mlock.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/mm/mlock.c b/mm/mlock.c
>> index c483c5c..941930b 100644
>> --- a/mm/mlock.c
>> +++ b/mm/mlock.c
>> @@ -64,6 +64,7 @@ void clear_page_mlock(struct page *page)
>>  			    -hpage_nr_pages(page));
>>  	count_vm_event(UNEVICTABLE_PGCLEARED);
>>  	if (!isolate_lru_page(page)) {
>> +		count_vm_event(UNEVICTABLE_PGMUNLOCKED);
>>  		putback_lru_page(page);
>>  	} else {
>>  		/*
>> -- 
>> 1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
