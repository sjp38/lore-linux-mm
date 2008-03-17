Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2HKPwKW019376
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 16:25:58 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2HKR6Om186970
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 14:27:06 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2HKR514029796
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 14:27:05 -0600
Subject: Re: [PATCH] [4/18] Add basic support for more than one hstate in
	hugetlbfs
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080317015817.DE00E1B41E0@basil.firstfloor.org>
References: <20080317258.659191058@firstfloor.org>
	 <20080317015817.DE00E1B41E0@basil.firstfloor.org>
Content-Type: text/plain
Date: Mon, 17 Mar 2008 15:28:52 -0500
Message-Id: <1205785732.10849.80.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

With this patch you will call try_to_free_low on all registered page
sizes.  As written, when a user reduces the number of one page size, all
page sizes could be affected.  I don't think that's what you want to do.
Perhaps just call do_try_to_free_low() on the hstate in question.

On Mon, 2008-03-17 at 02:58 +0100, Andi Kleen wrote:
> Signed-off-by: Andi Kleen <ak@suse.de>
> 
> ---
>  mm/hugetlb.c |   15 +++++++++++----
>  1 file changed, 11 insertions(+), 4 deletions(-)
> 
> Index: linux/mm/hugetlb.c
> ===================================================================
> --- linux.orig/mm/hugetlb.c
> +++ linux/mm/hugetlb.c
> @@ -550,26 +550,33 @@ static unsigned int cpuset_mems_nr(unsig
> 
>  #ifdef CONFIG_SYSCTL
>  #ifdef CONFIG_HIGHMEM
> -static void try_to_free_low(unsigned long count)
> +static void do_try_to_free_low(struct hstate *h, unsigned long count)
>  {
> -	struct hstate *h = &global_hstate;
>  	int i;
> 
>  	for (i = 0; i < MAX_NUMNODES; ++i) {
>  		struct page *page, *next;
>  		struct list_head *freel = &h->hugepage_freelists[i];
>  		list_for_each_entry_safe(page, next, freel, lru) {
> -			if (count >= nr_huge_pages)
> +			if (count >= h->nr_huge_pages)
>  				return;
>  			if (PageHighMem(page))
>  				continue;
>  			list_del(&page->lru);
> -			update_and_free_page(page);
> +			update_and_free_page(h, page);
>  			h->free_huge_pages--;
>  			h->free_huge_pages_node[page_to_nid(page)]--;
>  		}
>  	}
>  }
> +
> +static void try_to_free_low(unsigned long count)
> +{
> +	struct hstate *h;
> +	for_each_hstate (h) {
> +		do_try_to_free_low(h, count);
> +	}
> +}
>  #else
>  static inline void try_to_free_low(unsigned long count)
>  {
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
