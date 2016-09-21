Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 036AD6B026B
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 19:30:23 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id l91so136004095qte.3
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 16:30:22 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id i129si27410645qkd.117.2016.09.21.16.30.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Sep 2016 16:30:22 -0700 (PDT)
Subject: Re: [PATCH 3/5] mm/vmalloc.c: correct lazy_max_pages() return value
References: <57E20C49.8010304@zoho.com>
 <alpine.DEB.2.10.1609211418480.20971@chino.kir.corp.google.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <3ef46c24-769d-701a-938b-826f4249bf0b@zoho.com>
Date: Thu, 22 Sep 2016 07:30:05 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1609211418480.20971@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: zijun_hu@htc.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tj@kernel.org, mingo@kernel.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On 2016/9/22 5:21, David Rientjes wrote:
> On Wed, 21 Sep 2016, zijun_hu wrote:
> 
>> From: zijun_hu <zijun_hu@htc.com>
>>
>> correct lazy_max_pages() return value if the number of online
>> CPUs is power of 2
>>
>> Signed-off-by: zijun_hu <zijun_hu@htc.com>
>> ---
>>  mm/vmalloc.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index a125ae8..2804224 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -594,7 +594,9 @@ static unsigned long lazy_max_pages(void)
>>  {
>>  	unsigned int log;
>>  
>> -	log = fls(num_online_cpus());
>> +	log = num_online_cpus();
>> +	if (log > 1)
>> +		log = (unsigned int)get_count_order(log);
>>  
>>  	return log * (32UL * 1024 * 1024 / PAGE_SIZE);
>>  }
> 
> The implementation of lazy_max_pages() is somewhat arbitrarily defined, 
> the existing approximation has been around for eight years and 
> num_online_cpus() isn't intended to be rounded up to the next power of 2.  
> I'd be inclined to just leave it as it is.
> 
do i understand the intent in current code logic as below ?
[8, 15) roundup to 16?
[32, 63) roundup to 64?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
