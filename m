Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 873686B025E
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 04:24:44 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id xr1so61046522wjb.7
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 01:24:44 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id n6si14201475wjk.207.2016.12.05.01.24.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Dec 2016 01:24:43 -0800 (PST)
Message-ID: <584531CF.9030204@huawei.com>
Date: Mon, 5 Dec 2016 17:22:23 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] mm: use ACCESS_ONCE in page_cpupid_xchg_last()
References: <584523E4.9030600@huawei.com> <26c66f28-d836-4d6e-fb40-3e2189a540ed@de.ibm.com> <0cc3c2bb-e292-2d7b-8d44-16c8e6c19899@de.ibm.com>
In-Reply-To: <0cc3c2bb-e292-2d7b-8d44-16c8e6c19899@de.ibm.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Yisheng
 Xie <xieyisheng1@huawei.com>

On 2016/12/5 16:50, Christian Borntraeger wrote:

> On 12/05/2016 09:31 AM, Christian Borntraeger wrote:
>> On 12/05/2016 09:23 AM, Xishi Qiu wrote:
>>> By reading the code, I find the following code maybe optimized by
>>> compiler, maybe page->flags and old_flags use the same register,
>>> so use ACCESS_ONCE in page_cpupid_xchg_last() to fix the problem.
>>
>> please use READ_ONCE instead of ACCESS_ONCE for future patches.
>>
>>>
>>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>>> ---
>>>  mm/mmzone.c | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/mm/mmzone.c b/mm/mmzone.c
>>> index 5652be8..e0b698e 100644
>>> --- a/mm/mmzone.c
>>> +++ b/mm/mmzone.c
>>> @@ -102,7 +102,7 @@ int page_cpupid_xchg_last(struct page *page, int cpupid)
>>>  	int last_cpupid;
>>>
>>>  	do {
>>> -		old_flags = flags = page->flags;
>>> +		old_flags = flags = ACCESS_ONCE(page->flags);
>>>  		last_cpupid = page_cpupid_last(page);
>>>
>>>  		flags &= ~(LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT);
>>
>>
>> I dont thing that this is actually a problem. The code below does  
>>
>>    } while (unlikely(cmpxchg(&page->flags, old_flags, flags) != old_flags))
>>
>> and the cmpxchg should be an atomic op that should already take care of everything
>> (page->flags is passed as a pointer).
>>
> 
> Reading the code again, you might be right, but I think your patch description
> is somewhat misleading. I think the problem is that old_flags and flags are
> not necessarily the same.
> 
> So what about
> 
> a compiler could re-read "old_flags" from the memory location after reading
> and calculation "flags" and passes a newer value into the cmpxchg making 
> the comparison succeed while it should actually fail.
> 

Hi Christian,

I'll resend v2, thanks!

> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
