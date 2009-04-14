Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 81CB35F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 05:25:31 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [RFC][PATCH v3 1/6] mm: Don't unmap gup()ed page
Date: Tue, 14 Apr 2009 19:25:44 +1000
References: <20090414151204.C647.A69D9226@jp.fujitsu.com> <20090414151554.C64A.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090414151554.C64A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200904141925.46012.nickpiggin@yahoo.com.au>
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <aarcange@redhat.com>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 14 April 2009 16:16:52 KOSAKI Motohiro wrote:

> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Sugessted-by: Linus Torvalds <torvalds@osdl.org>

"Suggested-by:" ;)

> Cc: Hugh Dickins <hugh@veritas.com>
> Cc: Andrew Morton <akpm@osdl.org>
> Cc: Nick Piggin <nickpiggin@yahoo.com.au>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Jeff Moyer <jmoyer@redhat.com>
> Cc: linux-mm@kvack.org
> ---
>  mm/rmap.c     |   21 +++++++++++++++++++++
>  mm/swapfile.c |   10 +++++++++-
>  2 files changed, 30 insertions(+), 1 deletion(-)
> 
> Index: b/mm/swapfile.c
> ===================================================================
> --- a/mm/swapfile.c	2009-04-11 21:38:33.000000000 +0900
> +++ b/mm/swapfile.c	2009-04-11 21:38:45.000000000 +0900
> @@ -533,6 +533,8 @@ static inline int page_swapcount(struct 
>   * to it.  And as a side-effect, free up its swap: because the old content
>   * on disk will never be read, and seeking back there to write new content
>   * later would only waste time away from clustering.
> + * Caller must hold pte_lock. try_to_unmap() decrement page::_mapcount
> + * and get_user_pages() increment page::_count under pte_lock.
>   */
>  int reuse_swap_page(struct page *page)
>  {
> @@ -547,7 +549,13 @@ int reuse_swap_page(struct page *page)
>  			SetPageDirty(page);
>  		}
>  	}
> -	return count == 1;
> +
> +	/*
> +	 * If we can re-use the swap page _and_ the end
> +	 * result has only one user (the mapping), then
> +	 * we reuse the whole page
> +	 */
> +	return count + page_count(page) == 2;
>  }

I guess this patch does work to close the read-side race, but I slightly don't
like using page_count for things like this. page_count can be temporarily
raised for reasons other than access through their user mapping. Swapcache,
page reclaim, LRU pagevecs, concurrent do_wp_page, etc.


>  /*
> Index: b/mm/rmap.c
> ===================================================================
> --- a/mm/rmap.c	2009-04-11 21:38:33.000000000 +0900
> +++ b/mm/rmap.c	2009-04-12 00:58:58.000000000 +0900
> @@ -773,6 +773,27 @@ static int try_to_unmap_one(struct page 
>  		goto out;
>  
>  	/*
> +	 * Don't pull an anonymous page out from under get_user_pages.
> +	 * GUP carefully breaks COW and raises page count (while holding
> +	 * pte_lock, as we have here) to make sure that the page
> +	 * cannot be freed.  If we unmap that page here, a user write
> +	 * access to the virtual address will bring back the page, but
> +	 * its raised count will (ironically) be taken to mean it's not
> +	 * an exclusive swap page, do_wp_page will replace it by a copy
> +	 * page, and the user never get to see the data GUP was holding
> +	 * the original page for.
> +	 *
> +	 * This test is also useful for when swapoff (unuse_process) has
> +	 * to drop page lock: its reference to the page stops existing
> +	 * ptes from being unmapped, so swapoff can make progress.
> +	 */
> +	if (PageSwapCache(page) &&
> +	    page_count(page) != page_mapcount(page) + 2) {
> +		ret = SWAP_FAIL;
> +		goto out_unmap;
> +	}

I guess it does add another constraint to the VM, ie. not allowed to
unmap an anonymous page with elevated refcount. Maybe not a big deal
now, but I think it is enough that it should be noted. If you squint,
this could actually be more complex/intrusive to the wider VM than my
copy on fork (which is basically exactly like a manual do_wp_page at
fork time).

And.... I don't think this is safe against a concurrent gup_fast()
(which helps my point).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
