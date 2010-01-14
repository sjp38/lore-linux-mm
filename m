Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 39CF26B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 17:53:08 -0500 (EST)
Date: Thu, 14 Jan 2010 14:52:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] mm: remove function free_hot_page
Message-Id: <20100114145247.076430b4.akpm@linux-foundation.org>
In-Reply-To: <3a3680031001130654q1928df60pde0e3706ea2461c@mail.gmail.com>
References: <3a3680031001130654q1928df60pde0e3706ea2461c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Hong <lihong.hi@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jan 2010 22:54:50 +0800
Li Hong <lihong.hi@gmail.com> wrote:

> Now fuction 'free_hot_page' is just a wrap of ' free_hot_cold_page' with
> parameter 'cold = 0'. After adding a clear comment for 'free_hot_cold_page', it
> is reasonable to remove a level of call.
> 
> Signed-off-by: Li Hong <lihong.hi@gmail.com>
> ---
>  mm/page_alloc.c |    8 ++------
>  mm/swap.c       |    2 +-
>  2 files changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 175dd36..c88e03d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1073,6 +1073,7 @@ void mark_free_pages(struct zone *zone)
> 
>  /*
>   * Free a 0-order page
> + * cold == 1 ? free a cold page : free a hot page
>   */
>  static void free_hot_cold_page(struct page *page, int cold)
>  {
> @@ -1135,11 +1136,6 @@ out:
>         put_cpu();
>  }
> 
> -void free_hot_page(struct page *page)
> -{
> -       free_hot_cold_page(page, 0);
> -}
> -
>  /*
>   * split_page takes a non-compound higher-order page, and splits it into
>   * n (1<<order) sub-pages: page[0..n]
> @@ -2014,7 +2010,7 @@ void __free_pages(struct page *page, unsigned int order)
>  {
>         if (put_page_testzero(page)) {
>                 if (order == 0)
> -                       free_hot_page(page);
> +                       free_hot_cold_page(page, 0);
>                 else
>                         __free_pages_ok(page, order);
>         }
> diff --git a/mm/swap.c b/mm/swap.c
> index 308e57d..9036b89 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -55,7 +55,7 @@ static void __page_cache_release(struct page *page)
>                 del_page_from_lru(zone, page);
>                 spin_unlock_irqrestore(&zone->lru_lock, flags);
>         }
> -       free_hot_page(page);
> +       free_hot_cold_page(page, 0);
>  }

yup, it's worth removing a level of function call.

We could do that simply by making free_hot_page() an inline function -
that would be a bit neater and wouild generate the same code as your
patch will.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
