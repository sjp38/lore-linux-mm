Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id E85556B0279
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 09:35:30 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id c6so11479267vke.7
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 06:35:30 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id b76si2088302vkd.137.2017.06.23.06.35.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 06:35:29 -0700 (PDT)
Subject: Re: [PATCH v3 06/11] x86/mm: Rework lazy TLB mode and TLB freshness
 tracking
References: <cover.1498022414.git.luto@kernel.org>
 <70f3a61658aa7c1c89f4db6a4f81d8df9e396ade.1498022414.git.luto@kernel.org>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <cb8aad11-6e02-bc8e-8613-63f63a22bc77@oracle.com>
Date: Fri, 23 Jun 2017 09:34:42 -0400
MIME-Version: 1.0
In-Reply-To: <70f3a61658aa7c1c89f4db6a4f81d8df9e396ade.1498022414.git.luto@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Banman <abanman@sgi.com>, Mike Travis <travis@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Juergen Gross <jgross@suse.com>


> diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
> index 1d7a7213a310..f5df56fb8b5c 100644
> --- a/arch/x86/xen/mmu_pv.c
> +++ b/arch/x86/xen/mmu_pv.c
> @@ -1005,8 +1005,7 @@ static void xen_drop_mm_ref(struct mm_struct *mm)
>   	/* Get the "official" set of cpus referring to our pagetable. */
>   	if (!alloc_cpumask_var(&mask, GFP_ATOMIC)) {
>   		for_each_online_cpu(cpu) {
> -			if (!cpumask_test_cpu(cpu, mm_cpumask(mm))
> -			    && per_cpu(xen_current_cr3, cpu) != __pa(mm->pgd))
> +			if (per_cpu(xen_current_cr3, cpu) != __pa(mm->pgd))
>   				continue;
>   			smp_call_function_single(cpu, drop_mm_ref_this_cpu, mm, 1);
>   		}
> 


I wonder then whether
	cpumask_copy(mask, mm_cpumask(mm));
immediately below is needed.

-boris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
