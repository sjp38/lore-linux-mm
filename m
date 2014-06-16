Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f48.google.com (mail-oa0-f48.google.com [209.85.219.48])
	by kanga.kvack.org (Postfix) with ESMTP id 7DEC46B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 15:34:51 -0400 (EDT)
Received: by mail-oa0-f48.google.com with SMTP id m1so6276686oag.7
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 12:34:51 -0700 (PDT)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id h8si16831287obe.74.2014.06.16.12.34.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 12:34:50 -0700 (PDT)
Message-ID: <539F46D7.6050502@hp.com>
Date: Mon, 16 Jun 2014 15:34:47 -0400
From: Waiman Long <waiman.long@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Move __vma_address() to internal.h to be inlined
 in huge_memory.c
References: <1402600540-52031-1-git-send-email-Waiman.Long@hp.com> <20140612122546.cfdebdb22bb22c0f767e30b5@linux-foundation.org> <539A1CDA.5000709@hp.com> <alpine.DEB.2.02.1406121444140.12437@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1406121444140.12437@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Scott J Norton <scott.norton@hp.com>

On 06/12/2014 05:45 PM, David Rientjes wrote:
> On Thu, 12 Jun 2014, Waiman Long wrote:
>
>>>> The vma_address() function which is used to compute the virtual address
>>>> within a VMA is used only by 2 files in the mm subsystem - rmap.c and
>>>> huge_memory.c. This function is defined in rmap.c and is inlined by
>>>> its callers there, but it is also declared as an external function.
>>>>
>>>> However, the __split_huge_page() function which calls vma_address()
>>>> in huge_memory.c is calling it as a real function call. This is not
>>>> as efficient as an inlined function. This patch moves the underlying
>>>> inlined __vma_address() function to internal.h to be shared by both
>>>> the rmap.c and huge_memory.c file.
>>> This increases huge_memory.o's text+data_bss by 311 bytes, which makes
>>> me suspect that it is a bad change due to its increase of kernel cache
>>> footprint.
>>>
>>> Perhaps we should be noinlining __vma_address()?
>> On my test machine, I saw an increase of 144 bytes in the text segment
>> of huge_memory.o. The size in size is caused by an increase in the size
>> of the __split_huge_page function. When I remove the
>>
>>          if (unlikely(is_vm_hugetlb_page(vma)))
>>                  pgoff = page->index<<  huge_page_order(page_hstate(page));
>>
>> check, the increase in size drops down to 24 bytes. As a THP cannot be
>> a hugetlb page, there is no point in doing this check for a THP. I will
>> update the patch to pass in an additional argument to disable this
>> check for __split_huge_page.
>>
> I think we're seeking a reason or performance numbers that suggest
> __vma_address() being inline is appropriate and so far we lack any such
> evidence.  Adding additional parameters to determine checks isn't going to
> change the fact that it increases text size needlessly.

This patch was motivated by my investigation of a freeze problem of an 
application running on SLES11 sp3 which was caused by the long time it 
took to munmap part of a THP. Inlining vma_address help a bit in that 
situation. However, the problem will be essentially gone after including 
patches that changing the anon_vma_chain to use rbtree instead of a 
simple list.

I do agree that performance impact of inlining vma_address in minimal in 
the latest kernel. So I am not going to pursue this any further.

Thank for the review.

-Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
