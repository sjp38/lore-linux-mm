Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id B55B56B0037
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 17:34:22 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id eu11so1381171pac.11
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 14:34:22 -0700 (PDT)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id gr3si42794766pbb.210.2014.06.12.14.34.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 14:34:21 -0700 (PDT)
Message-ID: <539A1CDA.5000709@hp.com>
Date: Thu, 12 Jun 2014 17:34:18 -0400
From: Waiman Long <waiman.long@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Move __vma_address() to internal.h to be inlined
 in huge_memory.c
References: <1402600540-52031-1-git-send-email-Waiman.Long@hp.com> <20140612122546.cfdebdb22bb22c0f767e30b5@linux-foundation.org>
In-Reply-To: <20140612122546.cfdebdb22bb22c0f767e30b5@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Scott J Norton <scott.norton@hp.com>

On 06/12/2014 03:25 PM, Andrew Morton wrote:
> On Thu, 12 Jun 2014 15:15:40 -0400 Waiman Long<Waiman.Long@hp.com>  wrote:
>
>> The vma_address() function which is used to compute the virtual address
>> within a VMA is used only by 2 files in the mm subsystem - rmap.c and
>> huge_memory.c. This function is defined in rmap.c and is inlined by
>> its callers there, but it is also declared as an external function.
>>
>> However, the __split_huge_page() function which calls vma_address()
>> in huge_memory.c is calling it as a real function call. This is not
>> as efficient as an inlined function. This patch moves the underlying
>> inlined __vma_address() function to internal.h to be shared by both
>> the rmap.c and huge_memory.c file.
> This increases huge_memory.o's text+data_bss by 311 bytes, which makes
> me suspect that it is a bad change due to its increase of kernel cache
> footprint.
>
> Perhaps we should be noinlining __vma_address()?

On my test machine, I saw an increase of 144 bytes in the text segment
of huge_memory.o. The size in size is caused by an increase in the size
of the __split_huge_page function. When I remove the

         if (unlikely(is_vm_hugetlb_page(vma)))
                 pgoff = page->index << huge_page_order(page_hstate(page));

check, the increase in size drops down to 24 bytes. As a THP cannot be
a hugetlb page, there is no point in doing this check for a THP. I will
update the patch to pass in an additional argument to disable this
check for __split_huge_page.

-Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
