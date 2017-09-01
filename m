Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 289C16B0292
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 01:00:31 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b184so3820586oih.3
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 22:00:31 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id b143si1113433oii.529.2017.08.31.22.00.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 22:00:29 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm, page_owner: Skip unnecessary stack_trace entries
References: <1504078343-28754-1-git-send-email-guptap@codeaurora.org>
 <1504078343-28754-2-git-send-email-guptap@codeaurora.org>
 <82346e0c-176a-dc11-c535-47d023f237a8@suse.cz>
From: Prakash Gupta <guptap@codeaurora.org>
Message-ID: <b890d2a7-addc-1d67-a585-655c3a9f145a@codeaurora.org>
Date: Fri, 1 Sep 2017 10:30:23 +0530
MIME-Version: 1.0
In-Reply-To: <82346e0c-176a-dc11-c535-47d023f237a8@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, mhocko@suse.com, will.deacon@arm.com, catalin.marinas@arm.com, iamjoonsoo.kim@lge.com, rmk+kernel@arm.linux.org.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org


On 8/31/2017 1:04 PM, Vlastimil Babka wrote:
> On 08/30/2017 09:32 AM, Prakash Gupta wrote:
>> The page_owner stacktrace always begin as follows:
>>
>> [<ffffff987bfd48f4>] save_stack+0x40/0xc8
>> [<ffffff987bfd4da8>] __set_page_owner+0x3c/0x6c
> 
> Hmm, on x86_64 it looks like this:
> 
>   save_stack_trace+0x16/0x20
>   save_stack+0x43/0xe0
>   __set_page_owner+0x24/0x50
> 
> So after your patch there's still __set_page_owner. Seems x86 needs
> something similar to your arm64 patch 1/2?

Yes, that's correct.

> 
>> These two entries do not provide any useful information and limits the
>> available stacktrace depth.  The page_owner stacktrace was skipping caller
>> function from stack entries but this was missed with commit f2ca0b557107
>> ("mm/page_owner: use stackdepot to store stacktrace")
>>
>> Example page_owner entry after the patch:
>>
>> Page allocated via order 0, mask 0x8(ffffff80085fb714)
>> PFN 654411 type Movable Block 639 type CMA Flags 0x0(ffffffbe5c7f12c0)
>> [<ffffff9b64989c14>] post_alloc_hook+0x70/0x80
>> ...
>> [<ffffff9b651216e8>] msm_comm_try_state+0x5f8/0x14f4
>> [<ffffff9b6512486c>] msm_vidc_open+0x5e4/0x7d0
>> [<ffffff9b65113674>] msm_v4l2_open+0xa8/0x224
>>
>> Fixes: f2ca0b557107 ("mm/page_owner: use stackdepot to store stacktrace")
>> Signed-off-by: Prakash Gupta <guptap@codeaurora.org>
> 
> The patch itself improves the output regardless of whether we fix the
> x86 internals, so:
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks.

> 
>> ---
>>   mm/page_owner.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/page_owner.c b/mm/page_owner.c
>> index 10d16fc45bd9..75b7c39bf1df 100644
>> --- a/mm/page_owner.c
>> +++ b/mm/page_owner.c
>> @@ -139,7 +139,7 @@ static noinline depot_stack_handle_t save_stack(gfp_t flags)
>>   		.nr_entries = 0,
>>   		.entries = entries,
>>   		.max_entries = PAGE_OWNER_STACK_DEPTH,
>> -		.skip = 0
>> +		.skip = 2
>>   	};
>>   	depot_stack_handle_t handle;
>>   
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
