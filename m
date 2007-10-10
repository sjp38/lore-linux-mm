Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9ADw9IZ001188
	for <linux-mm@kvack.org>; Wed, 10 Oct 2007 09:58:09 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9ADw7wL097426
	for <linux-mm@kvack.org>; Wed, 10 Oct 2007 07:58:08 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9ADw70p013474
	for <linux-mm@kvack.org>; Wed, 10 Oct 2007 07:58:07 -0600
Subject: Re: [PATCH] hugetlb: Fix dynamic pool resize failure case
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1191964844.31114.28.camel@localhost>
References: <20071009155845.20191.85647.stgit@kernel>
	 <1191964844.31114.28.camel@localhost>
Content-Type: text/plain
Date: Wed, 10 Oct 2007 08:58:06 -0500
Message-Id: <1192024686.19775.70.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-10-09 at 14:20 -0700, Dave Hansen wrote:
> On Tue, 2007-10-09 at 08:58 -0700, Adam Litke wrote:
> > index 9b3dfac..f349c16 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -281,8 +281,11 @@ free:
> >  		list_del(&page->lru);
> >  		if ((--needed) >= 0)
> >  			enqueue_huge_page(page);
> > -		else
> > -			update_and_free_page(page);
> > +		else {
> > +			spin_unlock(&hugetlb_lock);
> > +			put_page(page);
> > +			spin_lock(&hugetlb_lock);
> > +		}
> >  	}
> 
> update_and_free_page() does several things:
> 1. it decrements nr_huge_pages(_node[])
> 2. it resets the member page flags to some known values
> 3. clears the compound page destructor
> 4. clears the page refcount (to 1)
> 5. actually frees the page back to the allocator
> 
> put_page() does several things, too:
> 1. put_page() hits PageCompound(), then calls put_compound_page()
> 2. put_compound_page() calls the compound page destructor which is set
>    to free_huge_page() (this was set in alloc_buddy_huge_page())
> 3. free_huge_page() checks page_count(), takes the hugetlb_lock, and
>    calls enqueue_huge_page()

Here's where I know your looking at different kernel source than this
was meant to patch :)

> 4. enqueue_huge_page() puts the page back in hugepage_freelists[nid],
>    then _increments_ nr_huge_pages(_node[])
> 
> This seems weird to me that you're replacing a function with something
> that eventually does the opposite.  update_and_free_page() also did
> nothing with the hugepage_freelists[], which enqueue_huge_page() does.
> Something doesn't quite add up here.  Did you realize that the destuctor
> was going to get called?  Or, did I misread it, and the destructor is
> _not_ called?

With my patches applied, free_huge_page() deals with both regular and
surplus pages.  When there is a surplus, the pool needs to gravitate
back to its configured size.  In that case, pages are freed to the buddy
allocator.  In the absence of a surplus, pages are dealt with in the way
you describe above.  So put_page() does _precisely_ what is needed in
this scenario.

> I also think it's a crime that alloc_buddy_huge_page() doesn't share
> code with alloc_fresh_huge_page().  

Different issue (unrelated to this patch), but I'll have a look and see
if I can consolidate them.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
