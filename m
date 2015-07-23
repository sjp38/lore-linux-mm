Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id C5C766B025F
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 10:41:25 -0400 (EDT)
Received: by igvi1 with SMTP id i1so15920747igv.1
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 07:41:25 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id o5si5567645ige.3.2015.07.23.07.41.24
        for <linux-mm@kvack.org>;
        Thu, 23 Jul 2015 07:41:25 -0700 (PDT)
Message-ID: <55B0FD14.8050501@intel.com>
Date: Thu, 23 Jul 2015 07:41:24 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Flush the TLB for a single address in a huge page
References: <1437585214-22481-1-git-send-email-catalin.marinas@arm.com> <alpine.DEB.2.10.1507221436350.21468@chino.kir.corp.google.com> <CAHkRjk7=VMG63VfZdWbZqYu8FOa9M+54Mmdro661E2zt3WToog@mail.gmail.com> <55B021B1.5020409@intel.com> <20150723104938.GA27052@e104818-lin.cambridge.arm.com> <20150723141303.GB23799@redhat.com>
In-Reply-To: <20150723141303.GB23799@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 07/23/2015 07:13 AM, Andrea Arcangeli wrote:
> On Thu, Jul 23, 2015 at 11:49:38AM +0100, Catalin Marinas wrote:
>> On Thu, Jul 23, 2015 at 12:05:21AM +0100, Dave Hansen wrote:
>>> On 07/22/2015 03:48 PM, Catalin Marinas wrote:
>>>> You are right, on x86 the tlb_single_page_flush_ceiling seems to be
>>>> 33, so for an HPAGE_SIZE range the code does a local_flush_tlb()
>>>> always. I would say a single page TLB flush is more efficient than a
>>>> whole TLB flush but I'm not familiar enough with x86.
>>>
>>> The last time I looked, the instruction to invalidate a single page is
>>> more expensive than the instruction to flush the entire TLB. 
>>
>> I was thinking of the overall cost of re-populating the TLB after being
>> nuked rather than the instruction itself.
> 
> Unless I'm not aware about timing differences in flushing 2MB TLB
> entries vs flushing 4kb TLB entries with invlpg, the benchmarks that
> have been run to tune the optimal tlb_single_page_flush_ceiling value,
> should already guarantee us that this is a valid optimization (as we
> just got one entry, we're not even close to the 33 ceiling that makes
> it more a grey area).

We had a discussion about this a few weeks ago:

	https://lkml.org/lkml/2015/6/25/666

The argument is that the CPU is so good at refilling the TLB that it
rarely waits on it, so the "cost" can be very very low.

>>> That said, I can't imagine this will hurt anything.  We also have TLBs
>>> that can mix 2M and 4k pages and I don't think we did back when we put
>>> that code in originally.
> 
> Dave, I'm confused about this. We should still stick to an invariant
> that we can't ever mix 2M and 4k TLB entries if their mappings end up
> overlapping on the same physical memory (if this isn't enforced in
> common code, some x86 implementation errata triggers, and it really
> oopses with machine checks so it's not just theoretical). Perhaps I
> misunderstood what you meant with mix 2M and 4k pages though.

On older CPUs we had dedicated 2M TLB slots.  Now, we have an STLB that
can hold 2M and 4k entries at the same time.  That will surely change
the performance profile enough that whatever testing we did in the past
is fairly stale now.

I didn't mean mixing 4k and 2M mappings for the same virtual address.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
