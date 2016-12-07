Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id EDF066B0038
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 03:49:08 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id hb5so81130848wjc.2
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 00:49:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xs6si23455578wjc.244.2016.12.07.00.49.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Dec 2016 00:49:07 -0800 (PST)
Subject: Re: [RFC PATCH v3] mm: use READ_ONCE in page_cpupid_xchg_last()
References: <584523E4.9030600@huawei.com> <58461A0A.3070504@huawei.com>
 <20161207084305.GA20350@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7b74a021-e472-a21e-7936-6741e07906b5@suse.cz>
Date: Wed, 7 Dec 2016 09:48:52 +0100
MIME-Version: 1.0
In-Reply-To: <20161207084305.GA20350@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Yisheng Xie <xieyisheng1@huawei.com>

On 12/07/2016 09:43 AM, Michal Hocko wrote:
> On Tue 06-12-16 09:53:14, Xishi Qiu wrote:
>> A compiler could re-read "old_flags" from the memory location after reading
>> and calculation "flags" and passes a newer value into the cmpxchg making 
>> the comparison succeed while it should actually fail.
>>
>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>> Suggested-by: Christian Borntraeger <borntraeger@de.ibm.com>
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
>> +		old_flags = flags = READ_ONCE(page->flags);
>>  		last_cpupid = page_cpupid_last(page);
> 
> what prevents compiler from doing?
> 		old_flags = READ_ONCE(page->flags);
> 		flags = READ_ONCE(page->flags);

AFAIK, READ_ONCE tells the compiler that page->flags is volatile. It
can't read from volatile location more times than being told?

> Or this doesn't matter?

I think it would matter.

>>  
>>  		flags &= ~(LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT);
>> -- 
>> 1.8.3.1
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
