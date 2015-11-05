Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6D33B82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 07:58:41 -0500 (EST)
Received: by wmll128 with SMTP id l128so12789965wml.0
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 04:58:41 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id 17si9767404wmg.112.2015.11.05.04.58.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 04:58:40 -0800 (PST)
Received: by wmll128 with SMTP id l128so12789620wml.0
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 04:58:40 -0800 (PST)
Date: Thu, 5 Nov 2015 14:58:38 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 4/4] mm: prepare page_referenced() and page_idle to new
 THP refcounting
Message-ID: <20151105125838.GF7614@node.shutemov.name>
References: <1446564375-72143-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1446564375-72143-5-git-send-email-kirill.shutemov@linux.intel.com>
 <20151105091013.GC29259@esperanza>
 <20151105092459.GC7614@node.shutemov.name>
 <20151105120726.GD29259@esperanza>
 <20151105123606.GE7614@node.shutemov.name>
 <20151105125354.GE29259@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151105125354.GE29259@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Nov 05, 2015 at 03:53:54PM +0300, Vladimir Davydov wrote:
> On Thu, Nov 05, 2015 at 02:36:06PM +0200, Kirill A. Shutemov wrote:
> > On Thu, Nov 05, 2015 at 03:07:26PM +0300, Vladimir Davydov wrote:
> > > @@ -849,30 +836,23 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
> > >  		if (pmd_page(*pmd) != page)
> > >  			goto unlock_pmd;
> > >  
> > > -		if (vma->vm_flags & VM_LOCKED) {
> > > -			pra->vm_flags |= VM_LOCKED;
> > > -			ret = SWAP_FAIL; /* To break the loop */
> > > -			goto unlock_pmd;
> > > -		}
> > > -
> > > -		if (pmdp_clear_flush_young_notify(vma, address, pmd))
> > > -			referenced++;
> > > -		spin_unlock(ptl);
> > > +		pte = (pte_t *)pmd;
> > 
> > pmd_t and pte_t are not always compatible. We shouldn't pretend they are.
> > And we shouldn't use pte_unmap_unlock() to unlock pmd table.
> 
> Out of curiosity, is it OK that __page_check_address can call
> pte_unmap_unlock on pte returned by huge_pte_offset, which isn't really
> pte, but pmd or pud?

hugetlb is usually implemented on architectures where you can expect some
level of compatibility between page table enties on different levels.

> > What about interface like this (I'm not sure about helper's name):
> > 
> > void page_check_address_transhuge(struct page *page, struct mm_struct *mm,
> >                                    unsigned long address,
> >                                    pmd_t **pmdp, pte_t **ptep,
> > 				   spinlock_t **ptlp);
> > 
> > page_check_address_transhuge(page, mm, address, &pmd, &pte, &ptl);
> > if (pmd) {
> > 	/* handle pmd... */
> > } else if (pte) {
> > 	/* handle pte... */
> > } else {
> > 	return SWAP_AGAIN;
> > }
> > 
> > /* common stuff */
> > 
> > if (pmd)
> > 	spin_unlock(ptl);
> > else 
> > 	pte_unmap_unlock(pte, ptl);
> 
> spin_unlock(ptl);
> if (pte)
> 	pte_unmap(pte);
> 
> would look neater IMO. Other than that, I think it's OK. At least, it
> looks better and less error-prone than duplicating such a huge chunk of
> code IMO.

Okay. Could you prepare the patch?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
