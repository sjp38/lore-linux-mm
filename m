Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l93HerbW015610
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 13:40:53 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l93HerUU693774
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 13:40:53 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l93Heqmj029571
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 13:40:52 -0400
Subject: Re: [PATCH] hugetlb: Fix pool resizing corner case
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071003154748.19516.90317.stgit@kernel>
References: <20071003154748.19516.90317.stgit@kernel>
Content-Type: text/plain
Date: Wed, 03 Oct 2007 10:40:48 -0700
Message-Id: <1191433248.4939.79.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-03 at 08:47 -0700, Adam Litke wrote:
> When shrinking the size of the hugetlb pool via the nr_hugepages sysctl, we
> are careful to keep enough pages around to satisfy reservations.  But the
> calculation is flawed for the following scenario:
> 
> Action                          Pool Counters (Total, Free, Resv)
> ======                          =============
> Set pool to 1 page              1 1 0
> Map 1 page MAP_PRIVATE          1 1 0
> Touch the page to fault it in   1 0 0
> Set pool to 3 pages             3 2 0
> Map 2 pages MAP_SHARED          3 2 2
> Set pool to 2 pages             2 1 2 <-- Mistake, should be 3 2 2
> Touch the 2 shared pages        2 0 1 <-- Program crashes here
> 
> The last touch above will terminate the process due to lack of huge pages.
> 
> This patch corrects the calculation so that it factors in pages being used
> for private mappings.  Andrew, this is a standalone fix suitable for
> mainline.  It is also now corrected in my latest dynamic pool resizing
> patchset which I will send out soon.
> 
> Signed-off-by: Adam Litke <agl@us.ibm.com>
> ---
> 
>  mm/hugetlb.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 84c795e..7af3908 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -224,14 +224,14 @@ static void try_to_free_low(unsigned long count)
>  	for (i = 0; i < MAX_NUMNODES; ++i) {
>  		struct page *page, *next;
>  		list_for_each_entry_safe(page, next, &hugepage_freelists[i], lru) {
> +			if (count >= nr_huge_pages)
> +				return;
>  			if (PageHighMem(page))
>  				continue;
>  			list_del(&page->lru);
>  			update_and_free_page(page);
>  			free_huge_pages--;
>  			free_huge_pages_node[page_to_nid(page)]--;
> -			if (count >= nr_huge_pages)
> -				return;
>  		}
>  	}
>  }

That's an excellent problem description.  I'm just a bit hazy on how the
patch fixes it. :)

What is the actual error in this loop?  The fact that we can go trying
to free pages when the count is actually OK?

BTW, try_to_free_low(count) kinda sucks for a function name.  Is that
count the number of pages we're trying to end up with, or the total
number of low pages that we're trying to free?

Also, as I look at try_to_free_low(), why do we need to #ifdef it out in
the case of !HIGHMEM?  If we have CONFIG_HIGHMEM=yes, we still might not
have any _actual_ high memory.  So, they loop obviously doesn't *hurt*
when there is no high memory.  

> @@ -251,7 +251,7 @@ static unsigned long set_max_huge_pages(unsigned long count)
>  		return nr_huge_pages;
> 
>  	spin_lock(&hugetlb_lock);
> -	count = max(count, resv_huge_pages);
> +	count = max(count, resv_huge_pages + nr_huge_pages - free_huge_pages);
>  	try_to_free_low(count);
>  	while (count < nr_huge_pages) {
>  		struct page *page = dequeue_huge_page(NULL, 0);

The real problem with this line is that "count" is too ambiguous. :)

We could rewrite the original max() line this way:

	if (resv_huge_pages > nr_of_pages_to_end_up_with)
		nr_of_pages_to_end_up_with = resv_huge_pages;
	try_to_make_the_total_nr_of_hpages(nr_of_pages_to_end_up_with);

Which makes it more clear that you're setting the number of total pages
to the number of reserved pages, which is obviously screwy.

OK, so this is actually saying: "count can never go below
resv_huge_pages+nr_huge_pages"?

Could we change try_to_free_low() to free a distinct number of pages?

	if (count > free_huge_pages)
		count = free_huge_pages;
	try_to_free_nr_huge_pages(count);

I feel a bit sketchy about the "resv_huge_pages + nr_huge_pages -
free_huge_pages" logic.  Could you elaborate a bit there on what the
rules are?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
