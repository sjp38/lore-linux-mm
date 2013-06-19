Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id ECF0F6B0037
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 04:53:20 -0400 (EDT)
Date: Wed, 19 Jun 2013 09:53:16 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm/vmscan.c: 'lru' may be used without initialized after
 the patch "3abf380..." in next-20130607 tree
Message-ID: <20130619085315.GK1875@suse.de>
References: <51C155D1.3090304@asianux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <51C155D1.3090304@asianux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: hannes@cmpxchg.org, riel@redhat.com, mhocko@suse.cz, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jun 19, 2013 at 02:55:13PM +0800, Chen Gang wrote:
> 
> 'lru' may be used without initialized, so need regressing part of the
> related patch.
> 
> The related patch:
>   "3abf380 mm: remove lru parameter from __lru_cache_add and lru_cache_add_lru"
> 
> 
> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> ---
>  mm/vmscan.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index fe73724..e92b1858 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -595,6 +595,7 @@ redo:
>  		 * unevictable page on [in]active list.
>  		 * We know how to handle that.
>  		 */
> +		lru = !!TestClearPageActive(page) + page_lru_base_type(page);
>  		lru_cache_add(page);

Thanks for catching this but I have one question. Why are you clearing
the active bit?

Before 3abf380 we did

active = TestClearPageActive(page);
lru = active + page_lru_base_type(page);
lru_cache_add_lru(page, lru);

so if the page was active before then it gets added to the active list. When
3abf380 is applied. it becomes.

Leave PageActive alone
lru_cache_add(page);
..... until __pagevec_lru_add -> __pagevec_lru_add_fn
int file = page_is_file_cache(page);
int active = PageActive(page);
enum lru_list lru = page_lru(page);

After your patch it's

Clear PageActive
lru_cache_add(page)
.......
always add to inactive list

I do not think you intended to do this and if you did, it deserves far
more comment than being a compile warning fix. In putback_lru_page we only
care about whether the lru was unevictable or not. Hence I think what you
meant to do was simply

	lru = page_lru_base_type(page);

If you agree then can you resend a revised version to Andrew please?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
