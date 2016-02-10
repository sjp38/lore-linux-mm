Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id E50BB6B0009
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 00:07:10 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id is5so12745799obc.0
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 21:07:10 -0800 (PST)
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com. [129.33.205.207])
        by mx.google.com with ESMTPS id v6si1095921oec.62.2016.02.09.21.07.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Feb 2016 21:07:10 -0800 (PST)
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 10 Feb 2016 00:07:09 -0500
Received: from b01cxnp23032.gho.pok.ibm.com (b01cxnp23032.gho.pok.ibm.com [9.57.198.27])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 45243C90041
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 00:07:05 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp23032.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1A577A935061794
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 05:07:07 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1A5775D018601
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 00:07:07 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm,thp: khugepaged: call pte flush at the time of collapse
In-Reply-To: <1455080175-10987-1-git-send-email-vgupta@synopsys.com>
References: <1455080175-10987-1-git-send-email-vgupta@synopsys.com>
Date: Wed, 10 Feb 2016 10:37:02 +0530
Message-ID: <87fux1xifd.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Vineet Gupta <Vineet.Gupta1@synopsys.com> writes:

> This showed up on ARC when running LMBench bw_mem tests as
> Overlapping TLB Machine Check Exception triggered due to STLB entry
> (2M pages) overlapping some NTLB entry (regular 8K page).
>
> bw_mem 2m touches a large chunk of vaddr creating NTLB entries.
> In the interim khugepaged kicks in, collapsing the contiguous ptes into
> a single pmd. pmdp_collapse_flush()->flush_pmd_tlb_range() is called to
> flush out NTLB entries for the ptes. This for ARC (by design) can only
> shootdown STLB entries (for pmd). The stray NTLB entries cause the overlap
> with the subsequent STLB entry for collapsed page.
> So make pmdp_collapse_flush() call pte flush interface not pmd flush.
>
> Note that originally all thp flush call sites in generic code called
> flush_tlb_range() leaving it to architecture to implement the flush for
> pte and/or pmd. Commit 12ebc1581ad11454 changed this by calling a new
> opt-in API flush_pmd_tlb_range() which made the semantics more explicit
> but failed to distinguish the pte vs pmd flush in generic code, which is
> what this patch fixes.
>
> Note that ARC can fixed w/o touching the generic pmdp_collapse_flush()
> by defining a ARC version, but that defeats the purpose of generic
> version, plus sementically this is the right thing to do.
>
> Fixes STAR 9000961194: LMBench on AXS103 triggering duplicate TLB
> exceptions with super pages
>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: <stable@vger.kernel.org> #4.4
> Cc: <linux-snps-arc@lists.infradead.org>
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Fixes: 12ebc1581ad11454 ("mm,thp: introduce flush_pmd_tlb_range")
> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

We do have reverse usage in migration code path, which I have as a patch
here.

https://github.com/kvaneesh/linux/commit/b8a78933fea93cb0b2978868e59a0a4b12eb92eb

> ---
>  mm/pgtable-generic.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
> index 7d3db0247983..1ba58213ad65 100644
> --- a/mm/pgtable-generic.c
> +++ b/mm/pgtable-generic.c
> @@ -210,7 +210,9 @@ pmd_t pmdp_collapse_flush(struct vm_area_struct *vma, unsigned long address,
>  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
>  	VM_BUG_ON(pmd_trans_huge(*pmdp));
>  	pmd = pmdp_huge_get_and_clear(vma->vm_mm, address, pmdp);
> -	flush_pmd_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
> +
> +	/* collapse entails shooting down ptes not pmd */
> +	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
>  	return pmd;
>  }
>  #endif
> -- 
> 2.5.0

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
