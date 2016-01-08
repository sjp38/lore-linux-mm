Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5E9AF6B0258
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 01:26:02 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id 65so5195002pff.2
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 22:26:02 -0800 (PST)
Received: from out11.biz.mail.alibaba.com (out114-135.biz.mail.alibaba.com. [205.204.114.135])
        by mx.google.com with ESMTP id s65si2702761pfs.14.2016.01.07.22.26.00
        for <linux-mm@kvack.org>;
        Thu, 07 Jan 2016 22:26:01 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1452119824-32715-1-git-send-email-mike.kravetz@oracle.com> <04d801d14922$5d1e2f30$175a8d90$@alibaba-inc.com> <568F3D73.60901@oracle.com>
In-Reply-To: <568F3D73.60901@oracle.com>
Subject: Re: [PATCH] mm/hugetlbfs: Unmap pages if page fault raced with hole punch
Date: Fri, 08 Jan 2016 14:25:23 +0800
Message-ID: <058d01d149dd$5b436ac0$11ca4040$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mike Kravetz' <mike.kravetz@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: 'Hugh Dickins' <hughd@google.com>, 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>, 'Davidlohr Bueso' <dave@stgolabs.net>, 'Dave Hansen' <dave.hansen@linux.intel.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Michel Lespinasse' <walken@google.com>

> On 01/07/2016 12:06 AM, Hillf Danton wrote:
> >> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> >> index 0444760..0871d70 100644
> >> --- a/fs/hugetlbfs/inode.c
> >> +++ b/fs/hugetlbfs/inode.c
> >> @@ -324,11 +324,46 @@ static void remove_huge_page(struct page *page)
> >>  	delete_from_page_cache(page);
> >>  }
> >>
> >> +static inline void
> >> +hugetlb_vmdelete_list(struct rb_root *root, pgoff_t start, pgoff_t end)
> >> +{
> >> +	struct vm_area_struct *vma;
> >> +
> >> +	/*
> >> +	 * end == 0 indicates that the entire range after
> >> +	 * start should be unmapped.
> >> +	 */
> >> +	vma_interval_tree_foreach(vma, root, start, end ? end : ULONG_MAX) {
> >
> > [1] perhaps end can be reused.
> >
> >> +		unsigned long v_offset;
> >> +
> >> +		/*
> >> +		 * Can the expression below overflow on 32-bit arches?
> >> +		 * No, because the interval tree returns us only those vmas
> >> +		 * which overlap the truncated area starting at pgoff,
> >> +		 * and no vma on a 32-bit arch can span beyond the 4GB.
> >> +		 */
> >> +		if (vma->vm_pgoff < start)
> >> +			v_offset = (start - vma->vm_pgoff) << PAGE_SHIFT;
> >> +		else
> >> +			v_offset = 0;
> >> +
> >> +		if (end) {
> >> +			end = ((end - start) << PAGE_SHIFT) +
> >> +			       vma->vm_start + v_offset;
> >
> > [2] end is input to be pgoff_t, but changed to be the type of v_offset.
> > Further we cannot handle the case that end is input to be zero.
> > See the diff below please.
> >
> <snip>
> >
> > --- a/fs/hugetlbfs/inode.c	Thu Jan  7 15:04:35 2016
> > +++ b/fs/hugetlbfs/inode.c	Thu Jan  7 15:31:03 2016
> > @@ -461,8 +461,11 @@ hugetlb_vmdelete_list(struct rb_root *ro
> >  	 * end == 0 indicates that the entire range after
> >  	 * start should be unmapped.
> >  	 */
> > -	vma_interval_tree_foreach(vma, root, start, end ? end : ULONG_MAX) {
> > +	if (!end)
> > +		end = ULONG_MAX;
> > +	vma_interval_tree_foreach(vma, root, start, end) {
> >  		unsigned long v_offset;
> > +		unsigned long v_end;
> >
> >  		/*
> >  		 * Can the expression below overflow on 32-bit arches?
> > @@ -475,15 +478,12 @@ hugetlb_vmdelete_list(struct rb_root *ro
> >  		else
> >  			v_offset = 0;
> >
> > -		if (end) {
> > -			end = ((end - start) << PAGE_SHIFT) +
> > +		v_end = ((end - start) << PAGE_SHIFT) +
> >  			       vma->vm_start + v_offset;
> > -			if (end > vma->vm_end)
> > -				end = vma->vm_end;
> > -		} else
> > -			end = vma->vm_end;
> > +		if (v_end > vma->vm_end)
> > +			v_end = vma->vm_end;
> >
> > -		unmap_hugepage_range(vma, vma->vm_start + v_offset, end, NULL);
> > +		unmap_hugepage_range(vma, vma->vm_start + v_offset, v_end, NULL);
> >  	}
> >  }
> >
> > --
> 
> Unfortunately, that calculation of v_end is not correct.  I know it
> is based on the existing code, but the existing code it not correct.
> 
> I attempted to fix in a patch earlier today, but that was not correct
> either.  Below is a proposed new version of hugetlb_vmdelete_list.

Thanks Mike.

> Let me know what you think.
> 
> static inline void
> hugetlb_vmdelete_list(struct rb_root *root, pgoff_t start, pgoff_t end)
> {
> 	struct vm_area_struct *vma;
> 
> 	/*
> 	 * end == 0 indicates that the entire range after
> 	 * start should be unmapped.
> 	 */
> 	vma_interval_tree_foreach(vma, root, start, end ? end : ULONG_MAX) {
> 		unsigned long v_offset;
> 		unsigned long v_end;
> 
> 		/*
> 		 * Can the expression below overflow on 32-bit arches?
> 		 * No, because the interval tree returns us only those vmas
> 		 * which overlap the truncated area starting at pgoff,
> 		 * and no vma on a 32-bit arch can span beyond the 4GB.
> 		 */
> 		if (vma->vm_pgoff < start)
> 			v_offset = (start - vma->vm_pgoff) << PAGE_SHIFT;
> 		else
> 			v_offset = 0;
> 
> 		if (!end)
> 			v_end = vma->vm_end;
> 		else {
> 			v_end = ((end - vma->vm_pgoff) << PAGE_SHIFT)
> 							+ vma->vm_start;
> 			if (v_end > vma->vm_end)
> 				v_end = vma->vm_end;
> 		}
> 
> 		unmap_hugepage_range(vma, vma->vm_start + v_offset, v_end,
> 									NULL);
> 	}
> }
> 
Looks good to me.

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
