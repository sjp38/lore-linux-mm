Date: Mon, 6 Mar 2006 16:50:39 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] avoid atomic op on page free
Message-Id: <20060306165039.1c3b66d8.akpm@osdl.org>
In-Reply-To: <20060307001015.GG32565@linux.intel.com>
References: <20060307001015.GG32565@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@linux.intel.com>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Benjamin LaHaise <bcrl@linux.intel.com> wrote:
>
> Hello Andrew et al,
> 
> The patch below adds a fast path that avoids the atomic dec and test 
> operation and spinlock acquire/release on page free.  This is especially 
> important to the network stack which uses put_page() to free user 
> buffers.  Removing these atomic ops helps improve netperf on the P4 
> from ~8126Mbit/s to ~8199Mbit/s (although that number fluctuates quite a 
> bit with some runs getting 8243Mbit/s).  There are probably better 
> workloads to see an improvement from this on, but removing 3 atomics and 
> an irq save/restore is good.
> 

Am a bit surprised at those numbers.

> diff --git a/mm/swap.c b/mm/swap.c
> index cce3dda..d6934cf 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -49,7 +49,10 @@ void put_page(struct page *page)
>  {
>  	if (unlikely(PageCompound(page)))
>  		put_compound_page(page);
> -	else if (put_page_testzero(page))
> +	else if (page_count(page) == 1 && !PageLRU(page)) {
> +		set_page_count(page, 0);
> +		free_hot_page(page);
> +	} else if (put_page_testzero(page))
>  		__page_cache_release(page);

Because userspace has to do peculiar things to get its pages taken off the
LRU.  What exactly was that application doing?

The patch adds slight overhead to the common case while providing
improvement to what I suspect is a very uncommon case?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
