Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3F3E06B0071
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 10:53:18 -0500 (EST)
Received: by fxm28 with SMTP id 28so14796485fxm.6
        for <linux-mm@kvack.org>; Wed, 13 Jan 2010 07:53:16 -0800 (PST)
Date: Wed, 13 Jan 2010 23:55:03 +0800
From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 3/3] mm: remove function free_hot_page
Message-ID: <20100113155503.GA2902@hack>
References: <3a3680031001130654q1928df60pde0e3706ea2461c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3a3680031001130654q1928df60pde0e3706ea2461c@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Li Hong <lihong.hi@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 13, 2010 at 10:54:50PM +0800, Li Hong wrote:
>Now fuction 'free_hot_page' is just a wrap of ' free_hot_cold_page' with
>parameter 'cold = 0'. After adding a clear comment for 'free_hot_cold_page', it
>is reasonable to remove a level of call.

How? The compiler can certainly inline it.

>
>Signed-off-by: Li Hong <lihong.hi@gmail.com>
>---
> mm/page_alloc.c |    8 ++------
> mm/swap.c       |    2 +-
> 2 files changed, 3 insertions(+), 7 deletions(-)
>
>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>index 175dd36..c88e03d 100644
>--- a/mm/page_alloc.c
>+++ b/mm/page_alloc.c
>@@ -1073,6 +1073,7 @@ void mark_free_pages(struct zone *zone)
>
> /*
>  * Free a 0-order page
>+ * cold == 1 ? free a cold page : free a hot page
>  */
> static void free_hot_cold_page(struct page *page, int cold)
> {
>@@ -1135,11 +1136,6 @@ out:
>        put_cpu();
> }
>
>-void free_hot_page(struct page *page)
>-{
>-       free_hot_cold_page(page, 0);
>-}
>-
> /*
>  * split_page takes a non-compound higher-order page, and splits it into
>  * n (1<<order) sub-pages: page[0..n]
>@@ -2014,7 +2010,7 @@ void __free_pages(struct page *page, unsigned int order)
> {
>        if (put_page_testzero(page)) {
>                if (order == 0)
>-                       free_hot_page(page);
>+                       free_hot_cold_page(page, 0);
>                else
>                        __free_pages_ok(page, order);
>        }
>diff --git a/mm/swap.c b/mm/swap.c
>index 308e57d..9036b89 100644
>--- a/mm/swap.c
>+++ b/mm/swap.c
>@@ -55,7 +55,7 @@ static void __page_cache_release(struct page *page)
>                del_page_from_lru(zone, page);
>                spin_unlock_irqrestore(&zone->lru_lock, flags);
>        }
>-       free_hot_page(page);
>+       free_hot_cold_page(page, 0);
> }
>
> static void put_compound_page(struct page *page)
>-- 
>1.6.3.3
>--
>To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>Please read the FAQ at  http://www.tux.org/lkml/

-- 
Live like a child, think like the god.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
