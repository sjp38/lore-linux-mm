Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 52C716B0003
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 11:40:02 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id d1so2129738qtn.12
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 08:40:02 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id f62si1653929qkj.162.2018.03.07.08.39.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 08:39:57 -0800 (PST)
Subject: Re: [Bug 199037] New: Kernel bug at mm/hugetlb.c:741
From: Mike Kravetz <mike.kravetz@oracle.com>
References: <bug-199037-27@https.bugzilla.kernel.org/>
 <20180306133135.4dc344e478d98f0e29f47698@linux-foundation.org>
 <7ffa77c8-8624-9c69-d1f5-058ef22c460c@oracle.com>
 <ecc197fa-ae01-8be8-55ec-e82eb1050f57@oracle.com>
 <f91575ec-d158-8876-0096-63a19f0289e0@oracle.com>
Message-ID: <0d893023-11c0-f3be-94d4-f17bf3f30195@oracle.com>
Date: Wed, 7 Mar 2018 08:39:45 -0800
MIME-Version: 1.0
In-Reply-To: <f91575ec-d158-8876-0096-63a19f0289e0@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, blurbdust@gmail.com

On 03/06/2018 08:19 PM, Mike Kravetz wrote:
> On 03/06/2018 04:31 PM, Mike Kravetz wrote:
>> On 03/06/2018 01:46 PM, Mike Kravetz wrote:
>>> On 03/06/2018 01:31 PM, Andrew Morton wrote:
>>>>
>>>> That's VM_BUG_ON(resv_map->adds_in_progress) in resv_map_release().
>>>>
>>>> Do you know if earlier kernel versions are affected?
>>>>
>>>> It looks quite bisectable.  Does the crash happen every time the test
>>>> program is run?
>>>
>>> I'll take a look.  There was a previous bug in this area:
>>> ff8c0c53: mm/hugetlb.c: don't call region_abort if region_chg fails
>>
>> This is similar to the issue addressed in 045c7a3f ("fix offset overflow
>> in hugetlbfs mmap").  The problem here is that the pgoff argument passed
>> to remap_file_pages() is 0x20000000000000.  In the process of converting
>> this to a page offset and putting it in vm_pgoff, and then converting back
>> to bytes to compute mapping length we end up with 0.  We ultimately end
>> up passing (from,to) page offsets into hugetlbfs where from is greater
>> than to. :( This confuses the heck out the the huge page reservation code
>> as the 'negative' range looks like an error and we never complete the
>> reservation process and leave the 'adds_in_progress'.
>>
>> This issue has existed for a long time.  The VM_BUG_ON just happens to
>> catch the situation which was previously not reported or had some other
>> side effect.  Commit 045c7a3f tried to catch these overflow issues when
>> converting types, but obviously missed this one.  I can easily add a test
>> for this specific value/condition, but want to think about it a little
>> more and see if there is a better way to catch all of these.
> 
> Well, I instrumented hugetlbfs_file_mmap when called via the remap_file_pages
> system call path.  Upon entry, vma->vm_pgoff is 0x20000000000000 which is
> the same as the value of the argument pgoff passed to the system call.
> vm_pgoff really should be a page offset (i.e. 0x20000000000000 >> PAGE_SHIFT).
> So, there is also an issue earlier in the remap_file_pages system call
> sequence.

My mistake.  The pgoff argument to remap_file_pages is a page offset in page
size units.  So, there should be no '>> PAGE_SHIFT' of the argument.

The hugetlbfs code wants to convert vm_pgoff to a byte offset by
'<< PAGE_SHIFT'.  This is what overflows and gets us into trouble.

My first thought is to simply check for this overflow in remap_file_pages.
Other code within the kernel converts vm_pgoff to a byte offset and I am
not sure they could handle/expect an overflow.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
