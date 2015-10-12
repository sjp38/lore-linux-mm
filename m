Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4ABB16B0253
	for <linux-mm@kvack.org>; Sun, 11 Oct 2015 21:41:58 -0400 (EDT)
Received: by qgeb31 with SMTP id b31so9310884qge.0
        for <linux-mm@kvack.org>; Sun, 11 Oct 2015 18:41:58 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id 198si12885212qhh.8.2015.10.11.18.41.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 11 Oct 2015 18:41:57 -0700 (PDT)
Message-ID: <561B0ECD.5000507@huawei.com>
Date: Mon, 12 Oct 2015 09:37:17 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: skip if required_kernelcore is larger than totalpages
References: <5615D311.5030908@huawei.com> <5617e00e.0c5b8c0a.2d0dd.3faa@mx.google.com>
In-Reply-To: <5617e00e.0c5b8c0a.2d0dd.3faa@mx.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, David
 Rientjes <rientjes@google.com>, Tang Chen <tangchen@cn.fujitsu.com>, zhongjiang@huawei.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/10/9 23:41, Yasuaki Ishimatsu wrote:

> 
> On Thu, 8 Oct 2015 10:21:05 +0800
> Xishi Qiu <qiuxishi@huawei.com> wrote:
> 
>> If kernelcore was not specified, or the kernelcore size is zero
>> (required_movablecore >= totalpages), or the kernelcore size is larger
> 
> Why does required_movablecore become larger than totalpages, when the
> kernelcore size is zero? I read the code but I could not find that you
> mention.
> 

If user only set boot option movablecore, and the value is larger than
totalpages, the calculation of kernelcore is zero, but we can't fill
the zone only with kernelcore, so skip it.

I have send a patch before this patch.
"fix overflow in find_zone_movable_pfns_for_nodes()"
		...
 		required_movablecore =
 			roundup(required_movablecore, MAX_ORDER_NR_PAGES);
+		required_movablecore = min(totalpages, required_movablecore);
 		corepages = totalpages - required_movablecore;
		...

Thanks,
Xishi Qiu

> Thanks,
> Yasuaki Ishimatsu
> 
>> than totalpages, there is no ZONE_MOVABLE. We should fill the zone
>> with both kernel memory and movable memory.
>>
>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>> ---
>>  mm/page_alloc.c | 7 +++++--
>>  1 file changed, 5 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index af3c9bd..6a6da0d 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5674,8 +5674,11 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>>  		required_kernelcore = max(required_kernelcore, corepages);
>>  	}
>>  
>> -	/* If kernelcore was not specified, there is no ZONE_MOVABLE */
>> -	if (!required_kernelcore)
>> +	/*
>> +	 * If kernelcore was not specified or kernelcore size is larger
>> +	 * than totalpages, there is no ZONE_MOVABLE.
>> +	 */
>> +	if (!required_kernelcore || required_kernelcore >= totalpages)
>>  		goto out;
>>  
>>  	/* usable_startpfn is the lowest possible pfn ZONE_MOVABLE can be at */
>> -- 
>> 2.0.0
>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
