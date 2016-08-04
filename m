Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 90AE56B025E
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 09:57:17 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id m130so518123846ioa.1
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 06:57:17 -0700 (PDT)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id l198si3180657itl.82.2016.08.04.06.57.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 06:57:17 -0700 (PDT)
Received: by mail-io0-x243.google.com with SMTP id q83so21966110iod.2
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 06:57:16 -0700 (PDT)
Subject: Re: [PATCH] fs:Fix kmemleak leak warning in getname_flags about
 working on unitialized memory
References: <1470260896-31767-1-git-send-email-xerofoify@gmail.com>
 <6b369f5c-6a9d-febf-81fe-2e1a4b408814@suse.cz>
From: nick <xerofoify@gmail.com>
Message-ID: <4bbd8d52-e4ee-74ef-d3f3-897c6ba209a2@gmail.com>
Date: Thu, 4 Aug 2016 09:57:14 -0400
MIME-Version: 1.0
In-Reply-To: <6b369f5c-6a9d-febf-81fe-2e1a4b408814@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, viro@zeniv.linux.org.uk
Cc: akpm@linux-foundation.org, msalter@redhat.com, kuleshovmail@gmail.com, david.vrabel@citrix.com, ard.biesheuvel@linaro.org, jgross@suse.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 2016-08-04 09:31 AM, Vlastimil Babka wrote:
> On 08/03/2016 11:48 PM, Nicholas Krause wrote:
>> This fixes a kmemleak leak warning complaining about working on
>> unitializied memory as found in the function, getname_flages. Seems
> 
> What exactly is the kmemleak warning saying?
> 
>> that we are indeed working on unitialized memory, as the filename
>> char pointer is never made to point to the filname structure's result
>> member for holding it's name, fix this by using memcpy to copy the
>> filname structure pointer's, name to the char pointer passed to this
>> function.
> 
> I don't understand what you're saying here. "the char pointer passed to
> this function" is the source, not destination.
> 
That's fine what I mean to state is this we are never copying back our internal
struct filename result's name member to the user pointer leading to a kmemleak
warning.
>> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
>> ---
>>  fs/namei.c         | 1 +
>>  mm/early_ioremap.c | 1 +
>>  2 files changed, 2 insertions(+)
>>
>> diff --git a/fs/namei.c b/fs/namei.c
>> index c386a32..6b18d57 100644
>> --- a/fs/namei.c
>> +++ b/fs/namei.c
>> @@ -196,6 +196,7 @@ getname_flags(const char __user *filename, int flags, int *empty)
>>  		}
>>  	}
>>  
>> +	memcpy((char *)result->name, filename, len);
> 
> This will be wrong even with strncpy_from_user instead of memcpy. AFAICS
> result->name already points to a copy of filename.
Yes that is correct but the pointer we are passing is called, filename into
getname_flags which is what I am passing as the second argument which is
confusing at least to me :).
> Also if you think that the above is "copy[ing] the filname structure
> pointer's, name to the char pointer passed to this function" then you
> are wrong.
> 
I assumed here that it was copying or moving the pointer over to point to
the region of memory allocated for the structure result pointer to hold
it's name member, I could be wrong :).
>>  	result->uptr = filename;
>>  	result->aname = NULL;
>>  	audit_getname(result);
>> diff --git a/mm/early_ioremap.c b/mm/early_ioremap.c
>> index 6d5717b..92c5235 100644
>> --- a/mm/early_ioremap.c
>> +++ b/mm/early_ioremap.c
>> @@ -215,6 +215,7 @@ early_ioremap(resource_size_t phys_addr, unsigned long size)
>>  void __init *
>>  early_memremap(resource_size_t phys_addr, unsigned long size)
>>  {
>> +	dump_stack();
>>  	return (__force void *)__early_ioremap(phys_addr, size,
>>  					       FIXMAP_PAGE_NORMAL);
>>  }
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
