Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 605CF6B002E
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 23:09:50 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 38so13612466wrv.8
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 20:09:50 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m13si11579579edi.197.2018.04.16.20.09.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 20:09:49 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3H38it2145425
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 23:09:47 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hd6g051mf-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 23:09:47 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 17 Apr 2018 04:09:44 +0100
Subject: Re: [PATCH 2/2] mm: vmalloc: Pass proper vm_start into debugobjects
References: <1523619234-17635-1-git-send-email-cpandya@codeaurora.org>
 <1523619234-17635-3-git-send-email-cpandya@codeaurora.org>
 <ee1e7036-ecdf-0f5b-f460-0d71b4a38dd7@linux.vnet.ibm.com>
 <72acd72a-7b92-c723-62d8-28dd81435457@codeaurora.org>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 17 Apr 2018 08:39:36 +0530
MIME-Version: 1.0
In-Reply-To: <72acd72a-7b92-c723-62d8-28dd81435457@codeaurora.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <e8d4c0b2-dfb5-8d4d-3bcc-30b8915d24cb@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, vbabka@suse.cz, labbott@redhat.com, catalin.marinas@arm.com, hannes@cmpxchg.org, f.fainelli@gmail.com, xieyisheng1@huawei.com, ard.biesheuvel@linaro.org, richard.weiyang@gmail.com, byungchul.park@lge.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/16/2018 05:39 PM, Chintan Pandya wrote:
> 
> 
> On 4/13/2018 5:31 PM, Anshuman Khandual wrote:
>> On 04/13/2018 05:03 PM, Chintan Pandya wrote:
>>> Client can call vunmap with some intermediate 'addr'
>>> which may not be the start of the VM area. Entire
>>> unmap code works with vm->vm_start which is proper
>>> but debug object API is called with 'addr'. This
>>> could be a problem within debug objects.
>>>
>>> Pass proper start address into debug object API.
>>>
>>> Signed-off-by: Chintan Pandya <cpandya@codeaurora.org>
>>> ---
>>>   mm/vmalloc.c | 4 ++--
>>>   1 file changed, 2 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>>> index 9ff21a1..28034c55 100644
>>> --- a/mm/vmalloc.c
>>> +++ b/mm/vmalloc.c
>>> @@ -1526,8 +1526,8 @@ static void __vunmap(const void *addr, int
>>> deallocate_pages)
>>>           return;
>>>       }
>>>   -    debug_check_no_locks_freed(addr, get_vm_area_size(area));
>>> -    debug_check_no_obj_freed(addr, get_vm_area_size(area));
>>> +    debug_check_no_locks_freed(area->addr, get_vm_area_size(area));
>>> +    debug_check_no_obj_freed(area->addr, get_vm_area_size(area));
>>
>> This kind of makes sense to me but I am not sure. We also have another
>> instance of this inside the function vm_unmap_ram() where we call for
> Right, I missed it. I plan to add below stub in v2.
> 
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1124,15 +1124,15 @@ void vm_unmap_ram(const void *mem, unsigned int
> count)
>         BUG_ON(addr > VMALLOC_END);
>         BUG_ON(!PAGE_ALIGNED(addr));
> 
> -       debug_check_no_locks_freed(mem, size);
> -
>         if (likely(count <= VMAP_MAX_ALLOC)) {
> +               debug_check_no_locks_freed(mem, size);

It should have been 'va->va_start' instead of 'mem' in here but as
said before it looks correct to me but I am not really sure.
