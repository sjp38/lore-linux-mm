Date: Wed, 28 Feb 2007 10:14:30 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 1/5] Lumpy Reclaim V3
In-Reply-To: <96f80944962593738d72a803797dbddc@kernel>
Message-ID: <Pine.LNX.4.64.0702281008330.21257@schroedinger.engr.sgi.com>
References: <exportbomb.1172604830@kernel> <96f80944962593738d72a803797dbddc@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Feb 2007, Andy Whitcroft wrote:

> +static int __isolate_lru_page(struct page *page, int active)
> +{
> +	int ret = -EINVAL;
> +
> +	if (PageLRU(page) && (PageActive(page) == active)) {
> +		ret = -EBUSY;
> +		if (likely(get_page_unless_zero(page))) {
> +			/*
> +			 * Be careful not to clear PageLRU until after we're
> +			 * sure the page is not being freed elsewhere -- the
> +			 * page release code relies on it.
> +			 */
> +			ClearPageLRU(page);
> +			ret = 0;

Is that really necessary? PageLRU is clear when a page is freed right? 
And clearing PageLRU requires the zone->lru_lock since we have to move it 
off the LRU.

> -			ClearPageLRU(page);
> -			target = dst;
> +		active = PageActive(page);

Why are we saving the active state? Page cannot be moved between LRUs 
while we hold the lru lock anyways.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
