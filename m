Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 094966B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 01:55:39 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b64so16764193pfl.13
        for <linux-mm@kvack.org>; Thu, 03 May 2018 22:55:39 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id g11si15566016pfk.187.2018.05.03.22.55.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 22:55:37 -0700 (PDT)
Subject: Re: [PATCH v2 2/2] mm: vmalloc: Pass proper vm_start into
 debugobjects
References: <1523961828-9485-1-git-send-email-cpandya@codeaurora.org>
 <1523961828-9485-3-git-send-email-cpandya@codeaurora.org>
 <20180503144222.bcb5c63bb96309bc3b37fb6f@linux-foundation.org>
From: Chintan Pandya <cpandya@codeaurora.org>
Message-ID: <26e3342d-b518-1e16-25ca-3c2f0ef077d4@codeaurora.org>
Date: Fri, 4 May 2018 11:25:25 +0530
MIME-Version: 1.0
In-Reply-To: <20180503144222.bcb5c63bb96309bc3b37fb6f@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: vbabka@suse.cz, labbott@redhat.com, catalin.marinas@arm.com, hannes@cmpxchg.org, f.fainelli@gmail.com, xieyisheng1@huawei.com, ard.biesheuvel@linaro.org, richard.weiyang@gmail.com, byungchul.park@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, khandual@linux.vnet.ibm.com, mhocko@kernel.org



On 5/4/2018 3:12 AM, Andrew Morton wrote:
> On Tue, 17 Apr 2018 16:13:48 +0530 Chintan Pandya <cpandya@codeaurora.org> wrote:
> 
>> Client can call vunmap with some intermediate 'addr'
>> which may not be the start of the VM area. Entire
>> unmap code works with vm->vm_start which is proper
>> but debug object API is called with 'addr'. This
>> could be a problem within debug objects.
>>
>> Pass proper start address into debug object API.
>>
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -1124,15 +1124,15 @@ void vm_unmap_ram(const void *mem, unsigned int count)
>>   	BUG_ON(addr > VMALLOC_END);
>>   	BUG_ON(!PAGE_ALIGNED(addr));
>>   
>> -	debug_check_no_locks_freed(mem, size);
>> -
>>   	if (likely(count <= VMAP_MAX_ALLOC)) {
>> +		debug_check_no_locks_freed(mem, size);
>>   		vb_free(mem, size);
>>   		return;
>>   	}
>>   
>>   	va = find_vmap_area(addr);
>>   	BUG_ON(!va);
>> +	debug_check_no_locks_freed(va->va_start, (va->va_end - va->va_start));
>>   	free_unmap_vmap_area(va);
>>   }
>>   EXPORT_SYMBOL(vm_unmap_ram);
> 
> hm, how did this sneak through?
My bad. I had tested them but missed bringing these compile fixes to the
patch file. Will be careful next time.

> 
> mm/vmalloc.c:1139:29: warning: passing argument 1 of debug_check_no_locks_freed makes pointer from integer without a cast [-Wint-conversion]
>    debug_check_no_locks_freed(va->va_start, (va->va_end - va->va_start));
> 
> --- a/mm/vmalloc.c~mm-vmalloc-pass-proper-vm_start-into-debugobjects-fix
> +++ a/mm/vmalloc.c
> @@ -1136,7 +1136,8 @@ void vm_unmap_ram(const void *mem, unsig
>   
>   	va = find_vmap_area(addr);
>   	BUG_ON(!va);
> -	debug_check_no_locks_freed(va->va_start, (va->va_end - va->va_start));
> +	debug_check_no_locks_freed((void *)va->va_start,
> +				    (va->va_end - va->va_start));
>   	free_unmap_vmap_area(va);
>   }
>   EXPORT_SYMBOL(vm_unmap_ram);
> 

Chintan
-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center,
Inc. is a member of the Code Aurora Forum, a Linux Foundation
Collaborative Project
