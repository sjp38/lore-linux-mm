Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1EA29280255
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 01:00:51 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id wk8so184377581pab.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 22:00:51 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id kg8si5818189pad.210.2016.09.22.22.00.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 22:00:50 -0700 (PDT)
Subject: Re: [PATCH 3/5] mm/vmalloc.c: correct lazy_max_pages() return value
References: <57E20C49.8010304@zoho.com>
 <alpine.DEB.2.10.1609211418480.20971@chino.kir.corp.google.com>
 <3ef46c24-769d-701a-938b-826f4249bf0b@zoho.com>
 <alpine.DEB.2.10.1609211731230.130215@chino.kir.corp.google.com>
 <57E3304E.4060401@zoho.com> <20160922123736.GA11204@dhcp22.suse.cz>
 <7671e782-b58f-7c41-b132-c7ebbcf61b99@zoho.com>
 <20160923133022.47cfd3dd@roar.ozlabs.ibm.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <a98b4ca9-11d1-6510-63c9-f63897129be3@zoho.com>
Date: Fri, 23 Sep 2016 13:00:35 +0800
MIME-Version: 1.0
In-Reply-To: <20160923133022.47cfd3dd@roar.ozlabs.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: zijun_hu@htc.com, Michal Hocko <mhocko@kernel.org>, npiggin@suse.de, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, tj@kernel.org, mingo@kernel.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

On 2016/9/23 11:30, Nicholas Piggin wrote:
> On Fri, 23 Sep 2016 00:30:20 +0800
> zijun_hu <zijun_hu@zoho.com> wrote:
> 
>> On 2016/9/22 20:37, Michal Hocko wrote:
>>> On Thu 22-09-16 09:13:50, zijun_hu wrote:  
>>>> On 09/22/2016 08:35 AM, David Rientjes wrote:  
>>> [...]  
>>>>> The intent is as it is implemented; with your change, lazy_max_pages() is 
>>>>> potentially increased depending on the number of online cpus.  This is 
>>>>> only a heuristic, changing it would need justification on why the new
>>>>> value is better.  It is opposite to what the comment says: "to be 
>>>>> conservative and not introduce a big latency on huge systems, so go with
>>>>> a less aggressive log scale."  NACK to the patch.
>>>>>  
>>>> my change potentially make lazy_max_pages() decreased not increased, i seems
>>>> conform with the comment
>>>>
>>>> if the number of online CPUs is not power of 2, both have no any difference
>>>> otherwise, my change remain power of 2 value, and the original code rounds up
>>>> to next power of 2 value, for instance
>>>>
>>>> my change : (32, 64] -> 64
>>>> 	     32 -> 32, 64 -> 64
>>>> the original code: [32, 63) -> 64
>>>>                    32 -> 64, 64 -> 128  
>>>
>>> You still completely failed to explain _why_ this is an improvement/fix
>>> or why it matters. This all should be in the changelog.
>>>   
>>
>> Hi npiggin,
>> could you give some comments for this patch since lazy_max_pages() is introduced
>> by you
>>
>> my patch is based on the difference between fls() and get_count_order() mainly
>> the difference between fls() and get_count_order() will be shown below
>> more MM experts maybe help to decide which is more suitable
>>
>> if parameter > 1, both have different return value only when parameter is
>> power of two, for example
>>
>> fls(32) = 6 VS get_count_order(32) = 5
>> fls(33) = 6 VS get_count_order(33) = 6
>> fls(63) = 6 VS get_count_order(63) = 6
>> fls(64) = 7 VS get_count_order(64) = 6
>>
>> @@ -594,7 +594,9 @@ static unsigned long lazy_max_pages(void) 
>> { 
>>     unsigned int log; 
>>
>> -    log = fls(num_online_cpus()); 
>> +    log = num_online_cpus(); 
>> +    if (log > 1) 
>> +        log = (unsigned int)get_count_order(log); 
>>
>>     return log * (32UL * 1024 * 1024 / PAGE_SIZE); 
>> } 
>>
> 
> To be honest, I don't think I chose it with a lot of analysis.
> It will depend on the kernel usage patterns, the arch code,
> and the CPU microarchitecture, all of which would have changed
> significantly.
> 
> I wouldn't bother changing it unless you do some bench marking
> on different system sizes to see where the best performance is.
> (If performance is equal, fewer lazy pages would be better.)
> 
> Good to see you taking a look at this vmalloc stuff. Don't be
> discouraged if you run into some dead ends.
> 
> Thanks,
> Nick
> 
thanks for your reply
please don't pay attention to this patch any more since i don't have
condition to do many test and comparison

i just feel my change maybe be consistent with operation of rounding up
to power of 2


 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
