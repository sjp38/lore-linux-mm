Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 16F066B025E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 12:30:02 -0400 (EDT)
Received: by mail-qk0-f175.google.com with SMTP id i4so8196059qkc.3
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 09:30:02 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 102si4522871qgo.126.2016.03.29.09.29.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Mar 2016 09:29:58 -0700 (PDT)
Subject: Re: [RFC PATCH 1/2] mm/hugetlbfs: Attempt PUD_SIZE mapping alignment
 if PMD sharing enabled
References: <1459213970-17957-1-git-send-email-mike.kravetz@oracle.com>
 <1459213970-17957-2-git-send-email-mike.kravetz@oracle.com>
 <024b01d1896e$2e600e70$8b202b50$@alibaba-inc.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <56FAAD70.1020806@oracle.com>
Date: Tue, 29 Mar 2016 09:29:36 -0700
MIME-Version: 1.0
In-Reply-To: <024b01d1896e$2e600e70$8b202b50$@alibaba-inc.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org
Cc: 'Hugh Dickins' <hughd@google.com>, 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'David Rientjes' <rientjes@google.com>, 'Dave Hansen' <dave.hansen@linux.intel.com>, 'Thomas Gleixner' <tglx@linutronix.de>, 'Ingo Molnar' <mingo@redhat.com>, "'H. Peter Anvin'" <hpa@zytor.com>, 'Catalin Marinas' <catalin.marinas@arm.com>, 'Will Deacon' <will.deacon@arm.com>, 'Steve Capper' <steve.capper@linaro.org>, 'Andrew Morton' <akpm@linux-foundation.org>

On 03/28/2016 08:50 PM, Hillf Danton wrote:
>>
>> When creating a hugetlb mapping, attempt PUD_SIZE alignment if the
>> following conditions are met:
>> - Address passed to mmap or shmat is NULL
>> - The mapping is flaged as shared
>> - The mapping is at least PUD_SIZE in length
>> If a PUD_SIZE aligned mapping can not be created, then fall back to a
>> huge page size mapping.
>>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>> ---
>>  fs/hugetlbfs/inode.c | 29 +++++++++++++++++++++++++++--
>>  1 file changed, 27 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
>> index 540ddc9..22b2e38 100644
>> --- a/fs/hugetlbfs/inode.c
>> +++ b/fs/hugetlbfs/inode.c
>> @@ -175,6 +175,17 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
>>  	struct vm_area_struct *vma;
>>  	struct hstate *h = hstate_file(file);
>>  	struct vm_unmapped_area_info info;
>> +	bool pud_size_align = false;
>> +	unsigned long ret_addr;
>> +
>> +	/*
>> +	 * If PMD sharing is enabled, align to PUD_SIZE to facilitate
>> +	 * sharing.  Only attempt alignment if no address was passed in,
>> +	 * flags indicate sharing and size is big enough.
>> +	 */
>> +	if (IS_ENABLED(CONFIG_ARCH_WANT_HUGE_PMD_SHARE) &&
>> +	    !addr && flags & MAP_SHARED && len >= PUD_SIZE)
>> +		pud_size_align = true;
>>
>>  	if (len & ~huge_page_mask(h))
>>  		return -EINVAL;
>> @@ -199,9 +210,23 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
>>  	info.length = len;
>>  	info.low_limit = TASK_UNMAPPED_BASE;
>>  	info.high_limit = TASK_SIZE;
>> -	info.align_mask = PAGE_MASK & ~huge_page_mask(h);
>> +	if (pud_size_align)
>> +		info.align_mask = PAGE_MASK & (PUD_SIZE - 1);
>> +	else
>> +		info.align_mask = PAGE_MASK & ~huge_page_mask(h);
>>  	info.align_offset = 0;
>> -	return vm_unmapped_area(&info);
>> +	ret_addr = vm_unmapped_area(&info);
>> +
>> +	/*
>> +	 * If failed with PUD_SIZE alignment, try again with huge page
>> +	 * size alignment.
>> +	 */
> 
> Can we avoid going another round as long as it is a file with
> the PUD page size?

Yes, that brings up a good point.

Since we only do PMD sharing with PMD_SIZE huge pages, that should be
part of the check as to whether we try PUD_SIZE alignment.  The initial
check should be expanded as follows:

if (IS_ENABLED(CONFIG_ARCH_WANT_HUGE_PMD_SHARE) && !addr &&
    flags & MAP_SHARED && huge_page_size(h) == PMD_SIZE && len >= PUD_SIZE)
	pud_size_align = true;

In that case, pud_size_align remains false and we do not retry.

-- 
Mike Kravetz

> 
> Hillf
>> +	if ((ret_addr & ~PAGE_MASK) && pud_size_align) {
>> +		info.align_mask = PAGE_MASK & ~huge_page_mask(h);
>> +		ret_addr = vm_unmapped_area(&info);
>> +	}
>> +
>> +	return ret_addr;
>>  }
>>  #endif
>>
>> --
>> 2.4.3
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
