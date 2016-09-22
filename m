Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1E49B6B026D
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 21:15:08 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id n185so12900883qke.2
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 18:15:08 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id e34si25605200qkh.308.2016.09.21.18.15.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 21 Sep 2016 18:15:07 -0700 (PDT)
Subject: Re: [PATCH 3/5] mm/vmalloc.c: correct lazy_max_pages() return value
References: <57E20C49.8010304@zoho.com>
 <alpine.DEB.2.10.1609211418480.20971@chino.kir.corp.google.com>
 <3ef46c24-769d-701a-938b-826f4249bf0b@zoho.com>
 <alpine.DEB.2.10.1609211731230.130215@chino.kir.corp.google.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <57E3304E.4060401@zoho.com>
Date: Thu, 22 Sep 2016 09:13:50 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1609211731230.130215@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, Andrew Morton <akpm@linux-foundation.org>, tj@kernel.org, mingo@kernel.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On 09/22/2016 08:35 AM, David Rientjes wrote:
> On Thu, 22 Sep 2016, zijun_hu wrote:
> 
>> On 2016/9/22 5:21, David Rientjes wrote:
>>> On Wed, 21 Sep 2016, zijun_hu wrote:
>>>
>>>> From: zijun_hu <zijun_hu@htc.com>
>>>>
>>>> correct lazy_max_pages() return value if the number of online
>>>> CPUs is power of 2
>>>>
>>>> Signed-off-by: zijun_hu <zijun_hu@htc.com>
>>>> ---
>>>>  mm/vmalloc.c | 4 +++-
>>>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>>>> index a125ae8..2804224 100644
>>>> --- a/mm/vmalloc.c
>>>> +++ b/mm/vmalloc.c
>>>> @@ -594,7 +594,9 @@ static unsigned long lazy_max_pages(void)
>>>>  {
>>>>  	unsigned int log;
>>>>  
>>>> -	log = fls(num_online_cpus());
>>>> +	log = num_online_cpus();
>>>> +	if (log > 1)
>>>> +		log = (unsigned int)get_count_order(log);
>>>>  
>>>>  	return log * (32UL * 1024 * 1024 / PAGE_SIZE);
>>>>  }
>>>
>>> The implementation of lazy_max_pages() is somewhat arbitrarily defined, 
>>> the existing approximation has been around for eight years and 
>>> num_online_cpus() isn't intended to be rounded up to the next power of 2.  
>>> I'd be inclined to just leave it as it is.
>>>
>> do i understand the intent in current code logic as below ?
>> [8, 15) roundup to 16?
>> [32, 63) roundup to 64?
>>
> 
> The intent is as it is implemented; with your change, lazy_max_pages() is 
> potentially increased depending on the number of online cpus.  This is 
> only a heuristic, changing it would need justification on why the new 
> value is better.  It is opposite to what the comment says: "to be 
> conservative and not introduce a big latency on huge systems, so go with
> a less aggressive log scale."  NACK to the patch.
> 
my change potentially make lazy_max_pages() decreased not increased, i seems
conform with the comment

if the number of online CPUs is not power of 2, both have no any difference
otherwise, my change remain power of 2 value, and the original code rounds up
to next power of 2 value, for instance

my change : (32, 64] -> 64
	     32 -> 32, 64 -> 64
the original code: [32, 63) -> 64
                   32 -> 64, 64 -> 128


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
