Received: from westrelay03.boulder.ibm.com (westrelay03.boulder.ibm.com [9.17.195.12])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j34DjILg265184
	for <linux-mm@kvack.org>; Mon, 4 Apr 2005 09:45:19 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay03.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j34DjInC180728
	for <linux-mm@kvack.org>; Mon, 4 Apr 2005 07:45:18 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j34DjIRc014178
	for <linux-mm@kvack.org>; Mon, 4 Apr 2005 07:45:18 -0600
Subject: Re: [PATCH 1/6] CKRM: Basic changes to the core kernel
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050402031206.GB23284@chandralinux.beaverton.ibm.com>
References: <20050402031206.GB23284@chandralinux.beaverton.ibm.com>
Content-Type: text/plain
Date: Mon, 04 Apr 2005 06:45:13 -0700
Message-Id: <1112622313.7189.50.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chandra Seetharaman <sekharan@us.ibm.com>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>  static inline void
>  add_page_to_active_list(struct zone *zone, struct page *page)
>  {
>         list_add(&page->lru, &zone->active_list);
>         zone->nr_active++;
> +       ckrm_mem_inc_active(page);
>  }

Are any of the current zone statistics used any more when this is
compiled in?

Also, why does everything have to say ckrm_* on it?  What if somebody
else comes along and wants to use the same functions to do some other
kind of accounting? 

I think names like this are plenty long and descriptive enough:

        mem_inc_active(page);
        clear_page_class(page);
        set_page_class(...);
        
I'd drop the "ckrm_".
        
> +#define PG_ckrm_account                21      /* CKRM accounting */

Are you sure you really need this bit *and* a whole new pointer in
'struct page'?  We already do some tricks with ->mapping so that we can
tell what is stored in it.  You could easily do something with the low
bit of your new structure member.

> @@ -355,6 +356,7 @@ free_pages_bulk(struct zone *zone, int c
>                 /* have to delete it as __free_pages_bulk list manipulates */
>                 list_del(&page->lru);
>                 __free_pages_bulk(page, zone, order);
> +               ckrm_clear_page_class(page);
>                 ret++;
>         }
>         spin_unlock_irqrestore(&zone->lock, flags);

When your option is on, how costly is the addition of code, here?  How
much does it hurt the microbenchmarks?  How much larger does it
make .text?

> +       if (!in_interrupt() && !ckrm_class_limit_ok(ckrm_get_mem_class(p)))
> +               return NULL;

ckrm_class_limit_ok() is called later on in the same hot path, and
there's a for loop in there over each zone.  How expensive is this on
SGI's machines?  What about an 8-node x44[05]?  Why can't you call it
from interrupts?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
