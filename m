Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id F27196B0005
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 16:47:52 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id n21-v6so3912592plp.9
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 13:47:52 -0700 (PDT)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id 3-v6si5885197pgm.37.2018.08.03.13.47.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 13:47:51 -0700 (PDT)
Subject: Re: [RFC v6 PATCH 1/2] mm: refactor do_munmap() to extract the common
 part
References: <1532628614-111702-1-git-send-email-yang.shi@linux.alibaba.com>
 <1532628614-111702-2-git-send-email-yang.shi@linux.alibaba.com>
 <20180803085335.GH27245@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <7b84088a-4e49-ed7c-e750-7aba5cc17f11@linux.alibaba.com>
Date: Fri, 3 Aug 2018 13:47:19 -0700
MIME-Version: 1.0
In-Reply-To: <20180803085335.GH27245@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 8/3/18 1:53 AM, Michal Hocko wrote:
> On Fri 27-07-18 02:10:13, Yang Shi wrote:
>> Introduces three new helper functions:
>>    * munmap_addr_sanity()
>>    * munmap_lookup_vma()
>>    * munmap_mlock_vma()
>>
>> They will be used by do_munmap() and the new do_munmap with zapping
>> large mapping early in the later patch.
>>
>> There is no functional change, just code refactor.
>>
>> Reviewed-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> ---
>>   mm/mmap.c | 120 ++++++++++++++++++++++++++++++++++++++++++--------------------
>>   1 file changed, 82 insertions(+), 38 deletions(-)
>>
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index d1eb87e..2504094 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -2686,34 +2686,44 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
>>   	return __split_vma(mm, vma, addr, new_below);
>>   }
>>   
>> -/* Munmap is split into 2 main parts -- this part which finds
>> - * what needs doing, and the areas themselves, which do the
>> - * work.  This now handles partial unmappings.
>> - * Jeremy Fitzhardinge <jeremy@goop.org>
>> - */
>> -int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>> -	      struct list_head *uf)
>> +static inline bool munmap_addr_sanity(unsigned long start, size_t len)
> munmap_check_addr? Btw. why does this need to have munmap prefix at all?
> This is a general address space check.

Just because I extracted this from do_munmap, no special consideration. 
It is definitely ok to use another name.

>
>>   {
>> -	unsigned long end;
>> -	struct vm_area_struct *vma, *prev, *last;
>> -
>>   	if ((offset_in_page(start)) || start > TASK_SIZE || len > TASK_SIZE-start)
>> -		return -EINVAL;
>> +		return false;
>>   
>> -	len = PAGE_ALIGN(len);
>> -	if (len == 0)
>> -		return -EINVAL;
>> +	if (PAGE_ALIGN(len) == 0)
>> +		return false;
>> +
>> +	return true;
>> +}
>> +
>> +/*
>> + * munmap_lookup_vma: find the first overlap vma and split overlap vmas.
>> + * @mm: mm_struct
>> + * @vma: the first overlapping vma
>> + * @prev: vma's prev
>> + * @start: start address
>> + * @end: end address
> This really doesn't help me to understand how to use the function.
> Why do we need both prev and vma etc...

prev will be used by unmap_region later.

>
>> + *
>> + * returns 1 if successful, 0 or errno otherwise
> This is a really weird calling convention. So what does 0 tell? /me
> checks the code. Ohh, it is nothing to do. Why cannot you simply return
> the vma. NULL implies nothing to do, ERR_PTR on error.

A couple of reasons why it is implemented as so:

 A A A  * do_munmap returns 0 for both success and no suitable vma

 A A A  * Since prev is needed by finding the start vma, and prev will be 
used by unmap_region later too, so I just thought it would look clean to 
have one function to return both start vma and prev. In this way, we can 
share as much as possible common code.

 A A A  * In this way, we just need return 0, 1 or error no just as same as 
what do_munmap does currently. Then we know what is failure case exactly 
to just bail out right away.

Actually, I tried the same approach as you suggested, but it had two 
problems:

 A A A  * If it returns the start vma, we have to re-find its prev later, 
but the prev has been found during finding start vma. And, duplicate the 
code in do_munmap_zap_rlock. It sounds not that ideal.

 A A A  * If it returns prev, it might be null (start vma is the first 
vma). We can't tell if null is a failure or success case

>
>> + */
>> +static int munmap_lookup_vma(struct mm_struct *mm, struct vm_area_struct **vma,
>> +			     struct vm_area_struct **prev, unsigned long start,
>> +			     unsigned long end)
>> +{
>> +	struct vm_area_struct *tmp, *last;
>>   
>>   	/* Find the first overlapping VMA */
>> -	vma = find_vma(mm, start);
>> -	if (!vma)
>> +	tmp = find_vma(mm, start);
>> +	if (!tmp)
>>   		return 0;
>> -	prev = vma->vm_prev;
>> -	/* we have  start < vma->vm_end  */
>> +
>> +	*prev = tmp->vm_prev;
> Why do you set prev here. We might "fail" with 0 right after this

No special reason, just copied from do_munmap. Yes, it is ideal to have 
prev set here. It can be moved further down.

>
>> +
>> +	/* we have start < vma->vm_end  */
>>   
>>   	/* if it doesn't overlap, we have nothing.. */
>> -	end = start + len;
>> -	if (vma->vm_start >= end)
>> +	if (tmp->vm_start >= end)
>>   		return 0;
>>   
>>   	/*
>> @@ -2723,7 +2733,7 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>>   	 * unmapped vm_area_struct will remain in use: so lower split_vma
>>   	 * places tmp vma above, and higher split_vma places tmp vma below.
>>   	 */
>> -	if (start > vma->vm_start) {
>> +	if (start > tmp->vm_start) {
>>   		int error;
>>   
>>   		/*
>> @@ -2731,13 +2741,14 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>>   		 * not exceed its limit; but let map_count go just above
>>   		 * its limit temporarily, to help free resources as expected.
>>   		 */
>> -		if (end < vma->vm_end && mm->map_count >= sysctl_max_map_count)
>> +		if (end < tmp->vm_end &&
>> +		    mm->map_count > sysctl_max_map_count)
>>   			return -ENOMEM;
>>   
>> -		error = __split_vma(mm, vma, start, 0);
>> +		error = __split_vma(mm, tmp, start, 0);
>>   		if (error)
>>   			return error;
>> -		prev = vma;
>> +		*prev = tmp;
>>   	}
>>   
>>   	/* Does it split the last one? */
>> @@ -2747,7 +2758,48 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>>   		if (error)
>>   			return error;
>>   	}
>> -	vma = prev ? prev->vm_next : mm->mmap;
>> +
>> +	*vma = *prev ? (*prev)->vm_next : mm->mmap;
>> +
>> +	return 1;
>> +}
> the patch would be much more easier to read if you didn't do vma->tmp
> renaming.

Yes, I should used another name for the "vma" argument.

Thanks,
Yang
