Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id BA7286B0031
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 09:26:21 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id w7so10457597qcr.22
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 06:26:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id s39si7601655qgs.184.2014.04.01.06.26.20
        for <linux-mm@kvack.org>;
        Tue, 01 Apr 2014 06:26:21 -0700 (PDT)
Message-ID: <533ABE71.9090507@redhat.com>
Date: Tue, 01 Apr 2014 09:26:09 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86,mm: delay TLB flush after clearing accessed bit
References: <20140331113442.0d628362@annuminas.surriel.com> <20140401105318.GA2823@gmail.com> <533AB741.5080508@redhat.com> <20140401132037.GB7024@gmail.com>
In-Reply-To: <20140401132037.GB7024@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, shli@kernel.org, akpm@linux-foundation.org, hughd@google.com, mgorman@suse.de, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>

On 04/01/2014 09:20 AM, Ingo Molnar wrote:
> 
> * Rik van Riel <riel@redhat.com> wrote:
> 
>>>>  int ptep_clear_flush_young(struct vm_area_struct *vma,
>>>>  			   unsigned long address, pte_t *ptep)
>>>>  {
>>>> -	int young;
>>>> +	int young, cpu;
>>>>  
>>>>  	young = ptep_test_and_clear_young(vma, address, ptep);
>>>> -	if (young)
>>>> -		flush_tlb_page(vma, address);
>>>> +	if (young) {
>>>> +		for_each_cpu(cpu, vma->vm_mm->cpu_vm_mask_var)
>>>> +			tlb_set_force_flush(cpu);
>>>
>>> Hm, just to play the devil's advocate - what happens when we have 
>>> a va that is used on a few dozen, a few hundred or a few thousand 
>>> CPUs? Will the savings be dwarved by the O(nr_cpus_used) loop 
>>> overhead?
>>>
>>> Especially as this is touching cachelines on other CPUs and likely 
>>> creating the worst kind of cachemisses. That can really kill 
>>> performance.
>>
>> flush_tlb_page does the same O(nr_cpus_used) loop, but it sends an 
>> IPI to each CPU every time, instead of dirtying a cache line once 
>> per pageout run (or until the next context switch).
>>
>> Does that address your concern?
> 
> That depends on the platform - which could implement flush_tlb_page() 
> as a broadcast IPI - but yes, it was bad before as well, now it became 
> more visible and I noticed it :)
> 
> Wouldn't it be more scalable to use a generation count as a timestamp, 
> and set that in the mm? mm that last flushed before that timestamp 
> need to flush, or so. That gets rid of the mask logic and the loop, 
> AFAICS.

More scalable in the page eviction code, sure.

However, that would cause the context switch code to load an
additional cache line, so I am not convinced that is a good
tradeoff...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
