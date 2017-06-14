Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C782E6B02C3
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 11:29:02 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id e187so3430627pgc.7
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 08:29:02 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q64si197017pfi.219.2017.06.14.08.29.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 08:29:02 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5EFO526084799
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 11:29:01 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2b33geycna-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 11:29:01 -0400
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 14 Jun 2017 09:28:58 -0600
Subject: Re: [PATCH 3/3] mm, thp: Do not loose dirty bit in
 __split_huge_pmd_locked()
References: <20170614135143.25068-1-kirill.shutemov@linux.intel.com>
 <20170614135143.25068-4-kirill.shutemov@linux.intel.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Date: Wed, 14 Jun 2017 20:58:45 +0530
MIME-Version: 1.0
In-Reply-To: <20170614135143.25068-4-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <4f87514b-e00e-065b-aa04-802a3302aa1d@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On Wednesday 14 June 2017 07:21 PM, Kirill A. Shutemov wrote:
> Until pmdp_invalidate() pmd entry is present and CPU can update it,
> setting dirty. Currently, we tranfer dirty bit to page too early and
> there is window when we can miss dirty bit.
> 
> Let's call SetPageDirty() after pmdp_invalidate().
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>   mm/huge_memory.c | 13 +++++++++----
>   1 file changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index a84909cf20d3..c4ee5c890910 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1928,7 +1928,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>   	struct page *page;
>   	pgtable_t pgtable;
>   	pmd_t _pmd;
> -	bool young, write, dirty, soft_dirty;
> +	bool young, write, soft_dirty;
>   	unsigned long addr;
>   	int i;
> 
> @@ -1965,7 +1965,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>   	page_ref_add(page, HPAGE_PMD_NR - 1);
>   	write = pmd_write(*pmd);
>   	young = pmd_young(*pmd);
> -	dirty = pmd_dirty(*pmd);
>   	soft_dirty = pmd_soft_dirty(*pmd);
> 
>   	pmdp_huge_split_prepare(vma, haddr, pmd);
> @@ -1995,8 +1994,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>   			if (soft_dirty)
>   				entry = pte_mksoft_dirty(entry);
>   		}
> -		if (dirty)
> -			SetPageDirty(page + i);
>   		pte = pte_offset_map(&_pmd, addr);
>   		BUG_ON(!pte_none(*pte));
>   		set_pte_at(mm, addr, pte, entry);
> @@ -2046,6 +2043,14 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>   	 * pmd_populate.
>   	 */
>   	pmdp_invalidate(vma, haddr, pmd);
> +
> +	/*
> +	 * Transfer dirty bit to page after pmd invalidated, so CPU would not
> +	 * be able to set it under us.
> +	 */
> +	if (pmd_dirty(*pmd))
> +		SetPageDirty(page);
> +
>   	pmd_populate(mm, pmd, pgtable);
> 

you fixed dirty bit loosing i discussed in my previous mail here.

thanks
-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
