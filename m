Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9EBF06B0031
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 13:12:41 -0400 (EDT)
Received: by mail-ig0-f175.google.com with SMTP id ur14so1845780igb.2
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 10:12:41 -0700 (PDT)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id u6si3307169icp.38.2014.03.27.10.12.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Mar 2014 10:12:40 -0700 (PDT)
Received: by mail-ie0-f174.google.com with SMTP id rp18so3754941iec.19
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 10:12:40 -0700 (PDT)
Date: Fri, 28 Mar 2014 01:12:37 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [patch]x86: clearing access bit don't flush tlb
Message-ID: <20140327171237.GA9490@kernel.org>
References: <20140326223034.GA31713@kernel.org>
 <53336907.1050105@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53336907.1050105@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, mel@csn.ul.ie

On Wed, Mar 26, 2014 at 07:55:51PM -0400, Rik van Riel wrote:
> On 03/26/2014 06:30 PM, Shaohua Li wrote:
> >
> >I posted this patch a year ago or so, but it gets lost. Repost it here to check
> >if we can make progress this time.
> 
> I believe we can make progress. However, I also
> believe the code could be enhanced to address a
> concern that Hugh raised last time this was
> proposed...
> 
> >And according to intel manual, tlb has less than 1k entries, which covers < 4M
> >memory. In today's system, several giga byte memory is normal. After page
> >reclaim clears pte access bit and before cpu access the page again, it's quite
> >unlikely this page's pte is still in TLB. And context swich will flush tlb too.
> >The chance skiping tlb flush to impact page reclaim should be very rare.
> 
> Context switch to a kernel thread does not result in a
> TLB flush, due to the lazy TLB code.
> 
> While I agree with you that clearing the TLB right at
> the moment the accessed bit is cleared in a PTE is
> not necessary, I believe it would be good to clear
> the TLB on affected CPUs relatively soon, maybe at the
> next time schedule is called?
> 
> >--- linux.orig/arch/x86/mm/pgtable.c	2014-03-27 05:22:08.572100549 +0800
> >+++ linux/arch/x86/mm/pgtable.c	2014-03-27 05:46:12.456131121 +0800
> >@@ -399,13 +399,12 @@ int pmdp_test_and_clear_young(struct vm_
> >  int ptep_clear_flush_young(struct vm_area_struct *vma,
> >  			   unsigned long address, pte_t *ptep)
> >  {
> >-	int young;
> >-
> >-	young = ptep_test_and_clear_young(vma, address, ptep);
> >-	if (young)
> >-		flush_tlb_page(vma, address);
> >-
> >-	return young;
> >+	/*
> >+	 * In X86, clearing access bit without TLB flush doesn't cause data
> >+	 * corruption. Doing this could cause wrong page aging and so hot pages
> >+	 * are reclaimed, but the chance should be very rare.
> >+	 */
> >+	return ptep_test_and_clear_young(vma, address, ptep);
> >  }
> 
> 
> At this point, we could use vma->vm_mm->cpu_vm_mask_var to
> set (or clear) some bit in the per-cpu data of each CPU that
> has active/valid tlb state for the mm in question.
> 
> I could see using cpu_tlbstate.state for this, or maybe
> another variable in cpu_tlbstate, so switch_mm will load
> both items with the same cache line.
> 
> At schedule time, the function switch_mm() can examine that
> variable (it already touches that data, anyway), and flush
> the TLB even if prev==next.
> 
> I suspect that would be both low overhead enough to get you
> the performance gains you want, and address the concern that
> we do want to flush the TLB at some point.
> 
> Does that sound reasonable?

So looks what you suggested is to force tlb flush for a mm with access bit
cleared in two corner cases:
1. lazy tlb flush
2. context switch between threads from one process

Am I missing anything? I'm wonering if we should care about these corner cases.
On the other hand, a thread might run long time without schedule. If the corner
cases are an issue, the long run thread is a severer issue. My point is context
switch does provide a safeguard, but we don't depend on it. The whole theory at
the back of this patch is page which has access bit cleared is unlikely
accessed again when its pte entry is still in tlb cache.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
