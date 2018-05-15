Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6E1216B0277
	for <linux-mm@kvack.org>; Tue, 15 May 2018 07:55:00 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g1-v6so13061928pfh.19
        for <linux-mm@kvack.org>; Tue, 15 May 2018 04:55:00 -0700 (PDT)
Received: from mx141.netapp.com (mx141.netapp.com. [2620:10a:4005:8000:2306::a])
        by mx.google.com with ESMTPS id r19-v6si8786258pgn.373.2018.05.15.04.54.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 04:54:59 -0700 (PDT)
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
 <20180514144901.0fe99d240ff8a53047dd512e@linux-foundation.org>
 <20180515004406.GB5168@bombadil.infradead.org>
From: Boaz Harrosh <boazh@netapp.com>
Message-ID: <cff721c3-65e8-c1e8-9f6d-c37ce6e56416@netapp.com>
Date: Tue, 15 May 2018 14:54:29 +0300
MIME-Version: 1.0
In-Reply-To: <20180515004406.GB5168@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jeff Moyer <jmoyer@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On 15/05/18 03:44, Matthew Wilcox wrote:
> On Mon, May 14, 2018 at 02:49:01PM -0700, Andrew Morton wrote:
>> On Mon, 14 May 2018 20:28:01 +0300 Boaz Harrosh <boazh@netapp.com> wrote:
>>> In this project we utilize a per-core server thread so everything
>>> is kept local. If we use the regular zap_ptes() API All CPU's
>>> are scheduled for the unmap, though in our case we know that we
>>> have only used a single core. The regular zap_ptes adds a very big
>>> latency on every operation and mostly kills the concurrency of the
>>> over all system. Because it imposes a serialization between all cores
>>
>> I'd have thought that in this situation, only the local CPU's bit is
>> set in the vma's mm_cpumask() and the remote invalidations are not
>> performed.  Is that a misunderstanding, or is all that stuff not working
>> correctly?
> 
> I think you misunderstand Boaz's architecture.  He has one thread per CPU,
> so every bit will be set in the mm's (not vma's) mm_cpumask.
> 

Hi Andrew, Matthew

Yes I have been trying to investigate and trace this for days.
Please see the code below:

> #define flush_tlb_range(vma, start, end)	\
> 		flush_tlb_mm_range(vma->vm_mm, start, end, vma->vm_flags)

The mm_struct @mm below comes from here vma->vm_mm

> diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
> index e055d1a..1d398a0 100644
> --- a/arch/x86/mm/tlb.c
> +++ b/arch/x86/mm/tlb.c
> @@ -611,39 +611,40 @@ static unsigned long tlb_single_page_flush_ceiling __read_mostly = 33;
>  void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
>  				unsigned long end, unsigned long vmflag)
>  {
>  	int cpu;
>  
>  	struct flush_tlb_info info __aligned(SMP_CACHE_BYTES) = {
>  		.mm = mm,
>  	};
>  
>  	cpu = get_cpu();
>  
>  	/* This is also a barrier that synchronizes with switch_mm(). */
>  	info.new_tlb_gen = inc_mm_tlb_gen(mm);
>  
>  	/* Should we flush just the requested range? */
>  	if ((end != TLB_FLUSH_ALL) &&
>  	    !(vmflag & VM_HUGETLB) &&
>  	    ((end - start) >> PAGE_SHIFT) <= tlb_single_page_flush_ceiling) {
>  		info.start = start;
>  		info.end = end;
>  	} else {
>  		info.start = 0UL;
>  		info.end = TLB_FLUSH_ALL;
>  	}
>  
>  	if (mm == this_cpu_read(cpu_tlbstate.loaded_mm)) {
>  		VM_WARN_ON(irqs_disabled());
>  		local_irq_disable();
>  		flush_tlb_func_local(&info, TLB_LOCAL_MM_SHOOTDOWN);
>  		local_irq_enable();
>  	}
>  
> -	if (cpumask_any_but(mm_cpumask(mm), cpu) < nr_cpu_ids)
> +	if (!(vmflag & VM_LOCAL_CPU) &&
> +	    cpumask_any_but(mm_cpumask(mm), cpu) < nr_cpu_ids)
>  		flush_tlb_others(mm_cpumask(mm), &info);
>  

I have been tracing the mm_cpumask(vma->vm_mm) at my driver at
different points. At vma creation (file_operations->mmap()), 
and before the call to insert_pfn (which calls here).

At the beginning I was wishful thinking that the mm_cpumask(vma->vm_mm)
should have a single bit set just as the affinity of the thread on
creation of that thread. But then I saw that at %80 of the times some
other random bits are also set.

Yes Random. Always the thread affinity (single) bit was set but
then zero one or two more bits were set as well. Never seen more then
two though, which baffles me a lot.

If it was like Matthew said .i.e the cpumask of the all process
then I would expect all the bits to be set. Because I have a thread
on each core. And also I would even expect that all vma->vm_mm
or maybe mm_cpumask(vma->vm_mm) to point to the same global object.
But it was not so. it was pointing to some thread unique object but
still those phantom bits were set all over. (And I am almost sure
same vma had those bits change over time)

So I would love some mm guy to explain where are those bits collected?
But I do not think this is a Kernel bug because as Matthew showed.
that vma above can and is allowed to leak memory addresses to other
threads / cores in the same process. So it appears that the Kernel
has some correct logic behind its madness.

Which brings me to another question. How can I find from
within a thread Say at the file_operations->mmap() call that the thread
is indeed core-pinned. What mm_cpumask should I inspect?

>  	put_cpu();
>  }

Thanks
Boaz
