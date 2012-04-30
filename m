Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id D76886B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 16:19:45 -0400 (EDT)
Received: by iajr24 with SMTP id r24so6763301iaj.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2012 13:19:45 -0700 (PDT)
Date: Mon, 30 Apr 2012 13:19:27 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] hugetlb: avoid gratuitous BUG_ON in hugetlb_fault() ->
 hugetlb_cow()
In-Reply-To: <201204291936.q3TJa4Mv008924@farm-0027.internal.tilera.com>
Message-ID: <alpine.LSU.2.00.1204301308090.2829@eggly.anvils>
References: <201204291936.q3TJa4Mv008924@farm-0027.internal.tilera.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>, Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 29 Apr 2012, Chris Metcalf wrote:

> Commit 66aebce747eaf added code to avoid a race condition by
> elevating the page refcount in hugetlb_fault() while calling
> hugetlb_cow().  However, one code path in hugetlb_cow() includes
> an assertion that the page count is 1, whereas it may now also
> have the value 2 in this path.
> 
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
> ---
> We discovered this while testing the original path; one particular
> application triggered this due to the specific number of huge pages
> it started with.

Well done finding that.  But I think it would be better to remove the
BUG_ON() than complicate it, and then no need to add a comment there.

IIRC it's unsafe to make any assertions about what a page_count() may
be, beyond whether it's 0 or non-0: because of speculative accesses to
the page from elsewhere (perhaps it used to be visible in a radix_tree,
perhaps __isolate_lru_pages is having a go at it).

I'd say that BUG_ON() has outlived its usefulness, and should just be
eliminated now: but git "blames" Mel for it, so let's see if he agrees.

Hugh

> 
>  mm/hugetlb.c |    9 ++++++++-
>  1 files changed, 8 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index cd65cb1..d5b0254 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2498,7 +2498,14 @@ retry_avoidcopy:
>  		if (outside_reserve) {
>  			BUG_ON(huge_pte_none(pte));
>  			if (unmap_ref_private(mm, vma, old_page, address)) {
> -				BUG_ON(page_count(old_page) != 1);
> +				/*
> +				 * Page refcount may be 1 in the common case,
> +				 * but since we may do an extra get_page()
> +				 * when called from hugetlb_fault(), we allow
> +				 * a page refcount of 2 as well.
> +				 */
> +				BUG_ON(page_count(old_page) != 1 &&
> +				       page_count(old_page) != 2);
>  				BUG_ON(huge_pte_none(pte));
>  				spin_lock(&mm->page_table_lock);
>  				ptep = huge_pte_offset(mm, address & huge_page_mask(h));
> -- 
> 1.6.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
