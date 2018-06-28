Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6A4A56B000A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 10:49:39 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id d14-v6so5814292qtn.3
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 07:49:39 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id i14-v6si1969827qvj.89.2018.06.28.07.49.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jun 2018 07:49:38 -0700 (PDT)
Subject: Re: [PATCH/RFC] mm: do not drop unused pages when userfaultd is
 running
References: <20180628123916.96106-1-borntraeger@de.ibm.com>
 <df95ae10-0c78-0d76-d2bb-c91712c145ea@redhat.com>
 <1e470063-d56c-0a76-7a7f-2c0f0e87824b@de.ibm.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <eca5be20-6c3a-5d9b-152a-f4e8b61b810e@redhat.com>
Date: Thu, 28 Jun 2018 16:49:35 +0200
MIME-Version: 1.0
In-Reply-To: <1e470063-d56c-0a76-7a7f-2c0f0e87824b@de.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-s390@vger.kernel.org
Cc: kvm@vger.kernel.org, Janosch Frank <frankja@linux.ibm.com>, Cornelia Huck <cohuck@redhat.com>, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>

On 28.06.2018 16:39, Christian Borntraeger wrote:
> 
> 
> On 06/28/2018 03:18 PM, David Hildenbrand wrote:
>> On 28.06.2018 14:39, Christian Borntraeger wrote:
>>> KVM guests on s390 can notify the host of unused pages. This can result
>>> in pte_unused callbacks to be true for KVM guest memory.
>>>
>>> If a page is unused (checked with pte_unused) we might drop this page
>>> instead of paging it. This can have side-effects on userfaultd, when the
>>> page in question was already migrated:
>>>
>>> The next access of that page will trigger a fault and a user fault
>>> instead of faulting in a new and empty zero page. As QEMU does not
>>> expect a userfault on an already migrated page this migration will fail.
>>>
>>> The most straightforward solution is to ignore the pte_unused hint if a
>>> userfault context is active for this VMA.
>>>
>>> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>>> Cc: stable@vger.kernel.org
>>> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
>>> ---
>>>  mm/rmap.c | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/mm/rmap.c b/mm/rmap.c
>>> index 6db729dc4c50..3f3a72aa99f2 100644
>>> --- a/mm/rmap.c
>>> +++ b/mm/rmap.c
>>> @@ -1481,7 +1481,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>>>  				set_pte_at(mm, address, pvmw.pte, pteval);
>>>  			}
>>>  
>>> -		} else if (pte_unused(pteval)) {
>>> +		} else if (pte_unused(pteval) && !vma->vm_userfaultfd_ctx.ctx) {
>>>  			/*
>>>  			 * The guest indicated that the page content is of no
>>>  			 * interest anymore. Simply discard the pte, vmscan
>>>
>>
>> To understand the implications better:
>>
>> This is like a MADV_DONTNEED from user space while a userfaultfd
>> notifier is registered for this vma range.
>>
>> While we can block such calls in QEMU ("we registered it, we know it
>> best"), we can't do the same in the kernel.
>>
>> These "intern MADV_DONTNEED" can actually trigger "deferred", so e.g. if
>> the pte_unused() was set before userfaultfd has been registered, we can
>> still get the same result, right?>
> Not sure I understand your last sentence.

Rephrased: Instead trying to stop somebody from setting pte_unused will
not work, as we might get a userfaultfd registration at some point and
find a previously set pte_unused afterwards. But I think you guessed
correctly what I meant :)

> This place here is called on the unmap, (e.g. when the host tries to page out).
> The value was transferred before (and always before) during the page table invalidation.
> So pte_unused was always set before. This is the place where we decide if we page
> out (ans establish a swap pte) or just drop this page table entry. So if
> no userfaultd is registered at that point in time we are good.

This certainly applies to ordinary userfaultfd we have right now.
userfaultfd WP (write-protect) or other features to come might be
different, but it does not seem to do any harm in case we page out
instead of dropping it. This way we are on the safe side.

In other words: I think this is the right approach.


-- 

Thanks,

David / dhildenb
