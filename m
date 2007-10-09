Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l99LKqeq019095
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 17:20:52 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l99LKjHT428364
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 15:20:46 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l99LKjf0020303
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 15:20:45 -0600
Subject: Re: [PATCH] hugetlb: Fix dynamic pool resize failure case
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071009155845.20191.85647.stgit@kernel>
References: <20071009155845.20191.85647.stgit@kernel>
Content-Type: text/plain
Date: Tue, 09 Oct 2007 14:20:44 -0700
Message-Id: <1191964844.31114.28.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-10-09 at 08:58 -0700, Adam Litke wrote:
> index 9b3dfac..f349c16 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -281,8 +281,11 @@ free:
>  		list_del(&page->lru);
>  		if ((--needed) >= 0)
>  			enqueue_huge_page(page);
> -		else
> -			update_and_free_page(page);
> +		else {
> +			spin_unlock(&hugetlb_lock);
> +			put_page(page);
> +			spin_lock(&hugetlb_lock);
> +		}
>  	}

update_and_free_page() does several things:
1. it decrements nr_huge_pages(_node[])
2. it resets the member page flags to some known values
3. clears the compound page destructor
4. clears the page refcount (to 1)
5. actually frees the page back to the allocator

put_page() does several things, too:
1. put_page() hits PageCompound(), then calls put_compound_page()
2. put_compound_page() calls the compound page destructor which is set
   to free_huge_page() (this was set in alloc_buddy_huge_page())
3. free_huge_page() checks page_count(), takes the hugetlb_lock, and
   calls enqueue_huge_page()
4. enqueue_huge_page() puts the page back in hugepage_freelists[nid],
   then _increments_ nr_huge_pages(_node[])

This seems weird to me that you're replacing a function with something
that eventually does the opposite.  update_and_free_page() also did
nothing with the hugepage_freelists[], which enqueue_huge_page() does.
Something doesn't quite add up here.  Did you realize that the destuctor
was going to get called?  Or, did I misread it, and the destructor is
_not_ called?

I also think it's a crime that alloc_buddy_huge_page() doesn't share
code with alloc_fresh_huge_page().  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
