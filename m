Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 969E16B0008
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 08:09:17 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v19so9340431pfn.7
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 05:09:17 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id t12-v6si11788234plm.192.2018.04.16.05.09.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 05:09:16 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: vmalloc: Pass proper vm_start into debugobjects
References: <1523619234-17635-1-git-send-email-cpandya@codeaurora.org>
 <1523619234-17635-3-git-send-email-cpandya@codeaurora.org>
 <ee1e7036-ecdf-0f5b-f460-0d71b4a38dd7@linux.vnet.ibm.com>
From: Chintan Pandya <cpandya@codeaurora.org>
Message-ID: <72acd72a-7b92-c723-62d8-28dd81435457@codeaurora.org>
Date: Mon, 16 Apr 2018 17:39:07 +0530
MIME-Version: 1.0
In-Reply-To: <ee1e7036-ecdf-0f5b-f460-0d71b4a38dd7@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, vbabka@suse.cz, labbott@redhat.com, catalin.marinas@arm.com, hannes@cmpxchg.org, f.fainelli@gmail.com, xieyisheng1@huawei.com, ard.biesheuvel@linaro.org, richard.weiyang@gmail.com, byungchul.park@lge.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 4/13/2018 5:31 PM, Anshuman Khandual wrote:
> On 04/13/2018 05:03 PM, Chintan Pandya wrote:
>> Client can call vunmap with some intermediate 'addr'
>> which may not be the start of the VM area. Entire
>> unmap code works with vm->vm_start which is proper
>> but debug object API is called with 'addr'. This
>> could be a problem within debug objects.
>>
>> Pass proper start address into debug object API.
>>
>> Signed-off-by: Chintan Pandya <cpandya@codeaurora.org>
>> ---
>>   mm/vmalloc.c | 4 ++--
>>   1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index 9ff21a1..28034c55 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -1526,8 +1526,8 @@ static void __vunmap(const void *addr, int deallocate_pages)
>>   		return;
>>   	}
>>   
>> -	debug_check_no_locks_freed(addr, get_vm_area_size(area));
>> -	debug_check_no_obj_freed(addr, get_vm_area_size(area));
>> +	debug_check_no_locks_freed(area->addr, get_vm_area_size(area));
>> +	debug_check_no_obj_freed(area->addr, get_vm_area_size(area));
> 
> This kind of makes sense to me but I am not sure. We also have another
> instance of this inside the function vm_unmap_ram() where we call for
Right, I missed it. I plan to add below stub in v2.

--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1124,15 +1124,15 @@ void vm_unmap_ram(const void *mem, unsigned int 
count)
         BUG_ON(addr > VMALLOC_END);
         BUG_ON(!PAGE_ALIGNED(addr));

-       debug_check_no_locks_freed(mem, size);
-
         if (likely(count <= VMAP_MAX_ALLOC)) {
+               debug_check_no_locks_freed(mem, size);
                 vb_free(mem, size);
                 return;
         }

         va = find_vmap_area(addr);
         BUG_ON(!va);
+       debug_check_no_locks_freed(va->va_start, (va->va_end - 
va->va_start));
         free_unmap_vmap_area(va);
  }
  EXPORT_SYMBOL(vm_unmap_ram);


> debug on locks without even finding the vmap_area first. But it is true
> that in both these functions the vmap_area gets freed eventually. Hence
> the entire mapping [va->va_start --> va->va_end] gets unmapped. Sounds
> like these debug functions should have the entire range as argument.
> But I am not sure and will seek Michal's input on this.
> 

Chintan
-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center,
Inc. is a member of the Code Aurora Forum, a Linux Foundation
Collaborative Project
