Date: Mon, 27 Jun 2005 07:12:20 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [patch 2] mm: speculative get_page
Message-ID: <20050627141220.GM3334@holomorphy.com>
References: <42BF9CD1.2030102@yahoo.com.au> <42BF9D67.10509@yahoo.com.au> <42BF9D86.90204@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42BF9D86.90204@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 27, 2005 at 04:32:38PM +1000, Nick Piggin wrote:
> +static inline struct page *page_cache_get_speculative(struct page **pagep)
> +{
> +	struct page *page;
> +
> +	preempt_disable();
> +	page = *pagep;
> +	if (!page)
> +		goto out_failed;
> +
> +	if (unlikely(get_page_testone(page))) {
> +		/* Picked up a freed page */
> +		__put_page(page);
> +		goto out_failed;
> +	}

So you pick up 0->1 refcount transitions.


On Mon, Jun 27, 2005 at 04:32:38PM +1000, Nick Piggin wrote:
> +	/*
> +	 * preempt can really be enabled here (only needs to be disabled
> +	 * because page allocation can spin on the elevated refcount, but
> +	 * we don't want to hold a reference on an unrelated page for too
> +	 * long, so keep preempt off until we know we have the right page
> +	 */
> +
> +	if (unlikely(PageFreeing(page)) ||

SetPageFreeing is only done in shrink_list(), so other pages in the
buddy bitmaps and/or pagecache pages freed by other methods may not
be found by this. There's also likely trouble with higher-order pages.


On Mon, Jun 27, 2005 at 04:32:38PM +1000, Nick Piggin wrote:
> +			unlikely(page != *pagep)) {
> +		/* Picked up a page being freed, or one that's been reused */
> +		put_page(page);
> +		goto out_failed;
> +	}
> +	preempt_enable();
> +
> +	return page;
> +
> +out_failed:
> +	preempt_enable();
> +	return NULL;
> +}

page != *pagep won't be reliably tripped unless the pagecache
modification has the appropriate memory barriers.

The lockless radix tree lookups are a harder problem than this, and
the implementation didn't look promising. I have other problems to deal
with so I'm not going to go very far into this.

While I agree that locklessness is the right direction for the
pagecache to go, this RFC seems to have too far to go to use it to
conclude anything about the subject.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
