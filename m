Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5F4226B01AD
	for <linux-mm@kvack.org>; Wed, 26 May 2010 05:04:16 -0400 (EDT)
Date: Wed, 26 May 2010 10:03:55 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/7] hugetlb, rmap: add reverse mapping for hugepage
Message-ID: <20100526090355.GI29038@csn.ul.ie>
References: <1273737326-21211-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1273737326-21211-2-git-send-email-n-horiguchi@ah.jp.nec.com> <20100513152737.GE27949@csn.ul.ie> <20100514074641.GD10000@spritzerA.linux.bs1.fc.nec.co.jp> <20100514095449.GB21481@csn.ul.ie> <20100524071516.GC11008@spritzerA.linux.bs1.fc.nec.co.jp> <20100525105957.GD29038@csn.ul.ie> <20100526065156.GC7128@spritzerA.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100526065156.GC7128@spritzerA.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 26, 2010 at 03:51:56PM +0900, Naoya Horiguchi wrote:
> Hi, Mel.
> 
> Thank you for the review.
> 
> On Tue, May 25, 2010 at 11:59:57AM +0100, Mel Gorman wrote:
> > ...
> > I'd have preferred to see the whole series but still...
> 
> OK.
> 
> > > diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> > > index 78b4bc6..a574d09 100644
> > > --- a/include/linux/hugetlb.h
> > > +++ b/include/linux/hugetlb.h
> > > @@ -14,11 +14,6 @@ struct user_struct;
> > >  
> > >  int PageHuge(struct page *page);
> > >  
> > > -static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
> > > -{
> > > -	return vma->vm_flags & VM_HUGETLB;
> > > -}
> > > -
> > >  void reset_vma_resv_huge_pages(struct vm_area_struct *vma);
> > >  int hugetlb_sysctl_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
> > >  int hugetlb_overcommit_handler(struct ctl_table *, int, void __user *, size_t *, loff_t *);
> > > @@ -77,11 +72,6 @@ static inline int PageHuge(struct page *page)
> > >  	return 0;
> > >  }
> > >  
> > > -static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
> > > -{
> > > -	return 0;
> > > -}
> > > -
> > 
> > You collapse two functions into one here and move them to another
> > header. Is there a reason why pagemap.h could not include hugetlb.h?
> 
> Yes, hugetlb.h includes pagemap.h through mempolicy.h.
> I didn't make pagemap.h depend on hugetlb.h because it makes cyclic dependency
> among pagemap.h, mempolicy.h and hugetlb.h.
> 

Ok, that's a good reason.

> > It adds another header dependency which is bad but moving hugetlb stuff
> > into mm.h seems bad too.
> 
> I have another choice to move the definition of is_vm_hugetlb_page() into
> mm/hugetlb.c and introduce declaration of this function to pagemap.h,
> but this needed a bit ugly #ifdefs and I didn't like it.
> If putting hugetlb code in mm.h is worse, I'll take the second choice
> in the next post.
> 

That would add an additional function call overhead to page table teardown
which would be very unfortunate. I still am not very keen on moving hugetlb
code to mm.h though.

How about moving the definition of shared_policy under a CONFIG_NUMA
block in mm_types.h and removing the dependency between hugetlb.h and
mempolicy.h?

Does anyone else see a problem with this from a "clean" perspective?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
