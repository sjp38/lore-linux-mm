Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id 577696B0031
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 08:55:40 -0400 (EDT)
Received: by mail-qa0-f43.google.com with SMTP id j15so9434368qaq.2
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 05:55:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id r9si7502290qar.162.2014.04.01.05.55.39
        for <linux-mm@kvack.org>;
        Tue, 01 Apr 2014 05:55:39 -0700 (PDT)
Message-ID: <533AB741.5080508@redhat.com>
Date: Tue, 01 Apr 2014 08:55:29 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86,mm: delay TLB flush after clearing accessed bit
References: <20140331113442.0d628362@annuminas.surriel.com> <20140401105318.GA2823@gmail.com>
In-Reply-To: <20140401105318.GA2823@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, shli@kernel.org, akpm@linux-foundation.org, hughd@google.com, mgorman@suse.de, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>

On 04/01/2014 06:53 AM, Ingo Molnar wrote:
> 
> The speedup looks good to me!
> 
> I have one major concern (see the last item), plus a few minor nits:

I will address all the minor issues. Let me explain the major one :)

>> @@ -196,6 +201,13 @@ static inline void reset_lazy_tlbstate(void)
>>  	this_cpu_write(cpu_tlbstate.active_mm, &init_mm);
>>  }
>>  
>> +static inline void tlb_set_force_flush(int cpu)
>> +{
>> +	struct tlb_state *percputlb= &per_cpu(cpu_tlbstate, cpu);
> 
> s/b= /b = /
> 
>> +	if (percputlb->force_flush == false)
>> +		percputlb->force_flush = true;
>> +}
>> +
>>  #endif	/* SMP */

This code does a test before the set, so each cache line will only be
grabbed exclusively once, if there is heavy pageout scanning activity.

>> @@ -399,11 +400,13 @@ int pmdp_test_and_clear_young(struct vm_area_struct *vma,
>>  int ptep_clear_flush_young(struct vm_area_struct *vma,
>>  			   unsigned long address, pte_t *ptep)
>>  {
>> -	int young;
>> +	int young, cpu;
>>  
>>  	young = ptep_test_and_clear_young(vma, address, ptep);
>> -	if (young)
>> -		flush_tlb_page(vma, address);
>> +	if (young) {
>> +		for_each_cpu(cpu, vma->vm_mm->cpu_vm_mask_var)
>> +			tlb_set_force_flush(cpu);
> 
> Hm, just to play the devil's advocate - what happens when we have a va 
> that is used on a few dozen, a few hundred or a few thousand CPUs? 
> Will the savings be dwarved by the O(nr_cpus_used) loop overhead?
> 
> Especially as this is touching cachelines on other CPUs and likely 
> creating the worst kind of cachemisses. That can really kill 
> performance.

flush_tlb_page does the same O(nr_cpus_used) loop, but it sends an
IPI to each CPU every time, instead of dirtying a cache line once
per pageout run (or until the next context switch).

Does that address your concern?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
