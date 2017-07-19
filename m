Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B1D656B025F
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 12:39:59 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id u123so4529869itu.5
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 09:39:59 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id h97si398954iod.343.2017.07.19.09.39.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 09:39:59 -0700 (PDT)
Subject: Re: [PATCH] mm/mremap: Fail map duplication attempts for private
 mappings
References: <1499961495-8063-1-git-send-email-mike.kravetz@oracle.com>
 <4e921eb5-8741-3337-9a7d-5ec9473412da@suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <fad64378-02d7-32c3-50c5-8b444a07d274@oracle.com>
Date: Wed, 19 Jul 2017 09:39:50 -0700
MIME-Version: 1.0
In-Reply-To: <4e921eb5-8741-3337-9a7d-5ec9473412da@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Aaron Lu <aaron.lu@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Linux API <linux-api@vger.kernel.org>

On 07/13/2017 12:11 PM, Vlastimil Babka wrote:
> [+CC linux-api]
> 
> On 07/13/2017 05:58 PM, Mike Kravetz wrote:
>> mremap will create a 'duplicate' mapping if old_size == 0 is
>> specified.  Such duplicate mappings make no sense for private
>> mappings.  If duplication is attempted for a private mapping,
>> mremap creates a separate private mapping unrelated to the
>> original mapping and makes no modifications to the original.
>> This is contrary to the purpose of mremap which should return
>> a mapping which is in some way related to the original.
>>
>> Therefore, return EINVAL in the case where if an attempt is
>> made to duplicate a private mapping.
>>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

After considering Michal's concerns with follow on patch, it appears
this patch provides the most desired behavior.  Any other concerns
or issues with this patch?

If this moves forward, I will create man page updates to describe the
mremap(old_size == 0) behavior.

-- 
Mike Kravetz

> 
>> ---
>>  mm/mremap.c | 7 +++++++
>>  1 file changed, 7 insertions(+)
>>
>> diff --git a/mm/mremap.c b/mm/mremap.c
>> index cd8a1b1..076f506 100644
>> --- a/mm/mremap.c
>> +++ b/mm/mremap.c
>> @@ -383,6 +383,13 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
>>  	if (!vma || vma->vm_start > addr)
>>  		return ERR_PTR(-EFAULT);
>>  
>> +	/*
>> +	 * !old_len  is a special case where a mapping is 'duplicated'.
>> +	 * Do not allow this for private mappings.
>> +	 */
>> +	if (!old_len && !(vma->vm_flags & (VM_SHARED | VM_MAYSHARE)))
>> +		return ERR_PTR(-EINVAL);
>> +
>>  	if (is_vm_hugetlb_page(vma))
>>  		return ERR_PTR(-EINVAL);
>>  
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
