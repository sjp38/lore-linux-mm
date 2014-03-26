Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id D66D96B0031
	for <linux-mm@kvack.org>; Wed, 26 Mar 2014 19:56:09 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so2243622eek.34
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 16:56:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id q2si285364eep.102.2014.03.26.16.56.07
        for <linux-mm@kvack.org>;
        Wed, 26 Mar 2014 16:56:08 -0700 (PDT)
Message-ID: <53336907.1050105@redhat.com>
Date: Wed, 26 Mar 2014 19:55:51 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch]x86: clearing access bit don't flush tlb
References: <20140326223034.GA31713@kernel.org>
In-Reply-To: <20140326223034.GA31713@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, hughd@google.com, mel@csn.ul.ie

On 03/26/2014 06:30 PM, Shaohua Li wrote:
>
> I posted this patch a year ago or so, but it gets lost. Repost it here to check
> if we can make progress this time.

I believe we can make progress. However, I also
believe the code could be enhanced to address a
concern that Hugh raised last time this was
proposed...

> And according to intel manual, tlb has less than 1k entries, which covers < 4M
> memory. In today's system, several giga byte memory is normal. After page
> reclaim clears pte access bit and before cpu access the page again, it's quite
> unlikely this page's pte is still in TLB. And context swich will flush tlb too.
> The chance skiping tlb flush to impact page reclaim should be very rare.

Context switch to a kernel thread does not result in a
TLB flush, due to the lazy TLB code.

While I agree with you that clearing the TLB right at
the moment the accessed bit is cleared in a PTE is
not necessary, I believe it would be good to clear
the TLB on affected CPUs relatively soon, maybe at the
next time schedule is called?

> --- linux.orig/arch/x86/mm/pgtable.c	2014-03-27 05:22:08.572100549 +0800
> +++ linux/arch/x86/mm/pgtable.c	2014-03-27 05:46:12.456131121 +0800
> @@ -399,13 +399,12 @@ int pmdp_test_and_clear_young(struct vm_
>   int ptep_clear_flush_young(struct vm_area_struct *vma,
>   			   unsigned long address, pte_t *ptep)
>   {
> -	int young;
> -
> -	young = ptep_test_and_clear_young(vma, address, ptep);
> -	if (young)
> -		flush_tlb_page(vma, address);
> -
> -	return young;
> +	/*
> +	 * In X86, clearing access bit without TLB flush doesn't cause data
> +	 * corruption. Doing this could cause wrong page aging and so hot pages
> +	 * are reclaimed, but the chance should be very rare.
> +	 */
> +	return ptep_test_and_clear_young(vma, address, ptep);
>   }


At this point, we could use vma->vm_mm->cpu_vm_mask_var to
set (or clear) some bit in the per-cpu data of each CPU that
has active/valid tlb state for the mm in question.

I could see using cpu_tlbstate.state for this, or maybe
another variable in cpu_tlbstate, so switch_mm will load
both items with the same cache line.

At schedule time, the function switch_mm() can examine that
variable (it already touches that data, anyway), and flush
the TLB even if prev==next.

I suspect that would be both low overhead enough to get you
the performance gains you want, and address the concern that
we do want to flush the TLB at some point.

Does that sound reasonable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
