Date: Mon, 5 Mar 2007 10:14:58 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [rfc][patch 2/2] mm: mlocked pages off LRU
In-Reply-To: <20070305161746.GD8128@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0703050948040.6620@schroedinger.engr.sgi.com>
References: <20070305161746.GD8128@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, 5 Mar 2007, Nick Piggin wrote:

> - PageMLock explicitly elevates the page's refcount, so PageMLock pages
>   don't ever get freed (thus requires less awareness in the rest of mm).

Which breaks page migration for mlocked pages.

I think there is still some thinking going on about also removing 
anonymous pages off the LRU if we are out of swap or have no swap. In 
that case we may need page->lru to track these pages so that they can be 
fed back to the LRU when swap is added later.

I was a bit hesitant to use an additional ref counter because we are here 
overloading a refcounter on a LRU field? I have a bad feeling here. There 
are possible race conditions and it seems that earlier approaches failed 
to address those.

> +static void inc_page_mlock(struct page *page)
> +{
> +	BUG_ON(!PageLocked(page));
> +
> +	if (!PageMLock(page)) {
> +		if (!isolate_lru_page(page)) {
> +			SetPageMLock(page);
> +			get_page(page);
> +			set_page_mlock_count(page, 1);
> +		}
> +	} else if (PageMLock(page)) {

You already checked for !PageMlock so PageMlock is true.

> -	if (!migration && ((vma->vm_flags & VM_LOCKED) ||
> -			(ptep_clear_flush_young(vma, address, pte)))) {
> -		ret = SWAP_FAIL;
> -		goto out_unmap;
> +	if (!migration) {
> +		if (vma->vm_flags & VM_LOCKED) {
> +			ret = SWAP_MLOCK;
> +			goto out_unmap;
> +		}
> +		if (ptep_clear_flush_young(vma, address, pte)) {
> +			ret = SWAP_FAIL;
> +			goto out_unmap;
> +		}

Ok you basically keep the first patch of my set. Maybe include that 
explicitly ?

>  /*
> + * This routine is used to map in an anonymous page into an address space:
> + * needed by execve() for the initial stack and environment pages.

Could we have some common code that also covers do_anonymous page etc?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
