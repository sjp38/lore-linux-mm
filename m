Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 77E658E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 12:05:50 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i6-v6so3047039pfo.18
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 09:05:50 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id w3-v6si2260301plz.333.2018.09.27.09.05.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 09:05:49 -0700 (PDT)
Subject: Re: [v2 PATCH 1/2 -mm] mm: mremap: dwongrade mmap_sem to read when
 shrinking
References: <1537985434-22655-1-git-send-email-yang.shi@linux.alibaba.com>
 <8c04afa9-45c2-be18-c084-058add73c978@suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <60c0544d-917f-89e1-2806-80c1beb830a0@linux.alibaba.com>
Date: Thu, 27 Sep 2018 09:04:55 -0700
MIME-Version: 1.0
In-Reply-To: <8c04afa9-45c2-be18-c084-058add73c978@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, mhocko@kernel.org, kirill@shutemov.name, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 9/27/18 4:50 AM, Vlastimil Babka wrote:
> On 9/26/18 8:10 PM, Yang Shi wrote:
>> Subject: [v2 PATCH 1/2 -mm] mm: mremap: dwongrade mmap_sem to read
> when shrinking
>
> "downgrade" in the subject

Will fix in the next version.

Thanks,
Yang

>
>> Other than munmap, mremap might be used to shrink memory mapping too.
>> So, it may hold write mmap_sem for long time when shrinking large
>> mapping, as what commit ("mm: mmap: zap pages with read mmap_sem in
>> munmap") described.
>>
>> The mremap() will not manipulate vmas anymore after __do_munmap() call for
>> the mapping shrink use case, so it is safe to downgrade to read mmap_sem.
>>
>> So, the same optimization, which downgrades mmap_sem to read for zapping
>> pages, is also feasible and reasonable to this case.
>>
>> The period of holding exclusive mmap_sem for shrinking large mapping
>> would be reduced significantly with this optimization.
>>
>> MREMAP_FIXED and MREMAP_MAYMOVE are more complicated to adopt this
>> optimization since they need manipulate vmas after do_munmap(),
>> downgrading mmap_sem may create race window.
>>
>> Simple mapping shrink is the low hanging fruit, and it may cover the
>> most cases of unmap with munmap together.
>>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Cc: Kirill A. Shutemov <kirill@shutemov.name>
>> Cc: Matthew Wilcox <willy@infradead.org>
>> Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> Looks fine,
>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>
> Nit:
>
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -2687,8 +2687,8 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
>>    * work.  This now handles partial unmappings.
>>    * Jeremy Fitzhardinge <jeremy@goop.org>
>>    */
>> -static int __do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>> -		       struct list_head *uf, bool downgrade)
>> +int __do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>> +		struct list_head *uf, bool downgrade)
>>   {
>>   	unsigned long end;
>>   	struct vm_area_struct *vma, *prev, *last;
>> diff --git a/mm/mremap.c b/mm/mremap.c
>> index 5c2e185..8f1ec2b 100644
>> --- a/mm/mremap.c
>> +++ b/mm/mremap.c
>> @@ -525,6 +525,7 @@ static int vma_expandable(struct vm_area_struct *vma, unsigned long delta)
>>   	unsigned long ret = -EINVAL;
>>   	unsigned long charged = 0;
>>   	bool locked = false;
>> +	bool downgrade = false;
> Maybe "downgraded" is more accurate here, or even "downgraded_mmap_sem".
