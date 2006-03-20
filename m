Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k2KKLxk2018065
	for <linux-mm@kvack.org>; Mon, 20 Mar 2006 15:21:59 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k2KKLkOM200818
	for <linux-mm@kvack.org>; Mon, 20 Mar 2006 15:21:49 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k2KKLjPs026810
	for <linux-mm@kvack.org>; Mon, 20 Mar 2006 15:21:45 -0500
Subject: RE: [patch] hugetlb strict commit accounting - v3
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <B14CB421AD82C944A59ED6C1CA4E068F18F696@scsmsx404.amr.corp.intel.com>
References: <B14CB421AD82C944A59ED6C1CA4E068F18F696@scsmsx404.amr.corp.intel.com>
Content-Type: text/plain
Date: Mon, 20 Mar 2006 14:21:44 -0600
Message-Id: <1142886104.14508.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: David Gibson <david@gibson.dropbear.id.au>, wli@holomorphy.com, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2006-03-20 at 10:48 -0800, Chen, Kenneth W wrote:
> Adam Litke wrote on Monday, March 20, 2006 7:35 AM
> > On Thu, 2006-03-09 at 19:14 -0800, Chen, Kenneth W wrote:
> > > @@ -98,6 +98,12 @@ struct page *alloc_huge_page(struct vm_a
> > >  	int i;
> > >  
> > >  	spin_lock(&hugetlb_lock);
> > > +	if (vma->vm_flags & VM_MAYSHARE)
> > > +		resv_huge_pages--;
> > > +	else if (free_huge_pages <= resv_huge_pages) {
> > > +		spin_unlock(&hugetlb_lock);
> > > +		return NULL;
> > > +	}
> > >  	page = dequeue_huge_page(vma, addr);
> > >  	if (!page) {
> > >  		spin_unlock(&hugetlb_lock);
> > 
> > Unfortunately this will break down when two or more threads race to
> > allocate the same page. You end up with a double-decrement of
> > resv_huge_pages even though only one thread will win the race.
> 
> Are you sure?  David introduced hugetlb_instantiation_mutex to serialize
> entire hugetlb fault path, such race is not possible anymore. I
> previously
> quipped about it, and soon realized that for private mapping, such thing
> is inevitable. And even for shared mapping, that means not needing a
> back
> out path.  I will add it for defensive measure.

You're right.  I forgot about that patch... With it applied, everything
works correctly.

> Thanks for bring this up though, there is one place where it still have
> problem - allocation can fail under file system quota.
> 
> Which brings up another interesting question: should private mapping
> hold
> file system quota?  If it does as it is now, that means file system
> quota
> need to be reserved up front along with hugetlb page reservation.

I must profess my ignorance about the filesystem quota part.  I've never
seen that used in practice as a resource limiting lever.  That said, I
think we need to ensure either: both shared and private hold quota, or
neither hold it.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
