Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EAD5E6B01AD
	for <linux-mm@kvack.org>; Wed, 26 May 2010 02:55:17 -0400 (EDT)
Date: Wed, 26 May 2010 15:51:56 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/7] hugetlb, rmap: add reverse mapping for hugepage
Message-ID: <20100526065156.GC7128@spritzerA.linux.bs1.fc.nec.co.jp>
References: <1273737326-21211-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1273737326-21211-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20100513152737.GE27949@csn.ul.ie>
 <20100514074641.GD10000@spritzerA.linux.bs1.fc.nec.co.jp>
 <20100514095449.GB21481@csn.ul.ie>
 <20100524071516.GC11008@spritzerA.linux.bs1.fc.nec.co.jp>
 <20100525105957.GD29038@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100525105957.GD29038@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Hi, Mel.

Thank you for the review.

On Tue, May 25, 2010 at 11:59:57AM +0100, Mel Gorman wrote:
> ...
> I'd have preferred to see the whole series but still...

OK.

> > diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> > index 78b4bc6..a574d09 100644
> > --- a/include/linux/hugetlb.h
> > +++ b/include/linux/hugetlb.h
> > @@ -14,11 +14,6 @@ struct user_struct;
> >  
> >  int PageHuge(struct page *page);
> >  
> > -static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
> > -{
> > -	return vma->vm_flags & VM_HUGETLB;
> > -}
> > -
> >  void reset_vma_resv_huge_pages(struct vm_area_struct *vma);
> >  int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
> >  int hugetlb_overcommit_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
> > @@ -77,11 +72,6 @@ static inline int PageHuge(struct page *page)
> >  	return 0;
> >  }
> >  
> > -static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
> > -{
> > -	return 0;
> > -}
> > -
> 
> You collapse two functions into one here and move them to another
> header. Is there a reason why pagemap.h could not include hugetlb.h?

Yes, hugetlb.h includes pagemap.h through mempolicy.h.
I didn't make pagemap.h depend on hugetlb.h because it makes cyclic dependency
among pagemap.h, mempolicy.h and hugetlb.h.

> It adds another header dependency which is bad but moving hugetlb stuff
> into mm.h seems bad too.

I have another choice to move the definition of is_vm_hugetlb_page() into
mm/hugetlb.c and introduce declaration of this function to pagemap.h,
but this needed a bit ugly #ifdefs and I didn't like it.
If putting hugetlb code in mm.h is worse, I'll take the second choice
in the next post.

> > @@ -2268,6 +2277,50 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
> >  	return 1;
> >  }
> >  
> > +/*
> > + * The following three functions are counterparts of ones in mm/rmap.c.
> > + * Unlike them, these functions don't have accounting code nor lru code,
> > + * because we handle hugepages differently from common anonymous pages.
> > + */
> > +static void __hugepage_set_anon_rmap(struct page *page,
> > +	struct vm_area_struct *vma, unsigned long address, int exclusive)
> > +{
> > +	struct anon_vma *anon_vma = vma->anon_vma;
> > +	BUG_ON(!anon_vma);
> > +	if (!exclusive) {
> > +		struct anon_vma_chain *avc;
> > +		avc = list_entry(vma->anon_vma_chain.prev,
> > +				 struct anon_vma_chain, same_vma);
> > +		anon_vma = avc->anon_vma;
> > +	}
> > +	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
> > +	page->mapping = (struct address_space *) anon_vma;
> > +	page->index = linear_page_index(vma, address);
> > +}
> > +
> > +static void hugepage_add_anon_rmap(struct page *page,
> > +			struct vm_area_struct *vma, unsigned long address)
> > +{
> > +	struct anon_vma *anon_vma = vma->anon_vma;
> > +	int first;
> > +	BUG_ON(!anon_vma);
> > +	BUG_ON(address < vma->vm_start || address >= vma->vm_end);
> > +	first = atomic_inc_and_test(&page->_mapcount);
> > +	if (first)
> > +		__hugepage_set_anon_rmap(page, vma, address, 0);
> > +}
> > +
> > +void hugepage_add_new_anon_rmap(struct page *page,
> > +	struct vm_area_struct *vma, unsigned long address)
> > +{
> > +	BUG_ON(address < vma->vm_start || address >= vma->vm_end);
> > +	atomic_set(&page->_mapcount, 0);
> > +	__hugepage_set_anon_rmap(page, vma, address, 1);
> > +}
> > +
> 
> Is it possible to move these to mm/rmap.c so all the anon rmap adding
> code is in the same place? In the event that __page_set_anon_rmap() is
> updated, there would be a greater chance the hugepage equivalent will be
> noticed and updated.

Sounds reasonable, I'll do it.

> I didn't spot anything particularly bad after this.  If these minor issues
> could be addressed and the full series reposted, I'll test the hugetlb side
> of things further just to be sure.

OK, thanks you :)

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
