Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 57C006B0261
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 03:50:12 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id a20so15577982wme.5
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 00:50:12 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l66si11921397wma.114.2016.12.05.00.50.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Dec 2016 00:50:11 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB58mmif096778
	for <linux-mm@kvack.org>; Mon, 5 Dec 2016 03:50:10 -0500
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0b-001b2d01.pphosted.com with ESMTP id 27548h1xpy-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 05 Dec 2016 03:50:09 -0500
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Mon, 5 Dec 2016 01:50:09 -0700
Subject: Re: [RFC PATCH] mm: use ACCESS_ONCE in page_cpupid_xchg_last()
References: <584523E4.9030600@huawei.com>
 <26c66f28-d836-4d6e-fb40-3e2189a540ed@de.ibm.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Mon, 5 Dec 2016 09:50:02 +0100
MIME-Version: 1.0
In-Reply-To: <26c66f28-d836-4d6e-fb40-3e2189a540ed@de.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <0cc3c2bb-e292-2d7b-8d44-16c8e6c19899@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>

On 12/05/2016 09:31 AM, Christian Borntraeger wrote:
> On 12/05/2016 09:23 AM, Xishi Qiu wrote:
>> By reading the code, I find the following code maybe optimized by
>> compiler, maybe page->flags and old_flags use the same register,
>> so use ACCESS_ONCE in page_cpupid_xchg_last() to fix the problem.
> 
> please use READ_ONCE instead of ACCESS_ONCE for future patches.
> 
>>
>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>> ---
>>  mm/mmzone.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/mmzone.c b/mm/mmzone.c
>> index 5652be8..e0b698e 100644
>> --- a/mm/mmzone.c
>> +++ b/mm/mmzone.c
>> @@ -102,7 +102,7 @@ int page_cpupid_xchg_last(struct page *page, int cpupid)
>>  	int last_cpupid;
>>
>>  	do {
>> -		old_flags = flags = page->flags;
>> +		old_flags = flags = ACCESS_ONCE(page->flags);
>>  		last_cpupid = page_cpupid_last(page);
>>
>>  		flags &= ~(LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT);
> 
> 
> I dont thing that this is actually a problem. The code below does  
> 
>    } while (unlikely(cmpxchg(&page->flags, old_flags, flags) != old_flags))
> 
> and the cmpxchg should be an atomic op that should already take care of everything
> (page->flags is passed as a pointer).
> 

Reading the code again, you might be right, but I think your patch description
is somewhat misleading. I think the problem is that old_flags and flags are
not necessarily the same.

So what about

a compiler could re-read "old_flags" from the memory location after reading
and calculation "flags" and passes a newer value into the cmpxchg making 
the comparison succeed while it should actually fail.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
