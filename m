Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9BED36B0003
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 01:11:09 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id e8-v6so4834430plb.5
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 22:11:09 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id t2si11082664pgb.338.2018.04.16.22.11.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 22:11:08 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: vmalloc: Pass proper vm_start into debugobjects
References: <1523619234-17635-1-git-send-email-cpandya@codeaurora.org>
 <1523619234-17635-3-git-send-email-cpandya@codeaurora.org>
 <ee1e7036-ecdf-0f5b-f460-0d71b4a38dd7@linux.vnet.ibm.com>
 <72acd72a-7b92-c723-62d8-28dd81435457@codeaurora.org>
 <e8d4c0b2-dfb5-8d4d-3bcc-30b8915d24cb@linux.vnet.ibm.com>
From: Chintan Pandya <cpandya@codeaurora.org>
Message-ID: <89438471-6e47-cb70-8909-0ffcc2d3e313@codeaurora.org>
Date: Tue, 17 Apr 2018 10:40:57 +0530
MIME-Version: 1.0
In-Reply-To: <e8d4c0b2-dfb5-8d4d-3bcc-30b8915d24cb@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, vbabka@suse.cz, labbott@redhat.com, catalin.marinas@arm.com, hannes@cmpxchg.org, f.fainelli@gmail.com, xieyisheng1@huawei.com, ard.biesheuvel@linaro.org, richard.weiyang@gmail.com, byungchul.park@lge.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 4/17/2018 8:39 AM, Anshuman Khandual wrote:
> On 04/16/2018 05:39 PM, Chintan Pandya wrote:
>>
>>
>> On 4/13/2018 5:31 PM, Anshuman Khandual wrote:
>>> On 04/13/2018 05:03 PM, Chintan Pandya wrote:
>>>> Client can call vunmap with some intermediate 'addr'
>>>> which may not be the start of the VM area. Entire
>>>> unmap code works with vm->vm_start which is proper
>>>> but debug object API is called with 'addr'. This
>>>> could be a problem within debug objects.
>>>>
>>>> Pass proper start address into debug object API.
>>>>
>>>> Signed-off-by: Chintan Pandya <cpandya@codeaurora.org>
>>>> ---
>>>>    mm/vmalloc.c | 4 ++--
>>>>    1 file changed, 2 insertions(+), 2 deletions(-)
>>>>
>>>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>>>> index 9ff21a1..28034c55 100644
>>>> --- a/mm/vmalloc.c
>>>> +++ b/mm/vmalloc.c
>>>> @@ -1526,8 +1526,8 @@ static void __vunmap(const void *addr, int
>>>> deallocate_pages)
>>>>            return;
>>>>        }
>>>>    -    debug_check_no_locks_freed(addr, get_vm_area_size(area));
>>>> -    debug_check_no_obj_freed(addr, get_vm_area_size(area));
>>>> +    debug_check_no_locks_freed(area->addr, get_vm_area_size(area));
>>>> +    debug_check_no_obj_freed(area->addr, get_vm_area_size(area));
>>>
>>> This kind of makes sense to me but I am not sure. We also have another
>>> instance of this inside the function vm_unmap_ram() where we call for
>> Right, I missed it. I plan to add below stub in v2.
>>
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -1124,15 +1124,15 @@ void vm_unmap_ram(const void *mem, unsigned int
>> count)
>>          BUG_ON(addr > VMALLOC_END);
>>          BUG_ON(!PAGE_ALIGNED(addr));
>>
>> -       debug_check_no_locks_freed(mem, size);
>> -
>>          if (likely(count <= VMAP_MAX_ALLOC)) {
>> +               debug_check_no_locks_freed(mem, size);
> 
> It should have been 'va->va_start' instead of 'mem' in here but as
> said before it looks correct to me but I am not really sure.

vb_free() doesn't honor va->va_start. If mem is not va_start and
deliberate, one will provide proper size. And that should be okay
to do as per the code. So, I don't think this particular debug_check
should have passed va_start in args.

> 

Chintan
-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center,
Inc. is a member of the Code Aurora Forum, a Linux Foundation
Collaborative Project
