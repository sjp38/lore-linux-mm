Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3F86B0005
	for <linux-mm@kvack.org>; Fri, 10 Aug 2018 14:24:11 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id g5-v6so4895806pgq.5
        for <linux-mm@kvack.org>; Fri, 10 Aug 2018 11:24:11 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id i5-v6si7472499plt.112.2018.08.10.11.24.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Aug 2018 11:24:10 -0700 (PDT)
Subject: Re: [RFC v7 PATCH 1/4] mm: refactor do_munmap() to extract the common
 part
References: <1533857763-43527-1-git-send-email-yang.shi@linux.alibaba.com>
 <1533857763-43527-2-git-send-email-yang.shi@linux.alibaba.com>
 <20180810174150.GA6487@bombadil.infradead.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <30ee3dd0-a794-1c93-dd22-5c643a9037a6@linux.alibaba.com>
Date: Fri, 10 Aug 2018 11:23:45 -0700
MIME-Version: 1.0
In-Reply-To: <20180810174150.GA6487@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: mhocko@kernel.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, vbabka@suse.cz, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 8/10/18 10:41 AM, Matthew Wilcox wrote:
> On Fri, Aug 10, 2018 at 07:36:00AM +0800, Yang Shi wrote:
>> +static inline bool addr_ok(unsigned long start, size_t len)
> Maybe munmap_range_ok()?  Otherwise some of the conditions here don't make
> sense for such a generic sounding function.

I don't know. I think the argument is about munmap_ prefix should be used.

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
>> + * @start: start address
>> + * @end: end address
>> + *
>> + * returns the pointer to vma, NULL or err ptr when spilt_vma returns error.
> kernel-doc prefers:
>
>   * Return: %NULL if no VMA overlaps this range.  An ERR_PTR if an
>   * overlapping VMA could not be split.  Otherwise a pointer to the first
>   * VMA which overlaps the range.

Ok, will fix it.

>
>> + */
>> +static struct vm_area_struct *munmap_lookup_vma(struct mm_struct *mm,
>> +			unsigned long start, unsigned long end)
>> +{
>> +	struct vm_area_struct *vma, *prev, *last;
>>   
>>   	/* Find the first overlapping VMA */
>>   	vma = find_vma(mm, start);
>>   	if (!vma)
>> -		return 0;
>> -	prev = vma->vm_prev;
>> -	/* we have  start < vma->vm_end  */
>> +		return NULL;
>>   
>> +	/* we have  start < vma->vm_end  */
> Can you remove the duplicate spaces here?

Sure

Thanks,
Yang
