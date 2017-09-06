Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 311BB2802FE
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 09:55:26 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u26so6260654wma.4
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 06:55:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s26si391175wma.233.2017.09.06.06.55.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Sep 2017 06:55:24 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm, page_owner: make init_pages_in_zone() faster
References: <20170720134029.25268-1-vbabka@suse.cz>
 <20170720134029.25268-2-vbabka@suse.cz>
 <20170724123843.GH25221@dhcp22.suse.cz>
 <483227ce-6786-f04b-72d1-dba18e06ccaa@suse.cz>
 <45813564-2342-fc8d-d31a-f4b68a724325@suse.cz>
 <20170906134908.xv7esjffv2xmpbq4@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ddbc40d6-0dba-d4d2-2c10-c6e2c3f9837a@suse.cz>
Date: Wed, 6 Sep 2017 15:55:22 +0200
MIME-Version: 1.0
In-Reply-To: <20170906134908.xv7esjffv2xmpbq4@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yang Shi <yang.shi@linaro.org>, Laura Abbott <labbott@redhat.com>, Vinayak Menon <vinmenon@codeaurora.org>, zhong jiang <zhongjiang@huawei.com>

On 09/06/2017 03:49 PM, Michal Hocko wrote:
> On Thu 31-08-17 09:55:25, Vlastimil Babka wrote:
>> On 08/23/2017 08:47 AM, Vlastimil Babka wrote:
>>> On 07/24/2017 02:38 PM, Michal Hocko wrote:
>>>> On Thu 20-07-17 15:40:26, Vlastimil Babka wrote:
>>>>> In init_pages_in_zone() we currently use the generic set_page_owner() function
>>>>> to initialize page_owner info for early allocated pages. This means we
>>>>> needlessly do lookup_page_ext() twice for each page, and more importantly
>>>>> save_stack(), which has to unwind the stack and find the corresponding stack
>>>>> depot handle. Because the stack is always the same for the initialization,
>>>>> unwind it once in init_pages_in_zone() and reuse the handle. Also avoid the
>>>>> repeated lookup_page_ext().
>>>>
>>>> Yes this looks like an improvement but I have to admit that I do not
>>>> really get why we even do save_stack at all here. Those pages might
>>>> got allocated from anywhere so we could very well provide a statically
>>>> allocated "fake" stack trace, no?
>>>
>>> We could, but it's much simpler to do it this way than try to extend
>>> stack depot/stack saving to support creating such fakes. Would it be
>>> worth the effort?
>>
>> Ah, I've noticed we already do this for the dummy (prevent recursion)
>> stack and failure stack. So here you go. It will also make the fake
>> stack more obvious after "[PATCH 2/2] mm, page_owner: Skip unnecessary
>> stack_trace entries" is merged, which would otherwise remove
>> init_page_owner() from the stack.
> 
> Yes this is what I've had in mind.
> 
>> ----8<----
>> >From 9804a5e62fc768e12b86fd4a3184e692c59ebfd1 Mon Sep 17 00:00:00 2001
>> From: Vlastimil Babka <vbabka@suse.cz>
>> Date: Thu, 31 Aug 2017 09:46:46 +0200
>> Subject: [PATCH] mm, page_owner: make init_pages_in_zone() faster-fix2
>>
>> Create statically allocated fake stack trace for early allocated pages, per
>> Michal Hocko.
> 
> Yes this looks good to me. I am just wondering why we need 3 different
> fake stacks. I do not see any code that would special case them when
> dumping traces. Maybe this can be done on top?

It's so that the user can differentiate them in the output. That's why
the functions are noinline.

>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> 
> Anyway
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
