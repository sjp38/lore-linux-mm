Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 86F2E6B03CE
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 17:31:16 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k14so1008286wrc.16
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 14:31:16 -0700 (PDT)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id v23si16746033wrv.127.2017.04.11.14.31.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Apr 2017 14:31:15 -0700 (PDT)
Subject: Re: [PATCH] mm/migrate: check for null vma before dereferencing it
References: <20170411125102.19497-1-colin.king@canonical.com>
 <20170411142633.d01ba0aaeb3e6075d517208c@linux-foundation.org>
From: Colin Ian King <colin.king@canonical.com>
Message-ID: <c105740f-4430-c0fe-28fe-8bc4ef8ac64d@canonical.com>
Date: Tue, 11 Apr 2017 22:31:12 +0100
MIME-Version: 1.0
In-Reply-To: <20170411142633.d01ba0aaeb3e6075d517208c@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

On 11/04/17 22:26, Andrew Morton wrote:
> On Tue, 11 Apr 2017 13:51:02 +0100 Colin King <colin.king@canonical.com> wrote:
> 
>> From: Colin Ian King <colin.king@canonical.com>
>>
>> check if vma is null before dereferencing it, this avoiding any
>> potential null pointer dereferences on vma via the is_vm_hugetlb_page
>> call or the direct vma->vm_flags reference.
>>
>> Detected with CoverityScan, CID#1427995 ("Dereference before null check")
>>
>> ...
>>
>> --- a/mm/migrate.c
>> +++ b/mm/migrate.c
>> @@ -2757,10 +2757,10 @@ int migrate_vma(const struct migrate_vma_ops *ops,
>>  	/* Sanity check the arguments */
>>  	start &= PAGE_MASK;
>>  	end &= PAGE_MASK;
>> -	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL))
>> -		return -EINVAL;
>>  	if (!vma || !ops || !src || !dst || start >= end)
>>  		return -EINVAL;
>> +	if (is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_SPECIAL))
>> +		return -EINVAL;
>>  	if (start < vma->vm_start || start >= vma->vm_end)
>>  		return -EINVAL;
>>  	if (end <= vma->vm_start || end > vma->vm_end)
> 
> I don't know what kernel version this is against but I don't think it's
> anything recent?

I should have said it was against linux-next
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
