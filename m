Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9OJIf4d009757
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 15:18:41 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9OJIfa2103266
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 15:18:41 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9OJIejB022664
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 15:18:40 -0400
Subject: Re: [PATCH 1/3] [FIX] hugetlb: Fix broken fs quota management
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1193252583.18417.52.camel@localhost.localdomain>
References: <20071024132335.13013.76227.stgit@kernel>
	 <20071024132345.13013.36192.stgit@kernel>
	 <1193251414.4039.14.camel@localhost>
	 <1193252583.18417.52.camel@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 24 Oct 2007 12:18:38 -0700
Message-Id: <1193253518.4039.41.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ken Chen <kenchen@google.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-24 at 14:03 -0500, Adam Litke wrote:
> On Wed, 2007-10-24 at 11:43 -0700, Dave Hansen wrote:
> > On Wed, 2007-10-24 at 06:23 -0700, Adam Litke wrote:
> > > --- a/mm/hugetlb.c
> > > +++ b/mm/hugetlb.c
> > > @@ -685,7 +685,17 @@ void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
> > >  	flush_tlb_range(vma, start, end);
> > >  	list_for_each_entry_safe(page, tmp, &page_list, lru) {
> > >  		list_del(&page->lru);
> > > -		put_page(page);
> > > +		if (put_page_testzero(page)) {
> > > +			/*
> > > +			 * When releasing the last reference to a page we must
> > > +			 * credit the quota.  For MAP_PRIVATE pages this occurs
> > > +			 * when the last PTE is cleared, for MAP_SHARED pages
> > > +			 * this occurs when the file is truncated.
> > > +			 */

Could we change this comment a bit?  It isn't completely clear that
_this_ code is never called for shared pages.  

/*
 * We'll never get here for MAP_SHARED.  We always
 * have another reference out for the address_space,
 * and will never get to page_count()==0 during
 * an unmap.  We put the quota for these in
 * some_function() instead.
 */

> > > +			VM_BUG_ON(PageMapping(page));
> > > +			hugetlb_put_quota(vma->vm_file->f_mapping);
> > > +			free_huge_page(page);
> > > +		}
> > >  	}
> > >  }
> > 
> > That's a pretty good mechanism to use.   
> > 
> > This particular nugget is for MAP_PRIVATE pages only, right?  The shared
> > ones should have another ref out on them for the 'mapping' too, so won't
> > get released at unmap, right?
> 
> Yep that's right.  Shared pages are released by truncate_hugepages()
> when the ref for the mapping is dropped.
> 
> > It isn't obvious from the context here, but how did free_huge_page() get
> > called for these pages before?
> 
> put_page() calls put_compound_page() which looks up the page dtor
> (free_huge_page) and calls it.

Ahhh, and put_page_testzero() doesn't hook into the destructors at all.
I wish it had an __ prefixed. :)

> > Can you use free_pages_check() here to get some more comprehensive page
> > tests?  Just a cursory look at it makes me think that it should work.  
> 
> Yeah, that should work but I am a little hesitant to use
> free_pages_check() because it may happen to "just work."  None of the
> other hugetlb code concerns itself with all of those page flags so it
> seems a little out of place to start caring only here.

I just think it is more comprehensive.  If you're going to check
PageMapping(), should you not also check page->mapping to make sure they
are consistent?  Anyway, bad_page() may also be more appropriate than a
VM_BUG_ON().  It gets you a much prettier message.

Your comment about this happening when the last PTE is shot down would
be reinforced by having the page_mapcount() check in free_pages_check().
But, it would also be worthless since we don't do rmap for huge
pages. ;)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
