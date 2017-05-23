Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4BCE56B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 01:26:42 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u96so14437025wrc.7
        for <linux-mm@kvack.org>; Mon, 22 May 2017 22:26:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 78si964837wmn.92.2017.05.22.22.26.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 22:26:41 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4N5IaHj037262
	for <linux-mm@kvack.org>; Tue, 23 May 2017 01:26:39 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2am85enxmu-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 May 2017 01:26:39 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Tue, 23 May 2017 06:26:37 +0100
Date: Tue, 23 May 2017 07:26:29 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH v3.1 4/6] mm/hugetlb: Allow architectures to override
 huge_pte_clear()
In-Reply-To: <20170522162555.4313-1-punit.agrawal@arm.com>
References: <20170522133604.11392-5-punit.agrawal@arm.com>
	<20170522162555.4313-1-punit.agrawal@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20170523072629.06163fa6@mschwideX1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, mike.kravetz@oracle.com, steve.capper@arm.com, mark.rutland@arm.com, linux-arch@vger.kernel.org, aneesh.kumar@linux.vnet.ibm.com, Heiko Carstens <heiko.carstens@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>

On Mon, 22 May 2017 17:25:55 +0100
Punit Agrawal <punit.agrawal@arm.com> wrote:

> When unmapping a hugepage range, huge_pte_clear() is used to clear the
> page table entries that are marked as not present. huge_pte_clear()
> internally just ends up calling pte_clear() which does not correctly
> deal with hugepages consisting of contiguous page table entries.
> 
> Add a size argument to address this issue and allow architectures to
> override huge_pte_clear() by wrapping it in a #ifndef block.
> 
> Update s390 implementation with the size parameter as well.
> 
> Note that the change only affects huge_pte_clear() - the other generic
> hugetlb functions don't need any change.
> 
> Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> ---
> 
> Changes since v3
> 
> * Drop weak function and use #ifndef block to allow architecture override
> * Drop unnecessary move of s390 function definition
> 
>  arch/s390/include/asm/hugetlb.h | 2 +-
>  include/asm-generic/hugetlb.h   | 4 +++-
>  mm/hugetlb.c                    | 2 +-
>  3 files changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/s390/include/asm/hugetlb.h b/arch/s390/include/asm/hugetlb.h
> index cd546a245c68..c0443500baec 100644
> --- a/arch/s390/include/asm/hugetlb.h
> +++ b/arch/s390/include/asm/hugetlb.h
> @@ -39,7 +39,7 @@ static inline int prepare_hugepage_range(struct file *file,
>  #define arch_clear_hugepage_flags(page)		do { } while (0)
> 
>  static inline void huge_pte_clear(struct mm_struct *mm, unsigned long addr,
> -				  pte_t *ptep)
> +				  pte_t *ptep, unsigned long sz)
>  {
>  	if ((pte_val(*ptep) & _REGION_ENTRY_TYPE_MASK) == _REGION_ENTRY_TYPE_R3)
>  		pte_val(*ptep) = _REGION3_ENTRY_EMPTY;

For the nop-change for s390:
Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
