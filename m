Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 122566B0031
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 20:04:33 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id cc10so2147060wib.16
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 17:04:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id w48si14056695een.14.2014.04.04.17.04.30
        for <linux-mm@kvack.org>;
        Fri, 04 Apr 2014 17:04:31 -0700 (PDT)
Date: Fri, 04 Apr 2014 20:04:09 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <533f488f.48c70e0a.4f2d.291eSMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <20140404150345.92400430db3111fe21df7c7f@linux-foundation.org>
References: <533efd68.435fe00a.6936.ffffa5e7SMTPIN_ADDED_BROKEN@mx.google.com>
 <20140404150345.92400430db3111fe21df7c7f@linux-foundation.org>
Subject: Re: [PATCH] mm/hugetlb.c: add NULL check of return value of
 huge_pte_offset
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, mgorman@suse.de, andi@firstfloor.org, sasha.levin@oracle.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, linux-mm@kvack.org

On Fri, Apr 04, 2014 at 03:03:45PM -0700, Andrew Morton wrote:
> On Fri, 04 Apr 2014 14:43:33 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > huge_pte_offset() could return NULL, so we need NULL check to avoid
> > potential NULL pointer dereferences.
> > 
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -2662,7 +2662,8 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
> >  				BUG_ON(huge_pte_none(pte));
> >  				spin_lock(ptl);
> >  				ptep = huge_pte_offset(mm, address & huge_page_mask(h));
> > -				if (likely(pte_same(huge_ptep_get(ptep), pte)))
> > +				if (likely(ptep &&
> > +					   pte_same(huge_ptep_get(ptep), pte)))
> >  					goto retry_avoidcopy;
> >  				/*
> >  				 * race occurs while re-acquiring page table
> > @@ -2706,7 +2707,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
> >  	 */
> >  	spin_lock(ptl);
> >  	ptep = huge_pte_offset(mm, address & huge_page_mask(h));
> > -	if (likely(pte_same(huge_ptep_get(ptep), pte))) {
> > +	if (likely(ptep && pte_same(huge_ptep_get(ptep), pte))) {
> >  		ClearPagePrivate(new_page);
> >  
> >  		/* Break COW */
> 
> Has anyone been hitting oopses here or was this from code inspection?

It's from code inspection. This is why I didn't CCed stable.

Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
