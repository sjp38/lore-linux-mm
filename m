Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 347FB6B02F4
	for <linux-mm@kvack.org>; Mon, 29 May 2017 19:42:44 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id r58so25499635qtb.0
        for <linux-mm@kvack.org>; Mon, 29 May 2017 16:42:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a129si10624302qkd.180.2017.05.29.16.42.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 May 2017 16:42:43 -0700 (PDT)
Message-ID: <1496101359.29205.73.camel@redhat.com>
Subject: Re: [PATCH v4 3/8] x86/mm: Refactor flush_tlb_mm_range() to merge
 local and remote cases
From: Rik van Riel <riel@redhat.com>
Date: Mon, 29 May 2017 19:42:39 -0400
In-Reply-To: <bcaf9dbdd1216b7fc03ad4870477e9772edecfc9.1495990440.git.luto@kernel.org>
References: <cover.1495990440.git.luto@kernel.org>
	 <bcaf9dbdd1216b7fc03ad4870477e9772edecfc9.1495990440.git.luto@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>
Cc: Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

On Sun, 2017-05-28 at 10:00 -0700, Andy Lutomirski wrote:

> @@ -292,61 +303,33 @@ static unsigned long
> tlb_single_page_flush_ceiling __read_mostly = 33;
> A void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
> A 				unsigned long end, unsigned long
> vmflag)
> A {
> -	unsigned long addr;
> -	struct flush_tlb_info info;
> -	/* do a global flush by default */
> -	unsigned long base_pages_to_flush = TLB_FLUSH_ALL;
> -
> -	preempt_disable();
> +	int cpu;
> A 
> -	if ((end != TLB_FLUSH_ALL) && !(vmflag & VM_HUGETLB))
> -		base_pages_to_flush = (end - start) >> PAGE_SHIFT;
> -	if (base_pages_to_flush > tlb_single_page_flush_ceiling)
> -		base_pages_to_flush = TLB_FLUSH_ALL;
> -
> -	if (current->active_mm != mm) {
> -		/* Synchronize with switch_mm. */
> -		smp_mb();
> -
> -		goto out;
> -	}
> -
> -	if (this_cpu_read(cpu_tlbstate.state) != TLBSTATE_OK) {
> -		leave_mm(smp_processor_id());
> +	struct flush_tlb_info info = {
> +		.mm = mm,
> +	};
> A 
> -		/* Synchronize with switch_mm. */
> -		smp_mb();
> +	cpu = get_cpu();
> A 
> -		goto out;
> -	}
> +	/* Synchronize with switch_mm. */
> +	smp_mb();
> A 
> -	/*
> -	A * Both branches below are implicit full barriers (MOV to CR
> or
> -	A * INVLPG) that synchronize with switch_mm.
> -	A */
> -	if (base_pages_to_flush == TLB_FLUSH_ALL) {
> -		count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
> -		local_flush_tlb();
> +	/* Should we flush just the requested range? */
> +	if ((end != TLB_FLUSH_ALL) &&
> +	A A A A !(vmflag & VM_HUGETLB) &&
> +	A A A A ((end - start) >> PAGE_SHIFT) <=
> tlb_single_page_flush_ceiling) {
> +		info.start = start;
> +		info.end = end;
> A 	} else {
> -		/* flush range by one by one 'invlpg' */
> -		for (addr = start; addr < end;	addr +=
> PAGE_SIZE) {
> -			count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ONE);
> -			__flush_tlb_single(addr);
> -		}
> -	}
> -	trace_tlb_flush(TLB_LOCAL_MM_SHOOTDOWN,
> base_pages_to_flush);
> -out:
> -	info.mm = mm;
> -	if (base_pages_to_flush == TLB_FLUSH_ALL) {
> A 		info.start = 0UL;
> A 		info.end = TLB_FLUSH_ALL;
> -	} else {
> -		info.start = start;
> -		info.end = end;
> A 	}
> -	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) <
> nr_cpu_ids)
> +
> +	if (mm == current->active_mm)
> +		flush_tlb_func_local(&info, TLB_LOCAL_MM_SHOOTDOWN);

It looks like this could cause flush_tlb_func_local to be
called over and over again even while cpu_tlbstate.state
equals TLBSTATE_LAZY, because active_mm is not changed by
leave_mm.

Do you want to also test cpu_tlbstate.state != TLBSTATE_OK
here, to ensure flush_tlb_func_local is only called when
necessary?

> +	if (cpumask_any_but(mm_cpumask(mm), cpu) < nr_cpu_ids)
> A 		flush_tlb_others(mm_cpumask(mm), &info);
> -	preempt_enable();
> +	put_cpu();
> A }
> A 
> A 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
