Date: Thu, 3 May 2007 13:24:23 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.6.22 -mm merge plans -- vm bugfixes
In-Reply-To: <46393BA7.6030106@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0705031306300.24945@blonde.wat.veritas.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
 <4636FDD7.9080401@yahoo.com.au> <Pine.LNX.4.64.0705011931520.16502@blonde.wat.veritas.com>
 <4638009E.3070408@yahoo.com.au> <Pine.LNX.4.64.0705021418030.16517@blonde.wat.veritas.com>
 <46393BA7.6030106@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, 3 May 2007, Nick Piggin wrote:
> 
> The problem is that lock/unlock_page is expensive on powerpc, and
> if we improve that, we improve more than just the fault handler...
> 
> The attached patch gets performance up a bit by avoiding some
> barriers and some cachelines:

There's a strong whiff of raciness about this...
but I could very easily be wrong.

> Index: linux-2.6/mm/filemap.c
> ===================================================================
> --- linux-2.6.orig/mm/filemap.c	2007-05-02 15:00:26.000000000 +1000
> +++ linux-2.6/mm/filemap.c	2007-05-03 08:34:32.000000000 +1000
> @@ -532,11 +532,13 @@
>   */
>  void fastcall unlock_page(struct page *page)
>  {
> +	VM_BUG_ON(!PageLocked(page));
>  	smp_mb__before_clear_bit();
> -	if (!TestClearPageLocked(page))
> -		BUG();
> -	smp_mb__after_clear_bit(); 
> -	wake_up_page(page, PG_locked);
> +	ClearPageLocked(page);
> +	if (unlikely(test_bit(PG_waiters, &page->flags))) {
> +		clear_bit(PG_waiters, &page->flags);
> +		wake_up_page(page, PG_locked);
> +	}
>  }
>  EXPORT_SYMBOL(unlock_page);
>  
> @@ -568,6 +570,11 @@ __lock_page (diff -p would tell us!)
>  {
>  	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
>  
> +	set_bit(PG_waiters, &page->flags);
> +	if (unlikely(!TestSetPageLocked(page))) {

What happens if another cpu is coming through __lock_page at the
same time, did its set_bit, now finds PageLocked, and so proceeds
to the __wait_on_bit_lock?  But this cpu now clears PG_waiters,
so this task's unlock_page won't wake the other?

> +		clear_bit(PG_waiters, &page->flags);
> +		return;
> +	}
>  	__wait_on_bit_lock(page_waitqueue(page), &wait, sync_page,
>  							TASK_UNINTERRUPTIBLE);
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
