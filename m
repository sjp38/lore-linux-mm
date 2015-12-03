Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 245346B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 19:52:29 -0500 (EST)
Received: by pfdd184 with SMTP id d184so2954216pfd.3
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 16:52:28 -0800 (PST)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id bm5si8073065pad.107.2015.12.02.16.52.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 16:52:28 -0800 (PST)
Received: by padhx2 with SMTP id hx2so55512533pad.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 16:52:28 -0800 (PST)
Message-ID: <565F924A.7050706@linaro.org>
Date: Wed, 02 Dec 2015 16:52:26 -0800
From: "Shi, Yang" <yang.shi@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH V2 2/7] mm/gup: add gup trace points
References: <1449096813-22436-1-git-send-email-yang.shi@linaro.org> <1449096813-22436-3-git-send-email-yang.shi@linaro.org> <565F8092.7000001@intel.com> <565F88B9.10306@linaro.org>
In-Reply-To: <565F88B9.10306@linaro.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On 12/2/2015 4:11 PM, Shi, Yang wrote:
> On 12/2/2015 3:36 PM, Dave Hansen wrote:
>> On 12/02/2015 02:53 PM, Yang Shi wrote:
>>> diff --git a/mm/gup.c b/mm/gup.c
>>> index deafa2c..10245a4 100644
>>> --- a/mm/gup.c
>>> +++ b/mm/gup.c
>>> @@ -13,6 +13,9 @@
>>>   #include <linux/rwsem.h>
>>>   #include <linux/hugetlb.h>
>>>
>>> +#define CREATE_TRACE_POINTS
>>> +#include <trace/events/gup.h>
>>> +
>>>   #include <asm/pgtable.h>
>>>   #include <asm/tlbflush.h>
>>
>> This needs to be _the_ last thing that gets #included.  Otherwise, you
>> risk colliding with any other trace header that gets implicitly included
>> below.
>
> Thanks for the suggestion, will move it to the last.
>
>>
>>> @@ -1340,6 +1346,8 @@ int __get_user_pages_fast(unsigned long start,
>>> int nr_pages, int write,
>>>                       start, len)))
>>>           return 0;
>>>
>>> +    trace_gup_get_user_pages_fast(start, nr_pages, write, pages);
>>> +
>>>       /*
>>>        * Disable interrupts.  We use the nested form as we can
>>> already have
>>>        * interrupts disabled by get_futex_key.
>>
>> It would be _really_ nice to be able to see return values from the
>> various gup calls as well.  Is that feasible?
>
> I think it should be feasible. kmem_cache_alloc trace event could show
> return value. I'm supposed gup trace events should be able to do the
> same thing.

Just did a quick test, it is definitely feasible. Please check the below 
test log:

        trace-cmd-200   [000]    99.221486: gup_get_user_pages: 
start=8000000ff0 nr_pages=1 ret=1
        trace-cmd-200   [000]    99.223215: gup_get_user_pages: 
start=8000000fdb nr_pages=1 ret=1
        trace-cmd-200   [000]    99.223298: gup_get_user_pages: 
start=8000000ed0 nr_pages=1 ret=1

nr_pages is the number of pages requested by the gup, ret is the return 
value.

If nobody has objection, I will add it into V3.

Regards,
Yang

>
> Regards,
> Yang
>
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
