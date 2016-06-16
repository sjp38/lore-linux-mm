Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9446B0253
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 07:51:58 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id k184so25881357wme.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 04:51:58 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id g29si5103300lji.56.2016.06.16.04.51.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 04:51:57 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id l188so5095107lfe.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 04:51:56 -0700 (PDT)
Date: Thu, 16 Jun 2016 14:51:54 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv9-rebased2 05/37] khugepaged: recheck pmd after mmap_sem
 re-acquired
Message-ID: <20160616115154.GE18137@node.shutemov.name>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1466021202-61880-6-git-send-email-kirill.shutemov@linux.intel.com>
 <20160616114603.GA19710@gezgin>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160616114603.GA19710@gezgin>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, sergey.senozhatsky.work@gmail.com

On Thu, Jun 16, 2016 at 02:47:14PM +0300, Ebru Akagunduz wrote:
> On Wed, Jun 15, 2016 at 11:06:10PM +0300, Kirill A. Shutemov wrote:
> > Vlastimil noted[1] that pmd can be no longer valid after we drop
> > mmap_sem. We need recheck it once mmap_sem taken again.
> > 
> > [1] http://lkml.kernel.org/r/12918dcd-a695-c6f4-e06f-69141c5f357f@suse.cz
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  mm/huge_memory.c | 6 ++++++
> >  1 file changed, 6 insertions(+)
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index d7ccc8558187..0efdad975659 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -2437,6 +2437,9 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
> >  			/* vma is no longer available, don't continue to swapin */
> >  			if (hugepage_vma_revalidate(mm, address))
> >  				return false;
> > +			/* check if the pmd is still valid */
> > +			if (mm_find_pmd(mm, address) != pmd)
> > +				return false;
> >  		}
> Thanks for fixing this.
> 
> >  		if (ret & VM_FAULT_ERROR) {
> >  			trace_mm_collapse_huge_page_swapin(mm, swapped_in, 0);
> > @@ -2522,6 +2525,9 @@ static void collapse_huge_page(struct mm_struct *mm,
> >  	result = hugepage_vma_revalidate(mm, address);
> >  	if (result)
> >  		goto out;
> > +	/* check if the pmd is still valid */
> > +	if (mm_find_pmd(mm, address) != pmd)
> > +		goto out;
> >  
> However here, I don't know do we need to check pmd.
> Because in collapse_huge_page; pmd is newly created,
> after taking mmap_sem read:
> {
> 
> 	pmd_t *pmd, _pmd;
>         pte_t *pte;
>         ...
>         down_read(&mm->mmap_sem);
>         result = hugepage_vma_revalidate(mm, address);
>         ...
>         pmd = mm_find_pmd(mm, address);
>         ...
> 
> Therefore it did not seem like a problem for me.

I guess you're looking on the first hugepage_vma_revalidate() in
collapse_huge_page(). The patch fixes issue after the second one:

	pmd_t *pmd, _pmd;
        pte_t *pte;
        ...
        down_read(&mm->mmap_sem);
        result = hugepage_vma_revalidate(mm, address);
        ...
        pmd = mm_find_pmd(mm, address);
        ...
	up_read(&mm->mmap_sem);
	...
	down_write(&mm->mmap_sem);
	result = hugepage_vma_revalidate(mm, address);
	if (mm_find_pmd(mm, address) != pmd)
		 goto out;


-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
