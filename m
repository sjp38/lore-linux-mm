Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A82406B0279
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 07:31:44 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id s4so7071399wrc.15
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 04:31:44 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w131si1858729wmb.188.2017.06.16.04.31.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 04:31:43 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5GBSaAH018013
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 07:31:42 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2b4edxg8p2-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 07:31:41 -0400
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 16 Jun 2017 21:31:38 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v5GBVbg565929388
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 21:31:37 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v5GBVRIl029039
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 21:31:28 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCHv2 3/3] mm: Use updated pmdp_invalidate() inteface to track dirty/accessed bits
In-Reply-To: <20170615145224.66200-4-kirill.shutemov@linux.intel.com>
References: <20170615145224.66200-1-kirill.shutemov@linux.intel.com> <20170615145224.66200-4-kirill.shutemov@linux.intel.com>
Date: Fri, 16 Jun 2017 17:01:30 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87bmpob23x.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:

> This patch uses modifed pmdp_invalidate(), that return previous value of pmd,
> to transfer dirty and accessed bits.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  fs/proc/task_mmu.c |  8 ++++----
>  mm/huge_memory.c   | 29 ++++++++++++-----------------
>  2 files changed, 16 insertions(+), 21 deletions(-)
>
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index f0c8b33d99b1..f2fc1ef5bba2 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c

.....

> @@ -1965,7 +1955,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  	page_ref_add(page, HPAGE_PMD_NR - 1);
>  	write = pmd_write(*pmd);
>  	young = pmd_young(*pmd);
> -	dirty = pmd_dirty(*pmd);
>  	soft_dirty = pmd_soft_dirty(*pmd);
>
>  	pmdp_huge_split_prepare(vma, haddr, pmd);
> @@ -1995,8 +1984,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  			if (soft_dirty)
>  				entry = pte_mksoft_dirty(entry);
>  		}
> -		if (dirty)
> -			SetPageDirty(page + i);
>  		pte = pte_offset_map(&_pmd, addr);
>  		BUG_ON(!pte_none(*pte));
>  		set_pte_at(mm, addr, pte, entry);
> @@ -2045,7 +2032,15 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  	 * and finally we write the non-huge version of the pmd entry with
>  	 * pmd_populate.
>  	 */
> -	pmdp_invalidate(vma, haddr, pmd);
> +	old = pmdp_invalidate(vma, haddr, pmd);
> +
> +	/*
> +	 * Transfer dirty bit using value returned by pmd_invalidate() to be
> +	 * sure we don't race with CPU that can set the bit under us.
> +	 */
> +	if (pmd_dirty(old))
> +		SetPageDirty(page);
> +
>  	pmd_populate(mm, pmd, pgtable);
>
>  	if (freeze) {


Can we invalidate the pmd early here ? ie, do pmdp_invalidate instead of
pmdp_huge_split_prepare() ?


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
