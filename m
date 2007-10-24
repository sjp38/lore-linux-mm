Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9OJqxvs011159
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 15:52:59 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9OJqxS3080276
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 13:52:59 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9OJqxlh021616
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 13:52:59 -0600
Subject: Re: [PATCH 3/3] [PATCH] hugetlb: Enforce quotas during reservation
	for shared mappings
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1193252821.4039.33.camel@localhost>
References: <20071024132335.13013.76227.stgit@kernel>
	 <20071024132408.13013.81566.stgit@kernel>
	 <1193252821.4039.33.camel@localhost>
Content-Type: text/plain
Date: Wed, 24 Oct 2007 14:52:58 -0500
Message-Id: <1193255578.18417.63.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ken Chen <kenchen@google.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-24 at 12:07 -0700, Dave Hansen wrote:
> On Wed, 2007-10-24 at 06:24 -0700, Adam Litke wrote:
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index eaade8c..5fc075e 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -769,6 +769,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
> >  	struct page *page;
> >  	struct address_space *mapping;
> >  	pte_t new_pte;
> > +	int shared_page = vma->vm_flags & VM_SHARED;
> > 
> >  	mapping = vma->vm_file->f_mapping;
> >  	idx = ((address - vma->vm_start) >> HPAGE_SHIFT)
> > @@ -784,23 +785,24 @@ retry:
> >  		size = i_size_read(mapping->host) >> HPAGE_SHIFT;
> >  		if (idx >= size)
> >  			goto out;
> > -		if (hugetlb_get_quota(mapping, 1))
> > +		/* Shared pages are quota-accounted at reservation/mmap time */
> > +		if (!shared_page && hugetlb_get_quota(mapping, 1))
> >  			goto out;
> >  		page = alloc_huge_page(vma, address);
> 
> Since alloc_huge_page() gets the VMA it could, in theory, be doing the
> accounting.  The other user, hugetlb_cow(), seems to have a similar code
> path.  But, it doesn't have to worry about shared_page, right?  We can
> only have COWs on MAP_PRIVATE.
> 
> I'm just trying to find ways to future-proof the quotas since they
> already got screwed up once.  The fewer call sites we have for them, the
> fewer places they can get screwed up. :)

Yep.  Originally I wanted to put the hugetlb_get_quota() call inside
alloc_huge_page() but the devil is in the details.  Failure to get quota
needs to result in a SIGBUS whereas a standard allocation failure is
OOM.  Because of this, we'd still need special handling of the
alloc_huge_page() return value.  While that can be done easily enough, I
didn't think it was worth it.  

> >  		if (!page) {
> > -			hugetlb_put_quota(mapping, 1);
> > +			if (!shared_page)
> > +				hugetlb_put_quota(mapping, 1);
> >  			ret = VM_FAULT_OOM;
> >  			goto out;
> >  		}
> >  		clear_huge_page(page, address);
> > 
> > -		if (vma->vm_flags & VM_SHARED) {
> > +		if (shared_page) {
> >  			int err;
> > 
> >  			err = add_to_page_cache(page, mapping, idx, GFP_KERNEL);
> >  			if (err) {
> >  				put_page(page);
> > -				hugetlb_put_quota(mapping, 1);
> >  				if (err == -EEXIST)
> >  					goto retry;
> >  				goto out;
> 
> To where was this quota put moved?  Is it because we're in a fault path
> here, and shared pages don't modify quotas during faults, only at
> mmap/truncate() time now?

That's right.

> >  backout:
> >  	spin_unlock(&mm->page_table_lock);
> > -	hugetlb_put_quota(mapping, 1);
> > +	if (!shared_page)
> > +		hugetlb_put_quota(mapping, 1);
> >  	unlock_page(page);
> >  	put_page(page);
> >  	goto out;
> > @@ -1144,6 +1147,8 @@ int hugetlb_reserve_pages(struct inode *inode, long from, long to)
> >  	if (chg < 0)
> >  		return chg;
> > 
> > +	if (hugetlb_get_quota(inode->i_mapping, chg))
> > +		return -ENOSPC;
> >  	ret = hugetlb_acct_memory(chg);
> >  	if (ret < 0)
> >  		return ret;
> > @@ -1154,5 +1159,6 @@ int hugetlb_reserve_pages(struct inode *inode, long from, long to)
> >  void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
> >  {
> >  	long chg = region_truncate(&inode->i_mapping->private_list, offset);
> > -	hugetlb_acct_memory(freed - chg);
> > +	hugetlb_put_quota(inode->i_mapping, (chg - freed));
> > +	hugetlb_acct_memory(-(chg - freed));
> >  }
> 
> Would it be any easier to just do all of the quota operations in
> _either_ truncate_hugepages() or in here?  Could you skip the quota
> operation in truncate_hugepages()'s while() loop, and just put the quota
> for the entire region in hugetlb_unreserve_pages()?

Yep, we certainly could do that.  I'll change it to that for the next
version so we can see how it looks.

> void hugetlb_unreserve_pages(struct inode *inode, long offset, long already_freed)
> {
>  	long total_truncated = region_truncate(&inode->i_mapping->private_list, offset);
> 	long newly_freed = total_truncated - already_freed;
> 	hugetlb_put_quota(inode->i_mapping, newly_freed);
> 	hugetlb_acct_memory(-newly_freed);
> }
> 
> I do see several hugetlb_put_quota()/hugetlb_acct_memory() pairs next to
> each other.  Do they deserve to be lumped together in one helper?

I don't really think putting them together in one helper would do
anything to improve readability.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
