Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 29A776B0031
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 09:20:42 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id u57so6046493wes.8
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 06:20:41 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id ni18si1079377wic.59.2014.04.01.06.20.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 06:20:40 -0700 (PDT)
Received: by mail-wi0-f173.google.com with SMTP id z2so3392675wiv.6
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 06:20:39 -0700 (PDT)
Date: Tue, 1 Apr 2014 15:20:37 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] x86,mm: delay TLB flush after clearing accessed bit
Message-ID: <20140401132037.GB7024@gmail.com>
References: <20140331113442.0d628362@annuminas.surriel.com>
 <20140401105318.GA2823@gmail.com>
 <533AB741.5080508@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <533AB741.5080508@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, shli@kernel.org, akpm@linux-foundation.org, hughd@google.com, mgorman@suse.de, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>


* Rik van Riel <riel@redhat.com> wrote:

> >>  int ptep_clear_flush_young(struct vm_area_struct *vma,
> >>  			   unsigned long address, pte_t *ptep)
> >>  {
> >> -	int young;
> >> +	int young, cpu;
> >>  
> >>  	young = ptep_test_and_clear_young(vma, address, ptep);
> >> -	if (young)
> >> -		flush_tlb_page(vma, address);
> >> +	if (young) {
> >> +		for_each_cpu(cpu, vma->vm_mm->cpu_vm_mask_var)
> >> +			tlb_set_force_flush(cpu);
> > 
> > Hm, just to play the devil's advocate - what happens when we have 
> > a va that is used on a few dozen, a few hundred or a few thousand 
> > CPUs? Will the savings be dwarved by the O(nr_cpus_used) loop 
> > overhead?
> > 
> > Especially as this is touching cachelines on other CPUs and likely 
> > creating the worst kind of cachemisses. That can really kill 
> > performance.
> 
> flush_tlb_page does the same O(nr_cpus_used) loop, but it sends an 
> IPI to each CPU every time, instead of dirtying a cache line once 
> per pageout run (or until the next context switch).
> 
> Does that address your concern?

That depends on the platform - which could implement flush_tlb_page() 
as a broadcast IPI - but yes, it was bad before as well, now it became 
more visible and I noticed it :)

Wouldn't it be more scalable to use a generation count as a timestamp, 
and set that in the mm? mm that last flushed before that timestamp 
need to flush, or so. That gets rid of the mask logic and the loop, 
AFAICS.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
