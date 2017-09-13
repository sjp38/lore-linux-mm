Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CEB406B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 01:06:27 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b195so7213757wmb.6
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 22:06:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j13si427570wmf.217.2017.09.12.22.06.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Sep 2017 22:06:26 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8D53hWN112130
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 01:06:25 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2cxx130enk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 01:06:25 -0400
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 13 Sep 2017 15:06:22 +1000
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v8D56KBm33947872
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 15:06:20 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v8D56Jm3030020
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 15:06:20 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCHv3 08/11] sparc64: update pmdp_invalidate to return old pmd value
In-Reply-To: <20170912153941.47012-9-kirill.shutemov@linux.intel.com>
References: <20170912153941.47012-1-kirill.shutemov@linux.intel.com> <20170912153941.47012-9-kirill.shutemov@linux.intel.com>
Date: Wed, 13 Sep 2017 10:36:13 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87r2vbur0a.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nitin Gupta <nitin.m.gupta@oracle.com>

"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:

> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>


You got the author wrong there.

>
> It's required to avoid loosing dirty and accessed bits.
>
> Signed-off-by: Nitin Gupta <nitin.m.gupta@oracle.com>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/sparc/include/asm/pgtable_64.h |  2 +-
>  arch/sparc/mm/tlb.c                 | 23 ++++++++++++++++++-----
>  2 files changed, 19 insertions(+), 6 deletions(-)
>
> diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
> index 4fefe3762083..83b06c98bb94 100644
> --- a/arch/sparc/include/asm/pgtable_64.h
> +++ b/arch/sparc/include/asm/pgtable_64.h
> @@ -979,7 +979,7 @@ void update_mmu_cache_pmd(struct vm_area_struct *vma, unsigned long addr,
>  			  pmd_t *pmd);
>
>  #define __HAVE_ARCH_PMDP_INVALIDATE
> -extern void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
> +extern pmd_t pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
>  			    pmd_t *pmdp);
>
>  #define __HAVE_ARCH_PGTABLE_DEPOSIT
> diff --git a/arch/sparc/mm/tlb.c b/arch/sparc/mm/tlb.c
> index ee8066c3d96c..d36c65fc55cf 100644
> --- a/arch/sparc/mm/tlb.c
> +++ b/arch/sparc/mm/tlb.c
> @@ -218,17 +218,28 @@ void set_pmd_at(struct mm_struct *mm, unsigned long addr,
>  	}
>  }
>
> +static inline pmd_t pmdp_establish(struct vm_area_struct *vma,
> +		unsigned long address, pmd_t *pmdp, pmd_t pmd)
> +{
> +	pmd_t old;
> +
> +	{
> +		old = *pmdp;
> +	} while (cmpxchg64(&pmdp->pmd, old.pmd, pmd.pmd) != old.pmd);
> +
> +	return old;
> +}
> +
>  /*
>   * This routine is only called when splitting a THP
>   */
> -void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
> +pmd_t pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
>  		     pmd_t *pmdp)
>  {
> -	pmd_t entry = *pmdp;
> -
> -	pmd_val(entry) &= ~_PAGE_VALID;
> +	pmd_t old, entry;
>
> -	set_pmd_at(vma->vm_mm, address, pmdp, entry);
> +	entry = __pmd(pmd_val(*pmdp) & ~_PAGE_VALID);
> +	old = pmdp_establish(vma, address, pmdp, entry);
>  	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
>
>  	/*
> @@ -239,6 +250,8 @@ void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
>  	if ((pmd_val(entry) & _PAGE_PMD_HUGE) &&
>  	    !is_huge_zero_page(pmd_page(entry)))
>  		(vma->vm_mm)->context.thp_pte_count--;
> +
> +	return old;
>  }
>
>  void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
> -- 
> 2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
