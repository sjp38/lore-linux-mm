Date: Thu, 3 May 2007 09:52:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.22 -mm merge plans -- vm bugfixes
Message-Id: <20070503095224.77e89dbf.akpm@linux-foundation.org>
In-Reply-To: <46393BA7.6030106@yahoo.com.au>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	<4636FDD7.9080401@yahoo.com.au>
	<Pine.LNX.4.64.0705011931520.16502@blonde.wat.veritas.com>
	<4638009E.3070408@yahoo.com.au>
	<Pine.LNX.4.64.0705021418030.16517@blonde.wat.veritas.com>
	<46393BA7.6030106@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, 03 May 2007 11:32:23 +1000 Nick Piggin <nickpiggin@yahoo.com.au> wrote:

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

Why is that significantly faster than plain old wake_up_page(), which
tests waitqueue_active()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
