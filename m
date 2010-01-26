Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3C4386B00A2
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 13:37:31 -0500 (EST)
Date: Tue, 26 Jan 2010 18:37:07 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 04 of 31] update futex compound knowledge
Message-ID: <20100126183706.GI16468@csn.ul.ie>
References: <patchbomb.1264513915@v2.random> <948638099c17d3da3d6f.1264513919@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <948638099c17d3da3d6f.1264513919@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 02:51:59PM +0100, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Futex code is smarter than most other gup_fast O_DIRECT code and knows about
> the compound internals. However now doing a put_page(head_page) will not
> release the pin on the tail page taken by gup-fast, leading to all sort of
> refcounting bugchecks. Getting a stable head_page is a little tricky.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/kernel/futex.c b/kernel/futex.c
> --- a/kernel/futex.c
> +++ b/kernel/futex.c
> @@ -218,7 +218,7 @@ get_futex_key(u32 __user *uaddr, int fsh
>  {
>  	unsigned long address = (unsigned long)uaddr;
>  	struct mm_struct *mm = current->mm;
> -	struct page *page;
> +	struct page *page, *page_head;
>  	int err;
>  
>  	/*
> @@ -250,10 +250,32 @@ again:
>  	if (err < 0)
>  		return err;
>  
> -	page = compound_head(page);
> -	lock_page(page);
> -	if (!page->mapping) {
> -		unlock_page(page);
> +	page_head = page;
> +	if (unlikely(PageTail(page))) {
> +		put_page(page);
> +		/* serialize against __split_huge_page_splitting() */
> +		local_irq_disable();
> +		if (likely(__get_user_pages_fast(address, 1, 1, &page) == 1)) {

I'm not fully getting from the changelog why the second round through
__get_user_pages_fast() is necessary or why the write parameter is
unconditionally 1.

Is the second round necessary just so compound_head() is called with
interrupts disabled? Is that sufficient?

> +			page_head = compound_head(page);
> +			local_irq_enable();
> +		} else {
> +			local_irq_enable();
> +			goto again;
> +		}
> +	}
> +
> +	lock_page(page_head);
> +	if (unlikely(page_head != page)) {
> +		compound_lock(page_head);
> +		if (unlikely(!PageTail(page))) {
> +			compound_unlock(page_head);
> +			unlock_page(page_head);
> +			put_page(page);
> +			goto again;
> +		}
> +	}
> +	if (!page_head->mapping) {
> +		unlock_page(page_head);
>  		put_page(page);
>  		goto again;
>  	}
> @@ -265,19 +287,21 @@ again:
>  	 * it's a read-only handle, it's expected that futexes attach to
>  	 * the object not the particular process.
>  	 */
> -	if (PageAnon(page)) {
> +	if (PageAnon(page_head)) {
>  		key->both.offset |= FUT_OFF_MMSHARED; /* ref taken on mm */
>  		key->private.mm = mm;
>  		key->private.address = address;
>  	} else {
>  		key->both.offset |= FUT_OFF_INODE; /* inode-based key */
> -		key->shared.inode = page->mapping->host;
> -		key->shared.pgoff = page->index;
> +		key->shared.inode = page_head->mapping->host;
> +		key->shared.pgoff = page_head->index;
>  	}
>  
>  	get_futex_key_refs(key);
>  
> -	unlock_page(page);
> +	if (unlikely(PageTail(page)))
> +		compound_unlock(page_head);
> +	unlock_page(page_head);
>  	put_page(page);
>  	return 0;
>  }
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
