Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E6B0A6B00B7
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 18:40:26 -0500 (EST)
Date: Tue, 22 Nov 2011 15:40:23 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch v2 4/4]thp: improve order in lru list for split huge
 page
Message-Id: <20111122154023.bf631f7e.akpm@linux-foundation.org>
In-Reply-To: <1321340661.22361.297.camel@sli10-conroe>
References: <1321340661.22361.297.camel@sli10-conroe>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <jweiner@redhat.com>

On Tue, 15 Nov 2011 15:04:21 +0800
Shaohua Li <shaohua.li@intel.com> wrote:

> Put the tail subpages of an isolated hugepage under splitting in the
> lru reclaim head as they supposedly should be isolated too next.
> 
> Queues the subpages in physical order in the lru for non isolated
> hugepages under splitting. That might provide some theoretical cache
> benefit to the buddy allocator later.
> 
> ...
>
> --- linux.orig/mm/swap.c	2011-11-14 16:12:03.000000000 +0800
> +++ linux/mm/swap.c	2011-11-15 09:15:33.000000000 +0800
> @@ -684,7 +684,7 @@ void lru_add_page_tail(struct zone* zone
>  		if (likely(PageLRU(page)))
>  			head = page->lru.prev;
>  		else
> -			head = &zone->lru[lru].list;
> +			head = zone->lru[lru].list.prev;
>  		__add_page_to_lru_list(zone, page_tail, lru, head);
>  	} else {
>  		SetPageUnevictable(page_tail);

This conflicts with changes in Johannes's "mm: collect LRU list heads
into struct lruvec":

@@ -674,10 +673,10 @@ void lru_add_page_tail(struct zone* zone
 		}
 		update_page_reclaim_stat(zone, page_tail, file, active);
 		if (likely(PageLRU(page)))
-			head = page->lru.prev;
+			__add_page_to_lru_list(zone, page_tail, lru,
+					       page->lru.prev);
 		else
-			head = &zone->lru[lru].list;
-		__add_page_to_lru_list(zone, page_tail, lru, head);
+			add_page_to_lru_list(zone, page_tail, lru);
 	} else {
 		SetPageUnevictable(page_tail);
 		add_page_to_lru_list(zone, page_tail, LRU_UNEVICTABLE);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
