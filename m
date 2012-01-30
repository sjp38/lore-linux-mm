Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 8065F6B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 06:15:26 -0500 (EST)
Date: Mon, 30 Jan 2012 11:15:22 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 02/15] mm: page_alloc: update migrate type of pages on
 pcp when isolating
Message-ID: <20120130111522.GE25268@csn.ul.ie>
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <1327568457-27734-3-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1327568457-27734-3-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

On Thu, Jan 26, 2012 at 10:00:44AM +0100, Marek Szyprowski wrote:
> From: Michal Nazarewicz <mina86@mina86.com>
> 
> This commit changes set_migratetype_isolate() so that it updates
> migrate type of pages on pcp list which is saved in their
> page_private.
> 
> Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> ---
>  include/linux/page-isolation.h |    6 ++++++
>  mm/page_alloc.c                |    1 +
>  mm/page_isolation.c            |   24 ++++++++++++++++++++++++
>  3 files changed, 31 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
> index 051c1b1..8c02c2b 100644
> --- a/include/linux/page-isolation.h
> +++ b/include/linux/page-isolation.h
> @@ -27,6 +27,12 @@ extern int
>  test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn);
>  
>  /*
> + * Check all pages in pageblock, find the ones on pcp list, and set
> + * their page_private to MIGRATE_ISOLATE.
> + */
> +extern void update_pcp_isolate_block(unsigned long pfn);
> +
> +/*
>   * Internal funcs.Changes pageblock's migrate type.
>   * Please use make_pagetype_isolated()/make_pagetype_movable().
>   */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index e1c5656..70709e7 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5465,6 +5465,7 @@ out:
>  	if (!ret) {
>  		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
>  		move_freepages_block(zone, page, MIGRATE_ISOLATE);
> +		update_pcp_isolate_block(pfn);
>  	}
>  
>  	spin_unlock_irqrestore(&zone->lock, flags);
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 4ae42bb..9ea2f6e 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -139,3 +139,27 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
>  	spin_unlock_irqrestore(&zone->lock, flags);
>  	return ret ? 0 : -EBUSY;
>  }
> +
> +/* must hold zone->lock */
> +void update_pcp_isolate_block(unsigned long pfn)
> +{
> +	unsigned long end_pfn = pfn + pageblock_nr_pages;
> +	struct page *page;
> +
> +	while (pfn < end_pfn) {
> +		if (!pfn_valid_within(pfn)) {
> +			++pfn;
> +			continue;
> +		}
> +

There is a potential problem here that you need to be aware of.
set_pageblock_migratetype() is called from start_isolate_page_range().
I do not think there is a guarantee that pfn + pageblock_nr_pages is
not in a different block of MAX_ORDER_NR_PAGES. If that is right then
your options are to add a check like this;

if ((pfn & (MAX_ORDER_NR_PAGES - 1)) == 0 && !pfn_valid(pfn))
	break;

or else ensure that end_pfn is always MAX_ORDER_NR_PAGES aligned and in
the same block as pfn and relying on the caller to have called
pfn_valid.

> +		page = pfn_to_page(pfn);
> +		if (PageBuddy(page)) {
> +			pfn += 1 << page_order(page);
> +		} else if (page_count(page) == 0) {
> +			set_page_private(page, MIGRATE_ISOLATE);
> +			++pfn;

This is dangerous for two reasons. If the page_count is 0, it could
be because the page is in the process of being freed and is not
necessarily on the per-cpu lists yet and you cannot be sure if the
contents of page->private are important. Second, there is nothing to
prevent another CPU allocating this page from its per-cpu list while
the private field is getting updated from here which might lead to
some interesting races.

I recognise that what you are trying to do is respond to Gilad's
request that you really check if an IPI here is necessary. I think what
you need to do is check if a page with a count of 0 is encountered
and if it is, then a draining of the per-cpu lists is necessary. To
address Gilad's concerns, be sure to only this this once per attempt at
CMA rather than for every page encountered with a count of 0 to avoid a
storm of IPIs.

> +		} else {
> +			++pfn;
> +		}
> +	}
> +}

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
