Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A462A6B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 04:40:55 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c4so593237311pfb.7
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 01:40:55 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z3si23365727pfd.61.2016.12.07.01.40.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 01:40:54 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB79cgIU006468
	for <linux-mm@kvack.org>; Wed, 7 Dec 2016 04:40:54 -0500
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0a-001b2d01.pphosted.com with ESMTP id 276arh9f5d-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 07 Dec 2016 04:40:54 -0500
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Wed, 7 Dec 2016 02:40:53 -0700
Subject: Re: [RFC PATCH v3] mm: use READ_ONCE in page_cpupid_xchg_last()
References: <584523E4.9030600@huawei.com> <58461A0A.3070504@huawei.com>
 <20161207084305.GA20350@dhcp22.suse.cz>
 <7b74a021-e472-a21e-7936-6741e07906b5@suse.cz>
 <20161207085809.GD17136@dhcp22.suse.cz>
 <b3c3cff5-5d47-7a32-9def-9f42640c9211@suse.cz>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Wed, 7 Dec 2016 10:40:47 +0100
MIME-Version: 1.0
In-Reply-To: <b3c3cff5-5d47-7a32-9def-9f42640c9211@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <ceb6c990-6d88-dc79-b494-432ed838f3c9@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>

On 12/07/2016 10:29 AM, Vlastimil Babka wrote:
> On 12/07/2016 09:58 AM, Michal Hocko wrote:
>> On Wed 07-12-16 09:48:52, Vlastimil Babka wrote:
>>> On 12/07/2016 09:43 AM, Michal Hocko wrote:
>>>> On Tue 06-12-16 09:53:14, Xishi Qiu wrote:
>>>>> A compiler could re-read "old_flags" from the memory location after reading
>>>>> and calculation "flags" and passes a newer value into the cmpxchg making 
>>>>> the comparison succeed while it should actually fail.
>>>>>
>>>>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>>>>> Suggested-by: Christian Borntraeger <borntraeger@de.ibm.com>
>>>>> ---
>>>>>  mm/mmzone.c | 2 +-
>>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>>
>>>>> diff --git a/mm/mmzone.c b/mm/mmzone.c
>>>>> index 5652be8..e0b698e 100644
>>>>> --- a/mm/mmzone.c
>>>>> +++ b/mm/mmzone.c
>>>>> @@ -102,7 +102,7 @@ int page_cpupid_xchg_last(struct page *page, int cpupid)
>>>>>  	int last_cpupid;
>>>>>  
>>>>>  	do {
>>>>> -		old_flags = flags = page->flags;
>>>>> +		old_flags = flags = READ_ONCE(page->flags);
>>>>>  		last_cpupid = page_cpupid_last(page);
>>>>
>>>> what prevents compiler from doing?
>>>> 		old_flags = READ_ONCE(page->flags);
>>>> 		flags = READ_ONCE(page->flags);
>>>
>>> AFAIK, READ_ONCE tells the compiler that page->flags is volatile. It
>>> can't read from volatile location more times than being told?
>>
>> But those are two different variables which we assign to so what
>> prevents the compiler from applying READ_ONCE on each of them
>> separately?
> 
> I would naively expect that it's assigned to flags first, and then from
> flags to old_flags. But I don't know exactly the C standard evaluation
> rules that apply here.
> 
>> Anyway, this could be addressed easily by
> 
> Yes, that way there should be no doubt.

That change would make it clearer, but the code is correct anyway,
as assignments in C are done from right to left, so 
old_flags = flags = READ_ONCE(page->flags);

is equivalent to 

flags = READ_ONCE(page->flags);
old_flags = flags;


> 
>> diff --git a/mm/mmzone.c b/mm/mmzone.c
>> index 5652be858e5e..b4e093dd24c1 100644
>> --- a/mm/mmzone.c
>> +++ b/mm/mmzone.c
>> @@ -102,10 +102,10 @@ int page_cpupid_xchg_last(struct page *page, int cpupid)
>>  	int last_cpupid;
>>  
>>  	do {
>> -		old_flags = flags = page->flags;
>> +		old_flags = READ_ONCE(page->flags);
>>  		last_cpupid = page_cpupid_last(page);
>>  
>> -		flags &= ~(LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT);
>> +		flags = old_flags & ~(LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT);
>>  		flags |= (cpupid & LAST_CPUPID_MASK) << LAST_CPUPID_PGSHIFT;
>>  	} while (unlikely(cmpxchg(&page->flags, old_flags, flags) != old_flags));
>>  
>>
>>>> Or this doesn't matter?
>>>
>>> I think it would matter.
>>>
>>>>>  
>>>>>  		flags &= ~(LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT);
>>>>> -- 
>>>>> 1.8.3.1
>>>>>
>>>>
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
