Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 298446B0038
	for <linux-mm@kvack.org>; Mon, 15 May 2017 20:33:47 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id k91so92408398ioi.3
        for <linux-mm@kvack.org>; Mon, 15 May 2017 17:33:47 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id u133si12276317iod.201.2017.05.15.17.33.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 17:33:46 -0700 (PDT)
Subject: Re: [v3 9/9] s390: teach platforms not to zero struct pages memory
References: <1494003796-748672-1-git-send-email-pasha.tatashin@oracle.com>
 <1494003796-748672-10-git-send-email-pasha.tatashin@oracle.com>
 <20170508113624.GA4876@osiris>
 <0669a945-4540-096e-799a-2d2b3c18abaa@oracle.com>
 <20170515231716.GA3314@osiris>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <a3a14b28-8389-33e4-3a84-e4db4bfdd17e@oracle.com>
Date: Mon, 15 May 2017 20:33:29 -0400
MIME-Version: 1.0
In-Reply-To: <20170515231716.GA3314@osiris>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, davem@davemloft.net

Ah OK, I will include the change.

Thank you,
Pasha

On 05/15/2017 07:17 PM, Heiko Carstens wrote:
> Hello Pasha,
> 
>> Thank you for looking at this patch. I am worried to make the proposed
>> change, because, as I understand in this case we allocate memory not for
>> "struct page"s but for table that hold them. So, we will change the behavior
>> from the current one, where this table is allocated zeroed, but now it won't
>> be zeroed.
> 
> The page table, if needed, is allocated and populated a couple of lines
> above. See the vmem_pte_alloc() call. So my request to include the hunk
> below is still valid ;)
> 
>>> If you add the hunk below then this is
>>>
>>> Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>
>>>
>>> diff --git a/arch/s390/mm/vmem.c b/arch/s390/mm/vmem.c
>>> index ffe9ba1aec8b..bf88a8b9c24d 100644
>>> --- a/arch/s390/mm/vmem.c
>>> +++ b/arch/s390/mm/vmem.c
>>> @@ -272,7 +272,7 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
>>>   		if (pte_none(*pt_dir)) {
>>>   			void *new_page;
>>> -			new_page = vmemmap_alloc_block(PAGE_SIZE, node, true);
>>> +			new_page = vmemmap_alloc_block(PAGE_SIZE, node, VMEMMAP_ZERO);
>>>   			if (!new_page)
>>>   				goto out;
>>>   			pte_val(*pt_dir) = __pa(new_page) | pgt_prot;
>>>
>>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
