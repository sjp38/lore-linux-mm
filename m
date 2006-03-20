Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Subject: RE: [patch] hugetlb strict commit accounting - v3
Date: Mon, 20 Mar 2006 10:48:40 -0800
Message-ID: <B14CB421AD82C944A59ED6C1CA4E068F18F696@scsmsx404.amr.corp.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: David Gibson <david@gibson.dropbear.id.au>, wli@holomorphy.com, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Adam Litke wrote on Monday, March 20, 2006 7:35 AM
> On Thu, 2006-03-09 at 19:14 -0800, Chen, Kenneth W wrote:
> > @@ -98,6 +98,12 @@ struct page *alloc_huge_page(struct vm_a
> >  	int i;
> >  
> >  	spin_lock(&hugetlb_lock);
> > +	if (vma->vm_flags & VM_MAYSHARE)
> > +		resv_huge_pages--;
> > +	else if (free_huge_pages <= resv_huge_pages) {
> > +		spin_unlock(&hugetlb_lock);
> > +		return NULL;
> > +	}
> >  	page = dequeue_huge_page(vma, addr);
> >  	if (!page) {
> >  		spin_unlock(&hugetlb_lock);
> 
> Unfortunately this will break down when two or more threads race to
> allocate the same page. You end up with a double-decrement of
> resv_huge_pages even though only one thread will win the race.

Are you sure?  David introduced hugetlb_instantiation_mutex to serialize
entire hugetlb fault path, such race is not possible anymore. I
previously
quipped about it, and soon realized that for private mapping, such thing
is inevitable. And even for shared mapping, that means not needing a
back
out path.  I will add it for defensive measure.

Thanks for bring this up though, there is one place where it still have
problem - allocation can fail under file system quota.

Which brings up another interesting question: should private mapping
hold
file system quota?  If it does as it is now, that means file system
quota
need to be reserved up front along with hugetlb page reservation.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
