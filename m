Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CEC296B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 07:47:27 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c82so25920298wme.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 04:47:27 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id x192si4239827wmf.62.2016.06.16.04.47.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 04:47:26 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id k184so10824102wme.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 04:47:26 -0700 (PDT)
Date: Thu, 16 Jun 2016 14:47:14 +0300
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: Re: [PATCHv9-rebased2 05/37] khugepaged: recheck pmd after mmap_sem
 re-acquired
Message-ID: <20160616114603.GA19710@gezgin>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1466021202-61880-6-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466021202-61880-6-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, sergey.senozhatsky.work@gmail.com

On Wed, Jun 15, 2016 at 11:06:10PM +0300, Kirill A. Shutemov wrote:
> Vlastimil noted[1] that pmd can be no longer valid after we drop
> mmap_sem. We need recheck it once mmap_sem taken again.
> 
> [1] http://lkml.kernel.org/r/12918dcd-a695-c6f4-e06f-69141c5f357f@suse.cz
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/huge_memory.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index d7ccc8558187..0efdad975659 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2437,6 +2437,9 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
>  			/* vma is no longer available, don't continue to swapin */
>  			if (hugepage_vma_revalidate(mm, address))
>  				return false;
> +			/* check if the pmd is still valid */
> +			if (mm_find_pmd(mm, address) != pmd)
> +				return false;
>  		}
Thanks for fixing this.

>  		if (ret & VM_FAULT_ERROR) {
>  			trace_mm_collapse_huge_page_swapin(mm, swapped_in, 0);
> @@ -2522,6 +2525,9 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	result = hugepage_vma_revalidate(mm, address);
>  	if (result)
>  		goto out;
> +	/* check if the pmd is still valid */
> +	if (mm_find_pmd(mm, address) != pmd)
> +		goto out;
>  
However here, I don't know do we need to check pmd.
Because in collapse_huge_page; pmd is newly created,
after taking mmap_sem read:
{

	pmd_t *pmd, _pmd;
        pte_t *pte;
        ...
        down_read(&mm->mmap_sem);
        result = hugepage_vma_revalidate(mm, address);
        ...
        pmd = mm_find_pmd(mm, address);
        ...

Therefore it did not seem like a problem for me.

>  	anon_vma_lock_write(vma->anon_vma);
>  
> -- 
> 2.8.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
