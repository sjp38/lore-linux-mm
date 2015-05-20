Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id E98806B013E
	for <linux-mm@kvack.org>; Wed, 20 May 2015 15:44:30 -0400 (EDT)
Received: by pdea3 with SMTP id a3so80076498pde.2
        for <linux-mm@kvack.org>; Wed, 20 May 2015 12:44:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gi11si27810274pbd.206.2015.05.20.12.44.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 May 2015 12:44:29 -0700 (PDT)
Date: Wed, 20 May 2015 12:44:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V5 2/3] powerpc/mm: Use generic version of
 pmdp_clear_flush
Message-Id: <20150520124428.9bab9007d7d589ec4b615ee6@linux-foundation.org>
In-Reply-To: <1431704550-19937-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1431704550-19937-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<1431704550-19937-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, kirill.shutemov@linux.intel.com, aarcange@redhat.com, schwidefsky@de.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Fri, 15 May 2015 21:12:29 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> Also move the pmd_trans_huge check to generic code.
> 
> ...
>
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -196,7 +196,12 @@ static inline pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
>  					unsigned long address,
>  					pmd_t *pmdp)
>  {
> -	return pmdp_clear_flush(vma, address, pmdp);
> +	pmd_t pmd;
> +	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
> +	VM_BUG_ON(pmd_trans_huge(*pmdp));
> +	pmd = pmdp_get_and_clear(vma->vm_mm, address, pmdp);
> +	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
> +	return pmd;
>  }

x86_64 allmodconfig:

In file included from ./arch/x86/include/asm/pgtable.h:878,
                 from include/linux/mm.h:53,
                 from include/linux/suspend.h:8,
                 from arch/x86/kernel/asm-offsets.c:12:
include/asm-generic/pgtable.h: In function 'pmdp_collapse_flush':
include/asm-generic/pgtable.h:199: error: 'HPAGE_PMD_MASK' undeclared (first use in this function)
include/asm-generic/pgtable.h:199: error: (Each undeclared identifier is reported only once
include/asm-generic/pgtable.h:199: error: for each function it appears in.)
include/asm-generic/pgtable.h:202: error: implicit declaration of function 'flush_tlb_range'
include/asm-generic/pgtable.h:202: error: 'HPAGE_PMD_SIZE' undeclared (first use in this function)


Including linux/huge_mm.h doesn't work.  A suitable fix would be to
move this into a .c file.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
