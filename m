Message-ID: <412F47E7.8010500@kolumbus.fi>
Date: Fri, 27 Aug 2004 17:40:39 +0300
From: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] speed up fork performance
References: <Pine.LNX.4.44.0408271006340.10272-100000@chimarrao.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.44.0408271006340.10272-100000@chimarrao.boston.redhat.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: rmk@arm.linux.org.uk, linux-mm@kvack.org, Arjan Van de Ven <arjanv@redhat.com>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:

>OK, this patch is _completely_ untested, but since I'm about to run
>off to a conference I guess I should get it to you anyway.
>
>Basically in 2.6 lru_cache_add_active() takes an extra reference to
>the page, but do_wp_page() and friends don't expect a private anonymous
>page to have 2 references instead of 1.  This little patchlet changes
>can_share_swap_page() and exclusive_swap_page() to expect the extra
>reference.
>
>Note that we cannot test for PageLRU(page) since lru_cache_add_active()
>uses a delayed insertion onto the LRU, so the PG_lru might not get set
>for a while...
>
>Use at your own risk.
>
>--- linux-2.6.9-rc1/mm/swapfile.c.blah	2004-08-27 09:51:54.000000000 -0400
>+++ linux-2.6.9-rc1/mm/swapfile.c	2004-08-27 09:55:38.000000000 -0400
>@@ -291,7 +291,8 @@ static int exclusive_swap_page(struct pa
> 		if (p->swap_map[swp_offset(entry)] == 1) {
> 			/* Recheck the page count with the swapcache lock held.. */
> 			spin_lock_irq(&swapper_space.tree_lock);
>-			if (page_count(page) == 2)
>+			/* Process, swapcache and LRU each have a reference. */
>+			if (page_count(page) == 3)
> 				retval = 1;
> 			spin_unlock_irq(&swapper_space.tree_lock);
> 		}
>@@ -315,15 +316,17 @@ int can_share_swap_page(struct page *pag
> 	if (!PageLocked(page))
> 		BUG();
> 	switch (page_count(page)) {
>-	case 3:
>+	case 4:
> 		if (!PagePrivate(page))
> 			break;
> 		/* Fallthrough */
>-	case 2:
>+	case 3:
> 		if (!PageSwapCache(page))
> 			break;
> 		retval = exclusive_swap_page(page);
> 		break;
>+	case 2:
>+		/* The LRU takes 1 reference */
> 	case 1:
> 		if (PageReserved(page))
> 			break;
>
>--
>
No, the reference taken in lru_cache_add is removed in __pagevec_lru_add.

--Mika


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
