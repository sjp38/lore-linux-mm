Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 80AF86B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 05:15:00 -0400 (EDT)
Received: by pdea3 with SMTP id a3so22765168pde.3
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 02:15:00 -0700 (PDT)
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com. [202.81.31.140])
        by mx.google.com with ESMTPS id yw3si14500116pac.106.2015.04.29.02.14.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Apr 2015 02:14:59 -0700 (PDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 29 Apr 2015 19:14:53 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id A677D2CE8040
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 19:14:49 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3T9Ee0m44433636
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 19:14:49 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3T9EEPi023840
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 19:14:15 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCHv5 18/28] x86, thp: remove infrastructure for handling splitting PMDs
In-Reply-To: <1429823043-157133-19-git-send-email-kirill.shutemov@linux.intel.com>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com> <1429823043-157133-19-git-send-email-kirill.shutemov@linux.intel.com>
Date: Wed, 29 Apr 2015 14:43:45 +0530
Message-ID: <87d22n8fg6.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:

> With new refcounting we don't need to mark PMDs splitting. Let's drop
> code to handle this.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  arch/x86/include/asm/pgtable.h       |  9 ---------
>  arch/x86/include/asm/pgtable_types.h |  2 --
>  arch/x86/mm/gup.c                    | 13 +------------
>  arch/x86/mm/pgtable.c                | 14 --------------
>  4 files changed, 1 insertion(+), 37 deletions(-)
>
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> index f89d6c9943ea..21a2e25a5393 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -158,11 +158,6 @@ static inline int pmd_large(pmd_t pte)
>  }
>  
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -static inline int pmd_trans_splitting(pmd_t pmd)
> -{
> -	return pmd_val(pmd) & _PAGE_SPLITTING;
> -}
> -
>  static inline int pmd_trans_huge(pmd_t pmd)
>  {
>  	return pmd_val(pmd) & _PAGE_PSE;
> @@ -792,10 +787,6 @@ extern int pmdp_clear_flush_young(struct vm_area_struct *vma,
>  				  unsigned long address, pmd_t *pmdp);
>  
>  
> -#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
> -extern void pmdp_splitting_flush(struct vm_area_struct *vma,
> -				 unsigned long addr, pmd_t *pmdp);
> -

Can we keep pmdp_splitting_flush or a variant and use that before a
hugepage split ? That is to have a special function to do
pmd_clear before splitting ?. We still depend on a IPI to be send to
other cpus on split and not all archs will do that in
pmdp_clear_flush_notify. I guess we need the ipi to make sure a
local_irq_disable can prevent a parallel split ?

Something like ?

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index cce4604c192f..0a0d00b21f76 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2608,7 +2608,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	young = pmd_young(*pmd);
 
 	/* leave pmd empty until pte is filled */
-	pmdp_clear_flush_notify(vma, haddr, pmd);
+	pmdp_splitting_clear_flush_notify(vma, haddr, pmd);
 
 	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
 	pmd_populate(mm, &_pmd, pgtable);


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
