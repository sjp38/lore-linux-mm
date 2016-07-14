Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 39A7D6B025F
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 09:32:16 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id q2so133364380pap.1
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 06:32:16 -0700 (PDT)
Received: from out01.mta.xmission.com (out01.mta.xmission.com. [166.70.13.231])
        by mx.google.com with ESMTPS id r5si4478776pfr.51.2016.07.14.06.32.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jul 2016 06:32:15 -0700 (PDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <1468299403-27954-1-git-send-email-zhongjiang@huawei.com>
	<1468299403-27954-2-git-send-email-zhongjiang@huawei.com>
	<87a8hm3lme.fsf@x220.int.ebiederm.org> <5785E764.8050304@huawei.com>
Date: Thu, 14 Jul 2016 08:19:21 -0500
In-Reply-To: <5785E764.8050304@huawei.com> (zhong jiang's message of "Wed, 13
	Jul 2016 15:01:56 +0800")
Message-ID: <87vb08ich2.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH 2/2] kexec: add a pmd huge entry condition during the page table
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: dyoung@redhat.com, horms@verge.net.au, vgoyal@redhat.com, yinghai@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, kexec@lists.infradead.org

zhong jiang <zhongjiang@huawei.com> writes:

> On 2016/7/12 23:46, Eric W. Biederman wrote:
>> zhongjiang <zhongjiang@huawei.com> writes:
>>
>>> From: zhong jiang <zhongjiang@huawei.com>
>>>
>>> when image is loaded into kernel, we need set up page table for it. and 
>>> all valid pfn also set up new mapping. it will tend to establish a pmd 
>>> page table in the form of a large page if pud_present is true. relocate_kernel 
>>> points to code segment can locate in the pmd huge entry in init_transtion_pgtable. 
>>> therefore, we need to take the situation into account.
>> I can see how in theory this might be necessary but when is a kernel virtual
>> address on x86_64 that is above 0x8000000000000000 in conflict with an
>> identity mapped physicall address that are all below 0x8000000000000000?
>>
>> If anything the code could be simplified to always assume those mappings
>> are unoccupied.
>>
>> Did you run into an actual failure somewhere?
>>
>> Eric
>>
>    I  do not understand what you trying to say,  Maybe I miss your point.
>   
>   The key is how to ensure that relocate_kernel points to the pmd
>   entry is not huge page.

Kernel virtual addresses are in the negative half of the address space.
Identity mapped physical addresses are in the positive half of the
address space.

As the entire negative half of the address space at the time that page
table entry is being created the are no huge pages present.

Even testing pmd_present is a redundant, and that is probably the bug.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
