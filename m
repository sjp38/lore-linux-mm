Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9OJ397t008389
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 15:03:09 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9OJ35jm093024
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 13:03:05 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9OJ340E004591
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 13:03:04 -0600
Subject: Re: [PATCH 1/3] [FIX] hugetlb: Fix broken fs quota management
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1193251414.4039.14.camel@localhost>
References: <20071024132335.13013.76227.stgit@kernel>
	 <20071024132345.13013.36192.stgit@kernel>
	 <1193251414.4039.14.camel@localhost>
Content-Type: text/plain
Date: Wed, 24 Oct 2007 14:03:03 -0500
Message-Id: <1193252583.18417.52.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ken Chen <kenchen@google.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-24 at 11:43 -0700, Dave Hansen wrote:
> On Wed, 2007-10-24 at 06:23 -0700, Adam Litke wrote:
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -685,7 +685,17 @@ void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
> >  	flush_tlb_range(vma, start, end);
> >  	list_for_each_entry_safe(page, tmp, &page_list, lru) {
> >  		list_del(&page->lru);
> > -		put_page(page);
> > +		if (put_page_testzero(page)) {
> > +			/*
> > +			 * When releasing the last reference to a page we must
> > +			 * credit the quota.  For MAP_PRIVATE pages this occurs
> > +			 * when the last PTE is cleared, for MAP_SHARED pages
> > +			 * this occurs when the file is truncated.
> > +			 */
> > +			VM_BUG_ON(PageMapping(page));
> > +			hugetlb_put_quota(vma->vm_file->f_mapping);
> > +			free_huge_page(page);
> > +		}
> >  	}
> >  }
> 
> That's a pretty good mechanism to use.   
> 
> This particular nugget is for MAP_PRIVATE pages only, right?  The shared
> ones should have another ref out on them for the 'mapping' too, so won't
> get released at unmap, right?

Yep that's right.  Shared pages are released by truncate_hugepages()
when the ref for the mapping is dropped.

> It isn't obvious from the context here, but how did free_huge_page() get
> called for these pages before?

put_page() calls put_compound_page() which looks up the page dtor
(free_huge_page) and calls it.

> Can you use free_pages_check() here to get some more comprehensive page
> tests?  Just a cursory look at it makes me think that it should work.  

Yeah, that should work but I am a little hesitant to use
free_pages_check() because it may happen to "just work."  None of the
other hugetlb code concerns itself with all of those page flags so it
seems a little out of place to start caring only here.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
