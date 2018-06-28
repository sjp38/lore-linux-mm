Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 383506B0005
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 10:39:22 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u7-v6so3074061wrr.22
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 07:39:22 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a23-v6si6040227wmb.21.2018.06.28.07.39.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jun 2018 07:39:20 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5SEd6xG028823
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 10:39:18 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jw1c6gx9m-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 10:39:17 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 28 Jun 2018 15:39:14 +0100
Subject: Re: [PATCH/RFC] mm: do not drop unused pages when userfaultd is
 running
References: <20180628123916.96106-1-borntraeger@de.ibm.com>
 <df95ae10-0c78-0d76-d2bb-c91712c145ea@redhat.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Thu, 28 Jun 2018 16:39:09 +0200
MIME-Version: 1.0
In-Reply-To: <df95ae10-0c78-0d76-d2bb-c91712c145ea@redhat.com>
Content-Language: en-US
Message-Id: <1e470063-d56c-0a76-7a7f-2c0f0e87824b@de.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, linux-s390@vger.kernel.org
Cc: kvm@vger.kernel.org, Janosch Frank <frankja@linux.ibm.com>, Cornelia Huck <cohuck@redhat.com>, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>



On 06/28/2018 03:18 PM, David Hildenbrand wrote:
> On 28.06.2018 14:39, Christian Borntraeger wrote:
>> KVM guests on s390 can notify the host of unused pages. This can result
>> in pte_unused callbacks to be true for KVM guest memory.
>>
>> If a page is unused (checked with pte_unused) we might drop this page
>> instead of paging it. This can have side-effects on userfaultd, when the
>> page in question was already migrated:
>>
>> The next access of that page will trigger a fault and a user fault
>> instead of faulting in a new and empty zero page. As QEMU does not
>> expect a userfault on an already migrated page this migration will fail.
>>
>> The most straightforward solution is to ignore the pte_unused hint if a
>> userfault context is active for this VMA.
>>
>> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: stable@vger.kernel.org
>> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
>> ---
>>  mm/rmap.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index 6db729dc4c50..3f3a72aa99f2 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -1481,7 +1481,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>>  				set_pte_at(mm, address, pvmw.pte, pteval);
>>  			}
>>  
>> -		} else if (pte_unused(pteval)) {
>> +		} else if (pte_unused(pteval) && !vma->vm_userfaultfd_ctx.ctx) {
>>  			/*
>>  			 * The guest indicated that the page content is of no
>>  			 * interest anymore. Simply discard the pte, vmscan
>>
> 
> To understand the implications better:
> 
> This is like a MADV_DONTNEED from user space while a userfaultfd
> notifier is registered for this vma range.
> 
> While we can block such calls in QEMU ("we registered it, we know it
> best"), we can't do the same in the kernel.
> 
> These "intern MADV_DONTNEED" can actually trigger "deferred", so e.g. if
> the pte_unused() was set before userfaultfd has been registered, we can
> still get the same result, right?

Not sure I understand your last sentence.
This place here is called on the unmap, (e.g. when the host tries to page out).
The value was transferred before (and always before) during the page table invalidation.
So pte_unused was always set before. This is the place where we decide if we page
out (ans establish a swap pte) or just drop this page table entry. So if
no userfaultd is registered at that point in time we are good.
