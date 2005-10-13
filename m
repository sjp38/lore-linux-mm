Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9DMQNlx015333
	for <linux-mm@kvack.org>; Thu, 13 Oct 2005 18:26:23 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9DMQM1a052074
	for <linux-mm@kvack.org>; Thu, 13 Oct 2005 18:26:23 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j9DMQMdV026540
	for <linux-mm@kvack.org>; Thu, 13 Oct 2005 18:26:22 -0400
Received: from austin.ibm.com (netmail2.austin.ibm.com [9.41.248.176])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j9DMQMaK026535
	for <linux-mm@kvack.org>; Thu, 13 Oct 2005 18:26:22 -0400
Received: from [127.0.0.1] (sig-9-65-8-84.mts.ibm.com [9.65.8.84])
	by austin.ibm.com (8.12.10/8.12.10) with ESMTP id j9DMQKuM039004
	for <linux-mm@kvack.org>; Thu, 13 Oct 2005 17:26:21 -0500
Message-ID: <434EDF0C.7060109@austin.ibm.com>
Date: Thu, 13 Oct 2005 17:26:20 -0500
From: Joel Schopp <jschopp@austin.ibm.com>
Reply-To: jschopp@austin.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Page eviction support in vmscan.c
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Christoph sent this to @vger.kernel.org instead of @kvack.org.  I assume 
he'll resend the original to this list.  Sorry if this messes up threading.

> This patch adds functions that allow the eviction of pages to swap space.
> Page eviction may be useful to migrate pages, suspend programs or for
> ummapping single pages (useful for faulty pages or pages with soft ECC
> failures)

I'm curious what use motivated you to write it.  I think for migration
it would usually make more sense to let the swapper free up LRU memory
and then do a memory to memory migration.  But I'm not really a
migration expert


> swapout_pages does its best to swapout the pages and does multiple passes over the list.
> However, swapout_pages may not be able to evict all pages for a variety of reasons.

Have you thought about using this in combination with the fragmentation
avoidance patches Mel has been posting?  __GFP_USER flag that adds would
go a long way toward determining what can and can't be swapped out.  We
use that for migration with great success.  I'd assume the criteria for
swapout and migration are pretty similar.

>  /*
> + * Swapout evicts the pages on the list to swap space.
> + * This is essentially a dumbed down version of shrink_list

Have you thought about reusing code from shrink list without duplicating
it?  That is a whole lot of duplicated code to maintain twice.

> +		if (PageDirty(page)) {
> +			/* Page is dirty, try to write it out here */
> +			switch(pageout(page, mapping)) {
> +			case PAGE_KEEP:
> +			case PAGE_ACTIVATE:
> +				goto retry_later_locked;
> +			case PAGE_SUCCESS:
> +				goto retry_later;
> +			case PAGE_CLEAN:
> +				; /* try to free the page below */
> +			}
> +                }

Tabs vs spaces?

> +
> +		list_del(&page->lru);
> +                unlock_page(page);
> +		put_page(page);
> +                continue;

Tabs vs spaces?





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
