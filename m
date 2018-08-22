Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8B33D6B2661
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 17:48:45 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id e140-v6so1073022vkd.11
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 14:48:45 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id z3-v6si1241359vkf.2.2018.08.22.14.48.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 14:48:44 -0700 (PDT)
Subject: Re: [PATCH v3 1/2] mm: migration: fix migration of huge PMD shared
 pages
References: <20180821205902.21223-2-mike.kravetz@oracle.com>
 <201808220831.eM0je51n%fengguang.wu@intel.com>
 <975b740d-26a6-eb3f-c8ca-1a9995d0d343@oracle.com>
 <20180822210507.lvb26bghqmt6c5fw@kshutemo-mobl1>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <c3880447-8f07-e78f-d107-c45bd526fb62@oracle.com>
Date: Wed, 22 Aug 2018 14:48:31 -0700
MIME-Version: 1.0
In-Reply-To: <20180822210507.lvb26bghqmt6c5fw@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On 08/22/2018 02:05 PM, Kirill A. Shutemov wrote:
> On Tue, Aug 21, 2018 at 06:10:42PM -0700, Mike Kravetz wrote:
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 3103099f64fd..f085019a4724 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -4555,6 +4555,9 @@ static bool vma_shareable(struct vm_area_struct *vma, unsigned long addr)
>>  
>>  	/*
>>  	 * check on proper vm_flags and page table alignment
>> +	 *
>> +	 * Note that this is the same check used in huge_pmd_sharing_possible.
>> +	 * If you change one, consider changing both.
> 
> Should we have helper to isolate the check in one place?
> 

Yes, I will create one.  Most likely just a #define.

>>  	 */
>>  	if (vma->vm_flags & VM_MAYSHARE &&
>>  	    vma->vm_start <= base && end <= vma->vm_end)
>> @@ -4562,6 +4565,43 @@ static bool vma_shareable(struct vm_area_struct *vma, unsigned long addr)
>>  	return false;
>>  }
>>  
>> +/*
>> + * Determine if start,end range within vma could be mapped by shared pmd.
>> + * If yes, adjust start and end to cover range associated with possible
>> + * shared pmd mappings.
>> + */
>> +bool huge_pmd_sharing_possible(struct vm_area_struct *vma,
>> +				unsigned long *start, unsigned long *end)
>> +{
>> +	unsigned long check_addr = *start;
>> +	bool ret = false;
>> +
>> +	if (!(vma->vm_flags & VM_MAYSHARE))
>> +		return ret;
> 
> Do we ever use return value? I don't see it.
> 
> And in this case function name is not really work...

You are correct.  None of the code uses the return value.  I initially
thought some caller would use it.  But every caller wants/needs to
adjust the range if sharing is possible.  This is a really long name
but how about:

void adjust_range_if_pmd_sharing_possible(struct vm_area_struct *vma,
				unsigned long *start, unsigned long *end)

I'm open to other names and will update patch with suggestions.
-- 
Mike Kravetz

> 
>> +	for (check_addr = *start; check_addr < *end; check_addr += PUD_SIZE) {
>> +		unsigned long a_start = check_addr & PUD_MASK;
>> +		unsigned long a_end = a_start + PUD_SIZE;
>> +
>> +		/*
>> +		 * If sharing is possible, adjust start/end if necessary.
>> +		 *
>> +		 * Note that this is the same check used in vma_shareable.  If
>> +		 * you change one, consider changing both.
>> +		 */
>> +		if (vma->vm_start <= a_start && a_end <= vma->vm_end) {
>> +			if (a_start < *start)
>> +				*start = a_start;
>> +			if (a_end > *end)
>> +				*end = a_end;
>> +
>> +			ret = true;
>> +		}
>> +	}
>> +
>> +	return ret;
>> +}
>> +
