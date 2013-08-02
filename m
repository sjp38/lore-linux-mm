Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 131016B0032
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 15:41:09 -0400 (EDT)
Date: Fri, 2 Aug 2013 15:41:02 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/4] mm, migrate: allocation new page lazyily in
 unmap_and_move()
Message-ID: <20130802194102.GV715@cmpxchg.org>
References: <1375409279-16919-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1375409279-16919-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375409279-16919-2-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Fri, Aug 02, 2013 at 11:07:57AM +0900, Joonsoo Kim wrote:
> We don't need a new page and then go out immediately if some condition
> is met. Allocation has overhead in comparison with some condition check,
> so allocating lazyily is preferable solution.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 6f0c244..86db87e 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -864,10 +864,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
>  {
>  	int rc = 0;
>  	int *result = NULL;
> -	struct page *newpage = get_new_page(page, private, &result);
> -
> -	if (!newpage)
> -		return -ENOMEM;
> +	struct page *newpage = NULL;
>  
>  	if (page_count(page) == 1) {
>  		/* page was freed from under us. So we are done. */
> @@ -878,6 +875,10 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
>  		if (unlikely(split_huge_page(page)))
>  			goto out;
>  
> +	newpage = get_new_page(page, private, &result);
> +	if (!newpage)
> +		return -ENOMEM;

get_new_page() sets up result to communicate error codes from the
following checks.  While the existing ones (page freed and thp split
failed) don't change rc, somebody else might add a condition whose
error code should be propagated back into *result but miss it.

Please leave get_new_page() where it is.  The win from this change is
not big enough to risk these problems.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
