Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id EC079828DF
	for <linux-mm@kvack.org>; Fri, 18 Mar 2016 09:53:56 -0400 (EDT)
Received: by mail-qk0-f182.google.com with SMTP id s5so49121454qkd.0
        for <linux-mm@kvack.org>; Fri, 18 Mar 2016 06:53:56 -0700 (PDT)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id c207si12250811qhc.129.2016.03.18.06.53.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 18 Mar 2016 06:53:56 -0700 (PDT)
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 18 Mar 2016 07:53:54 -0600
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id DED3A19D803F
	for <linux-mm@kvack.org>; Fri, 18 Mar 2016 07:41:45 -0600 (MDT)
Received: from d01av05.pok.ibm.com (d01av05.pok.ibm.com [9.56.224.195])
	by b01cxnp22036.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2IDrp5S23003378
	for <linux-mm@kvack.org>; Fri, 18 Mar 2016 13:53:51 GMT
Received: from d01av05.pok.ibm.com (localhost [127.0.0.1])
	by d01av05.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2IDmtmN019740
	for <linux-mm@kvack.org>; Fri, 18 Mar 2016 09:48:57 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCHv4 08/25] thp: support file pages in zap_huge_pmd()
In-Reply-To: <1457737157-38573-9-git-send-email-kirill.shutemov@linux.intel.com>
References: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com> <1457737157-38573-9-git-send-email-kirill.shutemov@linux.intel.com>
Date: Fri, 18 Mar 2016 19:23:41 +0530
Message-ID: <87a8lvao4a.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:

> [ text/plain ]
> split_huge_pmd() for file mappings (and DAX too) is implemented by just
> clearing pmd entry as we can re-fill this area from page cache on pte
> level later.
>
> This means we don't need deposit page tables when file THP is mapped.
> Therefore we shouldn't try to withdraw a page table on zap_huge_pmd()
> file THP PMD.

Archs like ppc64 use deposited page table to track the hardware page
table slot information. We probably may want to add hooks which arch can
use to achieve the same even with file THP 

>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/huge_memory.c | 12 +++++++++---
>  1 file changed, 9 insertions(+), 3 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 44468fb7cdbf..c22144e3fe11 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1684,10 +1684,16 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  		struct page *page = pmd_page(orig_pmd);
>  		page_remove_rmap(page, true);
>  		VM_BUG_ON_PAGE(page_mapcount(page) < 0, page);
> -		add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
>  		VM_BUG_ON_PAGE(!PageHead(page), page);
> -		pte_free(tlb->mm, pgtable_trans_huge_withdraw(tlb->mm, pmd));
> -		atomic_long_dec(&tlb->mm->nr_ptes);
> +		if (PageAnon(page)) {
> +			pgtable_t pgtable;
> +			pgtable = pgtable_trans_huge_withdraw(tlb->mm, pmd);
> +			pte_free(tlb->mm, pgtable);
> +			atomic_long_dec(&tlb->mm->nr_ptes);
> +			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
> +		} else {
> +			add_mm_counter(tlb->mm, MM_FILEPAGES, -HPAGE_PMD_NR);
> +		}
>  		spin_unlock(ptl);
>  		tlb_remove_page(tlb, page);
>  	}
> -- 
> 2.7.0
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
