Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id DCC636B000C
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 08:13:02 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id b11-v6so5812488pla.19
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 05:13:02 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id u23-v6si4889721plk.516.2018.04.13.05.13.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 05:13:01 -0700 (PDT)
Subject: Re: [PATCH] mm: vmalloc: Remove double execution of vunmap_page_range
References: <1523611019-17679-1-git-send-email-cpandya@codeaurora.org>
 <a623e12b-bb5e-58fa-c026-de9ea53c5bd9@linux.vnet.ibm.com>
 <8da9f826-2a3d-e618-e512-4fc8d45c16f2@codeaurora.org>
 <bbef0a92-f81b-5ba8-c5c1-d8c08444955b@linux.vnet.ibm.com>
 <fa104cc6-c32a-9081-280f-2e03e4279f65@codeaurora.org>
 <20180413110949.GA17670@dhcp22.suse.cz>
 <696fedc5-6bcd-f0a0-62f5-4f9e7b7c602a@codeaurora.org>
 <20180413114133.GJ17484@dhcp22.suse.cz>
From: Chintan Pandya <cpandya@codeaurora.org>
Message-ID: <7674bfda-6186-8b32-0144-62c666e05e3c@codeaurora.org>
Date: Fri, 13 Apr 2018 17:42:53 +0530
MIME-Version: 1.0
In-Reply-To: <20180413114133.GJ17484@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, vbabka@suse.cz, labbott@redhat.com, catalin.marinas@arm.com, hannes@cmpxchg.org, f.fainelli@gmail.com, xieyisheng1@huawei.com, ard.biesheuvel@linaro.org, richard.weiyang@gmail.com, byungchul.park@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 4/13/2018 5:11 PM, Michal Hocko wrote:
> On Fri 13-04-18 16:57:06, Chintan Pandya wrote:
>>
>>
>> On 4/13/2018 4:39 PM, Michal Hocko wrote:
>>> On Fri 13-04-18 16:15:26, Chintan Pandya wrote:
>>>>
>>>>
>>>> On 4/13/2018 4:10 PM, Anshuman Khandual wrote:
>>>>> On 04/13/2018 03:47 PM, Chintan Pandya wrote:
>>>>>>
>>>>>>
>>>>>> On 4/13/2018 3:29 PM, Anshuman Khandual wrote:
>>>>>>> On 04/13/2018 02:46 PM, Chintan Pandya wrote:
>>>>>>>> Unmap legs do call vunmap_page_range() irrespective of
>>>>>>>> debug_pagealloc_enabled() is enabled or not. So, remove
>>>>>>>> redundant check and optional vunmap_page_range() routines.
>>>>>>>
>>>>>>> vunmap_page_range() tears down the page table entries and does
>>>>>>> not really flush related TLB entries normally unless page alloc
>>>>>>> debug is enabled where it wants to make sure no stale mapping is
>>>>>>> still around for debug purpose. Deferring TLB flush improves
>>>>>>> performance. This patch will force TLB flush during each page
>>>>>>> table tear down and hence not desirable.
>>>>>>>
>>>>>> Deferred TLB invalidation will surely improve performance. But force
>>>>>> flush can help in detecting invalid access right then and there. I
>>>>>
>>>>> Deferred TLB invalidation was a choice made some time ago with the
>>>>> commit db64fe02258f1507e ("mm: rewrite vmap layer") as these vmalloc
>>>>> mappings wont be used other than inside the kernel and TLB gets
>>>>> flushed when they are reused. This way it can still avail the benefit
>>>>> of deferred TLB flushing without exposing itself to invalid accesses.
>>>>>
>>>>>> chose later. May be I should have clean up the vmap tear down code
>>>>>> as well where it actually does the TLB invalidation.
>>>>>>
>>>>>> Or make TLB invalidation in free_unmap_vmap_area() be dependent upon
>>>>>> debug_pagealloc_enabled().
>>>>>
>>>>> Immediate TLB invalidation needs to be dependent on debug_pagealloc_
>>>>> enabled() and should be done only for debug purpose. Contrary to that
>>>>> is not desirable.
>>>>>
>>>> Okay. I will raise v2 for that.
>>>
>>> More importantly. Your changelog absolutely lacks the _why_ part. It
>>> just states what the code does which is not all that hard to read from
>>> the diff. It is usually much more important to present _why_ the patch
>>> is an improvement and worth merging.
>>>
>>
>> It is improving performance in debug scenario.
> 
> Do not forget to add some numbers presenting the benefits when
> resubmitting.
Okay.

> 
>> More than that, I see it
>> as a clean up. Sure, I will try to address *why* in next change log. >
> As Anshuman pointed out the current code layout is deliberate. If you
> believe that reasons mentioned previously are not valid then dispute
> them and provide your arguments in the changelog.
> 
Here, the trade off is, performance vs catching use-after-free. Original
code is preferring performance gains. At first, it seemed to me that
stability is more important than performance. But giving more thoughts
on this (and reading commit db64fe02258f1507e ("mm: rewrite vmap
layer")), I feel that use-after-free is client side wrong-doing. vmap
layer need not loose its best case settings for potential client side
mistakes. For that, vmap layer can provide debug settings. So, I plan
to do TLB flush conditional on debug settings.

Chintan
-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center,
Inc. is a member of the Code Aurora Forum, a Linux Foundation
Collaborative Project
